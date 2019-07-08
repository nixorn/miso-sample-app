{ pkgs ? import <nixpkgs> {} }:

let
  pinnedPkgs = import (pkgs.fetchFromGitHub {
    owner="NixOS";
    repo="nixpkgs-channels";
    rev="1d36ad6d16dbf1d3937f899a087a4360332eb141";
    sha256="0rf1n61xlbvanrknh7g9884qjy6wmwc5x42by3f9vxqmfhz906sq";
  }){};

  hlib = pinnedPkgs.haskell.lib;
  dontCheck = hlib.dontCheck;
  disableCabalFlag = hlib.disableCabalFlag;
  ghcjs84 = pinnedPkgs.haskell.packages.ghcjs84;
  ghcjs = ghcjs84.override {
     overrides = self: super: {
      # doctest doesn't work on ghcjs, but sometimes dontCheck doesn't seem to get rid of the dependency
      doctest = pinnedPkgs.lib.warn "ignoring dependency on doctest" null;

      # These packages require doctest
      comonad = dontCheck super.comonad;
      http-types = dontCheck super.http-types;
      lens = disableCabalFlag (disableCabalFlag (dontCheck super.lens) "test-properties") "test-doctests";
      pgp-wordlist = dontCheck super.pgp-wordlist;
      prettyprinter = dontCheck super.prettyprinter;
      semigroupoids = disableCabalFlag super.semigroupoids "doctests";
      these = dontCheck super.these;
      servant = dontCheck super.servant;

      # Convenience: tests take long to finish
      megaparsec = dontCheck super.megaparsec;
      http-media = dontCheck super.http-media;
      tasty-quickcheck = dontCheck super.tasty-quickcheck;
      scientific = dontCheck super.scientific;
      tests = dontCheck super.tests;
      aeson = dontCheck super.aeson;

     };
  };

  miso = ghcjs.callCabal2nix "miso" (pinnedPkgs.fetchFromGitHub {
    owner  = "dmjio";
    repo   = "miso";
    rev    = "bb2be3264ff3c6aa3b18e471d7cf04296024059b";
    sha256 = "07k1rlvl9g027fp2khl9kiwla4rcn9sv8v2dzm0rzf149aal93vn";
  }){};

in

  ghcjs.callPackage ./app.nix {
    inherit miso;
  }
