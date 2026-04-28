# 💸 Splitify

> **Split smart. Settle fast.**

A full-stack bill-splitting app (like Splitwise) built with Flutter + GetX on the frontend and Node.js + Express + MongoDB on the backend. Splitify lets friend groups track shared expenses, visualise spending patterns, and settle debts in the fewest possible transactions using a greedy debt-simplification algorithm.

---

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart->=3.4.4-0175C2?logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-4.7.3-9C27B0)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/Platform-iOS-000000?logo=apple&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Railway-0B0D0E?logo=railway&logoColor=white)

---

## 📸 Screenshots

### Groups & Expense List

| Groups | Group Details |
|--------|---------------|
| <img src="https://github.com/user-attachments/assets/1730a03e-623d-45ee-8c72-81118af12fb7" width="220"/> | <img src="https://github.com/user-attachments/assets/65daf175-5584-4e09-8c61-7d847b901681" width="220"/> |

### Add Expense

| Add Expense |
|-------------|
| <img src="https://github.com/user-attachments/assets/52255a5c-ffae-4140-900f-e5ae8867e17d" width="220"/> |

### Charts

| Chart View 1 | Chart View 2 |
|--------------|--------------|
| <img src="https://github.com/user-attachments/assets/df6b61ee-c3d0-4370-96cb-26d02cc76380" width="220"/> | <img src="https://github.com/user-attachments/assets/88f90f17-8e19-4e4c-bada-3b039143c494" width="220"/> |

### Balances

| Balances |
|----------|
| <img src="https://github.com/user-attachments/assets/3f733030-9dab-4caa-a393-81a1461c0409" width="220"/> |

### Settlement Breakdown

| Step 1 | Step 2 | Step 3 | Step 4 |
|--------|--------|--------|--------|
| <img src="https://github.com/user-attachments/assets/8fd7ccfe-eef8-41b5-9366-4aa8691e4b3c" width="220"/> | <img src="https://github.com/user-attachments/assets/94cd38ee-7b6b-4e2e-b186-af9f50892995" width="220"/> | <img src="https://github.com/user-attachments/assets/0e8cffd1-e4b7-432b-a184-038c3b67c949" width="220"/> | <img src="https://github.com/user-attachments/assets/39d57da6-e037-45df-8f2f-501336aebbf4" width="220"/> |

---

## ✨ Features

### 🔐 Authentication
- Animated splash screen with fade + slide entrance and decorative teal blob backgrounds
- Register with name, email, and password — field-level inline validation (length, format, alphanumeric password)
- Login with email/password — JWT persisted in flutter_secure_storage
- Email verification gate — redirected to a resend-verification screen on unverified login (HTTP 403)
- Forgot password flow — triggers a reset email via API
- Auto-login on relaunch (token check in splash)
- Full logout — clears JWT, destroys all GetX controllers, returns to Login

### 🏠 Groups
- Groups list with per-group balance summary card (owed / owes / settled status)
- Shimmer skeleton loading on first fetch
- Create group: name + emoji picker (24 presets) + optional friends from your friend list
- Per-group balance preview (up to 2 rows inline; "+N more ›" tap opens the full breakdown sheet)
- "All settled up" state with green check indicator
- Group card taps navigate to the full expense view

### 💰 Expenses
- Expenses grouped by month with a month-total header (settlements excluded from total)
- Category icons auto-resolved from description keywords (food, transport, home, utilities, entertainment, shopping, health, education, and more)
- Expense card shows: category icon, description, payer, "you lent / you borrowed" amount, date
- **Add Expense**: description, amount, payer selector, member toggle checkboxes, split type selector
- **Three split modes**:
  - **Equal** — backend divides evenly across selected members
  - **Exact** — enter a dollar amount per person (must sum to total)
  - **Percentage** — enter % per person (must sum to 100%)
- **Edit Expense** — pre-fills all fields including split amounts; re-uses the same AddExpense screen
- **Delete Expense** — swipe left (endToStart dismissible) with confirmation dialog
- **Expense Detail Sheet** — bottom sheet showing payer, total, "lent / borrowed" pill, split breakdown table with per-member percentage progress bars
- **Edit Settlement** — inline dialog to update the settlement amount without navigating away

### ⚖️ Balances
- Net balance per member (positive = gets back, negative = owes)
- Suggested settlements list (minimum transactions via greedy algorithm)
- Shimmer loading state while balances are calculated server-side
- "Everyone is settled up" empty state with celebration icon

### 🧩 Settlement Breakdown Sheet
An interactive 4-step animated bottom sheet that teaches users _exactly_ how settlements are calculated:

1. **Net Balances** — total paid minus total owed per member, creditor/debtor tags
2. **Who Owes Who** — raw pairwise debts from all shared expenses
3. **Simplified** — before/after comparison showing the greedy reduction
4. **Result** — final settlement plan with transaction count savings

Triggered from: the Balances screen ("How is this calculated?" button) and the Group header ("See breakdown" / "+N more ›" tap).

### 📊 Charts
- **Spending by Member** — interactive donut chart; tap a slice to see the exact dollar amount
- **Monthly / Weekly Spending** — animated bar chart with a smooth toggle between views; tooltip on bar tap
- **My Share vs Others** — two-slice donut showing what you paid for others vs what you owe; net balance shown in the centre

### 📋 Totals
- Group total spend + expense count summary card
- Per-member breakdown: amount paid, share owed, % of group spend, net balance badge
- Linear progress bar showing each member's proportion of group spend
- "You" card highlighted with a teal border

### ⚙️ Group Settings
- Rename group (inline text field)
- Change group emoji (24-emoji picker grid)
- Change default split type (equal / exact / percentage)
- Add member by email
- Remove member with confirmation dialog
- Leave group (any member)
- Delete group (creator only — danger zone)
- All mutations update local state immediately without a full refetch

### 👤 Profile
- Avatar card with initials circle (gradient background) and inline name edit shortcut
- Overall balance summary card (teal gradient): total you're owed, total you owe, net, active group count
- Edit display name (bottom sheet with validation)
- Set default split type preference (persisted; applied when opening Add Expense)
- Invite a friend (copies app link to clipboard)
- Account settings: display name, email (read-only)
- Delete account (confirmation sheet with guard copy)
- Log out button

### 🧩 UX & Polish
- Portrait-only orientation lock
- Shimmer skeleton loading on Groups list, Expense list, and Balances screen
- All data mutations invalidate the relevant cache keys and silently refresh in the background
- Empty states with icons and CTAs on every screen
- Consistent snackbar via `AlertWidgets.showSnackBar()` — never raw `Get.snackbar()`

---

## 🛠 Tech Stack

### Frontend

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | 3.x | UI framework |
| `get` | ^4.7.3 | State management, routing, dependency injection |
| `dio` | ^5.9.1 | HTTP client with JWT interceptor |
| `flutter_secure_storage` | ^10.0.0 | Encrypted JWT token storage |
| `flutter_screenutil` | ^5.9.3 | Responsive `.w` / `.sp` sizing (design base 414×896) |
| `google_fonts` | ^7.0.0 | Inter font family throughout |
| `flutter_svg` | ^2.0.10+1 | SVG logo and icon assets |
| `lottie` | ^3.1.3 | Lottie JSON animation support |
| `fl_chart` | ^0.71.0 | Donut and bar charts |
| `cupertino_icons` | ^1.0.6 | iOS-style icon support |

### Backend

| Technology | Purpose |
|-----------|---------|
| Node.js + Express | REST API server |
| MongoDB + Mongoose | Database and ODM |
| JWT | Stateless authentication |
| Railway | Production cloud deployment |

---

## 🏗 Architecture

```
splitify/
├── lib/
│   ├── main.dart                          # Entry — ScreenUtilInit + GetMaterialApp
│   ├── core/
│   │   ├── api/
│   │   │   └── api_client.dart            # Dio singleton, base URL, JWT interceptor
│   │   ├── constants/
│   │   │   └── constants.dart             # Color palette, asset paths
│   │   ├── theme/
│   │   │   └── app_themes.dart            # headingText / subHeadingText / normalText
│   │   └── utils/
│   │       ├── cache_manager.dart         # TTL-based in-memory cache singleton
│   │       ├── date_helper.dart           # SplitifyDateUtils (format + groupByMonth)
│   │       └── snackbar_helper.dart       # SnackBarHelper.success / .error
│   ├── features/
│   │   ├── auth/                          # Login, Register, Splash, Verify, Forgot PW
│   │   ├── groups/                        # Groups list, Expenses, Balances, Settings,
│   │   │                                  # Settle Up, Charts, Totals, Breakdown Sheet
│   │   ├── expenses/                      # Add/Edit expense, Charts helpers
│   │   ├── friends/                       # Friends list (layout complete)
│   │   ├── activity/                      # Activity feed (placeholder)
│   │   ├── navigation/                    # Bottom nav controller + shell
│   │   └── profile/                       # Profile view, controller, user model
│   └── shared/
│       └── widgets/                       # AlertWidgets, GroupCard, Shimmer, BottomNav
└── src/                                   # Node.js backend
    ├── controllers/
    ├── models/
    ├── routes/
    ├── middleware/
    └── utils/
        └── balance.js                     # calculateGroupBalances() — cents arithmetic
```

---

## 🧠 State Management

Splitify uses **GetX** exclusively — no Provider, Riverpod, or Bloc.

### Pattern

```dart
// Register once (permanent controllers)
Get.put(GroupsController());
Get.put(ProfileController());

// Reactive variables
RxList<GroupSummary> summaries = <GroupSummary>[].obs;
RxBool isLoading = false.obs;

// Observe in UI
Obx(() => Text(groupCtrl.summaries.length.toString()))
```

### Controller Lifecycle

| Controller | Lifetime | Notes |
|-----------|---------|-------|
| `AuthController` | App session | Registered in Splash |
| `ProfileController` | App session | Registered in Splash |
| `GroupsController` | App session | Main data hub for all group data |
| `NavigationController` | App session | Tracks bottom nav index |
| `FriendsController` | App session | Tagged `'friends'` |
| `ActivityController` | App session | |
| `AddExpenseController` | Per-navigation | Deleted + re-created on every open to prevent stale state |

### Key Rule — Edit Mode

```dart
// Always delete before re-creating AddExpenseController
await Get.delete<AddExpenseController>(force: true);
final ctrl = AddExpenseController(editExpense: expense);
ctrl.groupId = expense.group ?? '';
Get.put(ctrl);           // onInit fires, fetches members, pre-fills form
Get.to(() => const AddExpenseView());
```

---

## ⚡ Caching Strategy

Splitify uses a **TTL-based in-memory singleton** (`CacheManager`) combined with **per-group Map-based stores** in `GroupsController`.

### How It Works

```dart
class CacheManager {
  // isFresh(key) — true if fetched within TTL (default 5 min)
  // markFetched(key) — stamps the current time for a key
  // invalidate(key) — forces the next access to hit the network
  // invalidateAll([...keys]) — batch invalidation
  // clear() — wipe everything on logout
}

class CacheKeys {
  static const String summaries = 'groups_summaries';
  static const String friends   = 'friends';
  static const String activity  = 'activity';
  // Per-group keys — unique per groupId:
  static String groupExpenses(String id) => 'expenses_$id';
  static String groupMembers(String id)  => 'members_$id';
  static String groupBalances(String id) => 'balances_$id';
}
```

### In-Memory Data Stores (`GroupsController`)

```dart
RxMap<String, GroupExpenses>      allGroupExpenses   // keyed by groupId
RxMap<String, GroupMembersModel>  allGroupMembers    // keyed by groupId
RxMap<String, GroupBalancesModel> allGroupBalances   // keyed by groupId
```

### Cache Invalidation After Mutations

```dart
_cache.invalidateAll([
  CacheKeys.summaries,
  CacheKeys.friends,
  CacheKeys.activity,
  CacheKeys.groupExpenses(groupId),
  CacheKeys.groupBalances(groupId),   // only for balance-affecting changes
]);
await Future.wait([
  fetchGroupExpenses(groupId: groupId, forceRefresh: true),
  fetchSummary(forceRefresh: true),
]);
```

Local-only mutations (rename, emoji, split type) update `summaries[index]` in place and call `summaries.refresh()` — no network round-trip.

---

## 🌐 Backend Integration

**Production API:** `https://splitify-backend-production.up.railway.app`

All requests attach the stored JWT automatically via a Dio interceptor:

```dart
options.headers["Authorization"] = "Bearer $token";
```

### Key Endpoints

| Method | Endpoint | Description |
|--------|---------|-------------|
| `POST` | `/api/auth/register` | Register + trigger email verification |
| `POST` | `/api/auth/login` | Returns `{ token, user }` |
| `POST` | `/api/auth/forgot-password` | Send password reset email |
| `GET` | `/api/groups/summary` | All groups with balance preview |
| `POST` | `/api/groups` | Create group |
| `GET` | `/api/groups/:id/expenses` | Expense list |
| `POST` | `/api/groups/:id/expenses` | Add expense |
| `PUT` | `/api/groups/:id/expenses/:eid` | Update expense |
| `DELETE` | `/api/groups/:id/expenses/:eid` | Delete expense |
| `GET` | `/api/groups/:id/balances` | Net balances + simplified settlements |
| `POST` | `/api/groups/:id/settle` | Record a settlement payment |
| `POST` | `/api/groups/:id/members` | Add member by email |
| `DELETE` | `/api/groups/:id/members/:mid` | Remove member |
| `PUT` | `/api/groups/:id/rename` | Rename group |
| `PUT` | `/api/groups/:id/emoji` | Update group emoji |
| `PUT` | `/api/groups/:id/default-split-type` | Update default split type |
| `DELETE` | `/api/groups/:id/leave` | Leave group |
| `DELETE` | `/api/groups/:id` | Delete group (creator only) |

### Debt Simplification Algorithm (Backend)

The backend runs a **greedy algorithm** to minimise settlement transactions:

1. Compute net balance per member (positive = creditor, negative = debtor)
2. Sort creditors and debtors descending by absolute value
3. Match the largest debtor to the largest creditor
4. If debtor owes less than creditor is owed → debtor settles in full, advance to next debtor
5. If debtor owes more → creditor is paid off fully, advance to next creditor
6. Result: the minimum number of transactions to settle all debts

---

## 🚀 Running Locally

### Prerequisites

- Flutter SDK ≥ 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or Xcode for a device/simulator
- Node.js ≥ 18 + MongoDB (only needed if running the backend locally)

### 1. Clone the repository

```bash
git clone https://github.com/your-username/splitify.git
cd splitify
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure the API URL

Open `lib/core/api/api_client.dart` and set the base URL:

```dart
// Local backend:
baseUrl: "http://localhost:3000",

// Production (Railway — already set by default):
baseUrl: "https://splitify-backend-production.up.railway.app",
```

> **iOS Simulator:** use `http://localhost:3000`  
> **Android Emulator:** use `http://10.0.2.2:3000`

### 4. (Optional) Run the backend locally

```bash
cd src
npm install
# Create a .env with MONGODB_URI and JWT_SECRET
npm start
```

### 5. Run the app

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

---

## 📦 Building a Release APK

```bash
flutter build apk --release
```

Output path:

```
build/app/outputs/flutter-apk/app-release.apk
```

For a Play Store app bundle:

```bash
flutter build appbundle --release
```

---

## 🔑 Auth Flow (User Perspective)

```
Launch app
    └── Splash (2 s) — checks stored JWT
          ├── Token valid + profile loaded  →  Home (Groups)
          └── No token / expired           →  Login

Register
    └── POST /register  →  Email Verification screen
          └── Click email link  →  Login

Login
    ├── HTTP 403 (unverified)  →  Verify Email screen (resend option)
    └── Success  →  JWT stored securely  →  Home

Forgot Password
    └── Enter email  →  POST /forgot-password  →  reset email sent  →  Login

Logout
    └── Delete JWT  →  destroy all controllers  →  Login screen
```

---

## 🗺 Roadmap

| Feature | Status |
|---------|--------|
| Groups, Expenses, Balances, Settle Up | ✅ Complete |
| Charts (donut, bar, my share) | ✅ Complete |
| Totals view | ✅ Complete |
| Settlement Breakdown Sheet (4-step) | ✅ Complete |
| Group Settings (rename, emoji, split type, members) | ✅ Complete |
| Profile (edit name, default split, delete account) | ✅ Complete |
| Email verification + forgot password | ✅ Complete |
| TTL-based cache with per-group maps | ✅ Complete |
| Shimmer skeleton loading states | ✅ Complete |
| Friends screen | 🔧 Layout complete — API integration pending |
| Activity feed | 🔧 Placeholder screen |
| Push notifications | 📋 Planned |
| Invite flow for non-registered users | 📋 Planned |
| Expense list pagination | 📋 Planned |
| Dark mode | 📋 Planned |

---

## 🎨 Design System

| Token | Value | Usage |
|-------|-------|-------|
| `bgColor` | `#F2F1F8` | Scaffold background (light purple-grey) |
| `bgColorLight` | `#FFFFFF` | Card / sheet background |
| `activeColor` | `#0DAD85` | Primary brand colour · positive balances · CTAs |
| `redColor` | `#E56D39` | Debt · danger · delete actions |
| `chipColor` | `#373B3F` | Inactive action chips |
| Font | Inter (Google Fonts) | All text — never hardcoded `fontFamily` |
| Card radius | 12–16 px | Consistent rounding on all cards |
| Chip radius | 10 px | Action chips |
| Pill radius | 20 px | Badge pills |

---

## 👤 Author

Built by **Safyian** — [GitHub](https://github.com/Safyian)

---

_Splitify — because nobody likes doing the maths after dinner._
