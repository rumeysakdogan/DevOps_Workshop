# Lab:Terraform Enterprise - Workspaces

Those who adopt Terraform typically want to leverage the principles of DRY (Don’t Repeat Yourself) development practices. One way to adopt this principle with respect to IaC is to utilize the same code base for different environments (development, quality, production, etc.)
Workspaces is a Terraform feature that allows us to organize infrastructure by environments and variables in a single directory.
Terraform is based on a stateful architecture and therefore stores state about your managed infrastruc- ture and configuration. This state is used by Terraform to map real world resources to your configura- tion, keep track of metadata, and to improve performance for large infrastructures.
The persistent data stored in the state belongs to a Terraform workspace. Initially the backend has only one workspace, called “default”, and thus there is only one Terraform state associated with that configuration.

- Task1: Using Terraform Workspaces(OpenSource)
- Task2: Create a new Terraform Workspace for Production State
- Task3: Deploy Infrastructure with in the Terraform production workspace
- Task4: Changing between Workspaces
- Task5: Utilizing the `${terraform.workspace}` interpolation sequence within your configuration