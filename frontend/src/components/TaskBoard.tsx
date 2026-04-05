import type { Task, TaskState } from "../types";
import { formatDate, titleize } from "../utils/format";

const columns: TaskState[] = ["todo", "in_progress", "review", "done"];

export function TaskBoard({
  tasks,
  onMove,
  onOpen
}: {
  tasks: Task[];
  onMove: (task: Task, nextState: TaskState) => Promise<void>;
  onOpen: (task: Task) => void;
}) {
  return (
    <div className="board-grid">
      {columns.map((column) => (
        <section
          key={column}
          className={`board-column state-${column}`}
          onDragOver={(event) => event.preventDefault()}
          onDrop={(event) => {
            event.preventDefault();
            const raw = event.dataTransfer.getData("application/task");
            if (!raw) return;
            const task = JSON.parse(raw) as Task;
            void onMove(task, column);
          }}
        >
          <header className="board-column-header">
            <div>
              <strong>{titleize(column)}</strong>
              <p>{column === "todo" ? "Queued work" : column === "in_progress" ? "Active delivery" : column === "review" ? "Pending validation" : "Finished items"}</p>
            </div>
            <span className="column-count">{tasks.filter((task) => task.state === column).length}</span>
          </header>
          <div className="board-cards">
            {tasks
              .filter((task) => task.state === column)
              .map((task) => (
                <article
                  key={task.id}
                  className="task-card"
                  draggable
                  onDragStart={(event) => {
                    event.dataTransfer.setData("application/task", JSON.stringify(task));
                  }}
                  onClick={() => onOpen(task)}
                >
                  <div className="task-card-top">
                    <span className="task-id">#{task.id}</span>
                    <span className={`pill priority-${task.priority}`}>{titleize(task.priority)}</span>
                  </div>
                  <h4>{task.title}</h4>
                  <p>{task.description || "No description added yet."}</p>
                  <div className="task-chip-row">
                    <span className="task-chip">{task.assigned_to_name ?? "Unassigned"}</span>
                    <span className="task-chip">Comments {task.comments_count}</span>
                    <span className="task-chip">Files {task.attachments.length}</span>
                  </div>
                  <div className="task-meta">
                    <span>Due {formatDate(task.target_date)}</span>
                  </div>
                </article>
              ))}
          </div>
        </section>
      ))}
    </div>
  );
}
