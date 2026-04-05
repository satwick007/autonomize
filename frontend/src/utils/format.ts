export const formatDate = (value?: string | null) => (value ? new Date(value).toLocaleDateString() : "-");
export const formatDateTime = (value?: string | null) => (value ? new Date(value).toLocaleString() : "-");
export const formatHours = (value?: number | null) => (value === null || value === undefined ? "-" : `${value}h`);
export const titleize = (value: string) => value.replace(/_/g, " ").replace(/\b\w/g, (character: string) => character.toUpperCase());
