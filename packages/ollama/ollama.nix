{ pkgs, lib, buildGo122Module, fetchFromGitHub, fetchpatch, buildEnv, linkFarm
, overrideCC, makeWrapper, stdenv, writeShellScriptBin

, cmake, gcc12, clblast, libdrm, rocmPackages, cudaPackages, linuxPackages

, config
# one of `[ null false "rocm" "cuda" ]`
, acceleration ? null }:

let
  pname = "ollama";
  # don't forget to invalidate all hashes each update
  version = "0.1.38";

  src = fetchFromGitHub {
    owner = "jmorganca";
    repo = "ollama";
    rev = "v${version}";
    hash = "sha256-9HHR48gqETYVJgIaDH8s/yHTrDPEmHm80shpDNS+6hY=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-zOQGhNcGNlQppTqZdPfx+y4fUrxH0NOUl38FN8J6ffE=";
  # ollama's patches of llama.cpp's example server
  # `ollama/llm/generate/gen_common.sh` -> "apply temporary patches until fix is upstream"
  # each update, these patches should be synchronized with the contents of `ollama/llm/patches/`
  llamacppPatches = [
    (preparePatch "02-clip-log.diff"
      "sha256-rMWbl3QgrPlhisTeHwD7EnGRJyOhLB4UeS7rqa0tdXM=")
    (preparePatch "03-load_exception.diff"
      "sha256-1DfNahFYYxqlx4E4pwMKQpL+XR0bibYnDFGt6dCL4TM=")
    (preparePatch "04-metal.diff"
      "sha256-Ne8J9R8NndUosSK0qoMvFfKNwqV5xhhce1nSoYrZo7Y=")
  ];

  preparePatch = patch: hash:
    fetchpatch {
      url = "file://${src}/llm/patches/${patch}";
      inherit hash;
      stripLen = 1;
      extraPrefix = "llm/llama.cpp/";
    };

  enableCuda = true;

  cudaToolkit = buildEnv {
    name = "cuda-toolkit";
    ignoreCollisions =
      true; # FIXME: find a cleaner way to do this without ignoring collisions
    paths = [
      cudaPackages.cudatoolkit
      cudaPackages.cuda_cudart
      cudaPackages.cuda_cudart.static
      cudaPackages.cudnn
      cudaPackages.tensorrt
      cudaPackages.cuda_nvcc
    ];
  };

  envSetupHook = writeShellScriptBin "env-setup-hook.sh" ''
    export CUDA_USE_TENSOR_CORES=yes
    export GGML_CUDA_FORCE_MMQ=yes 
    export LD_LIBRARY_PATH=${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${cudaPackages.tensorrt}/lib:${cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH
    export NVCC_FLAGS=" -Xptxas -O3 -arch=sm_89 -code=sm_89 -O3"
    export OLLAMA_CUSTOM_CPU_DEFS=" -DBLAS_LIBRARIES=${pkgs.amd-blis}/lib/libblis-mt.so -DBLAS_INCLUDE_DIRS=${pkgs.amd-blis}/include/blis -DLLAMA_BLAS=on -DLLAMA_BLAS_VENDOR=FLAME -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_F16C=on -DLLAMA_FMA=on"
  '';

  runtimeLibs = lib.optionals enableCuda [
    linuxPackages.nvidia_x11
    cudaPackages.cudnn
    cudaPackages.tensorrt
  ];

  goBuild = if enableCuda then
    buildGo122Module.override { stdenv = overrideCC stdenv gcc12; }
  else
    buildGo122Module;
  inherit (lib) licenses platforms maintainers;
in goBuild ((lib.optionalAttrs enableCuda {
  CUDA_LIB_DIR = "${cudaToolkit}/lib";
  CUDACXX = "${cudaToolkit}/bin/nvcc";
  CUDAToolkit_ROOT = cudaToolkit;
}) // {
  inherit pname version src vendorHash;

  nativeBuildInputs = [ envSetupHook cmake ]
    ++ lib.optionals (enableCuda) [ makeWrapper ];

  buildInputs = lib.optionals enableCuda [
    cudaPackages.cuda_cudart
    cudaPackages.cudnn
    cudaPackages.tensorrt
  ];

  patches = [
    # disable uses of `git` in the `go generate` script
    # ollama's build script assumes the source is a git repo, but nix removes the git directory
    # this also disables necessary patches contained in `ollama/llm/patches/`
    # those patches are added to `llamacppPatches`, and reapplied here in the patch phase
    ./disable-git.patch
  ] ++ llamacppPatches;
  postPatch = ''
    # replace inaccurate version number with actual release version
    substituteInPlace version/version.go --replace 0.0.0 '${version}'
  '';

  preBuild = ''
    # disable uses of `git`, since nix removes the git directory
    export OLLAMA_SKIP_PATCHING=true

    # build llama.cpp libraries for ollama
    go generate ./...
  '';

  postFixup = ''
    # the app doesn't appear functional at the moment, so hide it
    mv "$out/bin/app" "$out/bin/.ollama-app"
  '' + lib.optionalString (enableCuda) ''
    # expose runtime libraries necessary to use the gpu
    mv "$out/bin/ollama" "$out/bin/.ollama-unwrapped"
    makeWrapper "$out/bin/.ollama-unwrapped" "$out/bin/ollama"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/jmorganca/ollama/version.Version=${version}"
    "-X=github.com/jmorganca/ollama/server.mode=release"
  ];

  meta = {
    description = "Get up and running with large language models locally";
    homepage = "https://github.com/ollama/ollama";
    changelog = "https://github.com/ollama/ollama/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "ollama";
    maintainers = with maintainers; [ abysssol dit7ya elohmeier ];
  };
})
