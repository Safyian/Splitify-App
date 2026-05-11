# Splittify — Manual Test Cases
> Complete testing checklist before App Store & Play Store submission
> Mark each test: ✅ Pass | ❌ Fail | ⏭ Skip

---

## 1. Auth Flow

### Registration
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 1.1 | Register with valid name, email, password | Verification email received, navigate to verify screen | | ✅
| 1.2 | Register with invalid email format | Inline error: "Enter a valid email address" | | ✅
| 1.3 | Register with name less than 2 characters | Inline error: "Name must be at least 2 characters" | | ✅
| 1.4 | Register with password less than 8 characters | Inline error: "Password must be at least 8 characters" | | ✅
| 1.5 | Register with password containing no numbers | Inline error: "Password must contain letters and numbers" | | ✅
| 1.6 | Register with already registered email | Error: "An account with this email already exists" | | ✅
| 1.7 | Register → skip verification → try login | Redirected to verify email screen | | ✅
| 1.8 | Register → verify email → login | Login successful, lands on Groups screen | | ✅
| 1.9 | Resend verification email | New email received, old link expired, new link works | | ✅

### Login
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 2.1 | Login with wrong password | Error: "Invalid credentials" | | ✅
| 2.2 | Login with unregistered email | Error: "Invalid credentials" | | ✅
| 2.3 | Login with invalid email format | Inline error on email field | | ✅
| 2.4 | Login with empty password | Inline error on password field | | ✅
| 2.5 | Login with correct credentials | Lands on Groups screen | | ✅
| 2.6 | Attempt login 11 times rapidly | Blocked: "Too many attempts. Please try again later." | | 

### Forgot Password
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 3.1 | Enter unregistered email in forgot password | Generic success message (email existence not revealed) | |
| 3.2 | Enter registered email in forgot password | Reset email received | | ✅
| 3.3 | Click reset link in email | Reset password page opens in browser | | ✅
| 3.4 | Enter mismatched passwords on reset page | Error shown on page | | ✅
| 3.5 | Enter weak password on reset page | Error: password requirements shown | | ✅
| 3.6 | Enter valid new password → submit | Success page shown | | ✅
| 3.7 | Login with old password after reset | Fails: "Invalid credentials" | | ✅
| 3.8 | Login with new password after reset | Login successful | | ✅
| 3.9 | Click expired reset link (after 1 hour) | Expired page shown | | ✅

### Profile & Account
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 4.1 | Edit display name | Name updates instantly across the app | | ✅
| 4.2 | Delete account with unsettled balances | Blocked with clear error message | | ✅
| 4.3 | Delete account with all balances settled | Account deleted, redirected to login | |
| 4.4 | Logout | Cache cleared, login screen shown | | ✅
| 4.5 | Login again after logout | Fresh data loaded correctly | | ✅
| 4.6 | Change default split type to Exact | New expenses default to Exact split | | ✅
| 4.7 | Change default split type to Percentage | New expenses default to Percentage split | | ✅

---

## 2. Groups

### Create Group
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 5.1 | Create group with name only | Created with default 🏠 emoji | | ✅
| 5.2 | Create group with custom emoji | Emoji shown correctly everywhere | | ✅
| 5.3 | Create group and add friends | Members added successfully | | ✅
| 5.4 | Create group | Appears in Groups list immediately | | ✅

### Group Settings
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 6.1 | Rename group | Name updates everywhere instantly | | ✅
| 6.2 | Change group emoji | Emoji updates everywhere instantly | | ✅
| 6.3 | Change default split type | New expenses use that split type | | ✅
| 6.4 | Add member by email | Member appears in list | | ✅
| 6.5 | Add member with non-existent email | Clear error message shown | | ✅
| 6.6 | Remove member with unsettled balance | Blocked with clear error | | ✅
| 6.7 | Remove member with zero balance | Removed successfully | | ✅
| 6.8 | Leave group with unsettled balance | Blocked with clear error | | ✅
| 6.9 | Leave group with zero balance | Removed from groups list | | ✅
| 6.10 | Delete group as creator with unsettled balances | Blocked with clear error | | ✅
| 6.11 | Delete group as creator with all settled | Group deleted successfully | | ✅
| 6.12 | Non-creator tries to delete group | Delete option not available | | ✅

---

## 3. Expenses

### Add Expense
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 7.1 | Add expense with equal split | Amounts calculated correctly per member | |
| 7.2 | Add expense with exact split | Custom amounts accepted | |
| 7.3 | Add expense with percentage split totalling 100% | Expense added successfully | |
| 7.4 | Add expense with percentage not totalling 100% | Validation error shown | |
| 7.5 | Add expense with zero amount | Validation error shown | |
| 7.6 | Add expense with empty description | Validation error shown | |
| 7.7 | Add expense | Appears in expense list immediately | |
| 7.8 | Add expense | Group balance updates correctly | |
| 7.9 | Add expense | Activity feed shows new entry | |

### Edit Expense
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 8.1 | Edit expense description | Updates correctly | |
| 8.2 | Edit expense amount | Balances recalculate correctly | |
| 8.3 | Edit expense split type | Splits recalculate correctly | |
| 8.4 | Try to edit a settlement | Blocked — settlements have separate flow | |

### Delete Expense
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 9.1 | Delete expense | Removed from list immediately | |
| 9.2 | Delete expense | Group balance recalculates | |
| 9.3 | Delete expense | Activity feed shows deletion | |

### Split Calculations
| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 10.1 | Equal split among 3 people | Each gets exactly 1/3 of amount | |
| 10.2 | Exact split | Each person gets their specified amount | |
| 10.3 | Percentage split | Amounts match percentages correctly | |
| 10.4 | All split types | Balances on Groups screen match expense details | |

---

## 4. Settle Up

| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 11.1 | Settle full amount | Balance shows zero | |
| 11.2 | Settle partial amount | Balance reduced correctly | |
| 11.3 | Settle from Groups screen | Balance updates on groups screen | |
| 11.4 | Settle from Friends screen | Friend balance updates | |
| 11.5 | Settle | Activity feed shows settlement event | |
| 11.6 | Try to settle more than owed | Blocked — max amount enforced | |
| 11.7 | Edit settlement amount | Balance recalculates correctly | |
| 11.8 | Settlement in expense list | Shows as "Settlement" with correct amount | |

---

## 5. Friends

| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 12.1 | Add friend by email | Appears in friends list | |
| 12.2 | Add non-existent email | Clear error message | |
| 12.3 | Add already existing friend | Clear error message | |
| 12.4 | Friend net balance | Shows correct balance across all shared groups | |
| 12.5 | Remove explicit friend | Removed from friends list | |
| 12.6 | Remove friend in shared group | Appears as group contact only (not removed entirely) | |
| 12.7 | Friend detail screen | Shows shared groups correctly with balances | |

---

## 6. Activity Feed

| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 13.1 | Add expense | Appears in activity feed | |
| 13.2 | Delete expense | Appears in activity feed | |
| 13.3 | Settle up | Appears in activity feed | |
| 13.4 | Add group member | Appears in activity feed | |
| 13.5 | Remove group member | Appears in activity feed | |
| 13.6 | Rename group | Appears in activity feed | |
| 13.7 | Pull to refresh | Fetches latest activity | |
| 13.8 | Scroll to bottom with 30+ items | Load more works correctly | |
| 13.9 | Date grouping | Shows Today, Yesterday, older dates correctly | |

---

## 7. Caching

| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 14.1 | Open Groups → switch tabs → return within 5 mins | Instant load, no spinner | |
| 14.2 | Open Friends → switch tabs → return within 5 mins | Instant load, no spinner | |
| 14.3 | Open Activity → switch tabs → return within 2 mins | Instant load, no spinner | |
| 14.4 | Open Group A → open Group B → return to Group A | Instant load from cache | |
| 14.5 | Add expense → go to Groups screen | Balance updated (cache invalidated correctly) | |
| 14.6 | Settle up → check Friends screen | Friend balance updated | |
| 14.7 | Logout → login → all screens | Fresh data fetched (cache cleared on logout) | |
| 14.8 | Return to Activity after 2+ mins | Silent background refresh (no full spinner) | |

---

## 8. Network & Edge Cases

| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 15.1 | Turn off internet → open app | Error states shown, no crash | |
| 15.2 | Turn off internet → cached screens | Previously loaded data still visible | |
| 15.3 | Slow connection | Loading spinners show on all async operations | |
| 15.4 | Kill app mid-action → reopen | Data consistent, no corruption | |
| 15.5 | Very long group name | Displays correctly without overflow | |
| 15.6 | Very long expense description | Displays correctly without overflow | |
| 15.7 | Large amount (e.g. $99,999.99) | Displays correctly | |
| 15.8 | Zero balance group | Shows "Settled up" correctly | |
| 15.9 | Group with one member | No broken split options | |
| 15.10 | Empty groups list | Empty state shown correctly | |
| 15.11 | Empty friends list | Empty state shown correctly | |
| 15.12 | Empty activity feed | Empty state shown correctly | |

---

## 9. UI & UX

| # | Test Case | Expected Result | Status |
|---|-----------|-----------------|--------|
| 16.1 | All snackbar messages | Correct messages shown for all actions | |
| 16.2 | Loading states | Spinners shown on all async operations | |
| 16.3 | Back navigation | Works correctly on all screens | |
| 16.4 | Bottom sheets | Dismiss correctly everywhere | |
| 16.5 | Keyboard behaviour | Doesn't cover input fields | |
| 16.6 | Long lists | Scroll smoothly without jank | |
| 16.7 | Pull to refresh | Works on all main screens | |
| 16.8 | Portrait mode | All layouts correct | |
| 16.9 | Landscape mode | No broken layouts | |
| 16.10 | Small screen device | Nothing clipped or overflowing | |

---

## 10. Device Testing

| # | Device | OS Version | Status | Notes |
|---|--------|------------|--------|-------|
| 17.1 | Primary Android test device | | | |
| 17.2 | Friend's Android device | | | |
| 17.3 | Android 10 | 10 | | |
| 17.4 | Android 11 | 11 | | |
| 17.5 | Android 12 | 12 | | |
| 17.6 | Android 13 | 13 | | |
| 17.7 | iPhone (via Xcode) | iOS 16+ | | Requires Apple Developer account |

---

## Bug Log

Use this section to track issues found during testing:

| # | Screen | Bug Description | Expected Behaviour | Priority | Fixed |
|---|--------|-----------------|--------------------|----------|-------|
| B1 | | | | High / Medium / Low | ✅ / ❌ |
| B2 | | | | | |
| B3 | | | | | |
| B4 | | | | | |
| B5 | | | | | |

---

## Sign-Off Checklist

Before submitting to stores, confirm all of the following:

- [ ] All High priority bugs fixed
- [ ] All Medium priority bugs fixed or documented
- [ ] Auth flow tested end to end with real emails
- [ ] Tested on minimum 2 different Android devices
- [ ] No `print()` statements in production code
- [ ] API pointing to `api.splittify.app` (not localhost)
- [ ] App name shows "Splittify" on device
- [ ] Privacy policy live at `splittify.app/privacy.html`
- [ ] Release APK builds without errors
- [ ] App icon ready (512x512 Android, 1024x1024 iOS)
- [ ] Screenshots taken (minimum 3)
- [ ] App description written

---

*Splittify QA Checklist — v1.0*
*Generated for pre-submission testing*
