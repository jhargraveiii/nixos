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
  rocmPackages,
  cudaPackages,
  linuxPackages,
  darwin,

  testers,
  ollama,

  config,
  # one of `[ null false "rocm" "cuda" ]`
  acceleration ? null,
}:
let
  pname = "ollama";
  # don't forget to invalidate all hashes each update
  version = "0.1.48";

  src = fetchFromGitHub {
    owner = "jmorganca";
    repo = "ollama";
    rev = "v${version}";
    hash = "sha256-rMStHUFC88TXIH/1c9bCOU0csnEZHOhWKBlLKarmCmE=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-LNH3mpxIrPMe5emfum1W10jvXIjKC6GkGcjq1HhpJQo=";
  # ollama's patches of llama.cpp's example server
  # `ollama/llm/generate/gen_common.sh` -> "apply temporary patches until fix is upstream"
  # each update, these patches should be synchronized with the contents of `ollama/llm/patches/`
  # ollama's patches of llama.cpp's example server
  # `ollama/llm/generate/gen_common.sh` -> "apply temporary patches until fix is upstream"
  # each update, these patches should be synchronized with the contents of `ollama/llm/patches/`
  llamacppPatches = [
    (preparePatch "01-load-progress.diff" "sha256-K4GryCH/1cl01cyxaMLX3m4mTE79UoGwLMMBUgov+ew=")
    (preparePatch "02-clip-log.diff" "sha256-rMWbl3QgrPlhisTeHwD7EnGRJyOhLB4UeS7rqa0tdXM=")
    (preparePatch "03-load_exception.diff" "sha256-0XfMtMyg17oihqSFDBakBtAF0JwhsR188D+cOodgvDk=")
    (preparePatch "04-metal.diff" "sha256-Ne8J9R8NndUosSK0qoMvFfKNwqV5xhhce1nSoYrZo7Y=")
    (preparePatch "05-default-pretokenizer.diff" "sha256-JnCmFzAkmuI1AqATG3jbX7nGIam4hdDKqqbG5oh7h70=")
    (preparePatch "06-qwen2.diff" "sha256-nMtoAQUsjYuJv45uTlz8r/K1oF5NUsc75SnhgfSkE30=")
    (preparePatch "07-gemma.diff" "sha256-dKJrRvg/XC6xtwxLHZ7lFkLNMwT8Ugmd5xRPuKQDXvU=")
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
    "rocm"
    "cuda"
  ];
  validateFallback = lib.warnIf (config.rocmSupport && config.cudaSupport) (lib.concatStrings [
    "both `nixpkgs.config.rocmSupport` and `nixpkgs.config.cudaSupport` are enabled, "
    "but they are mutually exclusive; falling back to cpu"
  ]) (!(config.rocmSupport && config.cudaSupport));
  validateLinux =
    api:
    (lib.warnIfNot stdenv.isLinux
      "building ollama with `${api}` is only supported on linux; falling back to cpu"
      stdenv.isLinux
    );
  shouldEnable =
    assert accelIsValid;
    mode: fallback:
    ((acceleration == mode) || (fallback && acceleration == null && validateFallback))
    && (validateLinux mode);

  enableRocm = shouldEnable "rocm" config.rocmSupport;
  enableCuda = shouldEnable "cuda" config.cudaSupport;

  rocmClang = linkFarm "rocm-clang" { llvm = rocmPackages.llvm.clang; };
  rocmPath = buildEnv {
    name = "rocm-path";
    paths = [
      rocmPackages.clr
      rocmPackages.hipblas
      rocmPackages.rocblas
      rocmPackages.rocsolver
      rocmPackages.rocsparse
      rocmPackages.rocm-device-libs
      rocmClang
    ];
  };

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

  runtimeLibs =
    [
      pkgs.amd-blis
      pkgs.amd-libflame
    ]
    ++ lib.optionals enableRocm [ rocmPackages.rocm-smi ]
    ++ lib.optionals enableCuda [ linuxPackages.nvidia_x11 ];

  appleFrameworks = darwin.apple_sdk_11_0.frameworks;
  metalFrameworks = [
    appleFrameworks.Accelerate
    appleFrameworks.Metal
    appleFrameworks.MetalKit
    appleFrameworks.MetalPerformanceShaders
  ];

  goBuild =
    if enableCuda then
      buildGo122Module.override { stdenv = overrideCC stdenv gcc12; }
    else
      buildGo122Module;
  inherit (lib) licenses platforms maintainers;
in
goBuild (
  (lib.optionalAttrs enableRocm {
    ROCM_PATH = rocmPath;
    CLBlast_DIR = "${clblast}/lib/cmake/CLBlast";
  })
  // (lib.optionalAttrs enableCuda {
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

    nativeBuildInputs =
      [ cmake ]
      ++ lib.optionals enableRocm [ rocmPackages.llvm.bintools ]
      ++ lib.optionals (enableRocm || enableCuda) [ makeWrapper ]
      ++ lib.optionals stdenv.isDarwin metalFrameworks;

    buildInputs =
      [
        pkgs.amd-blis
        pkgs.amd-libflame
      ]
      ++ lib.optionals enableRocm [
        rocmPackages.clr
        rocmPackages.hipblas
        rocmPackages.rocblas
        rocmPackages.rocsolver
        rocmPackages.rocsparse
        libdrm
      ]
      ++ lib.optionals enableCuda [
        cudaPackages.cuda_cudart
        cudaPackages.tensorrt
        cudaPackages.cudnn
        cudaPackages.libcublas.dev
        cudaPackages.libcublas.lib
        cudaPackages.libcublas.static
      ]
      ++ lib.optionals stdenv.isDarwin metalFrameworks;

    patches = [
      # disable uses of `git` in the `go generate` script
      # ollama's build script assumes the source is a git repo, but nix removes the git directory
      # this also disables necessary patches contained in `ollama/llm/patches/`
      # those patches are added to `llamacppPatches`, and reapplied here in the patch phase
      ./disable-git.patch
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
      + lib.optionalString (enableRocm || enableCuda) ''
        # expose runtime libraries necessary to use the gpu
        mv "$out/bin/ollama" "$out/bin/.ollama-unwrapped"
        makeWrapper "$out/bin/.ollama-unwrapped" "$out/bin/ollama" ${lib.optionalString enableRocm "--set-default HIP_PATH '${rocmPath}' "} \
          --suffix LD_LIBRARY_PATH : '/run/opengl-driver/lib:${lib.makeLibraryPath runtimeLibs}'
      '';

    ldflags = [
      "-s"
      "-w"
      "-X=github.com/jmorganca/ollama/version.Version=${version}"
      "-X=github.com/jmorganca/ollama/server.mode=release"
    ];

    passthru.tests = {
      service = nixosTests.ollama;
      rocm = pkgs.ollama.override { acceleration = "rocm"; };
      cuda = pkgs.ollama.override { acceleration = "cuda"; };
      version = testers.testVersion {
        inherit version;
        package = ollama;
      };
    };

    meta = {
      description = "Get up and running with large language models locally";
      homepage = "https://github.com/ollama/ollama";
      changelog = "https://github.com/ollama/ollama/releases/tag/v${version}";
      license = licenses.mit;
      platforms = platforms.unix;
      mainProgram = "ollama";
      maintainers = with maintainers; [
        abysssol
        dit7ya
        elohmeier
      ];
    };
  }
)
