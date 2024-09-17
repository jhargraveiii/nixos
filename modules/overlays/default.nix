# This file defines overlays
{ inputs, ... }:
{
  cuda-override = final: prev: {
    cudaPackages = prev.cudaPackages.overrideScope (
      finalCuda: prevCuda: {
        tensorrt = prevCuda.tensorrt.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [
            finalCuda.cudatoolkit
            finalCuda.cudnn_8_9
            finalCuda.libcublas
          ];
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ final.autoPatchelfHook ];
          postFixup = ''
            ${oldAttrs.postFixup or ""}
            addAutoPatchelfSearchPath ${finalCuda.cudnn_8_9}/lib
            addAutoPatchelfSearchPath ${finalCuda.libcublas}/lib
            addAutoPatchelfSearchPath ${finalCuda.cudatoolkit}/lib
          '';
        });
      }
    );
  };

}
