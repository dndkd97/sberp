-- ============================================
-- 채용공고
-- ============================================

CREATE TABLE recruit (
    rec_id                 NUMBER(10)      NOT NULL,
    com_id                 NUMBER(10)      NOT NULL,
    emp_id                 NUMBER(10)      NOT NULL,
    rec_title              VARCHAR2(200)   NOT NULL,
    rec_department         VARCHAR2(100)   NOT NULL,
    rec_position            VARCHAR2(100)   NOT NULL,
    rec_headcount           NUMBER          NOT NULL,
    rec_employment_type     VARCHAR2(50)    NOT NULL,
    rec_description         CLOB,
    rec_start_date           DATE            NOT NULL,
    rec_end_date             DATE,
    rec_status               VARCHAR2(20)    DEFAULT 'OPEN' NOT NULL,
    created_at               DATE            DEFAULT SYSDATE NOT NULL,
    updated_at               DATE            DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_recruit PRIMARY KEY (rec_id),
    CONSTRAINT fk_recruit_com FOREIGN KEY (com_id) REFERENCES company(com_id),
    CONSTRAINT fk_recruit_emp FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT ck_recruit_status CHECK (rec_status IN ('OPEN', 'CLOSED', 'CANCELLED'))
);

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
-- 지원자 등록/관리
-- ============================================

CREATE TABLE applicant (
    apct_id         NUMBER(10)      NOT NULL,
    com_id          NUMBER(10)      NOT NULL,
    rec_id          NUMBER(10)      NOT NULL,
    apct_name       VARCHAR2(50)    NOT NULL,
    apct_email      VARCHAR2(100)   NOT NULL,
    apct_phone      VARCHAR2(20)    NOT NULL,
    apct_status     VARCHAR2(20)    DEFAULT 'RECEIVED' NOT NULL,
    apct_date       DATE            DEFAULT SYSDATE,
    created_at      DATE            DEFAULT SYSDATE NOT NULL,
    updated_at      DATE            DEFAULT SYSDATE NOT NULL,

    CONSTRAINT pk_applicant PRIMARY KEY (apct_id),
    CONSTRAINT fk_applicant_com FOREIGN KEY (com_id) REFERENCES company(com_id),
    CONSTRAINT fk_applicant_recruit FOREIGN KEY (rec_id) REFERENCES recruit(rec_id),
    CONSTRAINT ck_applicant_status
        CHECK (
            apct_status IN (
                'RECEIVED',
                'SCREENING',
                'INTERVIEW',
                'HIRED',
                'REJECTED'
            )
        )
);

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

CREATE INDEX fk_applicant_recruit_idx ON applicant(rec_id);
CREATE INDEX idx_applicant_status ON applicant(apct_status);
CREATE INDEX idx_recruit_com_id ON recruit(com_id);


-- ============================================
-- 이력서
-- ============================================

CREATE TABLE resume (
    rsm_id              NUMBER(10)      NOT NULL,
    apct_id             NUMBER(10)      NOT NULL,
    rsm_file_name       VARCHAR2(200),
    rsm_file_url        VARCHAR2(500),
    rsm_extracted_text  CLOB,
    rsm_ai_summary      CLOB,
    rsm_fit_score       NUMBER,
    rsm_status          VARCHAR2(20)    DEFAULT 'PENDING' NOT NULL,
    rsm_uploaded_at     DATE            DEFAULT SYSDATE NOT NULL,
    rsm_analyzed_at     DATE,

    CONSTRAINT pk_resume PRIMARY KEY (rsm_id),
    CONSTRAINT fk_resume_applicant FOREIGN KEY (apct_id) REFERENCES applicant(apct_id),
    CONSTRAINT ck_resume_status CHECK (rsm_status IN ('PENDING', 'COMPLETED', 'FAILED'))
);

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

CREATE TABLE resume_chunk (
    chunk_id         NUMBER(10)      NOT NULL,
    rsm_id           NUMBER(10)      NOT NULL,
    chunk_order      NUMBER          NOT NULL,
    chunk_text       CLOB            NOT NULL,
    chunk_embedding  CLOB            NOT NULL,

    CONSTRAINT pk_resume_chunk PRIMARY KEY (chunk_id),
    CONSTRAINT fk_chunk_resume FOREIGN KEY (rsm_id) REFERENCES resume(rsm_id)
);

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

CREATE INDEX fk_chunk_resume_idx ON resume_chunk(rsm_id);