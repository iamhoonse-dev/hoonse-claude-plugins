---
name: airflow-project-convention
description: Airflow v3 프로젝트의 디렉토리 구조, 파일 명명 규칙, Python 코딩 규약, 식별자 명명 규칙, 설정 관리 기준을 정의합니다. Airflow 프로젝트 작업 시 이 지침을 따릅니다.
user-invocable: false
---

## Airflow v3 프로젝트 규약

이 문서는 Airflow v3 기반 프로젝트에서 따라야 하는 구조와 코딩 규약을 정의합니다.

### 1. 프로젝트 디렉토리 구조

Airflow v3 프로젝트의 표준 레이아웃은 다음과 같습니다:

```
project/
├── dags/
│   ├── __init__.py
│   └── {domain}_{pipeline}_dag.py   # DAG 정의 파일
├── plugins/
│   ├── __init__.py
│   ├── operators/
│   │   ├── __init__.py
│   │   └── {domain}_operator.py     # 커스텀 오퍼레이터
│   ├── sensors/
│   │   ├── __init__.py
│   │   └── {domain}_sensor.py       # 커스텀 센서
│   └── hooks/
│       ├── __init__.py
│       └── {domain}_hook.py         # 커스텀 훅
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── unit/
│   │   ├── __init__.py
│   │   ├── dags/
│   │   │   ├── __init__.py
│   │   │   └── test_{domain}_{pipeline}_dag.py
│   │   ├── operators/
│   │   │   ├── __init__.py
│   │   │   └── test_{domain}_operator.py
│   │   └── hooks/
│   │       ├── __init__.py
│   │       └── test_{domain}_hook.py
│   └── integration/
│       ├── __init__.py
│       └── test_{domain}_{pipeline}_integration.py
├── config/
│   └── airflow.cfg                  # Airflow 설정 (로컬 개발용)
├── requirements.txt
└── docker-compose.yaml              # 로컬 개발 환경 (선택)
```

### 2. 파일 명명 규칙

| 파일 유형 | 명명 규칙 | 예시 |
|----------|-----------|------|
| DAG 파일 | `{domain}_{pipeline}_dag.py` | `sales_daily_report_dag.py` |
| 커스텀 오퍼레이터 | `{domain}_operator.py` | `slack_notification_operator.py` |
| 커스텀 센서 | `{domain}_sensor.py` | `s3_file_sensor.py` |
| 커스텀 훅 | `{domain}_hook.py` | `salesforce_hook.py` |
| 단위 테스트 | `test_{대상파일명}.py` | `test_sales_daily_report_dag.py` |
| 통합 테스트 | `test_{domain}_{pipeline}_integration.py` | `test_sales_daily_report_integration.py` |

- 모든 파일명은 **snake_case** 소문자 사용
- 도메인 이름은 비즈니스 영역을 나타냄 (예: `sales`, `inventory`, `marketing`)
- 파이프라인 이름은 작업 내용을 간결하게 표현 (예: `daily_report`, `etl_sync`)

### 3. Python 코딩 규약

#### 기본 규칙

- **PEP 8** 준수 (들여쓰기 4칸, 줄 길이 최대 88자)
- 모든 변수, 함수, 클래스에 **타입 힌트(type hints)** 사용
- **snake_case**: 변수, 함수, 모듈명
- **PascalCase**: 클래스명
- **UPPER_SNAKE_CASE**: 상수

#### import 순서 (isort 기준)

```python
# 1. 표준 라이브러리
from datetime import datetime, timedelta
from typing import Any

# 2. 서드파티 라이브러리 (Airflow 포함)
import pendulum
from airflow import DAG
from airflow.decorators import dag, task
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup

# 3. 프로젝트 내부 모듈
from plugins.hooks.custom_hook import CustomHook
```

#### 코드 스타일

```python
# 올바른 예: 타입 힌트 사용
def extract_data(source: str, date: str) -> dict[str, Any]:
    """데이터를 소스에서 추출합니다."""
    ...

# 잘못된 예: 타입 힌트 없음
def extract_data(source, date):
    ...
```

### 4. 식별자 명명 규칙

#### dag_id

- 형식: `{domain}.{pipeline}` (점(`.`) 구분자 사용)
- 소문자 snake_case 단어를 점으로 연결
- 예: `sales.daily_report`, `inventory.stock_sync`, `marketing.email_campaign`

```python
with DAG(
    dag_id="sales.daily_report",
    ...
) as dag:
    ...
```

#### task_id

- 형식: `{verb}_{noun}` (동사_명사)
- 동사는 작업의 성격을 표현 (예: `extract`, `transform`, `load`, `validate`, `notify`)
- 예: `extract_raw_data`, `transform_sales_records`, `load_to_warehouse`, `validate_schema`

```python
extract_task = PythonOperator(
    task_id="extract_raw_data",
    ...
)
```

#### connection_id

- 형식: `{system}_{env}` 또는 `{system}_{role}`
- 예: `postgres_prod`, `s3_data_lake`, `slack_alerts`, `salesforce_api`

#### variable_key

- 형식: `{domain}_{setting_name}` (snake_case)
- 예: `sales_api_endpoint`, `report_output_bucket`, `max_retry_count`

### 5. 설정 관리

#### Airflow Connections 사용 기준

외부 시스템 접속 정보(호스트, 포트, 계정, 비밀번호 등)는 반드시 Airflow Connection으로 관리합니다.

```python
# 올바른 예: Connection 사용
from airflow.hooks.base import BaseHook

conn = BaseHook.get_connection("postgres_prod")
host = conn.host
password = conn.password

# 잘못된 예: 하드코딩 금지
host = "prod-db.example.com"
password = "secret123"
```

#### Airflow Variables 사용 기준

환경별로 달라지는 설정 값(버킷명, API 엔드포인트, 임계값 등)은 Airflow Variable로 관리합니다.

```python
from airflow.models import Variable

output_bucket = Variable.get("report_output_bucket")
max_rows = int(Variable.get("max_rows_per_batch", default_var="10000"))
```

#### 환경 변수 사용 기준

Airflow 메타데이터 DB 접근이 불가한 외부 설정, 또는 Airflow 자체 설정(`AIRFLOW__CORE__...`)은 환경 변수로 관리합니다.

```python
import os

log_level = os.getenv("LOG_LEVEL", "INFO")
```

#### 우선순위

`Airflow Connection` > `Airflow Variable` > `환경 변수` > `코드 내 기본값`

민감 정보(비밀번호, API 키 등)는 절대 코드에 하드코딩하지 않습니다.

### 6. Airflow v3 특이사항

#### schedule 파라미터

Airflow v3에서는 `schedule_interval` 대신 `schedule`을 사용합니다:

```python
# cron 표현식
with DAG(dag_id="...", schedule="0 9 * * *", ...) as dag:
    ...

# 미리 정의된 값
with DAG(dag_id="...", schedule="@daily", ...) as dag:
    ...

# Asset(Dataset) 기반 트리거 (Airflow v3)
from airflow.sdk import Asset

my_asset = Asset("s3://bucket/path/to/data")

with DAG(dag_id="...", schedule=[my_asset], ...) as dag:
    ...

# 커스텀 Timetable
with DAG(dag_id="...", schedule=CustomTimetable(), ...) as dag:
    ...
```

#### catchup 기본 설정

신규 DAG는 기본적으로 `catchup=False`를 적용합니다. 과거 데이터 백필이 명시적으로 필요한 경우에만 `catchup=True`를 사용하고 그 이유를 주석으로 명시합니다.

```python
import pendulum

with DAG(
    dag_id="sales.daily_report",
    schedule="@daily",
    start_date=pendulum.datetime(2024, 1, 1, tz="Asia/Seoul"),
    catchup=False,  # 과거 실행 생략 (기본값)
    ...
) as dag:
    ...
```

#### start_date 설정

`start_date`는 `pendulum`을 사용하여 타임존을 명시합니다:

```python
import pendulum

start_date = pendulum.datetime(2024, 1, 1, tz="Asia/Seoul")
```

`datetime` 모듈 사용 시에도 타임존 정보를 포함합니다:

```python
from datetime import datetime, timezone

start_date = datetime(2024, 1, 1, tzinfo=timezone.utc)
```
