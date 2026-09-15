// pages/apct/dashboard.js
// 지원자 대시보드 (ROLE_ADMIN)
// GET /api/admin/applicant/dashboard (상태별 집계)
//
// 현재 채용 현황을 한눈에 확인하는 운영용 대시보드.
// 상세한 추이/이탈/전환 분석은 /apct/analysis에서 제공한다.

import React, { useEffect, useMemo } from "react";
import { useSelector, useDispatch } from "react-redux";
import { useTranslation } from "react-i18next";
import Link from "next/link";
import { Card, Row, Col, Button, Empty, Skeleton } from "antd";

import {
  ArrowLeftOutlined,
  BarChartOutlined,
  TeamOutlined,
  HourglassOutlined,
  TrophyOutlined,
} from "@ant-design/icons";

import { Doughnut, Bar } from "react-chartjs-2";

import {
  Chart as ChartJS,
  ArcElement,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend,
} from "chart.js";

import { fetchApplicantDashboardRequest } from "../../reducers/apct/applicantReducer";

ChartJS.register(
  ArcElement,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend
);

// 전형 순서 고정
const STATUS_ORDER = [
  "RECEIVED",
  "SCREENING",
  "INTERVIEW",
  "HIRED",
  "REJECTED",
];

export default function ApplicantDashboardPage() {
  const dispatch = useDispatch();
  const { t } = useTranslation("apct");

  const {
    dashboard,
    dashboardLoading,
    dashboardError,
  } = useSelector((state) => state.applicant);

  useEffect(() => {
    dispatch(fetchApplicantDashboardRequest());
  }, [dispatch]);

  // -----------------------------------------
  // 상태별 디자인
  // -----------------------------------------
  const STATUS_META = {
    RECEIVED: {
      text: t("common.statusLabels.received"),
      color: "#8a93a3",
    },

    SCREENING: {
      text: t("common.statusLabels.screening"),
      color: "#2563eb",
    },

    INTERVIEW: {
      text: t("common.statusLabels.interview"),
      color: "#d97706",
    },

    HIRED: {
      text: t("common.statusLabels.hired"),
      color: "#16a34a",
    },

    REJECTED: {
      text: t("common.statusLabels.rejected"),
      color: "#dc2626",
    },
  };

  // -----------------------------------------
  // 상태별 데이터
  // -----------------------------------------
  const countMap = useMemo(() => {
    const map = {};

    (dashboard || []).forEach((row) => {
      map[row.apctStatus] = row.count;
    });

    return map;
  }, [dashboard]);

  const total = STATUS_ORDER.reduce(
    (sum, key) => sum + (countMap[key] || 0),
    0
  );

  const hiredCnt = countMap.HIRED || 0;

  const inProgressCnt =
    (countMap.RECEIVED || 0) +
    (countMap.SCREENING || 0) +
    (countMap.INTERVIEW || 0);

  const hireRate =
    total > 0
      ? Math.round((hiredCnt / total) * 1000) / 10
      : 0;

  const labels = STATUS_ORDER.map(
    (key) => STATUS_META[key].text
  );

  const colors = STATUS_ORDER.map(
    (key) => STATUS_META[key].color
  );

  const values = STATUS_ORDER.map(
    (key) => countMap[key] || 0
  );

  // -----------------------------------------
  // Doughnut
  // -----------------------------------------
  const doughnutData = {
    labels,

    datasets: [
      {
        data: values,
        backgroundColor: colors,
        borderColor: "#fff",
        borderWidth: 2,
        hoverOffset: 6,
      },
    ],
  };

  const doughnutOptions = {
    maintainAspectRatio: false,

    cutout: "62%",

    plugins: {
      legend: {
        position: "bottom",

        labels: {
          boxWidth: 10,
          padding: 16,
          font: {
            size: 12.5,
          },
        },
      },

      tooltip: {
        callbacks: {
          label: (ctx) => {
            const value = ctx.raw || 0;

            const percentage =
              total > 0
                ? Math.round((value / total) * 1000) / 10
                : 0;

            return t("dashboard.doughnutTooltip", {
              label: ctx.label,
              count: value,
              pct: percentage,
            });
          },
        },
      },
    },
  };

  // -----------------------------------------
  // Bar
  // -----------------------------------------
  const barData = {
    labels,

    datasets: [
      {
        label: t("dashboard.barDatasetLabel"),
        data: values,
        backgroundColor: colors,
        borderRadius: 4,
        maxBarThickness: 46,
      },
    ],
  };

  const barOptions = {
    maintainAspectRatio: false,

    plugins: {
      legend: {
        display: false,
      },

      tooltip: {
        callbacks: {
          label: (ctx) =>
            t("dashboard.barTooltip", {
              count: ctx.raw,
            }),
        },
      },
    },

    scales: {
      x: {
        grid: {
          display: false,
        },
      },

      y: {
        beginAtZero: true,

        ticks: {
          precision: 0,
        },

        grid: {
          color: "#f0f0f0",
        },
      },
    },
  };

  return (
    <div className="sb-page">
      {/* =====================================
          페이지 헤더
      ===================================== */}
      <div className="sb-page-head">
        <div className="sb-page-head__txt">
          <Link href="/apct/list">
            <Button
              type="text"
              className="sb-page-back"
              icon={<ArrowLeftOutlined />}
            >
              {t("dashboard.backBtn")}
            </Button>
          </Link>

          <div className="sb-breadcrumb">
            {t("dashboard.breadcrumb")}
          </div>

          <h1>{t("dashboard.title")}</h1>

          <p>{t("dashboard.subtitle")}</p>
        </div>

        {/* 심화 분석 이동 */}
        <div className="sb-page-head__actions">
          <Link href="/apct/analysis">
            <Button
              type="primary"
              icon={<BarChartOutlined />}
            >
              심화 분석
            </Button>
          </Link>
        </div>
      </div>

      {/* =====================================
          Loading
      ===================================== */}
      {dashboardLoading && (
        <Card>
          <Skeleton
            active
            paragraph={{ rows: 3 }}
          />
        </Card>
      )}

      {/* =====================================
          Error
      ===================================== */}
      {!dashboardLoading && dashboardError && (
        <Card>
          <Empty description={dashboardError} />
        </Card>
      )}

      {/* =====================================
          Dashboard
      ===================================== */}
      {!dashboardLoading && !dashboardError && (
        <>
          {/* KPI */}
          <Row
            gutter={16}
            style={{ marginBottom: 16 }}
          >
            {/* 전체 지원자 */}
            <Col span={8}>
              <div className="sb-stat">
                <div className="sb-stat__top">
                  <span className="sb-stat__ico tone-violet">
                    <TeamOutlined />
                  </span>

                  <span className="sb-stat__label">
                    {t("dashboard.stats.total")}
                  </span>
                </div>

                <div className="sb-stat__val">
                  {total}

                  <span
                    style={{
                      fontSize: 14,
                      fontWeight: 650,
                    }}
                  >
                    {t("dashboard.unitPerson")}
                  </span>
                </div>
              </div>
            </Col>

            {/* 진행 중 */}
            <Col span={8}>
              <div className="sb-stat">
                <div className="sb-stat__top">
                  <span className="sb-stat__ico tone-blue">
                    <HourglassOutlined />
                  </span>

                  <span className="sb-stat__label">
                    {t("dashboard.stats.inProgress")}
                  </span>
                </div>

                <div className="sb-stat__val">
                  {inProgressCnt}

                  <span
                    style={{
                      fontSize: 14,
                      fontWeight: 650,
                    }}
                  >
                    {t("dashboard.unitPerson")}
                  </span>
                </div>

                <span className="sb-stat__delta flat">
                  {t("dashboard.inProgressDetail", {
                    received: countMap.RECEIVED || 0,
                    screening: countMap.SCREENING || 0,
                    interview: countMap.INTERVIEW || 0,
                  })}
                </span>
              </div>
            </Col>

            {/* 채용률 */}
            <Col span={8}>
              <div className="sb-stat">
                <div className="sb-stat__top">
                  <span className="sb-stat__ico tone-green">
                    <TrophyOutlined />
                  </span>

                  <span className="sb-stat__label">
                    {t("dashboard.stats.hireRate")}
                  </span>
                </div>

                <div className="sb-stat__val">
                  {hireRate}

                  <span
                    style={{
                      fontSize: 14,
                      fontWeight: 650,
                    }}
                  >
                    %
                  </span>
                </div>

                <span className="sb-stat__delta flat">
                  {t("dashboard.hireRateDetail", {
                    hired: hiredCnt,
                    total,
                  })}
                </span>
              </div>
            </Col>
          </Row>

          {/* 차트 */}
          {total === 0 ? (
            <Card>
              <Empty
                description={t(
                  "dashboard.emptyData"
                )}
              />
            </Card>
          ) : (
            <Row gutter={16}>
              {/* Doughnut */}
              <Col span={10}>
                <Card
                  title={t(
                    "dashboard.charts.distribution"
                  )}
                  bodyStyle={{ height: 300 }}
                >
                  <Doughnut
                    data={doughnutData}
                    options={doughnutOptions}
                  />
                </Card>
              </Col>

              {/* Bar */}
              <Col span={14}>
                <Card
                  title={t(
                    "dashboard.charts.byStatus"
                  )}
                  bodyStyle={{ height: 300 }}
                >
                  <Bar
                    data={barData}
                    options={barOptions}
                  />
                </Card>
              </Col>
            </Row>
          )}
        </>
      )}
    </div>
  );
}