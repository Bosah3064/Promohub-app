import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

serve(async (req) => {
    // Handle CORS preflight request
    if (req.method === 'OPTIONS') {
        return new Response('ok', {
            headers: corsHeaders
        });
    }

    try {
        // Create a Supabase client
        const supabaseUrl = Deno.env.get('https://fqbuptggiugkhztnpxjg.supabase.co');
        const supabaseKey = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxYnVwdGdnaXVna2h6dG5weGpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3NzY3ODcsImV4cCI6MjA2OTM1Mjc4N30.PaATjQmVQCcSFJ6bJ4ILGI1g-oD7i3OHC_-Fcm8jtYQ');
        const supabase = createClient(supabaseUrl, supabaseKey);

        // Create a Stripe client
        const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
        const stripe = new Stripe(stripeKey);

        // Get the request body
        const { amount, currency, listingId, buyerId, sellerId, description } = await req.json();

        // Validate required fields
        if (!amount || !currency || !listingId || !buyerId || !sellerId) {
            throw new Error('Missing required fields');
        }

        // Create a Stripe checkout session for marketplace payment
        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [
                {
                    price_data: {
                        currency: currency.toLowerCase(),
                        product_data: {
                            name: description || 'Marketplace Purchase',
                        },
                        unit_amount: Math.round(amount * 100), // Convert to cents
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: `${req.headers.get('origin')}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${req.headers.get('origin')}/listing/${listingId}`,
            metadata: {
                listing_id: listingId,
                buyer_id: buyerId,
                seller_id: sellerId,
            },
        });

        // Create transaction record in database
        const { data: transaction, error: transactionError } = await supabase
            .from('transactions')
            .insert({
                listing_id: listingId,
                buyer_id: buyerId,
                seller_id: sellerId,
                amount: amount,
                stripe_payment_intent_id: session.id,
                payment_status: 'pending',
                transaction_type: 'purchase',
                processing_fee: amount * 0.03, // 3% processing fee
            })
            .select()
            .single();

        if (transactionError) {
            throw new Error(`Transaction creation failed: ${transactionError.message}`);
        }

        // Return the Stripe checkout session
        return new Response(JSON.stringify({
            sessionId: session.id,
            sessionUrl: session.url,
            transactionId: transaction.id
        }), {
            headers: {
                ...corsHeaders,
                'Content-Type': 'application/json'
            },
            status: 200
        });

    } catch (error) {
        return new Response(JSON.stringify({
            error: error.message
        }), {
            headers: {
                ...corsHeaders,
                'Content-Type': 'application/json'
            },
            status: 400
        });
    }
});