-- ============================================================
-- 근태 x 인사평가 연동 테스트 데이터 v2
-- ============================================================
-- 평가 기간: 2026-07-01 ~ 2026-07-31 (영업일 23일)
-- 평가자: emp_id=11 (여정린/b@b, 보안관제팀 부서장)
-- 피평가자: 보안관제팀 7명
-- ============================================================

-- 1. 기존 평가 데이터 리셋
DELETE FROM evaluation_ai_report;
DELETE FROM performance_evaluation;
DELETE FROM evaluation_period;
COMMIT;

-- 2. 7월 근태 데이터용 기존 데이터 정리 (7월 중복 방지)
DELETE FROM attendance
 WHERE emp_id IN (13, 48, 75, 78, 80, 187, 196)
   AND att_date BETWEEN TO_DATE('2026-07-01','YYYY-MM-DD')
                     AND TO_DATE('2026-07-31','YYYY-MM-DD');
COMMIT;

-- 3. 평가 회차 생성 (READY)
INSERT INTO evaluation_period (
    period_id, com_id, eval_year, eval_term, title,
    start_date, end_date, period_status
) VALUES (
    SEQ_PERIOD.NEXTVAL, 1, 2026, 'H2', '2026년 하반기 정기평가',
    TO_DATE('2026-07-01','YYYY-MM-DD'),
    TO_DATE('2026-07-31','YYYY-MM-DD'),
    'READY'
);
COMMIT;

-- ──────────────────────────────────────────────
-- 4. 근태 데이터 (7명 x 23영업일 = 161건)
-- ──────────────────────────────────────────────
-- 13(하정랑/사원)  : 모범 - 23일 전출근, 지각0 결근0
-- 48(조준석/과장)  : 야근+지각 - 지각5, 연장근로 과다
-- 75(배영린/차장)  : 지각 잦음 - 지각7
-- 78(권현준/과장)  : 결근2 + 조퇴2
-- 80(정수혁/주임)  : 연차5 + 오전반차1 + 오후반차2
-- 187(남창원/대리) : 야근 과다 (22~23시 퇴근)
-- 196(남나율/주임) : 평범 - 지각2 + 연차1

INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-01 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-01 17:50:00','YYYY-MM-DD HH24:MI:SS'), 475, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-02','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-02 08:56:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-02 18:07:00','YYYY-MM-DD HH24:MI:SS'), 491, 11, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-03','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-03 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-03 17:51:00','YYYY-MM-DD HH24:MI:SS'), 483, 3, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-06','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-06 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-06 17:59:00','YYYY-MM-DD HH24:MI:SS'), 484, 4, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-07','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-07 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-07 17:50:00','YYYY-MM-DD HH24:MI:SS'), 479, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-08','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-08 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-08 17:53:00','YYYY-MM-DD HH24:MI:SS'), 487, 7, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-09','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-09 08:53:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-09 17:58:00','YYYY-MM-DD HH24:MI:SS'), 485, 5, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-10','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-10 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-10 18:07:00','YYYY-MM-DD HH24:MI:SS'), 499, 19, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-13 08:52:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-13 18:00:00','YYYY-MM-DD HH24:MI:SS'), 488, 8, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-14','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-14 08:57:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-14 17:56:00','YYYY-MM-DD HH24:MI:SS'), 479, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-15','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-15 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-15 18:04:00','YYYY-MM-DD HH24:MI:SS'), 494, 14, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-16','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-16 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-16 18:03:00','YYYY-MM-DD HH24:MI:SS'), 495, 15, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-17','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-17 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-17 18:03:00','YYYY-MM-DD HH24:MI:SS'), 497, 17, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-20','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-20 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-20 18:19:00','YYYY-MM-DD HH24:MI:SS'), 509, 29, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-21 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-21 17:57:00','YYYY-MM-DD HH24:MI:SS'), 488, 8, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-22','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-22 08:53:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-22 17:56:00','YYYY-MM-DD HH24:MI:SS'), 483, 3, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-23','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-23 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-23 18:20:00','YYYY-MM-DD HH24:MI:SS'), 514, 34, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-24','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-24 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-24 18:18:00','YYYY-MM-DD HH24:MI:SS'), 504, 24, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-27','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-27 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-27 17:50:00','YYYY-MM-DD HH24:MI:SS'), 482, 2, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-28 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-28 17:54:00','YYYY-MM-DD HH24:MI:SS'), 479, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-29','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-29 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-29 17:51:00','YYYY-MM-DD HH24:MI:SS'), 485, 5, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-30','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-30 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-30 18:14:00','YYYY-MM-DD HH24:MI:SS'), 503, 23, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 13, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-31 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-31 18:05:00','YYYY-MM-DD HH24:MI:SS'), 490, 10, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-01 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-01 20:06:00','YYYY-MM-DD HH24:MI:SS'), 616, 136, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-02','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-02 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-02 20:22:00','YYYY-MM-DD HH24:MI:SS'), 627, 147, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-03','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-03 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-03 21:20:00','YYYY-MM-DD HH24:MI:SS'), 681, 201, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-06','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-06 09:14:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-06 21:20:00','YYYY-MM-DD HH24:MI:SS'), 666, 186, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-07','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-07 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-07 21:23:00','YYYY-MM-DD HH24:MI:SS'), 696, 216, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-08','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-08 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-08 19:14:00','YYYY-MM-DD HH24:MI:SS'), 566, 86, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-09','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-09 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-09 20:29:00','YYYY-MM-DD HH24:MI:SS'), 638, 158, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-10','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-10 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-10 21:17:00','YYYY-MM-DD HH24:MI:SS'), 682, 202, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-13 09:24:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-13 21:10:00','YYYY-MM-DD HH24:MI:SS'), 646, 166, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-14','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-14 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-14 19:07:00','YYYY-MM-DD HH24:MI:SS'), 549, 69, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-15','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-15 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-15 19:25:00','YYYY-MM-DD HH24:MI:SS'), 567, 87, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-16','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-16 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-16 20:08:00','YYYY-MM-DD HH24:MI:SS'), 618, 138, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-17','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-17 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-17 19:29:00','YYYY-MM-DD HH24:MI:SS'), 583, 103, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-20','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-20 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-20 21:10:00','YYYY-MM-DD HH24:MI:SS'), 676, 196, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-21 09:23:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-21 21:15:00','YYYY-MM-DD HH24:MI:SS'), 652, 172, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-22','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-22 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-22 21:14:00','YYYY-MM-DD HH24:MI:SS'), 683, 203, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-23','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-23 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-23 20:04:00','YYYY-MM-DD HH24:MI:SS'), 617, 137, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-24','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-24 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-24 21:17:00','YYYY-MM-DD HH24:MI:SS'), 689, 209, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-27','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-27 08:53:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-27 20:23:00','YYYY-MM-DD HH24:MI:SS'), 630, 150, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-28 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-28 20:28:00','YYYY-MM-DD HH24:MI:SS'), 634, 154, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-29','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-29 09:35:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-29 20:07:00','YYYY-MM-DD HH24:MI:SS'), 572, 92, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-30','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-30 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-30 21:15:00','YYYY-MM-DD HH24:MI:SS'), 688, 208, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 48, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-31 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-31 19:27:00','YYYY-MM-DD HH24:MI:SS'), 581, 101, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-01 09:17:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-01 18:20:00','YYYY-MM-DD HH24:MI:SS'), 483, 3, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-02','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-02 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-02 18:19:00','YYYY-MM-DD HH24:MI:SS'), 512, 32, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-03','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-03 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-03 18:12:00','YYYY-MM-DD HH24:MI:SS'), 506, 26, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-06','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-06 09:39:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-06 19:17:00','YYYY-MM-DD HH24:MI:SS'), 518, 38, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-07','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-07 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-07 17:51:00','YYYY-MM-DD HH24:MI:SS'), 473, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-08','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-08 09:44:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-08 19:24:00','YYYY-MM-DD HH24:MI:SS'), 520, 40, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-09','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-09 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-09 18:03:00','YYYY-MM-DD HH24:MI:SS'), 488, 8, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-10','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-10 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-10 18:05:00','YYYY-MM-DD HH24:MI:SS'), 496, 16, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-13 08:52:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-13 17:54:00','YYYY-MM-DD HH24:MI:SS'), 482, 2, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-14','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-14 09:42:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-14 18:16:00','YYYY-MM-DD HH24:MI:SS'), 454, 0, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-15','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-15 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-15 17:54:00','YYYY-MM-DD HH24:MI:SS'), 475, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-16','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-16 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-16 17:52:00','YYYY-MM-DD HH24:MI:SS'), 474, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-17','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-17 09:33:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-17 18:17:00','YYYY-MM-DD HH24:MI:SS'), 464, 0, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-20','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-20 08:57:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-20 17:59:00','YYYY-MM-DD HH24:MI:SS'), 482, 2, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-21 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-21 18:00:00','YYYY-MM-DD HH24:MI:SS'), 490, 10, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-22','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-22 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-22 18:09:00','YYYY-MM-DD HH24:MI:SS'), 503, 23, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-23','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-23 09:25:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-23 18:07:00','YYYY-MM-DD HH24:MI:SS'), 462, 0, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-24','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-24 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-24 17:51:00','YYYY-MM-DD HH24:MI:SS'), 472, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-27','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-27 08:56:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-27 18:02:00','YYYY-MM-DD HH24:MI:SS'), 486, 6, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-28 09:44:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-28 18:04:00','YYYY-MM-DD HH24:MI:SS'), 440, 0, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-29','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-29 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-29 18:17:00','YYYY-MM-DD HH24:MI:SS'), 502, 22, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-30','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-30 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-30 18:16:00','YYYY-MM-DD HH24:MI:SS'), 509, 29, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 75, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-31 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-31 18:06:00','YYYY-MM-DD HH24:MI:SS'), 488, 8, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-01 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-01 17:54:00','YYYY-MM-DD HH24:MI:SS'), 475, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-02','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-02 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-02 18:14:00','YYYY-MM-DD HH24:MI:SS'), 503, 23, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-03','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-03 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-03 18:03:00','YYYY-MM-DD HH24:MI:SS'), 484, 4, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-06','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-06 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-06 17:51:00','YYYY-MM-DD HH24:MI:SS'), 483, 3, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-07','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ABSENT');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-08','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-08 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-08 17:59:00','YYYY-MM-DD HH24:MI:SS'), 489, 9, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-09','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-09 08:53:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-09 17:59:00','YYYY-MM-DD HH24:MI:SS'), 486, 6, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-10','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-10 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-10 14:02:00','YYYY-MM-DD HH24:MI:SS'), 251, 0, 0, 'EARLY_LEAVE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-13 08:56:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-13 17:53:00','YYYY-MM-DD HH24:MI:SS'), 477, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-14','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-14 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-14 17:55:00','YYYY-MM-DD HH24:MI:SS'), 489, 9, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-15','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-15 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-15 17:54:00','YYYY-MM-DD HH24:MI:SS'), 488, 8, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-16','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-16 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-16 18:06:00','YYYY-MM-DD HH24:MI:SS'), 491, 11, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-17','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-17 08:53:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-17 17:59:00','YYYY-MM-DD HH24:MI:SS'), 486, 6, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-20','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-20 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-20 18:07:00','YYYY-MM-DD HH24:MI:SS'), 493, 13, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-21 08:57:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-21 18:13:00','YYYY-MM-DD HH24:MI:SS'), 496, 16, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-22','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ABSENT');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-23','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-23 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-23 17:51:00','YYYY-MM-DD HH24:MI:SS'), 483, 3, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-24','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-24 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-24 18:11:00','YYYY-MM-DD HH24:MI:SS'), 496, 16, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-27','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-27 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-27 15:14:00','YYYY-MM-DD HH24:MI:SS'), 320, 0, 0, 'EARLY_LEAVE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-28 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-28 17:51:00','YYYY-MM-DD HH24:MI:SS'), 473, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-29','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-29 08:45:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-29 18:10:00','YYYY-MM-DD HH24:MI:SS'), 505, 25, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-30','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-30 08:57:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-30 17:53:00','YYYY-MM-DD HH24:MI:SS'), 476, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 78, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-31 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-31 17:58:00','YYYY-MM-DD HH24:MI:SS'), 490, 10, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-01 08:52:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-01 17:56:00','YYYY-MM-DD HH24:MI:SS'), 484, 4, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-02','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-02 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-02 18:14:00','YYYY-MM-DD HH24:MI:SS'), 507, 27, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-03','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ANNUAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-06','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ANNUAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-07','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ANNUAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-08','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-08 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-08 17:57:00','YYYY-MM-DD HH24:MI:SS'), 489, 9, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-09','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-09 08:57:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-09 17:50:00','YYYY-MM-DD HH24:MI:SS'), 473, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-10','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-10 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-10 17:51:00','YYYY-MM-DD HH24:MI:SS'), 476, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-13 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-13 13:00:00','YYYY-MM-DD HH24:MI:SS'), 245, 0, 0, 'AM_HALF');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-14','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-14 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-14 17:52:00','YYYY-MM-DD HH24:MI:SS'), 473, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-15','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ANNUAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-16','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ANNUAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-17','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-17 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-17 18:15:00','YYYY-MM-DD HH24:MI:SS'), 504, 24, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-20','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-20 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-20 18:01:00','YYYY-MM-DD HH24:MI:SS'), 493, 13, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-21 13:00:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-21 18:00:00','YYYY-MM-DD HH24:MI:SS'), 240, 0, 0, 'PM_HALF');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-22','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-22 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-22 18:00:00','YYYY-MM-DD HH24:MI:SS'), 493, 13, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-23','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-23 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-23 18:14:00','YYYY-MM-DD HH24:MI:SS'), 503, 23, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-24','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-24 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-24 18:17:00','YYYY-MM-DD HH24:MI:SS'), 508, 28, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-27','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-27 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-27 18:04:00','YYYY-MM-DD HH24:MI:SS'), 489, 9, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-28 13:00:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-28 18:00:00','YYYY-MM-DD HH24:MI:SS'), 240, 0, 0, 'PM_HALF');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-29','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-29 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-29 18:06:00','YYYY-MM-DD HH24:MI:SS'), 498, 18, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-30','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-30 08:45:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-30 17:55:00','YYYY-MM-DD HH24:MI:SS'), 490, 10, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 80, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-31 08:45:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-31 17:59:00','YYYY-MM-DD HH24:MI:SS'), 494, 14, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-01 08:52:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-01 23:33:00','YYYY-MM-DD HH24:MI:SS'), 821, 341, 93, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-02','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-02 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-02 21:32:00','YYYY-MM-DD HH24:MI:SS'), 705, 225, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-03','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-03 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-03 21:04:00','YYYY-MM-DD HH24:MI:SS'), 678, 198, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-06','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-06 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-06 21:43:00','YYYY-MM-DD HH24:MI:SS'), 709, 229, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-07','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-07 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-07 21:25:00','YYYY-MM-DD HH24:MI:SS'), 687, 207, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-08','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-08 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-08 23:15:00','YYYY-MM-DD HH24:MI:SS'), 809, 329, 75, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-09','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-09 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-09 23:02:00','YYYY-MM-DD HH24:MI:SS'), 788, 308, 62, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-10','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-10 08:54:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-10 21:26:00','YYYY-MM-DD HH24:MI:SS'), 692, 212, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-13 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-13 23:36:00','YYYY-MM-DD HH24:MI:SS'), 821, 341, 96, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-14','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-14 08:53:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-14 22:16:00','YYYY-MM-DD HH24:MI:SS'), 743, 263, 16, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-15','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-15 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-15 23:45:00','YYYY-MM-DD HH24:MI:SS'), 837, 357, 105, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-16','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-16 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-16 21:16:00','YYYY-MM-DD HH24:MI:SS'), 686, 206, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-17','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-17 08:51:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-17 21:42:00','YYYY-MM-DD HH24:MI:SS'), 711, 231, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-20','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-20 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-20 22:29:00','YYYY-MM-DD HH24:MI:SS'), 754, 274, 29, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-21 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-21 21:00:00','YYYY-MM-DD HH24:MI:SS'), 670, 190, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-22','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-22 08:52:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-22 23:36:00','YYYY-MM-DD HH24:MI:SS'), 824, 344, 96, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-23','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-23 08:46:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-23 21:34:00','YYYY-MM-DD HH24:MI:SS'), 708, 228, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-24','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-24 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-24 23:16:00','YYYY-MM-DD HH24:MI:SS'), 808, 328, 76, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-27','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-27 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-27 22:04:00','YYYY-MM-DD HH24:MI:SS'), 737, 257, 4, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-28 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-28 21:23:00','YYYY-MM-DD HH24:MI:SS'), 684, 204, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-29','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-29 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-29 21:28:00','YYYY-MM-DD HH24:MI:SS'), 699, 219, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-30','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-30 08:58:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-30 23:45:00','YYYY-MM-DD HH24:MI:SS'), 827, 347, 105, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 187, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-31 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-31 23:41:00','YYYY-MM-DD HH24:MI:SS'), 832, 352, 101, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-01 08:53:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-01 17:58:00','YYYY-MM-DD HH24:MI:SS'), 485, 5, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-02','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-02 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-02 17:52:00','YYYY-MM-DD HH24:MI:SS'), 483, 3, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-03','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-03 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-03 17:51:00','YYYY-MM-DD HH24:MI:SS'), 482, 2, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-06','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-06 08:56:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-06 17:54:00','YYYY-MM-DD HH24:MI:SS'), 478, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-07','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-07 08:49:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-07 17:55:00','YYYY-MM-DD HH24:MI:SS'), 486, 6, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-08','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-08 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-08 18:16:00','YYYY-MM-DD HH24:MI:SS'), 508, 28, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-09','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-09 09:41:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-09 19:28:00','YYYY-MM-DD HH24:MI:SS'), 527, 47, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-10','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-10 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-10 17:51:00','YYYY-MM-DD HH24:MI:SS'), 472, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-13','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-13 08:55:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-13 18:08:00','YYYY-MM-DD HH24:MI:SS'), 493, 13, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-14','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-14 08:45:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-14 17:55:00','YYYY-MM-DD HH24:MI:SS'), 490, 10, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-15','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-15 08:57:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-15 17:54:00','YYYY-MM-DD HH24:MI:SS'), 477, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-16','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-16 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-16 18:17:00','YYYY-MM-DD HH24:MI:SS'), 510, 30, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-17','YYYY-MM-DD'), NULL, NULL, 0, 0, 0, 'ANNUAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-20','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-20 08:56:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-20 18:17:00','YYYY-MM-DD HH24:MI:SS'), 501, 21, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-21','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-21 08:45:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-21 17:51:00','YYYY-MM-DD HH24:MI:SS'), 486, 6, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-22','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-22 08:59:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-22 17:58:00','YYYY-MM-DD HH24:MI:SS'), 479, 0, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-23','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-23 08:45:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-23 18:18:00','YYYY-MM-DD HH24:MI:SS'), 513, 33, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-24','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-24 09:45:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-24 18:13:00','YYYY-MM-DD HH24:MI:SS'), 448, 0, 0, 'LATE');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-27','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-27 08:47:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-27 17:54:00','YYYY-MM-DD HH24:MI:SS'), 487, 7, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-28','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-28 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-28 17:55:00','YYYY-MM-DD HH24:MI:SS'), 485, 5, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-29','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-29 08:48:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-29 17:51:00','YYYY-MM-DD HH24:MI:SS'), 483, 3, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-30','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-30 08:50:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-30 18:19:00','YYYY-MM-DD HH24:MI:SS'), 509, 29, 0, 'NORMAL');
INSERT INTO attendance (att_id, emp_id, att_date, check_in, check_out, work_minutes, overtime_minutes, night_minutes, att_status) VALUES (SEQ_ATTENDANCE.NEXTVAL, 196, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_TIMESTAMP('2026-07-31 08:56:00','YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-07-31 17:53:00','YYYY-MM-DD HH24:MI:SS'), 477, 0, 0, 'NORMAL');

COMMIT;

-- ──────────────────────────────────────────────
-- 5. 인사평가 데이터 (SUBMITTED)
--    평가자: emp_id=11 (부서장)
-- ──────────────────────────────────────────────

-- 13 (하정랑/사원) 고성과: P5 E4 T5 A5 G4 = 4.70
INSERT INTO performance_evaluation (
    eval_id, period_id, target_emp_id, evaluator_id, eval_type,
    score_performance, score_expertise, score_teamwork, score_attitude, score_growth,
    weighted_score, strength_comment, improvement_comment, eval_status
) VALUES (
    SEQ_EVAL.NEXTVAL,
    (SELECT period_id FROM evaluation_period WHERE com_id=1 AND eval_year=2026 AND eval_term='H2'),
    13, 11, 'LEADER', 5, 4, 5, 5, 4, 4.70,
    '맡은 업무를 항상 기한 내에 완수하며, 팀원들과의 소통이 원활합니다. 근태도 매우 성실하여 모범 사원입니다.',
    '기술적 전문성을 더 높이면 팀 내 리더 역할도 가능할 것으로 보입니다.',
    'SUBMITTED'
);

-- 48 (조준석/과장) 보통+지각: P4 E4 T3 A3 G4 = 3.70
INSERT INTO performance_evaluation (
    eval_id, period_id, target_emp_id, evaluator_id, eval_type,
    score_performance, score_expertise, score_teamwork, score_attitude, score_growth,
    weighted_score, strength_comment, improvement_comment, eval_status
) VALUES (
    SEQ_EVAL.NEXTVAL,
    (SELECT period_id FROM evaluation_period WHERE com_id=1 AND eval_year=2026 AND eval_term='H2'),
    48, 11, 'LEADER', 4, 4, 3, 3, 4, 3.70,
    '프로젝트 일정 관리 능력이 뛰어나며, 기술적 문제 해결에 적극적입니다. 야근을 마다하지 않는 업무 헌신이 돋보입니다.',
    '팀원 간 커뮤니케이션을 개선하고, 출근 시간을 보다 엄수할 필요가 있습니다.',
    'SUBMITTED'
);

-- 75 (배영린/차장) 지각 잦음: P3 E4 T3 A2 G3 = 3.10
INSERT INTO performance_evaluation (
    eval_id, period_id, target_emp_id, evaluator_id, eval_type,
    score_performance, score_expertise, score_teamwork, score_attitude, score_growth,
    weighted_score, strength_comment, improvement_comment, eval_status
) VALUES (
    SEQ_EVAL.NEXTVAL,
    (SELECT period_id FROM evaluation_period WHERE com_id=1 AND eval_year=2026 AND eval_term='H2'),
    75, 11, 'LEADER', 3, 4, 3, 2, 3, 3.10,
    '보안 분야 전문 지식이 풍부하고 경험이 많아 팀에 기여하는 바가 큽니다.',
    '잦은 지각으로 팀 분위기에 영향을 주고 있으며, 시간 관리 개선이 시급합니다. 출근 습관 교정이 필요합니다.',
    'SUBMITTED'
);

-- 78 (권현준/과장) 결근+조퇴: P3 E3 T4 A2 G3 = 3.10
INSERT INTO performance_evaluation (
    eval_id, period_id, target_emp_id, evaluator_id, eval_type,
    score_performance, score_expertise, score_teamwork, score_attitude, score_growth,
    weighted_score, strength_comment, improvement_comment, eval_status
) VALUES (
    SEQ_EVAL.NEXTVAL,
    (SELECT period_id FROM evaluation_period WHERE com_id=1 AND eval_year=2026 AND eval_term='H2'),
    78, 11, 'LEADER', 3, 3, 4, 2, 3, 3.10,
    '팀워크가 좋고 동료들과 협업을 잘 이끌어갑니다.',
    '건강 관리에 유의하여 결근/조퇴를 줄이고, 안정적인 출근 패턴을 유지했으면 합니다.',
    'SUBMITTED'
);

-- 80 (정수혁/주임) 연차 다수: P4 E3 T4 A4 G3 = 3.70
INSERT INTO performance_evaluation (
    eval_id, period_id, target_emp_id, evaluator_id, eval_type,
    score_performance, score_expertise, score_teamwork, score_attitude, score_growth,
    weighted_score, strength_comment, improvement_comment, eval_status
) VALUES (
    SEQ_EVAL.NEXTVAL,
    (SELECT period_id FROM evaluation_period WHERE com_id=1 AND eval_year=2026 AND eval_term='H2'),
    80, 11, 'LEADER', 4, 3, 4, 4, 3, 3.70,
    '맡은 업무에 성실하게 임하며, 근무 중에는 집중력이 뛰어납니다. 워라밸을 잘 유지하고 있습니다.',
    '연차 사용 시 업무 인수인계를 보다 체계적으로 정리해주면 좋겠습니다.',
    'SUBMITTED'
);

-- 187 (남창원/대리) 야근 과다: P5 E4 T4 A4 G5 = 4.50
INSERT INTO performance_evaluation (
    eval_id, period_id, target_emp_id, evaluator_id, eval_type,
    score_performance, score_expertise, score_teamwork, score_attitude, score_growth,
    weighted_score, strength_comment, improvement_comment, eval_status
) VALUES (
    SEQ_EVAL.NEXTVAL,
    (SELECT period_id FROM evaluation_period WHERE com_id=1 AND eval_year=2026 AND eval_term='H2'),
    187, 11, 'LEADER', 5, 4, 4, 4, 5, 4.50,
    '업무 완성도가 높고, 긴급 상황에 자발적으로 대응합니다. 성장 잠재력이 매우 높아 차기 팀 리더 후보입니다.',
    '연장 근무가 지나치게 많으니 효율적인 업무 분배를 고려해주세요. 건강 관리에 유의 바랍니다.',
    'SUBMITTED'
);

-- 196 (남나율/주임) 평범: P3 E3 T4 A4 G3 = 3.30
INSERT INTO performance_evaluation (
    eval_id, period_id, target_emp_id, evaluator_id, eval_type,
    score_performance, score_expertise, score_teamwork, score_attitude, score_growth,
    weighted_score, strength_comment, improvement_comment, eval_status
) VALUES (
    SEQ_EVAL.NEXTVAL,
    (SELECT period_id FROM evaluation_period WHERE com_id=1 AND eval_year=2026 AND eval_term='H2'),
    196, 11, 'LEADER', 3, 3, 4, 4, 3, 3.30,
    '꾸준하고 안정적인 업무 수행 능력을 보여주고 있습니다. 팀 분위기 조성에 기여합니다.',
    '자기개발을 통한 전문성 향상이 필요합니다. 자격증 취득 등을 권장합니다.',
    'SUBMITTED'
);

COMMIT;

-- ──────────────────────────────────────────────
-- 검증용 쿼리
-- ──────────────────────────────────────────────
-- 근태 건수 확인
-- SELECT emp_id, COUNT(*) cnt,
--        SUM(CASE WHEN att_status IN ('NORMAL','LATE','EARLY_LEAVE') THEN 1 ELSE 0 END) work_days,
--        SUM(CASE WHEN att_status = 'LATE' THEN 1 ELSE 0 END) late_cnt,
--        SUM(CASE WHEN att_status = 'ABSENT' THEN 1 ELSE 0 END) absent_cnt,
--        SUM(CASE WHEN att_status = 'ANNUAL' THEN 1 ELSE 0 END) annual_cnt
--   FROM attendance
--  WHERE emp_id IN (13,48,75,78,80,187,196)
--    AND att_date BETWEEN TO_DATE('2026-07-01','YYYY-MM-DD') AND TO_DATE('2026-07-31','YYYY-MM-DD')
--  GROUP BY emp_id ORDER BY emp_id;