# Weekly reports

One entry per week, newest at the top, written **during** that week. Five minutes
each. They are the record of how the project actually went, and they make your
final reflection almost write itself.

Copy this block:

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
