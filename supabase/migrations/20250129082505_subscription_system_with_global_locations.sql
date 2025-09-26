-- Location: supabase/migrations/20250129082505_subscription_system_with_global_locations.sql
-- Schema Analysis: Extending existing marketplace with subscription system and global data
-- Integration Type: Addition to existing schema
-- Dependencies: Extends 20250129081015_marketplace_with_payments.sql

-- Additional types for global system
CREATE TYPE public.subscription_status AS ENUM ('active', 'expired', 'cancelled', 'pending');
CREATE TYPE public.currency_status AS ENUM ('active', 'inactive');
CREATE TYPE public.location_status AS ENUM ('active', 'inactive');

-- Global currencies table
CREATE TABLE public.currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE, -- USD, EUR, GBP, etc.
    name TEXT NOT NULL,
    symbol TEXT NOT NULL,
    exchange_rate DECIMAL(10,6) DEFAULT 1.00, -- Rate relative to base currency
    is_base BOOLEAN DEFAULT false,
    status public.currency_status DEFAULT 'active'::public.currency_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Global locations table
CREATE TABLE public.locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code TEXT NOT NULL,
    country_name TEXT NOT NULL,
    state_code TEXT,
    state_name TEXT,
    city_name TEXT,
    postal_code TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    timezone TEXT,
    status public.location_status DEFAULT 'active'::public.location_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Subscription tiers
CREATE TABLE public.subscription_tiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency_id UUID REFERENCES public.currencies(id) ON DELETE CASCADE,
    billing_cycle TEXT DEFAULT 'monthly', -- monthly, yearly
    features JSONB DEFAULT '[]'::jsonb,
    max_listings INTEGER DEFAULT 10,
    priority_support BOOLEAN DEFAULT false,
    featured_listings BOOLEAN DEFAULT false,
    analytics_access BOOLEAN DEFAULT false,
    is_popular BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User subscriptions
CREATE TABLE public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    tier_id UUID REFERENCES public.subscription_tiers(id) ON DELETE CASCADE,
    status public.subscription_status DEFAULT 'pending'::public.subscription_status,
    current_period_start TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    current_period_end TIMESTAMPTZ,
    stripe_subscription_id TEXT,
    stripe_customer_id TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User preferences for location and currency
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    preferred_currency_id UUID REFERENCES public.currencies(id) ON DELETE SET NULL,
    preferred_location_id UUID REFERENCES public.locations(id) ON DELETE SET NULL,
    language_code TEXT DEFAULT 'en',
    theme TEXT DEFAULT 'system', -- light, dark, system
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Essential indexes
CREATE INDEX idx_currencies_code ON public.currencies(code);
CREATE INDEX idx_currencies_status ON public.currencies(status);
CREATE INDEX idx_locations_country_code ON public.locations(country_code);
CREATE INDEX idx_locations_status ON public.locations(status);
CREATE INDEX idx_subscription_tiers_active ON public.subscription_tiers(is_active);
CREATE INDEX idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_status ON public.user_subscriptions(status);
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id);

-- Enable RLS
ALTER TABLE public.currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- Helper functions
CREATE OR REPLACE FUNCTION public.can_access_user_subscription(subscription_uuid UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_subscriptions us
    WHERE us.id = subscription_uuid AND us.user_id = auth.uid()
)
$$;

-- RLS Policies
CREATE POLICY "public_can_read_active_currencies" ON public.currencies FOR SELECT
TO public USING (status = 'active'::public.currency_status);

CREATE POLICY "public_can_read_active_locations" ON public.locations FOR SELECT
TO public USING (status = 'active'::public.location_status);

CREATE POLICY "public_can_read_active_subscription_tiers" ON public.subscription_tiers FOR SELECT
TO public USING (is_active = true);

CREATE POLICY "users_manage_own_subscriptions" ON public.user_subscriptions FOR ALL
TO authenticated USING (public.can_access_user_subscription(id)) WITH CHECK (public.can_access_user_subscription(id));

CREATE POLICY "users_manage_own_preferences" ON public.user_preferences FOR ALL
TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Admin policies for management
CREATE POLICY "admins_manage_currencies" ON public.currencies FOR ALL
TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "admins_manage_locations" ON public.locations FOR ALL
TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "admins_manage_subscription_tiers" ON public.subscription_tiers FOR ALL
TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Sample data for global system
DO $$
DECLARE
    usd_id UUID := gen_random_uuid();
    eur_id UUID := gen_random_uuid();
    gbp_id UUID := gen_random_uuid();
    usa_id UUID := gen_random_uuid();
    uk_id UUID := gen_random_uuid();
    germany_id UUID := gen_random_uuid();
    basic_tier_id UUID := gen_random_uuid();
    premium_tier_id UUID := gen_random_uuid();
    pro_tier_id UUID := gen_random_uuid();
BEGIN
    -- Insert currencies
    INSERT INTO public.currencies (id, code, name, symbol, exchange_rate, is_base) VALUES
        (usd_id, 'USD', 'US Dollar', '$', 1.00, true),
        (eur_id, 'EUR', 'Euro', '€', 0.85, false),
        (gbp_id, 'GBP', 'British Pound', '£', 0.73, false);

    -- Insert major locations
    INSERT INTO public.locations (id, country_code, country_name, state_code, state_name, city_name, timezone) VALUES
        (usa_id, 'US', 'United States', 'NY', 'New York', 'New York City', 'America/New_York'),
        (uk_id, 'GB', 'United Kingdom', 'ENG', 'England', 'London', 'Europe/London'),
        (germany_id, 'DE', 'Germany', 'BE', 'Berlin', 'Berlin', 'Europe/Berlin');

    -- Insert subscription tiers
    INSERT INTO public.subscription_tiers (id, name, description, price, currency_id, features, max_listings, priority_support, featured_listings, analytics_access, is_popular) VALUES
        (basic_tier_id, 'Basic', 'Perfect for casual sellers', 0.00, usd_id, 
         '["Up to 5 active listings", "Basic messaging", "Standard support"]'::jsonb, 5, false, false, false, false),
        (premium_tier_id, 'Premium', 'Great for regular sellers', 9.99, usd_id,
         '["Up to 25 active listings", "Priority messaging", "Featured listings", "Basic analytics", "Priority support"]'::jsonb, 25, true, true, true, true),
        (pro_tier_id, 'Professional', 'For power sellers', 29.99, usd_id,
         '["Unlimited listings", "Advanced messaging", "Premium placement", "Advanced analytics", "Dedicated support", "Bulk tools"]'::jsonb, -1, true, true, true, false);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Global system data insertion failed: %', SQLERRM;
END $$;