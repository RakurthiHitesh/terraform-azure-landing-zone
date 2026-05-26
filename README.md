# Terraform Azure Landing Zone 🏗️

A production-ready Azure Landing Zone built with **Terraform modules**, supporting multiple environments (dev, staging, prod) with remote state management, modular architecture, and a full GitHub Actions CI/CD pipeline.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Azure Subscription                     │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │         Resource Group (rg-landing-zone-dev)     │   │
│  │                                                  │   │
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │      Virtual Network (10.0.0.0/16)        │   │   │
│  │  │                                           │   │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ │   │   │
│  │  │  │  App     │ │  Data    │ │  Mgmt    │ │   │   │
│  │  │  │  Subnet  │ │  Subnet  │ │  Subnet  │ │   │   │
│  │  │  │10.0.1/24 │ │10.0.2/24 │ │10.0.3/24 │ │   │   │
│  │  │  └──────────┘ └──────────┘ └──────────┘ │   │   │
│  │  │              NSG (deny-all default)       │   │   │
│  │  └──────────────────────────────────────────┘   │   │
│  │                                                  │   │
│  │  ┌─────────────┐      ┌──────────────────┐      │   │
│  │  │  Key Vault  │      │  Storage Account │      │   │
│  │  │  (RBAC)     │      │  (private, TLS)  │      │   │
│  │  └─────────────┘      └──────────────────┘      │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │   Remote State — rg-terraform-state              │   │
│  │   Storage: tfstatehitesh / container: tfstate    │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
terraform-azure-landing-zone/
├── main.tf                          # Root module — calls all child modules
├── variables.tf                     # Input variable definitions
├── outputs.tf                       # Output values
├── modules/
│   ├── resource-group/main.tf       # Azure Resource Group
│   ├── networking/main.tf           # VNet, Subnets, NSG, associations
│   ├── key-vault/main.tf            # Key Vault with RBAC
│   └── storage/main.tf             # Storage Account + container
├── environments/
│   ├── dev/terraform.tfvars         # Dev environment variables
│   ├── staging/terraform.tfvars     # Staging environment variables
│   └── prod/terraform.tfvars        # Prod environment variables
├── .github/
│   └── workflows/terraform.yml      # GitHub Actions — plan & apply
├── scripts/
│   └── bootstrap.sh                 # One-time remote state setup
└── .gitignore
```

---

## 🚀 Getting Started

### Prerequisites
- Terraform >= 1.5.0
- Azure CLI installed and logged in
- Azure subscription with Contributor access

### Step 1 — Bootstrap remote state (run once)

```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

### Step 2 — Initialise Terraform

```bash
terraform init
```

### Step 3 — Plan for an environment

```bash
# Dev
terraform plan -var-file=environments/dev/terraform.tfvars

# Staging
terraform plan -var-file=environments/staging/terraform.tfvars

# Prod
terraform plan -var-file=environments/prod/terraform.tfvars
```

### Step 4 — Apply

```bash
terraform apply -var-file=environments/dev/terraform.tfvars
```

---

## ⚙️ GitHub Actions Setup

Add these secrets to your repo under **Settings → Secrets → Actions**:

| Secret | Description |
|---|---|
| `ARM_CLIENT_ID` | Azure Service Principal App ID |
| `ARM_CLIENT_SECRET` | Azure Service Principal Secret |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID |
| `ARM_TENANT_ID` | Azure Tenant ID |

### Create a Service Principal

```bash
az ad sp create-for-rbac \
  --name "sp-terraform-landing-zone" \
  --role Contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID>
```

---

## 🔒 Security Highlights

- **Key Vault** — RBAC-based access, network ACLs deny public access
- **Storage Account** — TLS 1.2 minimum, no public blob access, versioning enabled
- **NSG** — Deny-all default rule, SSH restricted to management subnet only
- **Remote State** — Stored securely in Azure Blob Storage with LRS replication
- **No secrets in code** — All sensitive values via GitHub Secrets or tfvars (gitignored)

---

## 🌍 Environments

| Environment | VNet CIDR | Replication |
|---|---|---|
| dev | 10.0.0.0/16 | LRS |
| staging | 10.1.0.0/16 | LRS |
| prod | 10.2.0.0/16 | GRS |

---

## 👤 Author

**R. Hitesh Naga Pavan**
Azure DevOps Engineer
[LinkedIn](https://linkedin.com/in/hitesh-naga-pavan) • [GitHub](https://github.com/RakurthiHitesh)
