---
name: seo-auditor
version: 1.0.0
description: |
  Full SEO audit for a website. Runs a 4-layer parallel audit: Screaming Frog
  crawl (technical), GSC performance data, DataForSEO on-page + backlinks, and
  AI search visibility check. Outputs a prioritised findings report with
  CRITICAL / HIGH / MEDIUM / LOW severity. Use when asked to "audit the site",
  "full SEO check", "what is wrong with our SEO", or "run an SEO audit".
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# /seo-auditor — Full SEO Audit

Runs a 4-layer structured audit. Do not propose fixes here — that is /seo-fixer.
This skill produces FINDINGS only.

---

## Prerequisites Check

Before starting, confirm available tools:

```bash
SF_PATH="/Applications/Screaming Frog SEO Spider.app/Contents/MacOS/ScreamingFrogSEOSpider"
[ -f "$SF_PATH" ] && echo "SF: AVAILABLE" || echo "SF: NOT_INSTALLED"
claude mcp get gsc 2>/dev/null | grep -i status || echo "GSC: NOT_REGISTERED"
claude mcp get dfs-mcp 2>/dev/null | grep -i status || echo "DATAFORSEO: NOT_REGISTERED"
```

Note missing tools in the audit header. Partial audits are valid; skip unavailable layers.

---

## Phase 1 — Screaming Frog Crawl (Technical Layer)

Skip if SF is NOT_INSTALLED. Ask user for target URL if not provided.

```bash
TARGET_URL="${1:-https://zena.fictoralabs.ae}"
OUTPUT_DIR="/tmp/sf-audit-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

"/Applications/Screaming Frog SEO Spider.app/Contents/MacOS/ScreamingFrogSEOSpider" \
  --headless \
  --crawl "$TARGET_URL" \
  --output-folder "$OUTPUT_DIR" \
  --export-tabs "Internal:All,Response Codes:All,Page Titles:All,Meta Description:All,H1:All,Images:All,Canonicals:All,Directives:All" \
  2>&1 | tail -10

echo "OUTPUT: $OUTPUT_DIR"
ls "$OUTPUT_DIR"
```

Parse the CSVs and check:

Response Codes: 4xx (broken), 3xx chains (redirect loops), 5xx errors.
Page Titles: missing, duplicates, length outside 30-60 chars.
Meta Descriptions: missing, duplicates, length outside 120-160 chars.
H1: missing, multiple per page, mismatch with title.
Canonicals: wrong target, missing on key pages.
Images: missing alt text, files over 200KB.

```bash
for f in "$OUTPUT_DIR"/*.csv; do
  echo "=== $(basename $f) ==="
  wc -l "$f"
  head -2 "$f"
done
```

---

## Phase 2 — GSC Performance Data

Pull via GSC MCP tools:

1. list_properties — confirm property verified
2. get_performance_overview (days=28) — clicks, impressions, CTR, position
3. get_search_analytics (dimensions=query, row_limit=20) — top queries
4. get_search_analytics (dimensions=page, row_limit=20) — top pages
5. get_advanced_search_analytics — filter position > 10, impressions > 50 (page-2 opportunities)
6. batch_url_inspection — check indexing on 10 most important pages

Flag: unindexed pages, high impressions/low CTR (CTR < 2% with 200+ impressions),
queries at position 11-20, pages with zero clicks in 28 days.

---

## Phase 3 — DataForSEO Analysis

Skip if DATAFORSEO is NOT_REGISTERED.

Pull via DataForSEO MCP:
- On-page audit: technical score, issues list
- Backlink overview: total backlinks, referring domains, DA
- Keyword gap vs 2-3 competitors
- SERP features: which target queries have featured snippets or AI Overviews
  that we are NOT appearing in

---

## Phase 4 — AI Search Visibility Check

Use WebSearch to spot-check:
- Search "Zena WhatsApp CRM" — does our site appear?
- Search the top 3 queries from Phase 2 — are AI Overviews present?
- If AI Overviews appear: who is cited? Are we cited?

Note: deep AI search monitoring is handled by /ai-search-spy.

---

## Phase 5 — Synthesis Report

Write seo-audit-YYYY-MM-DD.md to the project root:

Header: tools used (available/not installed for each).
Executive summary: 2-3 sentences on overall health.

Findings sections: CRITICAL / HIGH / MEDIUM / LOW.
Each finding: description, evidence (URL or data point), recommended action.

Top 5 Quick Wins: ordered by impact vs effort.

Data snapshot table:
- Total clicks (28d)
- Total impressions (28d)
- Avg CTR
- Avg position
- Indexed pages
- Crawl errors found

---

## Rules

Every finding needs evidence. No guessing severity.
No fixes in this skill. Run /seo-fixer after the report is reviewed.
Run /seo-diagnoser on any CRITICAL finding that needs root-cause analysis.
