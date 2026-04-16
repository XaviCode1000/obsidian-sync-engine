# Obsidian Sync Engine

Pipeline de sincronización automatizada de documentación técnica desde repositorios Open Source hacia tu bóveda de Obsidian. **Cero carga computacional local.**

## Por qué esto existe

Tony Stark no mezcla cemento en el living de su casa. Este pipeline hace lo mismo con tu documentación:
- **Cloud-native**: Todo corre en GitHub Actions, tu máquina no expende CPU
- **Curación automática**: Elimina CHANGELOG, LICENSE, CODE_OF_CONDUCT antes de llegar a tu disco
- **Idempotente**: Si no hay cambios, no hay commit

## Arquitectura

```
obsidian-sync-engine/
├── .github/
│   └── workflows/
│       └── sync-pipeline.yml    # Pipeline de GitHub Actions
├── config/
│   └── repos.yml                # Lista de repositorios a sincronizar
├── scripts/
│   ├── 01-clone-repos.sh        # Clonación blobless (rápida)
│   ├── 02-curate-docs.sh        # Curación con fd (elimina basura)
│   └── 03-push-to-vault.sh      # Sincronización a Obsidian
└── README.md
```

## Repositorios sincronizados

```yaml
repos:
  - name: google-gemini/gemini-cli
  - name: QwenLM/qwen-code
  - name: NousResearch/hermes-agent
  - name: Gentleman-Programming/engram
```

## Setup (ya configurado)

Este setup ya está hecho para XaviCode1000. Si lo usás para vos:

### 1. Crear repos Vault

```bash
cd ~/Documentos/OBSIDIAN
git init
gh repo create MI-OBSIDIAN-VAULT --private
git remote add origin https://github.com/TU_USUARIO/MI-OBSIDIAN-VAULT.git
git add .
git commit -m "chore: initial vault"
git push -u origin main
```

### 2. Configurar el workflow

Editá `.github/workflows/sync-pipeline.yml` y reemplazá:
```yaml
repository: TU_USUARIO/TU_OBSIDIAN_VAULT_REPO
```

### 3. Generar Fine-grained PAT

1. **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
2. **Generate new token**:
   - Repository access: Only select repositories → elegí tu sync-engine repo
   - Permissions: Contents → Read and Write
   - Expiration: 6 meses
3. Copiá el token

### 4. Configurar secreto

**Repo sync-engine → Settings → Secrets and variables → Actions → New repository secret**
- Name: `OBSIDIAN_PAT`
- Value: el token

## Uso

| Método | Cuándo |
|--------|--------|
| **Automático** | Cron: todos los días a las 3 AM UTC |
| **Manual** | Actions → Run workflow → desmarcá `dry_run` |

## Agregar nuevos repos

Editá `config/repos.yml`:

```yaml
repos:
  - name: google-gemini/gemini-cli
  - name: QwenLM/qwen-code
  - name: NousResearch/hermes-agent
  - name: Gentleman-Programming/engram
  - name: nuevo/repo  # <-- agregá acá
```

Commit + push. El pipeline actualiza automáticamente.

## Costos

**Gratis.** 
- Repo público = 2,000 minutos/mes de Actions
- Cada ejecución = ~1-2 minutos
- Con 1 ejecución/día = ~60 minutos/mes

## Reglas de oro

1. **No editar `repository-docs/`** - el pipeline lo pisa en cada sync
2. **Solo editar `repos.yml`** para agregar/quitar repos
3. **Regenerar PAT cada 6 meses** cuando expire
