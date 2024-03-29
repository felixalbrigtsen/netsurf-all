{ lib
, stdenv
, fetchurl
, perl
, buildsystem
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netsurf-libparserutils";
  version = "0.2.5";

  src = ../libparserutils;

  buildInputs = [
    perl
    buildsystem
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    homepage = "https://www.netsurf-browser.org/projects/libparserutils/";
    description = "Parser building library for netsurf browser";
    license = lib.licenses.mit;
    inherit (buildsystem.meta) maintainers platforms;
  };
})
