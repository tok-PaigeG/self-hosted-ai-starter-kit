# Claude Code Workflow Development Context

This file provides context for Claude Code when working with n8n workflows in this repository.

## Repository Structure

```
self-hosted-ai-starter-kit/
├── workflows/                      # Version-controlled team workflows
│   ├── examples/                  # Example workflows and templates
│   └── [workflow-name]/           # Individual workflow directories
│       ├── workflow.json         # n8n workflow definition
│       ├── metadata.yml          # Workflow metadata
│       ├── README.md             # Documentation
│       ├── auth-config.yml       # Authentication requirements
│       └── test-data/            # Test files and examples
├── workflow-management/           # Management tools and scripts
│   ├── scripts/                  # Core management scripts
│   ├── templates/                # Templates for new workflows
│   └── shared-components/        # Reusable components
├── docs/                         # Team documentation
├── .claude-context/             # Claude Code context files
└── [existing n8n starter kit files]
```

## Core Management Scripts

### Workflow Creation
```bash
./workflow-management/scripts/create-workflow.sh
```
Interactive script that:
- Prompts for workflow details
- Creates directory structure
- Generates templates
- Sets up documentation

### Import/Export
```bash
# Export from running n8n to repository
./workflow-management/scripts/export-from-n8n.sh WORKFLOW_ID [workflow-name]

# Import from repository to running n8n
./workflow-management/scripts/import-to-n8n.sh workflows/workflow-name
```

### Validation
```bash
./workflow-management/scripts/validate-workflow.js workflows/workflow-name
```
Validates:
- File structure
- JSON/YAML syntax
- Security issues
- Documentation completeness

### Submission
```bash
./workflow-management/scripts/submit-workflow.sh workflow-name [--draft]
```
Creates GitHub PR with:
- Automated branch creation
- Comprehensive PR description
- Review checklist

## Development Workflow

1. **Create**: Use create-workflow.sh for new workflows
2. **Develop**: Import to n8n, design visually, export back
3. **Document**: Complete README.md and auth-config.yml
4. **Test**: Add test data and validate
5. **Submit**: Create PR for team review

## Common Commands for Claude Code

When working with this repository, use these commands:

### Check n8n Status
```bash
docker compose ps
curl http://localhost:5678
```

### Workflow Operations
```bash
# List available workflows
ls workflows/

# Validate specific workflow
./workflow-management/scripts/validate-workflow.js workflows/[name]

# Check workflow in n8n
curl http://localhost:5678/rest/workflows
```

### File Operations
Key files to read/modify:
- `workflows/[name]/workflow.json` - n8n workflow definition
- `workflows/[name]/metadata.yml` - workflow metadata
- `workflows/[name]/README.md` - documentation
- `workflows/[name]/auth-config.yml` - authentication config

## n8n Integration Patterns

### Standard Workflow Structure
Every workflow should have:
- Unique ID and descriptive name
- Proper node naming and organization
- Error handling for critical paths
- Documentation nodes (sticky notes)

### Credential Management
- Use n8n credential system, never hardcode secrets
- Document all credential requirements in auth-config.yml
- Test credentials thoroughly

### Common Node Types
- `@n8n/n8n-nodes-langchain.chatTrigger` - AI chat interfaces
- `@n8n/n8n-nodes-langchain.lmChatOllama` - Local AI processing
- `n8n-nodes-base.httpRequest` - API integrations
- `n8n-nodes-base.postgres` - Database operations

## Security Considerations

### Always Check For
- Hardcoded secrets or API keys
- Proper input validation
- Secure credential configuration
- Appropriate error handling (no secret leakage)

### Security Validation Patterns
```javascript
// Check for potential secrets in workflow JSON
const securityPatterns = [
    /password.*=.*[^{]/i,
    /api.?key.*=.*[^{]/i,
    /secret.*=.*[^{]/i,
    /token.*=.*[^{]/i
];
```

## Team Workflow Standards

### File Requirements
Every workflow must have:
- `workflow.json` - Valid n8n workflow
- `metadata.yml` - Complete metadata
- `README.md` - Comprehensive documentation
- `auth-config.yml` - Authentication setup

### Documentation Standards
- Clear description and use cases
- Complete setup instructions
- Input/output specifications
- Authentication requirements
- Test data and examples
- Troubleshooting guide

### Quality Gates
- Validation script passes
- No security issues
- Complete documentation
- Test data provided
- Team review approved

## Local Development Environment

### Services
- **n8n**: http://localhost:5678 (workflow editor)
- **Ollama**: http://localhost:11434 (local AI)
- **Qdrant**: http://localhost:6333 (vector database)
- **PostgreSQL**: localhost:5432 (data storage)

### Shared Directory
- Host: `./shared/` 
- Container: `/data/shared/`
- Use for file exchange between host and n8n

### Environment Variables
Key variables in `.env`:
```bash
POSTGRES_USER=root
POSTGRES_PASSWORD=password
POSTGRES_DB=n8n
N8N_ENCRYPTION_KEY=super-secret-key
OLLAMA_HOST=ollama:11434
```

## Troubleshooting Common Issues

### Import/Export Problems
- Ensure n8n is running: `docker compose ps`
- Check workflow JSON syntax: `jq empty workflow.json`
- Verify file permissions on scripts

### Validation Failures
- Check required files exist
- Verify no template placeholders remain
- Ensure proper YAML/JSON syntax
- Review security scan results

### Git/PR Issues
- Ensure GitHub CLI authenticated: `gh auth status`
- Check git repository status: `git status`
- Verify branch is clean before submission

## Best Practices for Claude Code

### When Creating Workflows
1. Always use the create-workflow.sh script
2. Follow the established directory structure
3. Complete all template sections thoroughly
4. Add meaningful test data

### When Modifying Workflows
1. Export from n8n after visual changes
2. Update documentation to match changes
3. Re-validate before committing
4. Update version in metadata.yml

### When Reviewing Code
1. Check all required files present
2. Validate JSON/YAML syntax
3. Review for security issues
4. Test import/export functionality
5. Verify documentation accuracy

## Integration with Existing Tools

### n8n Starter Kit Components
- Maintains compatibility with base docker-compose.yml
- Uses existing .env configuration
- Leverages shared/ directory mount
- Integrates with existing services

### Git Workflow
- Creates feature branches automatically
- Generates comprehensive PR descriptions
- Includes review checklists
- Maintains clean commit history

### Development Tools
- Works with existing Docker setup
- Uses standard CLI tools (jq, curl, git)
- Provides Node.js validation scripts
- Integrates with GitHub CLI