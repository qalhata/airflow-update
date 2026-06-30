# fix-airflow.ps1  -  Course 560S
$ErrorActionPreference = 'Stop'
Set-Location 'C:\Course560S\vm-build'

# 1) Back up the compose file so we can always revert
Copy-Item 'docker-compose.yml' 'docker-compose.yml.bak' -Force

# 2) Repoint the DAGs mount at the labs folder, add the /work mount, switch examples on
$yml = Get-Content 'docker-compose.yml' -Raw
$yml = $yml -replace '(?m)^([ \t]*)-\s*\.\./instructor/labs/airflow/dags:/opt/airflow/dags\s*$', ('${1}- ../Course560S_Labs:/opt/airflow/dags' + "`r`n" + '${1}- ..:/work')
$yml = $yml -replace 'AIRFLOW__CORE__LOAD_EXAMPLES:\s*"false"', 'AIRFLOW__CORE__LOAD_EXAMPLES: "true"'
[System.IO.File]::WriteAllText('C:\Course560S\vm-build\docker-compose.yml', $yml)

# 3) Create the Module 6 DAG in the labs folder (the same DAG shown in the notebook)
$dag = @(
'from datetime import datetime, timedelta',
'from airflow import DAG',
'from airflow.operators.python import PythonOperator',
'',
'def build_revenue(**context):',
'    print("Building revenue by category for", context["ds"])',
'',
'default_args = {"retries": 1, "retry_delay": timedelta(minutes=5)}',
'',
'with DAG(',
'    dag_id="revenue_daily",',
'    description="Build revenue by category each morning",',
'    schedule="0 6 * * *",',
'    start_date=datetime(2026, 1, 1),',
'    catchup=False,',
'    default_args=default_args,',
'    tags=["course"],',
') as dag:',
'    PythonOperator(task_id="build_revenue", python_callable=build_revenue)'
)
Set-Content -Path 'C:\Course560S\Course560S_Labs\revenue_daily.py' -Value $dag

# 4) Recreate the services so Airflow picks up the new mounts
docker compose down
docker compose --profile day2-spark up -d

Write-Host "`nDone. Wait ~60s, then run the two checks below." -ForegroundColor Green