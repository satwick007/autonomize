import type { Task } from "../types";
import { titleize } from "../utils/format";

type SortField =
  | "id"
  | "title"
  | "assigned_to_id"
  | "state"
  | "priority"
  | "target_date";

export function TaskTable({
  tasks,
  onOpen,
  sortBy,
  sortOrder,
  onSort
}: {
  tasks: Task[];
  onOpen: (task: Task) => void;
  sortBy: string;
  sortOrder: string;
  onSort: (field: SortField) => void;
}) {
  const renderSortableHeader = (label: string, field: SortField) => {
    const isActive = sortBy === field;
    const indicator = isActive ? (sortOrder === "asc" ? "↑" : "↓") : "↕";
    return (
      <button
        type="button"
        className={`table-sort ${isActive ? "active" : ""}`}
        onClick={() => onSort(field)}
      >
        <span>{label}</span>
        <span className="table-sort-indicator">{indicator}</span>
      </button>
    );
  };

  return (
    <div className="table-wrap">
      <table className="task-table">
        <thead>
          <tr>
            <th>{renderSortableHeader("ID", "id")}</th>
            <th>{renderSortableHeader("Title", "title")}</th>
            <th>{renderSortableHeader("Assigned To", "assigned_to_id")}</th>
            <th>{renderSortableHeader("State", "state")}</th>
            <th>{renderSortableHeader("Priority", "priority")}</th>
            <th>Tags</th>
          </tr>
        </thead>
        <tbody>
          {tasks.length ? (
            tasks.map((task) => (
              <tr key={task.id} onClick={() => onOpen(task)}>
                <td className="col-id">
                  <span className="task-id">#{task.id}</span>
                </td>
                <td className="col-title">
                  <strong className="table-title">{task.title}</strong>
                </td>
                <td className="col-assignee">{task.assigned_to_name ?? "Unassigned"}</td>
                <td className="col-state"><span className={`pill state-pill state-${task.state}`}>{titleize(task.state)}</span></td>
                <td className="col-priority"><span className={`pill priority-${task.priority}`}>{titleize(task.priority)}</span></td>
                <td className="col-tags">
                  <div className="tag-cell">
                    {task.tags.length ? task.tags.map((tag) => (
                      <span key={tag} className="task-chip">{tag}</span>
                    )) : <span className="muted-inline">No tags</span>}
                  </div>
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={6}>
                <div className="empty-state">No tasks match the current filters.</div>
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
