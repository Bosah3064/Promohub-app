-- Location: supabase/migrations/20250129081015_marketplace_with_payments.sql
-- Schema Analysis: Fresh marketplace implementation with authentication and payments
-- Integration Type: Complete new system
-- Dependencies: None (fresh start)

-- 1. Types and Core Tables
CREATE TYPE public.user_role AS ENUM ('admin', 'seller', 'buyer');
CREATE TYPE public.listing_status AS ENUM ('active', 'sold', 'expired', 'draft');
CREATE TYPE public.listing_condition AS ENUM ('new', 'like_new', 'good', 'fair', 'poor');
CREATE TYPE public.payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE public.transaction_type AS ENUM ('purchase', 'refund', 'fee');

-- User profiles intermediary table (required for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    phone TEXT,
    location TEXT,
    role public.user_role DEFAULT 'buyer'::public.user_role,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_sales INTEGER DEFAULT 0,
    total_purchases INTEGER DEFAULT 0,
    verification_status BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Categories for marketplace listings
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Marketplace listings
CREATE TABLE public.listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    condition public.listing_condition DEFAULT 'good'::public.listing_condition,
    status public.listing_status DEFAULT 'active'::public.listing_status,
    location TEXT,
    images TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    views_count INTEGER DEFAULT 0,
    favorites_count INTEGER DEFAULT 0,
    is_negotiable BOOLEAN DEFAULT true,
    featured BOOLEAN DEFAULT false,
    expires_at TIMESTAMPTZ DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days'),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User favorites
CREATE TABLE public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, listing_id)
);

-- Messages and conversations
CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    seller_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    last_message TEXT,
    last_message_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Payment transactions
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    seller_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    stripe_payment_intent_id TEXT,
    payment_status public.payment_status DEFAULT 'pending'::public.payment_status,
    transaction_type public.transaction_type DEFAULT 'purchase'::public.transaction_type,
    processing_fee DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ
);

-- User achievements for motivation
CREATE TABLE public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    icon_url TEXT,
    points INTEGER DEFAULT 0,
    badge_color TEXT DEFAULT '#4CAF50',
    criteria JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User achievement progress
CREATE TABLE public.user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    progress INTEGER DEFAULT 100,
    UNIQUE(user_id, achievement_id)
);

-- Reviews and ratings
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    reviewed_user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_listings_seller_id ON public.listings(seller_id);
CREATE INDEX idx_listings_category_id ON public.listings(category_id);
CREATE INDEX idx_listings_status ON public.listings(status);
CREATE INDEX idx_listings_price ON public.listings(price);
CREATE INDEX idx_listings_created_at ON public.listings(created_at DESC);
CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX idx_favorites_listing_id ON public.favorites(listing_id);
CREATE INDEX idx_conversations_listing_id ON public.conversations(listing_id);
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_transactions_buyer_id ON public.transactions(buyer_id);
CREATE INDEX idx_transactions_seller_id ON public.transactions(seller_id);
CREATE INDEX idx_user_achievements_user_id ON public.user_achievements(user_id);
CREATE INDEX idx_reviews_reviewed_user_id ON public.reviews(reviewed_user_id);

-- 3. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- 4. Helper Functions
CREATE OR REPLACE FUNCTION public.is_listing_owner(listing_uuid UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
SELECT EXISTS (
    SELECT 1 FROM public.listings l
    WHERE l.id = listing_uuid AND l.seller_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_conversation(conversation_uuid UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
SELECT EXISTS (
    SELECT 1 FROM public.conversations c
    WHERE c.id = conversation_uuid 
    AND (c.buyer_id = auth.uid() OR c.seller_id = auth.uid())
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_transaction(transaction_uuid UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
SELECT EXISTS (
    SELECT 1 FROM public.transactions t
    WHERE t.id = transaction_uuid 
    AND (t.buyer_id = auth.uid() OR t.seller_id = auth.uid())
)
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'::public.user_role
)
$$;

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'buyer')::public.user_role
  );  
  RETURN NEW;
END;
$$;

-- Function to update user ratings
CREATE OR REPLACE FUNCTION public.update_user_rating()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update the reviewed user's rating
    UPDATE public.user_profiles
    SET rating = (
        SELECT ROUND(AVG(rating)::numeric, 2)
        FROM public.reviews
        WHERE reviewed_user_id = NEW.reviewed_user_id
    )
    WHERE id = NEW.reviewed_user_id;
    
    RETURN NEW;
END;
$$;

-- 5. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_rating_trigger
  AFTER INSERT ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_user_rating();

-- 6. RLS Policies
CREATE POLICY "users_own_profile" ON public.user_profiles FOR ALL
USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "public_can_read_categories" ON public.categories FOR SELECT
TO public USING (is_active = true);

CREATE POLICY "admins_manage_categories" ON public.categories FOR ALL
TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "public_can_read_active_listings" ON public.listings FOR SELECT
TO public USING (status = 'active'::public.listing_status);

CREATE POLICY "sellers_manage_own_listings" ON public.listings FOR ALL
TO authenticated USING (public.is_listing_owner(id)) WITH CHECK (public.is_listing_owner(id));

CREATE POLICY "users_manage_own_favorites" ON public.favorites FOR ALL
TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "participants_access_conversations" ON public.conversations FOR ALL
TO authenticated USING (public.can_access_conversation(id)) WITH CHECK (public.can_access_conversation(id));

CREATE POLICY "participants_access_messages" ON public.messages FOR ALL
TO authenticated USING (
    EXISTS (
        SELECT 1 FROM public.conversations c
        WHERE c.id = conversation_id AND public.can_access_conversation(c.id)
    )
);

CREATE POLICY "users_access_own_transactions" ON public.transactions FOR ALL
TO authenticated USING (public.can_access_transaction(id)) WITH CHECK (public.can_access_transaction(id));

CREATE POLICY "public_can_read_achievements" ON public.achievements FOR SELECT
TO public USING (is_active = true);

CREATE POLICY "users_view_own_achievements" ON public.user_achievements FOR SELECT
TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "public_can_read_reviews" ON public.reviews FOR SELECT
TO public USING (true);

CREATE POLICY "users_create_reviews" ON public.reviews FOR INSERT
TO authenticated WITH CHECK (auth.uid() = reviewer_id);

-- 7. Sample Data for Testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    seller_uuid UUID := gen_random_uuid();
    buyer_uuid UUID := gen_random_uuid();
    electronics_cat_id UUID := gen_random_uuid();
    clothing_cat_id UUID := gen_random_uuid();
    listing1_id UUID := gen_random_uuid();
    listing2_id UUID := gen_random_uuid();
    achievement1_id UUID := gen_random_uuid();
    achievement2_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@promohub.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (seller_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'seller@promohub.com', crypt('seller123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Seller", "role": "seller"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (buyer_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'buyer@promohub.com', crypt('buyer123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Jane Buyer", "role": "buyer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert categories
    INSERT INTO public.categories (id, name, description, icon_url) VALUES
        (electronics_cat_id, 'Electronics', 'Phones, computers, and gadgets', 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=100'),
        (clothing_cat_id, 'Clothing', 'Fashion and apparel', 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=100');

    -- Insert sample listings
    INSERT INTO public.listings (id, seller_id, category_id, title, description, price, condition, images) VALUES
        (listing1_id, seller_uuid, electronics_cat_id, 'iPhone 14 Pro Max', 'Excellent condition iPhone 14 Pro Max, 256GB, Space Black. Includes original box and charger.', 899.99, 'like_new'::public.listing_condition, 
         ARRAY['https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400']),
        (listing2_id, seller_uuid, clothing_cat_id, 'Designer Leather Jacket', 'Authentic leather jacket from premium brand. Size Medium. Perfect for winter.', 299.99, 'good'::public.listing_condition,
         ARRAY['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400', 'https://images.unsplash.com/photo-1594633313593-bab3825d0caf?w=400']);

    -- Insert achievements
    INSERT INTO public.achievements (id, name, description, icon_url, points, criteria) VALUES
        (achievement1_id, 'First Sale', 'Complete your first successful sale', 'https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?w=100', 100, '{"type": "sales_count", "target": 1}'::jsonb),
        (achievement2_id, 'Power Seller', 'Complete 10 successful sales', 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=100', 500, '{"type": "sales_count", "target": 10}'::jsonb);

    -- Add a favorite
    INSERT INTO public.favorites (user_id, listing_id) VALUES
        (buyer_uuid, listing1_id);

    -- Create a conversation
    INSERT INTO public.conversations (listing_id, buyer_id, seller_id, last_message) VALUES
        (listing1_id, buyer_uuid, seller_uuid, 'Is this still available?');

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Sample data insertion failed: %', SQLERRM;
END $$;