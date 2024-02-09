{ lib
, stdenv
, fetchurl
, gperf
, pkg-config
, buildsystem
, libdom
, libhubbub
, libparserutils
, libwapcaplet
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netsurf-libsvgtiny";
  version = "0.1.8";

  src = ../libsvgtiny;

  nativeBuildInputs = [
    gperf
    pkg-config
  ];

  buildInputs = [
    buildsystem
    libdom
    libhubbub
    libparserutils
    libwapcaplet
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    homepage = "https://www.netsurf-browser.org/projects/libsvgtiny/";
    description = "NetSurf SVG decoder";
    license = lib.licenses.mit;
    inherit (buildsystem.meta) maintainers platforms;
  };
})
