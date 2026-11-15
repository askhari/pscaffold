variable "name" {
  description = "Resource name prefix, e.g. <project>-dev."
  type        = string
}

variable "region" {
  description = "DigitalOcean region slug."
  type        = string
}

variable "size" {
  description = "Droplet size slug."
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "ssh_public_key" {
  description = "Public key installed for the deploy user and root."
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to reach SSH. Narrow this to your IPs and CI where possible."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = list(string)
  default     = []
}
