-- ============================================
-- ATTENDANCE 테이블 DDL (수정)
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
                                        'NORMAL', 'LATE', 'EARLY_LEAVE', 'ABSENT',
                                        'ANNUAL', 'AM_HALF', 'PM_HALF'
                                    ))
);

-- 인덱스: 기간별 조회 성능
CREATE INDEX idx_att_date ON attendance (att_date);

-- 코멘트
COMMENT ON TABLE  attendance                    IS '근태 기록';
COMMENT ON COLUMN attendance.att_id             IS '근태 PK (SEQ_ATTENDANCE)';
COMMENT ON COLUMN attendance.emp_id             IS '사원 FK';
COMMENT ON COLUMN attendance.att_date           IS '근무일자';
COMMENT ON COLUMN attendance.check_in           IS '출근 시각 (연차 시 NULL)';
COMMENT ON COLUMN attendance.check_out          IS '퇴근 시각 (퇴근 전 또는 연차 시 NULL)';
COMMENT ON COLUMN attendance.work_minutes       IS '실근로시간(분) - 휴게 제외';
COMMENT ON COLUMN attendance.overtime_minutes   IS '연장근로시간(분) - 480분 초과분';
COMMENT ON COLUMN attendance.night_minutes      IS '야간근로시간(분) - 22:00~06:00 구간';
COMMENT ON COLUMN attendance.att_status         IS 'NORMAL/LATE/EARLY_LEAVE/ABSENT/ANNUAL/AM_HALF/PM_HALF';
COMMENT ON COLUMN attendance.created_at         IS '레코드 생성 시각';
COMMENT ON COLUMN attendance.updated_at         IS '최종 수정 시각';


-- ============================================
-- LEAVE_BALANCE 테이블 DDL (신규)
-- ============================================

CREATE SEQUENCE SEQ_LEAVE_BALANCE
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE TABLE leave_balance (
    balance_id      NUMBER          NOT NULL,
    emp_id          NUMBER          NOT NULL,
    year            NUMBER          NOT NULL,
    total_days      NUMBER(5,2)     DEFAULT 0,
    used_days       NUMBER(5,2)     DEFAULT 0,
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,

    CONSTRAINT pk_leave_balance         PRIMARY KEY (balance_id),
    CONSTRAINT uk_leave_balance_year    UNIQUE (emp_id, year),
    CONSTRAINT fk_leave_balance_emp     FOREIGN KEY (emp_id)
                                        REFERENCES employee (emp_id),
    CONSTRAINT ck_leave_used_days       CHECK (used_days >= 0),
    CONSTRAINT ck_leave_total_days      CHECK (total_days >= 0)
);

CREATE INDEX idx_leave_balance_emp ON leave_balance (emp_id);

COMMENT ON TABLE  leave_balance                 IS '연차 잔여 관리 (연도별)';
COMMENT ON COLUMN leave_balance.balance_id      IS '잔여 PK (SEQ_LEAVE_BALANCE)';
COMMENT ON COLUMN leave_balance.emp_id          IS '사원 FK';
COMMENT ON COLUMN leave_balance.year            IS '적용 연도';
COMMENT ON COLUMN leave_balance.total_days      IS '발생 일수 (leave_grant 합산)';
COMMENT ON COLUMN leave_balance.used_days       IS '사용 일수 (결재 승인 시 차감)';
COMMENT ON COLUMN leave_balance.created_at      IS '레코드 생성 시각';
COMMENT ON COLUMN leave_balance.updated_at      IS '최종 수정 시각';


-- ============================================
-- LEAVE_GRANT 테이블 DDL (팀 설계 기반)
-- ============================================

CREATE SEQUENCE SEQ_LEAVE_GRANT
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE TABLE leave_grant (
    grant_id        NUMBER          NOT NULL,
    emp_id          NUMBER          NOT NULL,
    grant_days      NUMBER(5,2)     NOT NULL,
    grant_type      VARCHAR2(20)    NOT NULL,
    granted_at      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    expire_at       DATE,
    reason          VARCHAR2(200),

    CONSTRAINT pk_leave_grant           PRIMARY KEY (grant_id),
    CONSTRAINT fk_leave_grant_emp       FOREIGN KEY (emp_id)
                                        REFERENCES employee (emp_id),
    CONSTRAINT ck_leave_grant_type      CHECK (grant_type IN ('REG', 'CAR', 'ADJ'))
);

CREATE INDEX idx_leave_grant_emp ON leave_grant (emp_id);

COMMENT ON TABLE  leave_grant                   IS '연차 부여 이력';
COMMENT ON COLUMN leave_grant.grant_id          IS '부여 PK (SEQ_LEAVE_GRANT)';
COMMENT ON COLUMN leave_grant.emp_id            IS '사원 FK';
COMMENT ON COLUMN leave_grant.grant_days        IS '부여 일수';
COMMENT ON COLUMN leave_grant.grant_type        IS 'REG(정기부여) / CAR(이월) / ADJ(수동조정)';
COMMENT ON COLUMN leave_grant.granted_at        IS '부여 시각';
COMMENT ON COLUMN leave_grant.expire_at         IS '소멸 시한';
COMMENT ON COLUMN leave_grant.reason            IS '부여 사유';
