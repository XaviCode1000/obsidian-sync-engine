#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/tmp/sync-workspace"
CONFIG_FILE="config/repos.yml"

echo "🚀 Iniciando extracción en $WORKSPACE..."
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

# Leemos el YAML usando yq
REPOS=$(yq e '.repos[].name' "$CONFIG_FILE")

for REPO in $REPOS; do
  echo "📥 Procesando $REPO..."
  DIR_NAME="${REPO/\//-}"
  REPO_DIR="$WORKSPACE/$DIR_NAME"

  # Clonado blobless ultra rápido
  git clone --filter=blob:none --no-checkout --depth 1 "https://github.com/$REPO.git" "$REPO_DIR-temp"

  cd "$REPO_DIR-temp"
  git sparse-checkout init --cone
  git sparse-checkout set docs
  git checkout

  mkdir -p "$REPO_DIR/docs"

  # Sincronizamos solo los .md de docs/ manteniendo estructura
  rsync -a --include='*/' --include='*.md' --exclude='*' docs/ "$REPO_DIR/docs/" || true

  # Copiamos los .md de la raíz usando fd
  fd -d 1 -e md -x cp {} "$REPO_DIR/" 2>/dev/null || true

  cd - > /dev/null
  rm -rf "$REPO_DIR-temp"
done

echo "✅ Extracción completada."