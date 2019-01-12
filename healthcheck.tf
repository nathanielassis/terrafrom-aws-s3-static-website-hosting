resource "aws_route53_health_check" "r53_health_check" {
  count             = "${var.enable_r53_healthcheck == "on"  ? 1 : 0}"
  fqdn              = "${var.app_name}.${var.hosted_zone_domain_name}"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/index.html"
  failure_threshold = "3"
  request_interval  = "10"

  # cloudwatch_alarm_name   = "${aws_cloudwatch_metric_alarm.static_health.alarm_name}"
  # cloudwatch_alarm_region = "${var.aws_region}"

  tags = "${merge("${var.tags}",map("Git", "s3-static-website-hosting"))}"
}

resource "aws_cloudwatch_metric_alarm" "static_health_alarm" {
  count               = "${var.enable_r53_healthcheck == "on"  ? 1 : 0}"
  alarm_name          = "${var.app_name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "Monititor if static site is up or down."
  alarm_actions       = "${var.alarm_action}"
  ok_actions          = "${var.alarm_action}"

  dimensions {
    HealthCheckId = "${aws_route53_health_check.r53_health_check.id}"
  }
}
