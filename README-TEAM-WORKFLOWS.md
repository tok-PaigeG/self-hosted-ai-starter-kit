# Team Workflow Management System

This document provides a quick start guide for the team workflow management system built on top of the n8n self-hosted AI starter kit.

## 🚀 Quick Start

### 1. Environment Setup

```bash
# Ensure environment is running
docker compose up

# Verify services
curl http://localhost:5678  # n8n interface
curl http://localhost:11434  # Ollama AI service
```

### 2. Create Your First Team Workflow

```bash
# Interactive workflow creation
./workflow-management/scripts/create-workflow.sh
```

Follow the prompts to create a structured workflow with documentation templates.

### 3. Develop in n8n

```bash
# Import to n8n for visual editing
./workflow-management/scripts/import-to-n8n.sh workflows/your-workflow-name
```

Open http://localhost:5678 to design your workflow visually.

### 4. Export and Submit

```bash
# Export your completed workflow
./workflow-management/scripts/export-from-n8n.sh WORKFLOW_ID your-workflow-name

# Validate quality and security
./workflow-management/scripts/validate-workflow.js workflows/your-workflow-name

# Submit for team review
./workflow-management/scripts/submit-workflow.sh your-workflow-name
```

## 📁 What's New in Your Repository

### Added Directory Structure
```
workflows/                      # 🆕 Team workflows
├── examples/                  # Example workflows
│   └── ai-chat-basic/        # Complete AI chat example
└── your-workflows/           # Your team's workflows

workflow-management/           # 🆕 Management tools
├── scripts/                  # Automation scripts
├── templates/                # Workflow templates
└── shared-components/        # Reusable components

docs/                         # 🆕 Team documentation
├── team-guidelines.md        # Team standards
└── workflow-development.md   # Development guide

.claude-context/              # 🆕 Claude Code integration
```

### Core Management Scripts
- `create-workflow.sh` - Interactive workflow creator
- `import-to-n8n.sh` - Import workflows to running n8n
- `export-from-n8n.sh` - Export workflows from n8n to repo
- `validate-workflow.js` - Quality and security validation
- `submit-workflow.sh` - Create PR for team review

## 🎯 Key Features

### ✅ Version Control Integration
- All workflows tracked in git with proper documentation
- Automated branching and PR creation
- Team review process with quality gates

### ✅ Quality Assurance
- Automated validation for structure and security
- No hardcoded secrets or credentials
- Documentation completeness checks
- Test data requirements

### ✅ Non-Technical Friendly
- Interactive scripts guide workflow creation
- Comprehensive templates reduce complexity
- Visual n8n editor for workflow design
- Automated export/import handles technical details

### ✅ Security First
- All AI processing stays local (Ollama)
- Credential management through n8n's secure system
- Security scanning prevents secret leakage
- Authentication requirements clearly documented

### ✅ Team Collaboration
- Shared workflow repository
- Standardized documentation and structure
- Code review process for quality
- Reusable components and patterns

## 📖 Example: AI Chat Workflow

A complete example is provided in `workflows/examples/ai-chat-basic/`:

```bash
# Try the example
./workflow-management/scripts/import-to-n8n.sh workflows/examples/ai-chat-basic

# View in n8n interface
open http://localhost:5678
```

This example demonstrates:
- Complete workflow structure
- Documentation standards  
- Authentication configuration
- Test data organization

## 🛠 Development Workflow

1. **Create**: Use interactive script for proper structure
2. **Develop**: Visual editing in n8n interface  
3. **Document**: Complete templates with your specifics
4. **Test**: Add test data and validate locally
5. **Submit**: Automated PR creation for team review
6. **Deploy**: Import approved workflows to team instances

## 📚 Documentation

### Team Guidelines
- `docs/team-guidelines.md` - Standards and best practices
- `docs/workflow-development.md` - Detailed development guide

### Development Context
- `.claude-context/workflow-context.md` - Claude Code integration
- `CLAUDE.md` - Complete repository context for AI assistance

## 🔧 Prerequisites

### Required Tools
- Docker and Docker Compose (for n8n stack)
- Git (for version control)
- GitHub CLI (`gh`) for PR management
- Node.js (for validation scripts)
- `jq` (for JSON processing)

### Installation Check
```bash
# Verify all tools are available
docker --version
git --version
gh --version
node --version
jq --version
```

## 🚨 Important Notes

### Preserves Original Functionality
- All original n8n starter kit features preserved
- Existing docker-compose.yml unchanged
- Original demo workflows still available
- No breaking changes to base setup

### Team-First Design
- Multiple developers can work simultaneously
- Version control prevents conflicts
- Quality gates ensure consistency
- Documentation standards enable collaboration

### Security & Privacy
- All AI processing remains local
- No external API dependencies required
- Credential management through n8n's secure system
- Security validation prevents accidental exposure

## 🆘 Getting Help

### Quick Troubleshooting
```bash
# Check service status
docker compose ps

# Validate workflow structure
./workflow-management/scripts/validate-workflow.js workflows/your-workflow

# Check script permissions
chmod +x workflow-management/scripts/*.sh
```

### Resources
- **Team Guidelines**: `docs/team-guidelines.md`
- **Development Guide**: `docs/workflow-development.md`
- **Example Workflow**: `workflows/examples/ai-chat-basic/`
- **Issues**: Create GitHub issue for problems
- **Original n8n Docs**: https://docs.n8n.io/

---

## Next Steps

1. **Explore the Example**: Import and test `ai-chat-basic` workflow
2. **Create Your First Workflow**: Use the interactive creation script
3. **Read Team Guidelines**: Understand standards and best practices
4. **Start Collaborating**: Submit workflows for team review

This system transforms the n8n starter kit into a collaborative team environment while preserving all original functionality. Happy workflow building! 🎉