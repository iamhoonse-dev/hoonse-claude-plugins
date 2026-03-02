---
name: airflow-test-convention
description: Airflow v3 프로젝트의 테스트 구조, DAG 구조 테스트, Operator/Hook 단위 테스트, TaskFlow 함수 테스트, 통합 테스트, 공통 fixture 패턴을 정의합니다. Airflow 테스트 작성 시 이 지침을 따릅니다.
user-invocable: false
---

## Airflow v3 테스트 규약

이 문서는 Airflow v3 프로젝트의 테스트 작성 규약과 패턴을 정의합니다.

### 1. 테스트 디렉토리 구조

```
tests/
├── __init__.py
├── conftest.py                          # 공통 fixtures
├── unit/
│   ├── __init__.py
│   ├── dags/
│   │   ├── __init__.py
│   │   └── test_{domain}_{pipeline}_dag.py   # DAG 구조 테스트
│   ├── operators/
│   │   ├── __init__.py
│   │   └── test_{domain}_operator.py         # 커스텀 Operator 단위 테스트
│   └── hooks/
│       ├── __init__.py
│       └── test_{domain}_hook.py             # 커스텀 Hook 단위 테스트
└── integration/
    ├── __init__.py
    └── test_{domain}_{pipeline}_integration.py  # 통합 테스트
```

### 2. DAG 구조 테스트

DAG 파일이 올바르게 로딩되고 기대하는 구조를 가지는지 검증합니다.

```python
# tests/unit/dags/test_sales_daily_report_dag.py

import pytest
from airflow.models import DagBag


class TestSalesDailyReportDag:
    """sales.daily_report DAG 구조 테스트."""

    DAG_ID = "sales.daily_report"

    def test_dag_loaded_without_errors(self, dag_bag: DagBag) -> None:
        """DagBag에 오류 없이 로딩되는지 확인합니다."""
        assert len(dag_bag.import_errors) == 0, (
            f"DAG 로딩 오류: {dag_bag.import_errors}"
        )

    def test_dag_exists(self, dag_bag: DagBag) -> None:
        """대상 DAG가 존재하는지 확인합니다."""
        assert self.DAG_ID in dag_bag.dags, (
            f"'{self.DAG_ID}' DAG를 찾을 수 없습니다."
        )

    def test_dag_has_expected_tasks(self, dag_bag: DagBag) -> None:
        """기대하는 task_id가 모두 존재하는지 확인합니다."""
        dag = dag_bag.get_dag(self.DAG_ID)
        expected_task_ids = {
            "extract_raw_data",
            "transform_data",
            "load_to_warehouse",
        }
        actual_task_ids = {task.task_id for task in dag.tasks}
        assert expected_task_ids.issubset(actual_task_ids), (
            f"누락된 태스크: {expected_task_ids - actual_task_ids}"
        )

    def test_dag_has_no_import_errors(self, dag_bag: DagBag) -> None:
        """DAG 파일에 임포트 오류가 없는지 확인합니다."""
        dag = dag_bag.get_dag(self.DAG_ID)
        assert dag is not None

    def test_dag_task_dependencies(self, dag_bag: DagBag) -> None:
        """태스크 의존성이 올바르게 설정되었는지 확인합니다."""
        dag = dag_bag.get_dag(self.DAG_ID)
        extract_task = dag.get_task("extract_raw_data")
        transform_task = dag.get_task("transform_data")
        load_task = dag.get_task("load_to_warehouse")

        assert transform_task.task_id in [
            t.task_id for t in extract_task.downstream_list
        ]
        assert load_task.task_id in [
            t.task_id for t in transform_task.downstream_list
        ]

    def test_dag_catchup_is_false(self, dag_bag: DagBag) -> None:
        """catchup이 False로 설정되었는지 확인합니다."""
        dag = dag_bag.get_dag(self.DAG_ID)
        assert dag.catchup is False

    def test_dag_has_tags(self, dag_bag: DagBag) -> None:
        """DAG에 태그가 설정되었는지 확인합니다."""
        dag = dag_bag.get_dag(self.DAG_ID)
        assert len(dag.tags) > 0
```

### 3. Operator / Hook 단위 테스트

외부 시스템 의존성을 mock으로 대체하여 순수 로직을 테스트합니다.

#### 커스텀 Operator 테스트

```python
# tests/unit/operators/test_slack_notification_operator.py

from unittest.mock import MagicMock, patch

import pytest

from plugins.operators.slack_notification_operator import SlackNotificationOperator


class TestSlackNotificationOperator:
    """SlackNotificationOperator 단위 테스트."""

    def test_execute_sends_message(self) -> None:
        """execute() 호출 시 Slack 메시지가 전송되는지 확인합니다."""
        operator = SlackNotificationOperator(
            task_id="notify_slack",
            slack_conn_id="slack_alerts",
            message="테스트 메시지",
        )

        mock_context = {"ds": "2024-01-01", "dag": MagicMock()}

        with patch.object(operator, "_get_slack_client") as mock_client:
            mock_client.return_value.chat_postMessage.return_value = {"ok": True}
            operator.execute(mock_context)
            mock_client.return_value.chat_postMessage.assert_called_once()

    def test_execute_raises_on_failure(self) -> None:
        """Slack API 오류 시 예외가 발생하는지 확인합니다."""
        operator = SlackNotificationOperator(
            task_id="notify_slack",
            slack_conn_id="slack_alerts",
            message="테스트 메시지",
        )

        with patch.object(operator, "_get_slack_client") as mock_client:
            mock_client.return_value.chat_postMessage.side_effect = Exception("API Error")
            with pytest.raises(Exception, match="API Error"):
                operator.execute({})
```

#### 커스텀 Hook 테스트

```python
# tests/unit/hooks/test_salesforce_hook.py

from unittest.mock import MagicMock, patch

import pytest

from plugins.hooks.salesforce_hook import SalesforceHook


class TestSalesforceHook:
    """SalesforceHook 단위 테스트."""

    def test_get_conn_uses_airflow_connection(
        self, mock_airflow_conn: MagicMock
    ) -> None:
        """get_conn()이 Airflow Connection을 사용하는지 확인합니다."""
        hook = SalesforceHook(salesforce_conn_id="salesforce_api")

        with patch.object(hook, "get_connection", return_value=mock_airflow_conn):
            conn = hook.get_conn()
            assert conn is not None

    def test_query_returns_records(self, mock_airflow_conn: MagicMock) -> None:
        """query() 메서드가 레코드 목록을 반환하는지 확인합니다."""
        hook = SalesforceHook(salesforce_conn_id="salesforce_api")
        expected_records = [{"Id": "001", "Name": "Test Account"}]

        with patch.object(hook, "get_conn") as mock_get_conn:
            mock_get_conn.return_value.query.return_value = {
                "records": expected_records
            }
            result = hook.query("SELECT Id, Name FROM Account")
            assert result == expected_records
```

### 4. TaskFlow 함수 테스트

`@task` 데코레이터 함수는 일반 Python 함수처럼 직접 호출하여 테스트합니다.

```python
# tests/unit/dags/test_sales_daily_report_dag.py (함수 테스트 부분)

from unittest.mock import patch, MagicMock

import pytest

# DAG 모듈에서 태스크 함수를 직접 임포트
from dags.sales_daily_report_dag import extract_sales_data, transform_data


class TestSalesDailyReportFunctions:
    """sales.daily_report DAG의 태스크 함수 단위 테스트."""

    def test_extract_sales_data_returns_dict(self) -> None:
        """extract_sales_data()가 딕셔너리를 반환하는지 확인합니다."""
        with patch("dags.sales_daily_report_dag.SalesforceHook") as mock_hook:
            mock_hook.return_value.query.return_value = [
                {"Id": "001", "Amount": 1000.0}
            ]
            # @task 데코레이터 함수는 .function 속성으로 원본 함수에 접근
            result = extract_sales_data.function(date="2024-01-01")
            assert isinstance(result, dict)
            assert "records" in result

    def test_transform_data_filters_invalid_records(self) -> None:
        """transform_data()가 유효하지 않은 레코드를 필터링하는지 확인합니다."""
        raw_data = {
            "records": [
                {"Id": "001", "Amount": 1000.0},
                {"Id": "002", "Amount": None},  # 유효하지 않은 레코드
            ]
        }
        result = transform_data.function(raw_data=raw_data)
        assert len(result) == 1
        assert result[0]["Id"] == "001"
```

### 5. 통합 테스트

LocalExecutor 기반으로 실제 DAG를 실행하여 전체 파이프라인을 검증합니다.

```python
# tests/integration/test_sales_daily_report_integration.py

import pytest
from airflow.models import DagBag, TaskInstance
from airflow.utils.state import DagRunState, TaskInstanceState
from airflow.utils.types import DagRunType


class TestSalesDailyReportIntegration:
    """sales.daily_report DAG 통합 테스트."""

    DAG_ID = "sales.daily_report"

    @pytest.mark.integration
    def test_dag_runs_successfully(
        self,
        dag_bag: DagBag,
        mock_airflow_conn: MagicMock,
        mock_airflow_var: None,
    ) -> None:
        """DAG가 성공적으로 실행되는지 확인합니다."""
        import pendulum
        from airflow.utils.session import create_session

        dag = dag_bag.get_dag(self.DAG_ID)
        logical_date = pendulum.datetime(2024, 1, 1, tz="Asia/Seoul")

        with create_session() as session:
            dag_run = dag.create_dagrun(
                state=DagRunState.RUNNING,
                logical_date=logical_date,
                run_id=f"test_run_{logical_date.isoformat()}",
                run_type=DagRunType.MANUAL,
                session=session,
            )

            for task in dag.tasks:
                ti = TaskInstance(task=task, run_id=dag_run.run_id)
                ti.run(ignore_all_deps=True, ignore_ti_state=True, session=session)
                assert ti.state == TaskInstanceState.SUCCESS, (
                    f"태스크 '{task.task_id}' 실패: {ti.state}"
                )
```

### 6. 공통 Fixture 패턴

`tests/conftest.py`에 공통 fixture를 정의합니다.

```python
# tests/conftest.py

from unittest.mock import MagicMock

import pytest
from airflow.models import Connection, DagBag, Variable


@pytest.fixture(scope="session")
def dag_bag() -> DagBag:
    """DagBag fixture - 세션당 한 번만 로딩합니다."""
    return DagBag(dag_folder="dags/", include_examples=False)


@pytest.fixture
def mock_airflow_conn() -> MagicMock:
    """Airflow Connection mock fixture."""
    conn = MagicMock(spec=Connection)
    conn.host = "mock-host"
    conn.port = 5432
    conn.login = "mock-user"
    conn.password = "mock-password"
    conn.schema = "mock-schema"
    conn.extra_dejson = {}
    return conn


@pytest.fixture
def mock_airflow_var(monkeypatch: pytest.MonkeyPatch) -> None:
    """Airflow Variable mock fixture - Variable.get()을 대체합니다."""
    mock_vars = {
        "report_output_bucket": "s3://test-bucket/reports",
        "max_rows_per_batch": "1000",
    }

    def mock_get(key: str, default_var=None, **kwargs):
        return mock_vars.get(key, default_var)

    monkeypatch.setattr(Variable, "get", staticmethod(mock_get))
```

### 7. Airflow v3 테스트 주의사항

#### pendulum 사용

날짜/시간 처리에는 `pendulum`을 사용합니다. `datetime` 대신 타임존 인식 객체를 생성합니다:

```python
# 올바른 예
import pendulum

logical_date = pendulum.datetime(2024, 1, 1, tz="Asia/Seoul")

# 잘못된 예 (타임존 없는 naive datetime)
from datetime import datetime

logical_date = datetime(2024, 1, 1)
```

#### logical_date vs execution_date

Airflow v3에서는 `execution_date` 대신 `logical_date`를 사용합니다:

```python
# Airflow v3 올바른 예
context["logical_date"]
context["data_interval_start"]
context["data_interval_end"]

# Airflow v2 이하 방식 (v3에서 deprecated)
context["execution_date"]
context["next_execution_date"]
```

#### 테스트 마커 사용

`pytest.ini` 또는 `pyproject.toml`에 마커를 등록하고, 통합 테스트와 단위 테스트를 분리합니다:

```ini
# pytest.ini
[pytest]
markers =
    integration: 통합 테스트 (외부 의존성 필요)
    unit: 단위 테스트 (mock 사용)
```

```bash
# 단위 테스트만 실행
pytest tests/unit/ -v

# 통합 테스트만 실행
pytest tests/integration/ -v -m integration

# 커버리지 포함 전체 실행
pytest tests/ --cov=dags --cov=plugins --cov-report=term-missing
```
