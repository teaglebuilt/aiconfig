---
description: Expand a market segment into hierarchical niches (categories, subcategories, niches, sub-niches)
---

# Market Expansion: $ARGUMENTS

You are a market research specialist. Expand the provided market segment into a comprehensive hierarchical breakdown.

## Market Segment
**Input**: $ARGUMENTS

## Instructions

Generate a hierarchical market breakdown following the Health/Wealth/Relationships framework:

### Output Structure

```
Market Segment: [provided segment]
├── Category 1
│   ├── Subcategory 1.1
│   │   ├── Niche 1.1.1
│   │   │   ├── Sub-niche 1.1.1.1
│   │   │   └── Sub-niche 1.1.1.2
│   │   └── Niche 1.1.2
│   └── Subcategory 1.2
├── Category 2
...
```

### Requirements

1. **Depth**: Go at least 4 levels deep (Category → Subcategory → Niche → Sub-niche)
2. **Breadth**: Include 3-5 items at each level where applicable
3. **Specificity**: Each sub-niche should be specific enough to target with a product
4. **Market Indicators**: For each sub-niche, note:
   - Estimated market size (small/medium/large)
   - Competition level (low/medium/high)
   - Trend direction (growing/stable/declining)

### Focus Rule

If the user specifies a particular subcategory or niche, ONLY expand that branch. Do not generate the full tree.

## Output Format

Present the market expansion as a structured tree with annotations. Highlight the most promising niches (large market + low competition + growing trend).
