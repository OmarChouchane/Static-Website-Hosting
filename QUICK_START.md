# Quick Start Guide

Get your static website live on AWS in under 5 minutes!

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) 1.0+ installed
- [AWS CLI](https://aws.amazon.com/cli/) configured with your credentials
- AWS account with S3 and CloudFront access

## 1️⃣ Clone & Setup

```bash
git clone https://github.com/OmarChouchane/Static-Website-Hosting.git
cd Static-Website-Hosting
```

## 2️⃣ Check AWS Configuration

```bash
aws sts get-caller-identity
```

You should see your AWS account info. If not, configure credentials:

```bash
aws configure
```

## 3️⃣ Initialize Terraform

```bash
terraform init
```

This downloads AWS provider plugins (~10 seconds).

## 4️⃣ Review Your Deployment

```bash
terraform plan
```

You'll see resources to be created:

- 1 S3 bucket
- 1 CloudFront distribution
- File uploads
- Bucket policy

## 5️⃣ Deploy! 🚀

```bash
terraform apply
```

Type `yes` when prompted. This takes 2-3 minutes.

## 6️⃣ Get Your Website URL

```bash
terraform output website_url
```

Copy the URL and open it in your browser. Your website is live!

## 📝 Customize Your Website

Edit files in the `www/` directory:

```bash
# Edit your homepage
nano www/index.html

# Edit styles
nano www/style.css

# Edit interactivity
nano www/script.js
```

Deploy changes:

```bash
terraform apply
```

## 🗑️ Clean Up

To avoid charges, destroy everything:

```bash
terraform destroy
```

Type `yes` to confirm.

## 🐛 Troubleshooting

**"Bucket already exists"**

- S3 bucket names are globally unique
- Edit `variables.tf` and change `bucket_name` to something unique
- Re-run `terraform apply`

**"Access Denied"**

- Ensure your AWS user has S3 and CloudFront permissions
- Check: `aws s3 ls`

**Website shows "Access Denied"**

- Give CloudFront a moment to initialize (~5 minutes)
- Refresh your browser

**Can't find my website URL**

```bash
terraform output website_url
# or
terraform output -json | grep website_url
```

## 📚 Learn More

- **Full Documentation**: See [README.md](README.md)
- **Architecture Details**: See [ARCHITECTURE.md](ARCHITECTURE.md)
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)

## 🎯 Next Steps

### Add Custom Domain

```bash
# Route 53 + ACM for custom domains
# See ARCHITECTURE.md for examples
```

### Add Security Headers

```bash
# Lambda@Edge for custom headers
# WAF rules for DDoS protection
```

### Monitor Performance

```bash
# CloudWatch dashboards
# S3/CloudFront metrics
```

### Enable HTTPS

```bash
# Already enabled by default!
# CloudFront provides automatic HTTPS
```

---

**Need help?** Check [README.md](README.md) or open an issue on GitHub.

Happy deploying! 🎉
