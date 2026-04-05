import type { FormEvent } from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ApiError } from "../api/client";
import { useAuth } from "../hooks/useAuth";

export function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setError("");
    try {
      await login(email, password);
      navigate("/");
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.status === 401) {
          setError("The email or password you entered is incorrect.");
        } else if (err.status === 422) {
          setError(err.details[0] ?? "Enter a valid email and a password with at least 6 characters.");
        } else {
          setError(err.message || "Login failed");
        }
      } else {
        setError(err instanceof Error ? err.message : "Login failed");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-shell auth-shell-login">
      <section className="auth-hero auth-login-hero">
        <div className="auth-login-badge">Task Management</div>
        <div className="auth-login-copy">
          <span className="eyebrow">Delivery workspace</span>
          <h1>Manage delivery work in one clear workspace.</h1>
          <p>Boards, lists, comments, files, and analytics in a single task system.</p>
        </div>
      </section>

      <div className="auth-login-panel">
        <form className="auth-card auth-login-card" onSubmit={handleSubmit}>
          <div className="auth-login-card-head">
            <span className="eyebrow">Sign in</span>
            <h2>Welcome back</h2>
            <p>Use your workspace account to continue managing delivery tasks.</p>
          </div>

          <label className="form-field">
            <span>Email</span>
            <input type="email" placeholder="you@company.com" value={email} onChange={(event) => setEmail(event.target.value)} required />
          </label>

          <label className="form-field">
            <span>Password</span>
            <input
              type="password"
              placeholder="Enter your password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
            />
          </label>

          {error ? <div className="error-banner">{error}</div> : null}

          <button className="primary-button auth-login-submit" disabled={loading}>
            {loading ? "Signing in..." : "Sign in"}
          </button>

          <p className="auth-login-switch">
            Need an account? <Link to="/register">Create one</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
