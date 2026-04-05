import { useEffect, useState } from "react";
import { api } from "../api/client";
import { useAuth } from "../hooks/useAuth";
import type { DashboardOverview } from "../types";
import { formatDate, titleize } from "../utils/format";

export function DashboardPage() {
  const { token } = useAuth();
  const [dashboard, setDashboard] = useState<DashboardOverview | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!token) {
      return;
    }

    setLoading(true);
    setError("");
    api.dashboard(token)
      .then(setDashboard)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false));
  }, [token]);

  return (
    <section className="page-shell dashboard-page">
      <div className="page-header">
        <div>
          <h1>Workspace dashboard</h1>
        </div>
      </div>

      {error ? <div className="error-banner">{error}</div> : null}
      {loading ? <div className="panel">Loading dashboard...</div> : null}

      {!loading && dashboard ? (
        <>
          <div className="dashboard-top-grid">
            <section className="panel dashboard-total-card">
              <span>Total Tasks</span>
              <strong>{dashboard.total}</strong>
              <p>All active work items currently tracked in the workspace.</p>
              <div className="dashboard-primary-metric-foot">
                <span className="dashboard-pill-neutral">{dashboard.my_work[0]?.value ?? 0} assigned to me</span>
                <span className="dashboard-pill-warning">{dashboard.due_soon.length} due soon</span>
                <span className="dashboard-pill-danger">{dashboard.overdue} overdue</span>
              </div>
            </section>

            <section className="panel dashboard-summary-card">
              <div className="section-heading">
                <div>
                  <h3>By State</h3>
                </div>
              </div>
              <div className="dashboard-mini-card-grid">
                {dashboard.state_cards.map((item) => (
                  <div key={item.label} className={`dashboard-mini-card dashboard-mini-card-state-${item.label.toLowerCase().replace(/\s+/g, "-")}`}>
                    <span>{item.label}</span>
                    <strong>{item.value}</strong>
                  </div>
                ))}
              </div>
            </section>

            <section className="panel dashboard-summary-card">
              <div className="section-heading">
                <div>
                  <h3>By Priority</h3>
                </div>
              </div>
              <div className="dashboard-mini-card-grid">
                {dashboard.priority_cards.map((item) => (
                  <div key={item.label} className={`dashboard-mini-card dashboard-mini-card-priority-${item.label.toLowerCase()}`}>
                    <span>{item.label}</span>
                    <strong>{item.value}</strong>
                  </div>
                ))}
              </div>
            </section>
          </div>

          <div className="dashboard-layout">
            <section className="panel dashboard-card">
              <div className="section-heading">
                <div>
                  <h3>Due Timeline</h3>
                  <p className="muted-inline">Tasks due per day over the next 7 days.</p>
                </div>
              </div>
              <div className="dashboard-trend-card">
                {dashboard.due_timeline.some((point) => point.count > 0) ? (
                  (() => {
                    const points = dashboard.due_timeline;
                    const maxCount = Math.max(...points.map((item) => item.count), 1);
                    const chartWidth = 620;
                    const chartHeight = 200;
                    const paddingX = 28;
                    const paddingTop = 24;
                    const paddingBottom = 34;
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
                    const areaPoints = [
                      `${paddingX},${chartHeight - paddingBottom}`,
                      ...chartPoints.map((point) => `${point.x},${point.y}`),
                      `${chartWidth - paddingX},${chartHeight - paddingBottom}`,
                    ].join(" ");
                    const gridLevels = [0.25, 0.5, 0.75];

                    return (
                      <div className="dashboard-trend-line">
                        <svg viewBox={`0 0 ${chartWidth} ${chartHeight}`} className="dashboard-trend-svg" preserveAspectRatio="none" aria-label="Tasks due timeline">
                          <defs>
                            <linearGradient id="dashboardTrendFill" x1="0" y1="0" x2="0" y2="1">
                              <stop offset="0%" stopColor="#0f6cbd" stopOpacity="0.22" />
                              <stop offset="100%" stopColor="#0f6cbd" stopOpacity="0.03" />
                            </linearGradient>
                          </defs>
                          {gridLevels.map((level) => {
                            const y = paddingTop + usableHeight - usableHeight * level;
                            return (
                              <line
                                key={level}
                                x1={paddingX}
                                y1={y}
                                x2={chartWidth - paddingX}
                                y2={y}
                                className="dashboard-trend-grid"
                              />
                            );
                          })}
                          <line
                            x1={paddingX}
                            y1={chartHeight - paddingBottom}
                            x2={chartWidth - paddingX}
                            y2={chartHeight - paddingBottom}
                            className="trend-line-axis"
                          />
                          <polygon points={areaPoints} className="dashboard-trend-area" />
                          <polyline points={polylinePoints} fill="none" className="dashboard-trend-path" />
                          {chartPoints.map((point) => (
                            <g key={point.date}>
                              <circle cx={point.x} cy={point.y} r="5" className="dashboard-trend-point" />
                              <text x={point.x} y={point.y - 12} textAnchor="middle" className="dashboard-trend-value">
                                {point.count}
                              </text>
                              <text x={point.x} y={chartHeight - 10} textAnchor="middle" className="dashboard-trend-label">
                                {point.label}
                              </text>
                            </g>
                          ))}
                        </svg>
                      </div>
                    );
                  })()
                ) : <div className="empty-state">No tasks due in the next 7 days.</div>}
              </div>
            </section>

            <section className="panel dashboard-card">
              <div className="section-heading">
                <div>
                  <h3>Due Next</h3>
                  <p className="muted-inline">Tasks that need attention within the next 7 days.</p>
                </div>
              </div>
              <div className="dashboard-list">
                {dashboard.due_soon.length ? dashboard.due_soon.map((task) => (
                  <article key={task.id} className="dashboard-list-row">
                    <div>
                      <strong>{task.title}</strong>
                      <p>{task.assigned_to_name || "Unassigned"} • {titleize(task.state)}</p>
                    </div>
                    <span>{formatDate(task.target_date)}</span>
                  </article>
                )) : <div className="empty-state">No tasks due in the next 7 days.</div>}
              </div>
            </section>

            <section className="panel dashboard-card">
              <div className="section-heading">
                <div>
                  <h3>Team Pulse</h3>
                  <p className="muted-inline">Who currently owns the active workload.</p>
                </div>
              </div>
              <div className="dashboard-pulse-list">
                {dashboard.team_pulse.length ? dashboard.team_pulse.map((entry) => (
                  <div key={entry.name} className="dashboard-pulse-row">
                    <div>
                      <strong>{entry.name}</strong>
                      <p>{entry.review} in review</p>
                    </div>
                    <span>{entry.count} active</span>
                  </div>
                )) : <div className="empty-state">No active team workload yet.</div>}
              </div>
            </section>

            <section className="panel dashboard-card">
              <div className="section-heading">
                <div>
                  <h3>Recently Updated</h3>
                  <p className="muted-inline">Quick access to the latest touched work items.</p>
                </div>
              </div>
              <div className="dashboard-list">
                {dashboard.recently_touched.length ? dashboard.recently_touched.map((task) => (
                  <article key={task.id} className="dashboard-list-row">
                    <div>
                      <strong>{task.title}</strong>
                      <p>{task.assigned_to_name || "Unassigned"} • {titleize(task.priority)}</p>
                    </div>
                    <span>{titleize(task.state)}</span>
                  </article>
                )) : <div className="empty-state">No recent task activity yet.</div>}
              </div>
            </section>
          </div>
        </>
      ) : null}
    </section>
  );
}
