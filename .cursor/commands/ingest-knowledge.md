---
description: Ingest a URL (blog post, docs, article) into the knowledge base for future reference
---

# Ingest Knowledge: $ARGUMENTS

You are a knowledge ingestion specialist. Fetch, process, and store the provided URL as structured knowledge.

## Input
**URL**: $ARGUMENTS

## Instructions

### Step 1: Fetch Content

Fetch the content from the URL:
- Extract the main article/content (ignore navigation, ads, footers)
- Preserve code blocks, lists, and formatting
- Capture metadata: title, author, date if available

### Step 2: Process Content

Transform the content into a knowledge entry:

```json
{
  "id": "knowledge-{YYYYMMDD}-{hash}",
  "source_url": "{url}",
  "title": "{extracted title}",
  "author": "{author if found}",
  "date_published": "{date if found}",
  "date_ingested": "{current ISO date}",
  "type": "article|documentation|tutorial|reference",
  "tags": ["{auto-generated tags}"],
  "summary": "{2-3 sentence summary}",
  "key_points": [
    "{main point 1}",
    "{main point 2}",
    "{main point 3}"
  ]
}
```

### Step 3: Determine Storage Location

Based on content type, store in appropriate location:

**Technical Documentation** → `~/aiconfig/memory/global/knowledge/docs/`
**Blog Posts/Articles** → `~/aiconfig/memory/global/knowledge/articles/`
**Tutorials** → `~/aiconfig/memory/global/knowledge/tutorials/`
**Reference Material** → `~/aiconfig/memory/global/knowledge/reference/`

### Step 4: Create Knowledge File

Write the knowledge entry as a markdown file:

```markdown
---
id: knowledge-{YYYYMMDD}-{hash}
source: {url}
title: {title}
author: {author}
date_published: {date}
date_ingested: {current date}
type: {type}
tags: [{tags}]
---

# {title}

> **Source**: [{url}]({url})
> **Ingested**: {date}

## Summary

{2-3 sentence summary}

## Key Points

- {point 1}
- {point 2}
- {point 3}

## Content

{full markdown content}
```

### Step 5: Update Knowledge Index

Append entry to `~/aiconfig/memory/global/knowledge/index.json`:

```json
{
  "id": "knowledge-{id}",
  "title": "{title}",
  "source": "{url}",
  "type": "{type}",
  "tags": ["{tags}"],
  "file": "{relative path to file}",
  "ingested": "{date}"
}
```

## Output

After ingestion, report:

```
✓ Knowledge ingested successfully

Title: {title}
Type: {type}
Tags: {tags}
Stored: {file path}

Summary:
{summary}

Key Points:
• {point 1}
• {point 2}
• {point 3}

Use `/recall {topic}` to retrieve this knowledge later.
```

## Error Handling

- **URL unreachable**: Report error, suggest checking URL
- **Content extraction failed**: Save raw HTML, flag for manual review
- **Duplicate URL**: Check index.json, ask to update or skip

## Examples

```
/ingest-knowledge https://blog.example.com/react-server-components
/ingest-knowledge https://docs.python.org/3/library/asyncio.html
```
