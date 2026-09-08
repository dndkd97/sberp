-- ============================================================
-- HR 규정 AI 챗봇(RAG) DDL — 신규 테이블 3개
-- emp 도메인
--
-- sal_plcy_doc / sal_plcy_chunk / sal_ai_chat_log 구조를 HR 도메인용으로 복제함
-- 급여 챗봇과 동일한 RAG 파이프라인을 사용하되, 도메인 스코프만 HR 규정으로 분리함
--
-- DROP → CREATE 형식: 기존에 테이블/시퀀스가 있어도 없어도 에러 없이 재실행 가능
-- created_at/updated_at은 JPA @PrePersist/@PreUpdate가 채움 (DB 트리거 사용 안 함)
-- ============================================================

-- ************************************************************
-- 1) hr_plcy_doc  — HR 규정 문서 메타 (회사별 버저닝)
-- ************************************************************

-- 테이블 DROP (hr_plcy_chunk가 FK 참조하므로 CASCADE CONSTRAINTS 필수)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE hr_plcy_doc CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 시퀀스 DROP
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE hr_plcy_doc_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- CREATE
CREATE TABLE hr_plcy_doc (
    doc_id          NUMBER          NOT NULL,
    com_id          NUMBER          NOT NULL,   -- 회사마다 HR 규정이 다르므로 필수 스코프
    title           VARCHAR2(200)   NOT NULL,   -- 문서 제목 (예: '2026년 취업규칙')
    doc_version     NUMBER          NOT NULL,   -- 개정 차수 (1부터 증가, "version"은 Oracle 예약어)
    actv            NUMBER(1)       DEFAULT 1 NOT NULL,  -- 현재 유효(=RAG 검색 대상) 여부
    src_file_name   VARCHAR2(200),              -- 원본 파일명
    src_file_url    VARCHAR2(500),              -- 저장된 파일 URL
    full_text       CLOB,                       -- PDFBox로 추출한 원문 전체 (재색인/디버깅용)
    created_at      DATE            NOT NULL,   -- JPA @PrePersist가 채움
    updated_at      DATE            NOT NULL,   -- JPA @PrePersist/@PreUpdate가 채움
    CONSTRAINT pk_hr_plcy_doc       PRIMARY KEY (doc_id),
    CONSTRAINT ck_hr_plcy_doc_actv  CHECK (actv IN (0, 1))
);

CREATE SEQUENCE hr_plcy_doc_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- 회사당 actv=1 문서는 항상 1건 이하 (DB 레벨 보장)
-- actv=0인 행은 CASE 식이 NULL을 반환해 유니크 인덱스가 무시한다
CREATE UNIQUE INDEX ux_hr_plcy_doc_actv
    ON hr_plcy_doc (CASE WHEN actv = 1 THEN com_id END);

CREATE INDEX ix_hr_plcy_doc_com ON hr_plcy_doc (com_id);


-- ************************************************************
-- 2) hr_plcy_chunk  — HR 규정 문서 청크 + 임베딩 벡터
-- ************************************************************

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE hr_plcy_chunk CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE hr_plcy_chunk_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

CREATE TABLE hr_plcy_chunk (
    chunk_id        NUMBER          NOT NULL,
    doc_id          NUMBER          NOT NULL,   -- hr_plcy_doc FK
    chunk_order     NUMBER          NOT NULL,   -- 문서 내 청크 순번 (0부터)
    article         VARCHAR2(50),               -- 조항 헤더 (예: '제6조(연차)')  null 가능
    page            NUMBER,                     -- 원본 PDF 기준 페이지 번호 (1부터)
    chunk_text      CLOB            NOT NULL,   -- 청크 원문
    chunk_embedding CLOB            NOT NULL,   -- 임베딩 벡터 JSON 문자열 ("[0.012,-0.045,...]")
    CONSTRAINT pk_hr_plcy_chunk     PRIMARY KEY (chunk_id),
    CONSTRAINT fk_hr_plcy_chunk_doc FOREIGN KEY (doc_id) REFERENCES hr_plcy_doc (doc_id)
);

CREATE SEQUENCE hr_plcy_chunk_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE INDEX ix_hr_plcy_chunk_doc ON hr_plcy_chunk (doc_id);


-- ************************************************************
-- 3) hr_ai_chat_log  — HR AI 챗봇 질문/답변 이력 (insert-only)
-- ************************************************************

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE hr_ai_chat_log CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE hr_ai_chat_log_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

CREATE TABLE hr_ai_chat_log (
    log_id          NUMBER          NOT NULL,
    emp_id          NUMBER          NOT NULL,   -- 질문한 사원
    com_id          NUMBER          NOT NULL,   -- 사원 소속 회사 (검색 스코프 기록용)
    question        CLOB            NOT NULL,
    answer          CLOB            NOT NULL,
    ref_chunk_ids   VARCHAR2(500),              -- 답변에 사용된 chunk_id 목록 (콤마 구분, FK 아님)
    grounded        NUMBER(1)       NOT NULL,   -- 1=근거 있음, 0=근거 없어 고정 안내문 반환
    created_at      DATE            NOT NULL,   -- JPA @PrePersist가 채움
    CONSTRAINT pk_hr_ai_chat_log        PRIMARY KEY (log_id),
    CONSTRAINT ck_hr_ai_chat_log_grnd   CHECK (grounded IN (0, 1))
);

CREATE SEQUENCE hr_ai_chat_log_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE INDEX ix_hr_ai_chat_log_emp ON hr_ai_chat_log (emp_id);
CREATE INDEX ix_hr_ai_chat_log_com ON hr_ai_chat_log (com_id);


-- ============================================================
-- 실행 완료 확인용
-- ============================================================
SELECT 'hr_plcy_doc'     AS tbl, COUNT(*) AS cnt FROM hr_plcy_doc     UNION ALL
SELECT 'hr_plcy_chunk'   AS tbl, COUNT(*) AS cnt FROM hr_plcy_chunk   UNION ALL
SELECT 'hr_ai_chat_log'  AS tbl, COUNT(*) AS cnt FROM hr_ai_chat_log;