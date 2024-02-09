{ lib
, stdenv
, fetchurl
, pkg-config
, buildsystem
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netsurf-libnspsl";
  version = "0.1.6";

  src = ../libnspsl;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    homepage = "https://www.netsurf-browser.org/";
    description = "NetSurf Public Suffix List - Handling library";
    license = lib.licenses.mit;
    inherit (buildsystem.meta) maintainers platforms;
  };
})
