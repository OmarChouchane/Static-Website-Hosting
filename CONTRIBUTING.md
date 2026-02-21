# Contributing to Static Website Hosting

Thank you for your interest in contributing! This project welcomes contributions from the community.

## Code of Conduct

Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

Before creating bug reports, check the issue list as you might find one already exists.

**When reporting a bug:**

- Use a clear, descriptive title
- Describe the exact steps to reproduce the problem
- Provide specific examples to demonstrate the steps
- Describe the behavior you observed and explain what you expected instead
- Include screenshots if applicable
- Include your environment details (OS, Terraform version, AWS region)

### Suggesting Enhancements

Enhancement suggestions are welcome! When suggesting enhancements:

- Use a clear, descriptive title (e.g., "Add support for custom domain names")
- Provide a detailed description of the enhancement
- List examples of similar functionality in other tools
- Explain the current limitations that would be addressed

### Pull Requests

1. **Fork the repository**

   ```bash
   git clone https://github.com/YOUR-USERNAME/Static-Website-Hosting.git
   cd Static-Website-Hosting
   ```

2. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Write clear, idiomatic Terraform code
   - Follow HashiCorp Terraform conventions
   - Add comments for complex logic
   - Format code: `terraform fmt`
   - Validate syntax: `terraform validate`

4. **Write commit messages**

   ```
   feat: Add support for custom domain names

   - Allow users to specify custom domain via variables
   - Integrate with Route 53 for DNS management
   - Update documentation with examples
   ```

5. **Push to your fork**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Provide a clear description of your changes
   - Link any related issues
   - Include screenshots where applicable
   - Ensure all checks pass

## Development Setup

```bash
# Install required tools
terraform version  # Should be 1.0+
aws --version      # Should be 2.0+

# Format and validate your code
terraform fmt -recursive .
terraform validate

# Test your changes
terraform plan
terraform apply
terraform destroy  # Clean up after testing
```

## Code Style Guide

### Terraform Files

```terraform
# Use 2-space indentation
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
  }
}

# Always include descriptions for variables and outputs
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-bucket"
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.example.arn
}
```

### Comments

- Use `#` for line comments
- Keep comments concise and meaningful
- Use block comments for complex logic

### Variable Naming

- Use snake_case for variable and resource names
- Use clear, descriptive names
- Avoid abbreviations unless standard

## Testing

Before submitting a PR:

1. **Lint check**: `terraform fmt -check -recursive .`
2. **Syntax validation**: `terraform validate`
3. **Plan review**: `terraform plan` and review output
4. **Full deployment**: `terraform apply` to verify end-to-end
5. **Cleanup**: `terraform destroy` to remove test resources

## Documentation

When adding features, update:

- README.md with usage examples
- Inline code comments
- Variable descriptions
- Output descriptions
- Architecture diagrams if applicable

## Questions?

Feel free to open an issue with questions or join the discussion on existing issues.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
