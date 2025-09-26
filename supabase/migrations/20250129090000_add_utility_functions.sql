-- Location: supabase/migrations/20250129090000_add_utility_functions.sql
-- Schema Analysis: Adding utility functions to existing comprehensive schema
-- Integration Type: Enhancement to existing marketplace and subscription system
-- Dependencies: Extends 20250129082505_subscription_system_with_global_locations.sql

-- Utility functions for better user experience and performance

-- Function to increment view count
CREATE OR REPLACE FUNCTION public.increment_view_count(listing_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.listings
    SET views_count = views_count + 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = listing_id;
END;
$$;

-- Function to increment favorites count
CREATE OR REPLACE FUNCTION public.increment_favorites_count(listing_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.listings
    SET favorites_count = favorites_count + 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = listing_id;
END;
$$;

-- Function to decrement favorites count
CREATE OR REPLACE FUNCTION public.decrement_favorites_count(listing_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.listings
    SET favorites_count = GREATEST(favorites_count - 1, 0),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = listing_id;
END;
$$;

-- Function to check if user can manage listing
CREATE OR REPLACE FUNCTION public.can_manage_listing(listing_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.listings l
    WHERE l.id = listing_uuid 
    AND (l.seller_id = user_uuid OR EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = user_uuid AND up.role = 'admin'::public.user_role
    ))
)
$$;

-- Function to get listing statistics
CREATE OR REPLACE FUNCTION public.get_listing_stats(listing_uuid UUID)
RETURNS TABLE(
    views_count INTEGER,
    favorites_count INTEGER,
    messages_count BIGINT,
    is_featured BOOLEAN,
    days_active INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.views_count,
        l.favorites_count,
        (SELECT COUNT(*) FROM public.conversations c WHERE c.listing_id = listing_uuid),
        l.featured,
        EXTRACT(DAY FROM (CURRENT_TIMESTAMP - l.created_at))::INTEGER
    FROM public.listings l
    WHERE l.id = listing_uuid;
END;
$$;

-- Function to get user dashboard statistics
CREATE OR REPLACE FUNCTION public.get_user_dashboard_stats(user_uuid UUID)
RETURNS TABLE(
    total_listings BIGINT,
    active_listings BIGINT,
    sold_listings BIGINT,
    total_views BIGINT,
    total_favorites BIGINT,
    total_messages BIGINT,
    avg_rating DECIMAL(3,2),
    total_sales BIGINT,
    revenue_this_month DECIMAL(10,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM public.listings WHERE seller_id = user_uuid),
        (SELECT COUNT(*) FROM public.listings WHERE seller_id = user_uuid AND status = 'active'::public.listing_status),
        (SELECT COUNT(*) FROM public.listings WHERE seller_id = user_uuid AND status = 'sold'::public.listing_status),
        (SELECT COALESCE(SUM(views_count), 0) FROM public.listings WHERE seller_id = user_uuid),
        (SELECT COALESCE(SUM(favorites_count), 0) FROM public.listings WHERE seller_id = user_uuid),
        (SELECT COUNT(*) FROM public.conversations WHERE seller_id = user_uuid),
        (SELECT COALESCE(AVG(rating), 0.00) FROM public.reviews WHERE reviewed_user_id = user_uuid),
        (SELECT COUNT(*) FROM public.transactions WHERE seller_id = user_uuid AND payment_status = 'completed'::public.payment_status),
        (SELECT COALESCE(SUM(amount), 0.00) 
         FROM public.transactions 
         WHERE seller_id = user_uuid 
         AND payment_status = 'completed'::public.payment_status
         AND created_at >= DATE_TRUNC('month', CURRENT_TIMESTAMP));
END;
$$;

-- Function to search listings with full-text search capabilities
CREATE OR REPLACE FUNCTION public.search_listings(
    search_query TEXT DEFAULT NULL,
    category_filter UUID DEFAULT NULL,
    min_price DECIMAL DEFAULT NULL,
    max_price DECIMAL DEFAULT NULL,
    condition_filter TEXT DEFAULT NULL,
    location_filter TEXT DEFAULT NULL,
    user_location TEXT DEFAULT NULL,
    result_limit INTEGER DEFAULT 20,
    result_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id UUID,
    title TEXT,
    description TEXT,
    price DECIMAL(10,2),
    condition public.listing_condition,
    location TEXT,
    images TEXT[],
    views_count INTEGER,
    favorites_count INTEGER,
    created_at TIMESTAMPTZ,
    seller_name TEXT,
    seller_rating DECIMAL(3,2),
    category_name TEXT,
    distance_score DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.title,
        l.description,
        l.price,
        l.condition,
        l.location,
        l.images,
        l.views_count,
        l.favorites_count,
        l.created_at,
        up.full_name AS seller_name,
        up.rating AS seller_rating,
        c.name AS category_name,
        CASE 
            WHEN user_location IS NOT NULL AND l.location IS NOT NULL THEN
                CASE WHEN l.location ILIKE '%' || user_location || '%' THEN 1.0 ELSE 0.5 END
            ELSE 1.0
        END AS distance_score
    FROM public.listings l
    JOIN public.user_profiles up ON l.seller_id = up.id
    JOIN public.categories c ON l.category_id = c.id
    WHERE l.status = 'active'::public.listing_status
        AND (search_query IS NULL OR 
             l.title ILIKE '%' || search_query || '%' OR 
             l.description ILIKE '%' || search_query || '%' OR
             l.tags::TEXT ILIKE '%' || search_query || '%')
        AND (category_filter IS NULL OR l.category_id = category_filter)
        AND (min_price IS NULL OR l.price >= min_price)
        AND (max_price IS NULL OR l.price <= max_price)
        AND (condition_filter IS NULL OR l.condition::TEXT = condition_filter)
        AND (location_filter IS NULL OR l.location ILIKE '%' || location_filter || '%')
    ORDER BY 
        distance_score DESC,
        l.featured DESC,
        l.created_at DESC
    LIMIT result_limit
    OFFSET result_offset;
END;
$$;

-- Function to get trending categories (most active in last 7 days)
CREATE OR REPLACE FUNCTION public.get_trending_categories(result_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    category_id UUID,
    category_name TEXT,
    listings_count BIGINT,
    avg_price DECIMAL(10,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id AS category_id,
        c.name AS category_name,
        COUNT(l.id) AS listings_count,
        COALESCE(AVG(l.price), 0.00) AS avg_price
    FROM public.categories c
    LEFT JOIN public.listings l ON c.id = l.category_id 
        AND l.status = 'active'::public.listing_status
        AND l.created_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
    WHERE c.is_active = true
    GROUP BY c.id, c.name
    ORDER BY listings_count DESC, c.name
    LIMIT result_limit;
END;
$$;

-- Function to clean up expired listings
CREATE OR REPLACE FUNCTION public.cleanup_expired_listings()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    -- Update expired listings
    UPDATE public.listings
    SET status = 'expired'::public.listing_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE status = 'active'::public.listing_status
    AND expires_at < CURRENT_TIMESTAMP;
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    
    RETURN expired_count;
END;
$$;

-- Function to get user subscription benefits
CREATE OR REPLACE FUNCTION public.get_user_subscription_benefits(user_uuid UUID)
RETURNS TABLE(
    has_active_subscription BOOLEAN,
    tier_name TEXT,
    max_listings INTEGER,
    current_listings_count BIGINT,
    can_create_listing BOOLEAN,
    priority_support BOOLEAN,
    featured_listings BOOLEAN,
    analytics_access BOOLEAN,
    days_remaining INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    subscription_record RECORD;
    current_listings BIGINT;
BEGIN
    -- Get active subscription
    SELECT us.*, st.name, st.max_listings, st.priority_support, 
           st.featured_listings, st.analytics_access
    INTO subscription_record
    FROM public.user_subscriptions us
    JOIN public.subscription_tiers st ON us.tier_id = st.id
    WHERE us.user_id = user_uuid 
    AND us.status = 'active'::public.subscription_status
    AND us.current_period_end > CURRENT_TIMESTAMP
    ORDER BY us.created_at DESC
    LIMIT 1;

    -- Count current active listings
    SELECT COUNT(*) INTO current_listings
    FROM public.listings
    WHERE seller_id = user_uuid AND status = 'active'::public.listing_status;

    -- Return subscription benefits
    RETURN QUERY
    SELECT 
        subscription_record.id IS NOT NULL AS has_active_subscription,
        COALESCE(subscription_record.name, 'Free') AS tier_name,
        COALESCE(subscription_record.max_listings, 5) AS max_listings,
        current_listings AS current_listings_count,
        (current_listings < COALESCE(subscription_record.max_listings, 5) OR 
         COALESCE(subscription_record.max_listings, 5) = -1) AS can_create_listing,
        COALESCE(subscription_record.priority_support, false) AS priority_support,
        COALESCE(subscription_record.featured_listings, false) AS featured_listings,
        COALESCE(subscription_record.analytics_access, false) AS analytics_access,
        CASE 
            WHEN subscription_record.current_period_end IS NOT NULL THEN
                EXTRACT(DAY FROM (subscription_record.current_period_end - CURRENT_TIMESTAMP))::INTEGER
            ELSE 0
        END AS days_remaining;
END;
$$;

-- Add indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_listings_search_text ON public.listings USING gin(to_tsvector('english', title || ' ' || description));
CREATE INDEX IF NOT EXISTS idx_listings_location_search ON public.listings USING gin(location gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_listings_price_range ON public.listings(price) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_listings_created_recent ON public.listings(created_at DESC) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_user_profiles_rating ON public.user_profiles(rating DESC) WHERE rating > 0;

-- Enable the pg_trgm extension for fuzzy text search if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_trgm;