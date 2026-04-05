import { useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import { useAuth } from "../hooks/useAuth";
import type { AnalyticsOverview } from "../types";
import { titleize } from "../utils/format";

export function AnalyticsPage() {
  const { token } = useAuth();
  const [analytics, setAnalytics] = useState<AnalyticsOverview | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!token) {
      return;
    }
    api.analytics(token).then(setAnalytics).catch((err: Error) => setError(err.message));
  }, [token]);

  const statusChart = useMemo(() => {
    const stateCounts = analytics?.by_state ?? {};
    const completed = stateCounts.done ?? 0;
    const inProgress = (stateCounts.in_progress ?? 0) + (stateCounts.review ?? 0);
    const pending = stateCounts.todo ?? 0;
    const total = completed + inProgress + pending;

    const segments = [
      { label: "Completed", value: completed, color: "#57b89b" },
      { label: "In Progress", value: inProgress, color: "#2c95ff" },
      { label: "Pending", value: pending, color: "#f2b55f" }
    ];

    if (!total) {
      return {
        total,
        segments,
        gradient: "conic-gradient(#dfeaf7 0deg 360deg)"
      };
    }

    let currentAngle = 0;
    const stops = segments.map((segment) => {
      const angle = (segment.value / total) * 360;
      const start = currentAngle;
      currentAngle += angle;
      return `${segment.color} ${start}deg ${currentAngle}deg`;
    });

    return {
      total,
      segments,
      gradient: `conic-gradient(${stops.join(", ")})`
    };
  }, [analytics]);

  const priorityChart = useMemo(() => {
    const priorityCounts = analytics?.by_priority ?? {};
    return [
      {
        label: "High",
        value: (priorityCounts.high ?? 0) + (priorityCounts.critical ?? 0),
        tone: "high"
      },
      {
        label: "Medium",
        value: priorityCounts.medium ?? 0,
        tone: "medium"
      },
      {
        label: "Low",
        value: priorityCounts.low ?? 0,
        tone: "low"
      }
    ];
  }, [analytics]);

  const downloadExport = async () => {
    if (!token) {
      return;
    }
    const blob = await api.exportTasks(token);
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "tasks-export.csv";
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <section className="page-shell analytics-page">
      <div className="page-header">
        <div>
          <h1>Task analytics and reporting</h1>
        </div>
        <div className="header-actions">
          <button className="secondary-button" onClick={downloadExport}>
            Export tasks
          </button>
        </div>
      </div>

      {error ? <div className="error-banner">{error}</div> : null}

      <div className="analytics-grid analytics-panels">
        <section className="panel analytics-panel">
          <div className="section-heading">
            <div>
              <h3>Task Overview</h3>
              <p className="muted-inline">Workload split by task status.</p>
            </div>
          </div>
          <div className="status-donut-layout">
            <div className="status-donut-card">
              <div className="status-donut" style={{ background: statusChart.gradient }}>
                <div className="status-donut-center">
                  <strong>{statusChart.total}</strong>
                  <span>Total</span>
                </div>
              </div>
            </div>
            <div className="status-donut-legend">
              {statusChart.segments.map((segment) => (
                <div key={segment.label} className="status-legend-item">
                  <span className="status-legend-dot" style={{ background: segment.color }} />
                  <span>{segment.label}</span>
                  <strong>{segment.value}</strong>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="panel analytics-panel">
          <div className="section-heading">
            <div>
              <h3>Priority Breakdown</h3>
              <p className="muted-inline">Urgent workload concentration across priorities.</p>
            </div>
          </div>
          <div className="priority-bar-chart">
            {priorityChart.map((item) => {
              const maxCount = Math.max(...priorityChart.map((entry) => entry.value), 1);
              const width = Math.max((item.value / maxCount) * 100, item.value ? 14 : 0);
              return (
                <div key={item.label} className="priority-bar-row">
                  <div className="priority-bar-header">
                    <span className="priority-bar-label">{item.label}</span>
                    <strong className="priority-bar-value">{item.value}</strong>
                  </div>
                  <div className="priority-bar-track">
                    <div
                      className={`priority-bar-fill analytics-priority-${item.tone}`}
                      style={{ width: `${width}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        <section className="panel analytics-panel analytics-panel-wide">
          <div className="section-heading">
            <div>
              <h3>User Performance Metrics</h3>
              <p className="muted-inline">Completed tasks by contributor.</p>
            </div>
          </div>
          <div className="mini-chart analytics-compact-chart">
            {(analytics?.user_performance ?? []).length ? (
              analytics?.user_performance.map((entry) => (
                <div key={entry.user} className="bar-row">
                  <span>{entry.user}</span>
                  <div className="bar-track">
                    <div className="bar-fill" style={{ width: `${Math.max(entry.completed_tasks, 1) * 20}px` }} />
                  </div>
                  <strong>{entry.completed_tasks}</strong>
                </div>
              ))
            ) : (
              <div className="empty-state">No user performance data yet.</div>
            )}
          </div>
        </section>

        <section className="panel analytics-panel analytics-panel-wide">
          <div className="section-heading">
            <div>
              <h3>Task Trends Over Time</h3>
              <p className="muted-inline">Completion trend across dates.</p>
            </div>
          </div>
          <div className="trend-chart-card">
            {(analytics?.completed_over_time ?? []).length ? (
              (() => {
                const points = analytics?.completed_over_time ?? [];
                const maxCount = Math.max(...points.map((item) => item.count), 1);
                const chartWidth = 760;
                const chartHeight = 220;
                const paddingX = 36;
                const paddingTop = 24;
                const paddingBottom = 36;
                const usableWidth = chartWidth - paddingX * 2;
                const usableHeight = chartHeight - paddingTop - paddingBottom;

                const chartPoints = points.map((point, index) => {
                  const x = points.length === 1
                    ? chartWidth / 2
                    : paddingX + (index / (points.length - 1)) * usableWidth;
                  const y = paddingTop + usableHeight - (point.count / maxCount) * usableHeight;
                  return { ...point, x, y };
                });

                const polylinePoints = chartPoints.map((point) => `${point.x},${point.y}`).join(" ");

                return (
                  <div className="trend-line-chart">
                    <svg viewBox={`0 0 ${chartWidth} ${chartHeight}`} className="trend-line-svg" preserveAspectRatio="none" aria-label="Task trends line chart">
                      <line
                        x1={paddingX}
                        y1={chartHeight - paddingBottom}
                        x2={chartWidth - paddingX}
                        y2={chartHeight - paddingBottom}
                        className="trend-line-axis"
                      />
                      <polyline
                        points={polylinePoints}
                        fill="none"
                        className="trend-line-path"
                      />
                      {chartPoints.map((point) => (
                        <g key={point.date}>
                          <circle cx={point.x} cy={point.y} r="5" className="trend-line-point" />
                          <text x={point.x} y={point.y - 14} textAnchor="middle" className="trend-line-value">
                            {point.count}
                          </text>
                          <text x={point.x} y={chartHeight - 10} textAnchor="middle" className="trend-line-label">
                            {point.date}
                          </text>
                        </g>
                      ))}
                    </svg>
                  </div>
                );
              })()
            ) : (
              <div className="empty-state">No trend data yet.</div>
            )}
          </div>
        </section>
      </div>
    </section>
  );
}
