// Barreira contra leitura de segredos: bloqueia .env e comandos que cospem
// tokens/secrets. Portado para a API de plugins do OpenCode V2.
// Ver https://opencode.ai/v2/docs/build/plugins/migrate-v1
//
// POR QUE .js E SEM IMPORT (não é descuido — é requisito):
// Este arquivo chega ao opencode como SYMLINK (stow: ~/.config/opencode/plugins/
// -> este repo). A resolução de módulo segue o realpath, então um
// `import { Plugin } from '@opencode/plugin'` seria procurado a partir do repo,
// que não tem node_modules — e o plugin falha silenciosamente ao carregar.
// No V1 passava batido porque era `import type`, apagado na compilação; o V2
// precisa do import em runtime. Por isso: objeto literal, nenhum import bare, e
// .js para não depender de transpilação de TS dentro do runtime.
// É o mesmo formato que o plugin do herdr usa, que comprovadamente carrega.
//
// Verificar se está ativo: `opencode plugin list` deve mostrar cwl.env-protection.

const forbiddenFilePatterns = [
  {
    regex: /\.env.*/,
    msg: 'Do not read .env files',
  },
];

const forbiddenCommandPatterns = [
  {
    regex: /kubectl .*get .*secret/,
    msg: 'Do not read kubernetes secrets',
  },
  {
    regex: /gcloud .*secrets/,
    msg: 'Do not read gcloud secrets',
  },
  {
    regex: /gh auth token/,
    msg: 'Do not read github tokens',
  },
  {
    regex: /gh auth status --show-token/,
    msg: 'Do not read github tokens',
  },
];

// O guia documenta `event.input` como os argumentos da chamada; a V1 usava
// `output.args`. Como isto é barreira de segurança, lemos os dois em vez de
// falhar aberto se o campo mudar numa 2.x posterior.
function argsOf(event) {
  return (event && (event.input ?? event.args)) || {};
}

// No V2 a ação de permissão virou `shell`; o nome da *tool* no evento não está
// documentado no guia, então aceitamos os dois rótulos.
function isShellTool(tool) {
  return tool === 'shell' || tool === 'bash';
}

function guard(event) {
  const args = argsOf(event);
  const tool = String((event && event.tool) || '');

  for (const { regex, msg } of forbiddenFilePatterns) {
    const readingForbiddenPathDirectly =
      tool === 'read' && !!args.filePath && regex.test(args.filePath);

    const readingForbiddenPathViaShell =
      isShellTool(tool) &&
      !!args.command &&
      /(cat|bat|rg|grep)/.test(args.command) &&
      regex.test(args.command);

    const readingForbiddenPathViaGrep =
      tool === 'grep' && !!args.include && /(\.env)/.test(args.include);

    if (
      readingForbiddenPathDirectly ||
      readingForbiddenPathViaShell ||
      readingForbiddenPathViaGrep
    ) {
      throw new Error(msg);
    }
  }

  for (const { regex, msg } of forbiddenCommandPatterns) {
    if (isShellTool(tool) && !!args.command && regex.test(args.command)) {
      throw new Error(msg);
    }
  }
}

export default {
  id: 'cwl.env-protection',
  async setup(ctx) {
    await ctx.tool.hook('execute.before', guard);
  },
};
