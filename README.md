# airflow-update

File update for airflow work.

## Local fix script for 560S Airflow configuration

Run the PowerShell script below to replace `560S` with `560s` in your local `airflow.cfg` file.

```powershell
pwsh -NoProfile -File ./fix-560s-airflow-config.ps1 -ConfigPath ./airflow.cfg
```

Optional dry run:

```powershell
pwsh -NoProfile -File ./fix-560s-airflow-config.ps1 -ConfigPath ./airflow.cfg -WhatIf
```
