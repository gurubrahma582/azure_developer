# Azure Resource Group - Terraform Configuration

This directory contains a Terraform configuration for creating an Azure Resource Group with automated naming based on the current subscription.

## Overview

This is a foundational Terraform module that creates:

- **Azure Resource Group**: A logical container for managing related Azure resources
- **Dynamic Naming**: Automatically includes the subscription ID to ensure uniqueness across environments

## Prerequisites

Before you can use this configuration from Visual Studio Code, ensure your local environment is ready:

1. **Visual Studio Code terminal**
   - Open the integrated terminal in VS Code (PowerShell, Command Prompt, or Git Bash)
   - Run the checks below from that terminal before continuing

2. **Terraform** (v1.0 or later; v1.15+ recommended)
   - Download from: https://www.terraform.io/downloads
   - Verify installation: `terraform --version`
   - Example output in this environment: `Terraform v1.15.7`

3. **Azure CLI** (v2.0 or later; v2.87+ recommended)
   - Download from: https://learn.microsoft.com/cli/azure/install-azure-cli
   - Verify installation: `az version`
   - Example output in this environment: `azure-cli 2.87.0`

4. **Azure Account**
   - Active Azure subscription with appropriate permissions
   - Authenticate: `az login`

If either command is not recognized, install the tool and reopen the VS Code terminal before proceeding.

## File Structure

- `main.tf` - Core Terraform configuration file containing:
  - Provider setup (Azure Resource Manager)
  - Data source for current Azure account information
  - Resource Group definition with detailed comments

- `README.md` - This file with usage instructions

## Usage

### Deployment Process

Follow these steps to deploy the resource group for a specific environment:

1. **Open the project folder**
   - Go to the Terraform project directory in VS Code.

2. **Check prerequisites**
   - Verify Terraform: `terraform --version`
   - Verify Azure CLI: `az version`
   - Sign in to Azure: `az login`

3. **Initialize Terraform**
   - Run: `terraform init`

4. **Format the configuration**
   - Run: `terraform fmt`

5. **Validate the configuration**
   - Run: `terraform validate`

6. **Preview the deployment**
   - For Dev: `terraform plan -var-file="environments/dev.tfvars"`
   - For QA: `terraform plan -var-file="environments/qa.tfvars"`

7. **Apply the deployment**
   - For Dev: `terraform apply -var-file="environments/dev.tfvars"`
   - For QA: `terraform apply -var-file="environments/qa.tfvars"`

8. **Verify the result**
   - Check Azure Portal or run: `az group list --output table`

9. **Inspect Terraform state**
   - Run: `terraform show`
   - Run: `terraform state list`

10. **Clean up if needed**
    - For Dev: `terraform destroy -var-file="environments/dev.tfvars"`
    - For QA: `terraform destroy -var-file="environments/qa.tfvars"`

### 1. Initialize Terraform

Initialize the working directory with Terraform configuration:

```bash
terraform init
```

This command:

- Downloads the required Azure provider
- Sets up the local Terraform state
- Prepares the working directory for planning and applying

### 2. Format the Configuration

Ensure the Terraform files follow standard formatting:

```bash
terraform fmt
```

### 3. Validate the Configuration

Check whether the Terraform configuration is syntactically valid and internally consistent:

```bash
terraform validate
```

### 4. Preview the Deployment

Generate an execution plan to preview what Terraform will create:

```bash
terraform plan
```

Output will show:

- Resources to be created
- Resource names (generated with subscription ID)
- Location and other properties

### 5. Apply the Configuration

Create the resources in Azure:

```bash
terraform apply
```

This command:

- Prompts for confirmation (type `yes` to proceed)
- Creates the resource group in Azure
- Saves state to local `terraform.tfstate` file

### 6. Deploy for a Specific Environment

You can deploy different environments by passing an environment variable file:

```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

For QA:

```bash
terraform plan -var-file="environments/qa.tfvars"
terraform apply -var-file="environments/qa.tfvars"
```

This will create resource groups named:

- `dev-rg-warehouse-azure`
- `qa-rg-warehouse-azure`

### 7. Inspect Terraform State

After initialization and apply, you can review the current Terraform state:

```bash
terraform show
terraform state list
```

These commands help you confirm which resources Terraform is tracking and inspect the current state contents.

### 5. Verify in Azure

Check that the resource group was created:

```bash
az group list --query "[].{Name:name, Location:location}" --output table
```

Or use the Azure Portal:

- Navigate to: https://portal.azure.com
- Search for "Resource Groups"
- Find the newly created resource group

## Configuration Details

### Resource Group Naming

The resource group is named using the pattern: `rg-{subscription-id}`

**Example:** `rg-12345678-1234-1234-1234-123456789012`

**Benefits:**

- Automatically unique across subscriptions
- Self-documenting (you can identify which subscription it belongs to)
- Prevents naming conflicts in multi-subscription environments

### Location

Default location: **East US**

To change the location, edit the `location` parameter in `main.tf`:

```terraform
location = "West US"  # Or another Azure region
```

Common Azure regions:

- `East US`
- `West US`
- `West Europe`
- `Southeast Asia`
- `Canada Central`
- See all: `az account list-locations --output table`

## Terraform State Management

After applying this configuration:

- **State File**: `terraform.tfstate` (contains current resource configuration)
- **Lock File**: `terraform.tfstate.lock.hcl` (prevents concurrent modifications)
- **Lock Info**: `.terraform.lock.hcl` (records provider versions used)

**Important**: Never commit `terraform.tfstate` to version control. For production environments, use remote state storage (Azure Storage Account, Terraform Cloud, etc.).

Useful state inspection commands:

```bash
terraform show
terraform state list
```

## Cleanup

To remove the created resources:

```bash
terraform destroy
```

This command:

- Prompts for confirmation (type `yes` to proceed)
- Deletes the Azure Resource Group and all its contents
- Updates the local Terraform state

## Troubleshooting

### Error: "No subscriptions found"

**Solution**: Run `az login` to authenticate with Azure

### Error: "Insufficient permissions"

**Solution**: Ensure your Azure account has "Owner" or "Contributor" role on the subscription

### Error: "Resource group already exists"

**Solution**: Use a different subscription or change the location in `main.tf`

### Error: "Provider initialization failed"

**Solution**:

1. Run `terraform init` again
2. Check your internet connection
3. Verify the required tools are available in the VS Code terminal:
   - `terraform --version`
   - `az version`
4. If the commands fail, reinstall the tools and reopen the terminal

## Next Steps

After creating the Resource Group, you can:

1. **Add more Azure resources** to the same Terraform configuration
   - Storage accounts, virtual machines, databases, etc.

2. **Use this as a base module** in larger infrastructure projects

3. **Configure remote state** for team collaboration
   - Use Azure Storage Account as backend

4. **Add variables and outputs** to make the configuration more flexible

## Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Resource Groups Overview](https://learn.microsoft.com/azure/azure-resource-manager/management/overview)
- [Terraform Getting Started](https://www.terraform.io/intro)
- [Azure CLI Documentation](https://learn.microsoft.com/cli/azure/)

## Support

For issues or questions:

- Check the troubleshooting section above
- Review the comments in `main.tf` for configuration details
- Consult the official documentation links
