#!/bin/bash
set -e

# Import workflows from repository to running n8n instance
# Usage: ./import-to-n8n.sh <workflow-directory> [--force]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
N8N_URL="http://localhost:5678"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

check_n8n_running() {
    if ! curl -s "$N8N_URL" > /dev/null; then
        log_error "n8n is not running at $N8N_URL"
        log_info "Start it with: docker compose up"
        exit 1
    fi
}

validate_workflow_directory() {
    local workflow_dir="$1"
    
    if [ ! -d "$workflow_dir" ]; then
        log_error "Workflow directory does not exist: $workflow_dir"
        exit 1
    fi
    
    if [ ! -f "$workflow_dir/workflow.json" ]; then
        log_error "workflow.json not found in $workflow_dir"
        exit 1
    fi
    
    # Validate JSON syntax
    if ! jq empty "$workflow_dir/workflow.json" 2>/dev/null; then
        log_error "Invalid JSON in workflow.json"
        exit 1
    fi
    
    log_info "Workflow directory validation passed"
}

check_credentials() {
    local workflow_dir="$1"
    local auth_config="$workflow_dir/auth-config.yml"
    
    if [ ! -f "$auth_config" ]; then
        log_warn "No auth-config.yml found - workflow may need manual credential setup"
        return
    fi
    
    log_step "Checking credential requirements from auth-config.yml..."
    
    # Extract required credentials (basic parsing)
    if grep -q "required_credentials:" "$auth_config"; then
        log_info "Found credential requirements:"
        grep -A 10 "required_credentials:" "$auth_config" | grep "  - " | sed 's/  - /    • /'
        log_warn "Ensure these credentials are configured in n8n before importing"
    fi
}

import_workflow() {
    local workflow_path="$1"
    local force_import="$2"
    
    # Handle both directory and direct file paths
    if [ -d "$workflow_path" ]; then
        local workflow_dir="$workflow_path"
        local workflow_file="$workflow_dir/workflow.json"
    elif [ -f "$workflow_path" ] && [[ "$workflow_path" == *.json ]]; then
        local workflow_file="$workflow_path"
        local workflow_dir="$(dirname "$workflow_path")"
    else
        log_error "Invalid workflow path: $workflow_path"
        log_info "Provide either a workflow directory or a workflow.json file"
        exit 1
    fi
    
    validate_workflow_directory "$workflow_dir"
    check_credentials "$workflow_dir"
    
    # Get workflow info
    local workflow_name=$(jq -r '.name // "Unknown"' "$workflow_file")
    local workflow_id=$(jq -r '.id // empty' "$workflow_file")
    
    log_step "Importing workflow: $workflow_name"
    
    # Copy workflow file to shared directory for import
    local temp_file="/tmp/n8n-import-$(date +%s).json"
    cp "$workflow_file" "$temp_file"
    
    # Copy to shared directory accessible by n8n container
    local shared_file="$PROJECT_ROOT/shared/temp-import.json"
    cp "$workflow_file" "$shared_file"
    
    # Import using n8n CLI
    log_step "Executing n8n import command..."
    
    if [ "$force_import" == "--force" ]; then
        log_warn "Force import enabled - existing workflow will be overwritten"
        import_result=$(docker compose exec -T n8n n8n import:workflow --separate --input=/data/shared/temp-import.json 2>&1 || true)
    else
        import_result=$(docker compose exec -T n8n n8n import:workflow --separate --input=/data/shared/temp-import.json 2>&1 || true)
    fi
    
    # Clean up temp file
    rm -f "$shared_file"
    
    # Check import result
    if echo "$import_result" | grep -q "Successfully imported"; then
        log_info "✅ Workflow imported successfully!"
        
        # Extract new workflow ID if available
        if echo "$import_result" | grep -q "workflow.*with id"; then
            new_id=$(echo "$import_result" | grep -o "with id [^[:space:]]*" | cut -d' ' -f3)
            log_info "🔗 New workflow ID: $new_id"
            log_info "🌐 Access at: $N8N_URL/workflow/$new_id"
            
            # Update metadata with new ID if different
            if [ -f "$workflow_dir/metadata.yml" ] && [ "$workflow_id" != "$new_id" ]; then
                sed -i.bak "s/id: .*/id: $new_id/" "$workflow_dir/metadata.yml"
                rm -f "$workflow_dir/metadata.yml.bak"
                log_info "📝 Updated metadata.yml with new workflow ID"
            fi
        fi
        
        # Show next steps
        log_step "Next steps:"
        echo "1. 🔧 Configure credentials in n8n if needed"
        echo "2. 🧪 Test the workflow with sample data"
        echo "3. 📖 Review the documentation in README.md"
        echo "4. ✅ Activate the workflow when ready"
        
    else
        log_error "❌ Failed to import workflow"
        log_error "Import output:"
        echo "$import_result"
        
        if echo "$import_result" | grep -q "already exists"; then
            log_warn "Workflow might already exist. Use --force to overwrite"
        fi
        exit 1
    fi
}

show_help() {
    echo "Import workflows from repository to running n8n instance"
    echo ""
    echo "Usage: $0 <workflow-directory|workflow.json> [--force]"
    echo ""
    echo "Arguments:"
    echo "  workflow-directory    Directory containing workflow.json and metadata"
    echo "  workflow.json         Direct path to workflow JSON file"
    echo "  --force              Overwrite existing workflow if it exists"
    echo ""
    echo "Examples:"
    echo "  $0 workflows/ai-chat-basic"
    echo "  $0 workflows/ai-chat-basic/workflow.json"
    echo "  $0 workflows/ai-chat-basic --force"
}

# Main execution
if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_help
    exit 0
fi

check_n8n_running
import_workflow "$1" "$2"