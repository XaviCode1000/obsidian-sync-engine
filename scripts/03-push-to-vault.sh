#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/tmp/sync-workspace"
VAULT_DIR="${1:-}"

if [[ -z "$VAULT_DIR" ]]; then
  echo "❌ Error: Tenés que pasar el path del Obsidian Vault."
  exit 1
fi

DEST_DIR="$VAULT_DIR/repository-docs"

echo "📦 Sincronizando archivos a $DEST_DIR..."
mkdir -p "$DEST_DIR"

# Rsync con --delete asegura que si borraron un archivo en el repo original, se borra en tu Obsidian
rsync -av --delete "$WORKSPACE/" "$DEST_DIR/"

echo "🔒 Preparando commit..."
cd "$VAULT_DIR"

# Configuración del bot
git config user.name "JARVIS Sync Bot"
git config user.email "jarvis@tonystark.com"

git add repository-docs/

# Detectamos si hay cambios reales
if git status --porcelain | rg -q "^[AMDR]"; then
  echo "📝 Cambios detectados. Creando commit..."
  git commit -m "chore(docs): sync upstream repositories - $(date -u +'%Y-%m-%d')"
  git push origin main
  echo "✅ Push exitoso a la bóveda."
else
  echo "🤷‍♂️ No hay cambios nuevos. Idempotencia FTW. Salteando commit."
fi