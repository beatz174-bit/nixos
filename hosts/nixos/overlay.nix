{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      dvdauthor = prev.dvdauthor.overrideAttrs (_: { dontBuild = true; });
    })
  ];
}