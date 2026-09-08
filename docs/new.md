-- ============================================
-- ATTENDANCE 테이블 DDL
-- ============================================

-- 시퀀스
CREATE SEQUENCE SEQ_ATTENDANCE
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- 테이블
CREATE TABLE attendance (
    att_id              NUMBER          NOT NULL,
    emp_id              NUMBER          NOT NULL,
    att_date            DATE            NOT NULL,
    check_in            TIMESTAMP,
    check_out           TIMESTAMP,
    work_minutes        NUMBER DEFAULT 0,
    overtime_minutes    NUMBER DEFAULT 0,
    night_minutes       NUMBER DEFAULT 0,
    att_status          VARCHAR2(20) DEFAULT 'ABSENT',
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP,

    CONSTRAINT pk_attendance        PRIMARY KEY (att_id),
    CONSTRAINT uk_attendance_daily  UNIQUE (emp_id, att_date),
    CONSTRAINT fk_attendance_emp    FOREIGN KEY (emp_id)
                                    REFERENCES employee (emp_id),
    CONSTRAINT ck_att_status        CHECK (att_status IN (
                                        'NORMAL', 'LATE', 'EARLY_LEAVE', 'ABSENT'
                                    ))
);

-- 인덱스: 기간별 조회 성능
CREATE INDEX idx_att_date ON attendance (att_date);

-- 코멘트
COMMENT ON TABLE  attendance                    IS '근태 기록';
COMMENT ON COLUMN attendance.att_id             IS '근태 PK (SEQ_ATTENDANCE)';
COMMENT ON COLUMN attendance.emp_id             IS '사원 FK';
COMMENT ON COLUMN attendance.att_date           IS '근무일자';
COMMENT ON COLUMN attendance.check_in           IS '출근 시각';
COMMENT ON COLUMN attendance.check_out          IS '퇴근 시각 (퇴근 전 NULL)';
COMMENT ON COLUMN attendance.work_minutes       IS '실근로시간(분) - 휴게 제외';
COMMENT ON COLUMN attendance.overtime_minutes   IS '연장근로시간(분) - 480분 초과분';
COMMENT ON COLUMN attendance.night_minutes      IS '야간근로시간(분) - 22:00~06:00 구간';
COMMENT ON COLUMN attendance.att_status         IS 'NORMAL/LATE/EARLY_LEAVE/ABSENT';
COMMENT ON COLUMN attendance.created_at         IS '레코드 생성 시각';
COMMENT ON COLUMN attendance.updated_at         IS '최종 수정 시각';



>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- ============================================
-- 결재선 즐겨찾기 테이블
-- ============================================
create table appr_line_favorite(
  fav_id number not null, -- 즐겨찾기  id
  dept_id number not null, -- 기준 부서
  for_id number not null, -- 기준 양식 ( 양식별로 하는거보다 그냥 부서별로 잡을까..)
  emp_ids varchar2(4000) not null, -- ( 결재자 empid 순서 )
  use_count number default 1 not null, -- ( 사용횟수 추천 기준 )
  constraint pk_appr_line_fav primary key (fav_id),
  constraint fk_appr_line_fav_dept foreign key (dept_id) references department (dept_id)
);

create sequence appr_line_fav_seq start with 1 increment by 1 nocache nocycle;
create index idx_fav_dept_form on appr_line_favorite (dept_id, for_id);

-- ============================================
-- 결재선 변경 요청
-- ============================================
create table appr_line_request (
  req_id           number not null, -- 변경 이력 id
  doc_id           number not null, -- 해당하는 문서 id
  lin_id           number not null, -- 결재선 id
  ori_emp_id  number not null, -- 기존 결재자 id
  new_emp_id       number, -- 신규(대결) 결재자 id
  req_emp_id     number not null, -- 변경 요청자 id
  pro_emp_id     number, -- 승인자 id
  req_reason           varchar2(500), -- 요청 사유
  req_status           varchar2(10) default 'REQ' not null, -- 요청 상태
  created_at       date default sysdate not null, -- 요청 타임스탬프
  processed_at     date, -- 승인 타임스탬프
  constraint pk_appr_line_request primary key (req_id),
  constraint fk_appr_line_request_doc1 foreign key (doc_id) references appr_doc (doc_id),
  constraint fk_appr_line_request_line1 foreign key (lin_id) references appr_line (lin_id),
  constraint fk_appr_line_request_ori_emp foreign key (ori_emp_id) references employee (emp_id),
  constraint fk_appr_line_request_new_emp foreign key (new_emp_id) references employee (emp_id),
  constraint fk_appr_line_request_req_emp foreign key (req_emp_id) references employee (emp_id),
  constraint fk_appr_line_request_por_emp foreign key (pro_emp_id) references employee (emp_id),
  constraint ck_appr_line_request_status check (req_status in ('REQ','APP','REJ'))
);
create sequence appr_lcr_seq start with 1 increment by 1 nocache nocycle;
create index idx_lcr_status on appr_line_request (req_status);
create index idx_lcr_doc on appr_line_request (doc_id);
create index idx_lcr_line on appr_line_request (lin_id); -- 특정 결재선의 대기중 조회용

-- ============================================
-- 감사 로그 테이블
-- ============================================
create table appr_log(
  log_id number not null, -- 로그 id
  doc_id number not null, -- 해당 문서 id
  ori_emp_id number not null, -- 기존 결재자 id
  act_emp_id number not null, -- 대결자(기존 결재자를 대신 결재할사람) id
  per_emp_id number not null, -- 위임 승인 관리자id
  created_at date default sysdate not null, -- 결재 생성 타임스탬프
  constraint pk_appr_audit_log primary key (log_id),
  constraint fk_appr_audit_doc foreign key (doc_id) references appr_doc (doc_id),
  constraint fk_appr_audit_original foreign key (ori_emp_id) references employee (emp_id),
  constraint fk_appr_audit_actual foreign key (act_emp_id) references employee (emp_id),
  constraint fk_audit_performed_by foreign key (per_emp_id) references employee (emp_id)
);

create sequence appr_audit_log_seq start with 1 increment by 1 nocache nocycle;
create index idx_audit_doc on appr_log (doc_id);

-- ==========================================
-- 연차 부여 이력 (leave_grant)
-- ==========================================
create table leave_grant (
  grant_id    number not null, -- 이력 id
  emp_id      number not null, -- 부여할 사원 id
  grant_days  number not null, -- 부여 날짜
  grant_type  varchar2(20) not null, -- 정기부여 REG /이월 CAR /수동조정 ADJ 세가지 예정
  granted_at  date default sysdate not null, -- 연차 부여 시간
  expire_at   date, -- 연차 소멸 시간
  reason      varchar2(200),
  constraint pk_leave_grant primary key (grant_id),
  constraint fk_leave_grant_emp foreign key (emp_id) references employee (emp_id),
  constraint ck_leave_grant_type check (grant_type in ('REG','CAR','ADJ'))
);

create sequence leave_grant_seq start with 1 increment by 1 nocache nocycle;

CREATE OR REPLACE TRIGGER leave_grant_trg
BEFORE INSERT ON leave_grant
FOR EACH ROW
BEGIN
  IF :NEW.grant_id IS NULL THEN
    SELECT leave_grant_seq.NEXTVAL INTO :NEW.grant_id FROM dual;
  END IF;
END;
/

CREATE INDEX idx_leave_grant_emp ON leave_grant (emp_id);


-- ==========================================
-- 연차 사용 신청 (leave_request) - appr_doc 1:1
-- ==========================================
CREATE TABLE leave_request (
  req_id          NUMBER NOT NULL, -- 신청 id
  doc_id          NUMBER NOT NULL, -- 문서 id
  emp_id          NUMBER NOT NULL, -- 사원 id
  start_date      DATE NOT NULL, -- 시작일
  end_date        DATE NOT NULL, -- 종료일
  requested_days  NUMBER(4,1) NOT NULL, -- 신청일
  status          VARCHAR2(20) DEFAULT 'PENDING' NOT NULL, -- 문서 요청 상태
  CONSTRAINT pk_leave_request PRIMARY KEY (req_id),
  CONSTRAINT uq_leave_request_doc UNIQUE (doc_id),
  CONSTRAINT fk_leave_request_doc
    FOREIGN KEY (doc_id) REFERENCES appr_doc (doc_id),
  CONSTRAINT fk_leave_request_emp
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id),
  CONSTRAINT ck_leave_request_status
    CHECK (status IN ('PENDING','CONFIRMED','CANCELED')),
  CONSTRAINT ck_leave_request_dates
    CHECK (end_date >= start_date)
);

CREATE SEQUENCE leave_request_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER leave_request_trg
BEFORE INSERT ON leave_request
FOR EACH ROW
BEGIN
  IF :NEW.req_id IS NULL THEN
    SELECT leave_request_seq.NEXTVAL INTO :NEW.req_id FROM dual;
  END IF;
END;
/

CREATE INDEX idx_leave_request_emp ON leave_request (emp_id);
CREATE INDEX idx_leave_request_status ON leave_request (status);


-- ==========================================
-- 연차 잔여일수 - emp_leave_balance
-- ==========================================
CREATE TABLE emp_leave_balance (
  emp_id     NUMBER NOT NULL, -- 해당 사원 id
  balance    NUMBER DEFAULT 0 NOT NULL,       -- 현재 잔여 연차일수
  updated_at DATE DEFAULT SYSDATE NOT NULL, -- 최근 갱신 시간
  CONSTRAINT pk_emp_leave_balance PRIMARY KEY (emp_id),
  CONSTRAINT fk_emp_leave_balance_emp
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

for_category varchar(20) default 'GENERAL' not null
constraint ck_appr_form_category check (for_category) in ('GENERAL', 'LEAVE'));
appr_form 테이블에 for_category 추가
-> 연차 사용 테이블이랑 엮어서 결재 기안해서 승인떨어지면 잔여일수 차감등 로직에 사용목적


>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//////////// 주석 버전 ////////////
-- ============================================
-- 채용공고
-- ============================================

CREATE TABLE recruit (
    rec_id                 NUMBER(10)      NOT NULL,                      -- PK, 시퀀스 자동 채번
    com_id                 NUMBER(10)      NOT NULL,                      -- 회사 FK
    emp_id                 NUMBER(10)      NOT NULL,                      -- 담당자(직원) FK
    rec_title              VARCHAR2(200)   NOT NULL,                      -- 공고 제목
    rec_department         VARCHAR2(100),                                 -- 모집 부서
    rec_position           VARCHAR2(100),                                 -- 모집 직무
    rec_headcount          NUMBER,                                        -- 모집 인원
    rec_employment_type    VARCHAR2(50),                                  -- 고용 형태
    rec_description        CLOB,                                          -- 공고 상세 내용
    rec_start_date         DATE,                                          -- 접수 시작일
    rec_end_date           DATE,                                          -- 접수 마감일
    rec_status             VARCHAR2(20)    DEFAULT 'OPEN' NOT NULL,       -- OPEN/CLOSED/CANCELLED
    created_at             DATE            DEFAULT SYSDATE NOT NULL,
    updated_at             DATE            DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_recruit PRIMARY KEY (rec_id),                                            -- PK 제약
    CONSTRAINT fk_recruit_com FOREIGN KEY (com_id) REFERENCES company(com_id),              -- 회사 FK 제약
    CONSTRAINT fk_recruit_emp FOREIGN KEY (emp_id) REFERENCES employee(emp_id),             -- 담당자 FK 제약
    CONSTRAINT ck_recruit_status CHECK (rec_status IN ('OPEN', 'CLOSED', 'CANCELLED'))      -- 상태값 제한
);

-- recruit 시퀀스
CREATE SEQUENCE seq_recruit START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_recruit_pk
BEFORE INSERT ON recruit
FOR EACH ROW
BEGIN
    IF :NEW.rec_id IS NULL THEN
        :NEW.rec_id := seq_recruit.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_recruit_bu
BEFORE UPDATE ON recruit
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/

-- ============================================
-- 지원자
-- ============================================

CREATE TABLE applicant (
    apct_id         NUMBER(10)      NOT NULL,                        -- PK, 시퀀스 자동 채번
    com_id          NUMBER(10)      NOT NULL,                        -- 회사 FK
    rec_id          NUMBER(10)      NOT NULL,                        -- 지원한 채용공고 FK
    apct_name       VARCHAR2(50)    NOT NULL,                        -- 지원자 이름
    apct_email      VARCHAR2(100),                                   -- 이메일
    apct_phone      VARCHAR2(20),                                    -- 연락처
    apct_status     VARCHAR2(20)    DEFAULT 'RECEIVED' NOT NULL,     -- 전형 상태
    apct_date       DATE            DEFAULT SYSDATE,                 -- 지원일
    created_at      DATE            DEFAULT SYSDATE NOT NULL,
    updated_at      DATE            DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_applicant PRIMARY KEY (apct_id),                                          -- PK 제약
    CONSTRAINT fk_applicant_com FOREIGN KEY (com_id) REFERENCES company(com_id),             -- 회사 FK 제약
    CONSTRAINT fk_applicant_recruit FOREIGN KEY (rec_id) REFERENCES recruit(rec_id),         -- 채용공고 FK 제약
    CONSTRAINT ck_applicant_status                                                           -- 전형 상태값 제한
        CHECK (
            apct_status IN (
                'RECEIVED',   -- 접수
                'SCREENING',  -- 서류심사
                'INTERVIEW',  -- 면접
                'HIRED',      -- 합격
                'REJECTED'    -- 불합격
            )
        )
);

-- applicant 채번용 시퀀스
CREATE SEQUENCE seq_applicant START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_applicant_pk
BEFORE INSERT ON applicant
FOR EACH ROW
BEGIN
    IF :NEW.apct_id IS NULL THEN
        :NEW.apct_id := seq_applicant.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_applicant_bu
BEFORE UPDATE ON applicant
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/

CREATE INDEX fk_applicant_recruit_idx ON applicant(rec_id);   -- 공고별 지원자 조회용 인덱스
CREATE INDEX idx_applicant_status ON applicant(apct_status);  -- 상태별 지원자 조회용 인덱스
CREATE INDEX idx_recruit_com_id ON recruit(com_id);           -- 회사별 공고 조회용 인덱스

-- ============================================
-- 이력서
-- ============================================

CREATE TABLE resume (
    rsm_id              NUMBER(10)      NOT NULL,                     -- PK, 시퀀스 자동 채번
    apct_id             NUMBER(10)      NOT NULL,                     -- 지원자 FK
    rsm_file_name       VARCHAR2(200),                                -- 업로드 원본 파일명
    rsm_file_url        VARCHAR2(500),                                -- 업로드 파일 경로/URL
    rsm_extracted_text  CLOB,                                         -- 파일에서 추출한 전체 텍스트
    rsm_ai_summary      CLOB,                                         -- AI가 생성한 이력서 요약
    rsm_fit_score       NUMBER,                                       -- AI가 매긴 적합도 점수
    rsm_status          VARCHAR2(20)    DEFAULT 'PENDING' NOT NULL,   -- 분석 처리 상태
    rsm_uploaded_at     DATE            DEFAULT SYSDATE NOT NULL,     -- 업로드 시각
    rsm_analyzed_at     DATE,                                         -- 분석 완료 시각

    CONSTRAINT pk_resume PRIMARY KEY (rsm_id),                                              -- PK 제약
    CONSTRAINT fk_resume_applicant FOREIGN KEY (apct_id) REFERENCES applicant(apct_id),      -- 지원자 FK 제약
    CONSTRAINT ck_resume_status                                                              -- 분석 상태값 제한
        CHECK (
            rsm_status IN (
                'PENDING',    -- 분석 대기/진행중
                'COMPLETED',  -- 분석 완료
                'FAILED'      -- 분석 실패
            )
        )
);

-- resume 시퀀스
CREATE SEQUENCE seq_resume START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_resume_pk
BEFORE INSERT ON resume
FOR EACH ROW
BEGIN
    IF :NEW.rsm_id IS NULL THEN
        :NEW.rsm_id := seq_resume.NEXTVAL;
    END IF;
END;
/

-- ============================================
-- 이력서 청크 + 임베딩
-- ============================================
-- 청크(chunk)     : 이력서 원문을 검색 가능한 단위로 잘게 쪼갠 조각
-- 임베딩(embedding): 각 청크 텍스트를 AI 임베딩 모델(text-embedding-3-small)로
--                    변환한 벡터값. 코사인 유사도 계산은 Java(애플리케이션) 레이어에서 처리
-- ============================================

CREATE TABLE resume_chunk (
    chunk_id         NUMBER(10)      NOT NULL,     -- PK, 시퀀스 자동 채번
    rsm_id           NUMBER(10)      NOT NULL,      -- 원본 이력서 FK
    chunk_order      NUMBER          NOT NULL,      -- 청크 순서 (원문 재구성/맥락 참고용)
    chunk_text       CLOB            NOT NULL,      -- 청크 원문 텍스트
    chunk_embedding  CLOB            NOT NULL,      -- 임베딩 벡터 (JSON 문자열로 저장, VECTOR 타입 미지원으로 CLOB 사용)

    CONSTRAINT pk_resume_chunk PRIMARY KEY (chunk_id),                                       -- PK 제약
    CONSTRAINT fk_chunk_resume FOREIGN KEY (rsm_id) REFERENCES resume(rsm_id)                 -- 원본 이력서 FK 제약
);

-- resume_chunk 채번용 시퀀스
CREATE SEQUENCE seq_resume_chunk START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_resume_chunk_pk
BEFORE INSERT ON resume_chunk
FOR EACH ROW
BEGIN
    IF :NEW.chunk_id IS NULL THEN
        :NEW.chunk_id := seq_resume_chunk.NEXTVAL;
    END IF;
END;
/

CREATE INDEX fk_chunk_resume_idx ON resume_chunk(rsm_id);   -- 이력서별 청크 목록 조회용 인덱스

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


## 3. 신규 테이블 상세 설명

### 3-1. `SALARY_STANDARD` (급여기준)

"이 직원은 기본급이 얼마고, 언제부터 적용되는가"를 저장하는 테이블입니다.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `STANDARD_ID` | NUMBER (PK) | 급여기준 고유번호 |
| `EMP_ID` | NUMBER (FK → EMPLOYEE) | 어떤 직원의 급여기준인지 |
| `BASE_SALARY` | NUMBER(15,2) | 기본급 |
| `ANNUAL_SALARY` | NUMBER(15,2) | 연봉계약액 (선택) |
| `START_DATE` | DATE | 적용 시작일 |
| `END_DATE` | DATE | 적용 종료일 (아직 유효하면 NULL) |
| `ACTIVE` | BOOLEAN | 현재 적용 중인 기준이면 true |
| `CREATED_AT` / `UPDATED_AT` | DATE | 생성/수정 시각 |

**왜 UPDATE 대신 새 행을 추가하는가?**
요구사항에 "연봉 인상 등으로 수정할 때 이전 값은 이력으로 보존해야 한다"는 조건이 있었습니다. 그래서
직원의 급여기준을 "수정"할 때, 기존 행을 지우거나 덮어쓰지 않고 다음처럼 처리합니다.

1. 기존 행의 `END_DATE`를 새 기준 시작일 전날로 채우고, `ACTIVE`를 `false`로 바꾼다 (= 종료 처리)
2. 새로운 값으로 행을 하나 더 INSERT하고, `ACTIVE = true`로 만든다

그 결과 한 직원의 급여기준 이력이 여러 행으로 쌓이고, "현재 적용 중인 것"은 항상 `ACTIVE = true`인
딱 1건입니다. 이런 방식을 **버저닝(versioning)** 이라고 부릅니다.

### 3-2. `SALARY_PAYMENT` (급여 지급 내역)

"이 직원이 이번 달에 얼마를 받는가"를 저장하는, 한 달치 급여 산정 결과입니다.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `PAYMENT_ID` | NUMBER (PK) | 급여지급 고유번호 |
| `EMP_ID` | NUMBER (FK → EMPLOYEE) | 누구의 급여인지 |
| `STANDARD_ID` | NUMBER (FK → SALARY_STANDARD) | 산정에 사용된 급여기준 |
| `PAYMENT_MONTH` | DATE | 지급월 (매월 1일로 저장) |
| `BASE_SALARY` | NUMBER(15,2) | 기본급 (급여기준에서 그대로 가져옴) |
| `ALLOWANCE_TOTAL` | NUMBER(15,2) | 수당 합계 |
| `DEDUCTION_TOTAL` | NUMBER(15,2) | 공제 합계 |
| `NET_PAY` | NUMBER(15,2) | 실지급액 (`기본급 + 수당 - 공제`) |
| `STATUS` | VARCHAR2(20) | 지급 상태: `PENDING`(대기) → `APPROVED`(승인) → `PAID`(지급완료), 또는 `REJECTED`(반려) |
| `REJECT_REASON` | VARCHAR2(500) | 반려 사유 (반려된 경우만) |
| `PAID_AT` | DATE | 실제 지급완료 처리된 시각 |
| `CREATED_AT` / `UPDATED_AT` | DATE | 생성/수정 시각 |

**상태(STATUS)는 아무렇게나 바뀌지 않습니다.** 코드에서 아래 순서만 허용합니다.

```
PENDING(대기) ──▶ APPROVED(승인) ──▶ PAID(지급완료)
      │                  │
      └──────────────────┴──▶ REJECTED(반려)
```

그리고 `PAID`(지급완료) 상태가 된 급여는 **수정도 삭제도 불가능**합니다. 이미 나간 돈이기 때문입니다.

### 3-3. `SALARY_PAYMENT_ITEM` (수당/공제 세부 항목)

급여 하나에는 "식대 10만원", "국민연금 -20만원" 처럼 여러 개의 수당/공제 항목이 붙습니다.
이 항목들을 한 줄씩 저장하는 테이블입니다. `SALARY_PAYMENT` 한 건에 여러 개가 딸려있는 구조(1:N)입니다.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ITEM_ID` | NUMBER (PK) | 항목 고유번호 |
| `PAYMENT_ID` | NUMBER (FK → SALARY_PAYMENT) | 어느 급여 지급 건에 속하는지 |
| `ITEM_CODE` | VARCHAR2(30) | 사전 정의된 항목 코드 (예: `MEAL_ALLOWANCE`, `NATIONAL_PENSION`) — 아래 3-3-1 참고 |
| `AMOUNT` | NUMBER(15,2) | 금액 (관리자가 입력) |

`SALARY_PAYMENT.ALLOWANCE_TOTAL`/`DEDUCTION_TOTAL`은 이 테이블의 항목들을 타입별로 더한 값입니다.

#### 3-3-1. 항목명을 자유 입력이 아니라 "미리 정해진 목록"에서 고르는 방식으로 설계했습니다

처음에는 `ITEM_TYPE`(수당/공제) + `ITEM_NAME`(자유 텍스트, 예: "식대")을 관리자가 직접 타이핑하는
구조였습니다. 하지만 신입 개발자들과 함께 작업하기엔 매번 오탈자·중복 항목명(`"식대"` vs `"식비"`) 문제가
생기기 쉬워서, **`SalaryItemCode`라는 enum(자바 코드에 미리 박아둔 값 목록)** 방식으로 바꿨습니다.

```java
public enum SalaryItemCode {
    MEAL_ALLOWANCE(ALLOWANCE, "식대"),
    POSITION_ALLOWANCE(ALLOWANCE, "직책수당"),
    ANNUAL_LEAVE_ALLOWANCE(ALLOWANCE, "연차수당"),
    NATIONAL_PENSION(DEDUCTION, "국민연금"),
    HEALTH_INSURANCE(DEDUCTION, "건강보험"),
    LONG_TERM_CARE_INSURANCE(DEDUCTION, "장기요양보험료"),
    EMPLOYMENT_INSURANCE(DEDUCTION, "고용보험"),
    INCOME_TAX(DEDUCTION, "소득세"),
    LOCAL_INCOME_TAX(DEDUCTION, "지방소득세");
    // 코드마다 "수당인지 공제인지"와 "화면에 보여줄 한글 이름"이 이미 정해져 있음
}
```

관리자는 급여를 등록할 때 이 목록 중에서 항목을 **선택**하고 **금액만** 입력합니다. 프론트엔드가
`GET /api/salary-payments/item-codes`를 호출하면 선택 가능한 전체 목록(코드/타입/한글명)을 받을 수
있어서, 이 목록으로 드롭다운(select)을 만들면 됩니다. 새 항목이 필요해지면 이 enum에 한 줄만 추가하면
되고, DB 테이블 구조를 바꿀 필요는 없습니다(`ITEM_CODE`는 그냥 문자열 컬럼입니다).

#### 3-3-2. 왜 이 9개만 골랐는가 (업로드해주신 급여명세서 기준)

업로드해주신 실제 급여명세서에는 훨씬 많은 항목(식대, 직책수당, 고정연장수당, 연차수당, 자가운전수당,
육아수당, 원격지수당, 강의수당, 추천수당, 인센티브, 자격수당, 추가지급, 기타수당, 그외수당 / 국민연금,
건강보험, 건강보험정산, 장기요양보험료, 장기요양보험정산, 고용보험, 동호회비, 소득세, 지방소득세, 원금,
이자, 확정급여공제, 기타공제)이 있었습니다. 전부 한 번에 구현하기엔 신입 개발자 팀에게 부담이 커서,
아래 기준으로 **9개만 1차로 선정**했습니다.

| 구분 | 선정 항목 | 선정 이유 |
|---|---|---|
| 수당 | 식대, 직책수당, 연차수당 | 대부분의 회사에서 표준적으로 쓰이고, 계산 로직이 단순(금액을 그대로 더하기)합니다. 특히 연차수당은 앞으로 추가될 연차관리 모듈과 바로 연결될 항목이라 먼저 넣어뒀습니다. |
| 공제 | 국민연금, 건강보험, 장기요양보험료, 고용보험, 소득세, 지방소득세 | 법으로 정해진 4대보험 + 세금이라 사실상 모든 회사에 필수입니다. 이 6개가 없으면 "진짜 급여명세서" 역할을 하기 어렵습니다. |

**1차에서 제외한 항목과 이유**

| 제외 항목 | 제외 이유 |
|---|---|
| 기타수당, 그외수당, 기타공제 | 사용자 요청으로 제외(용도가 모호한 캐치올 항목) |
| 고정연장수당 | 초과근무 시간 계산이 필요한데, 근태관리 모듈이 아직 없어서 계산 근거가 없음 |
| 자가운전수당, 원격지수당, 강의수당, 추천수당, 자격수당 | 특정 직군/조건에만 해당되는 회사 정책성 항목이라 전 직원 공통 MVP엔 우선순위가 낮음 |
| 인센티브, 추가지급 | 금액 산정 기준이 회사 정책/평가에 따라 달라 별도 기획이 필요함 |
| 육아수당 | 자격 요건(육아휴직 등) 검증 로직이 필요해서 별도 설계가 필요함 |
| 동호회비 | 회사 복지 정책에 따라 있고 없고가 갈리는 항목 |
| 원금, 이자 | 사내 대출 제도가 있어야 의미가 있는 항목이라, 사실상 "사내 대출" 서브시스템이 별도로 필요함 |
| 확정급여공제 | 퇴직연금(DB형) 관련 항목으로 계산이 복잡하고 별도 정산 주기를 가짐 |
| 건강보험정산, 장기요양보험정산 | 연말정산성 "정산" 항목이라 매달 발생하지 않고 별도 로직이 필요함 |

이 표에 없는 항목이 나중에 필요해지면 `SalaryItemCode`에 값을 추가하기만 하면 되므로, 지금 9개만으로
시작해도 구조상 손해 볼 게 없습니다.

### 3-4. `SALARY_CHANGE_HISTORY` (급여 변경 이력)

급여기준이나 급여지급이 등록/수정/삭제/상태변경될 때마다 **자동으로** 한 줄씩 쌓이는 로그 테이블입니다.
"누가, 언제, 무엇을, 어떻게 바꿨는지"를 기록해서 나중에 감사(audit)할 때 씁니다.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `HISTORY_ID` | NUMBER (PK) | 이력 고유번호 |
| `ACTOR_EMP_ID` | NUMBER | 변경을 실행한 관리자의 EMP_ID |
| `ACTOR_NAME` | VARCHAR2(100) | 변경을 실행한 관리자 이름 (스냅샷) |
| `TARGET_EMP_ID` | NUMBER | 변경 대상이 된 직원의 EMP_ID |
| `COM_ID` | NUMBER | 대상 직원의 소속 회사 (조회 범위 제한용, 5장 참고) |
| `DOMAIN_TYPE` | VARCHAR2(30) | `SALARY_STANDARD`(급여기준) 또는 `SALARY_PAYMENT`(급여지급) 중 무엇에 대한 이력인지 |
| `TARGET_ID` | NUMBER | 변경된 행의 PK (STANDARD_ID 또는 PAYMENT_ID) |
| `CHANGE_TYPE` | VARCHAR2(20) | `CREATE`/`UPDATE`/`DELETE`/`STATUS_CHANGE` |
| `BEFORE_VALUE` | CLOB | 변경 전 값 (JSON 텍스트) |
| `AFTER_VALUE` | CLOB | 변경 후 값 (JSON 텍스트) |
| `DESCRIPTION` | VARCHAR2(500) | 사람이 읽기 쉬운 설명 |
| `CREATED_AT` | DATE | 기록 시각 |

**이 테이블은 사람이 직접 등록/수정/삭제하지 않습니다.** 코드에도 그런 API 자체가 없습니다.
`SalaryStandardService`, `SalaryPaymentService`가 등록/수정/삭제/상태변경을 처리할 때마다 내부적으로
`SalaryChangeHistoryService.record(...)`를 호출해서 자동으로 한 줄씩 남기는 구조입니다. 그래서
"이력이 하나 빠졌다"는 일이 생길 수 없습니다(코드 흐름상 반드시 같이 기록되도록 짜여 있습니다).
