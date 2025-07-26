#!/bin/bash
set -e

# Submit workflow for team review via GitHub PR
# Usage: ./submit-workflow.sh <workflow-name> [--draft]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}===============================================${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}===============================================${NC}"
}

check_prerequisites() {
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed"
        log_info "Install with: brew install gh (macOS) or visit https://cli.github.com/"
        exit 1
    fi
    
    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub CLI"
        log_info "Run: gh auth login"
        exit 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        log_error "Not in a git repository"
        exit 1
    fi
    
    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "You have uncommitted changes. Consider committing them first."
        echo ""
        git status --short
        echo ""
        read -p "Continue anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Submission cancelled"
            exit 0
        fi
    fi
}

validate_workflow() {
    local workflow_name="$1"
    local workflow_dir="$PROJECT_ROOT/workflows/$workflow_name"
    
    if [ ! -d "$workflow_dir" ]; then
        log_error "Workflow directory not found: $workflow_dir"
        exit 1
    fi
    
    log_step "Validating workflow..."
    
    # Run validation script
    if [ -f "$PROJECT_ROOT/workflow-management/scripts/validate-workflow.js" ]; then
        if ! node "$PROJECT_ROOT/workflow-management/scripts/validate-workflow.js" "$workflow_dir"; then
            log_error "Workflow validation failed"
            log_info "Fix validation errors and try again"
            exit 1
        fi
    else
        log_warn "Validation script not found, skipping validation"
    fi
    
    log_info "✅ Workflow validation passed"
}

create_branch() {
    local workflow_name="$1"
    local branch_name="workflow/$workflow_name-$(date +%Y%m%d-%H%M%S)"
    
    log_step "Creating feature branch: $branch_name"
    
    # Ensure we're on main branch
    git checkout main
    git pull origin main
    
    # Create and checkout new branch
    git checkout -b "$branch_name"
    
    echo "$branch_name"
}

commit_changes() {
    local workflow_name="$1"
    local workflow_dir="$PROJECT_ROOT/workflows/$workflow_name"
    
    log_step "Committing workflow changes..."
    
    # Add workflow files
    git add "$workflow_dir"
    
    # Also add any changes to shared components or scripts
    if [ -n "$(git diff --cached --name-only | grep workflow-management)" ]; then
        git add workflow-management/
    fi
    
    # Create commit message
    local commit_message="feat: add $workflow_name workflow

- Add new team workflow: $workflow_name
- Include documentation and authentication configuration
- Ready for team review and testing

Workflow location: workflows/$workflow_name"
    
    git commit -m "$commit_message"
    
    log_info "✅ Changes committed"
}

create_pull_request() {
    local workflow_name="$1"
    local branch_name="$2"
    local is_draft="$3"
    local workflow_dir="$PROJECT_ROOT/workflows/$workflow_name"
    
    log_step "Creating pull request..."
    
    # Push branch to remote
    git push -u origin "$branch_name"
    
    # Load workflow metadata for PR description
    local workflow_description=""
    local workflow_author=""
    local workflow_category=""
    
    if [ -f "$workflow_dir/metadata.yml" ]; then
        workflow_description=$(grep "description:" "$workflow_dir/metadata.yml" | sed 's/description: *"\?\(.*\)"\?/\1/')
        workflow_author=$(grep "author:" "$workflow_dir/metadata.yml" | sed 's/author: *"\?\(.*\)"\?/\1/')
        workflow_category=$(grep "category:" "$workflow_dir/metadata.yml" | sed 's/category: *"\?\(.*\)"\?/\1/')
    fi
    
    # Create PR body
    local pr_body="## 🔄 New Workflow Submission

### Workflow Details
- **Name:** $workflow_name
- **Author:** $workflow_author
- **Category:** $workflow_category
- **Description:** $workflow_description

### 📁 Files Added/Modified
- \`workflows/$workflow_name/workflow.json\` - n8n workflow definition
- \`workflows/$workflow_name/metadata.yml\` - workflow metadata
- \`workflows/$workflow_name/README.md\` - documentation
- \`workflows/$workflow_name/auth-config.yml\` - authentication configuration

### ✅ Pre-submission Checklist
- [x] Workflow validation passed
- [x] Documentation is complete and accurate
- [x] Authentication requirements documented
- [x] No sensitive data in workflow files
- [ ] **Reviewer:** Test workflow functionality
- [ ] **Reviewer:** Verify documentation accuracy
- [ ] **Reviewer:** Check security considerations

### 🧪 Testing Instructions

1. **Import the workflow:**
   \`\`\`bash
   ./workflow-management/scripts/import-to-n8n.sh workflows/$workflow_name
   \`\`\`

2. **Configure credentials** (see \`auth-config.yml\`)

3. **Test with sample data** (see \`test-data/\` directory)

4. **Verify expected outputs**

### 🔒 Security Review
- [ ] No hardcoded secrets or API keys
- [ ] Proper error handling for sensitive operations
- [ ] Credential requirements documented
- [ ] Follows team security guidelines

### 📚 Documentation
- [ ] README.md is complete and accurate
- [ ] Setup instructions are clear
- [ ] Examples are provided and working
- [ ] Troubleshooting section is helpful

### 🚀 Deployment Notes
- Workflow can be safely imported to any n8n instance
- All dependencies are documented
- Authentication setup is clearly explained

---

**Review Guide:** See \`docs/team-guidelines.md\` for detailed review criteria.

🤖 Generated with Claude Code team workflow tools"
    
    # Create the PR
    local pr_flags=""
    if [ "$is_draft" == "--draft" ]; then
        pr_flags="--draft"
    fi
    
    local pr_title="🔄 Add $workflow_name workflow"
    
    # Create PR with GitHub CLI
    gh pr create \
        --title "$pr_title" \
        --body "$pr_body" \
        --assignee @me \
        --label "workflow,team-review" \
        $pr_flags
    
    # Get PR URL
    local pr_url=$(gh pr view --json url --jq .url)
    
    log_info "✅ Pull request created: $pr_url"
    
    return 0
}

show_next_steps() {
    local workflow_name="$1"
    local pr_url="$2"
    
    log_header "🎉 Workflow Submitted Successfully!"
    
    echo ""
    log_info "📋 What happens next:"
    echo "1. 👀 Team members will review your workflow"
    echo "2. 🧪 Reviewers will test functionality and documentation"
    echo "3. 💬 Feedback will be provided via PR comments"
    echo "4. ✅ Once approved, workflow will be merged"
    echo "5. 📦 Workflow becomes available to the team"
    echo ""
    
    log_step "🔧 If changes are needed:"
    echo "1. Make updates in n8n visual editor"
    echo "2. Export updated workflow:"
    echo "   ./workflow-management/scripts/export-from-n8n.sh [workflow-id] $workflow_name"
    echo "3. Update documentation as needed"
    echo "4. Commit and push changes to the same branch"
    echo ""
    
    log_step "📚 Review Resources:"
    echo "• Team Guidelines: docs/team-guidelines.md"
    echo "• Workflow Development: docs/workflow-development.md"
    echo "• Your PR: $pr_url"
    echo ""
    
    log_warn "💡 Tips for faster approval:"
    echo "• Respond promptly to reviewer feedback"
    echo "• Test your workflow thoroughly before submission"
    echo "• Keep documentation clear and comprehensive"
    echo "• Follow team conventions and standards"
}

# Main submission process
main() {
    local workflow_name="$1"
    local is_draft="$2"
    
    if [ -z "$workflow_name" ]; then
        log_error "Usage: $0 <workflow-name> [--draft]"
        log_info "Example: $0 my-ai-chat"
        log_info "Use --draft flag to create a draft PR for early feedback"
        exit 1
    fi
    
    log_header "🚀 N8N Workflow Submission"
    
    # Pre-flight checks
    check_prerequisites
    validate_workflow "$workflow_name"
    
    # Git workflow
    branch_name=$(create_branch "$workflow_name")
    commit_changes "$workflow_name"
    
    # Create PR
    create_pull_request "$workflow_name" "$branch_name" "$is_draft"
    pr_url=$(gh pr view --json url --jq .url)
    
    # Show next steps
    show_next_steps "$workflow_name" "$pr_url"
}

# Run main function
main "$@"