output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "alb_dns_name" {
  value = "${aws_alb.alb_web.dns_name}"
}

output "alb_target_group_arn" {
    value = "${aws_alb_target_group.alb_target_group.arn}"
}
