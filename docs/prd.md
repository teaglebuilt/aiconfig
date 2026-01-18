

## Use Cases

### Context Management

Example use cases using shared context

**Feature Development**

- I start a product feature with claude code in a project `/Users/teaglebuilt/github/project`. I hit a rate limit or run out of funds with claude code and want to transfer over to using claude code to continue the feature development.

**Feature Tweaking**

- I start a product feature with claude code in a project `/Users/teaglebuilt/github/project`. I am using claude code for development the feature and cursor agent for making edits along the way.

### Memory Management

- I want to retreive information from time ago and might not have the direct lookups required requiring a semantic search

- Retreive knowledge that I do not know but is stored from research.

- I ran a research job with product-strategy-advisor agent last week for generating a prd.md for a project. I could look that up later and do not have to save to git.

#### Semantic Search

**Benefits**

- **Embedded**: No server to manage, data stored as files
- **Portable**: Vector DB travels with your aiconfig
- **Fast**: Native vector search with filtering
- **Compatible**: Works alongside basic-memory

**Use Cases**:
- "Find similar problems I've solved before"
- "What patterns have I used for authentication?"
- "Retrieve relevant context for React performance"