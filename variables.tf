variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  
  validation {
    condition     = var.instance_type == "t2.micro"
    error_message = "All EC2 instances must be t2.micro type"
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the EC2 instances"
  type        = map(string)
  
  validation {
    condition     = contains(keys(var.tags), "project")
    error_message = "All EC2 instances must have project tag"
  }
}
