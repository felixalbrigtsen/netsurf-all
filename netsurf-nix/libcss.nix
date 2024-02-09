{ lib
, stdenv
, fetchurl
, perl
, pkg-config
, buildsystem
, libparserutils
, libwapcaplet
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netsurf-libcss";
  version = "0.9.2";

  src = ../libcss;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    perl
    buildsystem
    libparserutils
    libwapcaplet
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${buildsystem}/share/netsurf-buildsystem"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=implicit-fallthrough"
    "-Wno-error=${if stdenv.cc.isGNU then "maybe-uninitialized" else "uninitialized"}"
  ];

  meta = {
    homepage = "https://www.netsurf-browser.org/projects/libcss/";
    description = "Cascading Style Sheets library for netsurf browser";
    longDescription = ''
      LibCSS is a CSS parser and selection engine. It aims to parse the forward
      compatible CSS grammar. It was developed as part of the NetSurf project
      and is available for use by other software, under a more permissive
      license.
    '';
    license = lib.licenses.mit;
    inherit (buildsystem.meta) maintainers platforms;
  };
})
