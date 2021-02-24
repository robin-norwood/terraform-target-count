# Terraform Resource Targets

I've reproduced the following with Terraform versions 0.14.4 and 0.14.7.

1. Initialize the repo: `terraform init`
1. Apply config: `terraform apply -auto-approve`
   * Three each of "foo", "bar", and "baz" will be created.
1. Show plan for reducing # of resources: `terraform plan -var=resource_count=2`
   * One of each group will be destroyed, as expected.
1. Apply change, targeting the last "bar" resource: `terraform apply -var=resource_count=2 -target=null_resource.bar[2]`
   * Expected result: Only the targeted resource (`null_resource.bar[2]`) will be destroyed.
   * Actual result: The plan says two resources (`null_resource.bar[2] and null_resource.foo[2]`) will be destroyed, but accepting the plan only destroys one resource (`null_resource.bar[2]`).
1. Notes/other things I tried:
   * `terraform destroy -target=null_resource.bar[2]` works as expected - plan shows 1 to destroy, 1 is destroyed.
   * I ran into this via a more complex example: https://github.com/hashicorp/learn-terraform-resource-targeting
   * Saving the plan to a file and using `terraform show blah.plan` and `terraform apply blah.plan` gives the same results.

Output of final step (terraform v0.14.7):

```raw
$ terraform apply -var=resource_count=2 -target=null_resource.bar[2]
null_resource.foo[2]: Refreshing state... [id=3518838590304168957]
null_resource.foo[1]: Refreshing state... [id=5382324759337987587]
null_resource.foo[0]: Refreshing state... [id=4229333863487069839]
null_resource.bar[2]: Refreshing state... [id=1769106152658007569]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # null_resource.bar[2] will be destroyed
  - resource "null_resource" "bar" {
      - id = "1769106152658007569" -> null
    }

  # null_resource.foo[2] will be destroyed
  - resource "null_resource" "foo" {
      - id = "3518838590304168957" -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.


Warning: Resource targeting is in effect

You are creating a plan with the -target option, which means that the result
of this plan may not represent all of the changes requested by the current
configuration.
		
The -target option is not for routine use, and is provided only for
exceptional situations such as recovering from errors or mistakes, or when
Terraform specifically suggests to use it as part of an error message.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.bar[2]: Destroying... [id=1769106152658007569]
null_resource.bar[2]: Destruction complete after 0s

Warning: Applied changes may be incomplete

The plan was created with the -target option in effect, so some changes
requested in the configuration may have been ignored and the output values may
not be fully updated. Run the following command to verify that no other
changes are pending:
    terraform plan
	
Note that the -target option is not suitable for routine use, and is provided
only for exceptional situations such as recovering from errors or mistakes, or
when Terraform specifically suggests to use it as part of an error message.


Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
```
