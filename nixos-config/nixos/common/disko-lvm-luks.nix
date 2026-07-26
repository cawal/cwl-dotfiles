# Layout de disco reutilizável: LVM sobre LUKS, com /home separado.
#
# Um único container LUKS (uma senha no boot) contendo um VG LVM com volumes
# lógicos para root, home e swap. /home separado sobrevive a reinstalar o SO.
#
# Uso (num disko.nix por host):
#   import ../../common/disko-lvm-luks.nix { device = "/dev/sda"; }
#
# Passe `dockerSize` para dar ao Docker um LV próprio em /var/lib/docker — assim
# o Docker enchendo não afeta o /. Sem `dockerSize`, /var/lib/docker fica no root.
#
# Requer que o host importe também `disko.nixosModules.disko` (feito no flake.nix).
# É lido pelo `disko run` por caminho E entra no build do sistema (gera
# fileSystems/swapDevices/boot.initrd.luks a partir daqui).

{ device
, swapSize ? "8G"
, rootSize ? "80G"      # guarda /nix/store (e /var/lib/docker se dockerSize=null); resto vai p/ /home
, dockerSize ? null     # se setado, LV próprio p/ /var/lib/docker (Docker isolado do /)
, espSize ? "1G"
, vgName ? "pool"
, luksName ? "crypted"
}:

{
  disko.devices = {
    disk.main = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = espSize;
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = luksName;
              settings.allowDiscards = true;
              content = {
                type = "lvm_pv";
                vg = vgName;
              };
            };
          };
        };
      };
    };

    lvm_vg.${vgName} = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = swapSize;
          content.type = "swap";
        };
        root = {
          size = rootSize;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
        home = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        };
      } // (if dockerSize == null then {} else {
        docker = {
          size = dockerSize;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/var/lib/docker";
          };
        };
      });
    };
  };
}
