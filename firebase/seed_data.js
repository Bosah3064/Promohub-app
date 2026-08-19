/**
 * PromoHub Firestore Seed Data Script
 * 
 * Populates all Firestore collections with initial reference data.
 * Replaces all SQL migration seed data.
 * 
 * Usage:
 *   1. Install Firebase Admin SDK: npm install firebase-admin
 *   2. Download service account key from Firebase Console → Project Settings → Service Accounts
 *   3. Set environment variable: GOOGLE_APPLICATION_CREDENTIALS=path/to/serviceAccountKey.json
 *   4. Run: node seed_data.js
 */

const admin = require('firebase-admin');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = getFirestore();
const auth = getAuth();

// ============================================================
// HELPER: Generate a random ID (like PostgreSQL UUID)
// ============================================================
function generateId() {
  return db.collection('_').doc().id;
}

// ============================================================
// SEED ALL COLLECTIONS
// ============================================================
async function seedAll() {
  console.log('🚀 Starting Firestore seed data population...\n');

  try {
    // 1. Currencies
    await seedCurrencies();

    // 2. Locations
    await seedLocations();

    // 3. Categories
    await seedCategories();

    // 4. Subscription Tiers
    await seedSubscriptionTiers();

    // 5. Category Commissions
    await seedCategoryCommissions();

    // 6. Achievements
    await seedAchievements();

    // 7. Pickup Stations
    await seedPickupStations();

    // 8. Sample Users, Shops, and Listings (for development)
    await seedSampleData();

    console.log('\n✅ All seed data populated successfully!');
  } catch (error) {
    console.error('❌ Seed data failed:', error);
    process.exit(1);
  }
}

// ============================================================
// 1. CURRENCIES
// ============================================================
async function seedCurrencies() {
  console.log('💰 Seeding currencies...');
  const batch = db.batch();

  const currencies = [
    { code: 'USD', name: 'US Dollar', symbol: '$', exchange_rate: 1.00, is_base: true, status: 'active' },
    { code: 'EUR', name: 'Euro', symbol: '€', exchange_rate: 0.85, is_base: false, status: 'active' },
    { code: 'GBP', name: 'British Pound', symbol: '£', exchange_rate: 0.73, is_base: false, status: 'active' },
    { code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', exchange_rate: 153.50, is_base: false, status: 'active' },
    { code: 'NGN', name: 'Nigerian Naira', symbol: '₦', exchange_rate: 775.00, is_base: false, status: 'active' },
    { code: 'ZAR', name: 'South African Rand', symbol: 'R', exchange_rate: 18.50, is_base: false, status: 'active' },
    { code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵', exchange_rate: 12.50, is_base: false, status: 'active' },
    { code: 'TZS', name: 'Tanzanian Shilling', symbol: 'TSh', exchange_rate: 2500.00, is_base: false, status: 'active' },
    { code: 'UGX', name: 'Ugandan Shilling', symbol: 'USh', exchange_rate: 3750.00, is_base: false, status: 'active' },
    { code: 'INR', name: 'Indian Rupee', symbol: '₹', exchange_rate: 83.00, is_base: false, status: 'active' },
  ];

  for (const currency of currencies) {
    const ref = db.collection('currencies').doc();
    batch.set(ref, {
      ...currency,
      created_at: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  console.log(`  ✓ ${currencies.length} currencies created`);
}

// ============================================================
// 2. LOCATIONS
// ============================================================
async function seedLocations() {
  console.log('📍 Seeding locations...');
  const batch = db.batch();

  const locations = [
    // Kenya
    { country_code: 'KE', country_name: 'Kenya', state_code: 'NBI', state_name: 'Nairobi', city_name: 'Nairobi', timezone: 'Africa/Nairobi', status: 'active' },
    { country_code: 'KE', country_name: 'Kenya', state_code: 'MSA', state_name: 'Coast', city_name: 'Mombasa', timezone: 'Africa/Nairobi', status: 'active' },
    { country_code: 'KE', country_name: 'Kenya', state_code: 'KSM', state_name: 'Kisumu', city_name: 'Kisumu', timezone: 'Africa/Nairobi', status: 'active' },
    { country_code: 'KE', country_name: 'Kenya', state_code: 'NKR', state_name: 'Nakuru', city_name: 'Nakuru', timezone: 'Africa/Nairobi', status: 'active' },
    { country_code: 'KE', country_name: 'Kenya', state_code: 'ELD', state_name: 'Uasin Gishu', city_name: 'Eldoret', timezone: 'Africa/Nairobi', status: 'active' },
    // Nigeria
    { country_code: 'NG', country_name: 'Nigeria', state_code: 'LA', state_name: 'Lagos', city_name: 'Lagos', timezone: 'Africa/Lagos', status: 'active' },
    { country_code: 'NG', country_name: 'Nigeria', state_code: 'AB', state_name: 'Abuja', city_name: 'Abuja', timezone: 'Africa/Lagos', status: 'active' },
    { country_code: 'NG', country_name: 'Nigeria', state_code: 'KN', state_name: 'Kano', city_name: 'Kano', timezone: 'Africa/Lagos', status: 'active' },
    // South Africa
    { country_code: 'ZA', country_name: 'South Africa', state_code: 'GT', state_name: 'Gauteng', city_name: 'Johannesburg', timezone: 'Africa/Johannesburg', status: 'active' },
    { country_code: 'ZA', country_name: 'South Africa', state_code: 'WC', state_name: 'Western Cape', city_name: 'Cape Town', timezone: 'Africa/Johannesburg', status: 'active' },
    // Ghana
    { country_code: 'GH', country_name: 'Ghana', state_code: 'AA', state_name: 'Greater Accra', city_name: 'Accra', timezone: 'Africa/Accra', status: 'active' },
    // Tanzania
    { country_code: 'TZ', country_name: 'Tanzania', state_code: 'DS', state_name: 'Dar es Salaam', city_name: 'Dar es Salaam', timezone: 'Africa/Dar_es_Salaam', status: 'active' },
    // Uganda
    { country_code: 'UG', country_name: 'Uganda', state_code: 'KP', state_name: 'Kampala', city_name: 'Kampala', timezone: 'Africa/Kampala', status: 'active' },
    // United States
    { country_code: 'US', country_name: 'United States', state_code: 'NY', state_name: 'New York', city_name: 'New York City', timezone: 'America/New_York', status: 'active' },
    { country_code: 'US', country_name: 'United States', state_code: 'CA', state_name: 'California', city_name: 'Los Angeles', timezone: 'America/Los_Angeles', status: 'active' },
    // United Kingdom
    { country_code: 'GB', country_name: 'United Kingdom', state_code: 'ENG', state_name: 'England', city_name: 'London', timezone: 'Europe/London', status: 'active' },
    // Germany
    { country_code: 'DE', country_name: 'Germany', state_code: 'BE', state_name: 'Berlin', city_name: 'Berlin', timezone: 'Europe/Berlin', status: 'active' },
  ];

  for (const location of locations) {
    const ref = db.collection('locations').doc();
    batch.set(ref, {
      ...location,
      latitude: null,
      longitude: null,
      postal_code: null,
      created_at: FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  console.log(`  ✓ ${locations.length} locations created`);
}

// ============================================================
// 3. CATEGORIES
// ============================================================
async function seedCategories() {
  console.log('📦 Seeding categories...');
  const batch = db.batch();

  const categories = [
    { name: 'Electronics', description: 'Phones, computers, and gadgets', icon_url: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=100', commission_rate: 8.00, is_active: true },
    { name: 'Phones & Tablets', description: 'Mobile phones and tablets', icon_url: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=100', commission_rate: 6.00, is_active: true },
    { name: 'Fashion', description: 'Clothing, shoes, and accessories', icon_url: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=100', commission_rate: 12.00, is_active: true },
    { name: 'Beauty', description: 'Skincare, makeup, and fragrances', icon_url: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=100', commission_rate: 15.00, is_active: true },
    { name: 'Home & Garden', description: 'Furniture, decor, and garden', icon_url: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=100', commission_rate: 10.00, is_active: true },
    { name: 'Furniture', description: 'Tables, chairs, sofas, and beds', icon_url: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=100', commission_rate: 10.00, is_active: true },
    { name: 'Vehicles', description: 'Cars, motorcycles, and auto parts', icon_url: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=100', commission_rate: 5.00, is_active: true },
    { name: 'Sports & Fitness', description: 'Equipment and sportswear', icon_url: 'https://images.unsplash.com/photo-1461896836934-bd45ba7b2f36?w=100', commission_rate: 8.00, is_active: true },
    { name: 'Books & Media', description: 'Books, music, and movies', icon_url: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=100', commission_rate: 10.00, is_active: true },
    { name: 'Health', description: 'Health products and supplements', icon_url: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=100', commission_rate: 12.00, is_active: true },
    { name: 'Baby & Kids', description: 'Toys, clothing, and baby gear', icon_url: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=100', commission_rate: 10.00, is_active: true },
    { name: 'Food & Beverages', description: 'Groceries and beverages', icon_url: 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=100', commission_rate: 8.00, is_active: true },
  ];

  const categoryIds = {};
  for (const category of categories) {
    const ref = db.collection('categories').doc();
    batch.set(ref, {
      ...category,
      parent_id: null,
      created_at: FieldValue.serverTimestamp(),
    });
    categoryIds[category.name] = ref.id;
  }

  await batch.commit();
  console.log(`  ✓ ${categories.length} categories created`);
  return categoryIds;
}

// ============================================================
// 4. SUBSCRIPTION TIERS
// ============================================================
async function seedSubscriptionTiers() {
  console.log('💎 Seeding subscription tiers...');
  
  // Get USD currency ID
  const currencySnapshot = await db.collection('currencies').where('code', '==', 'USD').limit(1).get();
  const usdId = currencySnapshot.empty ? null : currencySnapshot.docs[0].id;

  const batch = db.batch();

  const tiers = [
    {
      name: 'Basic',
      description: 'Perfect for casual sellers',
      price: 0.00,
      currency_id: usdId,
      billing_cycle: 'monthly',
      features: ['Up to 5 active listings', 'Basic messaging', 'Standard support'],
      max_listings: 5,
      priority_support: false,
      featured_listings: false,
      analytics_access: false,
      is_popular: false,
      is_active: true,
    },
    {
      name: 'Premium',
      description: 'Great for regular sellers',
      price: 9.99,
      currency_id: usdId,
      billing_cycle: 'monthly',
      features: ['Up to 25 active listings', 'Priority messaging', 'Featured listings', 'Basic analytics', 'Priority support'],
      max_listings: 25,
      priority_support: true,
      featured_listings: true,
      analytics_access: true,
      is_popular: true,
      is_active: true,
    },
    {
      name: 'Professional',
      description: 'For power sellers',
      price: 29.99,
      currency_id: usdId,
      billing_cycle: 'monthly',
      features: ['Unlimited listings', 'Advanced messaging', 'Premium placement', 'Advanced analytics', 'Dedicated support', 'Bulk tools'],
      max_listings: -1,
      priority_support: true,
      featured_listings: true,
      analytics_access: true,
      is_popular: false,
      is_active: true,
    },
  ];

  for (const tier of tiers) {
    const ref = db.collection('subscription_tiers').doc();
    batch.set(ref, {
      ...tier,
      created_at: FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  console.log(`  ✓ ${tiers.length} subscription tiers created`);
}

// ============================================================
// 5. CATEGORY COMMISSIONS
// ============================================================
async function seedCategoryCommissions() {
  console.log('📊 Seeding category commissions...');
  
  const categoriesSnapshot = await db.collection('categories').get();
  const batch = db.batch();
  let count = 0;

  for (const categoryDoc of categoriesSnapshot.docs) {
    const categoryData = categoryDoc.data();
    const ref = db.collection('category_commissions').doc();
    batch.set(ref, {
      category_id: categoryDoc.id,
      category_name: categoryData.name,
      commission_rate: categoryData.commission_rate || 8.00,
      updated_at: FieldValue.serverTimestamp(),
      updated_by: null,
    });
    count++;
  }

  await batch.commit();
  console.log(`  ✓ ${count} category commissions created`);
}

// ============================================================
// 6. ACHIEVEMENTS
// ============================================================
async function seedAchievements() {
  console.log('🏆 Seeding achievements...');
  const batch = db.batch();

  const achievements = [
    { name: 'First Sale', description: 'Complete your first successful sale', icon_url: 'https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?w=100', points: 100, badge_color: '#4CAF50', criteria: { type: 'sales_count', target: 1 }, is_active: true },
    { name: 'Power Seller', description: 'Complete 10 successful sales', icon_url: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=100', points: 500, badge_color: '#FF9800', criteria: { type: 'sales_count', target: 10 }, is_active: true },
    { name: 'Top Rated', description: 'Achieve a 4.5+ star rating', icon_url: null, points: 300, badge_color: '#FFD700', criteria: { type: 'rating', target: 4.5 }, is_active: true },
    { name: 'Verified Seller', description: 'Complete identity verification', icon_url: null, points: 200, badge_color: '#2196F3', criteria: { type: 'verification', target: 1 }, is_active: true },
    { name: 'Super Seller', description: 'Complete 50 successful sales', icon_url: null, points: 1000, badge_color: '#9C27B0', criteria: { type: 'sales_count', target: 50 }, is_active: true },
    { name: 'First Purchase', description: 'Make your first purchase', icon_url: null, points: 50, badge_color: '#00BCD4', criteria: { type: 'purchase_count', target: 1 }, is_active: true },
    { name: 'Community Contributor', description: 'Leave 5 helpful reviews', icon_url: null, points: 150, badge_color: '#E91E63', criteria: { type: 'review_count', target: 5 }, is_active: true },
  ];

  for (const achievement of achievements) {
    const ref = db.collection('achievements').doc();
    batch.set(ref, {
      ...achievement,
      created_at: FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  console.log(`  ✓ ${achievements.length} achievements created`);
}

// ============================================================
// 7. PICKUP STATIONS
// ============================================================
async function seedPickupStations() {
  console.log('🏪 Seeding pickup stations...');
  const batch = db.batch();

  const stations = [
    { name: 'PromoHub Westlands Hub', address: 'Westlands Road, Sarit Centre', city: 'Nairobi', county: 'Nairobi', latitude: -1.2635, longitude: 36.8049, operating_hours: '8AM - 8PM Mon-Sat', phone: '+254700000001', is_active: true },
    { name: 'PromoHub CBD Pickup', address: 'Kenyatta Avenue, Kencom House', city: 'Nairobi', county: 'Nairobi', latitude: -1.2864, longitude: 36.8172, operating_hours: '8AM - 6PM Mon-Fri', phone: '+254700000002', is_active: true },
    { name: 'PromoHub Mombasa Hub', address: 'Nyali Road, City Mall', city: 'Mombasa', county: 'Mombasa', latitude: -4.0435, longitude: 39.6682, operating_hours: '9AM - 7PM Mon-Sat', phone: '+254700000003', is_active: true },
    { name: 'PromoHub Kisumu Hub', address: 'Oginga Odinga Street', city: 'Kisumu', county: 'Kisumu', latitude: -0.0917, longitude: 34.7680, operating_hours: '9AM - 6PM Mon-Sat', phone: '+254700000004', is_active: true },
  ];

  for (const station of stations) {
    const ref = db.collection('pickup_stations').doc();
    batch.set(ref, {
      ...station,
      created_at: FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  console.log(`  ✓ ${stations.length} pickup stations created`);
}

// ============================================================
// 8. SAMPLE DATA (Development only)
// ============================================================
async function seedSampleData() {
  console.log('👤 Seeding sample users and listings...');

  // Create sample auth users
  let adminUser, sellerUser, buyerUser;
  
  try {
    adminUser = await auth.createUser({
      email: 'admin@promohub.com',
      password: 'admin123',
      displayName: 'Admin User',
    });
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      adminUser = await auth.getUserByEmail('admin@promohub.com');
    } else throw e;
  }

  try {
    sellerUser = await auth.createUser({
      email: 'seller@promohub.com',
      password: 'seller123',
      displayName: 'John Seller',
    });
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      sellerUser = await auth.getUserByEmail('seller@promohub.com');
    } else throw e;
  }

  try {
    buyerUser = await auth.createUser({
      email: 'buyer@promohub.com',
      password: 'buyer123',
      displayName: 'Jane Buyer',
    });
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      buyerUser = await auth.getUserByEmail('buyer@promohub.com');
    } else throw e;
  }

  // Create user profiles
  const batch = db.batch();

  batch.set(db.collection('user_profiles').doc(adminUser.uid), {
    email: 'admin@promohub.com',
    full_name: 'Admin User',
    avatar_url: null,
    phone: null,
    location: 'Nairobi, Kenya',
    role: 'admin',
    rating: 0.00,
    total_sales: 0,
    total_purchases: 0,
    verification_status: true,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  });

  batch.set(db.collection('user_profiles').doc(sellerUser.uid), {
    email: 'seller@promohub.com',
    full_name: 'John Seller',
    avatar_url: null,
    phone: '+254712345678',
    location: 'Nairobi, Kenya',
    role: 'seller',
    rating: 4.50,
    total_sales: 15,
    total_purchases: 2,
    verification_status: true,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  });

  batch.set(db.collection('user_profiles').doc(buyerUser.uid), {
    email: 'buyer@promohub.com',
    full_name: 'Jane Buyer',
    avatar_url: null,
    phone: '+254723456789',
    location: 'Mombasa, Kenya',
    role: 'buyer',
    rating: 0.00,
    total_sales: 0,
    total_purchases: 5,
    verification_status: false,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  });

  // Create a sample shop
  const shopRef = db.collection('shops').doc();
  batch.set(shopRef, {
    owner_id: sellerUser.uid,
    name: 'TechHub Kenya',
    slug: 'techhub-kenya',
    description: 'Your one-stop shop for electronics and gadgets in Nairobi',
    logo_url: null,
    banner_url: null,
    location: 'Nairobi, Kenya',
    status: 'verified',
    rating: 4.50,
    total_reviews: 8,
    total_orders: 20,
    completed_orders: 15,
    response_rate: 95.00,
    cancellation_rate: 2.00,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  });

  await batch.commit();

  // Get category IDs for listings
  const electronicsSnap = await db.collection('categories').where('name', '==', 'Electronics').limit(1).get();
  const fashionSnap = await db.collection('categories').where('name', '==', 'Fashion').limit(1).get();
  const phonesSnap = await db.collection('categories').where('name', '==', 'Phones & Tablets').limit(1).get();

  const electronicsId = electronicsSnap.empty ? null : electronicsSnap.docs[0].id;
  const fashionId = fashionSnap.empty ? null : fashionSnap.docs[0].id;
  const phonesId = phonesSnap.empty ? null : phonesSnap.docs[0].id;

  // Create sample listings
  const listingsBatch = db.batch();

  const listing1Ref = db.collection('listings').doc();
  listingsBatch.set(listing1Ref, {
    seller_id: sellerUser.uid,
    seller_name: 'John Seller',
    seller_avatar: null,
    shop_id: shopRef.id,
    shop_name: 'TechHub Kenya',
    category_id: phonesId || electronicsId,
    category_name: phonesId ? 'Phones & Tablets' : 'Electronics',
    title: 'iPhone 14 Pro Max',
    description: 'Excellent condition iPhone 14 Pro Max, 256GB, Space Black. Includes original box and charger.',
    price: 899.99,
    condition: 'like_new',
    status: 'active',
    location: 'Nairobi, Kenya',
    images: [
      'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
    ],
    tags: ['iphone', 'apple', 'smartphone', '256gb'],
    views_count: 142,
    favorites_count: 23,
    is_negotiable: true,
    featured: true,
    inventory_count: 3,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
    expires_at: Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)),
  });

  const listing2Ref = db.collection('listings').doc();
  listingsBatch.set(listing2Ref, {
    seller_id: sellerUser.uid,
    seller_name: 'John Seller',
    seller_avatar: null,
    shop_id: shopRef.id,
    shop_name: 'TechHub Kenya',
    category_id: fashionId,
    category_name: 'Fashion',
    title: 'Designer Leather Jacket',
    description: 'Authentic leather jacket from premium brand. Size Medium. Perfect for winter.',
    price: 299.99,
    condition: 'good',
    status: 'active',
    location: 'Nairobi, Kenya',
    images: [
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
      'https://images.unsplash.com/photo-1594633313593-bab3825d0caf?w=400',
    ],
    tags: ['leather', 'jacket', 'fashion', 'designer'],
    views_count: 67,
    favorites_count: 12,
    is_negotiable: true,
    featured: false,
    inventory_count: 1,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
    expires_at: Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)),
  });

  const listing3Ref = db.collection('listings').doc();
  listingsBatch.set(listing3Ref, {
    seller_id: sellerUser.uid,
    seller_name: 'John Seller',
    seller_avatar: null,
    shop_id: shopRef.id,
    shop_name: 'TechHub Kenya',
    category_id: electronicsId,
    category_name: 'Electronics',
    title: 'Samsung Galaxy S24 Ultra',
    description: 'Brand new Samsung Galaxy S24 Ultra, 512GB, Titanium Gray. Factory sealed with warranty.',
    price: 1199.99,
    condition: 'new',
    status: 'active',
    location: 'Nairobi, Kenya',
    images: [
      'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400',
    ],
    tags: ['samsung', 'galaxy', 's24', 'ultra', 'smartphone'],
    views_count: 89,
    favorites_count: 15,
    is_negotiable: false,
    featured: true,
    inventory_count: 5,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
    expires_at: Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)),
  });

  // Add a favorite
  const favRef = db.collection('favorites').doc();
  listingsBatch.set(favRef, {
    user_id: buyerUser.uid,
    listing_id: listing1Ref.id,
    created_at: FieldValue.serverTimestamp(),
  });

  // Create a conversation
  const convRef = db.collection('conversations').doc();
  listingsBatch.set(convRef, {
    listing_id: listing1Ref.id,
    buyer_id: buyerUser.uid,
    seller_id: sellerUser.uid,
    last_message: 'Is this still available?',
    last_message_at: FieldValue.serverTimestamp(),
    created_at: FieldValue.serverTimestamp(),
  });

  // Create a seller wallet
  const walletRef = db.collection('seller_wallets').doc();
  listingsBatch.set(walletRef, {
    seller_id: sellerUser.uid,
    shop_id: shopRef.id,
    available_balance: 15000.00,
    pending_balance: 3500.00,
    total_earned: 45000.00,
    total_paid_out: 26500.00,
    total_commission: 3600.00,
    total_refunded: 0.00,
    updated_at: FieldValue.serverTimestamp(),
  });

  await listingsBatch.commit();
  console.log('  ✓ Sample users, shop, listings, favorites, conversation, and wallet created');
}

// ============================================================
// RUN
// ============================================================
seedAll().then(() => {
  console.log('\n🎉 Seed complete! Your Firestore database is ready.');
  process.exit(0);
}).catch((error) => {
  console.error('\n💥 Fatal error:', error);
  process.exit(1);
});
