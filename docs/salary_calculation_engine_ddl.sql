--------------------------------------------------------------------------------
-- 급여 산정 엔진(SalaryCalculationService) 신규 테이블 DDL
-- salary-calculation-engine-design.md 참고
--
-- DROP -> CREATE 형식: 기존에 테이블/시퀀스/트리거/인덱스가 있어도 없어도 에러 없이 재실행 가능하다.
-- (sal_std 등 기존 sal 모듈 테이블과 동일한 관례: created_at은 애플리케이션이 아니라 DB 트리거가 채운다
--  -> 엔티티에서는 insertable=false 로만 매핑한다.)
--
-- 컬럼명은 언더스코어로 구분된 조각마다 5자를 넘지 않도록 축약했다.
-- (policy -> plcy, pension -> pens, health -> hlth, employment -> empl, effective -> eff,
--  created -> creat, bracket -> brkt, amount -> amt, position -> pos - 프로젝트 기존 관례인
--  Position 엔티티의 pos_code/pos_name, SalPayItem.amt 와 동일한 축약을 재사용했다.)
--
-- 대상 테이블 4개
--   1) sal_rate_plcy            4대보험 요율 정책 (com_id 없음, 전국 공통)
--   2) sal_pos_alw     직책별 수당 정책 (com_id + pos 스코프)
--   3) sal_inc_tax_brkt     소득세 간이 구간표 (com_id 없음, 전국 공통 근사치)
--   4) sal_meal_alw_plcy  식대 정책 (com_id nullable, NULL = 전사 공통 fallback)
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 1) sal_rate_plcy
--------------------------------------------------------------------------------

-- DROP (있으면 삭제, 없어도 에러 없음)
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_rate_plcy_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_rate_plcy CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_rate_plcy_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- CREATE
CREATE TABLE sal_rate_plcy (
    rate_id      NUMBER(19)   NOT NULL,
    plcy_year    NUMBER(4)    NOT NULL,
    pens_rate    NUMBER(5,4)  NOT NULL,
    hlth_rate    NUMBER(5,4)  NOT NULL,
    care_rate    NUMBER(5,4)  NOT NULL,
    empl_rate    NUMBER(5,4)  NOT NULL,
    eff_from     DATE         NOT NULL,
    eff_to       DATE,
    created_at     DATE         NOT NULL,
    CONSTRAINT pk_sal_rate_plcy PRIMARY KEY (rate_id)
);

CREATE SEQUENCE sal_rate_plcy_seq
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 한 시점에 "현재 유효(eff_to IS NULL)" 요율 정책은 전국에 1건만 존재해야 한다.
BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX ux_sal_rate_plcy_open';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN RAISE; END IF;
END;
/

CREATE UNIQUE INDEX ux_sal_rate_plcy_open
    ON sal_rate_plcy (CASE WHEN eff_to IS NULL THEN 1 END);

-- created_at은 애플리케이션이 아니라 DB 트리거가 채운다(엔티티에서 insertable=false).
CREATE TRIGGER trg_sal_rate_plcy_ins
BEFORE INSERT ON sal_rate_plcy
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
END;
/


--------------------------------------------------------------------------------
-- 2) sal_pos_alw
--------------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_pos_alw_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_pos_alw CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_pos_alw_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

CREATE TABLE sal_pos_alw (
    alw_id       NUMBER(19)    NOT NULL,
    pos          VARCHAR2(30)  NOT NULL,
    com_id       NUMBER(19)    NOT NULL,
    amt          NUMBER(15)    NOT NULL,
    eff_from     DATE          NOT NULL,
    eff_to       DATE,
    created_at     DATE          NOT NULL,
    CONSTRAINT pk_sal_pos_alw PRIMARY KEY (alw_id),
    CONSTRAINT fk_sal_pos_alw_com FOREIGN KEY (com_id) REFERENCES company (com_id)
);

CREATE SEQUENCE sal_pos_alw_seq
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 동일 회사(com_id) + 동일 직책(pos) 조합의 "현재 유효" 정책은 1건만 존재해야 한다.
BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX ux_sal_pos_alw_open';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN RAISE; END IF;
END;
/

CREATE UNIQUE INDEX ux_sal_pos_alw_open
    ON sal_pos_alw (com_id, pos, CASE WHEN eff_to IS NULL THEN 1 END);

CREATE TRIGGER trg_sal_pos_alw_ins
BEFORE INSERT ON sal_pos_alw
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
END;
/


--------------------------------------------------------------------------------
-- 3) sal_inc_tax_brkt
--------------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_inc_tax_brkt_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_inc_tax_brkt CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_inc_tax_brkt_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

CREATE TABLE sal_inc_tax_brkt (
    brkt_id      NUMBER(19)   NOT NULL,
    min_amt      NUMBER(15)   NOT NULL,
    max_amt      NUMBER(15),
    tax_rate     NUMBER(5,4)  NOT NULL,
    eff_from     DATE         NOT NULL,
    eff_to       DATE,
    created_at     DATE         NOT NULL,
    CONSTRAINT pk_sal_inc_tax_brkt PRIMARY KEY (brkt_id)
);

CREATE SEQUENCE sal_inc_tax_brkt_seq
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 참고: 이 테이블은 sal_rate_plcy/sal_pos_alw와 달리 한 시점에 여러 구간(행)이
-- 동시에 유효해야 하므로(min~max 범위별) "현재 유효 1건" 유니크 인덱스를 두지 않는다.
-- 연도가 바뀌면 관리자가 기존 구간표 전체의 eff_to를 갱신하고 새 구간표를 등록한다.

CREATE TRIGGER trg_sal_inc_tax_brkt_ins
BEFORE INSERT ON sal_inc_tax_brkt
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
END;
/


--------------------------------------------------------------------------------
-- 4) sal_meal_alw_plcy
--------------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sal_meal_alw_plcy_ins';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sal_meal_alw_plcy CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE sal_meal_alw_plcy_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

CREATE TABLE sal_meal_alw_plcy (
    meal_plcy_id  NUMBER(19)  NOT NULL,
    com_id        NUMBER(19),                  -- NULL = 전사 공통 기본값(fallback)
    amt           NUMBER(15)  NOT NULL,
    eff_from      DATE        NOT NULL,
    eff_to        DATE,
    created_at      DATE        NOT NULL,
    CONSTRAINT pk_sal_meal_alw_plcy PRIMARY KEY (meal_plcy_id),
    CONSTRAINT fk_sal_meal_alw_plcy_com FOREIGN KEY (com_id) REFERENCES company (com_id)
);

CREATE SEQUENCE sal_meal_alw_plcy_seq
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 동일 com_id(NULL=전사 공통 포함)의 "현재 유효" 정책은 1건만 존재해야 한다.
BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX ux_sal_meal_alw_plcy_open';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN RAISE; END IF;
END;
/

CREATE TRIGGER trg_sal_meal_alw_plcy_ins
BEFORE INSERT ON sal_meal_alw_plcy
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSDATE;
END;
/


-- 닫힌 행(eff_to 존재)은 표현식 자체가 NULL -> 인덱스에서 완전히 제외
-- 열린 행(eff_to IS NULL)만 com_id 기준으로 유니크 체크
CREATE UNIQUE INDEX ux_sal_meal_alw_plcy_open
    ON sal_meal_alw_plcy (
        CASE WHEN eff_to IS NULL THEN TO_CHAR(com_id) END
    );