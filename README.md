# lamba-run-on-_SUCCESS

### Configuration

The Python program exists inside of `function/`.  `main.tf` is the Terraform configuration for the Lambda.  To create a unique name for your bucket please edit `terraform.tfvars`.

## Terraform Functionality 
This terraform creates the required IAM policies, Lambdas, and S3 buckets for a lambda to be trigger on upload of a "_SUCCESS" file to a desired bucket.

## Lambda Functionality

The lambda will then check all listings in the bucket for "_SUCCESS".  After one has been found it will `print("FOUND")`.  At this point one may wish to edit the code or terraform to have another series of events be pursued.

## Deploying the Lambda

1. Run `terraform init` to initialize the terraform repository.

2. Then run `terraform plan` to create the execution plan.

3. Finally, `terraform apply` to apply the changes (run the execution plan).

### LICENSE

MIT