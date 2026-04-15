# Obsidian Sync Engine

Pipeline de sincronización automatizada de documentación técnica desde repositorios Open Source hacia tu bóveda de Obsidian.

## Arquitectura

```
obsidian-sync-engine/
├── .github/
│   └── workflows/
│       └── sync-pipeline.yml    # Pipeline de GitHub Actions
├── config/
│   └── repos.yml                # Lista de repositorios a sincronizar
├── scripts/
│   ├── 01-clone-repos.sh        # Clonación blobless
│   ├── 02-curate-docs.sh        # Curación (eliminación de basura)
│   └── 03-push-to-vault.sh      # Sincronización a Obsidian
└── README.md
```

## Setup

### 1. Crear el repositorio de GitHub para tu Obsidian Vault

```bash
# En GitHub, creá un repo nuevo (privado) para tu bóveda de Obsidian
# Luego inicializalo localmente:
cd ~/Documentos/OBSIDIAN
git init
git remote add origin https://github.com/TU_USUARIO/TU_OBSIDIAN_VAULT_REPO.git
git add .
git commit -m "chore: initial vault setup"
git push -u origin main
```

### 2. Modificar `sync-pipeline.yml`

Reemplazá `TU_USUARIO/TU_OBSIDIAN_VAULT_REPO` con tu usuario y repo real.

### 3. Generar Fine-grained PAT

1. Ve a GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Generate new token:
   - **Repository access**: Only select repositories → elegí `obsidian-sync-engine`
   - **Permissions**: Contents → Read and Write
   - **Expiration**: 6 meses
3. Copiá el token

### 4. Configurar el secreto

En el repo `obsidian-sync-engine`:
- Settings → Secrets and variables → Actions → New repository secret
- Name: `OBSIDIAN_PAT`
- Value: el token que generaste

### 5. Pushear el motor

```bash
cd ~/Documentos/OBSIDIAN/obsidian-sync-engine
gh repo create obsidian-sync-engine --public --source=. --push
```

## Uso

- **Automático**: El cron corre todos los días a las 3 AM UTC
- **Manual**: Ve a Actions → "Obsidian Docs Cloud Pipeline" → Run workflow → desmarcá `dry_run`

## Agregar nuevos repos

Editá `config/repos.yml`:

```yaml
repos:
  - name: google/gemini-cli
  - name: qwen-code/qwen-code
  - name: hermes-agent/hermes-agent
  - name: gentle-ai/engram
  - name: nuevo/repo  # <-- agregá acá
```

Hacé commit y push. El pipeline se actualiza automáticamente.

## Reglas de oro

1. **No editar archivos en `docs-externos/`** - el pipeline los pisa en cada ejecución
2. **Editar solo `repos.yml`** para agregar/quit ar repos
3. **Regenerar el PAT** cada 6 meses cuando expire