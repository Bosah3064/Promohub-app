/**
 * PromoHub Firebase Cloud Functions
 *
 * Handles:
 * - M-Pesa STK Push (Daraja API) payments
 * - Stripe payment intents
 * - Order status triggers
 * - Subscription management
 * - Scheduled cleanup tasks
 */

import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import axios from "axios";
import Stripe from "stripe";

admin.initializeApp();
const db = admin.firestore();

// =============================================================
// CONFIG - Load from Firebase Functions Config
// =============================================================
const mpesaConfig = {
  consumerKey: functions.config().mpesa?.consumer_key || "",
  consumerSecret: functions.config().mpesa?.consumer_secret || "",
  shortcode: functions.config().mpesa?.shortcode || "",
  passkey: functions.config().mpesa?.passkey || "",
  environment: functions.config().mpesa?.environment || "sandbox",
  callbackUrl: functions.config().mpesa?.callback_url || "",
};

const stripeConfig = {
  secretKey: functions.config().stripe?.secret_key || "",
};

// =============================================================
// M-PESA STK PUSH (DARAJA API)
// =============================================================

/**
 * Get M-Pesa OAuth token from Daraja API
 */
async function getMpesaToken(): Promise<string> {
  const baseUrl = mpesaConfig.environment === "sandbox"
    ? "https://sandbox.safaricom.co.ke"
    : "https://api.safaricom.co.ke";

  const auth = Buffer.from(
    `${mpesaConfig.consumerKey}:${mpesaConfig.consumerSecret}`
  ).toString("base64");

  const response = await axios.get(
    `${baseUrl}/oauth/v1/generate?grant_type=client_credentials`,
    {headers: {Authorization: `Basic ${auth}`}}
  );

  return response.data.access_token;
}

/**
 * Callable: Initiate M-Pesa STK Push
 * Called from Flutter via: FirebaseFunctions.instance.httpsCallable('mpesaStkPush')
 */
export const mpesaStkPush = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to initiate payment"
    );
  }

  const {phone_number, amount, transaction_id, account_reference} = data;

  if (!phone_number || !amount || !transaction_id) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields: phone_number, amount, transaction_id"
    );
  }

  const baseUrl = mpesaConfig.environment === "sandbox"
    ? "https://sandbox.safaricom.co.ke"
    : "https://api.safaricom.co.ke";

  try {
    const token = await getMpesaToken();
    const timestamp = new Date().toISOString()
      .replace(/[-T:Z.]/g, "").slice(0, 14);
    const password = Buffer.from(
      `${mpesaConfig.shortcode}${mpesaConfig.passkey}${timestamp}`
    ).toString("base64");

    const response = await axios.post(
      `${baseUrl}/mpesa/stkpush/v1/processrequest`,
      {
        BusinessShortCode: mpesaConfig.shortcode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: Math.ceil(amount),
        PartyA: phone_number,
        PartyB: mpesaConfig.shortcode,
        PhoneNumber: phone_number,
        CallBackURL: mpesaConfig.callbackUrl ||
          `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/mpesaCallback`,
        AccountReference: account_reference || "PromoHub",
        TransactionDesc: `Payment for order ${transaction_id}`,
      },
      {
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      }
    );

    // Store the checkout request ID for callback matching
    await db.collection("transactions").doc(transaction_id).update({
      "mpesa_checkout_request_id": response.data.CheckoutRequestID,
      "mpesa_merchant_request_id": response.data.MerchantRequestID,
      "payment_status": "stk_pushed",
      "updated_at": admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      checkoutRequestId: response.data.CheckoutRequestID,
      merchantRequestId: response.data.MerchantRequestID,
      responseDescription: response.data.ResponseDescription,
    };
  } catch (error: any) {
    functions.logger.error("M-Pesa STK Push failed:", error);

    await db.collection("transactions").doc(transaction_id).update({
      "payment_status": "failed",
      "error_message": error.message || "STK Push failed",
      "updated_at": admin.firestore.FieldValue.serverTimestamp(),
    });

    throw new functions.https.HttpsError(
      "internal",
      `M-Pesa STK Push failed: ${error.message}`
    );
  }
});

/**
 * HTTP Endpoint: M-Pesa callback from Daraja API
 * Safaricom sends payment confirmation here
 */
export const mpesaCallback = functions.https.onRequest(async (req, res) => {
  const body = req.body;

  if (!body?.Body?.stkCallback) {
    res.status(400).json({error: "Invalid callback payload"});
    return;
  }

  const callback = body.Body.stkCallback;
  const resultCode = callback.ResultCode;
  const checkoutRequestId = callback.CheckoutRequestID;

  functions.logger.info("M-Pesa Callback received:", {
    resultCode,
    checkoutRequestId,
  });

  try {
    // Find the transaction by checkout request ID
    const txnSnap = await db.collection("transactions")
      .where("mpesa_checkout_request_id", "==", checkoutRequestId)
      .limit(1)
      .get();

    if (txnSnap.empty) {
      functions.logger.warn("No transaction found for checkout:", checkoutRequestId);
      res.status(200).json({ResultCode: 0, ResultDesc: "Accepted"});
      return;
    }

    const txnDoc = txnSnap.docs[0];

    if (resultCode === 0) {
      // Payment successful — extract M-Pesa metadata
      const metadata: Record<string, any> = {};
      if (callback.CallbackMetadata?.Item) {
        for (const item of callback.CallbackMetadata.Item) {
          metadata[item.Name] = item.Value;
        }
      }

      await txnDoc.ref.update({
        "payment_status": "completed",
        "mpesa_receipt_number": metadata.MpesaReceiptNumber || null,
        "mpesa_transaction_date": metadata.TransactionDate || null,
        "mpesa_phone_number": metadata.PhoneNumber || null,
        "updated_at": admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update the order status to 'processing'
      const txnData = txnDoc.data();
      if (txnData.order_id) {
        await db.collection("orders").doc(txnData.order_id).update({
          "status": "processing",
          "payment_status": "paid",
          "updated_at": admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      functions.logger.info("M-Pesa payment completed:", metadata.MpesaReceiptNumber);
    } else {
      // Payment failed
      await txnDoc.ref.update({
        "payment_status": "failed",
        "error_message": callback.ResultDesc || "Payment failed",
        "updated_at": admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.warn("M-Pesa payment failed:", callback.ResultDesc);
    }

    res.status(200).json({ResultCode: 0, ResultDesc: "Accepted"});
  } catch (error: any) {
    functions.logger.error("M-Pesa callback processing error:", error);
    res.status(200).json({ResultCode: 0, ResultDesc: "Accepted"});
  }
});

/**
 * Callable: Check M-Pesa transaction status
 */
export const checkMpesaStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required");
  }

  const {transaction_id} = data;
  const doc = await db.collection("transactions").doc(transaction_id).get();

  if (!doc.exists) {
    throw new functions.https.HttpsError("not-found", "Transaction not found");
  }

  const txnData = doc.data()!;
  return {
    status: txnData.payment_status,
    receipt: txnData.mpesa_receipt_number || null,
  };
});


// =============================================================
// STRIPE PAYMENTS
// =============================================================

/**
 * Callable: Create a Stripe PaymentIntent
 */
export const createStripePaymentIntent = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    const {amount, currency, order_id, description} = data;

    if (!amount || !currency || !order_id) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields"
      );
    }

    const stripe = new Stripe(stripeConfig.secretKey, {
      apiVersion: "2023-10-16",
    });

    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Stripe uses smallest currency unit
        currency: currency.toLowerCase(),
        metadata: {
          order_id,
          user_id: context.auth.uid,
        },
        description: description || `PromoHub order: ${order_id}`,
      });

      // Record transaction
      await db.collection("transactions").add({
        order_id,
        buyer_id: context.auth.uid,
        amount,
        payment_method: "stripe",
        payment_status: "pending",
        stripe_payment_intent_id: paymentIntent.id,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      };
    } catch (error: any) {
      functions.logger.error("Stripe PaymentIntent creation failed:", error);
      throw new functions.https.HttpsError(
        "internal",
        `Stripe error: ${error.message}`
      );
    }
  }
);


// =============================================================
// FIRESTORE TRIGGERS
// =============================================================

/**
 * Trigger: When an order status changes, send notification to buyer/seller
 */
export const onOrderStatusChange = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return null;

    const orderId = context.params.orderId;
    functions.logger.info(
      `Order ${orderId} status changed: ${before.status} → ${after.status}`
    );

    // Create a notification for the buyer
    if (after.buyer_id) {
      await db.collection("notifications").add({
        user_id: after.buyer_id,
        title: "Order Update",
        body: `Your order #${orderId.slice(0, 8)} is now ${after.status.replace(/_/g, " ")}`,
        type: "order_update",
        order_id: orderId,
        read: false,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // If delivered, prompt buyer to leave a review
    if (after.status === "delivered" && after.buyer_id) {
      await db.collection("notifications").add({
        user_id: after.buyer_id,
        title: "Leave a Review",
        body: "Your order has been delivered! Please leave a review for the seller.",
        type: "review_prompt",
        order_id: orderId,
        read: false,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return null;
  });

/**
 * Trigger: When a new listing is created, increment the shop's listing count
 */
export const onListingCreated = functions.firestore
  .document("listings/{listingId}")
  .onCreate(async (snap, context) => {
    const listing = snap.data();
    const shopId = listing.shop_id;

    if (shopId) {
      await db.collection("shops").doc(shopId).update({
        total_listings: admin.firestore.FieldValue.increment(1),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    return null;
  });

/**
 * Trigger: When a listing is deleted, decrement the shop's listing count
 */
export const onListingDeleted = functions.firestore
  .document("listings/{listingId}")
  .onDelete(async (snap, context) => {
    const listing = snap.data();
    const shopId = listing.shop_id;

    if (shopId) {
      await db.collection("shops").doc(shopId).update({
        total_listings: admin.firestore.FieldValue.increment(-1),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    return null;
  });


// =============================================================
// SCHEDULED FUNCTIONS
// =============================================================

/**
 * Scheduled: Check for expired subscriptions every hour
 */
export const checkExpiredSubscriptions = functions.pubsub
  .schedule("every 1 hours")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const expiredSubs = await db.collection("subscriptions")
      .where("status", "==", "active")
      .where("end_date", "<=", now)
      .get();

    const batch = db.batch();
    let count = 0;

    for (const doc of expiredSubs.docs) {
      batch.update(doc.ref, {
        status: "expired",
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Downgrade the shop to free tier
      const sub = doc.data();
      if (sub.shop_id) {
        const shopRef = db.collection("shops").doc(sub.shop_id);
        batch.update(shopRef, {
          subscription_tier: "free",
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      count++;
    }

    if (count > 0) {
      await batch.commit();
      functions.logger.info(`Expired ${count} subscriptions`);
    }

    return null;
  });

/**
 * Scheduled: Unfeature expired featured listings every 6 hours
 */
export const unfeatureExpiredListings = functions.pubsub
  .schedule("every 6 hours")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const expiredFeatured = await db.collection("sponsored_listings")
      .where("status", "==", "active")
      .where("end_date", "<=", now)
      .get();

    const batch = db.batch();
    let count = 0;

    for (const doc of expiredFeatured.docs) {
      batch.update(doc.ref, {
        status: "expired",
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Remove featured flag from the listing
      const ad = doc.data();
      if (ad.listing_id) {
        const listingRef = db.collection("listings").doc(ad.listing_id);
        batch.update(listingRef, {
          is_featured: false,
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      count++;
    }

    if (count > 0) {
      await batch.commit();
      functions.logger.info(`Unfeatured ${count} expired listings`);
    }

    return null;
  });

/**
 * Scheduled: Clean up stale pending transactions older than 24 hours
 */
export const cleanupStaleTransactions = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    const cutoff = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 24 * 60 * 60 * 1000)
    );

    const staleTxns = await db.collection("transactions")
      .where("payment_status", "==", "pending")
      .where("created_at", "<=", cutoff)
      .get();

    const batch = db.batch();
    let count = 0;

    for (const doc of staleTxns.docs) {
      batch.update(doc.ref, {
        payment_status: "expired",
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      count++;
    }

    if (count > 0) {
      await batch.commit();
      functions.logger.info(`Cleaned up ${count} stale transactions`);
    }

    return null;
  });
