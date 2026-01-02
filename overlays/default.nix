final: prev: {
  hidrd = prev.hidrd.overrideAttrs (oldAttrs: {
    NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "") + " -Wno-error=unterminated-string-initialization";
  });
}
