import type { FormEvent } from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

export function RegisterPage() {
  const { requestRegistrationOtp, verifyRegistrationOtp } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ fullName: "", email: "", password: "", otp: "" });
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [otpRequested, setOtpRequested] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");

    try {
      if (!otpRequested) {
        await requestRegistrationOtp(form.fullName, form.email, form.password);
        setOtpRequested(true);
        setSuccess("Verification code sent. Enter the OTP to complete registration.");
      } else {
        await verifyRegistrationOtp(form.email, form.otp);
        navigate("/");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Registration failed");
    } finally {
      setLoading(false);
    }
  };

  const handleResendOtp = async () => {
    setLoading(true);
    setError("");
    setSuccess("");

    try {
      await requestRegistrationOtp(form.fullName, form.email, form.password);
      setOtpRequested(true);
      setSuccess("A new verification code has been sent.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to resend OTP");
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
            <span className="eyebrow">{otpRequested ? "Verify email" : "Create account"}</span>
            <h2>{otpRequested ? "Enter verification code" : "Get started"}</h2>
            <p>
              {otpRequested
                ? "We sent a 6-digit code to your email. Enter it below to finish creating your account."
                : "Create your workspace account and we’ll send a one-time verification code to your email."}
            </p>
          </div>

          <label className="form-field">
            <span>Full name</span>
            <input
              placeholder="Your full name"
              value={form.fullName}
              onChange={(event) => setForm((current) => ({ ...current, fullName: event.target.value }))}
              required
              disabled={otpRequested}
            />
          </label>

          <label className="form-field">
            <span>Email</span>
            <input
              type="email"
              placeholder="you@company.com"
              value={form.email}
              onChange={(event) => setForm((current) => ({ ...current, email: event.target.value }))}
              required
              disabled={otpRequested}
            />
          </label>

          <label className="form-field">
            <span>Password</span>
            <div className="password-field">
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Create a password"
                value={form.password}
                onChange={(event) => setForm((current) => ({ ...current, password: event.target.value }))}
                required
                disabled={otpRequested}
              />
              <button
                type="button"
                className="password-toggle"
                onClick={() => setShowPassword((current) => !current)}
                aria-label={showPassword ? "Hide password" : "Show password"}
                disabled={otpRequested}
              >
                {showPassword ? "Hide" : "Show"}
              </button>
            </div>
          </label>

          {otpRequested ? (
            <label className="form-field">
              <span>Verification code</span>
              <input
                placeholder="Enter 6-digit OTP"
                value={form.otp}
                onChange={(event) => setForm((current) => ({ ...current, otp: event.target.value }))}
                required
                maxLength={6}
              />
            </label>
          ) : null}

          {error ? <div className="error-banner">{error}</div> : null}
          {success ? <div className="success-banner">{success}</div> : null}

          <button className="primary-button auth-login-submit" disabled={loading}>
            {loading ? (otpRequested ? "Verifying..." : "Sending OTP...") : (otpRequested ? "Verify and create account" : "Send OTP")}
          </button>

          {otpRequested ? (
            <button type="button" className="secondary-button" onClick={handleResendOtp} disabled={loading}>
              Resend OTP
            </button>
          ) : null}

          <p className="auth-login-switch">
            Already have an account? <Link to="/login">Sign in</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
