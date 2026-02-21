# Static Website Hosting on AWS with Terraform

A production-ready Infrastructure as Code solution for hosting static websites on AWS using Terraform. This project demonstrates cloud architecture best practices with automated provisioning, security hardening, and scalable global content delivery.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Installation & Deployment](#installation--deployment)
- [Configuration](#configuration)
- [Outputs](#outputs)
- [Security Considerations](#security-considerations)
- [Cost Estimation](#cost-estimation)
- [Cleanup](#cleanup)
- [Contributing](#contributing)
- [License](#license)

## Overview

This Terraform project automates the deployment of a secure, scalable static website hosting infrastructure on AWS. It combines S3 for reliable file storage, CloudFront for global content delivery, and Origin Access Control for secure private bucket access.

**Key Benefits:**

- ✅ **Infrastructure as Code**: Reproducible, version-controlled deployments
- ✅ **Automated Provisioning**: Single command deployment
- ✅ **Security First**: Private S3 bucket with restricted access
- ✅ **Global Performance**: CloudFront CDN for sub-second content delivery
- ✅ **Cost Efficient**: Pay-per-use pricing model

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet Users                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   CloudFront    │
                    │      (CDN)      │
                    │   OAC Enabled   │
                    └────────┬────────┘
                             │
        ┌────────────────────┤
        │                    │
   ┌────▼────────┐   ┌──────▼──────────┐
   │ Edge Caches │   │ Origin S3 Bucket│
   │ (worldwide) │   │   (Private)     │
   └─────────────┘   └─────────────────┘
                            │
                    ┌───────▼────────┐
                    │  Website Files │
                    │ (HTML/CSS/JS)  │
                    └────────────────┘
```

### Components

| Component                   | Purpose                | Details                                          |
| --------------------------- | ---------------------- | ------------------------------------------------ |
| **S3 Bucket**               | Static website storage | Private bucket with restricted access            |
| **CloudFront Distribution** | Global CDN             | Caches content at edge locations worldwide       |
| **Origin Access Control**   | Secure access          | Allows CloudFront to sign requests to S3         |
| **S3 Bucket Policy**        | Access control         | Restricts access to CloudFront service principal |
| **Public Access Block**     | Security hardening     | Prevents accidental public exposure              |

## Features

### Infrastructure

- 🔒 **Private S3 Bucket**: No direct public access
- 🌍 **Global CDN**: CloudFront distribution for worldwide content delivery
- 🔐 **Origin Access Control**: Signed requests from CloudFront to S3
- 📝 **Content Type Detection**: Automatic MIME type assignment
- 🚀 **Automatic File Upload**: `for_each` loop uploads all website files
- 📊 **Remote State Management**: S3 backend for team collaboration

### Security

- ✅ Bucket public access blocking enabled
- ✅ IAM-based access control
- ✅ HTTPS/TLS encryption in transit
- ✅ S3 server-side encryption at rest
- ✅ Least-privilege IAM policies

### Developer Experience

- 📦 Modular Terraform configuration
- 🎯 Clear variable definitions
- 📋 Descriptive outputs
- 🔄 Easy to customize and extend
- 📚 Well-documented code

## Prerequisites

### Required Tools

- **Terraform** 1.0+ ([Install](https://www.terraform.io/downloads.html))
- **AWS CLI** 2.0+ ([Install](https://aws.amazon.com/cli/))
- **Git** 2.0+ ([Install](https://git-scm.com/))

### AWS Requirements

- Active AWS account with production access
- IAM user with the following permissions:
  - `AmazonS3FullAccess`
  - `CloudFrontFullAccess`
  - `IAMUserChangePassword`

### Authentication

Configure AWS credentials using one of these methods:

```bash
# Option 1: AWS CLI configuration
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-west-1"

# Option 3: IAM roles (for CI/CD)
# Configure via AWS instances or containers
```

## Project Structure

```
static-website-hosting/
├── main.tf                  # Primary infrastructure configuration
├── variables.tf             # Input variables and defaults
├── outputs.tf               # Output values (URLs, IDs, etc.)
├── backend.tf               # Remote S3 state configuration
├── provider.tf              # AWS provider configuration
├── local.tf                 # Local values and computed variables
├── .gitignore               # Git ignore rules
├── README.md                # This file
├── LICENSE                  # MIT License
└── www/                     # Website source files
    ├── index.html           # Main HTML page
    ├── style.css            # Stylesheet
    └── script.js            # JavaScript functionality
```

### File Descriptions

- **main.tf**: Creates S3 bucket, CloudFront distribution, bucket policy, and uploads files
- **variables.tf**: Defines input variables (region, bucket prefix, tags)
- **outputs.tf**: Exports CloudFront URL and bucket details
- **backend.tf**: Configures S3 backend for state management
- **provider.tf**: AWS provider version and region configuration
- **local.tf**: Computed values and local resource naming

## Installation & Deployment

### Step 1: Clone the Repository

```bash
git clone https://github.com/OmarChouchane/Static-Website-Hosting.git
cd Static-Website-Hosting
```

### Step 2: Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider and initializes the working directory.

### Step 3: Review Deployment Plan

```bash
terraform plan
```

Review the resources that will be created. You should see:

- 1 S3 bucket
- 1 CloudFront distribution
- 1 Origin Access Control
- 1 Bucket policy
- 3+ S3 objects (website files)

### Step 4: Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted. Deployment typically takes 2-3 minutes.

### Step 5: Access Your Website

```bash
terraform output website_url
```

Visit the CloudFront URL in your browser to see your live website.

## Configuration

### Customize Variables

Edit `variables.tf` to modify deployment parameters:

```terraform
variable "aws_region" {
  default = "eu-west-1"  # Change your region
}

variable "bucket_name" {
  default = "omar-site-static-2026"  # Change bucket name
}
```

### Use Terraform Variables File

Create `terraform.tfvars` for environment-specific values:

```terraform
aws_region       = "us-east-1"
bucket_name      = "my-company-site"
```

Then apply with:

```bash
terraform apply -var-file="terraform.tfvars"
```

### Update Website Content

Modify files in the `www/` directory:

```bash
# Edit your page
nano www/index.html

# Re-apply to upload changes
terraform apply
```

## Outputs

After successful deployment, Terraform outputs:

```
website_url              = "https://d123xyz.cloudfront.net"
cloudfront_distribution_id = "E3ABC123XYZ"
s3_bucket_name          = "omar-site-static-2026"
s3_bucket_arn           = "arn:aws:s3:::omar-site-static-2026"
```

Use `terraform output <name>` to retrieve specific values:

```bash
terraform output website_url
```

## Security Considerations

### Best Practices Implemented

1. **Private S3 Bucket**: Public access is blocked by default
2. **Origin Access Control**: CloudFront signs all requests with AWS Signature v4
3. **Bucket Policy**: Restricts access to CloudFront service principal only
4. **Encryption**: S3 server-side encryption enabled
5. **HTTPS**: CloudFront enforces HTTPS/TLS

### Additional Recommendations

```terraform
# For production, consider adding:
- AWS WAF rules on CloudFront
- Lambda@Edge for custom logic
- Route 53 with custom domain
- AWS Certificate Manager for SSL
- CloudWatch monitoring and alarms
```

### IAM Policy Example

Minimal IAM policy for deployment:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:PutBucketPolicy",
        "s3:PutObject",
        "s3:GetObject",
        "cloudfront:CreateDistribution",
        "cloudfront:CreateOriginAccessControl"
      ],
      "Resource": "*"
    }
  ]
}
```

## Cost Estimation

### Monthly Costs (Example)

| Service                 | Usage              | Cost           |
| ----------------------- | ------------------ | -------------- |
| **S3 Storage**          | 100 GB             | ~$2.30         |
| **CloudFront**          | 1 TB data transfer | ~$85-170\*     |
| **S3 Requests**         | 100,000/month      | ~$0.40         |
| **CloudFront Requests** | 10M/month          | ~$0.85         |
| **Total**               |                    | ~$89-258/month |

\*Varies by region. See [AWS Pricing Calculator](https://calculator.aws/)

### Cost Optimization

- Use CloudFront caching effectively
- Compress assets (Gzip)
- Use appropriate S3 storage classes
- Monitor and set CloudWatch alarms

## Cleanup

### Destroy All Resources

```bash
terraform destroy
```

Type `yes` to confirm. This removes:

- S3 bucket and files
- CloudFront distribution
- IAM policies
- All associated resources

### Warning

Destroying will delete your website from AWS. Ensure you have backups before proceeding.

## Troubleshooting

### Common Issues

**"BucketAlreadyExists" Error**

- S3 bucket names are globally unique
- Solution: Change `bucket_name` in `variables.tf`

**"MalformedPolicy" Error**

- Bucket policy JSON is invalid
- Solution: Check IAM policy syntax or use AWS Policy Simulator

**CloudFront shows "Access Denied"**

- Origin Access Control not properly configured
- Solution: Verify bucket policy includes CloudFront service principal

**Files not uploading**

- IAM permissions insufficient
- Solution: Verify IAM user has S3 full access

### Debug Mode

Enable verbose Terraform logging:

```bash
export TF_LOG=DEBUG
terraform apply
```

## Contributing

Contributions welcome! Follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/enhancement`)
3. Commit changes (`git commit -m 'Add enhancement'`)
4. Push branch (`git push origin feature/enhancement`)
5. Open Pull Request

### Code Standards

- Format Terraform files: `terraform fmt`
- Validate syntax: `terraform validate`
- Follow Terraform conventions from Hashicorp
- Add comments for complex logic

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## Author

**Omar Chouchane**

## Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront CDN Guide](https://docs.aws.amazon.com/cloudfront/)
- [Origin Access Control](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)

## Support

For issues or questions:

1. Check [GitHub Issues](https://github.com/OmarChouchane/Static-Website-Hosting/issues)
2. Review AWS documentation
3. Check Terraform Registry examples

---

**Last Updated**: February 2026  
**Terraform Version**: 1.0+  
**AWS Provider Version**: 5.0+
