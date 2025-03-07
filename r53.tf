# # Route 53 Validation Records
# resource "aws_route53_record" "custom_domain_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.custom_domain_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   zone_id = "Z00541411T1NGPV97B5C0"  # Replace with your Route 53 zone ID
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60
#   records = [each.value.record]
# }

# # Wait for ACM certificate validation
# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.custom_domain_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.custom_domain_validation : record.fqdn]
# }

# # Route 53 Record for Custom Domain
# resource "aws_route53_record" "custom_domain_record" {
#   zone_id = "Z00541411T1NGPV97B5"  # Replace with your Route 53 zone ID
#   name    = "ws.sctp-sandbox.com"   # Replace with your custom domain
#   type    = "A"

#   alias {
#     name                   = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].target_domain_name
#     zone_id                = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].hosted_zone_id
#     evaluate_target_health = true
#   }
# }