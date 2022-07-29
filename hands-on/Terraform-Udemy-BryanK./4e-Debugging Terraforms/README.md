# Lab: Debugging Terraform

- Task1: Enable Logging
- Task2: Set Logging Path
- Task3: Disable Logging

### Task 1: Enable Logging
Terraform has detailed logs which can be enabled by setting the `TF_LOG` environment variable to any value. This will cause detailed logs to appear on `stderr`.
You can set `TF_LOG` to one of the log levels `TRACE`, `DEBUG`, `INFO`, `WARN` or `ERROR` to change the verbosity of the logs, with TRACE being the most verbose.
Linux
```sh
export TF_LOG=TRACE 
```
PowerShell
```sh
$env:TF_LOG="TRACE"
```
Run Terraform Apply.
```sh
 terraform apply
```
### Task 2: Enable Logging Path
To persist logged output you can set `TF_LOG_PATH` in order to force the log to always be appended to a specific file when logging is enabled. Note that even when `TF_LOG_PATH` is set, `TF_LOG` must be set in order for any logging to be enabled.
```sh
export TF_LOG_PATH="terraform_log.txt"
```
 PowerShell
```sh
$env:TF_LOG_PATH="terraform_log.txt"
```
Run `terraform init` to see the initialization debugging information.
```sh
 terraform init -upgrade
```
Open the `terraform_log.txt` to see the contents of the debug trace for your terraform init. Experiment with removing the provider stanza within your Terraform configuration and run a `terraform plan` to debug how Terraform searches for where a provider is located.

### Task 3: Disable Logging
Terraform logging can be disabled by clearing the appropriate environment variable. 
Linux
```sh
export TF_LOG=""
``` 
PowerShell
```sh
 $env:TF_LOG=""
 ```