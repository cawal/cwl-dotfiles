# Global Agents Rules

## Development flow

- NEVER commit directly to branches main, master, develop, staging, production. The only exception is for my dotfiles.
- NEVER update secrets or environment variables without asking for explicit permissions by the user and waiting for its approval. You need to indicate which variables you will change, why the change and also have a plan to rollback the change.
- Never commit generated plan files unless the user approves or asks for it.:q.

### Comandos Úteis

```bash
# Criar novo agente interativo
opencode agent create

# Listar modelos disponíveis  
opencode models

# Testar comando específico
opencode run "teste de prompt"
```
