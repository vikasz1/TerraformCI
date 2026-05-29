# CI/CD Deployment Guide

This guide walks through setting up GitHub Actions CI/CD pipelines for automated Azure infrastructure deployments.

## Prerequisites

- GitHub repository with this Terraform code
- Azure subscription with appropriate permissions
- Azure Service Principal with Contributor role
- GitHub account with admin access to the repository

## Step 1: Create Azure Service Principal

### Using Azure CLI

```bash
# Set your subscription
az account set --subscription "<subscription-id>"

# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-terraform" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id>

# Output will contain:
# {
#   "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   "clientSecret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# }
```

### Using Azure Portal

1. Navigate to Azure Active Directory > App registrations
2. Click "New registration"
3. Name: `github-actions-terraform`
4. Click "Register"
5. Go to "Certificates & secrets"
6. Create new client secret
7. Assign Contributor role in IAM

## Step 2: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Create the following secrets:

| Secret Name             | Value                          |
| ----------------------- | ------------------------------ |
| `AZURE_CLIENT_ID`       | Service principal clientId     |
| `AZURE_CLIENT_SECRET`   | Service principal clientSecret |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID          |
| `AZURE_TENANT_ID`       | Azure Tenant ID                |
| `AZURE_CREDENTIALS`     | JSON credentials object\*      |

\*AZURE_CREDENTIALS JSON format:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

## Step 3: Create GitHub Environments

1. Go to Settings > Environments
2. Create "development" environment:
   - No protection rules required
   - (Optional) Configure deployment branches: `develop`
3. Create "production" environment:
   - Add environment protection rule: "Require approval before deployment"
   - Reviewers: Select trusted team members
   - Configure deployment branches: `main`

## Step 4: Update Workflow Files

Edit `.github/workflows/deploy-dev.yml` and `.github/workflows/deploy-prod.yml`:

```yaml
# Update the app service names to match your resources
- name: Deploy to App Service
  uses: azure/webapps-deploy@v2
  with:
    app-name: myapp-dev # or myapp-prod
    package: .
```

## Step 5: Repository Branch Setup

### Development Workflow

1. Create `develop` branch if it doesn't exist:

   ```bash
   git checkout -b develop
   git push -u origin develop
   ```

2. Set `develop` as the development branch (Settings > Branches)

3. Create branch protection rules for `develop`:
   - Require pull request reviews: 1
   - Dismiss stale PR reviews
   - Require branches to be up to date before merging

### Production Workflow

1. `main` branch is default
2. Create branch protection rules for `main`:
   - Require pull request reviews: 2
   - Require status checks to pass
   - Require branches to be up to date before merging
   - Require approval from code owners
   - Allow auto-merge

## Step 6: Configure Code Owners (Optional)

Create `.github/CODEOWNERS`:

```
# Terraform infrastructure
*.tf @devops-team

# Workflows
.github/workflows/ @devops-team

# Configuration
terraform*.tfvars @devops-team
```

## Step 7: Test the Workflows

### Test Development Deployment

```bash
# Create a feature branch from develop
git checkout -b feature/test-workflow develop

# Make a small change
echo "# Test" >> README.md

# Commit and push
git add .
git commit -m "test: CI/CD workflow test"
git push -u origin feature/test-workflow

# Create pull request to develop
# After PR approval and merge, workflow triggers automatically
```

### Monitor the Workflow

1. Go to GitHub repo > Actions
2. Select the running workflow
3. View logs for each job:
   - terraform-plan
   - terraform-apply
   - deploy-to-app-service

## Workflow Execution Details

### Development Deployment (deploy-dev.yml)

```
Trigger: push to develop branch
├─ terraform-plan
│  ├─ Checkout code
│  ├─ Setup Terraform
│  ├─ Format check
│  ├─ Initialize
│  ├─ Validate
│  ├─ Plan
│  └─ Upload artifacts
├─ terraform-apply (depends on plan)
│  ├─ Download plan
│  ├─ Apply configuration
│  └─ Output results
└─ deploy-to-app-service (depends on apply)
   ├─ Azure Login
   └─ Deploy to App Service
```

### Production Deployment (deploy-prod.yml)

Same as development but:

- Uses `terraform.prod.tfvars`
- Requires manual approval in "production" environment
- Uses `main` branch
- Deploys to `myapp-prod`

## Troubleshooting

### Authentication Errors

**Error**: `Error: Error building account: Authenticating as a Service Principal using client secret`

**Solution**:

1. Verify all four secrets are correctly set
2. Ensure Service Principal has Contributor role
3. Check secret values don't have trailing spaces

### Terraform Plan Fails

**Error**: `Module not found` or `Provider not found`

**Solution**:

1. Ensure `terraform init` completes successfully
2. Check internet connectivity (may need to add proxy)
3. Verify .terraform directory isn't in .gitignore

### Deployment Stuck

**Error**: Workflow hanging at "Terraform Apply"

**Solution**:

1. Check if approval is pending in production environment
2. Manually cancel workflow if needed (Actions > Select workflow > Cancel)
3. Review resource quotas in Azure subscription

### App Service Deploy Fails

**Error**: `Error: Unable to find package`

**Solution**:

1. Ensure app code is in repository root or update `package` path
2. Verify App Service plan and runtime match application requirements
3. Check Application Insights connection

## Manual Deployment (Without CI/CD)

For one-time deployments or testing:

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file=terraform.dev.tfvars -out=tfplan

# Apply configuration
terraform apply tfplan

# View outputs
terraform output
```

## Rollback Procedure

```bash
# View previous state
terraform state list

# Revert to previous state (if needed)
terraform state pull > current.state
terraform state push previous.state

# Or use Git to revert infrastructure code
git revert <commit-hash>
git push origin develop  # or main for prod
```

## Best Practices

1. **Always use feature branches** - Never push directly to `develop` or `main`
2. **Code review before merge** - Require PR reviews for all changes
3. **Test in dev first** - Deploy to dev, test thoroughly, then prod
4. **Version your workflows** - Use semantic versioning for workflow updates
5. **Monitor deployments** - Set up alerts in Azure Monitor
6. **Keep secrets secure** - Rotate Service Principal secrets regularly
7. **Document changes** - Update README when modifying infrastructure
8. **Backup state** - Regularly backup `terraform.tfstate`

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Login Action](https://github.com/Azure/login)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Azure Web Apps Deploy Action](https://github.com/Azure/webapps-deploy)
