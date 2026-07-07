---
description: Compile results for Monday Meeting
---

Passe pelos meus arquivos de diário de trabalho (Turi) da última semana e compile os principais pontos para a reunião de segunda-feira com o time de produto.

## Verificação cruzada com o Notion

Os diários registram o status dos cards no momento em que foram escritos, mas o board evolui depois disso — em especial, cards concluídos (`Feito`) costumam ser movidos em lote para `Produção` quando uma sprint fecha. Isso não invalida o relato, mas ajuda a confirmar o que realmente aconteceu na semana e a não perder nada que só avançou depois do diário ter sido escrito.

Use o `ntn` (Notion CLI, via Bash) em vez de busca semântica — filtros exatos por propriedade evitam o cache desatualizado que a busca semântica às vezes traz.

1. **Descubra os identificadores** (raramente mudam de uma execução para outra):
   - Data source ID do board "Tarefas": `ntn datasources resolve <url-ou-id-do-database>`
   - Seu Notion user ID de pessoa (não o bot da integração): `ntn whoami` — é o ID que aparece perto do fim da linha, logo antes de "person"
2. **Descubra o início da semana** a partir do frontmatter (`journal-date`) do arquivo semanal (`journals/work/.../YYYY-Www-*.md`).
3. **Confirme o que foi concluído na semana**, incluindo o que já foi arquivado em `Produção` (que sozinho acumula o histórico de todas as sprints — só usar com o filtro de data abaixo):
```
ntn datasources query <data-source-id> --filter '{"and":[
  {"property":"Responsible","people":{"contains":"<meu-user-id>"}},
  {"or":[
    {"property":"Status","status":{"equals":"Feito"}},
    {"property":"Status","status":{"equals":"Produção"}}
  ]},
  {"timestamp":"last_edited_time","last_edited_time":{"on_or_after":"<inicio-da-semana>"}}
]}' --limit 50 --json
```
4. **Confirme o que segue em aberto**, para os planos da próxima semana (sem filtro de data — o status atual sempre importa):
```
ntn datasources query <data-source-id> --filter '{"and":[
  {"property":"Responsible","people":{"contains":"<meu-user-id>"}},
  {"or":[
    {"property":"Status","status":{"equals":"Em Andamento"}},
    {"property":"Status","status":{"equals":"Testando"}},
    {"property":"Status","status":{"equals":"Não iniciado"}}
  ]}
]}' --limit 50 --json
```
5. Use `ntn pages get <id>` para ler a descrição completa de cada card e confirmar/enriquecer o texto do resumo antes de compilar.

## Formato e tom: 
Orientado a resultados e valor de negócio, evitando jargão excessivamente técnico ou operacional interno.

## Inclua:

### Principais realizações
- Liste entregas concluídas e objetivos alcançados com foco no valor gerado
- Destaque projetos ou iniciativas importantes
- Importante: Se algum desafio técnico foi superado como parte de uma realização, inclua-o como contexto dessa realização (não como seção separada)

### Planos para a próxima semana
- Liste as principais iniciativas e objetivos planejados
- Apresente de forma direta, sem necessidade de classificar por níveis de prioridade
- Inclua apenas itens relevantes para visibilidade do time de produto

## Exclua ou minimize:
- Detalhes operacionais muito granulares (ex: ajudas pontuais a colegas, pequenas revisões de código)
- Necessidades internas de suporte/recursos que serão tratadas diretamente com stakeholders específicos
- Classificações artificiais de prioridade que não agregam à discussão
- Seções formais de 'bloqueios' ou 'desafios' - integre o contexto relevante nas realizações ou planos quando necessário
- Análises de custo-benefício detalhadas em decisões técnicas já tomadas (mantenha apenas se forem decisões ainda em discussão ou com impacto direto no roadmap de produto)"

