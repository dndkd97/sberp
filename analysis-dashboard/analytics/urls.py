from django.urls import path

from . import views


urlpatterns = [
    path('', views.dashboard_view, name='dashboard'),

    # Spring → Django 통계 저장
    path(
        'api/statistics/',
        views.api_receive_statistics,
        name='api_receive_statistics'
    ),

    # 분석 결과 조회
    path(
        'api/analysis/',
        views.api_analysis,
        name='api_analysis'
    ),
]