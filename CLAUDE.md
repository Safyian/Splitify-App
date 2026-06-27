# Splittify — Project Reference for Claude

This file is the single source of truth for the Splittify project.
Read this at the start of every session before writing any code.

> **Naming:** The brand/app name is always **"Splittify"** (two t's) — used in all
> user-facing strings, the Dart package name (`splittify`), and the API host.
> The **project folder on disk is `splitify`** (one t) and some legacy identifiers
> keep the single-t spelling: the Dart package import was historically `splitify`
> but is now `package:splittify/...`; the helper class `SplitifyDateUtils` and the
> asset `assets/images/splitify-logo.svg` (`Constants.splitifyLogo`) still use one t.
> When writing new user-facing copy, always spell it **Splittify**.

---

## Project Overview

**Splittify** is a bill-splitting app (like Splitwise).
- **Frontend (this repo):** Flutter (Android + iOS) with GetX state management.
- **Backend:** Node.js + Express + MongoDB (Mongoose). **Not in this repo** — it is
  a separate service hosted at `https://api.splittify.app`. The "Backend" sections
  below describe the contract the Flutter app depends on, inferred from the client.
- **Auth:** JWT stored in `flutter_secure_storage` under the key `"token"`.

---

## Tech Stack

- **Flutter / Dart** — SDK `>=3.4.4 <4.0.0`. Dart package name: `splittify`
  (import prefix `package:splittify/...`). App version `1.0.0+2`.
- **GetX** (`get: ^4.7.3`) — state management, routing, dependency injection. Only.
  No Provider / Riverpod / Bloc.
- **Dio** (`dio: ^5.9.1`) — HTTP via the `ApiClient` singleton.
- **flutter_secure_storage** (`^10.0.0`) — token storage (key `"token"`).
- **flutter_screenutil** (`^5.9.3`) — responsive sizing (`.w`, `.h`, `.sp`, `.r`),
  `designSize: Size(414, 896)`.
- **flutter_svg** (`^2.0.10+1`) — SVG icons. **lottie** (`^3.1.3`) — settle/arrow
  animations (`*.json`). **fl_chart** (`^0.71.0`) — charts view.
- **intl_phone_field** (`^3.2.0`) + **pinput** (`^5.0.0`) — phone entry + OTP UI.
- **flutter_contacts** (`^2.2.0`) + **permission_handler** (`^11.3.0`) +
  **crypto** (`^3.0.3`) — contact picker; numbers/emails are SHA-256 hashed before
  being sent to the backend for matching.
- **share_plus** (`^13.0.0`) + **url_launcher** (`^6.3.2`) — invite / share flows.
- **google_sign_in** (`^7.2.0`) + **sign_in_with_apple** (`^8.1.0`) — social auth.
- **flutter_launcher_icons** (`^0.14.4`, dev) — generates app icons from
  `assets/images/splittify_icon_1024.png`.

### Fonts — bundled Inter only (NO `google_fonts`)
- `google_fonts` is **not** a dependency. Do not add it or use `GoogleFonts.*`.
  (Older notes/memory said "GoogleFonts everywhere" — that is obsolete.)
- Inter is bundled as static `.ttf` files in `assets/fonts/` and declared in
  `pubspec.yaml`. `GetMaterialApp` sets `theme: ThemeData(fontFamily: 'Inter')`,
  so Inter is the default family app-wide. New `TextStyle`s normally don't need to
  set `fontFamily` (it inherits), but `AppTheme` and `inputDecoration` set
  `fontFamily: 'Inter'` explicitly — match the surrounding code.
- **Bundled weights (must stay in sync with any `FontWeight` you use):**

  | weight | file |
  |--------|------|
  | 400 | `Inter-Regular.ttf` |
  | 500 | `Inter-Medium.ttf` |
  | 600 | `Inter-SemiBold.ttf` |
  | 700 | `Inter-Bold.ttf` |
  | 800 | `Inter-ExtraBold.ttf` |

  Every `FontWeight` used in the UI must have a matching bundled file — there is no
  runtime font download in release. Currently used: `w400, w500, w600, w700`
  (`FontWeight.bold` == w700), `w800`. **If you introduce a new weight (e.g. w300),
  you must add the corresponding Inter static `.ttf` to `assets/fonts/` and declare
  it in `pubspec.yaml`, or it will silently fall back / render wrong in release.**

---

## Repository Structure

```
splitify/                         # folder is one-t; package is "splittify"
├── lib/
│   ├── main.dart                 # entry: ScreenUtilInit + GetMaterialApp, InitialBinding
│   ├── core/
│   │   ├── api/api_client.dart       # Dio singleton, base URL, Bearer interceptor
│   │   ├── bindings/initial_binding.dart  # app-wide controllers (see below)
│   │   ├── config/app_config.dart    # AppConfig.baseUrl
│   │   ├── constants/constants.dart  # colors, asset paths, inputDecoration
│   │   ├── theme/app_themes.dart     # AppTheme text styles
│   │   └── utils/
│   │       ├── cache_manager.dart    # TTL cache (CacheManager + CacheKeys)
│   │       ├── date_helper.dart      # SplitifyDateUtils
│   │       ├── expense_icon_helper.dart
│   │       ├── hash_helper.dart      # SHA-256 for contact matching
│   │       └── snackbar_helper.dart  # SnackBarHelper.success/error
│   ├── features/
│   │   ├── auth/
│   │   │   ├── Controllers/auth_controller.dart
│   │   │   ├── Views/   login_view, register_view, splash_view,
│   │   │   │            forgot_password_view, verify_email_view,
│   │   │   │            verify_phone_view, social_buttons
│   │   │   ├── auth_services.dart
│   │   │   └── auth_widgets.dart      # AuthLabel, AuthInputField, AuthPrimaryButton
│   │   ├── groups/                    # core feature — most active
│   │   │   ├── Controllers/groups_controller.dart
│   │   │   ├── Models/   group_summary_model, group_expenses_model,
│   │   │   │             group_members_model, group_balances_model
│   │   │   ├── Views/    groups_view, group_expenses_view, group_settings_view,
│   │   │   │             create_group_view, balances_view, settle_up_view,
│   │   │   │             totals_view, expense_detail_view, add_member_sheet,
│   │   │   │             settlement_breakdown_sheet
│   │   │   └── group_service.dart
│   │   ├── expenses/                  # add_expense_view/controller, charts_view,
│   │   │   │                          # chart_helpers, expense_payload_model, expense_service
│   │   ├── activity/                  # controller, model, services, view
│   │   ├── friends/                   # controller, model, services, view,
│   │   │   │                          # add_friend_view, contact_picker_view
│   │   ├── navigation/                # nav_controller, navigation_view
│   │   └── profile/                   # controller, service, view, user_model
│   └── shared/
│       ├── contacts/   add_by_email_field, contact_picker_widget, person_row
│       └── widgets/    alert_widgets, app_dialogs, bottom_navBar, shimmer,
│                       activity_card, friend_card, group_card
├── assets/fonts/                  # Inter static .ttf files (400–800)
├── assets/images/                 # svg / png / lottie json
├── android/  ios/                 # native projects (social-auth config lives here)
└── CLAUDE.md  README.md  pubspec.yaml
```

> **Folder-casing note:** `auth/`, `groups/` use capitalized subfolders
> (`Controllers/`, `Views/`, `Models/`). Most other features keep files flat in the
> feature root. Match whatever the feature you're editing already does.

---

## Theme & Design System

### Constants (`lib/core/constants/constants.dart`)
```dart
Constants.bgColor       = Color(0xFFF2F1F8)   // page background (light purple-grey)
Constants.bgColorLight  = Colors.white         // card background
Constants.activeColor   = Color(0xFF0DAD85)    // teal — primary brand color
Constants.redColor      = Color(0xFFE56D39)    // orange-red — debt / danger
Constants.chipColor     = Color(0xFF373B3F)    // dark grey — inactive chips
Constants.textDark      = Colors.black
Constants.textLight     = Colors.white
Constants.textGrey      = Colors.grey.shade600
```
`constants.dart` also exports a shared `inputDecoration` (rounded 10, filled,
red error borders) and all asset path strings (`Constants.*Logo`).

### AppTheme (`lib/core/theme/app_themes.dart`)
```dart
AppTheme.headingText    // Inter 16sp, w600, textDark
AppTheme.subHeadingText // Inter 14sp, w500, textDark
AppTheme.normalText     // Inter 13sp, w500, textDark
```
Use these + `.copyWith()` for variants rather than building `TextStyle` from scratch.

### Rules
- Font: bundled **Inter** (`fontFamily: 'Inter'`, inherited from theme) — never
  `GoogleFonts`, never hardcode another `fontFamily`.
- Background: `Constants.bgColor` on Scaffold, `Constants.bgColorLight` on cards.
- Positive/owed: `Constants.activeColor` (teal). Negative/debt: `Constants.redColor`.
- Borders: `Colors.grey.shade200/300`.
- No dark theme — light-only app.
- Spacing: use `SizedBox`, not `Padding`, for simple gaps.
- Border radius: cards 12–16, chips 10, pills 20.
- Sizing: `flutter_screenutil` (`.w/.h/.sp/.r`).

---

## Startup & Navigation Flow

### App start (`main.dart`)
1. `_setup()` — `WidgetsFlutterBinding.ensureInitialized()`, lock to portrait,
   `ScreenUtil.ensureScreenSize()`.
2. `GetMaterialApp` with `initialBinding: InitialBinding()` (registers all app-wide
   controllers once), `theme: ThemeData(fontFamily: 'Inter')`, `home: SplashView()`.

### Splash → route decision (`auth/Views/splash_view.dart`)
- Plays a 900ms fade/slide animation, waits ~2s, then `_runStartup()`:
  - `auth.checkLogin()` reads the token (sets `isLoggedIn`, no navigation).
  - No token → `Get.off(LoginView())`.
  - Token present → `profileCtrl.getUserDetails()`:
    - success → `loadInitialAppData()` then `Get.off(NavigationView())`.
    - 401 → token cleared inside `getUserDetails`, returns false → `LoginView`.
    - **network failure (token valid but offline) → `_ConnectionRetryView`** with a
      "Try again" button that re-runs the whole splash. It does **not** log the user
      out on a network error — only on a real 401.

### Bottom navigation (`navigation/navigation_view.dart` + `nav_controller.dart`)
`NavigationView` is a `StatelessWidget` whose body is `pages[currentIndex]` inside an
`Obx`. Tab order (indices):

| index | tab | page |
|-------|-----|------|
| 0 | Friends | `FriendsScreen` |
| 1 | Groups | `GroupsScreen` |
| 2 | Add | `SizedBox()` placeholder (handled specially in the nav bar) |
| 3 | Activity | `ActivityScreen` |
| 4 | Profile | `ProfileView` |

`NavigationController.changeTab(index)` sets `currentIndex` and refreshes the
relevant controller on tab switch (Friends→`fetchFriends`, Groups→`fetchSummary`,
Activity→`fetchActivity`). These respect the TTL cache, so switching tabs is cheap.

- Push/pop: `Get.to()` / `Get.back()`. Sheets: `Get.bottomSheet()`.
- Group detail flow: `GroupsView` → `GroupExpensesView` → tabs (`BalancesView`,
  `SettleUpView`, `ChartsView`, `TotalsView`). Settings icon → `GroupSettingsView`.

---

## State Management & Dependency Injection (GetX)

### App-wide controllers via `InitialBinding` (`core/bindings/initial_binding.dart`)
Registered **once** at app start with `Get.put(..., permanent: true)` and retrieved
everywhere with `Get.find<T>()`:

```dart
Get.put(AuthController(),       permanent: true);
Get.put(ProfileController(),    permanent: true);
Get.put(GroupsController(),     permanent: true);
Get.put(ActivityController(),   permanent: true);
Get.put(NavigationController(), permanent: true);
```

- **`permanent: true`** keeps them alive across route changes; but **logout
  explicitly deletes** them (`Get.delete<T>(force: true)`) to wipe per-user state.
- After a fresh login (email / phone / Google / Apple), `ensureAppControllers()`
  re-`put`s any controller that isn't currently registered (idempotent — safe to call
  every login). Then `loadInitialAppData()` kicks off `fetchSummary()` +
  `fetchActivity()`.
- `AuthController.logout()` deletes: `AddExpenseController`,
  `FriendsController(tag: 'friends')`, `ActivityController`, `GroupsController`,
  `ProfileController`, `NavigationController` — then `Get.offAll(LoginView())`.
  (`AuthController` itself is left registered.)

### Non-permanent / scoped controllers
- **`FriendsController`** is **not** in `InitialBinding`. It is `Get.put` **with
  `tag: 'friends'`** inside `friends_view.dart`. Always retrieve it as
  `Get.find<FriendsController>(tag: 'friends')` and guard with
  `Get.isRegistered<FriendsController>(tag: 'friends')`.
- **`AddExpenseController`** is recreated on every navigation: delete then put
  (`Get.delete<AddExpenseController>(force: true)` before `Get.put`). See
  "Add / Edit Expense".

### Reactive patterns
`RxBool/RxList/RxMap`, `.obs`, `Obx(() => ...)`. Loading flags per concern
(`isLoading`, `isSettling`, `isLoadingBalances`, `isLoadingMoreExpenses`).

---

## Caching (`core/utils/cache_manager.dart`)

`CacheManager` is a singleton holding a `key → lastFetched` timestamp map.
- `isFresh(key, ttl)` — default TTL 5 min; per-group fetches use **120s**.
- `markFetched`, `invalidate`, `invalidateAll([...])`, `clear()` (on logout).
- Keys via `CacheKeys`: `summaries`, `friends`, `activity`, and per-group
  `groupExpenses(id)`, `groupMembers(id)`, `groupBalances(id)`.

Controllers consult the cache before hitting the network and call
`invalidateAll([...])` after mutations (settle / delete / member changes / balance
mode) so dependent views refetch. `GroupsController` also stores per-group data in
`RxMap`s (`allGroupExpenses`, `allGroupMembers`, `allGroupBalances`) with
`expensesFor/membersFor/balancesFor(id)` getters.

---

## Offline / Error-State Convention (important)

Fetch methods distinguish **load-failure** from **genuinely-empty**:

- If a fetch fails **and there is no data loaded yet**, set an **inline error string**
  (`error.value` / `balanceErrors[id]` / `expenseErrors[id]`) =
  `'Check your connection and try again.'` → the view shows a retry/error state, not
  an "empty" state.
- If a fetch fails **but data is already present** (a refresh), keep the stale data
  and show a **snackbar** (`'Failed to refresh …'`) instead of clobbering the screen.
- An empty list with **no error** is a true empty state (show the empty UI).

When building/editing list views, preserve this three-way distinction
(error vs empty vs loaded). `FriendsController`, `GroupsController.fetchSummary`,
`fetchGroupExpenses`, and `fetchGroupBalances` all follow it.

---

## Auth UI Flows (`features/auth/`)

`AuthController` (app-wide) owns all flows. `AuthService` (`auth_services.dart`)
wraps the endpoints. Field-level validation errors live in
`fieldErrors` (`RxMap<String,String>`).

### Email
- **Register** `POST /auth/register {name,email,password}` → goes to
  `VerifyEmailView`. Client validation: name ≥ 2, valid email, password ≥ 8 and
  contains letters + numbers.
- **Login** `POST /auth/login {email,password}` → `{token, user}`. On HTTP **403**
  (email not verified) it routes to `VerifyEmailView` instead of erroring.
- **Resend verification** `POST /auth/resend-verification {email}` (rate-limited in UI).
- **Forgot password** `POST /auth/forgot-password {email}`.

### Phone (Twilio OTP)
- **Register** `POST /auth/register {name,phone,password}`; if response
  `requiresPhoneVerification == true` → `VerifyPhoneView(otpAlreadySent: true)`.
- **Login** `POST /auth/login-phone {phone,password}`; may also require verification.
- **OTP**: `POST /auth/send-phone-otp {phone}`, `POST /auth/verify-phone-otp {phone,otp}`.
- Phone numbers are normalized to **E.164** (via `intl_phone_field`,
  `completePhone`). OTP UI uses `pinput`. `isPhoneLogin` toggles email/phone mode.

### Google Sign-In (both platforms)
- `signInWithGoogle()` → `GoogleSignIn.instance.initialize(...)` then `.authenticate()`,
  sends the `idToken` to `POST /auth/google {idToken}`.
- iOS passes a platform-specific `clientId`; Android relies on `serverClientId` only.
  The `serverClientId` (web client) is the backend audience on **both** platforms.
- User-cancel (`GoogleSignInExceptionCode.canceled`) is silent.

### Apple Sign-In (iOS only)
- `signInWithApple()` → `SignInWithApple.getAppleIDCredential(...)`, sends `identityToken`
  to `POST /auth/apple {idToken, name}`.
- **Gated to iOS** — `Platform.isIOS`. The Apple button is only rendered on iOS
  (`if (Platform.isIOS)` in `social_buttons.dart`), and the controller path is
  iOS-only. Apple returns the user's name **only on first sign-in**, so it's captured
  from `givenName`/`familyName` and forwarded; cancel is silent.

### Post-login (all methods)
Write token → `ensureAppControllers()` → `getUserDetails()` (best-effort) →
`loadInitialAppData()` → `Get.offAll(NavigationView())`.

### `social_buttons.dart`
`SocialAuthButtons` renders logo-only circular buttons (56.r). Apple button shown
only on iOS, Google always. Follows Apple HIG (1:1, black/white background, artwork
used as-is).

---

## Backend API (contract the client expects)

Base URL: `AppConfig.baseUrl = 'https://api.splittify.app'` (used by the `ApiClient`
Dio singleton; **not** `localhost`). Every request carries
`Authorization: Bearer <token>` via the request interceptor. Timeouts: 10s
connect/receive.

### Auth
```
POST /auth/register             { name, email, password }  | { name, phone, password }
POST /auth/login                { email, password } → { token, user }
POST /auth/login-phone          { phone, password }
POST /auth/send-phone-otp       { phone }
POST /auth/verify-phone-otp     { phone, otp }
POST /auth/resend-verification  { email }
POST /auth/forgot-password      { email }
POST /auth/google               { idToken }
POST /auth/apple                { idToken, name }
GET    /auth/me                 → current user (ProfileService.getUser)
PATCH  /auth/me                 { name }   (update display name)
DELETE /auth/me                 (delete account)
```

### Groups
```
GET    /groups/summary                         → GroupSummary[]
POST   /groups/new                             { name } → { id }
GET    /groups/:groupId/expenses               (paginated) → GroupExpenses
GET    /groups/:groupId/members                → Member[]
GET    /groups/:groupId/balances               → GroupBalancesModel
POST   /groups/:groupId/members                { email } | { userId } | { name, email?, phone? }
DELETE /groups/:groupId/members/:memberId
PUT    /groups/:groupId/name                   { name }
PUT    /groups/:groupId/emoji                  { emoji }
PUT    /groups/:groupId/settings/split-type    { splitType }
PUT    /groups/:groupId/settings/balance-mode  { balanceMode }
POST   /groups/:groupId/leave
DELETE /groups/:groupId
POST   /groups/:groupId/settle                 { toUserId, amount }
```

### Expenses
```
POST   /groups/:groupId/expenses               AddExpenseRequest
PATCH  /groups/:groupId/expenses/:id           AddExpenseRequest (update)
DELETE /groups/:groupId/expenses/:id
PATCH  /groups/:groupId/settlements/:id        { amount }  (edit a settlement)
```

### Friends
```
GET    /friends                  → Friend[]
POST   /friends                  { email }
POST   /friends/add-by-id        { userId }
DELETE /friends/:friendId
POST   /friends/invite           { name, phone?, email? }
POST   /users/check-contacts     { hashes[...] }   (SHA-256 matched contacts)
```

### Activity
```
GET    /activity?page=&limit=    (paginated; data may arrive as Map or stringified JSON)
```

> Endpoint shapes are inferred from the Flutter services; if the backend disagrees,
> the backend wins — update this section.

---

## Key Data Models (Flutter)

### GroupSummary
```dart
class GroupSummary {
  String id;
  String name;
  String emoji;             // default "🏠"
  String defaultSplitType;  // "equal" | "exact" | "percentage"
  String createdBy;         // userId of creator
  String? adminId;          // admin (may differ from creator)
  String? balanceMode;      // "pairwise" | "simplified" (group balance display mode)
  Balance balance;          // { net, status: settled | you_owe | you_are_owed }
  List<Preview> preview;    // max 2 entries shown on card
  int othersCount;          // hidden entries beyond the 2 shown
}
```

### GroupBalancesModel
```dart
class GroupBalancesModel {
  List<MemberBalance> balances;     // net per member
  List<SettlementDebt> settlements; // simplified debts (greedy algo)
  List<PairwiseDebt> pairwise;      // raw pairwise from expenses
  String? balanceMode;              // active mode for this group
}
class MemberBalance { String userId; String name; double net; } // +owed / -owes
class SettlementDebt { String from, fromName, to, toName; double amount; }
class PairwiseDebt   { String from, fromName, to, toName; double amount; }
```

### AddExpenseRequest / SplitInput
```dart
class AddExpenseRequest {
  String description; double amount; String paidBy;  // userId
  SplitType splitType;          // equal | exact | percentage
  List<SplitInput> splits;
}
class SplitInput { String user; double? amount; double? percentage; }
```

---

## Backend Balance Calculation (reference for the contract)

- Per expense: `paidBy` gets `+amount`; each split user gets `-splitAmount`.
- Settlements are expenses with `description === "Settlement"`.
- Net per user; integer **cents** server-side; the client displays dollars,
  using a `toPrecision(2)` extension to avoid float drift and
  `.toStringAsFixed(2)` for display.
- **Balance modes:** `pairwise` (raw direct debts) is the default; `simplified` uses
  the greedy minimum-transactions algorithm. Toggle via group settings (balance mode).

### Simplify Debts Algorithm (greedy)
1. Split members into creditors (net > 0) and debtors (net < 0).
2. Sort both by absolute value, descending.
3. Match largest debtor ↔ largest creditor; pay off the smaller side fully; advance.
4. Result: minimum number of transactions.

---

## Feature: Add / Edit Expense

### Split types
- **Equal:** pass only `user` IDs — backend divides evenly.
- **Exact:** `user` + `amount` per person — must sum to total.
- **Percentage:** `user` + `percentage` (raw, e.g. `25.0` = 25%, not `0.25`) — must
  sum to 100. Backend converts to amounts on save.

### Edit-mode pattern
```dart
await Get.delete<AddExpenseController>(force: true); // 1. drop stale controller
final ctrl = AddExpenseController(editExpense: expense);
ctrl.groupId = expense.group ?? '';                  // 2. set groupId BEFORE put
Get.put(ctrl);                                       // 3. onInit fetches members + prefills
Get.to(() => const AddExpenseView(index: -1));
```
`selectedMembers` is an `RxSet<String>` of user IDs; `toggleMember(id)` adds/removes;
prefilled from `expense.splits` in edit mode.

---

## Feature: Settlement Breakdown Sheet

**File:** `lib/features/groups/Views/settlement_breakdown_sheet.dart`

4-step interactive bottom sheet explaining settlement math:
Net Balances → Who Owes Who (pairwise) → Simplified (before/after greedy) → Result.

```dart
final data = SettlementBreakdownData.fromBalancesModel(
  groupCtrl.balancesFor(groupId),       // balances must already be loaded
  myId,                                  // profileCtrl.user.value.user?.id
);
showSettlementBreakdown(context, data);
```

Triggers: `balances_view.dart` ("How is this calculated?", only when settlements
exist) and `group_expenses_view.dart` (header "See breakdown →" / "+N more ›").
**`fetchGroupBalances` deliberately does not toggle `isLoading`** — doing so would
swap the body for a spinner via `Obx`, unmount the triggering widget, and the sheet
would never show. (`settle_up_view.dart` is the pending trigger location.)

---

## Feature: Settle Up

**File:** `lib/features/groups/Views/settle_up_view.dart`
- Lists who the current user owes (from `settlements` filtered to `from == myId`).
- User picks a settlement, enters amount (max = settlement amount).
- `groupCtrl.settleExpense(groupId, toUserId, amount)` → invalidates summaries /
  friends / activity / group caches, refetches expenses + summary, pops 2 screens.

## Feature: Balances View

**File:** `lib/features/groups/Views/balances_view.dart`
- `groupCtrl.fetchGroupBalances(groupId: id)`; shows member nets + suggested
  settlements. `nameMap[b.userId] ?? b.name` — always falls back, never "Unknown".

## Feature: Group Settings

**File:** `lib/features/groups/Views/group_settings_view.dart`
- Rename, emoji, default split type, **balance mode**, add/remove members,
  leave / delete (danger zone). Only the creator/admin can delete; any member leaves.
- Rename/emoji/splitType/balanceMode update `summaries[index]` locally +
  `summaries.refresh()` (rename/emoji/splitType skip a full refetch; balance mode
  refetches summary + balances + friends).

## Feature: Expense List

**File:** `lib/features/groups/Views/group_expenses_view.dart`
- Grouped by month via `SplitifyDateUtils.groupByMonth()`; month totals exclude
  settlements. **Paginated** — `fetchGroupExpenses(loadMore: true)` appends the next
  page (`isLoadingMoreExpenses`, `hasMore`).
- Swipe-left to delete (confirm dialog). Tap → `_ExpenseDetailSheet` (split breakdown
  with percentage bar; Edit → `AddExpenseView` edit mode; settlements get an
  amount-only edit dialog). Balance preview: max 2 rows + inline `+N more ›` /
  `↗ See breakdown`.

## Feature: Friends & Contacts

- `FriendsController` (tag `'friends'`). Add by email / by userId / invite by
  name+phone/email. Contact picker (`shared/contacts/`, `friends/contact_picker_view`)
  hashes phone/email with SHA-256 (`hash_helper.dart`) and calls
  `/users/check-contacts` to find registered users; unregistered → invite/share flow.

---

## Shared Widgets & Dialogs (`lib/shared/widgets/`)

```
alert_widgets.dart   // AlertWidgets.showSnackBar(), showLoadingDialog(), hideLoadingDialog()
app_dialogs.dart     // AppDialogs: loading / success / confirm / invite / info
shimmer.dart         // skeleton loaders
activity_card.dart  friend_card.dart  group_card.dart  bottom_navBar.dart
```

### Snackbars
- Prefer `AlertWidgets.showSnackBar(message: '...')` — **not** `Get.snackbar()`
  directly (context issues). `SnackBarHelper.success/error` exists too.
- Where `Get.snackbar` is unavoidable (some `AuthController` paths), it is wrapped in
  `WidgetsBinding.instance.addPostFrameCallback` to avoid build-phase context errors.
  Before navigating after auth, close open snackbars (`Get.closeAllSnackbars()`).

---

## Common Patterns & Gotchas

- **Stale-data refresh:** after settle/delete/update, invalidate the relevant cache
  keys and refresh **both** expenses and summary:
  ```dart
  await Future.wait([
    groupCtrl.fetchGroupExpenses(groupId: groupId, forceRefresh: true),
    groupCtrl.fetchSummary(forceRefresh: true),
  ]);
  ```
- **Settlement detection:** `expense.description == "Settlement"`.
- **Amount precision:** server stores cents; client uses `toPrecision(2)` +
  `.toStringAsFixed(2)` for display.
- **Dates:** `SplitifyDateUtils.formatExpenseDate(...)` ("Mar 5"),
  `SplitifyDateUtils.groupByMonth(list, (e) => e.createdAt)`.
- **Positional `index`:** `GroupExpensesView` / `GroupSettingsView` take a positional
  `index` into `summaries` — always guard:
  `if (index >= groupCtrl.summaries.length) return const SizedBox.shrink();`
- **Create group flow:** close any open snackbar, then `Get.back()`, then set the
  Groups tab; clear `name/emoji/selectedFriendIds/searchQuery` after creation.
- **GetX + non-const text:** `TextStyle`/`AppTheme.*` are fine as non-const; widget
  constructors can still be `const`. Inter is the default family — don't pass another
  `fontFamily`.

---

## Pending / Not-Yet-Built

- [ ] Push notifications (`notification.svg` asset exists; no wiring yet).
- [ ] Add breakdown-sheet trigger to `settle_up_view.dart`.
- [ ] Activity screen polish (controller/view exist).

---

## Development Notes

- Dart package: `splittify` (import `package:splittify/...`).
- State/DI/routing: **GetX only**. HTTP: **Dio** via `ApiClient` singleton.
- Token in `flutter_secure_storage` (key `"token"`).
- Sizing: `flutter_screenutil` (`.w/.h/.sp/.r`, design 414×896). SVG via
  `flutter_svg`; Lottie for settle/arrow (`assets/images/*.json`).
- App icons generated by `flutter_launcher_icons` (`assets/images/splittify_icon_1024.png`).
- iOS-specific config (`ios/Runner/Info.plist`, signing) is required for Apple +
  Google sign-in; Android uses `serverClientId` from `auth_controller.dart`.
</content>
</invoke>
