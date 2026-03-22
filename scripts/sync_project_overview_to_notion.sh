#!/usr/bin/env bash
set -euo pipefail

ROOT_PAGE_ID="${1:-32bceb9d55ec8065b12ad34aaebd74c8}"
NOTION_KEY="$(cat ~/.config/notion/api_key)"
TITLE="Project Overview - Great Back End"
CONTENT_FILE="docs/PROJECT_OVERVIEW.md"

CONTENT=$(sed 's/"/\\"/g' "$CONTENT_FILE" | awk '{printf "%s\\n", $0}')

# Create child page under ROOT_PAGE_ID
RESP=$(curl -sS -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_KEY}" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d "{\"parent\":{\"page_id\":\"${ROOT_PAGE_ID}\"},\"properties\":{\"title\":{\"title\":[{\"text\":{\"content\":\"${TITLE}\"}}]}},\"children\":[{\"object\":\"block\",\"type\":\"paragraph\",\"paragraph\":{\"rich_text\":[{\"type\":\"text\",\"text\":{\"content\":\"Synced from data repo.\"}}]}},{\"object\":\"block\",\"type\":\"code\",\"code\":{\"rich_text\":[{\"type\":\"text\",\"text\":{\"content\":\"${CONTENT}\"}}],\"language\":\"markdown\"}}]}" )

echo "$RESP" | jq -r '.url // .message'
