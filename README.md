# RabbitMQ Auto-Scaling Load-Balanced Architecture

## 🚀 Overview

A fully automated, production-ready RabbitMQ cluster deployment on AWS using Infrastructure as Code (Terraform). This architecture provides high availability, automatic scaling, self-healing capabilities, and secure secret management for enterprise-grade message broker infrastructure.

## ✨ Key Features

- **Multi-AZ High Availability**: Distributed across multiple Availability Zones for maximum uptime
- **Dual Load Balancing**:
  - Application Load Balancer (ALB) for RabbitMQ Management UI (HTTP/HTTPS)
  - Network Load Balancer (NLB) for AMQP traffic (TCP)
- **Auto Scaling Groups**: Self-healing RabbitMQ nodes that automatically recover from failures
- **Secure Secret Management**: AWS Secrets Manager integration for credentials and Erlang cookies
- **Automated Bootstrapping**: Complete node configuration using Docker and EC2 User Data scripts
- **Production-Ready**: Battle-tested configuration suitable for enterprise workloads

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                         AWS VPC                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │              Multi-AZ Configuration                 │ │
│  │                                                     │ │
│  │  ┌──────────┐              ┌──────────┐           │ │
│  │  │   ALB    │              │   NLB    │           │ │
│  │  │ (Port    │              │ (Port    │           │ │
│  │  │  15672)  │              │  5672)   │           │ │
│  │  └────┬─────┘              └────┬─────┘           │ │
│  │       │                         │                 │ │
│  │       └──────────┬──────────────┘                 │ │
│  │                  │                                │ │
│  │      ┌───────────▼──────────────┐                 │ │
│  │      │   Auto Scaling Group     │                 │ │
│  │      │  ┌──────┐  ┌──────┐     │                 │ │
│  │      │  │ EC2  │  │ EC2  │ ... │                 │ │
│  │      │  │Docker│  │Docker│     │                 │ │
│  │      │  │RabbitMQ RabbitMQ      │                 │ │
│  │      │  └──────┘  └──────┘     │                 │ │
│  │      └──────────────────────────┘                 │ │
│  │                  │                                │ │
│  │                  ▼                                │ │
│  │      ┌──────────────────────┐                     │ │
│  │      │ AWS Secrets Manager  │                     │ │
│  │      │  - Admin Credentials │                     │ │
│  │      │  - Erlang Cookie     │                     │ │
│  │      └──────────────────────┘                     │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- **Terraform**: >= 1.0
- **AWS CLI**: Configured with appropriate credentials
- **AWS Account**: With permissions to create VPC, EC2, Load Balancers, Secrets Manager, and Auto Scaling resources
- **SSH Key Pair**: For EC2 instance access (optional, for debugging)

## 🔧 Components

### Infrastructure Components

1. **VPC & Networking**
   - Custom VPC with public and private subnets
   - Multi-AZ deployment for high availability
   - Internet Gateway and NAT Gateways
   - Security groups with minimal required access

2. **Load Balancers**
   - **ALB**: Routes traffic to RabbitMQ Management UI
   - **NLB**: Handles AMQP protocol traffic with low latency

3. **Compute**
   - EC2 instances running in Auto Scaling Groups
   - Docker containerized RabbitMQ
   - Automated cluster discovery and joining

4. **Security**
   - AWS Secrets Manager for sensitive data
   - IAM roles and policies following least privilege
   - Security groups restricting access

## 🚦 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Danielashkenazy/RabbitMQ-Auto-Scaling-Load-Balanced-Architecture.git
cd RabbitMQ-Auto-Scaling-Load-Balanced-Architecture
```

### 2. Configure Variables

Create a `terraform.tfvars` file with your configuration:

```hcl
aws_region          = "us-east-1"
environment         = "production"
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]

# RabbitMQ Configuration
rabbitmq_version    = "3.12-management"
instance_type       = "t3.medium"
min_size            = 3
max_size            = 10
desired_capacity    = 3

# Admin credentials (will be stored in Secrets Manager)
rabbitmq_admin_user = "admin"
rabbitmq_admin_pass = "YourSecurePassword123!"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan Deployment

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

### 6. Access RabbitMQ

After deployment completes, Terraform will output:
- **Management UI URL**: Access via ALB endpoint
- **AMQP Endpoint**: Connect your applications via NLB endpoint

```bash
# Example outputs
terraform output management_url
terraform output amqp_endpoint
```

## 🔐 Security Considerations

- All sensitive credentials are stored in AWS Secrets Manager
- Security groups limit access to only required ports
- Erlang cookie is automatically generated and secured
- IAM roles follow principle of least privilege
- Consider enabling VPC Flow Logs for audit trails
- Use SSL/TLS for production deployments

## 📊 Monitoring and Maintenance

### Health Checks
- ALB performs health checks on port 15672 (Management UI)
- NLB performs health checks on port 5672 (AMQP)
- Auto Scaling Groups automatically replace unhealthy instances

### Logging
- CloudWatch Logs integration available
- RabbitMQ logs accessible via EC2 instance
- Consider enabling centralized logging

### Scaling Policies
- Manual scaling: Adjust ASG desired capacity
- Automatic scaling: Configure CloudWatch alarms based on:
  - Queue depth
  - CPU utilization
  - Memory usage
  - Connection count

## 🛠️ Configuration Options

### Environment Variables in User Data

The EC2 User Data script supports:
- `RABBITMQ_VERSION`: Docker image tag
- `RABBITMQ_ERLANG_COOKIE`: Cluster cookie (from Secrets Manager)
- `RABBITMQ_DEFAULT_USER`: Admin username
- `RABBITMQ_DEFAULT_PASS`: Admin password

### RabbitMQ Configuration

Customize `rabbitmq.conf` for:
- Memory and disk limits
- Queue policies
- Federation settings
- Shovel configurations

## 📈 Performance Tuning

### Instance Sizing
- **Development**: t3.small (2 vCPU, 2 GB RAM)
- **Staging**: t3.medium (2 vCPU, 4 GB RAM)
- **Production**: m5.large or larger (2+ vCPU, 8+ GB RAM)

### RabbitMQ Optimization
```erlang
vm_memory_high_watermark.relative = 0.4
disk_free_limit.relative = 1.5
channel_max = 2048
```

## 🔄 Disaster Recovery

### Backup Strategy
1. Regular snapshots of EBS volumes
2. Export queue definitions periodically
3. Document custom policies and configurations

### Recovery Procedure
1. Terraform state is preserved
2. Secrets are stored in Secrets Manager
3. Run `terraform apply` to recreate infrastructure
4. Restore queue definitions via Management API

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all RabbitMQ data and configurations.

## 📝 Common Tasks

### Scale the Cluster
```bash
# Update desired_capacity in terraform.tfvars
terraform apply
```

### Update RabbitMQ Version
```bash
# Change rabbitmq_version variable
terraform apply
```

### Rotate Credentials
```bash
# Update secrets in AWS Secrets Manager
aws secretsmanager update-secret --secret-id rabbitmq-admin --secret-string '{"username":"admin","password":"NewPassword"}'
```

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- RabbitMQ team for excellent documentation
- AWS for robust cloud infrastructure
- Terraform for powerful IaC capabilities

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check RabbitMQ documentation: https://www.rabbitmq.com/docs
- AWS documentation: https://docs.aws.amazon.com

## 🎯 Roadmap

- [ ] Add CloudWatch dashboards
- [ ] Implement automated backups
- [ ] Add Prometheus monitoring integration
- [ ] SSL/TLS configuration examples
- [ ] Multi-region replication setup
- [ ] Terraform modules structure

---

**Built with ❤️ for scalable, reliable message broker infrastructure**
