<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use RuntimeException;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $adminEmail = config('app.admin_email');

        if (empty($adminEmail)) {
            throw new RuntimeException(
                'ADMIN_EMAIL is not configured.'
            );
        }

        $admin = User::query()
            ->where('email', $adminEmail)
            ->first();

        if (! $admin) {
            throw new RuntimeException(
                "Admin user with email {$adminEmail} was not found."
            );
        }

        $admin->forceFill([
            'role' => 'admin',
        ])->save();
    }
}
