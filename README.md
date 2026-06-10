# seo-skills

Four Claude Code skills for a complete SEO workflow: audit, diagnose, fix, and
monitor AI search visibility.

Built to work with Google Search Console MCP, DataForSEO MCP, and Screaming
Frog SEO Spider CLI. Each skill works independently — use what you have.

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| seo-auditor | `/seo-auditor` | Full site SEO audit (4-layer: crawl + GSC + DataForSEO + AI check) |
| seo-diagnoser | `/seo-diagnoser` | Root-cause a specific issue (traffic drop, ranking loss, not indexed) |
| seo-fixer | `/seo-fixer` | Apply fixes from audit/diagnosis to site source files |
| ai-search-spy | `/ai-search-spy` | Monitor AI Overview and GEO citation visibility |

## Dependencies

| Tool | Required by | Setup |
|------|-------------|-------|
| [GSC MCP](https://github.com/AminForou/mcp-gsc) | seo-auditor, seo-diagnoser | `claude mcp add ... gsc ...` |
| [DataForSEO MCP](https://dataforseo.com/model-context-protocol) | seo-auditor, seo-diagnoser, ai-search-spy | `claude mcp add ... dfs-mcp ...` |
| [Screaming Frog SEO Spider](https://www.screamingfrog.co.uk/seo-spider/) | seo-auditor, seo-diagnoser | Install app (paid licence), CLI used headlessly |

All tools are optional — skills degrade gracefully when a tool is unavailable.

## Installation

```bash
git clone https://github.com/Fictoralabs/seo-skills.git
bash seo-skills/install.sh
```

Or install individual skills manually:

```bash
cp -r seo-skills/seo-auditor ~/.claude/skills/
cp -r seo-skills/seo-diagnoser ~/.claude/skills/
cp -r seo-skills/seo-fixer ~/.claude/skills/
cp -r seo-skills/ai-search-spy ~/.claude/skills/
```

Then restart Claude Code. Skills are available as `/seo-auditor`, `/seo-diagnoser`,
`/seo-fixer`, `/ai-search-spy`.

## Recommended Workflow

```
/seo-auditor https://yoursite.com
    |
    +--> CRITICAL finding --> /seo-diagnoser (root cause)
    |                              |
    |                              +--> /seo-fixer (implement fix)
    |
    +--> HIGH/MEDIUM findings --> /seo-fixer (batch fix)
    |
    +--> AI visibility gaps --> /ai-search-spy (GEO analysis)
```

## Screaming Frog Integration

These skills use Screaming Frog in headless CLI mode. The app must be installed
at the default Mac path:

```
/Applications/Screaming Frog SEO Spider.app/Contents/MacOS/ScreamingFrogSEOSpider
```

The skill runs it headlessly with `--headless --crawl <url>` and reads the
exported CSV files. A paid licence is required for sites over 500 URLs.
The free version works for smaller sites.

## License

MIT
