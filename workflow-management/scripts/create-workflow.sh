#!/bin/bash
set -e

# Interactive workflow creation script for team collaboration
# Usage: ./create-workflow.sh

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

prompt_input() {
    local prompt="$1"
    local default="$2"
    local result
    
    if [ -n "$default" ]; then
        echo -n "$prompt [$default]: "
    else
        echo -n "$prompt: "
    fi
    
    read -r result
    if [ -z "$result" ] && [ -n "$default" ]; then
        result="$default"
    fi
    echo "$result"
}

prompt_multiline() {
    local prompt="$1"
    echo "$prompt (press Ctrl+D when done):"
    cat
}

select_category() {
    log_step "Select workflow category:"
    echo "1. AI Agent & Chat"
    echo "2. Document Processing"
    echo "3. Communication & Notifications"
    echo "4. Data Processing & Analysis"
    echo "5. Integration & Automation"
    echo "6. Custom/Other"
    
    local choice
    echo -n "Enter choice (1-6): "
    read -r choice
    
    case $choice in
        1) echo "ai-chat" ;;
        2) echo "document-processing" ;;
        3) echo "communication" ;;
        4) echo "data-processing" ;;
        5) echo "integration" ;;
        6) echo "custom" ;;
        *) echo "custom" ;;
    esac
}

select_template() {
    local category="$1"
    
    log_step "Select workflow template:"
    
    case $category in
        "ai-chat")
            echo "1. Basic AI Chat"
            echo "2. RAG (Retrieval Augmented Generation)"
            echo "3. AI Agent with Tools"
            echo "4. Custom AI Chat"
            ;;
        "document-processing")
            echo "1. PDF Text Extraction"
            echo "2. Document Classification"
            echo "3. Batch Document Processing"
            echo "4. Custom Document Workflow"
            ;;
        "communication")
            echo "1. Slack Bot"
            echo "2. Email Automation"
            echo "3. Teams Integration"
            echo "4. Custom Communication"
            ;;
        *)
            echo "1. Blank Workflow"
            echo "2. HTTP API Endpoint"
            echo "3. Scheduled Task"
            echo "4. File Processor"
            ;;
    esac
    
    local choice
    echo -n "Enter choice: "
    read -r choice
    echo "$choice"
}

create_workflow_directory() {
    local workflow_name="$1"
    local category="$2"
    local description="$3"
    local author="$4"
    local template_choice="$5"
    
    # Sanitize workflow name for filesystem
    local dir_name=$(echo "$workflow_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    local workflow_dir="$PROJECT_ROOT/workflows/$dir_name"
    
    if [ -d "$workflow_dir" ]; then
        log_error "Workflow directory already exists: $workflow_dir"
        exit 1
    fi
    
    mkdir -p "$workflow_dir"
    
    # Create workflow.json from template
    local template_file="$PROJECT_ROOT/workflow-management/templates/workflow-template.json"
    local workflow_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    
    # Copy and customize template
    jq --arg name "$workflow_name" \
       --arg id "$workflow_id" \
       --arg desc "$description" \
       '.name = $name | .id = $id | .meta.description = $desc' \
       "$template_file" > "$workflow_dir/workflow.json"
    
    # Create metadata.yml
    cat > "$workflow_dir/metadata.yml" << EOF
name: "$workflow_name"
id: $workflow_id
description: "$description"
author: "$author"
category: "$category"
created_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
updated_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
version: "1.0.0"
n8n_version: "latest"
tags: ["$category", "team-workflow"]
status: "development"
requirements:
  credentials: []
  nodes: []
  environment_variables: []
testing:
  test_data_provided: false
  validation_rules: []
deployment:
  auto_activate: false
  schedule: null
EOF
    
    # Create README.md from template
    cp "$PROJECT_ROOT/workflow-management/templates/documentation-template.md" "$workflow_dir/README.md"
    
    # Replace placeholders in README
    sed -i.bak "s/{{WORKFLOW_NAME}}/$workflow_name/g" "$workflow_dir/README.md"
    sed -i.bak "s/{{WORKFLOW_ID}}/$workflow_id/g" "$workflow_dir/README.md"
    sed -i.bak "s/{{DESCRIPTION}}/$description/g" "$workflow_dir/README.md"
    sed -i.bak "s/{{AUTHOR}}/$author/g" "$workflow_dir/README.md"
    sed -i.bak "s/{{CATEGORY}}/$category/g" "$workflow_dir/README.md"
    rm "$workflow_dir/README.md.bak"
    
    # Create auth-config.yml from template
    cp "$PROJECT_ROOT/workflow-management/templates/auth-config-template.yml" "$workflow_dir/auth-config.yml"
    
    # Create test data directory
    mkdir -p "$workflow_dir/test-data"
    echo "# Test Data\n\nAdd test data files here for workflow validation." > "$workflow_dir/test-data/README.md"
    
    echo "$workflow_dir"
}

show_next_steps() {
    local workflow_dir="$1"
    local workflow_name="$2"
    
    log_header "✅ Workflow Created Successfully!"
    
    log_info "📁 Workflow directory: $workflow_dir"
    log_info "📝 Files created:"
    echo "   • workflow.json (n8n workflow definition)"
    echo "   • metadata.yml (workflow metadata)"
    echo "   • README.md (documentation template)"
    echo "   • auth-config.yml (authentication configuration)"
    echo "   • test-data/ (test data directory)"
    
    log_step "🚀 Next Steps:"
    echo ""
    echo "1. 📖 Edit README.md with detailed documentation"
    echo "   - Add workflow description and use cases"
    echo "   - Document input/output specifications"
    echo "   - Include setup instructions"
    echo ""
    echo "2. 🔧 Configure authentication (if needed)"
    echo "   - Edit auth-config.yml"
    echo "   - Document required credentials"
    echo ""
    echo "3. 🎨 Design your workflow in n8n"
    echo "   - Import to n8n: ./workflow-management/scripts/import-to-n8n.sh '$workflow_dir'"
    echo "   - Edit visually at: http://localhost:5678"
    echo "   - Export back: ./workflow-management/scripts/export-from-n8n.sh [workflow-id] '$(basename "$workflow_dir")'"
    echo ""
    echo "4. 🧪 Add test data"
    echo "   - Add sample input files to test-data/"
    echo "   - Create validation test cases"
    echo ""
    echo "5. 🚢 Submit for review"
    echo "   - Validate: ./workflow-management/scripts/validate-workflow.js '$workflow_dir'"
    echo "   - Submit PR: ./workflow-management/scripts/submit-workflow.sh '$(basename "$workflow_dir")'"
    echo ""
    
    log_warn "💡 Tips:"
    echo "   • Use shared components from workflow-management/shared-components/"
    echo "   • Follow team guidelines in docs/team-guidelines.md"
    echo "   • Test locally before submitting"
}

# Main workflow creation process
main() {
    log_header "🎯 N8N Team Workflow Creator"
    
    log_info "This script will help you create a new team workflow with proper"
    log_info "documentation, structure, and integration with your n8n instance."
    echo ""
    
    # Gather workflow information
    log_step "📝 Workflow Information"
    workflow_name=$(prompt_input "Workflow name" "")
    if [ -z "$workflow_name" ]; then
        log_error "Workflow name is required"
        exit 1
    fi
    
    description=$(prompt_input "Brief description" "")
    author=$(prompt_input "Author name" "$(git config user.name 2>/dev/null || echo 'Unknown')")
    
    # Select category and template
    echo ""
    category=$(select_category)
    template_choice=$(select_template "$category")
    
    echo ""
    log_step "📋 Summary"
    echo "Name: $workflow_name"
    echo "Description: $description"
    echo "Author: $author"
    echo "Category: $category"
    echo "Template: $template_choice"
    echo ""
    
    confirm=$(prompt_input "Create workflow? (y/N)" "n")
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_info "Workflow creation cancelled"
        exit 0
    fi
    
    # Create the workflow
    workflow_dir=$(create_workflow_directory "$workflow_name" "$category" "$description" "$author" "$template_choice")
    
    # Show next steps
    show_next_steps "$workflow_dir" "$workflow_name"
}

# Run main function
main "$@"