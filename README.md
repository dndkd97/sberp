# 채용 데이터 분석 서버 구축 & AWS 배포 (Django + Pandas)

SBerp v3 채용관리 모듈 배포 이후, 통계 인사이트 요구에 대응하기 위해 혼자 추가로 구축한 채용 데이터 분석 서버와 그 배포 작업을 정리한 문서입니다. 프로젝트/태스크/채용관리 등 그 외 도메인 기능은 SBerp v3 README를 참고해 주세요.
> 팀 전체 코드→ https://github.com/yoonguri988/spring-breeze-erp
v3 (REST API + AI): https://github.com/dndkd97/SB_ERP_V3

## 📌 개요

| 항목 | 내용 |
|---|---|
| 개발 기간 | 2026.09 |
| 개발 인원 | 1인 단독 설계·구현 |
| 배경 | 기존 채용관리 시스템은 지원자 상태를 단순 나열만 해, 전형 단계별 병목이나 월별 지원 추이 같은 인사이트를 얻을 수 없었음 |
| 기술 스택 | Python, Django, Pandas |
| 연동 대상 | 기존 Spring Boot 백엔드(RestTemplate) |

## 🛠 기술 스택

![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![Django](https://img.shields.io/badge/Django-092E20?style=flat-square&logo=django&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=flat-square&logo=pandas&logoColor=white)
![AWS EC2](https://img.shields.io/badge/AWS%20EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat-square&logo=nginx&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)

> 분석 로직은 Python(Pandas)으로, 기존 Spring Boot 백엔드와는 REST API로 연동. 동일 EC2 인스턴스에 별도 프로세스로 배포하고 Nginx로 경로별 라우팅, GitHub Actions로 배포 자동화.

## 🚀 AWS 배포

- 기존 Spring Boot 백엔드는 그대로, 채용 데이터 분석 서버(Django)를 동일 EC2 인스턴스에 별도 프로세스(8000번 포트)로 추가 배포
- Spring Boot가 프론트엔드에 대한 단일 API 게이트웨이 역할을 하고, 내부적으로 분석 서버에 위임하는 구조
- Nginx 리버스 프록시에 `/dashboard/` 경로 라우팅 규칙을 추가해, 해당 경로 요청만 분석 서버(localhost:8000)로 전달
- GitHub Actions로 main/develop 브랜치 push/PR 시 build-test-deploy 자동화(CI/CD) 구성
- DB credentials, JWT secret, OpenAI API key 등 민감 설정은 `.env`/시스템 환경변수로 분리 관리

## 🐍 채용 데이터 분석 서버 (Python + Django + Pandas)

### 채용 퍼널 전환율/정체율 분석
- 접수 → 서류심사 → 면접 → 합격 파이프라인에서, 각 단계를 실제로 통과한 인원을 뒤에서부터(reversed) 누적 합산해 "최종 도달 인원" 기준 전환율 산출
- 단계별 정체(stall) 인원과 정체율을 계산해 병목 구간 자동 식별
- REJECTED(불합격)는 별도 트랙으로 분리해 전체 탈락률을 파이프라인 전환율과 혼동 없이 계산

### 월별 지원자 추이 분석
- 월별 지원자 수를 집계해 월평균/최다/최저 지원 월, 전월 대비 증감률 계산
- Pandas로 월별 데이터 정렬·집계 후 프론트엔드 KPI 카드/차트용 데이터로 가공

### 기존 백엔드와의 REST 연동
내부 전용 API 2종 제공:
- `POST /dashboard/api/statistics/` — 일자별 전형 상태 통계 upsert
- `POST /dashboard/api/analysis/` — 분석 결과 조회 (전환율, 정체 구간, 월별 추이 등)

### 주요 기술 포인트
- 전형 파이프라인은 RECEIVED → SCREENING → INTERVIEW → HIRED 4단계로 고정 정의, REJECTED는 전체 탈락률 계산에만 별도 사용
- 단계별 통과 인원은 배열을 뒤에서부터 누적 합산 — 중간에 다른 단계로 이동한 인원까지 고려한 "최종 도달 인원" 기준
- Pandas DataFrame의 `reindex`로, 특정 상태 데이터가 하나도 없어도 전체 상태값(0건 포함)이 항상 동일한 순서로 반환되도록 처리
- 세션 인증 없이 `@csrf_exempt`로 개방 — 외부 노출 없이 내부망(localhost) 통신 전용으로 설계

## 🛠 트러블슈팅

**배포 환경에서만 분석 API가 500 에러를 반환하던 문제**
로컬 개발 환경에서는 정상 동작했지만, 배포 서버에서만 분석 대시보드 조회 시 500 에러 발생.

- 1차 원인: `urls.py`가 참조하는 뷰 함수가 실제 코드에 없어 Django 프로세스가 부팅 단계에서 죽어있었음. PM2 등록 없이 터미널에서 수동 실행 중이라 세션 종료 시 함께 죽는 구조였던 것도 확인 → PM2에 정식 등록해 상시 구동으로 전환
- 2차 원인: Django를 정상화한 뒤에도 500이 계속 발생. 기존 백엔드 로그에서 `RestTemplate`이 `UnknownContentTypeException`을 던지는 것을 확인, 컴파일된 JAR의 문자열 상수를 추출(`strings`)해 실제 호출 URL을 역추적한 결과, 백엔드가 Django를 자기 자신의 공인 도메인으로 호출하고 있었는데 Nginx 설정에 해당 경로(`/dashboard/`)에 대한 라우팅이 아예 없어 요청이 프론트엔드로 잘못 전달되고 있었음
- 해결: Nginx에 `/dashboard/` → `localhost:8000` 프록시 라우팅 규칙 추가 후 `nginx -t` 검증, 무중단(reload) 반영

Nginx-백엔드-Django로 이어지는 다계층 요청 흐름을 계층별로 직접 로그를 확인하며 원인을 좁혀나가는 디버깅 과정을 통해, 코드 문제로 단정하지 않고 인프라 설정까지 확인 범위를 넓히는 습관을 얻었습니다.

## 🔭 향후 개선 방향

| 구분 | 현재 (AS-IS) | 개선 방향 (TO-BE) |
|---|---|---|
| DB | SQLite 단일 파일 사용 | 운영 규모 확대 시 PostgreSQL 등으로 전환 |
| 실행 방식 | Django 개발 서버(runserver)로 상시 구동 | gunicorn 등 운영용 WSGI 서버로 전환 |
| 데이터 갱신 방식 | 요청마다 원본 데이터를 통째로 전달받아 계산 | 배치/스케줄러 기반 사전 집계로 응답 속도 개선 |
| 분석 항목 | 전환율/정체율, 월별 추이 위주 | 채용 공고별/부서별 세분화 분석 추가 |
