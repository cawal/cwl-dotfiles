# Disko do host fi — LVM sobre LUKS com /home e /var/lib/docker separados.
# Disco NVMe único (nvme0n1, SK hynix ~1024G). Ver ../../common/disko-lvm-luks.nix.
#
# Importado pela config do fi (via flake.nix, na master) — gera
# fileSystems/swapDevices/boot.initrd.luks. Seguro no sistema em execução
# porque o pool /dev/mapper/pool-* já existe. Também consumido pelo
# `disko run ./nixos/hosts/fi/disko.nix` no live USB durante a instalação.
# Ver AGENTS.md → "Instalar/reinstalar um host com disko".
import ../../common/disko-lvm-luks.nix {
  device = "/dev/nvme0n1";
  # 16G de RAM: swap 24G cabe a imagem de hibernação com folga.
  swapSize = "24G";
  # SO + /nix/store. Maior que o navi (70G) porque fi tem CUDA + gaming,
  # que engordam o /nix/store. LVM permite redimensionar depois se apertar.
  rootSize = "100G";
  # Docker pesado isolado num LV próprio: encher /var/lib/docker não afeta o /.
  dockerSize = "250G";
  # /home fica com o resto (~578G).
}
