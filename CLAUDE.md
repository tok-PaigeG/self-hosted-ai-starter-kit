# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Self-hosted AI Starter Kit enhanced with **team workflow management capabilities**. It combines the original n8n starter kit (n8n + Ollama + Qdrant + PostgreSQL) with a comprehensive workflow development and collaboration system for teams.

## Repository Structure

### Original Starter Kit (Preserved)
- `docker-compose.yml` - Core services configuration
- `.env` - Environment variables (copied from .env.example)
- `shared/` - File sharing between host and n8n container
- `n8n/demo-data/` - Original demo workflows and credentials

### Team Workflow Management (Added)
- `workflows/` - Version-controlled team workflows
  - `examples/` - Example workflows and templates
  - `[workflow-name]/` - Individual workflow directories
- `workflow-management/` - Management tools and scripts
  - `scripts/` - Core workflow management scripts
  - `templates/` - Templates for new workflows
  - `shared-components/` - Reusable workflow components
- `docs/` - Team documentation and guidelines
- `.claude-context/` - Claude Code context and patterns

## Architecture

### Core Services
- **n8n**: Workflow automation platform (port 5678)
- **Ollama**: Local LLM inference (port 11434)
- **Qdrant**: Vector database (port 6333)
- **PostgreSQL**: Data storage (port 5432)

### Team Workflow System
- **Version Control**: Git-based workflow management
- **Quality Assurance**: Automated validation and security checks
- **Documentation**: Comprehensive templates and guidelines
- **Collaboration**: PR-based review process with GitHub integration

## Common Commands

### Environment Setup
```bash
# Initial setup (if not done)
cp .env.example .env  # Update secrets as needed
docker compose up     # Start all services

# Verify services
docker compose ps
curl http://localhost:5678  # n8n
curl http://localhost:11434  # Ollama
```

### Team Workflow Management

#### Create New Workflow
```bash
./workflow-management/scripts/create-workflow.sh
```
Interactive script that creates complete workflow structure with templates.

#### Import/Export Workflows
```bash
# Export from n8n to repository
./workflow-management/scripts/export-from-n8n.sh WORKFLOW_ID [workflow-name]

# Import from repository to n8n
./workflow-management/scripts/import-to-n8n.sh workflows/workflow-name
```

#### Validation and Quality
```bash
# Validate workflow structure and quality
./workflow-management/scripts/validate-workflow.js workflows/workflow-name

# Submit for team review
./workflow-management/scripts/submit-workflow.sh workflow-name [--draft]
```

### Development Workflow Commands
```bash
# Make scripts executable (if needed)
chmod +x workflow-management/scripts/*.sh

# Install validation dependencies
npm install js-yaml  # For YAML processing in validation

# Check workflow status
ls workflows/  # List available workflows
git status     # Check repository state
```

## Team Workflow Development Process

### 1. Creation
Use `create-workflow.sh` to generate proper structure:
- Workflow directory with all required files
- Documentation templates with placeholders
- Authentication configuration templates
- Test data directories

### 2. Development
- Import template to n8n for visual editing
- Design workflow using n8n interface
- Export completed workflow back to repository
- Update documentation and metadata

### 3. Quality Assurance
- Validation script checks structure, security, documentation
- No hardcoded secrets or credentials
- Complete documentation required
- Test data must be provided

### 4. Collaboration
- Git branch creation and PR submission automated
- Comprehensive review process with checklists
- Team guidelines enforce standards
- GitHub integration for seamless workflow

## Key File Structures

### Workflow Directory Structure
```
workflows/workflow-name/
├── workflow.json         # n8n workflow definition
├── metadata.yml         # workflow metadata and configuration
├── README.md            # comprehensive documentation
├── auth-config.yml      # authentication requirements
└── test-data/          # test files and sample data
    ├── sample-input.json
    └── expected-output.json
```

### Required Documentation Standards
- **Complete setup instructions** with prerequisites
- **Authentication configuration** with credential setup
- **Input/output specifications** with examples
- **Usage examples** and test scenarios
- **Error handling** and troubleshooting guides

## Security and Quality Standards

### Security Requirements
- **No hardcoded secrets** - use n8n credential system only
- **Input validation** for all user-provided data
- **Local processing** - prefer Ollama over external APIs
- **Credential documentation** in auth-config.yml
- **Security scanning** in validation process

### Quality Gates
- Validation script must pass (structure, syntax, security)
- Complete documentation required
- Test data provided for all workflows
- Team review and approval required
- No template placeholders in final documentation

## Integration Patterns

### AI Workflows (Common Pattern)
```javascript
// Standard Ollama integration
{
  "node": "Local Ollama Model",
  "type": "@n8n/n8n-nodes-langchain.lmChatOllama",
  "credentials": "Local Ollama Service",
  "model": "llama3.2:latest"
}
```

### Authentication (Standard Credentials)
- **Ollama API**: `http://ollama:11434` (local processing)
- **PostgreSQL**: Environment variables from .env
- **External APIs**: Documented in auth-config.yml with setup instructions

### File Sharing
- Host directory: `./shared/`
- Container path: `/data/shared/`
- Use for data exchange between workflows and file system

## Development Best Practices

### For New Workflows
1. Always use `create-workflow.sh` for consistent structure
2. Complete all documentation sections thoroughly
3. Test extensively before submission
4. Follow naming conventions (lowercase with hyphens)
5. Add meaningful test data and examples

### For Existing Workflows
1. Export from n8n after visual changes
2. Update documentation to match changes
3. Re-validate before committing
4. Update version numbers in metadata.yml
5. Maintain backwards compatibility when possible

### For Code Reviews
1. Test workflow import/export functionality
2. Verify all credentials are properly documented
3. Check for security issues and hardcoded secrets
4. Ensure documentation is complete and accurate
5. Validate test data works as expected

## Troubleshooting Common Issues

### Import/Export Problems
```bash
# Check n8n is running
docker compose ps | grep n8n
curl http://localhost:5678

# Validate JSON syntax
jq empty workflows/workflow-name/workflow.json

# Check file permissions
ls -la workflow-management/scripts/
```

### Validation Failures
- Ensure all required files exist (workflow.json, metadata.yml, README.md, auth-config.yml)
- Remove template placeholders ({{WORKFLOW_NAME}}, etc.)
- Check YAML/JSON syntax validity
- Review security scan results for hardcoded secrets

### Git/PR Issues
```bash
# Check GitHub CLI authentication
gh auth status

# Verify repository state
git status
git branch

# Test script permissions
./workflow-management/scripts/validate-workflow.js --help
```

## Environment Configuration

### Standard Environment Variables (.env)
```bash
POSTGRES_USER=root
POSTGRES_PASSWORD=password
POSTGRES_DB=n8n
N8N_ENCRYPTION_KEY=super-secret-key
N8N_USER_MANAGEMENT_JWT_SECRET=even-more-secret
OLLAMA_HOST=ollama:11434  # or host.docker.internal:11434 for Mac
```

### Mac-specific Configuration
For Mac users running Ollama locally:
1. Set `OLLAMA_HOST=host.docker.internal:11434` in .env
2. Update n8n Ollama credentials to use `http://host.docker.internal:11434/`

## Team Collaboration Features

### Automated Quality Assurance
- Structure validation (required files, proper format)
- Security scanning (no hardcoded secrets)
- Documentation completeness checks
- Test data validation

### GitHub Integration
- Automated branch creation for workflow submissions
- Comprehensive PR descriptions with review checklists
- Integration with GitHub CLI for seamless workflow
- Team review process with clear guidelines

### Documentation System
- Comprehensive templates for all workflow types
- Team guidelines and development standards
- Example workflows with complete documentation
- Claude Code context for development assistance

## Project Philosophy

This enhanced starter kit maintains the original's **learning and experimentation focus** while adding **team collaboration capabilities**:

- **Simplicity**: Easy workflow creation and management
- **Quality**: Automated validation and review processes  
- **Security**: Local processing with proper credential management
- **Collaboration**: Git-based workflow with team review
- **Documentation**: Comprehensive guides and examples

The system is designed for **learning and development environments**, not production deployment, focusing on enabling teams to rapidly prototype and share AI workflows while maintaining quality standards.