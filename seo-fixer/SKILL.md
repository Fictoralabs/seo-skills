---
name: seo-fixer
version: 1.0.0
description: |
  Apply SEO fixes to a website's source files based on findings from
  /seo-auditor or /seo-diagnoser. Handles meta tags, structured data (schema),
  heading hierarchy, internal links, image alt text, canonical tags, and
  robots/sitemap config. Creates one PR per fix batch. Use when asked to
  "fix the SEO issues", "implement the audit recommendations", or "apply SEO
  fixes from the report".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# /seo-fixer — SEO Fix Implementation

One fix at a time. Verify before moving to the next.
Never fix what was not identified in an audit or diagnosis.

---

## Step 1 — Load Findings

Read the most recent audit or diagnosis report:

```bash
ls -t seo-audit-*.md seo-diag-*.md 2>/dev/null | head -3
```

If no report exists: stop and ask the user to run /seo-auditor first.

Confirm with the user which findings to fix in this session before touching any files.
Start with CRITICAL, then HIGH. Never touch LOW items until CRITICAL/HIGH are done.

---

## Step 2 — Understand the Site Structure

Before editing, understand where meta/SEO config lives:

```bash
# Find meta tag templates
grep -rn "og:title\|meta.*description\|<title" --include="*.html" --include="*.njk" --include="*.hbs" --include="*.jsx" --include="*.tsx" . | head -20

# Find schema markup
grep -rn "application/ld+json\|schema.org" --include="*.html" --include="*.js" . | head -10

# Find robots.txt and sitemap
ls -la robots.txt sitemap.xml sitemap-index.xml 2>/dev/null

# Find canonical tag implementation
grep -rn 'rel="canonical"' --include="*.html" --include="*.njk" . | head -10
```

Read the identified template files before editing. Understand the pattern first.

---

## Step 3 — Fix Categories

### Meta Tags (Title + Description)
- Locate the template that renders <title> and <meta name="description">
- Update per page: titles 50-60 chars, descriptions 140-155 chars
- Primary keyword near the start of the title
- Description must be a selling proposition, not a summary

### Schema Markup (JSON-LD)
For a SaaS landing page, add/fix:
- Organization schema: name, url, logo, contactPoint, sameAs (social profiles)
- WebSite schema: name, url, potentialAction (SearchAction if site search exists)
- SoftwareApplication schema: applicationCategory, operatingSystem, offers, aggregateRating
- FAQPage schema: for any FAQ section

Template:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Zena",
  "applicationCategory": "BusinessApplication",
  "operatingSystem": "Web",
  "offers": {
    "@type": "Offer",
    "price": "199",
    "priceCurrency": "AED"
  }
}
</script>
```

### Heading Hierarchy
- One H1 per page, contains primary keyword
- H2s for main sections
- No skipped levels (H1 -> H3 without H2)
- Headings describe content, not just labels

### Internal Links
- Every important page reachable within 3 clicks from homepage
- Anchor text is descriptive (not "click here" or "learn more")
- Add contextual internal links from high-traffic pages to target pages

### Image Alt Text
```bash
# Find images missing alt
grep -rn '<img' --include="*.html" --include="*.njk" . | grep -v 'alt=' | head -20
```

### Canonical Tags
- Add <link rel="canonical" href="https://domain.com/page/"> to every page
- Self-referencing canonicals on all paginated pages
- Never canonical to a redirect

### robots.txt + Sitemap
- Verify sitemap URL is listed in robots.txt
- Verify sitemap is submitted in GSC

---

## Step 4 — Pre-Edit Checklist

Before each edit, note:
1. Which file and line?
2. What is the current value?
3. What will it become?
4. Does this affect any other pages or templates?

---

## Step 5 — One Fix, One Verify

After each logical change:

```bash
# For static site generators, do a local build to verify
# npm run build 2>&1 | tail -10

# Verify the change looks correct in the built output
grep -rn "CHANGED_ELEMENT" dist/ public/ _site/ 2>/dev/null | head -5
```

If the site has a dev server, check the relevant page visually before committing.

---

## Step 6 — Commit and PR

Group related fixes into one PR. Not all fixes in one PR.
Logical groupings: (a) meta tags, (b) schema, (c) internal links.

```bash
BRANCH="fix/seo-$(date +%Y%m%d)-<slug>"
git checkout -b "$BRANCH"
git add <specific files>
git commit -m "fix(seo): <describe what was fixed>"
git push origin "$BRANCH"
gh pr create \
  --title "fix(seo): <description>" \
  --body "Fixes from SEO audit $(date +%Y-%m-%d).

## Changes
- <what was changed>

## Evidence
- <audit finding that motivated this>

## Verification
- [ ] Build passes
- [ ] Meta tags correct on affected pages
- [ ] Schema valid (test at schema.org/SchemaApp)"
```

---

## Step 7 — Post-Fix Verification

After PR merges and deploys:

1. Run inspect_url_enhanced on fixed pages (GSC MCP) — confirm indexing OK
2. Validate schema at https://validator.schema.org
3. Note in the audit report which findings are FIXED vs PENDING

---

## Rules

Only fix items from a confirmed audit or diagnosis report.
One category of fixes per PR. No mixed commits.
Always read the file before editing it.
Never edit generated/compiled output files — edit the source template.
