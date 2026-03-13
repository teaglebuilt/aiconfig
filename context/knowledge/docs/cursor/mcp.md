# Cursor MCP Integration

Source: https://cursor.com/docs/mcp

## Overview

MCP (Model Context Protocol) enables Cursor to connect to external tools.

This allows the agent to access:

* APIs
* Databases
* custom services
* internal tooling

## MCP Architecture

Components:

Agent
↓
MCP Client
↓
MCP Server
↓
External System

## Example MCP Use Cases

* Query internal APIs
* Retrieve documents
* Run data pipelines
* Access company services

## Example MCP Tool

```
tool: getCustomer
input: { id: string }
```

Agent prompt:

```
Fetch customer details for id=123
```

The MCP server executes the request.

## Benefits

* Extend agent capabilities
* Secure integration
* Custom automation
