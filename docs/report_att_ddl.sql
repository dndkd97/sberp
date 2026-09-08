-- ============================================
-- 1단계: evaluation_ai_report 근태 컬럼 추가
-- ============================================

-- 근태 통계 컬럼 8개 추가
ALTER TABLE evaluation_ai_report ADD (
    att_work_days         NUMBER        DEFAULT 0,
    att_late_count        NUMBER        DEFAULT 0,
    att_early_leave_count NUMBER        DEFAULT 0,
    att_absent_count      NUMBER        DEFAULT 0,
    att_annual_used       NUMBER(5,2)   DEFAULT 0,
    att_total_work_min    NUMBER        DEFAULT 0,
    att_overtime_min      NUMBER        DEFAULT 0,
    att_rate              NUMBER(5,2)   DEFAULT 0
);

-- 코멘트
COMMENT ON COLUMN evaluation_ai_report.att_work_days         IS '평가기간 내 출근일수';
COMMENT ON COLUMN evaluation_ai_report.att_late_count        IS '평가기간 내 지각 횟수';
COMMENT ON COLUMN evaluation_ai_report.att_early_leave_count IS '평가기간 내 조퇴 횟수';
COMMENT ON COLUMN evaluation_ai_report.att_late_count        IS '평가기간 내 지각 횟수';
COMMENT ON COLUMN evaluation_ai_report.att_absent_count      IS '평가기간 내 결근 횟수';
COMMENT ON COLUMN evaluation_ai_report.att_annual_used       IS '평가기간 내 연차 사용일 (반차=0.5)';
COMMENT ON COLUMN evaluation_ai_report.att_total_work_min    IS '평가기간 내 총 근로시간(분)';
COMMENT ON COLUMN evaluation_ai_report.att_overtime_min      IS '평가기간 내 총 연장근로시간(분)';
COMMENT ON COLUMN evaluation_ai_report.att_rate              IS '출근율(%)';

commit;