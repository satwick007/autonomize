import type { ChangeEvent } from "react";
import { useEffect, useMemo, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { TaskBoard } from "../components/TaskBoard";
import { TaskTable } from "../components/TaskTable";
import { useAuth } from "../hooks/useAuth";
import type { MasterOption, TagOption, Task, TaskState, User } from "../types";

type ViewMode = "board" | "list";
type SortField =
  | "id"
  | "title"
  | "assigned_to_id"
  | "state"
  | "priority"
  | "target_date"
  | "created_at";

type CsvTaskRow = {
  title: string;
  description: string;
  state: string;
  priority: string;
  assigned_to_id: number | null;
  start_date: string | null;
  end_date: string | null;
  target_date: string | null;
  tags: string[];
};

type FilterOption = {
  value: string;
  label: string;
};

function MultiSelectFilter({
  label,
  placeholder,
  options,
  values,
  query,
  open,
  onQueryChange,
  onToggle,
  onOpen,
  onClose,
  onClear,
}: {
  label: string;
  placeholder: string;
  options: FilterOption[];
  values: string[];
  query: string;
  open: boolean;
  onQueryChange: (value: string) => void;
  onToggle: (value: string) => void;
  onOpen: () => void;
  onClose: () => void;
  onClear: () => void;
}) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const selectedOptions = values
    .map((value) => options.find((option) => option.value === value))
    .filter((option): option is FilterOption => Boolean(option));
  const normalizedQuery = query.trim().toLowerCase();
  const filteredOptions = options.filter((option) => {
    if (!normalizedQuery) {
      return true;
    }
    return option.label.toLowerCase().includes(normalizedQuery);
  });
  const summary =
    selectedOptions.length === 0
      ? placeholder
      : selectedOptions.length === 1
        ? selectedOptions[0].label
        : `${selectedOptions[0].label} (+${selectedOptions.length - 1})`;

  useEffect(() => {
    if (!open) {
      return;
    }

    const handlePointerDown = (event: MouseEvent) => {
      if (!containerRef.current?.contains(event.target as Node)) {
        onClose();
      }
    };

    document.addEventListener("mousedown", handlePointerDown);
    return () => document.removeEventListener("mousedown", handlePointerDown);
  }, [onClose, open]);

  return (
    <div className="toolbar-group" ref={containerRef}>
      <label>{label}</label>
      <div className="combobox">
        <button
          type="button"
          className={`filter-dropdown-trigger${selectedOptions.length ? " has-selection" : ""}${open ? " is-open" : ""}`}
          onClick={open ? onClose : onOpen}
        >
          <span className={selectedOptions.length ? "filter-dropdown-value" : "filter-dropdown-placeholder"} title={selectedOptions.length ? selectedOptions.map((option) => option.label).join(", ") : placeholder}>
            {summary}
          </span>
          <span className="filter-dropdown-caret">{open ? "▴" : "▾"}</span>
        </button>
        {open ? (
          <div className="combobox-menu filter-dropdown-menu">
            <div className="filter-dropdown-search">
              <input
                value={query}
                placeholder={`Search ${label.toLowerCase()}`}
                onChange={(event) => onQueryChange(event.target.value)}
                autoFocus
              />
            </div>
            <div className="filter-dropdown-options">
              <label className="filter-checkbox-row">
                <input
                  type="checkbox"
                  checked={values.length === 0}
                  onChange={() => onClear()}
                />
                <span>All</span>
              </label>
              {filteredOptions.map((option) => (
                <label
                  key={option.value}
                  className={`filter-checkbox-row${values.includes(option.value) ? " selected" : ""}`}
                >
                  <input
                    type="checkbox"
                    checked={values.includes(option.value)}
                    onChange={() => onToggle(option.value)}
                  />
                  <span>{option.label}</span>
                </label>
              ))}
              {!filteredOptions.length ? <div className="combobox-empty">No matching options</div> : null}
            </div>
            <div className="filter-dropdown-footer">
              <button type="button" className="filter-dropdown-clear" onClick={onClear} disabled={values.length === 0}>
                Clear
              </button>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}

function parseCsvLine(line: string) {
  const result: string[] = [];
  let current = "";
  let inQuotes = false;

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    const next = line[index + 1];

    if (char === "\"") {
      if (inQuotes && next === "\"") {
        current += "\"";
        index += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char === "," && !inQuotes) {
      result.push(current.trim());
      current = "";
      continue;
    }

    current += char;
  }

  result.push(current.trim());
  return result;
}

function normalizeHeader(header: string) {
  return header.trim().toLowerCase().replace(/\s+/g, "_");
}

function normalizeState(value: string) {
  const normalized = value.trim().toLowerCase().replace(/\s+/g, "_");
  if (normalized === "to_do") {
    return "todo";
  }
  if (normalized === "inprogress") {
    return "in_progress";
  }
  return normalized || "todo";
}

function normalizePriority(value: string) {
  return value.trim().toLowerCase() || "medium";
}

function parseTags(value: string) {
  return value
    .split(/[|,]/)
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean);
}

function normalizeCsvDate(value: string, label: string, rowNumber: number) {
  const raw = value.trim();
  if (!raw) {
    return null;
  }

  if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
    return raw;
  }

  const slashMatch = raw.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (slashMatch) {
    const [, day, month, year] = slashMatch;
    return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
  }

  const dashMatch = raw.match(/^(\d{1,2})-(\d{1,2})-(\d{4})$/);
  if (dashMatch) {
    const [, day, month, year] = dashMatch;
    return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
  }

  throw new Error(`Row ${rowNumber}: ${label} must be in yyyy-mm-dd or dd/mm/yyyy format.`);
}

function parseCsvTasks(csvText: string, users: User[]) {
  const lines = csvText
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);

  if (lines.length < 2) {
    throw new Error("CSV must include a header row and at least one task row.");
  }

  const headers = parseCsvLine(lines[0]).map(normalizeHeader);
  const tasks: CsvTaskRow[] = [];

  for (let lineIndex = 1; lineIndex < lines.length; lineIndex += 1) {
    const cells = parseCsvLine(lines[lineIndex]);
    const row = headers.reduce<Record<string, string>>((accumulator, header, headerIndex) => {
      accumulator[header] = cells[headerIndex]?.trim() ?? "";
      return accumulator;
    }, {});

    if (!row.title) {
      throw new Error(`Row ${lineIndex + 1}: title is required.`);
    }

    let assignedToId: number | null = null;
    const assignedToIdRaw = row.assigned_to_id || row.assignee_id || row.user_id;
    const assignedToEmailRaw = row.assigned_to_email || row.assignee_email || row.email;

    if (assignedToIdRaw) {
      const parsedId = Number(assignedToIdRaw);
      if (!Number.isFinite(parsedId)) {
        throw new Error(`Row ${lineIndex + 1}: assigned_to_id must be a number.`);
      }
      assignedToId = parsedId;
    } else if (assignedToEmailRaw) {
      const normalizedEmail = assignedToEmailRaw.trim().toLowerCase();
      const match = users.find((user) => user.email.trim().toLowerCase() === normalizedEmail);
      if (!match) {
        throw new Error(`Row ${lineIndex + 1}: user email "${assignedToEmailRaw}" was not found.`);
      }
      assignedToId = match.id;
    }

    tasks.push({
      title: row.title,
      description: row.description || "",
      state: normalizeState(row.state || ""),
      priority: normalizePriority(row.priority || ""),
      assigned_to_id: assignedToId,
      start_date: normalizeCsvDate(row.start_date || "", "start_date", lineIndex + 1),
      end_date: normalizeCsvDate(row.end_date || "", "end_date", lineIndex + 1),
      target_date: normalizeCsvDate(row.target_date || row.due_date || "", "target_date", lineIndex + 1),
      tags: parseTags(row.tags || "")
    });
  }

  return tasks;
}

export function TasksPage() {
  const { token, user } = useAuth();
  const navigate = useNavigate();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [stateOptions, setStateOptions] = useState<MasterOption[]>([]);
  const [priorityOptions, setPriorityOptions] = useState<MasterOption[]>([]);
  const [tagOptions, setTagOptions] = useState<TagOption[]>([]);
  const [total, setTotal] = useState(0);
  const [view, setView] = useState<ViewMode>("list");
  const [loading, setLoading] = useState(true);
  const [bulkUploading, setBulkUploading] = useState(false);
  const [error, setError] = useState("");
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const [openFilter, setOpenFilter] = useState<string | null>(null);
  const [filterQueries, setFilterQueries] = useState({
    assigned_to_id: "",
    state: "",
    priority: "",
    tag: "",
  });
  const [filters, setFilters] = useState({
    search: "",
    state: [] as string[],
    priority: [] as string[],
    tag: [] as string[],
    assigned_to_id: [] as string[],
    sort_by: "id",
    sort_order: "desc",
    page: 1,
    page_size: 8
  });

  const fetchTasks = async () => {
    if (!token) return;
    setLoading(true);
    setError("");
    try {
      const params = new URLSearchParams();
      Object.entries(filters).forEach(([key, value]) => {
        if (Array.isArray(value)) {
          if (value.length) {
            params.set(key, value.join(","));
          }
          return;
        }
        if (value !== "") params.set(key, String(value));
      });
      if (view === "board") {
        params.delete("page");
        params.delete("page_size");
        const result = await api.boardTasks(token, params);
        setTasks(result);
        setTotal(result.length);
      } else {
        const result = await api.tasks(token, params);
        setTasks(result.items);
        setTotal(result.total);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to load tasks");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void fetchTasks();
  }, [token, filters, view]);

  useEffect(() => {
    if (!token) {
      return;
    }
    api.users(token).then(setUsers).catch(() => setUsers([]));
    api.metadata(token)
      .then((metadata) => {
        setStateOptions(metadata.states);
        setPriorityOptions(metadata.priorities);
        setTagOptions(metadata.tags);
      })
      .catch(() => {
        setStateOptions([]);
        setPriorityOptions([]);
        setTagOptions([]);
      });
  }, [token]);

  const pageCount = useMemo(() => Math.max(Math.ceil(total / filters.page_size), 1), [filters.page_size, total]);
  const rangeStart = total === 0 ? 0 : (filters.page - 1) * filters.page_size + 1;
  const rangeEnd = total === 0 ? 0 : Math.min(filters.page * filters.page_size, total);
  const assigneeOptions = useMemo<FilterOption[]>(
    () => {
      const baseOptions: FilterOption[] = [];
      if (user) {
        baseOptions.push({ value: "__me__", label: "@Me" });
      }
      baseOptions.push({ value: "__unassigned__", label: "Unassigned" });
      return [
        ...baseOptions,
        ...users.map((optionUser) => ({ value: String(optionUser.id), label: optionUser.full_name })),
      ];
    },
    [user, users],
  );
  const stateFilterOptions = useMemo<FilterOption[]>(
    () => stateOptions.map((option) => ({ value: option.code, label: option.label })),
    [stateOptions],
  );
  const priorityFilterOptions = useMemo<FilterOption[]>(
    () => priorityOptions.map((option) => ({ value: option.code, label: option.label })),
    [priorityOptions],
  );
  const tagFilterOptions = useMemo<FilterOption[]>(
    () => tagOptions.map((option) => ({ value: option.name, label: option.name })),
    [tagOptions],
  );
  const handleMoveTask = async (task: Task, nextState: TaskState) => {
    if (!token || task.state === nextState) return;
    await api.updateTask(token, task.id, { state: nextState });
    await fetchTasks();
  };

  const openMultiFilter = (name: "assigned_to_id" | "state" | "priority" | "tag") => {
    setOpenFilter(name);
  };

  const toggleMultiFilterValue = (name: "assigned_to_id" | "state" | "priority" | "tag", value: string) => {
    setFilters((current) => {
      const nextValues = current[name].includes(value)
        ? current[name].filter((item) => item !== value)
        : [...current[name], value];
      return { ...current, [name]: nextValues, page: 1 };
    });
    setFilterQueries((current) => ({ ...current, [name]: "" }));
    setOpenFilter(name);
  };

  const clearMultiFilter = (name: "assigned_to_id" | "state" | "priority" | "tag") => {
    setFilters((current) => ({ ...current, [name]: [], page: 1 }));
    setFilterQueries((current) => ({ ...current, [name]: "" }));
    setOpenFilter(null);
  };

  const downloadExport = async () => {
    if (!token) return;
    const blob = await api.exportTasks(token);
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "tasks-export.csv";
    link.click();
    URL.revokeObjectURL(url);
  };

  const downloadBulkTemplate = () => {
    const template = [
      "title,description,state,priority,assigned_to_email,start_date,end_date,target_date,tags",
      'Backend API,Build auth endpoints,todo,high,satwick@example.com,2026-04-05,2026-04-08,2026-04-07,"backend,api"',
      'UI polish,Improve task page,review,medium,,2026-04-06,2026-04-10,2026-04-09,"frontend,ux"'
    ].join("\n");

    const blob = new Blob([template], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "task-bulk-upload-template.csv";
    link.click();
    URL.revokeObjectURL(url);
  };

  const handleBulkCsvUpload = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    event.target.value = "";
    if (!file || !token) {
      return;
    }

    setBulkUploading(true);
    setError("");

    try {
      const csvText = await file.text();
      const parsedTasks = parseCsvTasks(csvText, users);
      await api.bulkCreateTasks(token, { tasks: parsedTasks });
      await fetchTasks();
    } catch (uploadError) {
      setError(uploadError instanceof Error ? uploadError.message : "Unable to import CSV tasks");
    } finally {
      setBulkUploading(false);
    }
  };

  const handleSort = (field: SortField) => {
    setFilters((current) => ({
      ...current,
      sort_by: field,
      sort_order: current.sort_by === field && current.sort_order === "asc" ? "desc" : "asc",
      page: 1
    }));
  };

  return (
    <section className="page-shell">
      <div className="page-header">
        <div>
          <h1>Task Management</h1>
        </div>
        <div className="header-actions">
          <button className="secondary-button" onClick={downloadBulkTemplate}>
            Download Template
          </button>
          <button className="secondary-button" onClick={downloadExport}>
            Export CSV
          </button>
          <button
            className="secondary-button"
            onClick={() => fileInputRef.current?.click()}
            disabled={bulkUploading}
          >
            {bulkUploading ? "Uploading..." : "Upload CSV"}
          </button>
          <button className="primary-button" onClick={() => navigate("/tasks/new")}>
            New task
          </button>
        </div>
      </div>
      <input
        ref={fileInputRef}
        type="file"
        accept=".csv,text/csv"
        className="visually-hidden"
        onChange={handleBulkCsvUpload}
      />

      <div className="toolbar panel">
        <div className="toolbar-group toolbar-search">
          <label>Search</label>
          <input
            placeholder="Search tasks by title or description"
            value={filters.search}
            onChange={(event) => setFilters((current) => ({ ...current, search: event.target.value, page: 1 }))}
          />
        </div>
        <MultiSelectFilter
          label="Assigned To"
          placeholder="All assignees"
          options={assigneeOptions}
          values={filters.assigned_to_id}
          query={filterQueries.assigned_to_id}
          open={openFilter === "assigned_to_id"}
          onQueryChange={(value) => setFilterQueries((current) => ({ ...current, assigned_to_id: value }))}
          onToggle={(value) => toggleMultiFilterValue("assigned_to_id", value)}
          onOpen={() => openMultiFilter("assigned_to_id")}
          onClose={() => setOpenFilter(null)}
          onClear={() => clearMultiFilter("assigned_to_id")}
        />
        <MultiSelectFilter
          label="State"
          placeholder="All states"
          options={stateFilterOptions}
          values={filters.state}
          query={filterQueries.state}
          open={openFilter === "state"}
          onQueryChange={(value) => setFilterQueries((current) => ({ ...current, state: value }))}
          onToggle={(value) => toggleMultiFilterValue("state", value)}
          onOpen={() => openMultiFilter("state")}
          onClose={() => setOpenFilter(null)}
          onClear={() => clearMultiFilter("state")}
        />
        <MultiSelectFilter
          label="Priority"
          placeholder="All priorities"
          options={priorityFilterOptions}
          values={filters.priority}
          query={filterQueries.priority}
          open={openFilter === "priority"}
          onQueryChange={(value) => setFilterQueries((current) => ({ ...current, priority: value }))}
          onToggle={(value) => toggleMultiFilterValue("priority", value)}
          onOpen={() => openMultiFilter("priority")}
          onClose={() => setOpenFilter(null)}
          onClear={() => clearMultiFilter("priority")}
        />
        <MultiSelectFilter
          label="Tags"
          placeholder="All tags"
          options={tagFilterOptions}
          values={filters.tag}
          query={filterQueries.tag}
          open={openFilter === "tag"}
          onQueryChange={(value) => setFilterQueries((current) => ({ ...current, tag: value }))}
          onToggle={(value) => toggleMultiFilterValue("tag", value)}
          onOpen={() => openMultiFilter("tag")}
          onClose={() => setOpenFilter(null)}
          onClear={() => clearMultiFilter("tag")}
        />
        <div className="segmented">
          <button className={view === "list" ? "is-active" : ""} onClick={() => setView("list")}>
            List
          </button>
          <button className={view === "board" ? "is-active" : ""} onClick={() => setView("board")}>
            Board
          </button>
        </div>
      </div>

      {error ? <div className="error-banner">{error}</div> : null}
      {loading ? <div className="panel">Loading tasks...</div> : null}

      {!loading && (view === "list" ? (
        <TaskTable
          tasks={tasks}
          onOpen={(task) => navigate(`/tasks/${task.id}/edit`)}
          sortBy={filters.sort_by}
          sortOrder={filters.sort_order}
          onSort={handleSort}
        />
      ) : (
        <TaskBoard tasks={tasks} onMove={handleMoveTask} onOpen={(task) => navigate(`/tasks/${task.id}/edit`)} />
      ))}

      <div className="pagination">
        <span className="pagination-summary">
          {rangeStart}-{rangeEnd} of {total}
        </span>
        <span className="pagination-page">Page {filters.page} of {pageCount}</span>
        <div className="pagination-actions">
          <button
            className="secondary-button"
            disabled={filters.page <= 1}
            onClick={() => setFilters((current) => ({ ...current, page: current.page - 1 }))}
          >
            Previous
          </button>
          <button
            className="secondary-button"
            disabled={filters.page >= pageCount}
            onClick={() => setFilters((current) => ({ ...current, page: current.page + 1 }))}
          >
            Next
          </button>
        </div>
      </div>

    </section>
  );
}
