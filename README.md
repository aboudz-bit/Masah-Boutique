# بوتيك ماسـة | Masah Boutique

Luxury Fashion E-commerce App (Flutter + Express.js + PostgreSQL)

Instagram: [@masahboutique](https://www.instagram.com/masahboutique)

## Tech Stack

- **Mobile & Web App:** Flutter (Dart) - iOS, Android, Web
- **Backend API:** Express.js (TypeScript)
- **Database:** PostgreSQL with Drizzle ORM
- **Payment:** Abstraction layer ready for Moyasar/HyperPay/Tap integration
- **Shipping:** Abstraction layer ready for Aramex/SMSA/DHL integration

## Project Structure

```
├── masah_boutique/          # Flutter app (mobile + web)
│   ├── lib/
│   │   ├── models/          # Data models (Product, Cart, Order, Store)
│   │   ├── screens/         # UI screens (Home, Products, Cart, Checkout, Orders, Stores)
│   │   ├── services/        # API service, Cart provider, Locale provider
│   │   ├── widgets/         # Reusable widgets (ProductCard)
│   │   └── l10n/            # Arabic & English localization
│   └── web/                 # Web deployment files
├── server/                  # Express.js backend
│   ├── index.ts             # Server entry point
│   ├── routes.ts            # API routes
│   ├── storage.ts           # Database operations
│   ├── seed.ts              # Seed data for Masah Boutique
│   ├── payments.ts          # Payment abstraction layer
│   └── shipping.ts          # Shipping abstraction layer
└── shared/
    └── schema.ts            # Database schema (Drizzle ORM)
```

## Features

- Bilingual Arabic/English support (RTL)
- Product catalog with categories (Abayas, Jalabiyas, Dresses, Bridal, Kids, Gifts)
- Shopping cart with size/color selection
- Checkout with delivery or store pickup
- Discount codes
- Order tracking
- Store locator (Saihat, Qatif, Dammam)
- Instagram integration (@masahboutique)
- Dark theme with gold accent branding

## Getting Started

### Backend
```bash
npm install
# Set DATABASE_URL environment variable
npm run db:push   # Push schema to database
npm run dev       # Start development server
```

### Flutter App
```bash
cd masah_boutique
flutter pub get
flutter run             # Mobile
flutter run -d chrome   # Web
```

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| GET /api/products | List products (filter by category, search, featured) |
| GET /api/products/:id | Product details |
| GET/POST /api/cart | Cart operations |
| POST /api/orders | Create order |
| GET /api/orders | List orders |
| GET /api/stores | List stores |
| POST /api/discounts/validate | Validate discount code |
| POST /api/payments/session | Create payment |
| POST /api/shipping/quote | Get shipping quotes |
