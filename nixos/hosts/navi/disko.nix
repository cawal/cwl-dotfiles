# Disko do host navi — LVM sobre LUKS com /home separado.
# Disco único SATA (sda, 223,6 GB). Ver ../../common/disko-lvm-luks.nix.
#
# Importado pela config do navi (via flake.nix, na master) — gera
# fileSystems/swapDevices/boot.initrd.luks. Seguro no sistema em execução
# porque o pool /dev/mapper/pool-* já existe. Também consumido pelo
# `disko run ./nixos/hosts/navi/disko.nix` no live USB durante a instalação.
# Ver AGENTS.md → "Instalar/reinstalar um host com disko".
import ../../common/disko-lvm-luks.nix {
  device = "/dev/sda";
  # navi é máquina de apoio (Docker pesado fica no fi). SO ocupa ~32G hoje;
  # 70G dá >2x de folga. LVM permite redimensionar depois se apertar.
  rootSize = "70G";
}
