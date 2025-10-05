---
allowed-tools: Task, Read, Write, WebSearch, WebFetch
argument-hint: research_topic_or_query
description: Execute comprehensive academic and technical research using multi-source analysis
---

# Research Command

Esegui ricerca accademica e tecnica approfondita utilizzando agenti specializzati per papers, video analysis, e web research.

## Variables

- **TOPIC**: $ARGUMENTS or "latest AI/ML developments" if not specified
  - Topic di ricerca (esempi "machine learning optimization", "React performance patterns")
  - Used by: researcher-opus and supporting agents

## Agent Groups

### Academic Research Agents
- @agent-researcher-sonnet (comprehensive academic search)
- @agent-mathematician-opus (mathematical/computational analysis)


## Execution Instructions

1. **Topic Analysis**
   - Analizza il research topic per identificare domini coinvolti
   - Determina quale combination di agenti attivare
   - Setup research parameters e scope

2. **Multi-Source Research Phase**
   - **Academic Sources**: Effettua ricerca utilizzando i tool mcp arxiv e mcp papers e mcp papers with code
   - **Video Analysis**: YouTube tool transcipt analysis, effettua summary delle spiegazioni su un argomento.
   - **Web Intelligence**: Current trends e industry insights


3. **Analysis & Synthesis**
   - Cross-reference findings tra diverse fonti
   - Identify patterns e consensus nel campo
   - Extract actionable insights e best practices

4. **Knowledge Storage**
   - Store findings 
   - Create entity/relationship mappings
   - Tag per future retrieval e cross-referencing

## Research Methodology

### Phase 1: Discovery 
```
1. Broad topic exploration via web search
2. Academic paper identification via ArXiv/Semantic Scholar
3. Video content analysis per practical insights
4. Industry trend analysis
```

### Phase 2: Deep Dive 
```
1. Selected paper detailed analysis
2. Code implementation review
3. Expert opinion synthesis
4. Comparative analysis
```

### Phase 3: Synthesis 
```
1. Findings consolidation
2. Actionable recommendations extraction
3. Future research directions identification
4. Knowledge graph population
```

## Output Format

Crea comprehensive research report:

```
research_results/
└── research_<timestamp>/
    ├── academic_papers/      # Downloaded papers e summaries
    ├── video_analysis/       # YouTube content analysis
    ├── web_intelligence/     # Industry trends e insights
    ├── code_examples/        # Implementation patterns
    ├── synthesis/           # Cross-source analysis
    └── knowledge_graph/     # KRAG entities/relationships
```

## Research Deliverables

1. **Executive Summary** (2-3 pages)
   - Key findings e consensus
   - Actionable recommendations
   - Implementation roadmap

2. **Academic Literature Review** 
   - Top 10-15 relevant papers
   - Key authors e institutions
   - Methodology comparisons

3. **Technical Implementation Guide**
   - Code examples e patterns
   - Best practices synthesis
   - Performance considerations

4. **Future Directions**
   - Emerging trends identification
   - Research gaps analysis
   - Innovation opportunities

## Success Metrics

- **Coverage**: 5+ academic sources analyzed
- **Recency**: 70% sources from last 2 years
- **Diversity**: Multiple methodologies/perspectives
- **Actionability**: Clear implementation guidance
- **Storage**: Knowledge properly stored in KRAG

## Report

Al completamento fornisci:
- Path alla research directory
- Number of sources analyzed per category
- Key insights summary
- Actionable recommendations list
- KRAG memory entities created