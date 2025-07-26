# Team Workflow Guidelines

This document outlines the standards and best practices for developing n8n workflows as a team using this repository.

## Overview

Our team workflow management system enables:
- **Version Control**: All workflows are tracked in git with proper documentation
- **Collaboration**: Multiple developers can work on workflows simultaneously
- **Quality Assurance**: Automated validation ensures consistency and security
- **Non-technical Participation**: Guided scripts help non-developers contribute
- **Documentation**: Comprehensive docs for setup, usage, and maintenance

## Workflow Development Process

### 1. Creating a New Workflow

```bash
# Interactive workflow creation
./workflow-management/scripts/create-workflow.sh
```

This will:
- Prompt for workflow details (name, description, category)
- Create proper directory structure
- Generate documentation templates
- Set up authentication configuration

### 2. Developing the Workflow

1. **Import to n8n for visual editing:**
   ```bash
   ./workflow-management/scripts/import-to-n8n.sh workflows/your-workflow
   ```

2. **Design visually in n8n** at http://localhost:5678

3. **Export back to repository:**
   ```bash
   ./workflow-management/scripts/export-from-n8n.sh [workflow-id] your-workflow
   ```

### 3. Documentation and Testing

1. **Update README.md** with:
   - Clear description and use cases
   - Setup instructions
   - Input/output specifications
   - Usage examples
   - Troubleshooting guide

2. **Configure authentication** in `auth-config.yml`:
   - Document all required credentials
   - Provide setup instructions
   - Include security considerations

3. **Add test data** in `test-data/` directory

4. **Validate the workflow:**
   ```bash
   ./workflow-management/scripts/validate-workflow.js workflows/your-workflow
   ```

### 4. Submission and Review

```bash
# Submit for team review
./workflow-management/scripts/submit-workflow.sh your-workflow

# For early feedback, use draft PR
./workflow-management/scripts/submit-workflow.sh your-workflow --draft
```

## Quality Standards

### Code Quality

- **No Hardcoded Secrets**: Use n8n credentials system
- **Error Handling**: Implement proper error handling for all nodes
- **Naming Conventions**: Use descriptive names for nodes and workflows
- **Documentation**: Every workflow must have complete documentation
- **Testing**: Include test data and validation scenarios

### Security Requirements

- **Credential Management**: All secrets in n8n credential store
- **Access Control**: Document required permissions and scopes
- **Data Privacy**: Ensure sensitive data is handled appropriately
- **Local Processing**: Prefer local AI processing (Ollama) over external APIs
- **Validation**: All inputs should be validated

### Documentation Standards

- **README.md**: Complete setup and usage guide
- **auth-config.yml**: Detailed authentication requirements
- **metadata.yml**: Accurate workflow metadata
- **Test Data**: Sample inputs and expected outputs
- **Changelog**: Version history and changes

## Review Process

### For Reviewers

When reviewing a workflow PR:

1. **Functionality Review**:
   - Import and test the workflow
   - Verify all documented use cases
   - Check error handling scenarios
   - Test with provided sample data

2. **Security Review**:
   - No hardcoded secrets or credentials
   - Proper input validation
   - Secure credential configuration
   - Appropriate error messages (no sensitive info leakage)

3. **Documentation Review**:
   - Clear and accurate setup instructions
   - Complete authentication guide
   - Working examples and test cases
   - Proper troubleshooting information

4. **Code Quality Review**:
   - Follows naming conventions
   - Proper node organization
   - Reuses shared components where appropriate
   - Efficient workflow design

### Review Checklist

- [ ] **Workflow imports successfully**
- [ ] **All credentials documented and testable**
- [ ] **Documentation is complete and accurate**
- [ ] **No security issues or hardcoded secrets**
- [ ] **Test data works as expected**
- [ ] **Error handling is appropriate**
- [ ] **Follows team conventions**
- [ ] **Performance is acceptable**

## Shared Components

### Reusable Node Configurations

Store common node configurations in `workflow-management/shared-components/common-nodes/`:
- Standard HTTP request patterns
- Common data transformations
- Error handling templates
- Logging configurations

### Credential Templates

Standard credential configurations in `workflow-management/shared-components/credentials/`:
- Ollama API setup
- PostgreSQL connections
- Common API patterns

### Utilities

Helper functions and common utilities in `workflow-management/shared-components/utilities/`:
- Data validation functions
- Common transformations
- Utility workflows

## Environment Management

### Local Development

- Use the provided Docker Compose setup
- Ollama for AI processing: `http://ollama:11434`
- Qdrant for vector storage: `http://qdrant:6333`
- PostgreSQL for data: configured via environment variables

### Environment Variables

Standard environment variables in `.env`:
```bash
POSTGRES_USER=root
POSTGRES_PASSWORD=password
POSTGRES_DB=n8n
N8N_ENCRYPTION_KEY=super-secret-key
N8N_USER_MANAGEMENT_JWT_SECRET=even-more-secret
OLLAMA_HOST=ollama:11434  # or host.docker.internal:11434 for Mac
```

## Naming Conventions

### Workflow Names
- Use lowercase with hyphens: `ai-chat-basic`
- Be descriptive: `document-pdf-processor`
- Include category prefix when helpful: `slack-bot-notifications`

### Node Names
- Use descriptive names: "Parse PDF Content"
- Be consistent within workflow
- Use action verbs: "Send", "Process", "Transform"

### File Structure
```
workflows/your-workflow-name/
├── workflow.json          # n8n workflow definition
├── metadata.yml          # workflow metadata
├── README.md             # documentation
├── auth-config.yml       # authentication setup
└── test-data/           # test files and examples
    ├── sample-input.json
    └── expected-output.json
```

## Troubleshooting

### Common Issues

1. **Workflow Import Fails**
   - Check JSON syntax in workflow.json
   - Verify all required credentials exist
   - Ensure n8n is running and accessible

2. **Credential Errors**
   - Verify auth-config.yml is accurate
   - Check credential names match exactly
   - Test connections in n8n interface

3. **Validation Failures**
   - Fix errors reported by validation script
   - Ensure all required files present
   - Check for template placeholders in documentation

4. **PR Submission Issues**
   - Ensure GitHub CLI is authenticated
   - Check git repository status
   - Run validation before submission

### Getting Help

- **Documentation**: Check `docs/workflow-development.md`
- **Examples**: Look at existing workflows in `workflows/examples/`
- **Issues**: Create GitHub issue for bugs or feature requests
- **Team Chat**: Use team communication channels for questions

## Best Practices

### Development Workflow

1. **Start Small**: Begin with simple functionality, iterate to add features
2. **Test Early**: Test frequently during development
3. **Document as You Go**: Update docs while developing, not after
4. **Use Examples**: Reference existing workflows for patterns
5. **Seek Feedback**: Use draft PRs for early feedback

### Performance Considerations

- **Minimize HTTP Requests**: Batch operations when possible
- **Use Local Processing**: Prefer Ollama over external AI APIs
- **Efficient Data Handling**: Process data in appropriate chunks
- **Resource Management**: Be mindful of memory and CPU usage

### Maintenance

- **Regular Updates**: Keep workflows updated with n8n changes
- **Dependency Management**: Document and manage external dependencies
- **Security Updates**: Regularly review and update credentials
- **Performance Monitoring**: Monitor execution times and resource usage

## Integration with Claude Code

This repository is optimized for Claude Code development. See `.claude-context/` for:
- Workflow development patterns
- Common troubleshooting solutions
- Integration guidelines
- Development context

## Support and Resources

- **n8n Documentation**: https://docs.n8n.io/
- **Team Repository**: This repository's README and docs
- **Workflow Examples**: `workflows/examples/` directory
- **Community**: n8n community forum for general n8n questions