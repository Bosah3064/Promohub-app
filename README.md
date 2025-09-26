# PromoHub - Marketplace Application

A Flutter-based marketplace application with Supabase backend integration.

## Database Setup

### Prerequisites
- Supabase project created
- Supabase CLI installed

### Running Migrations

To apply the database migrations and create the required tables:

1. **Initialize Supabase locally (if not done already):**
   ```bash
   supabase init
   ```

2. **Link to your Supabase project:**
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

3. **Apply migrations to your database:**
   ```bash
   supabase db push
   ```

   Or alternatively:
   ```bash
   supabase migration up
   ```

4. **Verify tables were created:**
   ```bash
   supabase db diff
   ```

### Manual Migration Application

If you prefer to apply migrations manually through the Supabase Dashboard:

1. Go to your Supabase Dashboard
2. Navigate to the SQL Editor
3. Copy the contents of `supabase/migrations/20250129081015_marketplace_with_payments.sql`
4. Paste and execute the SQL

### Troubleshooting

If you encounter the error `relation "public.user_profiles" does not exist`:

1. Check if migrations have been applied:
   ```bash
   supabase migration list
   ```

2. If migrations show as pending, apply them:
   ```bash
   supabase db push
   ```

3. Verify the tables exist in your database through the Supabase Dashboard

## Environment Setup

Create your environment configuration with the following keys:

```bash
flutter run --dart-define=SUPABASE_URL=your-supabase-url --dart-define=SUPABASE_ANON_KEY=your-anon-key --dart-define=STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get`
3. Set up your Supabase project and apply migrations
4. Configure environment variables
5. Run the app with `flutter run`

## Features

- User authentication and profiles
- Marketplace listings with categories
- Messaging system
- Payment integration with Stripe
- User achievements and ratings
- Subscription management
- Location-based features

## Database Schema

The application uses the following main tables:
- `user_profiles` - User account information
- `listings` - Marketplace items
- `categories` - Product categories
- `conversations` & `messages` - Chat system
- `transactions` - Payment records
- `favorites` - Saved items
- `achievements` & `user_achievements` - Gamification
- `reviews` - User ratings

For detailed schema, see the migration files in `supabase/migrations/`.