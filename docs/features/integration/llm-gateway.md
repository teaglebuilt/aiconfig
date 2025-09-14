# LLM Gateway Integration

## Overview

The LLM Gateway provides a centralized proxy layer between Claude Code and model providers, offering several key benefits:

- **Centralized authentication**: Manage API keys in one place
- **Usage tracking**: Monitor and analyze model usage across your organization
- **Cost controls**: Set budgets and rate limits to control spending
- **Audit logging**: Track all API calls for compliance and debugging
- **Model routing**: Route requests to different providers based on your needs

## Configuration Methods

### Authentication Options

#### 1. Static API Key
Set a static API key that remains constant:

```bash
export ANTHROPIC_AUTH_TOKEN=sk-litellm-static-key
```

#### 2. Dynamic API Key with Helper Script
Configure Claude Code to fetch/generate keys dynamically with a refresh interval:

```bash
export CLAUDE_CODE_API_KEY_HELPER_TTL_MS=3600000
```

### Endpoint Configuration

#### Unified Endpoint (Recommended)
Use a single endpoint for all model providers:

```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000
```

#### Provider-Specific Pass-Through Endpoints

##### Anthropic API
```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic
```

##### Amazon Bedrock
```bash
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
export CLAUDE_CODE_USE_BEDROCK=1
```

##### Google Vertex AI
```bash
export ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1
export ANTHROPIC_VERTEX_PROJECT_ID=your-gcp-project-id
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
```

## Important Notes

- LiteLLM is a third-party service
- Anthropic does not endorse or audit LiteLLM's functionality
- Default models can be overridden with custom configurations
- Ensure your LLM Gateway is properly configured for your specific model providers

## Benefits

1. **Centralized Management**: Single point of control for all LLM interactions
2. **Enhanced Security**: Centralized authentication and access control
3. **Cost Optimization**: Built-in usage tracking and cost controls
4. **Compliance**: Comprehensive audit logging for regulatory requirements
5. **Flexibility**: Support for multiple model providers through a unified interface