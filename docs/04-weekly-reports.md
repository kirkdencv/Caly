# Weekly reports

One entry per week, newest at the top, written **during** that week. Five minutes
each. They are the record of how the project actually went, and they make your
final reflection almost write itself.

Copy this block:

---

## Week 3 (September 30, 2026 to October 4, 2026)

**Done this week**
- Completed the integrated MVP across the Flutter client and FastAPI backend.
- Added validated food and daily-note models, JSON persistence, demo-session restoration, saved History, goal editing, and sign-out.
- Connected Today to FastAPI and Gemini with asynchronous loading, retry, correction, deletion, undo, and automatic calorie-total updates.
- Changed food logging from a modal form to inline note-style typing with a debounce so unfinished text is not submitted immediately.
- Added Gemini structured output validation, Google Search grounding, timeout handling, API error mapping, and an ungrounded fallback for exhausted search quota.
- Added Flutter and backend tests for API, storage, authentication, journal isolation, corrections, retries, History, and sign-out.
- Refactored large screens into models, services, theme files, utilities, and reusable widgets.
- Added a system dark theme and corrected the CALY wordmark contrast.
- Deployed the Flutter web build through GitHub Pages and configured the FastAPI service for Vercel.
- Connected the Pages build to the deployed backend through the `CALY_API_BASE_URL` repository variable and restricted production CORS to the Pages origin.

**In progress**
- Completing the final documentation, security review, manual browser checks, and public-repository cleanup.
- Verifying the complete deployed flow on both desktop and mobile-sized browser layouts.
- Recording a short demonstration of the final app.

**Blocked or stuck on**
- Gemini initially returned HTTP 503 responses while the API key or provider request was unavailable, so I traced the backend response instead of treating it as a Flutter layout error.
- Vercel initially downloaded `backend/index.py` as a static file because the FastAPI project was not detected; adding `backend/vercel.json` fixed the deployment framework configuration.
- The first GitHub Pages deployment returned 404 until Pages was enabled with GitHub Actions as the publishing source.
- The first dark theme made part of the CALY wordmark too dark, so its neutral letters were changed to use theme-aware contrast.

**Decisions made, and why**
- I kept the Gemini key on the backend and compiled only the public API base URL into Flutter web so visitors cannot extract the billable credential from the app bundle.
- I kept journal entries in local storage because the MVP does not need a shared database or real accounts.
- I used Pydantic and Dart model validation on both sides of the HTTP boundary so malformed AI output cannot silently enter saved journal data.
- I kept failed note text visible and retryable because losing what the user typed would make intermittent backend failures frustrating.
- I used `ThemeMode.system` so Caly follows the device appearance without adding another settings control.

**Hours spent, roughly:**
- Roughly 12 hours across implementation, refactoring, testing, deployment troubleshooting, interface QA, and documentation.

**Next week I will:**
- Run the final manual test checklist against the live Pages and Vercel deployments.
- Finish the README, security checklist, screenshots, and demo video.
- Review the repository diff, create a focused documentation commit, and submit the public repository link.

---

## Week 2 (September 24, 2026 to September 29, 2026)

**Done this week**
- Replaced the starter counter with the Today journal screen from the high-level mockup.
- Added separate Breakfast, Lunch, and Dinner state so entries go to the selected meal only.
- Created the first `FoodEntry` model and calculated the daily calorie total from current entries.
- Added correction behavior so editing an entry immediately recalculates the total.
- Moved meal rendering into a stateless reusable `MealSection` while Today remained the owner of changing journal state.
- Built the first FastAPI endpoint, request and response schemas, validation for blank text, and independent endpoint tests.
- Added the Flutter HTTP service with JSON encoding, response validation, timeouts, and useful errors.
- Introduced `shared_preferences` plus JSON as the MVP persistence approach for journal days and the calorie goal.
- Added the local demo sign-in flow, History screen, Settings screen, and three-tab navigation shell.

**In progress**
- Replacing temporary backend responses with Gemini structured interpretation.
- Making food entry feel like writing a normal note instead of completing a separate form.
- Expanding automated coverage for persistence, authentication, and backend failure states.

**Blocked or stuck on**
- I needed to separate temporary row state from saved entries so loading and failed requests would not be persisted as completed food.
- Browser requests required CORS configuration because Flutter web and FastAPI used different local ports.
- The original Firebase direction added more account and database scope than the MVP needed.

**Decisions made, and why**
- I chose a stable JSON contract between Flutter and FastAPI before adding Gemini so both sides could be tested independently.
- I kept the meal category controlled by Flutter and FastAPI rather than asking Gemini to guess it.
- I chose local JSON persistence over Firebase for the final MVP because it supports saved history without introducing cloud authentication and security rules.
- I made `FoodEntry` immutable and used replacement objects for corrections so state changes remain predictable.

**Hours spent, roughly:**
- Roughly 9 hours across Flutter state work, backend setup, persistence, navigation, and debugging.

**Next week I will:**
- Finish Gemini integration and its validation and failure handling.
- Complete asynchronous inline note logging, retry, correction, and deletion.
- Add end-to-end tests and prepare the web and backend deployments.
- Refactor repeated UI and service responsibilities into smaller files.

---

## Week 1 (September 16, 2026 to September 23, 2026)

**Done this week**
- Cloned and opened the final project repository for Caly.
- Checked my development environment and confirmed I am using Flutter 3.44.4 and Dart 3.12.2.
- Ran `flutter pub get` successfully and generated the `pubspec.lock` file.
- Ran the starter Flutter project using `flutter run -d web-server --web-port 8080`.
- Confirmed that the project works in the browser using Device Preview with an iPhone 13 frame.
- Created a clean baseline commit before making major changes.
- Created a separate branch called `chore/caly-app-shell`.
- Started changing the generic Flutter template into the Caly app.
- Created `lib/theme/caly_theme.dart`.
- Added the first version of the Caly design system using the planned gold, warm paper, ink, muted, outline, and error colors.
- Added Caly's text styles, button styling, and input field styling through `ThemeData`.
- Connected the Caly theme to `MaterialApp`.
- Tested the app again and confirmed that the new theme works without breaking the existing starter counter.

**In progress**
- Replacing the remaining starter project content with the actual Caly interface.
- Cleaning up the app title and starter AppBar.
- Preparing to build the first real Caly screen, the Today food journal screen.
- Continuing to organize the Flutter project into separate files instead of keeping everything in `main.dart`.

**Blocked or stuck on**
- I was not blocked by a major error this week.
- I needed time to understand how `ThemeData`, `MaterialApp(theme:)`, `BuildContext`, and `Theme.of(context)` work before continuing.
- `flutter pub get` showed that some packages have newer versions available, but the current dependencies installed successfully, so I did not update them yet.


**Decisions made, and why**
- I decided to build the Flutter interface first before adding Firebase, FastAPI, or Gemini so I can understand the UI and state flow before adding backend complexity.
- I moved the visual design into `caly_theme.dart` instead of keeping all theme settings inside `main.dart` so the app will be easier to maintain as it grows.
- I kept Device Preview because it lets me test the app using a phone-sized layout while running it in the browser.
- I am keeping each major change in a separate Git branch and commit so the development history is easier to understand and document.

**Hours spent, roughly:**
- Roughly 4 hours since i first read the documentation and asked AI how to structure it and tutor me in using the flutter.

**Next week I will:**
- Build the first version of the Today food journal screen.
- Create the Breakfast, Lunch, and Dinner sections using local Flutter widgets.
- Start separating screens and reusable widgets into their own files.
- Add simple local state for food entries before connecting any backend.
- Continue updating the documentation and AI usage record as development continues.

---
---

## Week N (date to date)

**Done this week**
-

**In progress**
-

**Blocked or stuck on**
-

**Decisions made, and why**
-

**Hours spent, roughly:**

**Next week I will:**
-

---
