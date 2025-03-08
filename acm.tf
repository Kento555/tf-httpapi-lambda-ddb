resource "aws_acm_certificate" "custom_domain_cert" {
  domain_name       = "ws-api.sctp-sandbox.com"  # Replace with your custom domain
  validation_method = "DNS"
  subject_alternative_names = [
    "www.ws-api.sctp-sandbox.com"  # Optional: add any additional subdomains
  ]

  tags = {
    Name = "CustomDomainCertificate"
  }
}

