import json
import pandas as pd

from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt

from .models import ApplicantStatusLog


STATUS_LABELS = {
    'RECEIVED': '접수',
    'SCREENING': '서류심사',
    'INTERVIEW': '면접',
    'HIRED': '합격',
    'REJECTED': '불합격',
}

STATUS_ORDER = [
    'RECEIVED',
    'SCREENING',
    'INTERVIEW',
    'HIRED',
    'REJECTED',
]


def dashboard_view(request):

    # DB에서 통계 데이터 가져오기
    qs = ApplicantStatusLog.objects.all().values(
        'date',
        'status',
        'count'
    )

    if not qs.exists():
        context = {
            'labels': [],
            'values': [],
            'total_count': 0,
            'top_status': '데이터 없음',
            
            'average_conversion': 0,
            'max_drop_stage': '데이터 없음',
            'max_drop_count': 0,
            'max_drop_rate': 0,

            'conversion_data': [],
        }

        return render(
            request,
            'analytics/dashboard.html',
            context
        )

    # --------------------------------------------------
    # Pandas DataFrame 생성
    # --------------------------------------------------

    df = pd.DataFrame(list(qs))

    # 날짜별 최신 데이터만 사용
    latest_date = df['date'].max()

    today_df = df[df['date'] == latest_date].copy()

    # 전형 순서 고정
    today_df = (
        today_df
        .set_index('status')
        .reindex(STATUS_ORDER, fill_value=0)
        .reset_index()
    )

    today_df['count'] = (
        today_df['count']
        .fillna(0)
        .astype(int)
    )

    # --------------------------------------------------
    # 단계별 데이터
    # --------------------------------------------------

    labels = [
        STATUS_LABELS[status]
        for status in today_df['status']
    ]

    values = today_df['count'].tolist()

    total_count = int(today_df['count'].sum())

    # 가장 많은 지원자가 있는 단계
    if values and max(values) > 0:
        top_index = values.index(max(values))
        top_status = labels[top_index]
    else:
        top_status = '데이터 없음'
    top_count = max(values) if values else 0
    # --------------------------------------------------
    # 단계별 전환율 / 이탈률 분석
    # --------------------------------------------------

    conversion_data = []

    conversion_rates = []

    max_drop_count = 0
    max_drop_rate = 0
    max_drop_stage = '데이터 없음'

    for i in range(len(STATUS_ORDER) - 1):

        current_status = STATUS_ORDER[i]
        next_status = STATUS_ORDER[i + 1]

        current_count = int(
            today_df.loc[
                today_df['status'] == current_status,
                'count'
            ].iloc[0]
        )

        next_count = int(
            today_df.loc[
                today_df['status'] == next_status,
                'count'
            ].iloc[0]
        )

        # 전환율
        if current_count > 0:
            conversion_rate = round(
                (next_count / current_count) * 100,
                1
            )
        else:
            conversion_rate = 0

        # 이탈 인원
        drop_count = max(
            current_count - next_count,
            0
        )

        # 이탈률
        if current_count > 0:
            drop_rate = round(
                (drop_count / current_count) * 100,
                1
            )
        else:
            drop_rate = 0

        conversion_rates.append(
            conversion_rate
        )

        conversion_data.append({
            'from_status': STATUS_LABELS[current_status],
            'to_status': STATUS_LABELS[next_status],
            'from_count': current_count,
            'to_count': next_count,
            'conversion_rate': conversion_rate,
            'drop_count': drop_count,
            'drop_rate': drop_rate,
        })

        # 가장 큰 이탈 구간 찾기
        if drop_count > max_drop_count:
            max_drop_count = drop_count
            max_drop_rate = drop_rate

            max_drop_stage = (
                f"{STATUS_LABELS[current_status]} → "
                f"{STATUS_LABELS[next_status]}"
            )

    # --------------------------------------------------
    # 평균 전환율
    # --------------------------------------------------

    if conversion_rates:
        average_conversion = round(
            sum(conversion_rates) / len(conversion_rates),
            1
        )
    else:
        average_conversion = 0

    # --------------------------------------------------
    # 화면으로 전달
    # --------------------------------------------------

    context = {
        'labels': labels,
        'values': values,

        'total_count': total_count,
        'top_status': top_status,
        'top_count': top_count,
        'average_conversion': average_conversion,

        'max_drop_stage': max_drop_stage,
        'max_drop_count': max_drop_count,
        'max_drop_rate': max_drop_rate,

        'conversion_data': conversion_data,
    }

    return render(
        request,
        'analytics/dashboard.html',
        context
    )


@csrf_exempt
def api_receive_statistics(request):

    if request.method != 'POST':
        return JsonResponse(
            {
                'status': 'fail',
                'message': 'POST 요청만 지원합니다.'
            },
            status=405
        )

    try:

        data = json.loads(request.body)

        ApplicantStatusLog.objects.update_or_create(
            date=data.get('date'),
            status=data.get('category'),
            defaults={
                'count': data.get('count', 0)
            }
        )

        return JsonResponse({
            'status': 'success',
            'message': '통계 데이터 갱신 완료!'
        })

    except Exception as e:

        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)
        
@csrf_exempt
def api_analysis(request):

    if request.method != 'POST':
        return JsonResponse(
            {
                'status': 'fail',
                'message': 'POST 요청만 지원합니다.'
            },
            status=405
        )

    try:

        data = json.loads(request.body)

        status_counts = data.get('statusCounts', [])
        monthly_counts = data.get('monthlyCounts', [])

        # -----------------------------------------
        # 상태별 실제 지원자 데이터
        # -----------------------------------------

        status_df = pd.DataFrame(status_counts)

        if status_df.empty:
            status_df = pd.DataFrame({
                'status': STATUS_ORDER,
                'count': [0] * len(STATUS_ORDER)
            })
        else:
            status_df['count'] = (
                pd.to_numeric(status_df['count'], errors='coerce')
                .fillna(0)
                .astype(int)
            )

            status_df = (
                status_df
                .set_index('status')
                .reindex(STATUS_ORDER, fill_value=0)
                .reset_index()
            )

            status_df['count'] = (
                status_df['count'].fillna(0).astype(int)
            )

        counts = dict(zip(status_df['status'], status_df['count']))

        # -----------------------------------------
        # 파이프라인 정의 (REJECTED는 별도 처리)
        # -----------------------------------------

        PIPELINE_ORDER = ['RECEIVED', 'SCREENING', 'INTERVIEW', 'HIRED']

        rejected_count = int(counts.get('REJECTED', 0))
        active_total = sum(int(counts.get(s, 0)) for s in PIPELINE_ORDER)
        total_count = active_total + rejected_count

        # -----------------------------------------
        # 진행 중
        # -----------------------------------------

        in_progress_status = ['RECEIVED', 'SCREENING', 'INTERVIEW']
        in_progress = sum(int(counts.get(s, 0)) for s in in_progress_status)

        # -----------------------------------------
        # 상태별 분포 (현재 스냅샷, 그대로 유지)
        # -----------------------------------------

        status_distribution = []
        for status in STATUS_ORDER:
            status_distribution.append({
                'status': status,
                'label': STATUS_LABELS[status],
                'count': int(counts.get(status, 0)),
            })

        # -----------------------------------------
        # 월별 실제 지원자 추이
        # -----------------------------------------

        monthly_df = pd.DataFrame(monthly_counts)
        monthly_trend = []

        if not monthly_df.empty:
            monthly_df['count'] = (
                pd.to_numeric(monthly_df['count'], errors='coerce')
                .fillna(0)
                .astype(int)
            )
            monthly_df = monthly_df.sort_values('month')

            for _, row in monthly_df.iterrows():
                monthly_trend.append({
                    'date': str(row['month']),
                    'count': int(row['count']),
                })

        # -----------------------------------------
        # 누적 통과 인원 계산 (뒤에서부터 누적)
        # -----------------------------------------

        reached = {}
        running = 0
        for s in reversed(PIPELINE_ORDER):
            running += int(counts.get(s, 0))
            reached[s] = running

        # -----------------------------------------
        # 전형별 전환 / 정체 분석 (파이프라인 4단계만, REJECTED 제외)
        # -----------------------------------------

        conversion_data = []
        conversion_rates = []

        max_stall_count = 0
        max_stall_rate = 0
        max_stall_stage = '데이터 없음'

        for i in range(len(PIPELINE_ORDER) - 1):

            current_status = PIPELINE_ORDER[i]
            next_status = PIPELINE_ORDER[i + 1]

            current_reached = reached[current_status]
            next_reached = reached[next_status]

            if current_reached > 0:
                conversion_rate = round(
                    (next_reached / current_reached) * 100, 1
                )
            else:
                conversion_rate = 0

            # 현재 이 단계에 머물러 있는(다음으로 못 넘어간) 인원
            stall_count = int(counts.get(current_status, 0))

            if current_reached > 0:
                stall_rate = round(
                    (stall_count / current_reached) * 100, 1
                )
            else:
                stall_rate = 0

            conversion_rates.append(conversion_rate)

            conversion_data.append({
                'from_status': STATUS_LABELS[current_status],
                'to_status': STATUS_LABELS[next_status],
                'from_count': current_reached,
                'to_count': next_reached,
                'conversion_rate': conversion_rate,
                'drop_count': stall_count,
                'drop_rate': stall_rate,
            })

            if stall_count > max_stall_count:
                max_stall_count = stall_count
                max_stall_rate = stall_rate
                max_stall_stage = (
                    f"{STATUS_LABELS[current_status]} → "
                    f"{STATUS_LABELS[next_status]}"
                )

        if conversion_rates:
            average_conversion = round(
                sum(conversion_rates) / len(conversion_rates), 1
            )
        else:
            average_conversion = 0

        # -----------------------------------------
        # 탈락률 (전체 지원자 대비, 파이프라인과 별도)
        # -----------------------------------------

        rejection_rate = (
            round((rejected_count / total_count) * 100, 1)
            if total_count > 0 else 0
        )

        # -----------------------------------------
        # 가장 많은 단계 (현재 스냅샷 기준)
        # -----------------------------------------

        values = [int(counts.get(s, 0)) for s in STATUS_ORDER]

        if values and max(values) > 0:
            top_index = values.index(max(values))
            top_status = STATUS_LABELS[STATUS_ORDER[top_index]]
            top_count = max(values)
        else:
            top_status = '데이터 없음'
            top_count = 0

        # -----------------------------------------
        # JSON 반환
        # -----------------------------------------

        return JsonResponse({
            'status': 'success',
            'data': {
                'totalCount': total_count,
                'inProgress': in_progress,
                'latestDate': None,
                'topStatus': top_status,
                'topStatusCount': top_count,
                'averageConversion': average_conversion,
                'maxDropStage': max_stall_stage,
                'maxDropCount': max_stall_count,
                'maxDropRate': max_stall_rate,
                'rejectedCount': rejected_count,
                'rejectionRate': rejection_rate,
                'statusDistribution': status_distribution,
                'monthlyTrend': monthly_trend,
                'conversionData': conversion_data,
            }
        })

    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)