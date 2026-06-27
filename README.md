# 💸 Splittify

> **Split smart. Settle fast.**

A bill-splitting app (like Splitwise) built with Flutter + GetX, backed by a Node.js + Express + MongoDB REST API. Splittify lets friend groups track shared expenses, visualise spending patterns, and settle debts in the fewest possible transactions using a greedy debt-simplification algorithm.

---

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart->=3.4.4-0175C2?logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-4.7.3-9C27B0)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/Platform-iOS-000000?logo=apple&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Node.js-339933?logo=nodedotjs&logoColor=white)

---

## 📸 Screenshots

### 🔐 Authentication

| Sign In | Sign Up |
|:-------:|:-------:|
| <img src="https://github.com/user-attachments/assets/c0d142a5-9fd4-481f-9dcf-d9df7acfca1b" width="220"/> | <img src="https://github.com/user-attachments/assets/0e0a018f-e1dc-4d7c-ae81-b6b6bfaa066e" width="220"/> |

### 🧭 Main Navigation

| Friends | Groups | Activity | Profile |
|:-------:|:------:|:--------:|:-------:|
| <img src="https://github.com/user-attachments/assets/d775f0cc-1aa6-4a9d-9ac8-2cc741737be5" width="220"/> | <img src="https://github.com/user-attachments/assets/7c5c8cf3-00dc-4fc5-84b5-58177a45488f" width="220"/> | <img src="https://github.com/user-attachments/assets/1f1b95d9-58b6-4aba-aa00-997023a099fc" width="220"/> | <img src="https://github.com/user-attachments/assets/72d96852-025f-4290-acd4-c130eb63fc37" width="220"/> |

### 💰 Group Expenses

| Expenses | Expense Details | Add Expense |
|:--------:|:---------------:|:-----------:|
| <img src="https://github.com/user-attachments/assets/15eb49ef-a863-41dd-bfe1-9e0400f9c7e7" width="220"/> | <img src="https://github.com/user-attachments/assets/65c82b35-ba4b-4047-bca1-6c0ea81400be" width="220"/> | <img src="https://github.com/user-attachments/assets/62fdbb61-8338-4847-9b50-921e257a8530" width="220"/> |

| Settle Up | Add Settlement |
|:---------:|:--------------:|
| <img src="https://github.com/user-attachments/assets/07c3fc7f-5f81-453c-bfdc-08722101611b" width="220"/> | <img src="https://github.com/user-attachments/assets/c1a6240a-cb09-4df4-baf9-366671aa1585" width="220"/> |

### 🏠 Create & Manage Groups

| Create — Step 1 | Create — Step 2 | Group Settings |
|:---------------:|:---------------:|:--------------:|
| <img src="https://github.com/user-attachments/assets/16baff97-8ec1-4160-9f8a-d6afb60c545d" width="220"/> | <img src="https://github.com/user-attachments/assets/0105222f-e053-40c3-b2fb-218219826c50" width="220"/> | <img src="https://github.com/user-attachments/assets/fe4f3ceb-a98a-4525-9dcd-9a9ff43a6c01" width="220"/> |

### 📊 Insights

| Charts | Totals |
|:------:|:------:|
| <img src="https://github.com/user-attachments/assets/64a5ed2f-1737-4054-ad8e-f15ab39b5041" width="220"/> | <img src="https://github.com/user-attachments/assets/52bb3db5-735a-4cf3-98b9-c6257d24eca7" width="220"/> |

---

## ✨ Features

### 🔐 Authentication
- Animated splash screen with fade + slide entrance and decorative teal blob backgrounds
- **Four sign-in methods**:
  - **Email + password** — field-level inline validation (length, format, alphanumeric password)
  - **Phone + OTP** — register/login by phone number with a one-time passcode (E.164 entry via `intl_phone_field`, OTP UI via `pinput`)
  - **Google Sign-In** — available on **both** Android and iOS
  - **Apple Sign-In** — available on **iOS only** (gated behind `Platform.isIOS`; captures the user's name on first sign-in)
- JWT persisted in `flutter_secure_storage`
- Email verification gate — redirected to a resend-verification screen on unverified login (HTTP 403)
- Forgot password flow — triggers a reset email via API
- Auto-login on relaunch (token check in splash); on a network failure with a valid token, a "Couldn't connect" retry screen is shown instead of logging the user out
- Full logout — clears JWT, destroys all per-user GetX controllers, returns to Login

### 🏠 Groups
- Groups list with per-group balance summary card (owed / owes / settled status)
- Shimmer skeleton loading on first fetch
- Create group: name + emoji picker + optional friends from your friend list
- Per-group balance preview (up to 2 rows inline; "+N more ›" tap opens the full breakdown sheet)
- "All settled up" state with green check indicator
- Group card taps navigate to the full expense view

### 💰 Expenses
- Expenses grouped by month with a month-total header (settlements excluded from total)
- **Paginated** expense history — older expenses load on demand
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
- **Balance modes** — view raw **pairwise** direct debts (default) or **simplified** suggested settlements (minimum transactions via greedy algorithm); toggle per group in settings
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

### 👥 Friends & Contacts
- Friends list with per-friend net balance across all shared groups
- **Add a friend by email**
- **Add from device contacts** — contacts are matched against registered users using **privacy-preserving SHA-256 hashing** (phone numbers / emails are hashed on-device before being sent for matching)
- **Invite non-registered contacts** — share an invite to people who aren't on Splittify yet via the native share sheet
- Friend changes refresh balances across the app

### ⚙️ Group Settings
- Rename group (inline text field)
- Change group emoji (emoji picker grid)
- Change default split type (equal / exact / percentage)
- Change balance mode (pairwise / simplified)
- Add member by email, by user, or from contacts
- Remove member with confirmation dialog
- Leave group (any member)
- Delete group (creator/admin only — danger zone)
- Local mutations (rename, emoji, split type, balance mode) update state immediately without a full refetch

### 👤 Profile
- Avatar card with initials circle (gradient background) and inline name edit shortcut
- Overall balance summary card (teal gradient): total you're owed, total you owe, net, active group count
- Edit display name (bottom sheet with validation)
- Set default split type preference (persisted; applied when opening Add Expense)
- Invite a friend (shares the app link)
- Account settings: display name, email (read-only)
- Delete account (confirmation sheet with guard copy)
- Log out button

### 🔔 Activity
- Activity feed surfacing new expenses and settlements across your groups (paginated)

### 🧩 UX & Polish
- Portrait-only orientation lock
- Shimmer skeleton loading on Groups list, Expense list, and Balances screen
- All data mutations invalidate the relevant cache keys and silently refresh in the background
- **Offline-aware fetches** — a failed load with no cached data shows an inline retry/error state, while a failed refresh of existing data keeps the screen and shows a snackbar (load-failure is distinguished from genuinely-empty)
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
| `flutter_screenutil` | ^5.9.3 | Responsive `.w` / `.h` / `.sp` / `.r` sizing (design base 414×896) |
| `flutter_svg` | ^2.0.10+1 | SVG logo and icon assets |
| `lottie` | ^3.1.3 | Lottie JSON animation support |
| `fl_chart` | ^0.71.0 | Donut and bar charts |
| `google_sign_in` | ^7.2.0 | Google authentication (Android + iOS) |
| `sign_in_with_apple` | ^8.1.0 | Apple authentication (iOS) |
| `intl_phone_field` | ^3.2.0 | Phone number input with country codes |
| `pinput` | ^5.0.0 | OTP / PIN entry fields |
| `flutter_contacts` | ^2.2.0 | Device contacts access for friend matching |
| `permission_handler` | ^11.3.0 | Runtime permission requests (contacts) |
| `crypto` | ^3.0.3 | SHA-256 hashing for privacy-preserving contact matching |
| `share_plus` | ^13.0.0 | Native share sheet for invites |
| `url_launcher` | ^6.3.2 | Open external links |
| `cupertino_icons` | ^1.0.6 | iOS-style icon support |

> **Fonts:** The **Inter** family is bundled as static `.ttf` files in `assets/fonts/` (weights 400–800) and declared in `pubspec.yaml`. The app sets `fontFamily: 'Inter'` on its theme — it does **not** use the `google_fonts` runtime package, so there is no font download at runtime.

> **Dev tooling:** `flutter_lints ^3.0.0`, `flutter_launcher_icons ^0.14.4`.

### Backend

| Technology | Purpose |
|-----------|---------|
| Node.js + Express | REST API server |
| MongoDB + Mongoose | Database and ODM |
| JWT | Stateless authentication |

> The backend is a separate service and is **not** included in this repository. The Flutter app talks to it through the base URL configured in `lib/core/config/app_config.dart`.

---

## 🏗 Architecture

```
splitify/                                  # repo folder (one "t"); package name is "splittify"
├── lib/
│   ├── main.dart                          # Entry — ScreenUtilInit + GetMaterialApp + InitialBinding
│   ├── core/
│   │   ├── api/
│   │   │   └── api_client.dart            # Dio singleton + JWT interceptor
│   │   ├── bindings/
│   │   │   └── initial_binding.dart       # App-wide controllers registered once
│   │   ├── config/
│   │   │   └── app_config.dart            # Base API URL lives here
│   │   ├── constants/
│   │   │   └── constants.dart             # Color palette, asset paths, input decoration
│   │   ├── theme/
│   │   │   └── app_themes.dart            # headingText / subHeadingText / normalText (Inter)
│   │   └── utils/
│   │       ├── cache_manager.dart         # TTL-based in-memory cache singleton
│   │       ├── date_helper.dart           # SplitifyDateUtils (format + groupByMonth)
│   │       ├── expense_icon_helper.dart   # Category icon resolution
│   │       ├── hash_helper.dart           # SHA-256 hashing for contact matching
│   │       └── snackbar_helper.dart       # SnackBarHelper.success / .error
│   ├── features/
│   │   ├── auth/
│   │   │   ├── Controllers/               # AuthController
│   │   │   ├── Views/                     # Login, Register, Splash, Verify Email,
│   │   │   │                              # Verify Phone, Forgot PW, Social buttons
│   │   │   ├── auth_services.dart
│   │   │   └── auth_widgets.dart
│   │   ├── groups/
│   │   │   ├── Controllers/               # GroupsController
│   │   │   ├── Models/                    # summary / expenses / members / balances
│   │   │   ├── Views/                     # Groups list, Expenses, Balances, Settings,
│   │   │   │                              # Settle Up, Totals, Detail, Breakdown Sheet,
│   │   │   │                              # Create Group, Add Member Sheet
│   │   │   └── group_service.dart
│   │   ├── expenses/                      # Add/Edit expense, Charts, helpers, service
│   │   ├── friends/                       # Friends list + contact picker + service
│   │   ├── activity/                      # Activity feed (controller / model / service / view)
│   │   ├── navigation/                    # Bottom nav controller + shell
│   │   └── profile/                       # Profile view, controller, service, user model
│   └── shared/
│       ├── contacts/                      # Reusable contact picker widgets
│       └── widgets/                       # AlertWidgets, AppDialogs, GroupCard,
│                                          # Shimmer, BottomNav, cards
├── assets/
│   ├── fonts/                             # Inter static .ttf files (400–800)
│   └── images/                            # SVG / PNG / Lottie JSON assets
├── android/                              # Android project (Google sign-in config)
└── ios/                                  # iOS project (Apple + Google sign-in config)
```

---

## 🧠 State Management

Splittify uses **GetX** exclusively — no Provider, Riverpod, or Bloc.

### Pattern

```dart
// App-wide controllers registered once in InitialBinding
Get.put(GroupsController(), permanent: true);
Get.put(ProfileController(), permanent: true);

// Reactive variables
RxList<GroupSummary> summaries = <GroupSummary>[].obs;
RxBool isLoading = false.obs;

// Observe in UI
Obx(() => Text(groupCtrl.summaries.length.toString()))
```

### Controller Lifecycle

App-wide controllers are registered **once** in `core/bindings/initial_binding.dart`
(`Get.put(..., permanent: true)`) and retrieved everywhere with `Get.find<T>()`.
On logout they are explicitly deleted to wipe per-user state, then re-created on the
next sign-in via `ensureAppControllers()`.

| Controller | Lifetime | Notes |
|-----------|---------|-------|
| `AuthController` | App session | Registered in `InitialBinding`; owns all auth flows |
| `ProfileController` | App session | Registered in `InitialBinding`; current user |
| `GroupsController` | App session | Registered in `InitialBinding`; main data hub |
| `ActivityController` | App session | Registered in `InitialBinding` |
| `NavigationController` | App session | Registered in `InitialBinding`; tracks bottom nav index |
| `FriendsController` | App session | Registered with `tag: 'friends'` from the Friends screen |
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

Splittify uses a **TTL-based in-memory singleton** (`CacheManager`) combined with **per-group Map-based stores** in `GroupsController`.

### How It Works

```dart
class CacheManager {
  // isFresh(key, {ttl}) — true if fetched within TTL (default 5 min; per-group 120 s)
  // markFetched(key)    — stamps the current time for a key
  // invalidate(key)     — forces the next access to hit the network
  // invalidateAll([...keys]) — batch invalidation
  // clear()             — wipe everything on logout
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

Local-only mutations (rename, emoji, split type, balance mode) update `summaries[index]` in place and call `summaries.refresh()` — no network round-trip.

---

## 🌐 Backend Integration

The base API URL is configured in **`lib/core/config/app_config.dart`**:

```dart
class AppConfig {
  static const String baseUrl = '<YOUR_BACKEND_BASE_URL>';
}
```

All requests attach the stored JWT automatically via a Dio interceptor in `lib/core/api/api_client.dart`:

```dart
options.headers["Authorization"] = "Bearer $token";
```

### Key Endpoints

| Method | Endpoint | Description |
|--------|---------|-------------|
| `POST` | `/auth/register` | Register (email or phone) + trigger verification |
| `POST` | `/auth/login` | Email/password login → `{ token, user }` |
| `POST` | `/auth/login-phone` | Phone + password login |
| `POST` | `/auth/send-phone-otp` | Send a phone OTP |
| `POST` | `/auth/verify-phone-otp` | Verify a phone OTP |
| `POST` | `/auth/google` | Exchange a Google ID token for a session |
| `POST` | `/auth/apple` | Exchange an Apple ID token for a session |
| `POST` | `/auth/resend-verification` | Resend the email verification link |
| `POST` | `/auth/forgot-password` | Send password reset email |
| `GET` | `/auth/me` | Current user profile |
| `PATCH` | `/auth/me` | Update display name |
| `DELETE` | `/auth/me` | Delete account |
| `GET` | `/groups/summary` | All groups with balance preview |
| `POST` | `/groups/new` | Create group |
| `GET` | `/groups/:id/expenses` | Expense list (paginated) |
| `POST` | `/groups/:id/expenses` | Add expense |
| `PATCH` | `/groups/:id/expenses/:eid` | Update expense |
| `DELETE` | `/groups/:id/expenses/:eid` | Delete expense |
| `PATCH` | `/groups/:id/settlements/:eid` | Update a settlement amount |
| `GET` | `/groups/:id/balances` | Net balances + pairwise + simplified settlements |
| `POST` | `/groups/:id/settle` | Record a settlement payment |
| `POST` | `/groups/:id/members` | Add member (by email, user id, or contact) |
| `DELETE` | `/groups/:id/members/:mid` | Remove member |
| `PATCH` | `/groups/:id/name` | Rename group |
| `PATCH` | `/groups/:id/emoji` | Update group emoji |
| `PATCH` | `/groups/:id/settings/split-type` | Update default split type |
| `PATCH` | `/groups/:id/settings/balance-mode` | Update balance mode |
| `POST` | `/groups/:id/leave` | Leave group |
| `DELETE` | `/groups/:id` | Delete group (creator/admin only) |
| `GET` | `/friends` | Friends list with balances |
| `POST` | `/friends` | Add friend by email |
| `POST` | `/friends/add-by-id` | Add friend by user id |
| `DELETE` | `/friends/:id` | Remove friend |
| `POST` | `/friends/invite` | Invite a non-registered contact |
| `POST` | `/users/check-contacts` | Match hashed contacts against registered users |
| `GET` | `/activity` | Activity feed (paginated) |

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

- Flutter SDK ≥ 3.x, Dart `>=3.4.4 <4.0.0` ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio (min SDK 21) and/or Xcode + CocoaPods for a device/simulator
- A running instance of the Splittify backend API

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

Open **`lib/core/config/app_config.dart`** and set the base URL to your own backend instance:

```dart
class AppConfig {
  static const String baseUrl = '<YOUR_BACKEND_BASE_URL>';
}
```

> **iOS Simulator:** a local backend is reachable at `http://localhost:<port>`
> **Android Emulator:** use `http://10.0.2.2:<port>` to reach a local backend

### 4. Configure social sign-in (optional)

Google and Apple sign-in require your own credentials configured in the native
`android/` and `ios/` projects. Provide your own client IDs — do not commit secrets.

### 5. Run the app

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

---

## 📦 Building a Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

APK output path:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔑 Auth Flow (User Perspective)

```
Launch app
    └── Splash (~2 s) — checks stored JWT
          ├── Token valid + profile loaded  →  Home (Groups)
          ├── No token / 401                →  Login
          └── Token valid but offline       →  "Couldn't connect" retry screen

Sign in / Register
    ├── Email + password
    │     ├── Register  →  Email Verification screen  →  (verify link)  →  Login
    │     └── Login
    │           ├── HTTP 403 (unverified)  →  Verify Email screen (resend option)
    │           └── Success  →  JWT stored securely  →  Home
    ├── Phone + OTP
    │     └── Register / Login  →  Verify Phone screen (OTP)  →  Home
    ├── Google (Android + iOS)
    │     └── Google account  →  POST /auth/google  →  Home
    └── Apple (iOS only)
          └── Apple ID  →  POST /auth/apple  →  Home

Forgot Password
    └── Enter email  →  POST /auth/forgot-password  →  reset email sent  →  Login

Logout
    └── Delete JWT  →  destroy per-user controllers  →  Login screen
```

---

## 🗺 Roadmap

| Feature | Status |
|---------|--------|
| Groups, Expenses, Balances, Settle Up | ✅ Complete |
| Charts (donut, bar, my share) | ✅ Complete |
| Totals view | ✅ Complete |
| Settlement Breakdown Sheet (4-step) | ✅ Complete |
| Group Settings (rename, emoji, split type, balance mode, members) | ✅ Complete |
| Profile (edit name, default split, delete account) | ✅ Complete |
| Email verification + forgot password | ✅ Complete |
| Phone + OTP authentication | ✅ Complete |
| Google + Apple Sign-In | ✅ Complete |
| Friends screen + add by email / contacts (hashed matching) | ✅ Complete |
| Invite flow for non-registered contacts | ✅ Complete |
| Activity feed | ✅ Complete |
| Expense list pagination | ✅ Complete |
| TTL-based cache with per-group maps | ✅ Complete |
| Shimmer skeleton loading states | ✅ Complete |
| Push notifications | 📋 Planned |
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
| Font | Inter (bundled static fonts in `assets/fonts/`, weights 400–800) | All text — set via theme `fontFamily: 'Inter'`, never hardcoded per widget |
| Card radius | 12–16 px | Consistent rounding on all cards |
| Chip radius | 10 px | Action chips |
| Pill radius | 20 px | Badge pills |

---

## 👤 Author

Built by **Safyian** — [GitHub](https://github.com/Safyian)

---

_Splittify — because nobody likes doing the maths after dinner._
</content>