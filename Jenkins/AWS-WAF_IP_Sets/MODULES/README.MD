## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_ip_set.block-list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_set"></a> [ip\_set](#input\_ip\_set) | List of IP adresses that should be in IP set | `list(string)` | <pre>[]</pre> | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | Scope | `string` | `"REGIONAL"` | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of IP set | `string` | `"block-list"` | yes |
| <a name="input_description"></a> [description](#input\_description) | Description | `string` | `"IP set, managed by Terraform"` | yes |
| <a name="input_ip_addr_versions"></a> [ip\_addr\_version](#input\_ip\_addr\_version) | IP address version | `string` | `IPV4` | yes |

## Outputs

No outputs.
