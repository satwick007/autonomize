import type { FormEvent } from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

export function RegisterPage() {
  const { requestRegistrationOtp, verifyRegistrationOtp } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ fullName: "", email: "", password: "", otp: "" });
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
    <div className="auth-shell">
      <div className="auth-hero">
        <span className="eyebrow">Workspace onboarding</span>
        <h1>Create your delivery workspace.</h1>
        <p>Register with email verification, then manage work across board and list views with the same live task data.</p>
      </div>
      <form className="auth-card" onSubmit={handleSubmit}>
        <h2>{otpRequested ? "Verify email" : "Create account"}</h2>
        <input
          placeholder="Full name"
          value={form.fullName}
          onChange={(event) => setForm((current) => ({ ...current, fullName: event.target.value }))}
          required
          disabled={otpRequested}
        />
        <input
          type="email"
          placeholder="Email"
          value={form.email}
          onChange={(event) => setForm((current) => ({ ...current, email: event.target.value }))}
          required
          disabled={otpRequested}
        />
        <input
          type="password"
          placeholder="Password"
          value={form.password}
          onChange={(event) => setForm((current) => ({ ...current, password: event.target.value }))}
          required
          disabled={otpRequested}
        />
        {otpRequested ? (
          <input
            placeholder="Enter 6-digit OTP"
            value={form.otp}
            onChange={(event) => setForm((current) => ({ ...current, otp: event.target.value }))}
            required
            maxLength={6}
          />
        ) : null}
        {error ? <div className="error-banner">{error}</div> : null}
        {success ? <div className="success-banner">{success}</div> : null}
        <button className="primary-button" disabled={loading}>
          {loading ? (otpRequested ? "Verifying..." : "Sending OTP...") : (otpRequested ? "Verify and create account" : "Send OTP")}
        </button>
        {otpRequested ? (
          <button type="button" className="secondary-button" onClick={handleResendOtp} disabled={loading}>
            Resend OTP
          </button>
        ) : null}
        <p>
          Already have an account? <Link to="/login">Sign in</Link>
        </p>
      </form>
    </div>
  );
}
