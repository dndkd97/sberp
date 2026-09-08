-- ============================================================
-- 급여기준 (SalStd) — 요구사항 6. 급여기준 관리
-- 이력 보존을 위해 UPDATE 대신 버저닝(기존 행 종료 + 새 행 추가) 방식을 쓴다.
-- 금액 컬럼은 BigDecimal이 아니라 Long으로 다루므로 소수점 없는 NUMBER(15)로 정의한다(원화는 소수단위 없음).
--
-- DROP → CREATE 형식: 기존에 테이블/시퀀스/트리거가 있어도 없어도 에러 없이 재실행 가능하다
-- (DROP 대상이 존재하지 않을 때 나는 Oracle 에러 코드만 무시하고, 그 외 에러는 그대로 올린다).
-- ============================================================

-- 트리거 DROP (없으면 ORA-04080 무시)
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_std_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_std_upd';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

-- 테이블 DROP (없으면 ORA-00942 무시). CASCADE CONSTRAINTS로 다른 테이블(sal_pay)이 걸어둔 FK도 함께 정리한다.
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_std CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 시퀀스 DROP (없으면 ORA-02289 무시)
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_std_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- ============================================================
-- CREATE
-- ============================================================

CREATE TABLE sal_std (
    std_id      NUMBER          NOT NULL,
    emp_id      NUMBER          NOT NULL,
    base_sal    NUMBER(15)      NOT NULL,
    annu_sal    NUMBER(15),
    start_date  DATE            NOT NULL,
    end_date    DATE,
    actv        NUMBER(1)       DEFAULT 1 NOT NULL,
    created_at  DATE            NOT NULL,
    updated_at  DATE            NOT NULL,
    CONSTRAINT pk_sal_std PRIMARY KEY (std_id),
    CONSTRAINT fk_sal_std_emp FOREIGN KEY (emp_id) REFERENCES employee (emp_id),
    CONSTRAINT ck_sal_std_actv CHECK (actv IN (0, 1))
);

CREATE SEQUENCE sal_std_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE INDEX ix_sal_std_emp ON sal_std (emp_id);

-- 특정 시점 기준 직원당 활성(actv=1) 급여기준은 최대 1건이어야 한다.
-- Oracle은 CREATE INDEX에 WHERE 절을 지원하지 않으므로, actv=0인 행은 함수식이 NULL이 되게 해서
-- 유니크 인덱스가 NULL을 무시하는 특성을 이용한다(actv=1인 행만 emp_id 유일성 검증).
CREATE UNIQUE INDEX ux_sal_std_emp_actv
    ON sal_std (CASE WHEN actv = 1 THEN emp_id END);

-- created_at/updated_at은 애플리케이션이 아니라 DB 트리거가 채운다(엔티티에서 insertable=false).
CREATE TRIGGER trg_sal_std_ins
BEFORE INSERT ON sal_std
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
    :NEW.updated_at := SYSDATE;
END;
/

CREATE TRIGGER trg_sal_std_upd
BEFORE UPDATE ON sal_std
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/


-- ============================================================
-- 급여 지급 (SalPay) — 요구사항 7. 급여 지급 관리
-- 상태: PENDING → APPROVED → PAID / REJECTED (담당자가 직접 처리, 전자결재 미연동)
-- 금액 컬럼은 BigDecimal이 아니라 Long으로 다루므로 소수점 없는 NUMBER(15)로 정의한다(원화는 소수단위 없음).
-- bank_name/acct_no/hldr_name: sal_acct(급여 수령 계좌)의 지급 시점 스냅샷(2026-08-20 추가). FK 아님(값만 복사).
--
-- DROP → CREATE 형식: 기존에 테이블/시퀀스/트리거가 있어도 없어도 에러 없이 재실행 가능하다.
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_pay_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_pay_upd';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

-- CASCADE CONSTRAINTS로 sal_pay_item이 걸어둔 FK도 함께 정리한다.
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_pay CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_pay_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- ============================================================
-- CREATE
-- ============================================================

CREATE TABLE sal_pay (
    pay_id       NUMBER          NOT NULL,
    emp_id       NUMBER          NOT NULL,
    std_id       NUMBER,
    pay_month    DATE            NOT NULL,
    base_sal     NUMBER(15)      NOT NULL,
    allow_total  NUMBER(15)      NOT NULL,
    dedt_total   NUMBER(15)      NOT NULL,
    net_pay      NUMBER(15)      NOT NULL,
    stat         VARCHAR2(20)    NOT NULL,
    rej_rsn      VARCHAR2(500),
    paid_at      DATE,
    bank_name    VARCHAR2(50),
    acct_no      VARCHAR2(30),
    hldr_name    VARCHAR2(50),
    created_at   DATE            NOT NULL,
    updated_at   DATE            NOT NULL,
    CONSTRAINT pk_sal_pay PRIMARY KEY (pay_id),
    CONSTRAINT fk_sal_pay_emp FOREIGN KEY (emp_id) REFERENCES employee (emp_id),
    CONSTRAINT fk_sal_pay_std FOREIGN KEY (std_id) REFERENCES sal_std (std_id),
    CONSTRAINT ck_sal_pay_stat CHECK (stat IN ('PENDING', 'APPROVED', 'PAID', 'REJECTED'))
);

CREATE SEQUENCE sal_pay_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE INDEX ix_sal_pay_emp ON sal_pay (emp_id);
CREATE INDEX ix_sal_pay_std ON sal_pay (std_id);
CREATE INDEX ix_sal_pay_month ON sal_pay (pay_month);

CREATE TRIGGER trg_sal_pay_ins
BEFORE INSERT ON sal_pay
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
    :NEW.updated_at := SYSDATE;
END;
/

CREATE TRIGGER trg_sal_pay_upd
BEFORE UPDATE ON sal_pay
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/


-- ============================================================
-- 급여 지급 세부 항목 (SalPayItem) — 수당/공제 (SalaryItemCode 카탈로그에서 선택)
-- created_at/updated_at 없음(부모 sal_pay 저장 시점에 함께 생성/삭제되는 종속 데이터).
-- 금액 컬럼은 BigDecimal이 아니라 Long으로 다루므로 소수점 없는 NUMBER(15)로 정의한다(원화는 소수단위 없음).
--
-- DROP → CREATE 형식: 기존에 테이블/시퀀스가 있어도 없어도 에러 없이 재실행 가능하다.
-- (이 테이블에는 트리거가 없다 — created_at/updated_at 컬럼 자체가 없기 때문)
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_pay_item CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_pay_item_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- ============================================================
-- CREATE
-- ============================================================

CREATE TABLE sal_pay_item (
    item_id    NUMBER          NOT NULL,
    pay_id     NUMBER          NOT NULL,
    item_code  VARCHAR2(30)    NOT NULL,
    amt        NUMBER(15)      NOT NULL,
    CONSTRAINT pk_sal_pay_item PRIMARY KEY (item_id),
    CONSTRAINT fk_sal_pay_item_pay FOREIGN KEY (pay_id) REFERENCES sal_pay (pay_id) ON DELETE CASCADE
);

CREATE SEQUENCE sal_pay_item_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE INDEX ix_sal_pay_item_pay ON sal_pay_item (pay_id);

-- ============================================================
-- 급여 변경이력 (SalHist) — 요구사항 8. 급여 변경이력 관리
-- insert-only. 사람이 직접 등록/수정/삭제하지 않으며 시스템이 CUD 시점마다 자동 기록한다.
--
-- DROP → CREATE 형식: 기존에 테이블/시퀀스/트리거가 있어도 없어도 에러 없이 재실행 가능하다.
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_hist_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_hist CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_hist_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- ============================================================
-- CREATE
-- ============================================================

CREATE TABLE sal_hist (
    hist_id       NUMBER          NOT NULL,
    actor_emp_id  NUMBER          NOT NULL,
    actor_name    VARCHAR2(100),
    trgt_emp_id   NUMBER,
    com_id        NUMBER,
    dom_type      VARCHAR2(30)    NOT NULL,
    trgt_id       NUMBER          NOT NULL,
    chg_type      VARCHAR2(20)    NOT NULL,
    bfr_val       CLOB,
    aft_val       CLOB,
    descr         VARCHAR2(2000),
    created_at    DATE            NOT NULL,
    CONSTRAINT pk_sal_hist PRIMARY KEY (hist_id),
    CONSTRAINT ck_sal_hist_dom CHECK (dom_type IN ('SALARY_STANDARD', 'SALARY_PAYMENT', 'SALARY_ACCOUNT')),
    CONSTRAINT ck_sal_hist_chg CHECK (chg_type IN ('CREATE', 'UPDATE', 'DELETE', 'STATUS_CHANGE', 'MANUAL_ADJUST'))
);

CREATE SEQUENCE sal_hist_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE INDEX ix_sal_hist_actor ON sal_hist (actor_emp_id);
CREATE INDEX ix_sal_hist_trgt ON sal_hist (trgt_emp_id);
CREATE INDEX ix_sal_hist_com ON sal_hist (com_id);

-- created_at만 있고 updated_at은 없음(수정 자체가 불가능한 insert-only 테이블이므로).
CREATE TRIGGER trg_sal_hist_ins
BEFORE INSERT ON sal_hist
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
END;
/


-- ============================================================
-- 급여 수령 계좌 (SalAcct) — 직원당 1건
-- Employee(emp 모듈)에는 계좌 컬럼이 없고 손댈 수 없으므로 sal 모듈 전용 테이블로 별도 관리한다.
-- 계좌 변경 이력은 sal_hist(SALARY_ACCOUNT)로 남고, 지급 시점 계좌 값은 sal_pay에 스냅샷으로 남는다.
--
-- DROP → CREATE 형식: 기존에 테이블/시퀀스/트리거가 있어도 없어도 에러 없이 재실행 가능하다.
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_acct_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_acct_upd';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_acct CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_acct_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- ============================================================
-- CREATE
-- ============================================================

CREATE TABLE sal_acct (
    acct_id      NUMBER          NOT NULL,
    emp_id       NUMBER          NOT NULL,
    bank_name    VARCHAR2(50)    NOT NULL,
    acct_no      VARCHAR2(30)    NOT NULL,
    hldr_name    VARCHAR2(50)    NOT NULL,
    created_at   DATE            NOT NULL,
    updated_at   DATE            NOT NULL,
    CONSTRAINT pk_sal_acct PRIMARY KEY (acct_id),
    CONSTRAINT fk_sal_acct_emp FOREIGN KEY (emp_id) REFERENCES employee (emp_id),
    CONSTRAINT uk_sal_acct_emp UNIQUE (emp_id)
);

CREATE SEQUENCE sal_acct_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TRIGGER trg_sal_acct_ins
BEFORE INSERT ON sal_acct
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
    :NEW.updated_at := SYSDATE;
END;
/

CREATE TRIGGER trg_sal_acct_upd
BEFORE UPDATE ON sal_acct
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/
