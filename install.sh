#!/bin/bash
set -e

SKILLS_DIR="${HOME}/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing seo-skills to $SKILLS_DIR..."

for skill in seo-auditor seo-diagnoser seo-fixer ai-search-spy; do
  if [ -d "$SCRIPT_DIR/$skill" ]; then
    mkdir -p "$SKILLS_DIR/$skill"
    cp "$SCRIPT_DIR/$skill/SKILL.md" "$SKILLS_DIR/$skill/SKILL.md"
    echo "  installed: $skill"
  fi
done

echo ""
echo "Done. Restart Claude Code, then use:"
echo "  /seo-auditor    Full SEO audit"
echo "  /seo-diagnoser  Root-cause an SEO issue"
echo "  /seo-fixer      Apply SEO fixes"
echo "  /ai-search-spy  Monitor AI search visibility"
