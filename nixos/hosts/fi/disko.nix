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
  # que engordam o /nix/store.
  #
  # Era 100G até 2026-10-26. Um `switch` é atômico, então as duas closures do
  # sistema — a atual e a nova — coexistem durante a operação, ~40G cada. Em
  # 100G isso não cabia: o bump do pin estável encheu o disco e falhou
  # (2026-10-21), o que mantinha `system.autoUpgrade` desligado por falta de
  # espaço, não por escolha. Ver docs/RESIZE-LV-FI.md.
  rootSize = "200G";
  # Docker pesado isolado num LV próprio: encher /var/lib/docker não afeta o /.
  #
  # Era 250G; reduzido para pagar o aumento da raiz. O LV tinha 32G em uso de
  # 246G, e o conteúdo (imagens + volumes do Supabase local) é de teste e
  # reconstruível a partir das migrations. A SOMA root+docker é 350G nos dois
  # casos, DE PROPÓSITO: o LV de home é `100%FREE`, então mexer apenas nestes
  # dois não desloca /home nem deixa extent sobrando no VG.
  dockerSize = "150G";
  # /home fica com o resto (~578G).
}
