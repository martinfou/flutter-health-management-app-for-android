<?php

namespace App\Services;

use Illuminate\Support\Facades\Mail;
use Illuminate\Mail\Message;

class EmailService
{
    /**
     * Send password reset email
     */
    public function sendPasswordResetEmail(string $email, string $token, string $name = ''): bool
    {
        try {
            $resetUrl = config('app.frontend_url') . '/reset-password?token=' . $token . '&email=' . urlencode($email);

            Mail::send('emails.password-reset', [
                'name' => $name,
                'resetUrl' => $resetUrl,
                'email' => $email,
            ], function (Message $message) use ($email) {
                $message->to($email)
                    ->subject('Reset Your Password - Health Management App');
            });

            return true;
        } catch (\Exception $e) {
            // Log the error but don't throw
            logger()->error('Failed to send password reset email: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send welcome email
     */
    public function sendWelcomeEmail(string $email, string $name = ''): bool
    {
        try {
            Mail::send('emails.welcome', [
                'name' => $name,
                'appUrl' => config('app.url'),
            ], function (Message $message) use ($email) {
                $message->to($email)
                    ->subject('Welcome to Health Management App');
            });

            return true;
        } catch (\Exception $e) {
            // Log the error but don't throw
            logger()->error('Failed to send welcome email: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send account deletion confirmation email
     */
    public function sendAccountDeletionEmail(string $email, string $name = ''): bool
    {
        try {
            Mail::send('emails.account-deleted', [
                'name' => $name,
                'supportEmail' => env('SUPPORT_EMAIL', 'support@healthapp.com'),
            ], function (Message $message) use ($email) {
                $message->to($email)
                    ->subject('Your Account Has Been Deleted - Health Management App');
            });

            return true;
        } catch (\Exception $e) {
            // Log the error but don't throw
            logger()->error('Failed to send account deletion email: ' . $e->getMessage());
            return false;
        }
    }
}
