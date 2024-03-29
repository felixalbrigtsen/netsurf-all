{ lib
, stdenv
, fetchurl
, buildsystem
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netsurf-libwapcaplet";
  version = "0.4.3";

  src = ../libwapcaplet;

  buildInputs = [ buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${buildsystem}/share/netsurf-buildsystem"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=cast-function-type";

  meta = {
    homepage = "https://www.netsurf-browser.org/projects/libwapcaplet/";
    description = "String internment library for netsurf browser";
    license = lib.licenses.mit;
    inherit (buildsystem.meta) maintainers platforms;
  };
})
