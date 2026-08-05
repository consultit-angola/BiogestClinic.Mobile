# biogest_clinic_mobile

A new Flutter project.

## Auto commit

Run the script with the Dart SDK managed by FVM:

```powershell
.\.fvm\flutter_sdk\bin\dart.bat run tool\auto_commit.dart --branch=<branch-name> --msg="Commit message"
```

To pull from `test` after committing and before pushing:

```powershell
.\.fvm\flutter_sdk\bin\dart.bat run tool\auto_commit.dart --branch=<branch-name> --msg="Commit message" --pull-from-test
```

Use `--pull-branch=<branch-name>` together with `--pull-from-test` when the base branch is not `test`.
