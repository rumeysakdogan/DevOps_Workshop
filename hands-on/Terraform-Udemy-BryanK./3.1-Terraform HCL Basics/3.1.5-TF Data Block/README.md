## Lab: Introduction to the Terraform Data Block

Data sources are used in Terraform to load or query data from APIs or other Terraform workspaces. You can use this data to make your project’s configuration more flexible, and to connect workspaces that manage different parts of your infrastructure. You can also use data sources to connect and share data between workspaces in Terraform Cloud and Terraform Enterprise.
To use a data source, you declare it using a data block in your Terraform configuration. Terraform will perform the query and store the returned data. You can then use that data throughout your Terraform configuration file where it makes sense.

Data Blocks within Terraform HCL are comprised of the following components:

- `Data Block` - “resource” is a top-level keyword like “for” and “while” in other programming languages.
- `DataType` - The next value is the type of the resource .Resources types are always prefixed with their provider (aws in this case). There can be multiple resources of the same type in a Terraform configuration.
- `Data Local Name` - The next value is the name of the resource. The resource type and name together form the resource identifier, or ID. In this lab, one of the resource IDs is aws_instance.web. The resource ID must be unique for a given configuration, even if multiple files are used.
- `Data Arguments` - Most of the arguments with in the body of a resource block are specific to the selected resource type. The resource type’s documentation lists which arguments are available and how their values should be formatted.

Example: A data block requests that Terraform read from a given data source (“aws_ami”) and export the result under the given local name (“example”). The name is used to refer to this resource from elsewhere in the same Terraform module.

```bash
data “<DATA TYPE>” “<DATA LOCAL NAME>”   {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```
- Task1: Add a new data source to query the current AWS region being used
- Task2: Update the Terraform configuration file to use the new data source
- Task3: View the data source used to retrieve the availability zones with in the region
- Task4: Validate the data source is being used in the Terraform configuration file
- Task5:CreateanewdatasourceforqueryingadifferentUbuntuimage
- Task6: Make the aws_instance web_server use the Ubuntu image returned by the data source

[Data Sources official Documentation](https://www.terraform.io/language/data-sources)
