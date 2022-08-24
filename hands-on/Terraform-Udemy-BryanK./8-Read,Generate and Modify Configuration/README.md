# Lab: Local Variables

A local value assigns a name to an expression, so you can use it multiple times within a configuration without repeating it. The expressions in local values are not limited to literal constants; they can also reference other values in the configuration in order to transform or combine them, including variables, resource attributes, or other local values.
You can use local values to simplify your Terraform configuration and avoid repetition. Local values (locals) can also help you write a more readable configuration by using meaningful names rather than hard-coding values. If overused they can also make a configuration hard to read by future maintainers by hiding the actual values used.
Use local values only in moderation, in situations where a single value or result is used in many places and that value is likely to be changed in future. The ability to easily change the value in a central place is the key advantage of local values.

* Task1: Create local values in a configuration block
* Task2: Interpolate local values
* Task3: Using locals with variable expressions
* Task4: Using locals with terraform expressions and operators

# Lab: Variables

We don’t want to hardcode all of our values in the main.tf file. We can create a variable file for easier use.Inthevariables blocklab,wecreatedafewnewvariables,learnedhowtomanuallysettheir values, and even how to set the defaults. In this lab, we’ll learn the other ways that we can set the values for our variables that are used across our Terraform configuration.

* Task1: Set the value of a variable using environment variables 
* Task2: Declare the desired values using a tfvars file
* Task3: Override the variable on the CLI

# Lab: Outputs

Terraform generates a significant amount of metadata that is too tedious to sort through with terraform show. Even with just one instance deployed, we wouldn’t want to scan 38 lines of metadata every time. Outputs allow us to query for specific values rather than parse metadata in terraform show.
* Task1: Create output values in the configuration file
* Task2: Use the output command to find specific values 
* Task3: Suppress outputs of sensitive values in the CLI