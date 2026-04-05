import type { AnalyticsOverview, Comment, DashboardOverview, PaginatedTasks, Task, TaskMetadata, User } from "../types";

const AUTH_API_URL = import.meta.env.VITE_AUTH_API_URL ?? "http://localhost:3000/api";
const TASK_API_URL = import.meta.env.VITE_TASK_API_URL ?? "http://localhost:3001/api";

type RequestOptions = {
  method?: string;
  body?: BodyInit | null;
  token?: string | null;
  headers?: Record<string, string>;
};

export class ApiError extends Error {
  status: number;
  details: string[];

  constructor(message: string, status = 500, details: string[] = []) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.details = details;
  }
}

type ErrorPayload = {
  detail?: unknown;
  errors?: Array<{ loc?: string[]; msg?: string }>;
};

function formatValidationErrors(errors: Array<{ loc?: string[]; msg?: string }>): string[] {
  return errors.map((item) => `${item.loc?.join(".") ?? "request"}: ${item.msg ?? "Invalid value"}`);
}

async function parseError(response: Response, fallbackMessage: string): Promise<ApiError> {
  const contentType = response.headers.get("content-type") ?? "";

  if (contentType.includes("application/json")) {
    const payload = (await response.json().catch(() => ({}))) as ErrorPayload;
    const validationDetails = Array.isArray(payload.errors)
      ? formatValidationErrors(payload.errors)
      : Array.isArray(payload.detail)
        ? formatValidationErrors(payload.detail as Array<{ loc?: string[]; msg?: string }>)
        : [];
    const detail =
      validationDetails[0]
      ?? (typeof payload.detail === "string" ? payload.detail : undefined)
      ?? fallbackMessage;
    return new ApiError(detail || fallbackMessage, response.status, validationDetails);
  }

  const text = (await response.text().catch(() => "")) || fallbackMessage;
  return new ApiError(text, response.status);
}

async function request<T>(baseUrl: string, path: string, options: RequestOptions = {}): Promise<T> {
  let response: Response;
  try {
    response = await fetch(`${baseUrl}${path}`, {
      method: options.method ?? "GET",
      body: options.body ?? null,
      headers: {
        ...(options.body instanceof FormData ? {} : { "Content-Type": "application/json" }),
        ...(options.token ? { Authorization: `Bearer ${options.token}` } : {}),
        ...options.headers
      }
    });
  } catch {
    throw new ApiError("Unable to reach the server. Please check that the services are running.", 0);
  }

  if (!response.ok) {
    throw await parseError(response, "Request failed");
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

async function requestBlob(baseUrl: string, path: string, token: string, fallbackMessage: string): Promise<Blob> {
  let response: Response;
  try {
    response = await fetch(`${baseUrl}${path}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
  } catch {
    throw new ApiError("Unable to reach the server. Please check that the services are running.", 0);
  }

  if (!response.ok) {
    throw await parseError(response, fallbackMessage);
  }

  return response.blob();
}

export const api = {
  requestRegistrationOtp: (payload: { full_name: string; email: string; password: string }) =>
    request<{ message: string; delivery_method: string }>(AUTH_API_URL, "/auth/register/request-otp", {
      method: "POST",
      body: JSON.stringify(payload)
    }),
  verifyRegistrationOtp: (payload: { email: string; otp: string }) =>
    request<{ access_token: string; token_type: string; user: User }>(AUTH_API_URL, "/auth/register/verify-otp", {
      method: "POST",
      body: JSON.stringify(payload)
    }),
  register: (payload: { full_name: string; email: string; password: string }) =>
    request<{ access_token: string; token_type: string; user: User }>(AUTH_API_URL, "/auth/register", {
      method: "POST",
      body: JSON.stringify(payload)
    }),
  login: (payload: { email: string; password: string }) =>
    request<{ access_token: string; token_type: string; user: User }>(AUTH_API_URL, "/auth/login", {
      method: "POST",
      body: JSON.stringify(payload)
    }),
  logout: (token: string) => request<void>(AUTH_API_URL, "/auth/logout", { method: "POST", token }),
  me: (token: string) => request<User>(AUTH_API_URL, "/auth/me", { token }),
  updateMe: (token: string, payload: { full_name: string }) =>
    request<User>(AUTH_API_URL, "/auth/me", { method: "PUT", token, body: JSON.stringify(payload) }),
  changePassword: (token: string, payload: { current_password: string; new_password: string }) =>
    request<void>(AUTH_API_URL, "/auth/change-password", { method: "PUT", token, body: JSON.stringify(payload) }),
  users: (token: string) => request<User[]>(AUTH_API_URL, "/auth/users", { token }),
  tasks: (token: string, params: URLSearchParams) =>
    request<PaginatedTasks>(TASK_API_URL, `/tasks?${params.toString()}`, { token }),
  task: (token: string, id: number) => request<Task>(TASK_API_URL, `/tasks/${id}`, { token }),
  createTask: (token: string, payload: Record<string, unknown>) =>
    request<Task>(TASK_API_URL, "/tasks", { method: "POST", token, body: JSON.stringify(payload) }),
  bulkCreateTasks: (token: string, payload: { tasks: Record<string, unknown>[] }) =>
    request<Task[]>(TASK_API_URL, "/tasks/bulk", { method: "POST", token, body: JSON.stringify(payload) }),
  updateTask: (token: string, id: number, payload: Record<string, unknown>) =>
    request<Task>(TASK_API_URL, `/tasks/${id}`, { method: "PUT", token, body: JSON.stringify(payload) }),
  deleteTask: (token: string, id: number) =>
    request<void>(TASK_API_URL, `/tasks/${id}`, { method: "DELETE", token }),
  analytics: (token: string) => request<AnalyticsOverview>(TASK_API_URL, "/analytics/overview", { token }),
  dashboard: (token: string) => request<DashboardOverview>(TASK_API_URL, "/dashboard/overview", { token }),
  metadata: (token: string) => request<TaskMetadata>(TASK_API_URL, "/metadata", { token }),
  comments: (token: string, taskId: number) => request<Comment[]>(TASK_API_URL, `/tasks/${taskId}/comments`, { token }),
  createComment: (token: string, taskId: number, content: string) =>
    request<Comment>(TASK_API_URL, `/tasks/${taskId}/comments`, {
      method: "POST",
      token,
      body: JSON.stringify({ content })
    }),
  updateComment: (token: string, commentId: number, content: string) =>
    request<Comment>(TASK_API_URL, `/comments/${commentId}`, {
      method: "PUT",
      token,
      body: JSON.stringify({ content })
    }),
  deleteComment: (token: string, commentId: number) =>
    request<void>(TASK_API_URL, `/comments/${commentId}`, {
      method: "DELETE",
      token
    }),
  uploadAttachment: (token: string, taskId: number, file: File) => {
    const body = new FormData();
    body.append("file", file);
    return request(TASK_API_URL, `/tasks/${taskId}/attachments`, {
      method: "POST",
      token,
      body
    });
  },
  downloadAttachment: (token: string, attachmentId: number) =>
    requestBlob(TASK_API_URL, `/attachments/${attachmentId}/download`, token, "Unable to download attachment"),
  deleteAttachment: (token: string, attachmentId: number) =>
    request<void>(TASK_API_URL, `/attachments/${attachmentId}`, {
      method: "DELETE",
      token
    }),
  exportTasks: (token: string) =>
    requestBlob(TASK_API_URL, "/analytics/export", token, "Unable to export tasks")
};
