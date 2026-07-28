# Disko do host navi — LVM sobre LUKS com /home separado.
# Disco único SATA (sda, 223,6 GB). Ver ../../common/disko-lvm-luks.nix.
#
# NÃO é importado pela config do navi na branch nixos-navi (o disco atual ainda
# é LUKS cru). É consumido:
#   - pelo `disko run ./nixos/hosts/navi/disko.nix` no live USB, e
#   - pelo build do sistema na branch navi-disko (via flake.nix).
import ../../common/disko-lvm-luks.nix {
  device = "/dev/sda";
  # navi é máquina de apoio (Docker pesado fica no fi). SO ocupa ~32G hoje;
  # 70G dá >2x de folga. LVM permite redimensionar depois se apertar.
  rootSize = "70G";
}
