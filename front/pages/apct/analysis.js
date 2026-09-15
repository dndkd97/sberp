// pages/apct/analysis.js
// 채용 데이터 심화 분석

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { Button, Empty, Skeleton } from "antd";

import {
  ArrowLeftOutlined,
  BarChartOutlined,
  RiseOutlined,
  TeamOutlined,
  TrophyOutlined,
} from "@ant-design/icons";

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Tooltip,
  Legend,
} from "chart.js";

import { Bar, Line } from "react-chartjs-2";

import api from "../../api/axios";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Tooltip,
  Legend
);

export default function ApplicantAnalysisPage() {
  const [analysis, setAnalysis] = useState(null);
  const [loading, setLoading] = useState(true);

  // Django + Pandas 분석 결과 조회
  useEffect(() => {
    const fetchAnalysis = async () => {
      try {
        const response = await api.get(
          "/api/admin/applicant/analysis"
        );

        setAnalysis(response.data.data);
      } catch (error) {
        console.error(
          "지원자 심화 분석 조회 실패:",
          error
        );
      } finally {
        setLoading(false);
      }
    };

    fetchAnalysis();
  }, []);

  // 로딩
  if (loading) {
    return (
      <main className="sb-content">
        <div className="sb-page-head">
          <div className="sb-page-head__txt">
            <div className="sb-breadcrumb">
              <Link href="/">홈</Link>
              <i className="bi bi-chevron-right"></i>
              <Link href="/apct/dashboard">
                지원자 관리
              </Link>
              <i className="bi bi-chevron-right"></i>
              데이터 분석
            </div>
            <h1>채용 데이터 분석</h1>
            <p> 지원자 현황을 넘어 채용 데이터의 추이와 특징을 분석합니다. </p>
          </div>
          <div className="sb-page-head__actions">
            <Link href="/apct/dashboard">
              <Button size="small" icon={<ArrowLeftOutlined />} > 대시보드 </Button>
            </Link>
          </div>
        </div>
        <div className="sb-card">
          <div className="sb-card__body">
            <Skeleton active />
          </div>
        </div>
      </main>
    );
  }

  // 데이터 없음
  if (!analysis) {
    return (
      <main className="sb-content">
        <div className="sb-page-head">
          <div className="sb-page-head__txt">
            <div className="sb-breadcrumb">
              <Link href="/">홈</Link>
              <i className="bi bi-chevron-right"></i>
              <Link href="/apct/dashboard">
                지원자 관리
              </Link>
              <i className="bi bi-chevron-right"></i>
              데이터 분석
            </div>
            <h1>채용 데이터 분석</h1>
            <p> 지원자 현황을 넘어 채용 데이터의 추이와 특징을 분석합니다. </p>
          </div>
          <div className="sb-page-head__actions">
            <Link href="/apct/dashboard">
              <Button size="small" icon={<ArrowLeftOutlined />} > 대시보드 </Button>
            </Link>
          </div>
        </div>
        <div className="sb-card">
          <div className="sb-card__body">
            <Empty
              description="분석 데이터를 불러오지 못했습니다."
            />
          </div>
        </div>
      </main>
    );
  }

  // 월별 분석 데이터
  const monthlyTrend = analysis.monthlyTrend || [];
  const monthlyCounts = monthlyTrend.map( (item) => Number(item.count) || 0 );
  const getMonthLabel = (item) => { if (!item?.date) { return "-"; }
    const date = new Date(item.date);
    if (Number.isNaN(date.getTime())) { return item.date; }
    return `${date.getMonth() + 1}월`;
  };

  // 월별 통계 계산
  const monthlyStats = (() => {
  if (monthlyCounts.length === 0) {
    return {
      average: 0,
      max: 0,
      min: 0,
      maxMonth: "-",
      minMonth: "-",
    };
  }

  const total = monthlyCounts.reduce( (sum, count) => sum + count, 0 );
  const average = Math.round( (total / monthlyCounts.length) * 10 ) / 10;
  const max = Math.max(...monthlyCounts);
  const min = Math.min(...monthlyCounts);
  const maxIndex = monthlyCounts.indexOf(max);
  const minIndex = monthlyCounts.indexOf(min);

  return {
    average, max, min,
    maxMonth:
      maxIndex >= 0
        ? getMonthLabel(monthlyTrend[maxIndex])
        : "-",

    minMonth:
      minIndex >= 0
        ? getMonthLabel(monthlyTrend[minIndex])
        : "-",
  };
})();

  // 최근 월 변화
  const latestCount =
    monthlyCounts.length > 0
      ? monthlyCounts[monthlyCounts.length - 1]
      : 0;

  const previousCount =
    monthlyCounts.length > 1
      ? monthlyCounts[monthlyCounts.length - 2]
      : 0;

  const latestMonth =
    monthlyTrend.length > 0
      ? getMonthLabel(
          monthlyTrend[monthlyTrend.length - 1]
        )
      : "-";

  const previousMonth =
    monthlyTrend.length > 1
      ? getMonthLabel(
          monthlyTrend[monthlyTrend.length - 2]
        )
      : "-";

  const monthChange =
    previousCount > 0
      ? Math.round(
          ((latestCount - previousCount) /
            previousCount) *
            1000
        ) / 10
      : 0;

  // 월별 지원자 추이
  const monthlyApplicants = {
    labels: monthlyTrend.map((item) => getMonthLabel(item) ),
    datasets: [
      {
        label: "지원자 수",
        data: monthlyCounts,
        borderColor: "#4f6ef7",
        backgroundColor: "rgba(79, 110, 247, 0.15)",
        fill: true,
        borderWidth: 2,
        tension: 0.35,
        pointRadius: 4,
        pointHoverRadius: 6,
        pointBackgroundColor: "#4f6ef7",
      },
    ],
  };

  const monthlyOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false, },
      tooltip: { callbacks: { label: (ctx) => ` ${ctx.raw}명`, }, },
    },
    scales: { x: { grid: { display: false, }, },
      y: { beginAtZero: true, ticks: { precision: 0, callback: (value) => `${value}명`, }, },
    },
  };

  // 월별 지원자 비교
  const monthlyBarData = {
    labels: monthlyTrend.map((item) => getMonthLabel(item) ),
    datasets: [
      {
        label: "지원자 수",
        data: monthlyCounts,
        backgroundColor: "#7c8cf8",
        borderRadius: 5,
        maxBarThickness: 48,
      },
    ],
  };
  const monthlyBarOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false, },
      tooltip: { callbacks: { label: (ctx) => ` 지원자 ${ctx.raw}명`, }, },
    },
    scales: { 
      x: { grid: { display: false, }, },
      y: {
        beginAtZero: true,
        ticks: { precision: 0,
          callback: (value) => `${value}명`,
        },
      },
    },
  };

  return (
    <main className="sb-content">
      {/* 페이지 헤더 */}
      <div className="sb-page-head">
        <div className="sb-page-head__txt">
          <div className="sb-breadcrumb">
            <Link href="/">홈</Link>
            <i className="bi bi-chevron-right"></i>
            <Link href="/apct/dashboard">
              지원자 관리
            </Link>
            <i className="bi bi-chevron-right"></i>
            데이터 분석
          </div>
          <h1>채용 데이터 분석</h1>
          <p> 지원자 현황을 넘어 채용 데이터의 추이와 특징을 분석합니다. </p>
        </div>
        <div className="sb-page-head__actions">
          <Link href="/apct/dashboard">
            <Button size="small" icon={<ArrowLeftOutlined />} > 대시보드 </Button>
          </Link>
        </div>
      </div>
      {/* 분석 KPI */}
      <div className="row g-3 mb-3">
        {/* 월평균 지원자 */}
        <div className="col" style={{ flex: "0 0 25%", maxWidth: "25%", }} >
          <div className="sb-stat h-100">
            <div className="sb-stat__top">
              <span className="sb-stat__ico tone-violet">
                <TeamOutlined />
              </span>
              <span className="sb-stat__label"> 월평균 지원자 </span>
            </div>
            <div className="sb-stat__val">
              {monthlyStats.average}
              <span style={{ fontSize: 14, fontWeight: 650, }} > 명 </span>
            </div>
          </div>
        </div>
        {/* 최다 지원 월 */}
        <div className="col" style={{ flex: "0 0 25%", maxWidth: "25%", }} >
          <div className="sb-stat h-100">
            <div className="sb-stat__top">
              <span className="sb-stat__ico tone-blue">
                <BarChartOutlined />
              </span>
              <span className="sb-stat__label"> 최다 지원 월 </span>
            </div>
            <div className="sb-stat__val"> {monthlyStats.maxMonth} </div>
            <span className="sb-stat__delta flat"> {monthlyStats.max}명 지원 </span>
          </div>
        </div>
        {/* 최근 월 지원자 */}
        <div className="col" style={{ flex: "0 0 25%", maxWidth: "25%", }} >
          <div className="sb-stat h-100">
            <div className="sb-stat__top">
              <span className="sb-stat__ico tone-green">
                <RiseOutlined />
              </span>
              <span className="sb-stat__label"> 최근 월 지원자 </span>
            </div>
            <div className="sb-stat__val">
              {latestCount}
              <span style={{ fontSize: 14, fontWeight: 650, }} > 명 </span>
            </div>

            <span className="sb-stat__delta flat">
              {monthChange > 0
                ? `전월 대비 ${monthChange}% 증가`
                : monthChange < 0
                ? `전월 대비 ${Math.abs(
                    monthChange
                  )}% 감소`
                : "전월과 동일"}
            </span>
          </div>
        </div>
        {/* 최저 지원 월 */}
        <div className="col" style={{ flex: "0 0 25%", maxWidth: "25%", }} >
          <div className="sb-stat h-100">
            <div className="sb-stat__top">
              <span className="sb-stat__ico tone-red">
                <TrophyOutlined />
              </span>
              <span className="sb-stat__label"> 최저 지원 월 </span>
            </div>
            <div className="sb-stat__val"> {monthlyStats.minMonth} </div>
            <span className="sb-stat__delta flat"> {monthlyStats.min}명 지원 </span>
          </div>
        </div>
      </div>
      {/* 월별 지원자 추이 */}

      <div className="sb-card mb-3">
        <div className="sb-card__head">
          <div>
            <h2 className="mb-1"> 월별 지원자 추이 </h2>
            <p className="text-faint mb-0"> 월별 지원자 규모가 어떻게 변화했는지 확인합니다. </p>
          </div>
        </div>
        <div className="sb-card__body">
          <div style={{ height: 320 }}>
            {monthlyTrend.length > 0 ? (
              <Line
                data={monthlyApplicants}
                options={monthlyOptions}
              />
            ) : (
              <Empty
                description="월별 데이터가 없습니다."
              />
            )}
          </div>
        </div>
      </div>

      {/* 월별 지원 규모 비교 */}

      <div className="sb-card mb-3">
        <div className="sb-card__head">
          <div>
            <h2 className="mb-1"> 월별 지원 규모 비교 </h2>
            <p className="text-faint mb-0"> 각 월의 지원자 수를 비교하여 지원 규모의 차이를 확인합니다. </p>
          </div>
        </div>
        <div className="sb-card__body">
          <div style={{ height: 320 }}>
            {monthlyTrend.length > 0 ? (
              <Bar
                data={monthlyBarData}
                options={monthlyBarOptions}
              />
            ) : (
              <Empty
                description="비교할 데이터가 없습니다."
              />
            )}
          </div>
        </div>
      </div>

      {/* 주요 분석 결과 */}
      <div className="sb-card">
        <div className="sb-card__head">
          <div>
            <h2 className="mb-1"> 주요 분석 결과 </h2>
            <p className="text-faint mb-0"> 월별 지원 데이터를 기준으로 확인되는 주요 특징입니다. </p>
          </div>
        </div>
        <div className="sb-card__body">
          <div className="row g-4">
            {/* 평균 */}
            <div className="col-md-4">
              <div className="text-faint mb-2"> 월평균 지원자 </div>
              <strong className="fs-4"> {monthlyStats.average}명 </strong>
              <div className="text-faint mt-1"> 총 {monthlyTrend.length}개월 기준 </div>
            </div>
            {/* 최대 */}
            <div className="col-md-4">
              <div className="text-faint mb-2"> 지원자가 가장 많았던 월 </div>
              <strong className="fs-5"> {monthlyStats.maxMonth} </strong>
              <div className="text-faint mt-1"> {monthlyStats.max}명 지원 </div>
            </div>
            {/* 최근 변화 */}
            <div className="col-md-4">
              <div className="text-faint mb-2"> 최근 지원 규모 변화 </div>
              <strong className="fs-5">
                {monthChange > 0
                  ? `+${monthChange}%`
                  : `${monthChange}%`}
              </strong>
              <div className="text-faint mt-1">
                {previousMonth} → {latestMonth}
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
