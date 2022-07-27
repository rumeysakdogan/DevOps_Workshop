# Lab: Terraform Taint and Replace

The terraform taint command allows for you to manually mark a resource for recreation. The `taint` command informs Terraform that a particular resource needs to be rebuilt even if there has been no configuration change for that resource. Terraform represents this by marking the resource as “tainted” in the Terraform state, in which case Terraform will propose to replace it in the next plan you create.

- Task1: Manually mark a resource to be rebuilt by using the terraform `taint` command.
-  Task2: Observe a `remote-exec` provisoner failing,resulting in Terraform automatically tainting a resource.
- Task3: Untaint a resource
- Task4: Use the `-replace` option rather than taint

> `taint` comment is deprecated, `-replace` option is the recommended approach now.
