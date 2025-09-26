# 📱 PromoHub App

PromoHub is a Flutter-based mobile marketplace app where users can buy, sell, and promote items.  
Think of it as **Jiji + Extra Features** 🚀

## ✨ Features
- 🔑 User Authentication (email, phone, social)
- 👤 User Profiles with ratings & verification
- 📦 Post Ads: title, description, price, category, images/videos
- 🗂 Categories: Vehicles, Real Estate, Electronics, Jobs, Services, Fashion, Others
- 🔍 Search & Filters (price, location, category, etc.)
- 📍 Location-aware listings (global support with currencies)
- 💬 In-app Messaging & Calls
- ❤️ Favorites & Saved Searches
- 💳 Subscriptions & Payments (Stripe now, Pesapal coming)
- 🛡 Safety features: report users/ads, verified badges
- 👨‍💻 Admin panel (manage users, categories, reports)

## 💰 Subscription Plans
- **Free** — 7 listings, basic visibility
- **Standard (2,500 KSH)** — 30 listings, featured badge, analytics
- **Premium (7,500 KSH)** — unlimited listings, AI-powered tools, top search priority

## 🛠 Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Postgres + Auth)
- **Payments**: Stripe (future Pesapal integration)
- **Other**: Realtime DB, Edge Functions, Geo-location services

## 🚀 Getting Started
1. Clone repo:
   git clone https://github.com/Bosah3064/Promohub-app.git
   cd Promohub-app

2. Install dependencies:
   flutter pub get

3. Create .env from .env.example:
   SUPABASE_URL=your-url
   SUPABASE_ANON_KEY=your-key
   STRIPE_SECRET=your-stripe-secret

4. Run the app:
   flutter run

## 🤝 Contributing
See CONTRIBUTING.md

