-- ============================================================
-- recruit 더미 데이터 FIX: UQ_APPLICANT_PROVIDER(REC_ID,APCT_PROVIDER,APCT_PROVIDER_ID) 위반 수정
--
-- 원인: 실제 applicant 테이블에는 소셜로그인 provider/provider_id 컬럼 + 
--       UNIQUE(REC_ID,APCT_PROVIDER,APCT_PROVIDER_ID) 제약이 있는데, 이전 스크립트는 이 두 컬럼을
--       넣지 않아 NULL로 들어갔다. Oracle 은 복합 UNIQUE 제약에서 REC_ID(NOT NULL)만 있고 나머지가
--       전부 NULL인 행끼리는 서로 중복으로 취급하기 때문에, 같은 공고(REC_ID)에 2번째 지원자부터
--       ORA-00001 로 실패했다 (10_recruit_dummy_data.sql 실행 로그와 정확히 일치 확인함).
--
-- 조치:
--   1) 이미 성공적으로 들어간 applicant 19건 -> UPDATE로 provider/provider_id 보강
--   2) 실패했던 applicant 15건 -> provider/provider_id 포함해서 재INSERT
--   3) 그 여파로 같이 실패했던 resume/resume_chunk -> 재INSERT
--   4) 시퀀스 재동기화
--
-- recruit 22건은 이번 오류와 무관하게 전부 정상 입력되어 있으므로 손대지 않는다.
-- ============================================================

SET DEFINE OFF;

-- ------------------------------------------------------------
-- 1) 이미 입력된 applicant 19건에 provider/provider_id 보강 (UPDATE)
-- ------------------------------------------------------------
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'NAVER', APCT_PROVIDER_ID = '7257600568' WHERE APCT_ID = 1; -- 윤예준
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'NAVER', APCT_PROVIDER_ID = '67483560211' WHERE APCT_ID = 4; -- 윤동현
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'KAKAO', APCT_PROVIDER_ID = '329394561' WHERE APCT_ID = 6; -- 이건우
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'GOOGLE', APCT_PROVIDER_ID = '698867118501743703877' WHERE APCT_ID = 8; -- 신지훈
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'NAVER', APCT_PROVIDER_ID = '7363244507' WHERE APCT_ID = 10; -- 서동현
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'GOOGLE', APCT_PROVIDER_ID = '613695957837347307448' WHERE APCT_ID = 11; -- 오시우
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'KAKAO', APCT_PROVIDER_ID = '1974241578' WHERE APCT_ID = 12; -- 김지호
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'GOOGLE', APCT_PROVIDER_ID = '734995042208601355292' WHERE APCT_ID = 14; -- 한동현
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'GOOGLE', APCT_PROVIDER_ID = '915339573920834904987' WHERE APCT_ID = 17; -- 박도현
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'KAKAO', APCT_PROVIDER_ID = '899618056' WHERE APCT_ID = 18; -- 서우진
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'NAVER', APCT_PROVIDER_ID = '5003447781' WHERE APCT_ID = 19; -- 조하윤
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'GOOGLE', APCT_PROVIDER_ID = '287757698856885193424' WHERE APCT_ID = 20; -- 최다은
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'KAKAO', APCT_PROVIDER_ID = '7817405295' WHERE APCT_ID = 21; -- 장민준
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'NAVER', APCT_PROVIDER_ID = '150556356' WHERE APCT_ID = 22; -- 윤도현
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'GOOGLE', APCT_PROVIDER_ID = '857986529356933924721' WHERE APCT_ID = 23; -- 신서현
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'KAKAO', APCT_PROVIDER_ID = '320346430' WHERE APCT_ID = 24; -- 조건우
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'NAVER', APCT_PROVIDER_ID = '29429573117' WHERE APCT_ID = 25; -- 권지유
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'NAVER', APCT_PROVIDER_ID = '1034366560' WHERE APCT_ID = 28; -- 최소율
UPDATE SBERP.APPLICANT SET APCT_PROVIDER = 'GOOGLE', APCT_PROVIDER_ID = '450117163310006439632' WHERE APCT_ID = 29; -- 김도윤
COMMIT;

-- ------------------------------------------------------------
-- 2) 실패했던 applicant 15건 재INSERT (provider/provider_id 포함)
-- ------------------------------------------------------------
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (2,1,1,'윤지훈','applicant002@example.com','010-1472-3873','SCREENING',to_date('26/01/30','RR/MM/DD'),'GOOGLE','289832155736911040943');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (3,1,1,'조현우','applicant003@example.com','010-2005-6167','INTERVIEW',to_date('26/01/21','RR/MM/DD'),'KAKAO','7282131912');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (5,1,2,'장지호','applicant005@example.com','010-4939-9414','REJECTED',to_date('26/07/14','RR/MM/DD'),'GOOGLE','942568919995367109238');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (7,1,3,'최서윤','applicant007@example.com','010-9282-6922','RECEIVED',to_date('26/06/11','RR/MM/DD'),'NAVER','0557264440');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (9,1,4,'조민서','applicant009@example.com','010-5268-9098','INTERVIEW',to_date('26/01/25','RR/MM/DD'),'KAKAO','551358576');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (13,1,7,'오소율','applicant013@example.com','010-5119-2578','RECEIVED',to_date('26/02/12','RR/MM/DD'),'NAVER','470932813');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (15,1,8,'권수아','applicant015@example.com','010-3228-5924','INTERVIEW',to_date('26/03/04','RR/MM/DD'),'KAKAO','30132165044');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (16,1,8,'최서현','applicant016@example.com','010-8168-8991','HIRED',to_date('26/03/15','RR/MM/DD'),'NAVER','75381923350');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (26,1,20,'한서연','applicant026@example.com','010-7151-7208','SCREENING',to_date('26/02/16','RR/MM/DD'),'GOOGLE','591366130410987772300');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (27,1,20,'한서현','applicant027@example.com','010-7435-1796','INTERVIEW',to_date('26/02/12','RR/MM/DD'),'KAKAO','1789288191');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (30,1,22,'권하윤','applicant030@example.com','010-3436-8263','REJECTED',to_date('26/08/04','RR/MM/DD'),'KAKAO','6997590248');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (31,1,22,'한민준','applicant031@example.com','010-3586-6585','RECEIVED',to_date('26/08/08','RR/MM/DD'),'NAVER','6351328094');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (32,1,22,'권다은','applicant032@example.com','010-3582-8347','SCREENING',to_date('26/08/02','RR/MM/DD'),'GOOGLE','108363802404772373450');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (33,1,22,'이서연','applicant033@example.com','010-1567-4502','INTERVIEW',to_date('26/08/01','RR/MM/DD'),'KAKAO','667331533');
Insert into SBERP.APPLICANT (APCT_ID,COM_ID,REC_ID,APCT_NAME,APCT_EMAIL,APCT_PHONE,APCT_STATUS,APCT_DATE,APCT_PROVIDER,APCT_PROVIDER_ID) values (34,1,22,'김시우','applicant034@example.com','010-5385-8573','HIRED',to_date('26/08/11','RR/MM/DD'),'NAVER','59994401346');
COMMIT;

-- ------------------------------------------------------------
-- 3) 여파로 실패했던 resume 12건 재INSERT
-- ------------------------------------------------------------
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (2,2,'윤지훈_이력서.pdf','/uploads/resume/2026/0002_윤지훈.pdf','윤지훈 이력서 요약: 기술팀 백엔드 개발자 채용 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','윤지훈 지원자는 ''백엔드 개발자 채용'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 74점.',74,'COMPLETED',to_date('26/01/30','RR/MM/DD'),to_date('26/01/31','RR/MM/DD')); -- 윤지훈
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (3,3,'조현우_이력서.pdf','/uploads/resume/2026/0003_조현우.pdf','조현우 이력서 요약: 기술팀 백엔드 개발자 채용 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','조현우 지원자는 ''백엔드 개발자 채용'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 87점.',87,'COMPLETED',to_date('26/01/21','RR/MM/DD'),to_date('26/01/21','RR/MM/DD')); -- 조현우
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (5,5,'장지호_이력서.pdf','/uploads/resume/2026/0005_장지호.pdf',NULL,NULL,NULL,'FAILED',to_date('26/07/14','RR/MM/DD'),to_date('26/07/15','RR/MM/DD')); -- 장지호
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (8,9,'조민서_이력서.pdf','/uploads/resume/2026/0008_조민서.pdf','조민서 이력서 요약: 생산부 생산관리 담당자 채용 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','조민서 지원자는 ''생산관리 담당자 채용'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 89점.',89,'COMPLETED',to_date('26/01/25','RR/MM/DD'),to_date('26/01/25','RR/MM/DD')); -- 조민서
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (13,15,'권수아_이력서.pdf','/uploads/resume/2026/0013_권수아.pdf','권수아 이력서 요약: 고객지원팀 고객지원 상담원 채용 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','권수아 지원자는 ''고객지원 상담원 채용'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 74점.',74,'COMPLETED',to_date('26/03/04','RR/MM/DD'),to_date('26/03/04','RR/MM/DD')); -- 권수아
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (14,16,'최서현_이력서.pdf','/uploads/resume/2026/0014_최서현.pdf','최서현 이력서 요약: 고객지원팀 고객지원 상담원 채용 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','최서현 지원자는 ''고객지원 상담원 채용'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 80점.',80,'COMPLETED',to_date('26/03/15','RR/MM/DD'),to_date('26/03/16','RR/MM/DD')); -- 최서현
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (24,26,'한서연_이력서.pdf','/uploads/resume/2026/0024_한서연.pdf','한서연 이력서 요약: 생산팀 생산직 사원(제조) 채용 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','한서연 지원자는 ''생산직 사원(제조) 채용'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 77점.',77,'COMPLETED',to_date('26/02/16','RR/MM/DD'),to_date('26/02/17','RR/MM/DD')); -- 한서연
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (25,27,'한서현_이력서.pdf','/uploads/resume/2026/0025_한서현.pdf','한서현 이력서 요약: 생산팀 생산직 사원(제조) 채용 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','한서현 지원자는 ''생산직 사원(제조) 채용'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 93점.',93,'COMPLETED',to_date('26/02/12','RR/MM/DD'),to_date('26/02/13','RR/MM/DD')); -- 한서현
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (28,30,'권하윤_이력서.pdf','/uploads/resume/2026/0028_권하윤.pdf','권하윤 이력서 요약: 전 부문 2026년 하반기 신입 공채 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','권하윤 지원자는 ''2026년 하반기 신입 공채'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 85점.',85,'COMPLETED',to_date('26/08/04','RR/MM/DD'),to_date('26/08/06','RR/MM/DD')); -- 권하윤
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (29,32,'권다은_이력서.pdf','/uploads/resume/2026/0029_권다은.pdf','권다은 이력서 요약: 전 부문 2026년 하반기 신입 공채 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','권다은 지원자는 ''2026년 하반기 신입 공채'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 61점.',61,'COMPLETED',to_date('26/08/02','RR/MM/DD'),to_date('26/08/03','RR/MM/DD')); -- 권다은
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (30,33,'이서연_이력서.pdf','/uploads/resume/2026/0030_이서연.pdf','이서연 이력서 요약: 전 부문 2026년 하반기 신입 공채 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','이서연 지원자는 ''2026년 하반기 신입 공채'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 95점.',95,'COMPLETED',to_date('26/08/01','RR/MM/DD'),to_date('26/08/01','RR/MM/DD')); -- 이서연
Insert into SBERP.RESUME (RSM_ID,APCT_ID,RSM_FILE_NAME,RSM_FILE_URL,RSM_EXTRACTED_TEXT,RSM_AI_SUMMARY,RSM_FIT_SCORE,RSM_STATUS,RSM_UPLOADED_AT,RSM_ANALYZED_AT) values (31,34,'김시우_이력서.pdf','/uploads/resume/2026/0031_김시우.pdf','김시우 이력서 요약: 전 부문 2026년 하반기 신입 공채 직무 지원. 관련 실무 경력 및 프로젝트 수행 경험 보유. 자기소개서 상 지원 동기와 직무 역량을 기재함.','김시우 지원자는 ''2026년 하반기 신입 공채'' 직무 요건과 전반적으로 부합하며, 관련 실무 경험과 커뮤니케이션 역량이 강점으로 파악됨. AI 적합도 점수 69점.',69,'COMPLETED',to_date('26/08/11','RR/MM/DD'),to_date('26/08/13','RR/MM/DD')); -- 김시우
COMMIT;

-- ------------------------------------------------------------
-- 4) 여파로 실패했던 resume_chunk 26건 재INSERT
-- ------------------------------------------------------------
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (4,2,1,'경력사항: 윤지훈, 지원 직무 유관 직무에서 실무 경험 보유. 담당 업무 수행 및 성과 개선 사례 있음.','[-0.0245,0.3924,0.8437,-0.1871,0.5271,0.0531,-0.5357,0.1816,0.5773,0.2975,-0.2247,-0.7031,0.3794,-0.5505,-0.6009,-0.5536]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (5,2,2,'자기소개: 윤지훈는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[-0.6941,-0.984,-0.3839,-0.0567,-0.7997,-0.8589,0.6899,-0.5754,0.0005,-0.2333,-0.8938,0.757,0.7821,0.1014,0.8501,-0.7542]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (6,2,3,'보유기술 및 자격: 직무 관련 툴/자격증 보유. 관련 실무 도구 활용 가능.','[0.5395,0.5236,-0.705,-0.9198,-0.249,0.2725,-0.2515,0.5104,-0.2144,0.8359,-0.5332,0.536,0.291,-0.1048,0.9058,-0.7549]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (7,3,1,'학력사항: 조현우, 관련 전공 학사 졸업. 재학 중 직무 관련 프로젝트 및 대외활동 수행.','[0.143,0.2917,-0.5213,-0.6842,0.7972,0.6212,0.6601,0.4462,0.1046,-0.7517,-0.9711,0.6845,-0.9791,-0.316,0.39,-0.0754]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (8,3,2,'자기소개: 조현우는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[-0.3373,0.3914,0.812,0.3005,-0.8203,0.9087,-0.4709,0.8877,0.0204,-0.2638,0.5188,0.0117,0.5556,0.4755,-0.9013,-0.1414]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (17,8,1,'학력사항: 조민서, 관련 전공 학사 졸업. 재학 중 직무 관련 프로젝트 및 대외활동 수행.','[0.2805,0.3218,0.2975,0.2987,-0.8435,0.7656,-0.3825,0.3887,-0.1832,0.3805,0.5074,-0.6934,0.7385,-0.8918,-0.3738,0.3871]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (18,8,2,'경력사항: 조민서, 지원 직무 유관 직무에서 실무 경험 보유. 담당 업무 수행 및 성과 개선 사례 있음.','[0.2121,-0.0629,-0.9084,-0.2147,0.9144,-0.7053,-0.7953,0.8418,-0.4034,0.2716,-0.7981,-0.3908,-0.4359,-0.6505,-0.1337,0.7859]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (31,13,1,'자기소개: 권수아는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[0.9166,0.6781,0.5251,-0.6936,0.9139,0.3878,0.4365,-0.1925,0.2401,0.2364,-0.5475,-0.3468,0.9397,0.5645,0.82,0.452]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (32,13,2,'보유기술 및 자격: 직무 관련 툴/자격증 보유. 관련 실무 도구 활용 가능.','[0.6737,-0.0684,-0.2516,-0.7571,0.7482,0.5855,0.8379,0.9548,-0.8393,-0.0641,-0.5845,-0.8071,-0.5486,0.058,-0.9077,-0.8862]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (33,14,1,'자기소개: 최서현는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[-0.8876,0.1406,-0.3964,-0.1775,0.3843,-0.5482,0.5645,0.7199,-0.9318,-0.1202,-0.9798,-0.5113,0.79,0.205,-0.5349,0.7995]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (34,14,2,'보유기술 및 자격: 직무 관련 툴/자격증 보유. 관련 실무 도구 활용 가능.','[0.4921,-0.0512,-0.9711,0.1145,0.4,0.77,-0.8981,0.8768,-0.6356,-0.1648,0.309,0.099,0.1143,-0.6194,-0.3871,-0.1401]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (57,24,1,'자기소개: 한서연는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[0.7605,0.7848,0.6905,-0.6149,0.7265,0.9864,0.6291,-0.5855,0.2326,-0.778,0.6808,0.6055,-0.1618,0.4497,0.7632,-0.19]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (58,24,2,'학력사항: 한서연, 관련 전공 학사 졸업. 재학 중 직무 관련 프로젝트 및 대외활동 수행.','[-0.5607,0.9201,-0.2578,0.7928,0.8431,0.9894,0.2899,0.4219,0.4058,0.465,-0.0015,-0.4292,0.512,-0.6131,0.5126,-0.84]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (59,24,3,'경력사항: 한서연, 지원 직무 유관 직무에서 실무 경험 보유. 담당 업무 수행 및 성과 개선 사례 있음.','[-0.5963,0.1051,-0.5907,0.4576,0.7683,-0.2849,-0.1616,0.585,0.8027,-0.6719,-0.1475,-0.7129,-0.2606,-0.9362,-0.202,-0.1026]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (60,25,1,'보유기술 및 자격: 직무 관련 툴/자격증 보유. 관련 실무 도구 활용 가능.','[0.2127,-0.1845,0.153,0.1323,-0.9146,-0.3508,-0.5112,-0.6954,0.7719,-0.544,0.9441,-0.4637,0.7932,0.5085,-0.7055,0.3654]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (61,25,2,'학력사항: 한서현, 관련 전공 학사 졸업. 재학 중 직무 관련 프로젝트 및 대외활동 수행.','[0.819,0.2464,0.1704,0.8397,-0.394,0.6025,0.7532,-0.6591,0.4097,0.7796,-0.0006,-0.0074,0.8871,-0.8871,-0.6815,0.7501]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (62,25,3,'자기소개: 한서현는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[0.6267,-0.4972,-0.2958,0.5178,-0.5683,-0.6434,-0.5426,0.4822,-0.6893,-0.3502,-0.3205,0.3072,0.9844,-0.8985,0.5147,0.4061]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (67,28,1,'보유기술 및 자격: 직무 관련 툴/자격증 보유. 관련 실무 도구 활용 가능.','[0.8686,0.4438,-0.224,-0.5687,-0.2267,0.6564,0.9177,-0.0324,-0.0899,-0.4039,0.0927,0.7836,0.4929,0.5965,0.6229,0.7925]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (68,28,2,'학력사항: 권하윤, 관련 전공 학사 졸업. 재학 중 직무 관련 프로젝트 및 대외활동 수행.','[0.9472,0.87,0.9336,0.2394,0.9682,0.7182,-0.1175,-0.6296,-0.0196,0.8637,-0.1095,-0.6113,0.0692,-0.6277,0.9023,-0.2523]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (69,29,1,'보유기술 및 자격: 직무 관련 툴/자격증 보유. 관련 실무 도구 활용 가능.','[-0.8317,-0.5136,0.6451,-0.4723,-0.9268,0.0383,-0.3731,0.5496,0.0415,0.1736,-0.0219,0.5629,0.3835,-0.5785,-0.629,-0.4944]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (70,29,2,'학력사항: 권다은, 관련 전공 학사 졸업. 재학 중 직무 관련 프로젝트 및 대외활동 수행.','[-0.0107,-0.7733,-0.0879,-0.6967,-0.9448,-0.1619,-0.452,0.274,0.1046,0.4654,0.7664,0.9823,-0.129,0.278,0.2902,-0.7904]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (71,30,1,'보유기술 및 자격: 직무 관련 툴/자격증 보유. 관련 실무 도구 활용 가능.','[0.8461,0.8283,-0.3861,-0.4024,-0.5938,-0.2599,0.4822,0.7026,0.054,-0.0369,-0.8152,-0.5376,-0.703,0.467,0.7821,-0.8335]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (72,30,2,'자기소개: 이서연는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[-0.6383,-0.8458,0.4604,0.9872,0.983,-0.3532,0.8771,0.16,-0.7144,-0.3079,0.6081,0.0648,-0.5858,0.3591,-0.221,-0.1467]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (73,30,3,'경력사항: 이서연, 지원 직무 유관 직무에서 실무 경험 보유. 담당 업무 수행 및 성과 개선 사례 있음.','[0.7389,-0.5979,-0.0903,-0.4794,0.1316,0.7122,-0.6706,-0.8419,-0.3222,-0.9046,0.5758,0.0579,0.0709,0.3373,0.5502,-0.8668]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (74,31,1,'학력사항: 김시우, 관련 전공 학사 졸업. 재학 중 직무 관련 프로젝트 및 대외활동 수행.','[0.3203,-0.0619,-0.4443,0.6537,-0.1743,-0.2609,-0.5971,-0.835,0.6244,-0.4093,0.763,0.2518,-0.5192,-0.8099,-0.367,0.9887]');
Insert into SBERP.RESUME_CHUNK (CHUNK_ID,RSM_ID,CHUNK_ORDER,CHUNK_TEXT,CHUNK_EMBEDDING) values (75,31,2,'자기소개: 김시우는 ''지원 직무'' 직무에 대한 지원 동기와 향후 포부를 기재함.','[0.3721,0.9739,0.691,0.3311,0.0154,-0.585,0.4926,-0.4051,-0.6377,-0.1636,-0.1958,0.9923,0.0099,-0.2242,0.1647,0.1248]');
COMMIT;

-- ------------------------------------------------------------
-- 5) 시퀀스 재동기화 (이번에 실제로 채워진 MAX(pk) 기준으로 다시 맞춤)
-- ------------------------------------------------------------
DECLARE
    PROCEDURE resync_seq(p_seq_name VARCHAR2, p_table VARCHAR2, p_col VARCHAR2) IS
        v_next NUMBER;
    BEGIN
        EXECUTE IMMEDIATE 'SELECT NVL(MAX(' || p_col || '),0)+1 FROM ' || p_table INTO v_next;
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || p_seq_name;
        EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || p_seq_name ||
            ' START WITH ' || v_next || ' INCREMENT BY 1 NOCACHE NOCYCLE';
    END;
BEGIN
    resync_seq('seq_applicant', 'applicant', 'apct_id');
    resync_seq('seq_resume', 'resume', 'rsm_id');
    resync_seq('seq_resume_chunk', 'resume_chunk', 'chunk_id');
END;
/

COMMIT;