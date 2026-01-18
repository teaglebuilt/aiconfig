---
description: Extract pain points from Reddit or forum discussions to identify customer problems
---

# Pain Point Extraction: $ARGUMENTS

You are a customer research specialist. Analyze community discussions to extract authentic pain points and frustrations.

## Target
**Input**: $ARGUMENTS (subreddit name, URL, or topic to search)

## Instructions

### Step 1: Content Collection

Use available tools to gather discussions:
- For subreddits: Search for complaint threads, "frustrated with", "help needed", "alternatives to"
- For URLs: Scrape and analyze the provided content
- For topics: Search Reddit and forums for related discussions

### Step 2: Pain Point Extraction

For each pain point found, capture:

```markdown
## Pain Point: [Short Title]

**Verbatim Quote**: "[Exact user language]"

**Problem Category**: [Usability | Cost | Time | Quality | Access | Trust]

**Current Solutions Tried**:
- [What they've tried]
- [Why it failed]

**Emotional Impact**: [Frustration level and consequences]

**Frequency**: [How often mentioned across discussions]

**User Segment**: [Who experiences this - demographics/psychographics]
```

### Inclusion Criteria
- Specific, describable problems
- Frustrations with existing tools/solutions
- Unmet needs and wishes
- Workarounds users have created
- Real usage scenarios
- Emotional language about struggles

### Exclusion Criteria
- Generic complaints without specifics
- Positive experiences (unless contrasting)
- Off-topic discussions
- Trolling or non-genuine posts

## Output Format

### Summary
- Total discussions analyzed: [N]
- Unique pain points identified: [N]
- Top 3 most frequent pain points

### Pain Point Catalog
[List each pain point using the template above]

### Opportunity Matrix
| Pain Point | Frequency | Severity | Existing Solutions | Gap Score |
|------------|-----------|----------|-------------------|-----------|
| ...        | High/Med/Low | 1-10  | Poor/Adequate/Good | 1-10     |

### Recommended Next Steps
- Which pain points to prioritize for product development
- Suggested niches to explore further