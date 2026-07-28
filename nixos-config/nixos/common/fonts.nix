# Fontes do sistema (nixpkgs, sem overlay).
#
# Importado por desktop.nix. Para adicionar uma fonte, inclua o pacote em
# `fonts.packages` e, se for virar padrão, ajuste `fontconfig.defaultFonts`.
#
# Nerd Fonts vêm do namespace `nerd-fonts.<nome>` (NixOS 24.11+; o pacote
# monolítico `nerdfonts` com override foi removido). Liste os nomes com:
#   nix eval --raw --impure --expr \
#     'builtins.concatStringsSep "\n" (builtins.attrNames (import <nixpkgs> {}).nerd-fonts)'
#
# Google Fonts: `google-fonts` traz a coleção inteira (~2GB). Para poucas
# famílias, restrinja: (google-fonts.override { fonts = [ "Inter" "Roboto" ]; }).

{ config, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;   # base: DejaVu, Liberation, Noto core

    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.iosevka
      nerd-fonts.monoid
      nerd-fonts.roboto-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      noto-fonts
      noto-fonts-color-emoji
    ];

    fontconfig.defaultFonts = {
      monospace = [ "Hack Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif     = [ "Noto Serif" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
