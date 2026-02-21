# Architecture Documentation

## System Architecture

This document provides a detailed explanation of the Static Website Hosting infrastructure and how all components interact.

## Overview Diagram

```
                           ┌─────────────────────────────────────────┐
                           │         Internet / End Users            │
                           └────────────────┬────────────────────────┘
                                            │
                                            │ HTTP/HTTPS Requests
                                            │
                                  ┌─────────▼──────────┐
                                  │   AWS CloudFront   │
                                  │       (CDN)        │
                                  ├────────────────────┤
                                  │ • Global Edge      │
                                  │   Locations        │
                                  │ • TLS/HTTPS        │
                                  │ • Caching Layer    │
                                  │ • Origin Access    │
                                  │   Control          │
                                  └─────────┬──────────┘
                                            │
                          ┌─────────────────┼─────────────────┐
                          │                 │                 │
                  ┌───────▼────────┐ ┌──────▼──────┐ ┌───────▼────────┐
                  │ Cache hit      │ │ Cache miss  │ │ Origin Request │
                  │ → Serve from    │ │ → Fetch     │ │ (S3 Bucket)    │
                  │ Edge location   │ │ from Origin │ │                │
                  └────────┬────────┘ └─────┬───────┘ └────────┬───────┘
                           │                │                 │
                           └────────────────┼─────────────────┘
                                            │
                              ┌─────────────▼──────────────┐
                              │   Amazon S3 Bucket         │
                              │  (Private, Static Content) │
                              ├────────────────────────────┤
                              │ • index.html               │
                              │ • style.css                │
                              │ • script.js                │
                              │ • Other assets             │
                              └────────────────────────────┘
```

## Components

### 1. CloudFront Distribution

**Purpose**: Global content delivery network (CDN)

**Key Features**:

- Distributes content across 200+ edge locations worldwide
- Caches content closer to users for faster delivery
- Provides HTTPS/TLS encryption
- DDoS protection via AWS Shield Standard
- Automatic HTTP to HTTPS redirect

**Configuration Details**:

- Origin: S3 bucket regional domain name
- Origin Access Control (OAC): Provides secure, signed requests to S3
- Caching Policy: Default TTL of 86,400 seconds (24 hours)
- Viewer Protocol Policy: Redirect HTTP to HTTPS
- Price Class: 100 (standard edge locations, optimized for cost)

**Access Pattern**:

```
1. User requests index.html from https://d123xyz.cloudfront.net
2. CloudFront checks edge cache for the object
3. If not cached (cache miss):
   - CloudFront signs request with AWS Signature v4
   - Forwards request to S3 bucket via OAC
4. S3 validates signature and returns object
5. CloudFront caches response at edge location
6. Object returned to user with reduced latency
```

### 2. S3 Bucket

**Purpose**: Secure, durable storage for static website files

**Key Features**:

- Server-side encryption at rest (AES-256)
- Low cost for infrequent access
- Reliable and scalable storage
- Immutable object versioning

**Security Configuration**:

- Public access blocking: Enabled
- Bucket policy: Restricts access to CloudFront only
- No public ACLs allowed
- All objects: Private by default

**Structure**:

```
s3://omar-site-static-2026/
├── index.html        (text/html)
├── style.css         (text/css)
├── script.js         (text/javascript)
└── [other assets]
```

**Object Configuration**:

- Content-Type: Set automatically based on file extension
- Cache-Control: Managed by CloudFront distribution
- Server-side Encryption: Enabled by default

### 3. Origin Access Control (OAC)

**Purpose**: Secure, signed communication between CloudFront and S3

**How It Works**:

1. CloudFront uses OAC identity to sign API requests
2. OAuth 2.0 SAML assertion included in request headers
3. S3 bucket policy validates requests originate from specific CloudFront distribution
4. Only CloudFront can read objects; direct S3 URLs are blocked

**Benefits**:

- No URL guessing to access objects
- Requests cryptographically verified
- Prevents unauthorized access
- Replaces legacy Origin Access Identity (OAI)

### 4. S3 Bucket Policy

**Purpose**: Access control for bucket-level operations

**Current Policy**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFront",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bucket-name/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::123456789012:distribution/E3ABC123XYZ"
        }
      }
    }
  ]
}
```

**Permissions Granted**:

- `s3:GetObject`: Read objects from bucket
- Limited to CloudFront distribution via condition

**Principles**:

- Least privilege: Only CloudFront can read
- Condition-based: Restricted to specific distribution
- Service-to-service: CloudFront service principal used

## Data Flow

### Request Flow (User to Website)

```
1. User opens browser, navigates to:
   https://d123xyz.cloudfront.net/index.html

2. DNS resolution:
   CloudFront domain → Edge location IP

3. Edge location processing:
   - Entry point: Closest edge location
   - Cache lookup: Check for index.html

4. Origin request (if cache miss):
   - Sign request with OAC
   - Send to S3 bucket
   - Include AWS Signature v4 headers

5. S3 processing:
   - Validate signature
   - Check bucket policy
   - Return object with metadata

6. CloudFront processing:
   - Cache in edge location
   - Add cache headers
   - Return to user

7. Browser rendering:
   - Receive HTML
   - Request CSS, JS, images
   - Repeat steps 2-6 for each asset
```

### Update Flow (Deploying New Content)

```
1. Modify files in www/ directory
2. Run: terraform apply
3. Terraform uploads files to S3
4. CloudFront cache contains old version
5. Run CloudFront invalidation (manual or scheduled)
6. Edge locations serve updated content
```

## Performance Characteristics

### Latency Optimization

| Stage                    | Latency   | Optimization            |
| ------------------------ | --------- | ----------------------- |
| DNS Resolution           | 100-200ms | CloudFront's global DNS |
| Edge Location Connection | 10-50ms   | Proximity to user       |
| Cache Hit                | 5-20ms    | Warm cache at edge      |
| Cache Miss + S3 fetch    | 100-300ms | Origin fetches          |

### Caching Strategy

**Cache Behavior**:

- Default TTL: 86,400 seconds (24 hours)
- Max TTL: 31,536,000 seconds (1 year)
- Cache-Control headers respected from origin

**Cache Invalidation**:

```bash
# Manual invalidation (immediate)
aws cloudfront create-invalidation \
  --distribution-id E3ABC123XYZ \
  --paths "/*"

# Or via Terraform
terraform apply -refresh-only
```

## Security Model

### Threat Protection

| Threat                | Protection                    | Implementation       |
| --------------------- | ----------------------------- | -------------------- |
| Direct S3 access      | Bucket public access blocking | AWS policy           |
| URL brute force       | No object discovery           | Bucket policy        |
| Unauthorized sources  | OAC verification              | Signature validation |
| Network layer attacks | AWS Shield Standard           | CloudFront           |
| DDoS attacks          | AWS DDoS protection           | CloudFront           |

### Network Security

```
┌──────────────┐
│ Internet     │ ← Unauthorized users blocked here
└──────────────┘    (no direct S3 URLs)
        │
        │ Can only access via CloudFront
        │
┌───────▼─────────────────┐
│ CloudFront Distribution  │ ← Signature verification
└───────┬─────────────────┘
        │ OAC signed request
        │
┌───────▼─####────────────┐
│ S3 Bucket Policy         │ ← Condition validation
│ (Allow CloudFront only)  │
└──────────────────────────┘
```

## Scalability

### Horizontal Scaling

- **S3**: Automatically scales to billions of objects
- **CloudFront**: Distributes across 200+ edge locations
- **No capacity planning needed**: AWS handles scaling

### Performance Under Load

- **10M requests/month**: Single distribution handles easily
- **1TB/month transfer**: Well within free tier for many use cases
- **Concurrent users**: No per-connection limits

## High Availability

### Redundancy

- **Content**: Replicated across S3 availability zones
- **Distribution**: Distributed across global edge locations
- **Failover**: Automatic if origin becomes unavailable (returns cached content)

### Availability SLA

- **S3**: 99.99% availability
- **CloudFront**: 99.99% availability
- **Combined**: Higher with caching at edge

## Cost Optimization

### Cost Components

1. **S3 Storage**: ~$0.023 per GB/month
2. **S3 Requests**: GET requests @ $0.0004 per 10K requests
3. **CloudFront Data Transfer**: $0.085-0.170 per GB
4. **CloudFront Requests**: ~$0.0085 per 10K requests

### Cost Reduction Strategies

```hcl
# 1. Compression
# Enable gzip compression in CloudFront

# 2. Cache longer
# Increase default TTL for static assets

# 3. Regional distribution
# Use lower-cost regions for origin

# 4. Monitor transfer
# CloudWatch metrics for optimization
```

## Monitoring & Observability

### CloudWatch Metrics

Available metrics:

- `Requests`: Total requests to distribution
- `BytesDownloaded`: Data served to users
- `BytesUploaded`: Data sent to origin
- `4xxErrorRate`: Client errors
- `5xxErrorRate`: Server errors
- `CacheHitRate`: Percentage of cache hits

### Example CloudWatch Query

```
fields @timestamp, @message
| filter @logStream like /origin-request/
| stats count() as RequestCount by @logStream
```

## Disaster Recovery

### Backup Strategy

```bash
# Backup bucket contents to local device
aws s3 sync s3://omar-site-static-2026 ./backup

# Restore from backup
aws s3 sync ./backup s3://omar-site-static-2026
```

### Recovery Time Objective (RTO)

- **S3 replication failure**: < 1 minute (automatic)
- **CloudFront cache refresh**: < 5 seconds (invalidation)
- **Complete recovery**: ~30 minutes (redeploy via Terraform)

## Future Enhancements

### Recommended Additions

```terraform
# 1. Route 53 custom domain
resource "aws_route53_record" "website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# 2. WAF protection
resource "aws_wafv2_web_acl" "cdn_waf" {
  // Configuration for WAF rules
}

# 3. Lambda@Edge
resource "aws_lambda_function" "edge_function" {
  // Custom logic at edge
}
```

## References

- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Origin Access Control](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

Last updated: February 2026
