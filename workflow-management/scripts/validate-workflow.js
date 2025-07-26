#!/usr/bin/env node

/**
 * Workflow Validation Script
 * Validates n8n workflows for team standards and quality
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// ANSI color codes
const colors = {
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    purple: '\x1b[35m',
    reset: '\x1b[0m'
};

function log(level, message) {
    const prefix = {
        info: `${colors.green}[INFO]${colors.reset}`,
        warn: `${colors.yellow}[WARN]${colors.reset}`,
        error: `${colors.red}[ERROR]${colors.reset}`,
        step: `${colors.blue}[STEP]${colors.reset}`
    };
    console.log(`${prefix[level]} ${message}`);
}

class WorkflowValidator {
    constructor(workflowDir) {
        this.workflowDir = workflowDir;
        this.errors = [];
        this.warnings = [];
        this.info = [];
    }

    validate() {
        log('step', `Validating workflow directory: ${this.workflowDir}`);
        
        // Check directory structure
        this.validateDirectoryStructure();
        
        // Load and validate workflow.json
        const workflow = this.validateWorkflowJson();
        if (!workflow) return this.getResults();
        
        // Load and validate metadata.yml
        const metadata = this.validateMetadata();
        
        // Validate documentation
        this.validateDocumentation();
        
        // Validate auth configuration
        this.validateAuthConfig();
        
        // Validate workflow content
        this.validateWorkflowContent(workflow, metadata);
        
        return this.getResults();
    }

    validateDirectoryStructure() {
        const requiredFiles = [
            'workflow.json',
            'metadata.yml',
            'README.md',
            'auth-config.yml'
        ];

        const optionalFiles = [
            'test-data/README.md'
        ];

        requiredFiles.forEach(file => {
            const filePath = path.join(this.workflowDir, file);
            if (!fs.existsSync(filePath)) {
                this.errors.push(`Missing required file: ${file}`);
            }
        });

        optionalFiles.forEach(file => {
            const filePath = path.join(this.workflowDir, file);
            if (!fs.existsSync(filePath)) {
                this.warnings.push(`Missing optional file: ${file}`);
            }
        });
    }

    validateWorkflowJson() {
        const workflowPath = path.join(this.workflowDir, 'workflow.json');
        
        if (!fs.existsSync(workflowPath)) {
            return null;
        }

        try {
            const content = fs.readFileSync(workflowPath, 'utf8');
            const workflow = JSON.parse(content);

            // Required fields
            const requiredFields = ['id', 'name', 'nodes'];
            requiredFields.forEach(field => {
                if (!workflow[field]) {
                    this.errors.push(`workflow.json missing required field: ${field}`);
                }
            });

            // Validate workflow structure
            if (workflow.nodes && Array.isArray(workflow.nodes)) {
                if (workflow.nodes.length === 0) {
                    this.warnings.push('Workflow has no nodes');
                } else {
                    this.validateWorkflowNodes(workflow.nodes);
                }
            }

            // Check for security issues
            this.validateWorkflowSecurity(workflow);

            return workflow;
        } catch (error) {
            this.errors.push(`Invalid JSON in workflow.json: ${error.message}`);
            return null;
        }
    }

    validateWorkflowNodes(nodes) {
        const nodeTypes = {};
        const nodeIds = new Set();
        
        nodes.forEach((node, index) => {
            // Check required node fields
            if (!node.id) {
                this.errors.push(`Node ${index} missing required field: id`);
            } else if (nodeIds.has(node.id)) {
                this.errors.push(`Duplicate node ID: ${node.id}`);
            } else {
                nodeIds.add(node.id);
            }

            if (!node.type) {
                this.errors.push(`Node ${node.id || index} missing required field: type`);
            } else {
                nodeTypes[node.type] = (nodeTypes[node.type] || 0) + 1;
            }

            if (!node.name) {
                this.warnings.push(`Node ${node.id || index} missing name field`);
            }

            // Check for sensitive data in parameters
            if (node.parameters) {
                this.checkForSensitiveData(node.parameters, `Node ${node.name || node.id}`);
            }
        });

        // Report node type statistics
        this.info.push(`Workflow uses ${Object.keys(nodeTypes).length} different node types`);
        
        // Check for common patterns
        if (nodeTypes['@n8n/n8n-nodes-langchain.chatTrigger']) {
            this.info.push('Workflow includes AI chat functionality');
        }
        if (nodeTypes['n8n-nodes-base.httpRequest']) {
            this.warnings.push('Workflow makes HTTP requests - ensure proper error handling');
        }
    }

    validateWorkflowSecurity(workflow) {
        const workflowStr = JSON.stringify(workflow);
        
        // Check for potential security issues
        const securityPatterns = [
            { pattern: /password.*=.*[^{]/i, message: 'Potential hardcoded password detected' },
            { pattern: /api.?key.*=.*[^{]/i, message: 'Potential hardcoded API key detected' },
            { pattern: /secret.*=.*[^{]/i, message: 'Potential hardcoded secret detected' },
            { pattern: /token.*=.*[^{]/i, message: 'Potential hardcoded token detected' }
        ];

        securityPatterns.forEach(({ pattern, message }) => {
            if (pattern.test(workflowStr)) {
                this.errors.push(`Security issue: ${message}`);
            }
        });
    }

    checkForSensitiveData(obj, context) {
        if (typeof obj === 'string') {
            // Check for potential secrets in string values
            const sensitivePatterns = [
                /sk-[a-zA-Z0-9]{20,}/,  // OpenAI API keys
                /xoxb-[a-zA-Z0-9-]+/,   // Slack bot tokens
                /ghp_[a-zA-Z0-9]{36}/,  // GitHub personal access tokens
            ];

            sensitivePatterns.forEach(pattern => {
                if (pattern.test(obj)) {
                    this.errors.push(`Potential secret detected in ${context}`);
                }
            });
        } else if (typeof obj === 'object' && obj !== null) {
            Object.entries(obj).forEach(([key, value]) => {
                this.checkForSensitiveData(value, `${context}.${key}`);
            });
        }
    }

    validateMetadata() {
        const metadataPath = path.join(this.workflowDir, 'metadata.yml');
        
        if (!fs.existsSync(metadataPath)) {
            return null;
        }

        try {
            const content = fs.readFileSync(metadataPath, 'utf8');
            const metadata = yaml.load(content);

            // Required fields
            const requiredFields = ['name', 'id', 'description', 'author', 'created_at'];
            requiredFields.forEach(field => {
                if (!metadata[field]) {
                    this.errors.push(`metadata.yml missing required field: ${field}`);
                }
            });

            // Validate date formats
            if (metadata.created_at && !this.isValidISODate(metadata.created_at)) {
                this.errors.push('Invalid created_at date format in metadata.yml');
            }
            if (metadata.updated_at && !this.isValidISODate(metadata.updated_at)) {
                this.errors.push('Invalid updated_at date format in metadata.yml');
            }

            // Check version format
            if (metadata.version && !this.isValidSemVer(metadata.version)) {
                this.warnings.push('Version should follow semantic versioning (e.g., 1.0.0)');
            }

            return metadata;
        } catch (error) {
            this.errors.push(`Invalid YAML in metadata.yml: ${error.message}`);
            return null;
        }
    }

    validateDocumentation() {
        const readmePath = path.join(this.workflowDir, 'README.md');
        
        if (!fs.existsSync(readmePath)) {
            return;
        }

        const content = fs.readFileSync(readmePath, 'utf8');
        
        // Check for template placeholders
        const placeholders = content.match(/{{[^}]+}}/g);
        if (placeholders) {
            this.warnings.push(`README.md contains template placeholders: ${placeholders.join(', ')}`);
        }

        // Check for minimum documentation sections
        const requiredSections = [
            'Description',
            'Setup',
            'Usage',
            'Authentication'
        ];

        requiredSections.forEach(section => {
            const sectionRegex = new RegExp(`##\\s*${section}`, 'i');
            if (!sectionRegex.test(content)) {
                this.warnings.push(`README.md missing section: ${section}`);
            }
        });

        // Check documentation length
        if (content.length < 500) {
            this.warnings.push('README.md seems too short - consider adding more detailed documentation');
        }
    }

    validateAuthConfig() {
        const authPath = path.join(this.workflowDir, 'auth-config.yml');
        
        if (!fs.existsSync(authPath)) {
            return;
        }

        try {
            const content = fs.readFileSync(authPath, 'utf8');
            const authConfig = yaml.load(content);

            if (authConfig.required_credentials && Array.isArray(authConfig.required_credentials)) {
                if (authConfig.required_credentials.length > 0) {
                    this.info.push(`Workflow requires ${authConfig.required_credentials.length} credential(s)`);
                    
                    authConfig.required_credentials.forEach(cred => {
                        if (!cred.name || !cred.type) {
                            this.warnings.push('Credential configuration incomplete');
                        }
                    });
                }
            }
        } catch (error) {
            this.errors.push(`Invalid YAML in auth-config.yml: ${error.message}`);
        }
    }

    isValidISODate(dateString) {
        const date = new Date(dateString);
        return date instanceof Date && !isNaN(date) && dateString.includes('T');
    }

    isValidSemVer(version) {
        const semVerRegex = /^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$/;
        return semVerRegex.test(version);
    }

    getResults() {
        return {
            valid: this.errors.length === 0,
            errors: this.errors,
            warnings: this.warnings,
            info: this.info
        };
    }
}

// CLI interface
function main() {
    const args = process.argv.slice(2);
    
    if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
        console.log('Usage: node validate-workflow.js <workflow-directory>');
        console.log('');
        console.log('Validates n8n workflow structure and content for team standards.');
        process.exit(0);
    }

    const workflowDir = args[0];
    
    if (!fs.existsSync(workflowDir)) {
        log('error', `Workflow directory does not exist: ${workflowDir}`);
        process.exit(1);
    }

    if (!fs.statSync(workflowDir).isDirectory()) {
        log('error', `Path is not a directory: ${workflowDir}`);
        process.exit(1);
    }

    const validator = new WorkflowValidator(workflowDir);
    const results = validator.validate();

    // Output results
    console.log('\n' + '='.repeat(50));
    console.log(`${colors.purple}Workflow Validation Report${colors.reset}`);
    console.log('='.repeat(50));

    if (results.info.length > 0) {
        console.log(`\n${colors.blue}Information:${colors.reset}`);
        results.info.forEach(info => console.log(`  ℹ️  ${info}`));
    }

    if (results.warnings.length > 0) {
        console.log(`\n${colors.yellow}Warnings:${colors.reset}`);
        results.warnings.forEach(warning => console.log(`  ⚠️  ${warning}`));
    }

    if (results.errors.length > 0) {
        console.log(`\n${colors.red}Errors:${colors.reset}`);
        results.errors.forEach(error => console.log(`  ❌ ${error}`));
    }

    console.log('\n' + '='.repeat(50));
    
    if (results.valid) {
        log('info', '✅ Workflow validation passed!');
        console.log('\n🚀 Ready for submission. Run: ./workflow-management/scripts/submit-workflow.sh');
        process.exit(0);
    } else {
        log('error', `❌ Workflow validation failed with ${results.errors.length} error(s)`);
        console.log('\n🔧 Fix the errors above and run validation again.');
        process.exit(1);
    }
}

// Handle missing js-yaml gracefully
try {
    require.resolve('js-yaml');
} catch (e) {
    console.log(`${colors.yellow}[WARN]${colors.reset} js-yaml not found. Installing...`);
    require('child_process').execSync('npm install js-yaml', { stdio: 'inherit' });
    // Re-require after installation
    global.yaml = require('js-yaml');
}

if (require.main === module) {
    main();
}