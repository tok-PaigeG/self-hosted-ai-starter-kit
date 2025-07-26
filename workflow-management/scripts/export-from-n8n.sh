#!/bin/bash
set -e

# Export workflows from running n8n instance to repository
# Usage: ./export-from-n8n.sh [workflow-id] [optional-name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
N8N_URL="http://localhost:5678"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

check_n8n_running() {
    if ! curl -s "$N8N_URL" > /dev/null; then
        log_error "n8n is not running at $N8N_URL"
        log_info "Start it with: docker compose up"
        exit 1
    fi
}

export_workflow() {
    local workflow_id="$1"
    local workflow_name="$2"
    
    if [ -z "$workflow_id" ]; then
        log_error "Usage: $0 <workflow-id> [workflow-name]"
        log_info "Get workflow ID from n8n URL: http://localhost:5678/workflow/YOUR_WORKFLOW_ID"
        exit 1
    fi
    
    log_info "Exporting workflow $workflow_id from n8n..."
    
    # Export workflow using n8n CLI inside container
    local export_result
    export_result=$(docker compose exec -T n8n n8n export:workflow --id="$workflow_id" --output=json 2>/dev/null || echo "")
    
    if [ -z "$export_result" ]; then
        log_error "Failed to export workflow $workflow_id"
        log_warn "Make sure the workflow ID is correct and the workflow exists"
        exit 1
    fi
    
    # Generate workflow directory name
    if [ -z "$workflow_name" ]; then
        # Extract name from workflow JSON or use ID
        workflow_name=$(echo "$export_result" | jq -r '.name // empty' 2>/dev/null || echo "")
        if [ -z "$workflow_name" ]; then
            workflow_name="workflow-$workflow_id"
        else
            # Sanitize name for filesystem
            workflow_name=$(echo "$workflow_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
        fi
    fi
    
    # Create workflow directory
    local workflow_dir="$PROJECT_ROOT/workflows/$workflow_name"
    mkdir -p "$workflow_dir"
    
    # Save workflow JSON
    echo "$export_result" | jq '.' > "$workflow_dir/workflow.json"
    
    # Create/update metadata
    cat > "$workflow_dir/metadata.yml" << EOF
name: $(echo "$export_result" | jq -r '.name')
id: $workflow_id
description: "Exported workflow from n8n"
author: $(git config user.name || echo "Unknown")
created_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
exported_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
n8n_version: "latest"
tags: []
categories: []
requirements:
  credentials: []
  nodes: []
EOF
    
    # Create README if it doesn't exist
    if [ ! -f "$workflow_dir/README.md" ]; then
        cp "$PROJECT_ROOT/workflow-management/templates/documentation-template.md" "$workflow_dir/README.md"
        
        # Replace placeholders
        sed -i.bak "s/{{WORKFLOW_NAME}}/$(echo "$export_result" | jq -r '.name')/g" "$workflow_dir/README.md"
        sed -i.bak "s/{{WORKFLOW_ID}}/$workflow_id/g" "$workflow_dir/README.md"
        rm "$workflow_dir/README.md.bak"
    fi
    
    # Create auth config template if it doesn't exist
    if [ ! -f "$workflow_dir/auth-config.yml" ]; then
        cp "$PROJECT_ROOT/workflow-management/templates/auth-config-template.yml" "$workflow_dir/auth-config.yml"
    fi
    
    log_info "Workflow exported to: $workflow_dir"
    log_info "Files created:"
    log_info "  - workflow.json (n8n workflow definition)"
    log_info "  - metadata.yml (workflow metadata)"
    log_info "  - README.md (documentation)"
    log_info "  - auth-config.yml (authentication requirements)"
    
    log_warn "Next steps:"
    log_warn "1. Update README.md with proper documentation"
    log_warn "2. Configure auth-config.yml with required credentials"
    log_warn "3. Add test data if needed"
    log_warn "4. Commit and create PR with: ./workflow-management/scripts/submit-workflow.sh $workflow_name"
}

# Main execution
check_n8n_running
export_workflow "$1" "$2"