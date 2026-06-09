---
name: ai-search-spy
version: 1.0.0
description: |
  Monitor AI search visibility for a website. Checks whether the site appears
  in AI Overviews (Google SGE), Perplexity, and ChatGPT answers for target
  queries. Identifies which competitors are being cited. Audits content for
  AI-citation readiness (GEO: Generative Engine Optimisation). Use when asked
  to "check our AI search visibility", "are we in AI Overviews", "monitor GEO",
  or "why are competitors being cited by AI and not us".
allowed-tools:
  - Bash
  - Read
  - Write
  - WebSearch
---

# /ai-search-spy — AI Search Visibility Monitor

AI search engines (Google AI Overviews, Perplexity, ChatGPT) cite sources
differently from traditional search. This skill audits your current visibility
and what it would take to get cited.

---

## Step 1 — Define Target Queries

If not provided, pull the top 20 queries from GSC:
- Use get_search_analytics (dimensions=query, row_limit=20)
- Prioritise queries with > 100 impressions

Also ask the user for 3-5 "money queries" — the searches your ideal customer
does right before buying. These may not yet have GSC data if you don't rank.

---

## Step 2 — AI Overview Presence Check

For each target query, use WebSearch and note:

1. Does a Google AI Overview appear?
2. Is our site cited in the AI Overview?
3. Which competitors are cited?
4. What is the format of the AI answer? (list, paragraph, table, step-by-step)

Track results in a table:

| Query | AI Overview present | We are cited | Competitors cited | Answer format |
|-------|--------------------|--------------|--------------------|---------------|

Queries where AI Overviews appear but we are NOT cited = highest priority targets.

---

## Step 3 — DataForSEO AI Search Analysis

If DataForSEO MCP is active, use its AI-related tools to:

- Check SERP features for target queries: which have AI Overviews, featured
  snippets, People Also Ask boxes
- Pull competitors appearing in AI features for our target keywords
- Identify the content structure that gets cited (use DataForSEO content
  analysis tools on the cited competitor pages)

---

## Step 4 — Content Citation Readiness Audit

AI search engines prefer content that is:

A. Answer-first: the direct answer appears in the first paragraph, not buried.
B. Structured: uses headers, bullet lists, numbered steps that match query intent.
C. Authoritative: cites sources, has data/statistics, links to research.
D. FAQ-formatted: includes a Q&A section that mirrors how people phrase questions.
E. Schema-marked: FAQPage, HowTo, or Article schema helps AI parse the content.

Check the top 5 pages of our site against these criteria:

```bash
# Find FAQ sections
grep -rn "FAQ\|faq\|frequently asked" --include="*.html" --include="*.njk" . | head -10

# Check for FAQ schema
grep -rn "FAQPage" --include="*.html" --include="*.js" . | head -5

# Check for HowTo schema
grep -rn "HowTo" --include="*.html" --include="*.js" . | head -5

# Find pages with statistics/data (AI loves citing pages with numbers)
grep -rn '[0-9]\+%\|[0-9]\+x \|[0-9]\+,000' --include="*.html" . | head -10
```

---

## Step 5 — Competitor Citation Analysis

For the top 3 competitors appearing in AI Overviews for our target queries:

1. WebSearch their cited pages — what does the cited content look like?
2. Note: content format, page type (blog post, landing page, resource page),
   word count (approximate), presence of statistics, schema markup used.
3. Identify the gap between their content and ours.

This is not about copying — it is about understanding the citation pattern
so we can produce more citable content.

---

## Step 6 — GEO Opportunity Report

Output ai-search-report-YYYY-MM-DD.md with:

## Executive Summary
<are we visible in AI search? how does it compare to competitors?>

## AI Overview Presence (by query)
<table from Step 2>

## Top Citation Opportunities
Queries where AI Overviews exist, competitors are cited, we are not.
For each: what type of content would need to be created or improved.

## Content Gaps
Pages on our site that cover AI-cited topics but are NOT getting cited.
Specific improvements needed (answer-first rewrite, FAQ schema, etc.).

## Quick Wins
Content changes that can be made in < 1 day that improve citation likelihood.

## Structural Changes Needed
Larger content investments (new pages, resource hub, original research).

---

## Step 7 — Handoff

For content rewrites identified: note file paths and specific changes needed.
Pass to /seo-fixer for schema additions (FAQPage, HowTo markup).
Flag any new content pages needed for the roadmap.

---

## Notes

AI search visibility changes fast. Run this monthly minimum.
Do not assume correlation = citation. Verify manually via WebSearch.
GEO is a long game. Content cited by AI today was published and built
authority over months. Start now.
