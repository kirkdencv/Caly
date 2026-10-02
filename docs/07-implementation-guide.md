# Caly implementation guide

This guide explains the current Flutter code and the numbered `TODO(Caly)`
comments. Complete the phases in order. Keep the app working after each small
step before moving on.

## How the current code works

### Application start

`lib/main.dart` checks the local demo session, calls `runApp`, enables Device
Preview, creates `MaterialApp`, and opens either `SignInScreen` or
`AppShellScreen`.

```text
main()
  -> MyApp
  -> SignInScreen
  -> AppShellScreen
  -> Today / History / Settings
```

### Sign in

`SignInScreen` owns two `TextEditingController` objects. It validates both
fields, displays loading and error states, and asks `LocalDemoAuthService` to
compare the credentials. Only a successful match saves the local session and
opens `AppShellScreen`. This is a demo gate, not secure authentication.

### Signed-in shell

`AppShellScreen` owns `_selectedIndex`. Tapping the navigation bar calls
`setState`, which selects a child in `IndexedStack`. `IndexedStack` preserves
inactive screens, so their local state is not recreated after every tab change.

### Today and food entries

`TodayScreen` is stateful because its three meal lists change. Each `FoodEntry`
keeps the typed text, interpreted name, quantity, unit, calories, and selected
meal in one object. `_entriesForMeal` selects the owned list, while `_allEntries`
combines them for `_totalCalories` to sum with `fold`.

```text
TodayScreen entries -> MealSection -> FoodEntryRow
TodayScreen callback <- note typing, retry, or calorie tap
```

Each meal exposes an inline text line instead of an Add Food dialog. TodayScreen
debounces typing for 1,200 milliseconds and keeps the draft visible while the
request is running. Pressing Enter submits immediately. If typing resumes, the
old response is ignored; only a response that still matches the latest draft can
be logged. Three animated dots appear beside the draft until FastAPI returns.

Tapping a calorie opens `FoodCorrectionSheet` with `showModalBottomSheet`. The
sheet returns a new `FoodEntry` through `Navigator.pop`. Today replaces the
matching entry, rebuilds, and recalculates the total.

### History and settings

`HistoryScreen` loads saved `DailyNote` objects, sorts them newest-first, and
filters that loaded list locally. Selecting a row sends its date to
`AppShellScreen`, which rebuilds Today for that date. Settings and Today share
the persisted calorie goal.

## Phase 1 - Local behavior complete

- [x] DateTime source of truth and formatted Today date
- [x] Separate Breakfast, Lunch, and Dinner entry lists
- [x] Meal-specific inline note callbacks
- [x] Validated local food and calorie input
- [x] FoodEntry objects for local state
- [x] Food name and calorie row display
- [x] Calculated daily total
- [x] Correction updates the row and total
- [x] Entries rendered inside MealSection
- [x] Stateless MealSection with TodayScreen owning state
- [x] Finalized local FoodEntry fields

## Phase 2 - FastAPI foundation complete

- [x] FastAPI application and health check
- [x] `POST /api/v1/foods/interpret`
- [x] Pydantic request and response models
- [x] Deterministic fake food response
- [x] Whitespace-only food validation
- [x] Independent endpoint tests

```text
POST /api/v1/foods/interpret
request:  { "text": "1 cup rice", "meal": "breakfast" }
response: {
  "originalText": "1 cup rice",
  "foodName": "White rice, cooked",
  "quantity": 1,
  "unit": "cup",
  "calories": 200,
  "mealCategory": "breakfast"
}
```

The implementation and run instructions live in `backend/README.md`.

## Phase 3 - Flutter to FastAPI connection complete

- [x] Added the `http` package
- [x] Created injectable `FoodApiService` and `interpretFood()`
- [x] Encoded the request as JSON and sent it with HTTP POST
- [x] Checked the status before decoding the response
- [x] Added timeout, network, non-200, malformed JSON, and invalid-field errors
- [x] Implemented validated `FoodEntry.fromJson()`
- [x] Made food submission asynchronous
- [x] Added loading, success, error, and retry states per food row
- [x] Preserved typed text after a failed request
- [x] Added Flutter service and widget tests
- [x] Enabled local-development CORS in FastAPI

Flutter remains responsible for the selected meal; the backend must not choose
Breakfast, Lunch, or Dinner.

## Phase 4 - Gemini behind FastAPI complete

- [x] Added an ignored `backend/.env` and safe `.env.example`
- [x] Added the official Google Gen AI SDK
- [x] Created an injectable Gemini food service
- [x] Sent only food text as model content
- [x] Kept meal selection under Flutter/FastAPI control
- [x] Requested structured food fields with a Pydantic schema
- [x] Enabled Google Search grounding for more accurate nutrition lookup
- [x] Falls back to an ungrounded estimate when search quota is unavailable
- [x] Parsed and validated model output again before returning it
- [x] Cleaned valid numeric strings and rejected invalid quantities/calories
- [x] Preserved the existing Flutter response contract
- [x] Mapped configuration, timeout, API, and invalid-output failures cleanly
- [x] Added isolated tests that do not call Gemini or consume quota

Keeping the contract unchanged means Flutter does not care whether FastAPI is
returning a fake result or a Gemini result.

## Phase 5 - Local demo login complete

- [x] Kept Sign In as the initial screen without a saved session
- [x] Restored an optional saved demo session on startup
- [x] Added login loading and error states
- [x] Validated that email and password are not empty
- [x] Compared input with the documented demo credentials
- [x] Opened `AppShellScreen` only for matching credentials
- [x] Displayed an invalid-credentials message for a mismatch
- [x] Displayed the demo email and account type in Settings
- [x] Cleared the local session before returning to Sign In
- [x] Added service and widget tests using in-memory session storage

The saved preference contains only a boolean session flag. The password is
never written to preferences. Because the credentials ship inside the app,
this remains demonstration behavior and must not protect private user data.

## Phase 6 - Local persistence complete

- [x] Added `shared_preferences` as a direct dependency
- [x] Added validated `FoodEntry.toMap()` and `FoodEntry.fromMap()`
- [x] Created `DailyNote` with date, entries, total, and timestamps
- [x] Added validated `DailyNote.toMap()` and `DailyNote.fromMap()`
- [x] Created a JSON-backed `LocalStorageService`
- [x] Added save, date lookup, load-all, update, and delete operations
- [x] Added persistent calorie-goal operations
- [x] Consolidated the demo-session flag into the same storage service
- [x] Loaded saved entries and goal when Today starts
- [x] Saved successful additions and corrected entries
- [x] Loaded and saved the goal from Settings
- [x] Added model, service, corruption, and widget persistence tests

The JSON journal is stored under one versioned preferences key and indexed by
`yyyy-MM-dd`. Loading validates every note and entry. Loading/error UI rows are
transient; only successfully interpreted entries are written.

## Phase 7 - Saved history complete

- [x] Replaced mock rows with locally saved `DailyNote` objects
- [x] Sorted saved notes by date descending
- [x] Kept search local to the loaded notes
- [x] Displayed saved dates, food summaries, and calorie totals
- [x] Passed the selected date through `AppShellScreen`
- [x] Loaded the selected historical day in Today
- [x] Saved corrections back to the selected historical date
- [x] Refreshed History after journal changes
- [x] Added sorting, filtering, selection, and historical-edit tests

## Phase 8 - Tests and final checks

Complete TODO 8.1 one behavior at a time:

1. Empty food text is not submitted.
2. Adding Lunch does not change Breakfast or Dinner.
3. Totals update after adding and correcting food.
4. Cancel leaves an entry unchanged.
5. Backend failure preserves the typed text and shows Retry.
6. Signing out returns to Sign In.
7. Local JSON survives rebuilding the relevant screens.

Run after every small change:

```text
dart format lib test
flutter analyze
flutter test
```

## Recommended next coding task

Begin Phase 8 by completing the remaining behavior tests, screenshots, security
review, and demo preparation.
