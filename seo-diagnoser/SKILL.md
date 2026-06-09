---
name: seo-diagnoser
version: 1.0.0
description: |
  Root-cause a specific SEO issue. Takes a symptom (traffic drop, ranking loss,
  page not indexing, CTR decline) and traces it to its cause using GSC data,
  DataForSEO, and Screaming Frog crawl data. Outputs a diagnosis with evidence
  and a fix recommendation. Use when asked to "why did traffic drop", "why is
  this page not ranking", "diagnose this SEO problem", or after /seo-auditor
  flags a CRITICAL or HIGH issue.
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# /seo-diagnoser — SEO Issue Root-Cause Investigator

Iron Law: no fix recommendation without confirmed root cause.
Treat every hypothesis as unconfirmed until data backs it.

---

## Step 1 — Define the Symptom

If not provided by the user, ask:
- What changed? (traffic drop, ranking loss, CTR drop, not indexed)
- Which URL or query is affected? (specific page or keyword)
- When did it start? (approximate date)
- What was the baseline? (traffic/position before vs after)

Document the symptom precisely before investigating.

---

## Step 2 — Prerequisites

```bash
SF_PATH="/Applications/Screaming Frog SEO Spider.app/Contents/MacOS/ScreamingFrogSEOSpider"
[ -f "$SF_PATH" ] && echo "SF: AVAILABLE" || echo "SF: NOT_INSTALLED"
claude mcp get gsc 2>/dev/null | grep -i status || echo "GSC: NOT_REGISTERED"
claude mcp get dfs-mcp 2>/dev/null | grep -i status || echo "DATAFORSEO: NOT_REGISTERED"
```

---

## Step 3 — Timeline Reconstruction (GSC)

Use GSC MCP to establish what happened and when:

1. compare_search_periods — compare 28 days before the drop vs 28 days after.
   Use dimensions=query to see which queries lost clicks/position.
   Use dimensions=page to see which pages were affected.

2. get_advanced_search_analytics — pull daily data (dimensions=date) for the
   affected period to pinpoint the exact day the change happened.

3. inspect_url_enhanced — if a specific page is affected, check its indexing
   status, last crawl date, and any coverage issues.

Cross-reference the drop date with:
```bash
# Check if any site changes were deployed around that date
git log --oneline --after="YYYY-MM-DD" --before="YYYY-MM-DD" 2>/dev/null | head -20
```

---

## Step 4 — Screaming Frog Spot-Crawl

If SF is available and the issue is technical (not indexed, crawl errors):

```bash
TARGET_URL="$AFFECTED_URL"
OUTPUT_DIR="/tmp/sf-diag-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

"/Applications/Screaming Frog SEO Spider.app/Contents/MacOS/ScreamingFrogSEOSpider" \
  --headless \
  --crawl "$TARGET_URL" \
  --output-folder "$OUTPUT_DIR" \
  --export-tabs "Response Codes:All,Directives:All,Canonicals:All,Page Titles:All" \
  2>&1 | tail -5

ls "$OUTPUT_DIR"
```

Check for: noindex directive, wrong canonical, redirect to wrong URL,
4xx/5xx status, blocked by robots.txt.

---

## Step 5 — Pattern Matching

Match the symptoms to known SEO failure patterns:

| Pattern | Symptoms | What to check |
|---------|----------|---------------|
| Algorithm update | Broad traffic drop, all pages, gradual | Compare drop date vs Google update dates (WebSearch) |
| Crawl budget issue | Pages disappearing from index over time | GSC Coverage report, robots.txt, SF crawl |
| Canonicalisation | Page not indexed, duplicate content | inspect_url_enhanced, SF canonicals CSV |
| Redirect chain | Ranking loss after site change | SF response codes, 3xx chains |
| Manual penalty | Sudden drop, specific pages | GSC Security + Manual Actions section |
| Thin content | Low-traffic pages, high bounce | DataForSEO on-page score, content length |
| Backlink loss | Position drop on competitive keywords | DataForSEO backlink history |
| Page speed regression | CTR stable but positions drop | Core Web Vitals via DataForSEO or PageSpeed API |

For algorithm update check:
```bash
# WebSearch to cross-reference drop date
# Query: "Google algorithm update <month> <year>"
```

---

## Step 6 — Form and Confirm Hypothesis

State clearly: "Root cause hypothesis: [specific claim]"
Then confirm it with a second data point before recommending a fix.

If hypothesis cannot be confirmed: state NEEDS_CONTEXT and list what
additional data would prove or disprove it.

If 3 hypotheses fail: STOP. Report BLOCKED with what was tried.

---

## Step 7 — Diagnosis Report

Output structured report:

DIAGNOSIS REPORT
Symptom: [what the user observed, with numbers]
Period: [date range affected]
Root cause: [confirmed or high-confidence hypothesis]
Evidence: [specific data points that confirm it]
Ruling out: [what was checked and eliminated]
Fix: [call /seo-fixer with specific task, or describe manual action needed]
Status: CONFIRMED / HIGH_CONFIDENCE / UNCONFIRMED / BLOCKED
