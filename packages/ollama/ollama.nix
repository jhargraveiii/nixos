{
  lib,
  buildGo122Module,
  fetchFromGitHub,
  fetchpatch,
  buildEnv,
  linkFarm,
  overrideCC,
  makeWrapper,
  stdenv,
  nixosTests,
  pkgs,
  cmake,
  gcc12,
  clblast,
  libdrm,
  cudaPackages,
  linuxPackages,
  addDriverRunpath,
  testers,
  ollama,
  config,
  # one of `[ null false "rocm" "cuda" ]`
  acceleration ? null,
}:
let
  pname = "ollama";
  # don't forget to invalidate all hashes each update
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "jmorganca";
    repo = "ollama";
    rev = "v${version}";
    hash = "sha256-baEX0skofhIULe2UAO00rYpFwid6NoBWVbpaQbYcGxY=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-hSxcREAujhvzHVNwnRTfhi0MKI3s8HNavER2VLz6SYk=";
  # ollama's patches of llama.cpp's example server
  # `ollama/llm/generate/gen_common.sh` -> "apply temporary patches until fix is upstream"
  # each update, these patches should be synchronized with the contents of `ollama/llm/patches/`
  llamacppPatches = [
    (preparePatch "0001-llama-3.1-rope-scaling.diff" "sha256-20gmWQI+kIdwGYnItaqb/nwPCPNVt/DulOa4dfxaZXY=")
    (preparePatch "01-load-progress.diff" "sha256-K4GryCH/1cl01cyxaMLX3m4mTE79UoGwLMMBUgov+ew=")
    (preparePatch "02-clip-log.diff" "sha256-rMWbl3QgrPlhisTeHwD7EnGRJyOhLB4UeS7rqa0tdXM=")
    (preparePatch "03-load_exception.diff" "sha256-NJkT/k8Mf8HcEMb0XkaLmyUNKV3T+384JRPnmwDI/sk=")
    (preparePatch "04-metal.diff" "sha256-bPBCfoT3EjZPjWKfCzh0pnCUbM/fGTj37yOaQr+QxQ4=")
    (preparePatch "05-default-pretokenizer.diff" "sha256-50+mzQBQZmYEhYvARHw/dliH0M/gDOYm2uy/yJupDF4=")
    (preparePatch "06-embeddings.diff" "sha256-lqg2SI0OapD9LCoAG6MJW6HIHXEmCTv7P75rE9yq/Mo=")
    (preparePatch "07-clip-unicode.diff" "sha256-1qMJoXhDewxsqPbmi+/7xILQfGaybZDyXc5eH0winL8=")
    (preparePatch "08-pooling.diff" "sha256-7meKWbr06lbVrtxau0AU9BwJ88Z9svwtDXhmHI+hYBk=")
    (preparePatch "09-lora.diff" "sha256-HVDYiqNkuWO9K7aIiT73iiMj5lxMsJC1oqIG4madAPk=")
  ];

  preparePatch =
    patch: hash:
    fetchpatch {
      url = "file://${src}/llm/patches/${patch}";
      inherit hash;
      stripLen = 1;
      extraPrefix = "llm/llama.cpp/";
    };

  accelIsValid = builtins.elem acceleration [
    null
    false
    "cuda"
  ];

  shouldEnable =
    assert accelIsValid;
    mode: fallback: (acceleration == mode) || (fallback && acceleration == null);

  enableCuda = shouldEnable "cuda" config.cudaSupport;
  cudaRequested = shouldEnable "cuda" config.cudaSupport;

  cudaToolkit = buildEnv {
    name = "cuda-toolkit";
    ignoreCollisions = true; # FIXME: find a cleaner way to do this without ignoring collisions
    paths = [
      cudaPackages.cudatoolkit
      cudaPackages.cuda_cudart
      cudaPackages.cuda_cudart.static
      cudaPackages.libcublas.dev
      cudaPackages.libcublas.lib
      cudaPackages.libcublas.static
      cudaPackages.tensorrt
      cudaPackages.cudnn
      pkgs.amd-blis
      pkgs.amd-libflame
    ];
  };

  runtimeLibs = [
    pkgs.amd-blis
    pkgs.amd-libflame
  ] ++ lib.optionals enableCuda [ linuxPackages.nvidia_x11 ];

  wrapperOptions = [
    # ollama embeds llama-cpp binaries which actually run the ai models
    # these llama-cpp binaries are unaffected by the ollama binary's DT_RUNPATH
    # LD_LIBRARY_PATH is temporarily required to use the gpu
    # until these llama-cpp binaries can have their runpath patched
    "--suffix LD_LIBRARY_PATH : '${addDriverRunpath.driverLink}/lib'"
  ];
  wrapperArgs = builtins.concatStringsSep " " wrapperOptions;

  goBuild =
    if enableCuda then
      buildGo122Module.override { stdenv = overrideCC stdenv gcc12; }
    else
      buildGo122Module;
  inherit (lib) licenses platforms maintainers;
in
goBuild (
  (lib.optionalAttrs enableCuda {
    CUDA_LIB_DIR = "${cudaToolkit}/lib";
    CUDACXX = "${cudaToolkit}/bin/nvcc";
    CUDAToolkit_ROOT = cudaToolkit;
  })
  // {
    inherit
      pname
      version
      src
      vendorHash
      ;

    nativeBuildInputs = [ cmake ] ++ lib.optionals (enableCuda) [ makeWrapper ];

    buildInputs =
      [
        pkgs.amd-blis
        pkgs.amd-libflame
      ]
      ++ lib.optionals enableCuda [
        cudaPackages.cuda_cudart
        cudaPackages.tensorrt
        cudaPackages.cudnn
        cudaPackages.libcublas.dev
        cudaPackages.libcublas.lib
        cudaPackages.libcublas.static
      ];
    patches = [
      # disable uses of `git` in the `go generate` script
      # ollama's build script assumes the source is a git repo, but nix removes the git directory
      # this also disables necessary patches contained in `ollama/llm/patches/`
      # those patches are added to `llamacppPatches`, and reapplied here in the patch phase
      ./disable-git.patch
      # disable a check that unnecessarily exits compilation during rocm builds
      # since `rocmPath` is in `LD_LIBRARY_PATH`, ollama uses rocm correctly
      ./disable-lib-check.patch
    ] ++ llamacppPatches;
    postPatch = ''
      # replace inaccurate version number with actual release version
      substituteInPlace version/version.go --replace-fail 0.0.0 '${version}'
    '';
    preBuild = ''
      # disable uses of `git`, since nix removes the git directory
      export OLLAMA_SKIP_PATCHING=true
      # build llama.cpp libraries for ollama

      export CMAKE_CUDA_ARCHITECTURES="89"
      export CMAKE_BUILD_TYPE=Release
      export BLAS_ROOT="${pkgs.amd-blis}"
      export BLAS_LIBRARIES="${pkgs.amd-blis}/lib/libblis-mt.so"
      export BLAS_INCLUDE_DIRS="${pkgs.amd-blis}/include/blis"

      export LD_LIBRARY_PATH="${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.cudaPackages.tensorrt}/lib:$LD_LIBRARY_PATH";
      export LIBRARY_PATH="${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.cudaPackages.tensorrt}/lib:$LIBRARY_PATH";
      export CPATH="${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.cudaPackages.tensorrt}/lib:$CPATH";

      export FORCE_CMAKE=1
      export OLLAMA_CUSTOM_CUDA_DEFS=" -DLLAMA_CUDA_KQUANTS_ITER=2 -DLLAMA_CUDA_FORCE_MMQ=off -DLLAMA_CUDA=on -DLLAMA_CUDA_F16=on"
      export OLLAMA_CUSTOM_CPU_DEFS=" -DBLAS_ROOT=${pkgs.amd-blis} -DBLAS_LIBRARIES=${pkgs.amd-blis}/lib/libblis-mt.so -DBLAS_INCLUDE_DIRS=${pkgs.amd-blis}/include/blis -DLLAMA_BLAS=on -DLLAMA_BLAS_VENDOR=FLAME -DLLAMA_NATIVE=on -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_FMA=on -DLLAMA_F16C=on"
      go generate ./...
    '';
    postFixup =
      ''
        # the app doesn't appear functional at the moment, so hide it
        mv "$out/bin/app" "$out/bin/.ollama-app"
      ''
      + lib.optionalString (enableCuda) ''
        # expose runtime libraries necessary to use the gpu
        wrapProgram "$out/bin/ollama" ${wrapperArgs}
      '';

    ldflags = [
      "-s"
      "-w"
      "-X=github.com/jmorganca/ollama/version.Version=${version}"
      "-X=github.com/jmorganca/ollama/server.mode=release"
    ];

    passthru.tests = {
      inherit ollama;
      service = nixosTests.ollama;
      version = testers.testVersion {
        inherit version;
        package = ollama;
      };
    };
    meta = {
      description =
        "Get up and running with large language models locally"
        + lib.optionalString cudaRequested ", using CUDA for NVIDIA GPU acceleration";
      homepage = "https://github.com/ollama/ollama";
      changelog = "https://github.com/ollama/ollama/releases/tag/v${version}";
      license = licenses.mit;
      platforms = if (cudaRequested) then platforms.linux else platforms.unix;
      mainProgram = "ollama";
      maintainers = with maintainers; [
        abysssol
        dit7ya
        elohmeier
        roydubnium
      ];
    };
  }
)
