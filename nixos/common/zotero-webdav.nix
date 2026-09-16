# Servidor WebDAV para o file sync do Zotero (só o host fi hospeda isto).
#
# O Zotero sincroniza em duas camadas: os metadados (itens, notas, tags) passam
# pelos servidores do Zotero (grátis, ilimitado) e os ANEXOS (PDFs etc.) vão por
# WebDAV. Este módulo sobe um WebDAV enxuto em nginx para servir os anexos na LAN
# — resolve o uso no tablet Android e em outros notebooks (o Syncthing da pasta
# de dados, que o app de Android não lê, é aposentado). Ver o plano em
# ~/.claude/plans (tender-chasing-allen.md) para o passo a passo de migração.
#
# nginx traz o ngx_http_dav_module por padrão (PUT/DELETE/MKCOL/COPY/MOVE);
# nginxModules.dav adiciona PROPFIND/OPTIONS, que o Zotero exige. Basic Auth via
# htpasswd (leitura livre sob ProtectSystem=strict).
#
# Os dados NÃO ficam em /home: o serviço nginx roda com ProtectHome=true e
# ProtectSystem=strict, então /home é invisível e o resto do FS é read-only. Por
# isso usamos StateDirectory (/var/lib/zotero-webdav), que o systemd cria como
# nginx:nginx E marca como gravável no sandbox. A biblioteca de anexos é pequena
# (~centenas de MB), cabe folgado na LV / (não precisa da LV /home).
#
# CONFIGURAR o Zotero (Preferências → Sync → File Syncing) com URL
# http://fi.local:7777/ — o próprio Zotero acrescenta /zotero/ à URL base. Antes
# do primeiro uso, criar o htpasswd (a pasta já existe após o switch):
#   nix-shell -p apacheHttpd --run \
#     "sudo htpasswd -c -B /var/lib/zotero-webdav/htpasswd zotero"
{ config, pkgs, lib, ... }:

let
  davRoot = "/var/lib/zotero-webdav";
  htpasswd = "${davRoot}/htpasswd";
  port = 7777;
in
{
  services.nginx = {
    enable = true;
    # ngx_http_dav_module já vem embutido; isto adiciona PROPFIND/OPTIONS.
    additionalModules = [ pkgs.nginxModules.dav ];
    recommendedGzipSettings = true;

    virtualHosts."zotero-webdav" = {
      listen = [ { addr = "0.0.0.0"; inherit port; } ];
      locations."/zotero/" = {
        root = davRoot; # /zotero/ → ${davRoot}/zotero/
        extraConfig = ''
          dav_methods PUT DELETE MKCOL COPY MOVE;
          dav_ext_methods PROPFIND OPTIONS;
          create_full_put_path on;
          dav_access user:rw group:rw all:r;
          # PDFs grandes: sem limite de corpo e temp no MESMO filesystem que o
          # destino, senão o rename final do PUT falha com cross-device.
          client_max_body_size 0;
          client_body_temp_path ${davRoot}/.nginx-tmp;
          auth_basic "Zotero WebDAV";
          auth_basic_user_file ${htpasswd};
          autoindex on;
        '';
      };
    };
  };

  # Cria /var/lib/zotero-webdav (+ subpasta zotero) como nginx:nginx e — crucial
  # — inclui o caminho no conjunto gravável do sandbox systemd do nginx
  # (ProtectSystem=strict deixa todo o resto read-only). Sem isto o nginx não
  # consegue nem criar o temp nem gravar os anexos. StateDirectory persiste
  # entre reinícios, então o htpasswd guardado aqui sobrevive.
  systemd.services.nginx.serviceConfig.StateDirectory = [
    "zotero-webdav"
    "zotero-webdav/zotero"
  ];

  networking.firewall.allowedTCPPorts = [ port ];
}
