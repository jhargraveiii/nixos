{ lib, autoAddDriverRunpath, cmake, fetchFromGitHub, nix-update-script, stdenv

, config, cudaSupport ? config.cudaSupport, cudaPackages ? { }

, blasSupport ? builtins.all (x: !x) [ cudaSupport ], blas

, pkg-config, mpiSupport ? false # Increases the runtime closure by ~700M
, vulkan-headers, vulkan-loader, ninja, git, mpi }:

let
  # It's necessary to consistently use backendStdenv when building with CUDA support,
  # otherwise we get libstdc++ errors downstream.
  # cuda imposes an upper bound on the gcc version, e.g. the latest gcc compatible with cudaPackages_11 is gcc11
  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
  inherit (lib) cmakeBool cmakeFeature optionals;

  cudaBuildInputs = with cudaPackages; [
    cuda_cccl.dev # <nv/target>

    # A temporary hack for reducing the closure size, remove once cudaPackages
    # have stopped using lndir: https://github.com/NixOS/nixpkgs/issues/271792
    cuda_cudart.dev
    cuda_cudart.lib
    cuda_cudart.static
    libcublas.dev
    libcublas.lib
    libcublas.static
  ];
in effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "llama-cpp";
  version = "2885";

  src = fetchFromGitHub {
    owner = "ggerganov";
    repo = "llama.cpp";
    rev = "refs/tags/b${finalAttrs.version}";
    hash = "sha256-DEvyeYCjHAdUyY+Civ7SxN8QfVeTrnNthW2Yw433Jjg=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  postPatch = ''
    substituteInPlace ./ggml-metal.m \
      --replace-fail '[bundle pathForResource:@"ggml-metal" ofType:@"metal"];' "@\"$out/bin/ggml-metal.metal\";"

    substituteInPlace ./scripts/build-info.cmake \
      --replace-fail 'set(BUILD_NUMBER 0)' 'set(BUILD_NUMBER ${finalAttrs.version})' \
      --replace-fail 'set(BUILD_COMMIT "unknown")' "set(BUILD_COMMIT \"$(cat COMMIT)\")"
  '';

  nativeBuildInputs = [ cmake ninja pkg-config git ]
    ++ optionals cudaSupport [ cudaPackages.cuda_nvcc autoAddDriverRunpath ];

  buildInputs = optionals cudaSupport cudaBuildInputs
    ++ optionals mpiSupport [ mpi ];

  cmakeFlags = [
    # -march=native is non-deterministic; override with platform-specific flags if needed
    (cmakeBool "LLAMA_NATIVE" false)
    (cmakeBool "BUILD_SHARED_SERVER" true)
    (cmakeBool "BUILD_SHARED_LIBS" true)
    (cmakeBool "BUILD_SHARED_LIBS" true)
    (cmakeBool "LLAMA_BLAS" blasSupport)
    (cmakeBool "LLAMA_CUDA" cudaSupport)
    (cmakeBool "LLAMA_MPI" mpiSupport)
  ] ++ optionals cudaSupport [
    (with cudaPackages.flags;
      cmakeFeature "CMAKE_CUDA_ARCHITECTURES"
      (builtins.concatStringsSep ";" (map dropDot cudaCapabilities)))
  ];

  # upstream plans on adding targets at the cmakelevel, remove those
  # additional steps after that
  postInstall = ''
    mv $out/bin/main $out/bin/llama
    mv $out/bin/server $out/bin/llama-server
    mkdir -p $out/include
    cp $src/llama.h $out/include/
  '';

  passthru.updateScript = nix-update-script {
    attrPath = "llama-cpp";
    extraArgs = [ "--version-regex" "b(.*)" ];
  };

  meta = with lib; {
    description = "Port of Facebook's LLaMA model in C/C++";
    homepage = "https://github.com/ggerganov/llama.cpp/";
    license = licenses.mit;
    mainProgram = "llama";
    maintainers = with maintainers; [ dit7ya elohmeier philiptaron ];
    platforms = platforms.unix;
  };
})
