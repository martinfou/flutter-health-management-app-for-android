<?php

declare(strict_types=1);

namespace HealthApp\Services;

class EmailService
{
    private string $fromEmail;
    private string $fromName;

    public function __construct(array $config)
    {
        $this->fromEmail = $config['from_email'] ?? 'noreply@health.martinfourier.com';
        $this->fromName = $config['from_name'] ?? 'Health Management App';
    }

    private function send(string $toEmail, string $subject, string $htmlBody): bool
    {
        $headers = [
            'From' => $this->fromName . ' <' . $this->fromEmail . '>',
            'MIME-Version' => '1.0',
            'Content-Type' => 'text/html; charset=UTF-8',
            'Reply-To' => $this->fromEmail,
            'X-Mailer' => 'PHP/' . phpversion(),
        ];

        $success = mail($toEmail, $subject, $htmlBody, implode("\r\n", $headers));

        if (!$success) {
            error_log('Email failed to ' . $toEmail);
        }

        return $success;
    }

    public function sendPasswordResetEmail(string $email, string $token): bool
    {
        $resetUrl = 'https://health.martinfourier.com/reset-password?token=' . urlencode($token);
        $subject = 'Password Reset - Health Management App';

        $htmlBody = $this->getPasswordResetTemplate($email, $resetUrl);

        return $this->send($email, $subject, $htmlBody);
    }

    public function sendAccountDeletionConfirmation(string $email): bool
    {
        $subject = 'Account Deleted - Health Management App';

        $htmlBody = $this->getAccountDeletionTemplate($email);

        return $this->send($email, $subject, $htmlBody);
    }

    private function getPasswordResetTemplate(string $email, string $resetUrl): string
    {
        return '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Your Password</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .button { display: inline-block; padding: 12px 30px; background: #4CAF50; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }
        .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Health Management App</h1>
        </div>
        <div class="content">
            <h2>Reset Your Password</h2>
            <p>Hello,</p>
            <p>We received a request to reset your password for account associated with <strong>' . htmlspecialchars($email) . '</strong>.</p>
            <p>Click the button below to reset your password:</p>
            <center>
                <a href="' . htmlspecialchars($resetUrl) . '" class="button">Reset Password</a>
            </center>
            <p>If you did not make this request, you can safely ignore this email. Your password will remain unchanged.</p>
            <p>This link will expire in 1 hour for security reasons.</p>
        </div>
        <div class="footer">
            <p>&copy; 2026 Health Management App. All rights reserved.</p>
        </div>
    </div>
</body>
</html>';
    }

    private function getAccountDeletionTemplate(string $email): string
    {
        return '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Deleted</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #f44336; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Health Management App</h1>
        </div>
        <div class="content">
            <h2>Account Deleted</h2>
            <p>Hello,</p>
            <p>Your account associated with <strong>' . htmlspecialchars($email) . '</strong> has been successfully deleted from Health Management App.</p>
            <p><strong>All your data has been permanently removed from our servers.</strong></p>
            <p>If you did not request this deletion, please contact our support team immediately.</p>
            <p>Thank you for using Health Management App.</p>
        </div>
        <div class="footer">
            <p>&copy; 2026 Health Management App. All rights reserved.</p>
        </div>
    </div>
</body>
</html>';
    }
}
