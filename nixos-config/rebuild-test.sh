#!/usr/bin/env bash
# Script para testar/aplicar configuração NixOS

set -e

cd "$(dirname "$0")"

echo "🔨 Building NixOS configuration..."
echo ""

# Usar --show-trace para ver erros detalhados se necessário
if sudo nixos-rebuild test --flake . --impure; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Test the configuration (already active)"
    echo "  2. If everything works, apply permanently:"
    echo "     sudo nixos-rebuild switch --flake . --impure"
    echo ""
    echo "  3. To rollback if something breaks:"
    echo "     sudo nixos-rebuild --rollback switch"
else
    echo ""
    echo "❌ Build failed!"
    echo ""
    echo "💡 To see detailed error trace, run:"
    echo "   sudo nixos-rebuild test --flake . --impure --show-trace"
    exit 1
fi
