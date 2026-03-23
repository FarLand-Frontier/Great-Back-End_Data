#!/usr/bin/env bash
set -euo pipefail

ROOT_PAGE_ID="${1:-32bceb9d55ec8065b12ad34aaebd74c8}"
NOTION_KEY="$(cat ~/.config/notion/api_key)"
TITLE="${2:-Project Overview - Great Back End}"
CONTENT_FILE="${3:-docs/PROJECT_OVERVIEW.md}"

if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "content file not found: $CONTENT_FILE" >&2
  exit 1
fi

# 1) Create child page
CREATE_RESP=$(curl -sS -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_KEY}" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d "{\"parent\":{\"page_id\":\"${ROOT_PAGE_ID}\"},\"properties\":{\"title\":{\"title\":[{\"text\":{\"content\":\"${TITLE}\"}}]}}}")

PAGE_ID=$(echo "$CREATE_RESP" | jq -r '.id // empty')
if [[ -z "$PAGE_ID" ]]; then
  echo "$CREATE_RESP" | jq -r '.message // .'
  exit 1
fi

# 2) Add intro paragraph
curl -sS -X PATCH "https://api.notion.com/v1/blocks/${PAGE_ID}/children" \
  -H "Authorization: Bearer ${NOTION_KEY}" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"children":[{"object":"block","type":"paragraph","paragraph":{"rich_text":[{"type":"text","text":{"content":"Synced from data repo."}}]}}]}' >/dev/null

# 3) Split markdown into <=1800-char chunks and append as multiple code blocks
python3 - "$CONTENT_FILE" >/tmp/notion_chunks.json <<'PY'
import json,sys
p=sys.argv[1]
text=open(p,'r',encoding='utf-8').read()
size=1800
chunks=[text[i:i+size] for i in range(0,len(text),size)] or [""]
children=[]
for c in chunks:
    children.append({
      "object":"block",
      "type":"code",
      "code":{
        "rich_text":[{"type":"text","text":{"content":c}}],
        "language":"markdown"
      }
    })
print(json.dumps({"children":children},ensure_ascii=False))
PY

curl -sS -X PATCH "https://api.notion.com/v1/blocks/${PAGE_ID}/children" \
  -H "Authorization: Bearer ${NOTION_KEY}" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  --data @/tmp/notion_chunks.json >/dev/null

echo "https://www.notion.so/$(echo "$PAGE_ID" | tr -d '-')"