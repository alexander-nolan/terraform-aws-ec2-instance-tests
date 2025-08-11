# tests/integration.tftest.hcl

run "setup_infrastructure" {
  module {
    source = "./tests/setup"
  }
}

run "test_ec2_instance_creation" {
  command = apply
  
  variables {
    instance_count = 2
    instance_type  = "t2.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    subnet_ids = [run.setup_infrastructure.subnet_id]
  }
  
  # Test that instances are created
  assert {
    condition     = length(aws_instance.app[*].id) == 2
    error_message = "Should create exactly 2 EC2 instances"
  }
  
  # Test that instance IDs are valid
  assert {
    condition     = alltrue([for id in aws_instance.app[*].id : can(regex("^i-", id))])
    error_message = "All EC2 instances should have valid instance IDs"
  }
}

run "test_instance_count_variable" {
  command = apply
  
  variables {
    instance_count = 3
    instance_type  = "t2.small"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    subnet_ids = [run.setup_infrastructure.subnet_id]
  }
  
  # Test that variable changes affect instance count
  assert {
    condition     = length(aws_instance.app[*].id) == 3
    error_message = "Should create exactly 3 EC2 instances when instance_count = 3"
  }
}

run "validate_ec2_instance_tags" {
  command = apply

  variables {
    instance_count = 2
    instance_type  = "t2.micro"
    subnet_ids     = ["subnet-12345", "subnet-67890"]
    security_group_ids = ["sg-12345"]
    tags = {
      environment = "dev"
      project     = "project-alpha"
    }
  }

  # Test that instances have project tag
  assert {
    condition     = alltrue([for instance in aws_instance.app : contains(keys(instance.tags), "project")])
    error_message = "All EC2 instances must have project tag"
  }
}

run "validate_ec2_instance_type" {
  command = apply

  variables {
    instance_count = 2
    instance_type  = "t2.micro"
    subnet_ids     = ["subnet-12345", "subnet-67890"]
    security_group_ids = ["sg-12345"]
    tags = {
      project     = "project-alpha"
      environment = "dev"
    }
  }

  # Test that all instances have the correct instance type
  assert {
    condition     = alltrue([for instance in aws_instance.app : instance.instance_type == "t2.micro"])
    error_message = "All EC2 instances must be t2.micro type"
  }
}