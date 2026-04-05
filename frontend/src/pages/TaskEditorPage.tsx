import type { ChangeEvent, FormEvent } from "react";
import { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../hooks/useAuth";
import type { Comment, TagOption, Task, TaskPriority, TaskState, User } from "../types";
import { formatDateTime } from "../utils/format";

type TaskFormValues = {
  title: string;
  description: string;
  state: TaskState;
  priority: TaskPriority;
  assigned_to_id: string;
  start_date: string;
  end_date: string;
  target_date: string;
  tags: string;
};

const defaults: TaskFormValues = {
  title: "",
  description: "",
  state: "todo",
  priority: "medium",
  assigned_to_id: "",
  start_date: "",
  end_date: "",
  target_date: "",
  tags: ""
};

function taskToFormValues(task: Task): TaskFormValues {
  return {
    title: task.title,
    description: task.description,
    state: task.state,
    priority: task.priority,
    assigned_to_id: task.assigned_to_id ? String(task.assigned_to_id) : "",
    start_date: task.start_date ?? "",
    end_date: task.end_date ?? "",
    target_date: task.target_date ?? "",
    tags: task.tags.join(", ")
  };
}

const allowedFileExtensions = new Set(["png", "jpg", "jpeg", "pdf", "doc", "docx", "txt"]);

function initialsFor(name: string) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (!parts.length) {
    return "U";
  }
  return parts.slice(0, 2).map((part) => part.charAt(0).toUpperCase()).join("");
}

function normalizeTaskFormValues(values: TaskFormValues) {
  return {
    title: values.title.trim(),
    description: values.description.trim(),
    state: values.state,
    priority: values.priority,
    assigned_to_id: values.assigned_to_id,
    start_date: values.start_date || "",
    end_date: values.end_date || "",
    target_date: values.target_date || "",
    tags: values.tags
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean)
      .join(",")
  };
}

export function TaskEditorPage() {
  const { token, user } = useAuth();
  const { taskId } = useParams();
  const navigate = useNavigate();
  const isEdit = Boolean(taskId);
  const [users, setUsers] = useState<User[]>([]);
  const [stateOptions, setStateOptions] = useState<Array<{ code: string; label: string }>>([]);
  const [priorityOptions, setPriorityOptions] = useState<Array<{ code: string; label: string }>>([]);
  const [tagOptions, setTagOptions] = useState<TagOption[]>([]);
  const [values, setValues] = useState<TaskFormValues>(defaults);
  const [existingTask, setExistingTask] = useState<Task | null>(null);
  const [assigneeQuery, setAssigneeQuery] = useState("");
  const [assigneeOpen, setAssigneeOpen] = useState(false);
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const [comments, setComments] = useState<Comment[]>([]);
  const [commentDraft, setCommentDraft] = useState("");
  const [editingCommentId, setEditingCommentId] = useState<number | null>(null);
  const [editingCommentDraft, setEditingCommentDraft] = useState("");
  const [tagQuery, setTagQuery] = useState("");
  const [tagOpen, setTagOpen] = useState(false);
  const [loading, setLoading] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [attachmentDeletingId, setAttachmentDeletingId] = useState<number | null>(null);
  const [commentSaving, setCommentSaving] = useState(false);
  const [commentActionLoadingId, setCommentActionLoadingId] = useState<number | null>(null);
  const [error, setError] = useState("");
  const [initialSnapshot, setInitialSnapshot] = useState(() => JSON.stringify(normalizeTaskFormValues(defaults)));

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
        setStateOptions([
          { code: "todo", label: "Todo" },
          { code: "in_progress", label: "In Progress" },
          { code: "review", label: "Review" },
          { code: "done", label: "Done" }
        ]);
        setPriorityOptions([
          { code: "low", label: "Low" },
          { code: "medium", label: "Medium" },
          { code: "high", label: "High" },
          { code: "critical", label: "Critical" }
        ]);
      });
  }, [token]);

  useEffect(() => {
    if (!token || !taskId) {
      setValues(defaults);
      setExistingTask(null);
      setInitialSnapshot(JSON.stringify(normalizeTaskFormValues(defaults)));
      setLoading(false);
      return;
    }

    setLoading(true);
    api.task(token, Number(taskId))
      .then((task) => {
        setExistingTask(task);
        const nextValues = taskToFormValues(task);
        setValues(nextValues);
        setInitialSnapshot(JSON.stringify(normalizeTaskFormValues(nextValues)));
      })
      .catch((fetchError: Error) => setError(fetchError.message))
      .finally(() => setLoading(false));
  }, [taskId, token]);

  useEffect(() => {
    if (!token || !taskId) {
      setComments([]);
      return;
    }
    api.comments(token, Number(taskId)).then(setComments).catch(() => setComments([]));
  }, [taskId, token]);

  useEffect(() => {
    if (!values.assigned_to_id) {
      setAssigneeQuery("");
      return;
    }
    const selectedUser = users.find((user) => String(user.id) === values.assigned_to_id);
    setAssigneeQuery(selectedUser?.full_name ?? "");
  }, [users, values.assigned_to_id]);

  const filteredUsers = useMemo(() => {
    const query = assigneeQuery.trim().toLowerCase();
    if (!query) {
      return users;
    }
    return users.filter((user) => user.full_name.toLowerCase().includes(query));
  }, [assigneeQuery, users]);

  const selectedTags = useMemo(
    () => values.tags.split(",").map((item) => item.trim()).filter(Boolean),
    [values.tags]
  );

  const filteredTags = useMemo(() => {
    const query = tagQuery.trim().toLowerCase();
    return tagOptions.filter((tag) => {
      if (selectedTags.includes(tag.name)) {
        return false;
      }
      return !query || tag.name.toLowerCase().includes(query);
    });
  }, [selectedTags, tagOptions, tagQuery]);

  const canCreateTag = useMemo(() => {
    const normalized = tagQuery.trim().toLowerCase();
    if (!normalized) {
      return false;
    }
    return !tagOptions.some((tag) => tag.name.toLowerCase() === normalized) && !selectedTags.includes(normalized);
  }, [selectedTags, tagOptions, tagQuery]);

  const hasChanges = useMemo(() => {
    const current = JSON.stringify(normalizeTaskFormValues(values));
    return current !== initialSnapshot || selectedFiles.length > 0;
  }, [initialSnapshot, selectedFiles.length, values]);

  const canSave = hasChanges && !saving;

  const handleChange = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setValues((current) => ({ ...current, [event.target.name]: event.target.value }));
  };

  const handleFileSelection = (files: FileList | null) => {
    if (!files?.length) {
      return;
    }
    const nextFiles = Array.from(files);
    const validFiles: File[] = [];
    const invalidNames: string[] = [];

    nextFiles.forEach((file) => {
      const extension = file.name.split(".").pop()?.toLowerCase() ?? "";
      if (!allowedFileExtensions.has(extension)) {
        invalidNames.push(file.name);
        return;
      }
      validFiles.push(file);
    });

    if (invalidNames.length) {
      setError(`Unsupported file type: ${invalidNames.join(", ")}`);
    }

    if (validFiles.length) {
      setSelectedFiles((current) => [...current, ...validFiles]);
    }
  };

  const removeSelectedFile = (indexToRemove: number) => {
    setSelectedFiles((current) => current.filter((_, index) => index !== indexToRemove));
  };

  const addTag = (tagName: string) => {
    const normalized = tagName.trim().toLowerCase();
    if (!normalized) {
      return;
    }
    const nextTags = Array.from(new Set([...selectedTags, normalized]));
    setValues((current) => ({ ...current, tags: nextTags.join(", ") }));
    if (!tagOptions.some((tag) => tag.name === normalized)) {
      setTagOptions((current) => [...current, { id: Date.now(), name: normalized }].sort((left, right) => left.name.localeCompare(right.name)));
    }
    setTagQuery("");
    setTagOpen(false);
  };

  const removeTag = (tagName: string) => {
    const nextTags = selectedTags.filter((tag) => tag !== tagName);
    setValues((current) => ({ ...current, tags: nextTags.join(", ") }));
  };

  const handleAddComment = async () => {
    if (!token || !taskId || !commentDraft.trim()) {
      return;
    }
    setCommentSaving(true);
    try {
      const createdComment = await api.createComment(token, Number(taskId), commentDraft.trim());
      setComments((current) => [...current, createdComment]);
      setCommentDraft("");
    } catch (commentError) {
      setError(commentError instanceof Error ? commentError.message : "Unable to add comment");
    } finally {
      setCommentSaving(false);
    }
  };

  const handleStartEditComment = (comment: Comment) => {
    setEditingCommentId(comment.id);
    setEditingCommentDraft(comment.content);
  };

  const handleCancelEditComment = () => {
    setEditingCommentId(null);
    setEditingCommentDraft("");
  };

  const handleSaveEditedComment = async (commentId: number) => {
    if (!token || !editingCommentDraft.trim()) {
      return;
    }
    setCommentActionLoadingId(commentId);
    try {
      const updatedComment = await api.updateComment(token, commentId, editingCommentDraft.trim());
      setComments((current) => current.map((comment) => (comment.id === commentId ? updatedComment : comment)));
      setEditingCommentId(null);
      setEditingCommentDraft("");
    } catch (commentError) {
      setError(commentError instanceof Error ? commentError.message : "Unable to update comment");
    } finally {
      setCommentActionLoadingId(null);
    }
  };

  const handleDeleteComment = async (commentId: number) => {
    if (!token) {
      return;
    }
    const confirmed = window.confirm("Delete this comment?");
    if (!confirmed) {
      return;
    }
    setCommentActionLoadingId(commentId);
    try {
      await api.deleteComment(token, commentId);
      setComments((current) => current.filter((comment) => comment.id !== commentId));
      if (editingCommentId === commentId) {
        setEditingCommentId(null);
        setEditingCommentDraft("");
      }
    } catch (commentError) {
      setError(commentError instanceof Error ? commentError.message : "Unable to delete comment");
    } finally {
      setCommentActionLoadingId(null);
    }
  };

  const handleDownloadAttachment = async (attachmentId: number, fileName: string) => {
    if (!token) {
      return;
    }
    try {
      const blob = await api.downloadAttachment(token, attachmentId);
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(url);
    } catch (downloadError) {
      setError(downloadError instanceof Error ? downloadError.message : "Unable to download attachment");
    }
  };

  const handleDeleteAttachment = async (attachmentId: number) => {
    if (!token || attachmentDeletingId === attachmentId) {
      return;
    }
    const confirmed = window.confirm("Delete this file?");
    if (!confirmed) {
      return;
    }

    setAttachmentDeletingId(attachmentId);
    try {
      await api.deleteAttachment(token, attachmentId);
      setExistingTask((current) => {
        if (!current) {
          return current;
        }
        return {
          ...current,
          attachments: current.attachments.filter((attachment) => attachment.id !== attachmentId)
        };
      });
    } catch (deleteError) {
      setError(deleteError instanceof Error ? deleteError.message : "Unable to delete attachment");
    } finally {
      setAttachmentDeletingId(null);
    }
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (!token) {
      return;
    }
    setSaving(true);
    setError("");

    try {
      const payload = {
        title: values.title,
        description: values.description,
        state: values.state,
        priority: values.priority,
        assigned_to_id: values.assigned_to_id ? Number(values.assigned_to_id) : null,
        start_date: values.start_date || null,
        end_date: values.end_date || null,
        target_date: values.target_date || null,
        tags: values.tags.split(",").map((item) => item.trim()).filter(Boolean)
      };

      const task = isEdit && taskId
        ? await api.updateTask(token, Number(taskId), payload)
        : await api.createTask(token, payload);

      for (const file of selectedFiles) {
        await api.uploadAttachment(token, task.id, file);
      }
      const refreshedTask = await api.task(token, task.id);
      const nextValues = taskToFormValues(refreshedTask);
      setExistingTask(refreshedTask);
      setValues(nextValues);
      setInitialSnapshot(JSON.stringify(normalizeTaskFormValues(nextValues)));
      setSelectedFiles([]);
      setError("");

      if (!isEdit) {
        navigate(`/tasks/${task.id}/edit`, { replace: true });
      }
    } catch (submitError) {
      setError(submitError instanceof Error ? submitError.message : "Unable to save task");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!token || !taskId || deleting) {
      return;
    }
    const confirmed = window.confirm("Delete this task? It will be removed from the active task list.");
    if (!confirmed) {
      return;
    }

    setDeleting(true);
    setError("");
    try {
      await api.deleteTask(token, Number(taskId));
      navigate("/tasks");
    } catch (deleteError) {
      setError(deleteError instanceof Error ? deleteError.message : "Unable to delete task");
      setDeleting(false);
    }
  };

  if (loading) {
    return <section className="page-shell"><div className="panel">Loading task editor...</div></section>;
  }

  return (
    <section className="page-shell">
      <div className="editor-hero panel">
        <div className="header-actions">
          <button type="button" className="secondary-button" onClick={() => navigate("/tasks")}>
            Back to tasks
          </button>
        </div>
      </div>

      <form className="panel task-editor-form" onSubmit={handleSubmit}>
        {error ? <div className="error-banner">{error}</div> : null}

        <div className="work-item-header">
          <div className="work-item-title-block">
            <div className="work-item-id-row">
              <span className="work-item-id-badge">{isEdit ? `TASK ${existingTask?.id ?? ""}` : "NEW TASK"}</span>
              <div className="editor-header-actions">
                {isEdit ? (
                  <button
                    type="button"
                    className="danger-button"
                    onClick={handleDelete}
                    disabled={deleting || saving}
                  >
                    {deleting ? "Deleting..." : "Delete task"}
                  </button>
                ) : null}
                <button type="submit" className="primary-button editor-save editor-save-inline" disabled={!canSave || deleting} aria-disabled={!canSave || deleting}>
                  {saving ? "Saving..." : "Save task"}
                </button>
              </div>
            </div>
            <div className="form-field">
              <label htmlFor="task-title-page">
                Title <span className="required-mark">*</span>
              </label>
              <input
                id="task-title-page"
                name="title"
                value={values.title}
                placeholder="Enter task title"
                onChange={handleChange}
                minLength={3}
                required
              />
            </div>
          </div>
        </div>

        <div className="editor-layout">
          <div className="editor-main">
            <div className="editor-section">
              <div className="task-meta-grid">
                <div className="form-field">
                  <label htmlFor="task-assignee-page">Assigned To</label>
                  <div className="combobox">
                    <div className="assignee-input-shell">
                      <span className={`assignee-avatar ${values.assigned_to_id ? "" : "assignee-avatar-default"}`.trim()}>
                        {values.assigned_to_id ? initialsFor(assigneeQuery || "User") : "•"}
                      </span>
                      <input
                        id="task-assignee-page"
                        value={assigneeQuery}
                        placeholder="Search users by name"
                        onFocus={() => setAssigneeOpen(true)}
                        onBlur={() => window.setTimeout(() => setAssigneeOpen(false), 120)}
                        onChange={(event) => {
                          setAssigneeQuery(event.target.value);
                          setAssigneeOpen(true);
                          setValues((current) => ({ ...current, assigned_to_id: "" }));
                        }}
                      />
                    </div>
                    {assigneeOpen ? (
                      <div className="combobox-menu">
                        <button
                          type="button"
                          className={`combobox-option ${values.assigned_to_id === "" ? "selected" : ""}`}
                          onMouseDown={(event) => event.preventDefault()}
                          onClick={() => {
                            setValues((current) => ({ ...current, assigned_to_id: "" }));
                            setAssigneeQuery("");
                            setAssigneeOpen(false);
                          }}
                        >
                          <span className="assignee-option">
                            <span className="assignee-avatar assignee-avatar-default option-avatar">•</span>
                            <span>Unassigned</span>
                          </span>
                        </button>
                        {filteredUsers.map((userItem) => (
                          <button
                            key={userItem.id}
                            type="button"
                            className={`combobox-option ${values.assigned_to_id === String(userItem.id) ? "selected" : ""}`}
                            onMouseDown={(event) => event.preventDefault()}
                            onClick={() => {
                              setValues((current) => ({ ...current, assigned_to_id: String(userItem.id) }));
                              setAssigneeQuery(userItem.full_name);
                              setAssigneeOpen(false);
                            }}
                          >
                            <span className="assignee-option">
                              <span className="assignee-avatar option-avatar">{initialsFor(userItem.full_name)}</span>
                              <span>{userItem.full_name}</span>
                            </span>
                          </button>
                        ))}
                        {!filteredUsers.length ? <div className="combobox-empty">No matching users</div> : null}
                      </div>
                    ) : null}
                  </div>
                </div>
                <div className="form-field">
                  <label htmlFor="task-tags-page">Tags</label>
                  <div className="tag-picker">
                    <div className="combobox">
                      <div className="tag-input-shell">
                        {selectedTags.map((tag) => (
                          <span key={tag} className="task-chip removable-chip">
                            <span>{tag}</span>
                            <button type="button" className="chip-remove" onClick={() => removeTag(tag)} aria-label={`Remove ${tag}`}>
                              x
                            </button>
                          </span>
                        ))}
                        <input
                          id="task-tags-page"
                          value={tagQuery}
                          placeholder="Search tags or create a new tag"
                          onFocus={() => setTagOpen(true)}
                          onBlur={() => window.setTimeout(() => setTagOpen(false), 120)}
                          onChange={(event) => {
                            setTagQuery(event.target.value);
                            setTagOpen(true);
                          }}
                          onKeyDown={(event) => {
                            if (event.key === "Enter" && canCreateTag) {
                              event.preventDefault();
                              addTag(tagQuery);
                            }
                          }}
                        />
                      </div>
                      {tagOpen ? (
                        <div className="combobox-menu">
                          {filteredTags.map((tag) => (
                            <button
                              key={tag.id}
                              type="button"
                              className="combobox-option"
                              onMouseDown={(event) => event.preventDefault()}
                              onClick={() => addTag(tag.name)}
                            >
                              {tag.name}
                            </button>
                          ))}
                          {canCreateTag ? (
                            <button
                              type="button"
                              className="combobox-option selected"
                              onMouseDown={(event) => event.preventDefault()}
                              onClick={() => addTag(tagQuery)}
                            >
                              Create "{tagQuery.trim().toLowerCase()}"
                            </button>
                          ) : null}
                          {!filteredTags.length && !canCreateTag ? <div className="combobox-empty">No matching tags</div> : null}
                        </div>
                      ) : null}
                    </div>
                  </div>
                </div>
                <div className="form-field">
                  <label htmlFor="task-state-page">State</label>
                  <select id="task-state-page" name="state" value={values.state} onChange={handleChange}>
                    {stateOptions.map((option) => (
                      <option key={option.code} value={option.code}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="form-field">
                  <label htmlFor="task-priority-page">Priority</label>
                  <select id="task-priority-page" name="priority" value={values.priority} onChange={handleChange}>
                    {priorityOptions.map((option) => (
                      <option key={option.code} value={option.code}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>

            <div className="editor-section">
              <h3>Description</h3>
              <div className="form-field">
                <textarea
                  id="task-description-page"
                  className="description-textarea"
                  name="description"
                  rows={6}
                  value={values.description}
                  placeholder="Describe scope, expected outcome, or implementation notes"
                  onChange={handleChange}
                />
              </div>
            </div>

              <details className="editor-section collapsible-section" open>
                <summary className="collapsible-summary">
                  <div className="attachments-label-row">
                    <h3>Attachments</h3>
                    <span>Add files while creating or updating the task.</span>
                  </div>
                </summary>
                <div className="collapsible-body">
                  <div
                    className="upload-dropzone editor-dropzone"
                    onDragOver={(event) => event.preventDefault()}
                    onDrop={(event) => {
                      event.preventDefault();
                      handleFileSelection(event.dataTransfer.files);
                    }}
                  >
                    <strong>Upload files</strong>
                    <p>Drag and drop files here, or click to browse.</p>
                    <label className="upload-picker" htmlFor="task-attachments-input">
                      <span className="secondary-button">Choose files</span>
                      <span className="upload-picker-text">PNG, JPG, PDF, DOC, DOCX, TXT</span>
                    </label>
                    <input
                      id="task-attachments-input"
                      className="visually-hidden"
                      type="file"
                      multiple
                      accept=".png,.jpg,.jpeg,.pdf,.doc,.docx,.txt"
                      onChange={(event) => handleFileSelection(event.target.files)}
                    />
                  </div>
                  {selectedFiles.length ? (
                    <div className="file-chip-row">
                      {selectedFiles.map((file, index) => (
                        <span key={`${file.name}-${file.size}-${index}`} className="task-chip removable-chip">
                          <span>{file.name}</span>
                          <button type="button" className="chip-remove" onClick={() => removeSelectedFile(index)}>
                            Remove
                          </button>
                        </span>
                      ))}
                    </div>
                  ) : null}
                  {existingTask?.attachments.length ? (
                    <div className="file-chip-row">
                      {existingTask.attachments.map((attachment) => (
                        <span key={attachment.id} className="task-chip removable-chip">
                          <button
                            type="button"
                            className="task-chip-button"
                            onClick={() => handleDownloadAttachment(attachment.id, attachment.file_name)}
                          >
                            {attachment.file_name}
                          </button>
                          <button
                            type="button"
                            className="chip-remove"
                            onClick={() => handleDeleteAttachment(attachment.id)}
                            disabled={attachmentDeletingId === attachment.id}
                            aria-label={`Delete ${attachment.file_name}`}
                          >
                            {attachmentDeletingId === attachment.id ? "..." : "x"}
                          </button>
                        </span>
                      ))}
                    </div>
                  ) : null}
                </div>
              </details>
            <details className="editor-section collapsible-section" open>
              <summary className="collapsible-summary">
                <div className="discussion-header">
                  <h3>Discussion</h3>
                  <span>{isEdit ? "Collaborate directly on this task." : "Save the task first to enable comments."}</span>
                </div>
              </summary>
              <div className="collapsible-body">
                {isEdit ? (
                  <>
                    <div className="comment-composer">
                      <div className="comment-avatar">{(user?.full_name ?? "U").trim().charAt(0).toUpperCase()}</div>
                      <div className="comment-editor">
                        <textarea
                          rows={3}
                          placeholder="Write a comment"
                          value={commentDraft}
                          onChange={(event) => setCommentDraft(event.target.value)}
                        />
                        <div className="comment-actions">
                          <button
                            type="button"
                            className="secondary-button"
                            onClick={() => setCommentDraft("")}
                          >
                            Cancel
                          </button>
                          <button
                            type="button"
                            className="primary-button"
                            disabled={commentSaving || !commentDraft.trim()}
                            onClick={handleAddComment}
                          >
                            {commentSaving ? "Saving..." : "Add comment"}
                          </button>
                        </div>
                      </div>
                    </div>
                    <div className="comments-thread">
                      {comments.length ? comments.map((comment) => (
                        <article key={comment.id} className="comment-thread-card">
                          <div className="comment-avatar comment-avatar-small">
                            {comment.author_name.trim().charAt(0).toUpperCase()}
                          </div>
                          <div className="comment-thread-body">
                            <div className="comment-thread-head">
                              <strong>{comment.author_name}</strong>
                              <span>{formatDateTime(comment.created_at)}</span>
                            </div>
                            {editingCommentId === comment.id ? (
                              <div className="comment-editor">
                                <textarea
                                  rows={3}
                                  value={editingCommentDraft}
                                  onChange={(event) => setEditingCommentDraft(event.target.value)}
                                />
                                <div className="comment-actions">
                                  <button
                                    type="button"
                                    className="secondary-button"
                                    onClick={handleCancelEditComment}
                                  >
                                    Cancel
                                  </button>
                                  <button
                                    type="button"
                                    className="primary-button"
                                    disabled={commentActionLoadingId === comment.id || !editingCommentDraft.trim()}
                                    onClick={() => handleSaveEditedComment(comment.id)}
                                  >
                                    {commentActionLoadingId === comment.id ? "Saving..." : "Save"}
                                  </button>
                                </div>
                              </div>
                            ) : (
                              <>
                                <p>{comment.content}</p>
                                {user?.id === comment.author_id ? (
                                  <div className="comment-inline-actions">
                                    <button
                                      type="button"
                                      className="comment-link-button"
                                      onClick={() => handleStartEditComment(comment)}
                                      disabled={commentActionLoadingId === comment.id}
                                    >
                                      Edit
                                    </button>
                                    <button
                                      type="button"
                                      className="comment-link-button comment-link-button-danger"
                                      onClick={() => handleDeleteComment(comment.id)}
                                      disabled={commentActionLoadingId === comment.id}
                                    >
                                      {commentActionLoadingId === comment.id ? "Deleting..." : "Delete"}
                                    </button>
                                  </div>
                                ) : null}
                              </>
                            )}
                          </div>
                        </article>
                      )) : <div className="empty-state">No comments yet.</div>}
                    </div>
                  </>
                ) : (
                  <div className="empty-state">Comments become available after the task is created.</div>
                )}
              </div>
            </details>
          </div>

          <aside className="editor-sidebar">
            <div className="editor-side-section">
              <h3>Planning</h3>
              <div className="side-field-list">
                <div className="side-field">
                  <label htmlFor="task-start-date-page">Start Date</label>
                  <input id="task-start-date-page" name="start_date" type="date" value={values.start_date} onChange={handleChange} />
                </div>
                <div className="side-field">
                  <label htmlFor="task-target-date-page">Target Date</label>
                  <input id="task-target-date-page" name="target_date" type="date" value={values.target_date} onChange={handleChange} />
                </div>
                <div className="side-field">
                  <label htmlFor="task-end-date-page">End Date</label>
                  <input id="task-end-date-page" name="end_date" type="date" value={values.end_date} onChange={handleChange} />
                </div>
                <div className="side-field side-field-inline">
                  <span>Created Date</span>
                  <strong>{existingTask ? formatDateTime(existingTask.created_at) : "Will be set on save"}</strong>
                </div>
              </div>
            </div>
          </aside>
        </div>

      </form>
    </section>
  );
}
