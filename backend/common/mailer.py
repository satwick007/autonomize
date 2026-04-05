from __future__ import annotations

from email.message import EmailMessage
import smtplib

from fastapi import HTTPException, status

from config.settings import get_settings


def send_registration_otp_email(email: str, full_name: str, otp_code: str) -> None:
    settings = get_settings()

    if not all([settings.smtp_host, settings.smtp_from_email, settings.smtp_username, settings.smtp_password]):
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="SMTP is not configured for OTP email delivery.",
        )

    message = EmailMessage()
    message["Subject"] = "Your Task Management verification code"
    message["From"] = settings.smtp_from_email
    message["To"] = email
    message.set_content(
        f"Hello {full_name},\n\n"
        f"Your Task Management registration OTP is: {otp_code}\n\n"
        f"It expires in {settings.registration_otp_expire_minutes} minutes.\n"
    )

    try:
        with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=10) as server:
            if settings.smtp_use_tls:
                server.starttls()
            server.login(settings.smtp_username, settings.smtp_password)
            server.send_message(message)
    except (smtplib.SMTPException, OSError) as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Unable to send OTP email. Please check SMTP settings.",
        ) from exc
