import type { FormEvent } from "react";
import { useEffect, useState } from "react";
import { ApiError, api } from "../api/client";
import { useAuth } from "../hooks/useAuth";
import { formatDateTime } from "../utils/format";

export function ProfilePage() {
  const { token, user, setCurrentUser } = useAuth();
  const [openPanel, setOpenPanel] = useState<"profile" | "password" | null>(null);
  const [fullName, setFullName] = useState(user?.full_name ?? "");
  const [profileLoading, setProfileLoading] = useState(false);
  const [passwordLoading, setPasswordLoading] = useState(false);
  const [profileError, setProfileError] = useState("");
  const [profileSuccess, setProfileSuccess] = useState("");
  const [passwordError, setPasswordError] = useState("");
  const [passwordSuccess, setPasswordSuccess] = useState("");
  const [passwords, setPasswords] = useState({
    current_password: "",
    new_password: "",
    confirm_password: ""
  });

  useEffect(() => {
    setFullName(user?.full_name ?? "");
  }, [user?.full_name]);

  const handleProfileSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (!token || !user) {
      return;
    }

    setProfileLoading(true);
    setProfileError("");
    setProfileSuccess("");

    try {
      const updatedUser = await api.updateMe(token, { full_name: fullName.trim() });
      setCurrentUser(updatedUser);
      setProfileSuccess("Profile updated successfully.");
    } catch (error) {
      setProfileError(error instanceof Error ? error.message : "Unable to update profile");
    } finally {
      setProfileLoading(false);
    }
  };

  const handlePasswordSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (!token) {
      return;
    }

    setPasswordError("");
    setPasswordSuccess("");

    if (passwords.new_password !== passwords.confirm_password) {
      setPasswordError("New password and confirm password must match.");
      return;
    }

    setPasswordLoading(true);
    try {
      await api.changePassword(token, {
        current_password: passwords.current_password,
        new_password: passwords.new_password
      });
      setPasswords({ current_password: "", new_password: "", confirm_password: "" });
      setPasswordSuccess("Password changed successfully.");
    } catch (error) {
      if (error instanceof ApiError && error.status === 400) {
        setPasswordError(error.message);
      } else {
        setPasswordError(error instanceof Error ? error.message : "Unable to change password");
      }
    } finally {
      setPasswordLoading(false);
    }
  };

  return (
    <section className="page-shell profile-page">
      <div className="page-header">
        <div>
          <span className="eyebrow">Profile</span>
          <h1>Account settings</h1>
        </div>
      </div>

      <section className="panel profile-hero-card">
        <div className="profile-hero-main">
          <div className="profile-avatar-large">{(user?.full_name ?? "U").trim().charAt(0).toUpperCase()}</div>
          <div className="profile-overview-copy">
            <span className="eyebrow">Workspace account</span>
            <h2>{user?.full_name}</h2>
            <p>{user?.email}</p>
          </div>
        </div>
        <div className="profile-hero-meta">
          <div className="profile-stat-card">
            <span>Member Since</span>
            <strong>{formatDateTime(user?.created_at)}</strong>
          </div>
          <div className="profile-stat-card">
            <span>Status</span>
            <strong>Active</strong>
          </div>
        </div>
        <div className="profile-hero-actions">
          <button
            type="button"
            className={openPanel === "profile" ? "primary-button" : "secondary-button"}
            onClick={() => setOpenPanel((current) => (current === "profile" ? null : "profile"))}
          >
            {openPanel === "profile" ? "Close profile editor" : "Edit profile"}
          </button>
          <button
            type="button"
            className={openPanel === "password" ? "primary-button" : "secondary-button"}
            onClick={() => setOpenPanel((current) => (current === "password" ? null : "password"))}
          >
            {openPanel === "password" ? "Close password form" : "Change password"}
          </button>
        </div>
      </section>

      <div className="profile-layout">
        {openPanel === "profile" ? (
        <section className="panel profile-form-card">
          <div className="section-heading">
            <div>
              <h3>Edit profile</h3>
              <p className="muted-inline">Update the name shown across tasks, comments, and assignments.</p>
            </div>
            <button
              type="button"
              className="panel-close-button"
              aria-label="Close profile editor"
              onClick={() => setOpenPanel(null)}
            >
              x
            </button>
          </div>

          <form className="profile-form" onSubmit={handleProfileSubmit}>
            <label className="form-field">
              <span>Full name</span>
              <input value={fullName} onChange={(event) => setFullName(event.target.value)} required />
            </label>

            <label className="form-field">
              <span>Email</span>
              <input value={user?.email ?? ""} disabled />
            </label>

            {profileError ? <div className="error-banner">{profileError}</div> : null}
            {profileSuccess ? <div className="success-banner">{profileSuccess}</div> : null}

            <div className="profile-actions">
              <button
                type="submit"
                className="primary-button"
                disabled={profileLoading || !user || fullName.trim() === user.full_name}
              >
                {profileLoading ? "Saving..." : "Save profile"}
              </button>
            </div>
          </form>
        </section>
        ) : null}

        {openPanel === "password" ? (
        <section className="panel profile-form-card">
          <div className="section-heading">
            <div>
              <h3>Change password</h3>
              <p className="muted-inline">Choose a new password to keep your account secure.</p>
            </div>
            <button
              type="button"
              className="panel-close-button"
              aria-label="Close password form"
              onClick={() => setOpenPanel(null)}
            >
              x
            </button>
          </div>

          <form className="profile-form" onSubmit={handlePasswordSubmit}>
            <label className="form-field">
              <span>Current password</span>
              <input
                type="password"
                value={passwords.current_password}
                onChange={(event) => setPasswords((current) => ({ ...current, current_password: event.target.value }))}
                required
              />
            </label>

            <label className="form-field">
              <span>New password</span>
              <input
                type="password"
                value={passwords.new_password}
                onChange={(event) => setPasswords((current) => ({ ...current, new_password: event.target.value }))}
                required
              />
            </label>

            <label className="form-field">
              <span>Confirm new password</span>
              <input
                type="password"
                value={passwords.confirm_password}
                onChange={(event) => setPasswords((current) => ({ ...current, confirm_password: event.target.value }))}
                required
              />
            </label>

            {passwordError ? <div className="error-banner">{passwordError}</div> : null}
            {passwordSuccess ? <div className="success-banner">{passwordSuccess}</div> : null}

            <div className="profile-actions">
              <button
                type="submit"
                className="primary-button"
                disabled={
                  passwordLoading
                  || !passwords.current_password
                  || !passwords.new_password
                  || !passwords.confirm_password
                }
              >
                {passwordLoading ? "Updating..." : "Change password"}
              </button>
            </div>
          </form>
        </section>
        ) : null}
      </div>
    </section>
  );
}
