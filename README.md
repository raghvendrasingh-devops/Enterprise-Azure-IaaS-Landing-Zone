<div align="center">

  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=1,15,35&height=220&section=header&text=ENTERPRISE%20AZURE%20IAAS%20LANDING%20ZONE&fontSize=38&fontAlignY=38&animation=fadeIn&fontColor=ffffff&desc=Production-Ready%203-Tier%20Compute%20%7C%20VMSS%20%7C%20Hub-and-Spoke%20%7C%20Azure%20Firewall%20%7C%20ASR&descSize=16&descAlignY=62&descAlign=50" width="100%" alt="IaaS Landing Zone Banner" />

  <p align="center">
    <img src="https://img.shields.io/badge/Architecture-Enterprise_IaaS_CAF-blue?style=for-the-badge&logo=microsoftazure" />
    <img src="https://img.shields.io/badge/IaC-Terraform_1.7+-7B42BC?style=for-the-badge&logo=terraform" />
    <img src="https://img.shields.io/badge/Compute-VMSS_Multi--AZ-0078D4?style=for-the-badge&logo=windows" />
    <img src="https://img.shields.io/badge/Security-Azure_Firewall_Premium-red?style=for-the-badge&logo=shield" />
    <img src="https://img.shields.io/badge/DR-RTO_%3C_15m_%7C_RPO_%3C_5m-success?style=for-the-badge&logo=statuspage" />
  </p>

</div>

---

## 🏛️ Architecture Overview

This repository delivers a **production-hardened Infrastructure-as-a-Service (IaaS) Enterprise Landing Zone** designed according to Microsoft Cloud Adoption Framework (CAF) best practices.

It isolates enterprise workloads into a secure **3-Tier compute model** connected to a central **Hub Virtual Network** with centralized egress inspection, private management, and automated disaster recovery.

```mermaid
graph TD
    subgraph HubNetwork["🌐 Central Hub VNet (172.16.0.0/20)"]
        FW["Azure Firewall Premium\n(TLS & IDPS Inspection)"]
        GW["ExpressRoute / VPN Gateway"]
        BASTION["Azure Bastion Host"]
        DNS["Private DNS Resolver"]
    end

    subgraph IaaSSpoke["🏢 IaaS 3-Tier Spoke VNet (172.16.16.0/20)"]
        subgraph Tier1["Tier 1: Web Ingress"]
            AGW["Application Gateway WAF v2\n(Public Facing Ingress)"]
        end

        subgraph Tier2["Tier 2: Application Core"]
            ILB["Internal Load Balancer"]
            VMSS["Linux / Windows VMSS\n(Multi-AZ Autoscaling)"]
        end

        subgraph Tier3["Tier 3: Database & Storage"]
            DB["Enterprise Database VMs\n(Accelerated Networking + Premium SSD)"]
            ASR["Azure Site Recovery & Backup Vault"]
        end
    end

    GW --> FW
    AGW ==> |"UDR Inspection"| FW
    FW ==> |"Forced Routing"| ILB
    ILB --> VMSS
    VMSS --> DB
    DB -.-> ASR
```

---

## ⚡ Key Features

| Pillar | Capability & Production Hardening |
| :--- | :--- |
| **🌐 Central Hub Network** | Hub VNet with dedicated `AzureFirewallSubnet`, `GatewaySubnet`, `AzureBastionSubnet`, and Route Tables. |
| **🛡️ Zero-Trust Security** | Azure Firewall Premium with IDPS and TLS inspection enforcing `0.0.0.0/0` outbound inspection via UDRs. |
| **💻 Scalable IaaS Compute** | Virtual Machine Scale Sets (VMSS) running across Availability Zones (1, 2, 3) with metric-based autoscale. |
| **🚦 Traffic Balancing** | Application Gateway WAF v2 for public traffic; Internal Standard Load Balancers for east-west traffic. |
| **💾 Storage & Backups** | Premium SSD Managed Disks with Customer-Managed Keys (CMK) and Recovery Services Vault automated backups. |
| **🔄 DevSecOps Automation** | Complete CI/CD pipeline with TFLint, Checkov SAST, TruffleHog, and Infracost cost estimation. |

---

## 📁 Repository Structure

```text
Enterprise-Azure-IaaS-Landing-Zone/
├── .github/workflows/
│   └── devsecops-ci-cd.yml       # Multi-stage CI/CD: Lint, SAST, Plan, Deploy
├── terraform/
│   ├── modules/
│   │   ├── hub_network/          # Hub VNet, Azure Firewall, Bastion, UDR
│   │   ├── iaas_compute_vmss/    # App Gateway WAF, Internal LB, VMSS
│   │   └── iaas_storage_backup/  # Recovery Services Vault, Backup Policies
│   └── environments/
│       └── prod/
│           ├── main.tf           # Root Orchestrator
│           ├── variables.tf
│           ├── terraform.tfvars
│           └── versions.tf
└── README.md
```

---

## 🚀 Quick Start & Deployment

### Prerequisites
* Terraform `>= 1.5.0`
* Azure CLI `>= 2.50.0`
* Active Azure Subscription with Owner / Contributor permissions

### Local Execution

```bash
cd terraform/environments/prod

# Initialize Terraform modules and providers
terraform init

# Validate configuration syntax
terraform validate

# Review execution plan and resource changes
terraform plan

# Apply infrastructure deployment
terraform apply -auto-approve
```

---

## 👤 Author
**Raghvendra Singh**  
Lead DevSecOps Architect & Enterprise Cloud Strategist  
GitHub: [@raghvendrasingh-devops](https://github.com/raghvendrasingh-devops)  
LinkedIn: [raghvendra-singh-devops](https://linkedin.com/in/raghvendra-singh-devops)
