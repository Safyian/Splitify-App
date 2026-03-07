# Splitify — Project Reference for Claude

This file is the single source of truth for the Splitify project.
Read this at the start of every session before writing any code.

---

## Project Overview

**Splitify** is a bill-splitting app (like Splitwise) with:
- **Backend:** Node.js + Express + MongoDB (Mongoose)
- **Frontend:** Flutter (Android) with GetX state management
- **Auth:** JWT stored in secure storage

---

## Repository Structure

```
splitify/
├── src/                          # Node.js backend
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── groups.controller.js
│   │   ├── expenses.controller.js
│   │   └── profile.controller.js
│   ├── models/
│   │   ├── user.js
│   │   ├── group.js
│   │   └── expense.js
│   ├── routes/
│   ├── middleware/
│   │   └── auth.middleware.js    # JWT verify → req.user
│   └── utils/
│       └── balance.js            # calculateGroupBalances()
│
└── lib/                          # Flutter frontend
    ├── core/
    │   ├── api/api_client.dart   # Dio HTTP client, base URL, JWT header
    │   ├── constants/constants.dart
    │   ├── theme/app_themes.dart
    │   └── utils/
    │       ├── date_helper.dart
    │       └── snackbar_helper.dart
    ├── features/
    │   ├── auth/
    │   ├── groups/               # Core feature — most active
    │   ├── expenses/
    │   ├── activity/
    │   ├── friends/
    │   ├── navigation/
    │   └── profile/
    └── shared/widgets/
```

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

### AppTheme (`lib/core/theme/app_themes.dart`)
```dart
AppTheme.headingText    // Inter 16sp, w600, textDark
AppTheme.subHeadingText // Inter 14sp, w500, textDark
AppTheme.normalText     // Inter 13sp, w500, textDark
```

### Rules
- Font: `GoogleFonts.inter()` everywhere — never hardcode fontFamily
- Background: `Constants.bgColor` on Scaffold, `Constants.bgColorLight` on cards
- Positive/owed: `Constants.activeColor` (teal)
- Negative/debt: `Constants.redColor` (orange-red)
- Borders: `Colors.grey.shade200`
- No dark theme — this is a light-only app
- Spacing: use `SizedBox`, not `Padding` for simple gaps
- Border radius: cards = 12-16, chips = 10, pills = 20

---

## Backend API

### Base URL
Configured in `lib/core/api/api_client.dart` (Dio).
All requests include `Authorization: Bearer <token>` header.

### Auth Endpoints
```
POST /api/auth/register   { name, email, password }
POST /api/auth/login      { email, password }  → { token, user }
```

### Groups Endpoints
```
GET    /api/groups/summary                          → GroupSummary[]
POST   /api/groups                                  { name }
POST   /api/groups/:groupId/members                 { email }
DELETE /api/groups/:groupId/members/:memberId
DELETE /api/groups/:groupId/leave
DELETE /api/groups/:groupId
GET    /api/groups/:groupId/members                 → Member[]
GET    /api/groups/:groupId/expenses                → Expense[]
GET    /api/groups/:groupId/balances                → GroupBalancesModel (see below)
PUT    /api/groups/:groupId/rename                  { name }
PUT    /api/groups/:groupId/emoji                   { emoji }
PUT    /api/groups/:groupId/default-split-type      { splitType }
```

### Expenses Endpoints
```
POST   /api/groups/:groupId/expenses           AddExpenseRequest
PUT    /api/groups/:groupId/expenses/:id       AddExpenseRequest (update)
DELETE /api/groups/:groupId/expenses/:id
PUT    /api/groups/:groupId/expenses/:id/settle  { amount }
```

### Settle Up Endpoint
```
POST /api/groups/:groupId/settle   { toUserId, amount }
```

---

## Key Data Models

### GroupBalancesModel (Flutter)
```dart
class GroupBalancesModel {
  List<MemberBalance> balances;    // net per member
  List<SettlementDebt> settlements; // simplified debts (greedy algo)
  List<PairwiseDebt> pairwise;     // raw pairwise from expenses
}

class MemberBalance {
  String userId;
  String name;
  double net;          // positive = is owed, negative = owes
}

class SettlementDebt {
  String from; String fromName;
  String to;   String toName;
  double amount;
}

class PairwiseDebt {
  String from; String fromName;
  String to;   String toName;
  double amount;
}
```

### AddExpenseRequest (Flutter)
```dart
class AddExpenseRequest {
  String description;
  double amount;
  String paidBy;          // userId
  SplitType splitType;    // equal | exact | percentage
  List<SplitInput> splits;
}

class SplitInput {
  String user;
  double? amount;      // for exact split
  double? percentage;  // for percentage split
}
```

### GroupSummary (Flutter)
```dart
class GroupSummary {
  String id;
  String name;
  String emoji;             // default "🏠"
  String defaultSplitType;  // "equal" | "exact" | "percentage", default "equal"
  String createdBy;         // userId of group creator
  Balance balance;          // { net, status: settled|you_owe|you_are_owed }
  List<Preview> preview;    // max 2 entries shown on card
  int othersCount;          // hidden entries beyond the 2 shown
}
```

---

## Backend Balance Calculation

### `utils/balance.js` — `calculateGroupBalances(group, expenses)`
- Returns `{ [userId]: netCents }` (integer cents, not dollars)
- For each expense: paidBy gets `+amount`, each split user gets `-splitAmount`
- Settlements are expenses with `description === "Settlement"`

### `getGroupBalances` controller response
```json
{
  "balances": [
    { "userId": "...", "name": "John", "net": 40.37 }
  ],
  "settlements": [
    { "from": "...", "fromName": "Sufi", "to": "...", "toName": "John", "amount": 324.27 }
  ],
  "pairwise": [
    { "from": "...", "fromName": "Sufi", "to": "...", "toName": "John", "amount": 224.14 }
  ]
}
```

### Simplify Debts Algorithm (greedy)
1. Separate members into creditors (net > 0) and debtors (net < 0)
2. Sort both descending by absolute value
3. Match largest debtor to largest creditor
4. If debtor owes less than creditor is owed: debtor pays off fully → move to next debtor
5. If debtor owes more: creditor is paid off fully → move to next creditor
6. Result: minimum number of transactions

---

## Flutter Architecture

### State Management: GetX
- Controllers registered with `Get.put()` or `Get.find()`
- `GroupsController` is the main controller — registered once at app start
- `AddExpenseController` is re-created on every navigation (`Get.delete<AddExpenseController>(force: true)` before `Get.put`)
- Reactive variables: `RxBool`, `RxList`, `.obs`, `Obx()`

### Navigation
- Bottom nav: Groups | Friends | Add | Activity | Profile
- `Get.to()` / `Get.back()` for push/pop
- `Get.bottomSheet()` for bottom sheets
- Group detail flow: `GroupsView` → `GroupExpensesView` → tabs (BalancesView, SettleUpView, ChartsView, TotalsView)
- Settings icon in `GroupExpensesView` → `GroupSettingsView` (rename, emoji, default split type, add/remove members, leave, delete)

### Key Controllers
```dart
GroupsController        // summaries, groupExpenses, groupBalances, groupMembers
                        // + settings: addMember, removeMember, renameGroup,
                        //   updateEmoji, updateDefaultSplitType, leaveGroup, deleteGroup
AddExpenseController    // form state, split inputs, edit mode
ProfileController       // current user (user.value.user?.id for myId)
AuthController          // login/register/logout
```

---

## Feature: Settlement Breakdown Sheet

**File:** `lib/features/groups/settlement_breakdown_sheet.dart`

### What it does
4-step interactive bottom sheet explaining how settlements are calculated:
1. Net Balances — each member's total paid vs owed
2. Who Owes Who — pairwise direct debts
3. Simplified — before/after comparison with greedy algo explanation
4. Result — final settlement plan with amounts

### How to trigger
```dart
// Requires groupBalances to already be loaded
final data = SettlementBreakdownData.fromBalancesModel(
  groupCtrl.groupBalances.value,
  myId,  // profileCtrl.user.value.user?.id
);
showSettlementBreakdown(context, data);
```

### Current trigger locations
1. `lib/features/groups/balances_view.dart` — "How is this calculated?" button next to "Suggested Settlements" heading. Only shows when `settlements.isNotEmpty`.
2. `lib/features/groups/group_expenses_view.dart` — "See breakdown →" link (or "+N more ›" inline) in the group header balance preview. Auto-fetches balances if not yet loaded.

### Important: fetchGroupBalances does NOT set isLoading
`fetchGroupBalances` was intentionally changed to skip toggling `isLoading` — doing so would unmount the widget that triggered it (due to Obx replacing the body with a spinner), causing `context.mounted` to be false and the sheet to never show.

### Pending trigger location
- **`settle_up_view.dart`** — "How is this calculated?" link below the amount

---

## Feature: Add / Edit Expense

### Split Types
- **Equal:** pass only `user` IDs — backend divides evenly
- **Exact:** pass `user` + `amount` per person — must sum to total
- **Percentage:** pass `user` + `percentage` per person — must sum to 100

### Percentage storage
Percentages are stored as raw values (e.g. `25.0` = 25%) in the DB, not decimals. Backend converts to amounts on save.

### Edit mode pattern
```dart
// 1. Delete old controller (important — prevents stale state)
await Get.delete<AddExpenseController>(force: true);
// 2. Create new one with editExpense
final ctrl = AddExpenseController(editExpense: expense);
// 3. Set groupId BEFORE Get.put (so onInit has it)
ctrl.groupId = expense.group ?? '';
// 4. Put — onInit fires and fetches members + pre-fills form
Get.put(ctrl);
Get.to(() => const AddExpenseView(index: -1));
```

### Member selection
`selectedMembers` is a `RxSet<String>` of user IDs. `toggleMember(id)` adds/removes.
In edit mode, `selectedMembers` is pre-filled from `expense.splits`.

---

## Feature: Settle Up

**File:** `lib/features/groups/settle_up_view.dart`

- Shows list of who current user owes (from `groupBalances.settlements` filtered to `from == myId`)
- User selects a settlement, enters amount (max = settlement amount)
- Calls `groupCtrl.settleExpense(groupId, toUserId, amount)`
- On success: refreshes expenses + summary, pops 2 screens

---

## Feature: Balances View

**File:** `lib/features/groups/balances_view.dart`

- Fetched via `groupCtrl.fetchGroupBalances(groupId: id)`
- Shows member net balances + suggested settlements
- `nameMap` built from `groupCtrl.groupMembers` with fallback to API names:
  ```dart
  nameMap[b.userId] ?? b.name  // always falls back, never shows "Unknown"
  ```

---

## Feature: Group Settings

**File:** `lib/features/groups/group_settings_view.dart`

- Rename group, change emoji, set default split type
- Add member by email, remove member (with confirmation)
- Leave group / Delete group (danger zone)
- Only creator can delete; any member can leave
- After rename/emoji/splitType: updates `summaries[index]` locally + calls `summaries.refresh()` (no full refetch)

---

## Feature: Expense List

**File:** `lib/features/groups/group_expenses_view.dart`

- Expenses grouped by month using `SplitifyDateUtils.groupByMonth()`
- Month totals exclude settlements (`description != 'Settlement'`)
- Swipe left (endToStart) to delete — shows confirmation dialog
- Tap → `_ExpenseDetailSheet` bottom sheet
  - Shows split breakdown with percentage bar
  - Edit button → opens `AddExpenseView` in edit mode
  - For settlements: shows edit dialog (amount only, no split)
- Balance preview shows max 2 rows; if `othersCount > 0`, last row has inline `+N more ›` tap to open breakdown sheet
- When `othersCount == 0`, shows `↗ See breakdown` underlined link below rows

---

## Shared Widgets (`lib/shared/widgets/`)

```
alert_widgets.dart   // AlertWidgets.showSnackBar(), showLoadingDialog(), hideLoadingDialog()
activity_card.dart
friend_card.dart
group_card.dart
bottom_navBar.dart
```

### Snackbar pattern
Always use `AlertWidgets.showSnackBar(message: '...')` — NOT `Get.snackbar()` directly (causes context issues).

---

## Common Patterns & Gotchas

### GetX Snackbar
```dart
// ✅ Correct
AlertWidgets.showSnackBar(message: 'Done');
// ❌ Avoid — can throw context errors
Get.snackbar('Title', 'Message');
```

### Stale balance bug fix
After settle/delete/update, always refresh BOTH:
```dart
await Future.wait([
  groupCtrl.fetchGroupExpenses(groupId: groupId),
  groupCtrl.fetchSummary(),
]);
```
`fetchGroupBalances` is separate and only called when navigating to BalancesView.

### Settlement detection
```dart
final isSettlement = expense.description == "Settlement";
```
Settlements are regular expenses with this specific description string.

### Amount precision
Backend stores in cents (integer). Frontend uses `toPrecision(2)` extension on doubles to avoid floating point drift. Always `.toStringAsFixed(2)` for display.

### Date formatting
```dart
SplitifyDateUtils.formatExpenseDate(expense.createdAt)  // "Mar 5"
SplitifyDateUtils.groupByMonth(expenses, (e) => e.createdAt)  // groups list
```

---

## Pending Features (not yet built)

- [ ] Push notifications (when someone adds expense or settles)
- [ ] Pagination on expense list (currently loads all)
- [ ] Friends screen (currently placeholder)
- [ ] Activity screen (currently placeholder)
- [ ] Invite flow (currently only works if user already registered)
- [ ] Add breakdown sheet trigger to `settle_up_view.dart`

---

## Backend Models (Mongoose)

### Expense
```js
{
  group: ObjectId,
  description: String,
  amount: Number,           // dollars (float)
  paidBy: ObjectId,
  splitType: 'equal' | 'exact' | 'percentage',
  splits: [{ user: ObjectId, amount: Number, percentage: Number }],
  createdAt: Date
}
```

### Group
```js
{
  name: String,
  emoji: String,              // default "🏠"
  defaultSplitType: String,   // "equal" | "exact" | "percentage"
  members: [ObjectId],
  createdBy: ObjectId,
  createdAt: Date
}
```

### User
```js
{
  name: String,
  email: String,
  password: String (hashed),
  createdAt: Date
}
```

---

## Development Notes

- Flutter package: `splitify` (import prefix `package:splitify/...`)
- State: GetX only — no Provider, no Riverpod, no Bloc
- HTTP: Dio via `ApiClient` singleton
- Auth token stored in flutter_secure_storage
- ScreenUtil (`flutter_screenutil`) used for `.w` / `.sp` sizing
- SVG assets via `flutter_svg`
- Lottie animations for settle/arrow in assets/images/*.json
