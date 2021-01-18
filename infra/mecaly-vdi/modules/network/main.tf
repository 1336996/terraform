#route 53
resource "aws_route53_zone" "hosted_zone" {
  name = "rohit123.com"
   tags = {
    Platform        = "vaarst"
    Environment = "Dev"
  }
}

resource "aws_route53_record" "rcrd" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "dev.rohit123.com"
  type    = "A"
  ttl     = "3000"
  records = ["1.1.1.1"]
}
