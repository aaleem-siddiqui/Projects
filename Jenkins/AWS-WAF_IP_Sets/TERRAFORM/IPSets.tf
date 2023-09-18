/* -------- IP SETS -------- */
/* -------- MAKE ANY MODIFICATIONS TO THE 'block-list' CODE BLOCK BELOW -------- */
/* -------- FOR MORE INFO: [documentation link here] -------- */



variable "ip_sets" {
  type        = map(any)
  description = "Map of rule name and CIDR blocks with description to be blocked."
  default = {
    block-list = [
      "11.22.33.44/32",
      "55.66.77.88/24"
    ],
    block-list-ipv6 = [
      "1a23:45f6:7c8c:910e:0000:0000:0000:0001/128"
    ]
  }
}
