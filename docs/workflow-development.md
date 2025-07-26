# Workflow Development Guide

This guide provides detailed instructions for developing n8n workflows within our team environment.

## Getting Started

### Prerequisites

1. **Docker Environment Running**:
   ```bash
   docker compose up
   ```
   Verify services:
   - n8n: http://localhost:5678
   - Qdrant: http://localhost:6333
   - Ollama: http://localhost:11434

2. **Required Tools**:
   - Git (for version control)
   - GitHub CLI (`gh`) for PR management
   - Node.js (for validation scripts)
   - jq (for JSON processing)

3. **Repository Setup**:
   ```bash
   # Ensure you have the latest code
   git pull origin main
   
   # Make scripts executable
   chmod +x workflow-management/scripts/*.sh
   ```

## Development Workflow

### Step 1: Create New Workflow

Use the interactive creation script:

```bash
./workflow-management/scripts/create-workflow.sh
```

This will prompt you for:
- Workflow name
- Description  
- Author
- Category (AI Chat, Document Processing, etc.)
- Template type

The script creates a complete workflow directory with:
- `workflow.json` - Basic n8n workflow template
- `metadata.yml` - Workflow metadata and configuration
- `README.md` - Documentation template
- `auth-config.yml` - Authentication requirements
- `test-data/` - Directory for test files

### Step 2: Import to n8n for Visual Development

```bash
./workflow-management/scripts/import-to-n8n.sh workflows/your-workflow-name
```

This imports your workflow template into the running n8n instance where you can:
- Design the workflow visually
- Configure nodes and connections
- Test functionality
- Set up credentials

### Step 3: Develop in n8n Visual Editor

Open http://localhost:5678 and find your imported workflow:

1. **Design Your Workflow**:
   - Add nodes from the node panel
   - Configure parameters for each node
   - Connect nodes to create the flow
   - Use the sticky note node for documentation

2. **Configure Credentials**:
   - Set up required credentials in n8n
   - Test connections to external services
   - Document credential requirements

3. **Test Thoroughly**:
   - Use the workflow execution panel
   - Test with sample data
   - Verify error handling
   - Check edge cases

### Step 4: Export Back to Repository

Once your workflow is working in n8n:

```bash
./workflow-management/scripts/export-from-n8n.sh WORKFLOW_ID your-workflow-name
```

Find the workflow ID from the n8n URL: `http://localhost:5678/workflow/YOUR_WORKFLOW_ID`

This updates your repository files with the latest workflow definition.

### Step 5: Complete Documentation

Update the generated documentation:

1. **README.md**:
   - Replace template placeholders
   - Add detailed description and use cases
   - Include setup instructions
   - Document input/output formats
   - Add usage examples
   - Include troubleshooting section

2. **auth-config.yml**:
   - Document all required credentials
   - Provide setup instructions for each
   - Include security considerations
   - Add testing procedures

3. **metadata.yml**:
   - Update tags and categories
   - Add dependencies
   - Document environment requirements

### Step 6: Add Test Data

Create test files in the `test-data/` directory:

```bash
# Example test data structure
test-data/
├── README.md
├── sample-input.json       # Example input data
├── expected-output.json    # Expected output format
├── test-files/            # Sample files for processing
│   ├── sample.pdf
│   └── sample.txt
└── edge-cases/            # Edge case test data
    ├── empty-input.json
    └── large-input.json
```

### Step 7: Validate Workflow

Run the validation script to ensure quality standards:

```bash
./workflow-management/scripts/validate-workflow.js workflows/your-workflow-name
```

The validator checks:
- Required files present
- Valid JSON/YAML syntax
- No hardcoded secrets
- Documentation completeness
- Metadata accuracy
- Security best practices

### Step 8: Submit for Review

Create a pull request for team review:

```bash
# For completed workflows
./workflow-management/scripts/submit-workflow.sh your-workflow-name

# For early feedback (draft PR)
./workflow-management/scripts/submit-workflow.sh your-workflow-name --draft
```

## Development Patterns

### AI Chat Workflows

Common pattern for AI chat workflows using Ollama:

1. **Chat Trigger**: Use `@n8n/n8n-nodes-langchain.chatTrigger`
2. **LLM Chain**: Use `@n8n/n8n-nodes-langchain.chainLlm`
3. **Ollama Model**: Configure `@n8n/n8n-nodes-langchain.lmChatOllama`

Example credential setup for Ollama:
```yaml
- name: "ollama_api"
  type: "ollamaApi"
  base_url: "http://ollama:11434"
```

### Document Processing Workflows

Common pattern for document processing:

1. **File Trigger**: Monitor directory or webhook
2. **File Processing**: Extract text, parse format
3. **AI Analysis**: Use Ollama for content analysis
4. **Output**: Save results or trigger notifications

### API Integration Workflows

Pattern for external API integrations:

1. **Webhook/Schedule Trigger**: Initiate workflow
2. **HTTP Request**: Call external APIs
3. **Data Transformation**: Process response data
4. **Error Handling**: Handle API failures gracefully
5. **Storage**: Save to PostgreSQL or files

## Working with Shared Components

### Using Common Node Configurations

Reuse standardized node configurations from `workflow-management/shared-components/common-nodes/`:

```bash
# Copy common HTTP request configuration
cp workflow-management/shared-components/common-nodes/http-request-template.json my-config.json
```

### Standard Credential Patterns

Use credential templates from `workflow-management/shared-components/credentials/`:

- `ollama-local.yml` - Local Ollama setup
- `postgres-local.yml` - Local PostgreSQL connection
- `webhook-auth.yml` - Webhook authentication patterns

### Utility Functions

Use helper utilities from `workflow-management/shared-components/utilities/`:

- Data validation functions
- Common transformations
- Error handling patterns
- Logging configurations

## Testing and Debugging

### Local Testing

1. **Use n8n Test Feature**:
   - Click "Test workflow" in n8n interface
   - Use the execution panel to see results
   - Check node outputs and errors

2. **Test with Sample Data**:
   - Use files from `test-data/` directory
   - Test various input scenarios
   - Verify output formats

3. **Debug Issues**:
   - Check n8n logs: `docker compose logs n8n`
   - Use webhook.site for testing webhooks
   - Enable debug mode in workflow settings

### Integration Testing

Test workflow integration with the full stack:

1. **Database Integration**:
   ```bash
   # Check PostgreSQL connection
   docker compose exec postgres psql -U $POSTGRES_USER -d $POSTGRES_DB
   ```

2. **AI Service Testing**:
   ```bash
   # Test Ollama directly
   curl http://localhost:11434/api/generate -d '{"model":"llama3.2","prompt":"Hello"}'
   ```

3. **Vector Database Testing**:
   ```bash
   # Check Qdrant status
   curl http://localhost:6333/
   ```

## Performance Optimization

### Best Practices

1. **Batch Processing**: Process multiple items together when possible
2. **Efficient Queries**: Optimize database queries and API calls
3. **Memory Management**: Handle large files appropriately
4. **Caching**: Use n8n's built-in caching where beneficial

### Monitoring

Monitor workflow performance:

1. **Execution Time**: Check workflow execution duration
2. **Resource Usage**: Monitor CPU and memory usage
3. **Error Rates**: Track failed executions
4. **Throughput**: Measure items processed per hour

## Security Considerations

### Credential Management

- **Never hardcode secrets** in workflow JSON
- **Use n8n credential system** for all authentication
- **Document required permissions** in auth-config.yml
- **Test with minimal privileges** required

### Data Handling

- **Validate all inputs** to prevent injection attacks
- **Sanitize file uploads** and user content
- **Handle sensitive data** according to privacy requirements
- **Log appropriately** without exposing secrets

### Network Security

- **Use HTTPS** for external API calls
- **Validate certificates** for security-critical connections
- **Implement rate limiting** for public endpoints
- **Monitor access patterns** for anomalies

## Troubleshooting

### Common Issues

1. **Import Failures**:
   ```bash
   # Check workflow JSON syntax
   jq empty workflows/your-workflow/workflow.json
   
   # Verify n8n is running
   curl http://localhost:5678
   ```

2. **Credential Errors**:
   - Check credential names match exactly
   - Verify credentials are properly configured in n8n
   - Test credentials independently

3. **Node Execution Errors**:
   - Check node configuration
   - Verify input data format
   - Review error messages in execution log

4. **Performance Issues**:
   - Check for infinite loops
   - Optimize data processing
   - Review resource usage

### Debug Workflows

Enable detailed logging:

1. **Workflow Settings**: Enable "Save manual executions"
2. **Node Settings**: Enable "Always output data"
3. **Environment**: Set `N8N_LOG_LEVEL=debug` for detailed logs

### Getting Help

1. **Documentation**: Check this guide and team guidelines
2. **Examples**: Review existing workflows in `workflows/examples/`
3. **Community**: n8n community forum for general questions
4. **Team**: Create GitHub issues for repository-specific problems

## Advanced Topics

### Custom Node Development

For advanced use cases, consider developing custom nodes:

1. **Node Structure**: Follow n8n node development guidelines
2. **Testing**: Test thoroughly with various inputs
3. **Documentation**: Provide comprehensive documentation
4. **Integration**: Ensure compatibility with team standards

### Workflow Orchestration

For complex multi-workflow scenarios:

1. **Workflow Dependencies**: Document workflow relationships
2. **Data Flow**: Plan data sharing between workflows
3. **Error Handling**: Implement cross-workflow error handling
4. **Monitoring**: Set up monitoring for workflow chains

### CI/CD Integration

Integrate with continuous integration:

1. **Automated Testing**: Run validation on every commit
2. **Deployment**: Automate workflow deployment
3. **Monitoring**: Set up alerts for workflow failures
4. **Rollback**: Plan rollback procedures for issues

## Resources

### Documentation
- [n8n Official Docs](https://docs.n8n.io/)
- [Ollama Documentation](https://ollama.com/docs)
- [Qdrant Documentation](https://qdrant.tech/documentation/)

### Team Resources
- `docs/team-guidelines.md` - Team standards and processes
- `workflows/examples/` - Example implementations
- `.claude-context/` - Claude Code integration context

### External Tools
- [webhook.site](https://webhook.site/) - Webhook testing
- [JSONPath Online](https://jsonpath.com/) - JSON path testing
- [RegEx101](https://regex101.com/) - Regular expression testing