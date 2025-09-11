---
argument-hint: [url] [feature]
description: load documentation into markdown file for agents to use for context
allowed-tools: mcp__firecrawl-mcp__firecrawl_scrape, Task WebFetch, Write, Edit, Bash(ls*)
---

### Usage

`/load_docs url path`

## Example 
```
/load_docs https://developers.zoom.us/docs/api/ docs/features/video/zoom-sdk.md
```
