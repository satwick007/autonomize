export type TaskState = "todo" | "in_progress" | "review" | "done";
export type TaskPriority = "low" | "medium" | "high" | "critical";

export interface User {
  id: number;
  full_name: string;
  email: string;
  created_at: string;
}

export interface Attachment {
  id: number;
  task_id: number;
  file_name: string;
  file_path: string;
  file_size_bytes: number;
  content_type?: string | null;
  uploaded_by_id: number;
  uploaded_at: string;
}

export interface Task {
  id: number;
  title: string;
  description: string;
  state_id?: number;
  state: TaskState;
  priority_id?: number;
  priority: TaskPriority;
  assigned_to_id?: number | null;
  assigned_to_name?: string | null;
  start_date?: string | null;
  end_date?: string | null;
  target_date?: string | null;
  tag_ids?: number[];
  tags: string[];
  created_at: string;
  updated_at: string;
  attachments: Attachment[];
  comments_count: number;
}

export interface Comment {
  id: number;
  task_id: number;
  author_id: number;
  author_name: string;
  content: string;
  created_at: string;
  updated_at: string;
}

export interface AnalyticsOverview {
  by_state: Record<string, number>;
  by_priority: Record<string, number>;
  completed_over_time: Array<{ date: string; count: number }>;
  user_performance: Array<{ user: string; completed_tasks: number }>;
}

export interface DashboardMiniStat {
  label: string;
  value: number;
}

export interface DashboardTimelinePoint {
  date: string;
  label: string;
  count: number;
}

export interface DashboardDueSoonTask {
  id: number;
  title: string;
  assigned_to_name?: string | null;
  state: string;
  target_date?: string | null;
}

export interface DashboardTeamPulse {
  name: string;
  count: number;
  review: number;
}

export interface DashboardRecentTask {
  id: number;
  title: string;
  assigned_to_name?: string | null;
  priority: string;
  state: string;
  updated_at: string;
}

export interface DashboardOverview {
  total: number;
  overdue: number;
  unassigned: number;
  my_work: DashboardMiniStat[];
  state_cards: DashboardMiniStat[];
  priority_cards: DashboardMiniStat[];
  due_timeline: DashboardTimelinePoint[];
  due_soon: DashboardDueSoonTask[];
  team_pulse: DashboardTeamPulse[];
  recently_touched: DashboardRecentTask[];
}

export interface PaginatedTasks {
  total: number;
  page: number;
  page_size: number;
  items: Task[];
}

export interface MasterOption {
  id: number;
  code: string;
  label: string;
}

export interface TagOption {
  id: number;
  name: string;
}

export interface TaskMetadata {
  states: MasterOption[];
  priorities: MasterOption[];
  tags: TagOption[];
}
