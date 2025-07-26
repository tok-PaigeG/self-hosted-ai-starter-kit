# AI Chat Basic Example

**Workflow ID:** `ai-chat-basic-example`  
**Category:** ai-chat  
**Author:** Team Example  
**Status:** Example/Template  

## Description

A simple AI chat interface that demonstrates the basic pattern for building conversational AI workflows using local Ollama processing. This example shows how to create a web-accessible chat interface that processes user messages through a local language model.

## Use Cases

- **Customer Support**: Basic AI-powered customer service chat
- **Learning Assistant**: Educational chatbot for answering questions
- **Internal Tool**: Company knowledge assistant
- **Prototype Development**: Starting point for more complex AI agents

## Setup Instructions

### Prerequisites

- [x] n8n instance running (http://localhost:5678)
- [x] Ollama service running with llama3.2 model
- [x] Local Ollama credential configured in n8n

### Installation

1. **Import the workflow:**
   ```bash
   ./workflow-management/scripts/import-to-n8n.sh workflows/examples/ai-chat-basic
   ```

2. **Configure Ollama credential:**
   - Go to http://localhost:5678/home/credentials
   - Create "Ollama API" credential named "Local Ollama Service"
   - Set Base URL to: `http://ollama:11434`
   - Test the connection

3. **Activate the workflow:**
   - Open the imported workflow in n8n
   - Click "Activate" in the top right
   - Note the webhook URL for chat access

4. **Test the chat:**
   - Click "Chat" button in the workflow
   - Send a test message
   - Verify AI responses

## Authentication

### Required Credentials

- **Local Ollama Service** (`ollamaApi`)
  - Type: Ollama API
  - Base URL: `http://ollama:11434`
  - Description: Local Ollama service for AI processing

See `auth-config.yml` for detailed credential configuration.

## Input/Output

### Input Format (Chat Messages)

```json
{
  "chatInput": "Hello, how can you help me?",
  "sessionId": "unique-session-identifier"
}
```

### Output Format (AI Responses)

```json
{
  "output": "Hello! I'm an AI assistant. I can help you with questions, provide information, and assist with various tasks. What would you like to know?",
  "sessionId": "unique-session-identifier"
}
```

## Configuration

### Workflow Parameters

| Parameter | Description | Type | Default |
|-----------|-------------|------|---------|
| Model | Ollama model to use | String | llama3.2:latest |
| Temperature | Response creativity (0-1) | Number | 0.7 |

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| OLLAMA_HOST | Ollama service endpoint | ollama:11434 | Yes |

## Usage Examples

### Example 1: Basic Chat

1. **Access the chat interface:**
   - Open the workflow in n8n
   - Click the "Chat" button at the bottom
   - Start typing messages

2. **Sample conversation:**
   ```
   User: What is machine learning?
   AI: Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed...
   
   User: Can you give me an example?
   AI: Sure! A common example is email spam filtering. The system learns from examples of spam and legitimate emails...
   ```

### Example 2: API Integration

Access the chat via webhook URL:

```bash
curl -X POST "http://localhost:5678/webhook/ai-chat-basic-webhook" \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Explain quantum computing",
    "sessionId": "user-123"
  }'
```

### Example 3: Web Integration

Embed in a web page:

```html
<iframe 
  src="http://localhost:5678/webhook/ai-chat-basic-webhook" 
  width="400" 
  height="600"
  frameborder="0">
</iframe>
```

## Test Data

Test data is available in the `test-data/` directory:

- `sample-questions.json` - Example chat inputs
- `expected-responses.json` - Sample AI responses
- `conversation-flows.json` - Multi-turn conversation examples

## Error Handling

| Error Code | Description | Solution |
|------------|-------------|----------|
| Connection Failed | Cannot reach Ollama service | Check Ollama is running and accessible |
| Model Not Found | llama3.2 model not available | Run `ollama pull llama3.2` |
| Authentication Error | Invalid Ollama credential | Reconfigure credential with correct URL |
| Timeout | Request took too long | Check Ollama performance, consider smaller model |

## Monitoring & Logs

- **n8n Execution Logs**: Check workflow execution history in n8n interface
- **Ollama Logs**: Monitor with `docker compose logs ollama`
- **Performance**: Track response times and token usage
- **Usage**: Monitor chat session counts and user engagement

## Customization

### Modify AI Behavior

1. **Adjust Temperature**: Change in "Local Ollama Model" node parameters
   - Lower (0.1-0.3): More consistent, factual responses
   - Higher (0.7-1.0): More creative, varied responses

2. **Change Model**: Update model name in node configuration
   - `llama3.2:latest` - General purpose
   - `llama3.2:instruct` - Better for instructions
   - `codellama` - Code-focused responses

3. **Add System Prompt**: Configure in LLM Chain node
   ```
   You are a helpful assistant that always responds in a friendly, professional manner.
   ```

### Add Features

1. **Conversation Memory**: Already included in chain configuration
2. **User Authentication**: Add authentication nodes before chat trigger
3. **Content Filtering**: Add content moderation nodes
4. **Analytics**: Add database storage for chat metrics

## Contributing

This is an example workflow. To create your own based on this pattern:

1. **Copy the structure:**
   ```bash
   ./workflow-management/scripts/create-workflow.sh
   # Choose "AI Chat" category and "Basic AI Chat" template
   ```

2. **Customize for your use case:**
   - Modify system prompts
   - Add domain-specific knowledge
   - Integrate with your systems
   - Add authentication/authorization

3. **Export your changes:**
   ```bash
   ./workflow-management/scripts/export-from-n8n.sh YOUR_WORKFLOW_ID your-workflow-name
   ```

4. **Submit for team review:**
   ```bash
   ./workflow-management/scripts/submit-workflow.sh your-workflow-name
   ```

## Changelog

### Version 1.0.0
- Initial example workflow
- Basic chat functionality with Ollama
- Web interface integration
- Documentation and test data

## Support

- **Team Guidelines:** See `docs/team-guidelines.md`
- **Workflow Development:** See `docs/workflow-development.md`
- **Technical Issues:** Create GitHub issue
- **n8n Documentation:** https://docs.n8n.io/integrations/builtin/cluster-nodes/

## Related Workflows

- `document-processor` - Process documents with AI analysis
- `slack-bot` - Team communication AI assistant
- Advanced AI agent workflows (coming soon)

This example serves as a foundation for building more sophisticated AI-powered workflows in your team environment.