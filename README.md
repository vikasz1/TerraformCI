# TerraformCI - Azure App Service Infrastructure

Complete Terraform infrastructure-as-code solution for deploying Azure App Services with virtual networks, CI/CD pipelines, and environment-specific configurations (dev/prod).

## 📋 Features

- **Azure App Service** with Linux runtime
- **Virtual Network (VNet)** with subnets for app and database tiers
- **Network Security Groups** for traffic management
- **App Service Plans** (separate tiers for dev and prod)
- **Application Insights** for monitoring and diagnostics
- **Staging Slots** for blue-green deployments and CI/CD
- **Managed Identity** for secure Azure resource access
- **GitHub Actions Workflows** for automated deployments
- **Environment-specific configurations** (dev/prod using tfvars)

## 🏗️ Architecture

```
├── Resource Group
│   ├── Storage Account
│   ├── Virtual Network
│   │   ├── App Subnet
│   │   │   └── Network Security Group
│   │   └── Database Subnet
│   ├── App Service Plan
│   ├── App Service
│   │   ├── Staging Slot (CI/CD)
│   │   └── VNet Integration
│   └── Application Insights
```

## 📁 Project Structure

```
.
├── main.tf                 # Main infrastructure configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── terraform.dev.tfvars    # Development environment variables
├── terraform.prod.tfvars   # Production environment variables
├── .github/
│   └── workflows/
│       ├── deploy-dev.yml  # Dev deployment pipeline
│       └── deploy-prod.yml # Prod deployment pipeline
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 0.12
- Azure CLI or Azure PowerShell
- Azure Service Principal with appropriate permissions
- GitHub repository (for CI/CD)

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd TerraformCI
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Set environment variables for authentication**

   ```bash
   export ARM_CLIENT_ID="<service-principal-client-id>"
   export ARM_CLIENT_SECRET="<service-principal-client-secret>"
   export ARM_SUBSCRIPTION_ID="<azure-subscription-id>"
   export ARM_TENANT_ID="<azure-tenant-id>"
   ```

4. **Plan deployment for dev environment**

   ```bash
   terraform plan -var-file=terraform.dev.tfvars
   ```

5. **Apply configuration for dev environment**

   ```bash
   terraform apply -var-file=terraform.dev.tfvars
   ```

6. **For production deployment**
   ```bash
   terraform plan -var-file=terraform.prod.tfvars
   terraform apply -var-file=terraform.prod.tfvars
   ```

## 📝 Configuration Files

### terraform.dev.tfvars

Development environment configuration with:

- **Basic B1** App Service Plan (cost-effective)
- VNet: 10.0.0.0/16
- App Subnet: 10.0.1.0/24
- Database Subnet: 10.0.2.0/24
- CI/CD enabled (develop branch)

### terraform.prod.tfvars

Production environment configuration with:

- **Standard S2** App Service Plan (higher capacity)
- VNet: 10.1.0.0/16
- App Subnet: 10.1.1.0/24
- Database Subnet: 10.1.2.0/24
- CI/CD enabled (main branch)

## 🔑 Required Variables

| Variable                  | Type              | Required | Default        | Description                           |
| ------------------------- | ----------------- | -------- | -------------- | ------------------------------------- |
| `client_id`               | string            | Yes      | -              | Azure Service Principal Client ID     |
| `client_secret`           | string            | Yes      | -              | Azure Service Principal Client Secret |
| `subscription_id`         | string            | Yes      | -              | Azure Subscription ID                 |
| `tenant_id`               | string            | Yes      | -              | Azure Tenant ID                       |
| `environment`             | string            | Yes      | -              | Environment name (dev/prod)           |
| `location`                | string            | No       | Southeast Asia | Azure region                          |
| `resource_group_name`     | string            | Yes      | -              | Resource group name                   |
| `app_service_plan_tier`   | string            | Yes      | -              | Tier (B/S/P)                          |
| `app_service_plan_size`   | string            | Yes      | -              | Size (1/2/3)                          |
| `vnet_address_space`      | list(string)      | Yes      | -              | VNet address space                    |
| `subnet_address_prefixes` | map(list(string)) | Yes      | -              | Subnet configurations                 |
| `app_service_name`        | string            | Yes      | -              | App Service name                      |
| `docker_image`            | string            | No       | ""             | Docker image URI                      |
| `enable_ci_cd`            | bool              | No       | true           | Enable staging slots                  |
| `repository_url`          | string            | No       | ""             | Git repository URL                    |
| `repository_branch`       | string            | No       | main           | Git branch                            |
| `tags`                    | map(string)       | No       | {}             | Resource tags                         |

## 📤 Outputs

The infrastructure exports the following outputs:

- `resource_group_name` - Resource group name
- `vnet_name` - Virtual network name
- `app_subnet_id` - App subnet ID
- `app_service_name` - App Service name
- `app_service_url` - App Service HTTPS URL
- `app_service_principal_id` - Managed Identity principal ID
- `application_insights_id` - Application Insights resource ID
- `application_insights_instrumentation_key` - Instrumentation key for monitoring

## 🔄 CI/CD Setup

### GitHub Secrets Required

Configure these secrets in your GitHub repository:

```
AZURE_CLIENT_ID           # Service Principal Client ID
AZURE_CLIENT_SECRET       # Service Principal Client Secret
AZURE_SUBSCRIPTION_ID     # Azure Subscription ID
AZURE_TENANT_ID          # Azure Tenant ID
AZURE_CREDENTIALS        # JSON credentials for azure/login action
```

### GitHub Environments

Create two environments in your GitHub repository:

1. **development** - For dev deployments (protection rules optional)
2. **production** - For prod deployments (require approval)

### Workflow Triggers

- **Deploy Dev** (`deploy-dev.yml`)
  - Triggered on: push to `develop` branch
  - Manual trigger: workflow_dispatch

- **Deploy Prod** (`deploy-prod.yml`)
  - Triggered on: push to `main` branch
  - Manual trigger: workflow_dispatch

## 🔐 Security Best Practices

1. **Use Managed Identities**
   - Resources use system-assigned managed identities
   - No credential storage in configuration

2. **Network Security**
   - NSG restricts inbound traffic to HTTP/HTTPS only
   - VNet integration for private communication
   - HTTPS-only enforcement on App Service

3. **Secrets Management**
   - Store credentials in GitHub Secrets
   - Use Azure Key Vault for runtime secrets
   - Never commit sensitive data

4. **Environment Isolation**
   - Separate resource groups per environment
   - Different subnet ranges
   - Environment-specific access controls

## 📊 Monitoring & Diagnostics

- **Application Insights** automatically enabled
- Diagnostic logs configured for App Service
- Monitor metrics in Azure Portal
- Custom alerts can be configured

## 🧹 Cleanup

To destroy all resources:

```bash
# For development
terraform destroy -var-file=terraform.dev.tfvars

# For production
terraform destroy -var-file=terraform.prod.tfvars
```

## 🤝 Contributing

1. Create feature branch from `develop`
2. Make changes and test locally
3. Submit pull request to `develop`
4. Approve and merge to trigger dev deployment
5. Merge to `main` for production deployment

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Best Practices](https://www.terraform.io/language)

## 📄 License

This project is licensed under the MIT License.

## 👥 Support

For issues or questions:

1. Check existing GitHub Issues
2. Create a new issue with detailed description
3. Include Terraform version and error messages
