# Terraform

### TF commands:
- `terraform init`: looks for providers in our tf config. dls plugins for the api
- `terraform plan`: dry run of your code
- `terraform apply`: deploy your code(`—auto-approve` to skip the prompt)
- `terraform destroy`: destroy the resources in your blueprint
`terrform state list`: list resources we have state for
`terraform state show [resource-from state list cmd]`: see detailed info about resource
`terraform output`: Print out the outputs
`terraform refresh`: Allows you to print out newly added outputs without deploying (tf apply)
`terraform destroy -target aws_instance.web-server-instance`: target a resource (-target). This will delete only the aws_instance.


### Variables
- `terraform apply -var subnet_prefix=10.0.1.0/24`: pass in a variable (var name needs to be defined in code)

- Terraform looks for `terraform.tfvars` for variables

- Use file other than `terraform.tfvars` file: Pass in  `-var-file` when running `terraform [command]`. Ex: `terraform apply -var-file example.tfvars`

- Can use default value in tf code. If no variable provided, will use that default value.
    - ex: 
    ```tf
        variable "subnet_prefix" {
            description = "cidr block for subnet"
            default     = "10.0.66.0/24"
            type        = string
        }
    ```
    *also notice you can give vars a type (see string)*
