{ lib
, stdenv
, fetchurl
, bison
, flex
, buildsystem
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netsurf-nsgenbind";
  version = "0.8";

  src = ../nsgenbind;

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [ buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    homepage = "https://www.netsurf-browser.org/";
    description = "Generator for JavaScript bindings for netsurf browser";
    license = lib.licenses.mit;
    inherit (buildsystem.meta) maintainers platforms;
  };
})
