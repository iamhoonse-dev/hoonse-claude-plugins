---
name: airflow-component-guide
description: Airflow v3의 핵심 컴포넌트(DAG, Task, Operator, Hook, Sensor, TaskGroup, Asset, Dynamic Task Mapping)의 역할과 선택 기준을 정의합니다. Airflow 컴포넌트 설계 시 이 지침을 따릅니다.
user-invocable: false
---

## Airflow v3 컴포넌트 가이드

이 문서는 Airflow v3의 핵심 컴포넌트별 역할, 선택 기준, 구현 패턴을 정의합니다.

### 1. DAG (Directed Acyclic Graph)

#### 역할

DAG는 파이프라인의 오케스트레이션 단위입니다. 태스크들의 실행 순서와 스케줄을 정의합니다.

#### 새 DAG를 만드는 기준

다음 중 하나라도 해당하면 별도의 DAG를 생성합니다:

- **도메인이 다를 때**: `sales`와 `inventory`는 별도 DAG
- **스케줄이 다를 때**: 시간별 수집과 일별 리포트는 별도 DAG
- **독립적으로 실행 가능할 때**: 서로 의존하지 않는 파이프라인은 분리
- **팀/담당자가 다를 때**: 소유권을 명확히 하기 위해 분리

#### 기본 DAG 패턴

```python
import pendulum
from airflow.decorators import dag

@dag(
    dag_id="sales.daily_report",
    description="일별 매출 리포트 생성 파이프라인",
    schedule="@daily",
    start_date=pendulum.datetime(2024, 1, 1, tz="Asia/Seoul"),
    catchup=False,
    default_args={
        "owner": "data-engineering",
        "depends_on_past": False,
        "email_on_failure": True,
        "email_on_retry": False,
        "retries": 3,
        "retry_delay": pendulum.duration(minutes=5),
    },
    tags=["sales", "report", "daily"],
)
def sales_daily_report_dag():
    ...

dag = sales_daily_report_dag()
```

### 2. Task / Operator

#### 역할

Task는 파이프라인의 실행 단위입니다. Operator는 Task의 유형을 정의합니다.

#### PythonOperator vs @task 데코레이터 선택 기준

| 상황 | 권장 방식 |
|------|-----------|
| Python 함수만 실행 (단순 로직) | `@task` 데코레이터 |
| XCom으로 값을 주고받는 Python 태스크 | `@task` 데코레이터 |
| 기존 코드베이스에서 `PythonOperator` 사용 중 | `PythonOperator` (일관성 유지) |
| 외부 시스템 연동 (DB, API, 클라우드) | Provider 오퍼레이터 |
| Bash 명령 실행 | `BashOperator` |
| 브랜치 분기 | `BranchPythonOperator` 또는 `@task.branch` |

#### @task 데코레이터 패턴 (TaskFlow API)

```python
from airflow.decorators import dag, task

@dag(dag_id="sales.daily_report", ...)
def sales_daily_report_dag():

    @task
    def extract_sales_data(date: str) -> dict:
        """판매 데이터를 추출합니다."""
        ...
        return {"records": [...]}

    @task
    def transform_data(raw_data: dict) -> list:
        """데이터를 변환합니다."""
        ...

    @task
    def load_to_warehouse(transformed: list) -> None:
        """데이터웨어하우스에 적재합니다."""
        ...

    raw = extract_sales_data(date="{{ ds }}")
    transformed = transform_data(raw)
    load_to_warehouse(transformed)
```

#### Provider 오퍼레이터 사용

공식 Airflow provider 패키지를 우선 사용합니다:

```python
# S3 파일 전송
from airflow.providers.amazon.aws.transfers.s3_to_redshift import S3ToRedshiftOperator

# BigQuery 쿼리 실행
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator

# Postgres 쿼리
from airflow.providers.postgres.operators.postgres import PostgresOperator
```

### 3. Hook

#### 역할

Hook은 외부 시스템과의 연결을 추상화합니다. Operator 내부에서 사용하거나 `@task` 함수 내에서 직접 사용합니다.

#### 커스텀 Hook 작성 시점

다음 조건을 모두 만족할 때만 커스텀 Hook을 작성합니다:

- 공식 Airflow provider 패키지에 해당 시스템의 Hook이 없을 때
- 동일한 시스템 연결 로직이 2개 이상의 Operator/태스크에서 재사용될 때
- 연결 정보(Connection)를 Airflow 방식으로 관리해야 할 때

#### 커스텀 Hook 패턴

```python
from airflow.hooks.base import BaseHook

class SalesforceHook(BaseHook):
    """Salesforce API 연결 훅."""

    conn_name_attr = "salesforce_conn_id"
    default_conn_name = "salesforce_default"
    conn_type = "salesforce"
    hook_name = "Salesforce"

    def __init__(self, salesforce_conn_id: str = default_conn_name) -> None:
        super().__init__()
        self.salesforce_conn_id = salesforce_conn_id
        self._client = None

    def get_conn(self):
        if self._client is None:
            conn = self.get_connection(self.salesforce_conn_id)
            self._client = self._create_client(conn)
        return self._client

    def _create_client(self, conn):
        ...
```

### 4. Sensor

#### 역할

Sensor는 외부 이벤트나 상태 변화를 감지하여 다음 태스크 실행을 제어합니다.

#### poke_interval / timeout 설정 기준

| 시나리오 | poke_interval | timeout |
|----------|---------------|---------|
| 파일 도착 대기 (분 단위) | 60초 | 3600초 (1시간) |
| API 응답 대기 (초 단위) | 10초 | 300초 (5분) |
| 긴 배치 작업 완료 대기 | 300초 | 86400초 (24시간) |

`mode`는 기본 `poke` 대신 `reschedule`을 권장합니다 (워커 스레드 점유 방지):

```python
from airflow.sensors.filesystem import FileSensor

wait_for_file = FileSensor(
    task_id="wait_for_input_file",
    filepath="/data/input/{{ ds }}/sales.csv",
    poke_interval=60,
    timeout=3600,
    mode="reschedule",  # 워커 슬롯 절약
    soft_fail=False,
)
```

### 5. TaskGroup

#### 역할

TaskGroup은 관련 태스크들을 논리적으로 묶어 UI에서 그룹으로 표시하고 관리합니다.

#### 사용 기준

- 5개 이상의 태스크가 논리적으로 하나의 단계를 구성할 때
- 동일 패턴이 여러 도메인에서 반복될 때 (재사용 가능한 TaskGroup 함수로 추출)
- 복잡한 DAG의 가독성 향상이 필요할 때

#### 재사용 가능한 TaskGroup 패턴

```python
from airflow.utils.task_group import TaskGroup
from airflow.decorators import task

def create_data_quality_group(table_name: str) -> TaskGroup:
    """데이터 품질 검사 TaskGroup을 생성합니다."""
    with TaskGroup(
        group_id=f"dq_{table_name}",
        tooltip=f"{table_name} 데이터 품질 검사",
    ) as group:

        @task(task_id="check_row_count")
        def check_row_count() -> int:
            ...

        @task(task_id="check_null_values")
        def check_null_values() -> dict:
            ...

        @task(task_id="check_schema")
        def check_schema() -> bool:
            ...

        check_row_count() >> check_null_values() >> check_schema()

    return group


# DAG 내 사용
with dag:
    dq_group = create_data_quality_group("sales_orders")
    load_task >> dq_group
```

### 6. Asset (Dataset) — Airflow v3

#### 역할

Asset(구 Dataset)은 Airflow v3에서 DAG 간 데이터 의존성을 선언적으로 표현합니다. 한 DAG의 출력 데이터가 다른 DAG의 트리거 조건이 됩니다.

#### DAG 간 트리거 기준

다음 상황에서 Asset 기반 트리거를 사용합니다:

- 두 DAG가 시간 스케줄이 아닌 **데이터 준비 완료**에 의존할 때
- 업스트림 DAG 완료 후 다운스트림 DAG를 자동 실행해야 할 때
- 데이터 계보(lineage)를 명시적으로 표현해야 할 때

#### Asset 패턴

```python
from airflow.sdk import Asset

# 업스트림 DAG: Asset 생산
sales_raw_asset = Asset("s3://data-lake/sales/raw/{{ ds }}/")

@dag(dag_id="sales.raw_ingestion", schedule="@daily", ...)
def raw_ingestion_dag():

    @task(outlets=[sales_raw_asset])
    def ingest_raw_data() -> None:
        """원시 데이터를 S3에 저장합니다."""
        ...

    ingest_raw_data()


# 다운스트림 DAG: Asset 소비 (Asset 준비 완료 시 자동 트리거)
@dag(dag_id="sales.daily_report", schedule=[sales_raw_asset], ...)
def daily_report_dag():

    @task
    def generate_report() -> None:
        """원시 데이터를 기반으로 리포트를 생성합니다."""
        ...

    generate_report()
```

### 7. Dynamic Task Mapping

#### 역할

`expand()`를 사용하여 런타임에 결정되는 입력 목록에 대해 동적으로 태스크를 생성합니다.

#### 사용 기준

- 처리 대상 목록이 런타임에 결정될 때
- 동일한 처리 로직을 여러 입력에 병렬 적용할 때
- 입력 목록이 너무 커서 정적으로 DAG를 정의하기 어려울 때

#### Dynamic Task Mapping 패턴

```python
from airflow.decorators import dag, task

@dag(dag_id="sales.multi_region_report", schedule="@daily", ...)
def multi_region_report_dag():

    @task
    def get_regions() -> list[str]:
        """처리할 지역 목록을 반환합니다."""
        return ["KR", "JP", "US", "EU"]

    @task
    def process_region(region: str) -> dict:
        """지역별 데이터를 처리합니다."""
        ...
        return {"region": region, "status": "done"}

    @task
    def aggregate_results(results: list[dict]) -> None:
        """모든 지역 결과를 집계합니다."""
        ...

    regions = get_regions()
    region_results = process_region.expand(region=regions)
    aggregate_results(region_results)
```

#### expand_kwargs 패턴 (복수 파라미터)

```python
@task
def process_partition(table: str, date: str) -> None:
    ...

process_partition.expand_kwargs([
    {"table": "orders", "date": "2024-01-01"},
    {"table": "returns", "date": "2024-01-01"},
])
```
