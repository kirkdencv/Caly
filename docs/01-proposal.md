# Proposal

Paste in the proposal you submitted, and replace it with the final version when
the project is done. You do not need to keep it in sync week to week: nobody
reads this folder until you hand the project in.

Keep these headings so a reader can scan it:

[Submitted proposal (PDF)](assets/caly-proposal.pdf)

## The problem, in one sentence

Caly makes calorie tracking feel like writing a normal note: the user types a
food or drink in plain language, and the app estimates and records its calories
without requiring a long database search or multi-step form.

## Who it is for

Caly is for students, young adults, and people new to calorie tracking who want
a quick, low-friction journal. It is especially suited to users who find
traditional nutrition apps too dense or time-consuming and who only need an
understandable calorie estimate rather than clinical nutrition analysis.

## Core features

- A demo sign-in flow with a locally remembered session.
- A note-style Today screen with separate Breakfast, Lunch, and Dinner sections.
- Automatic submission after the user pauses typing, with animated thinking,
  success, failure, and retry states on the affected line.
- A FastAPI service that sends only the food text to Gemini, optionally uses
  Google Search grounding, validates structured results, and returns the meal
  category selected by the app.
- Calorie totals that update when an entry is added, corrected, or removed.
- Swipe-to-delete with undo and a correction sheet for food details and calories.
- Local JSON persistence for journal days, calorie goals, and the demo session.
- Searchable History that opens a saved day for review or correction.
- Settings for the daily calorie goal and demo sign-out.
- Responsive Flutter layouts, system light/dark themes, and a three-tab app shell.

## Out of scope, and why

- Real account authentication, password recovery, and multi-user authorization:
  the current login is explicitly a local classroom demo.
- Cloud synchronization and cross-device journal access: local persistence keeps
  the MVP small and usable without a database.
- Full nutrient and macro tracking: the project focuses on the single calorie
  total promised by the proposal.
- Medical or dietetic advice: AI-generated calories are estimates and should not
  be treated as clinical guidance.
- Voice input, barcode scanning, meal photographs, social features, and trend
  analytics: these would expand the project beyond the final-project timeline.

## Data the app remembers, and where it is saved

| Data | Storage | Purpose |
| --- | --- | --- |
| Journal date, food entries, calories, meal category, and timestamps | JSON in `shared_preferences` on the device/browser | Restore Today and build History |
| Daily calorie goal | `shared_preferences` | Keep the user's chosen target |
| Demo signed-in flag | `shared_preferences` | Restore the local demo session |
| Gemini API key | Server environment only (`backend/.env` locally or Vercel environment variables) | Authorize server-to-server Gemini requests |

Food text is sent over HTTPS to the deployed FastAPI endpoint for interpretation.
The backend does not save a journal database; it returns a validated result to
Flutter, which stores the completed entry locally.

## Risks

- Gemini can return an inaccurate estimate, especially when the amount or brand
  is unclear. Caly labels the result as an estimate and lets the user correct it.
- Gemini, search grounding, network, or provider quota failures can interrupt an
  entry. The row preserves the original text and offers retry.
- The deployed interpretation endpoint is public and currently has no user
  authentication or rate limit, so it is suitable for a supervised demo rather
  than unrestricted production traffic.
- Browser local storage is tied to a browser profile and can be cleared; it is
  not a backup or cross-device account.
- The demo credentials are shipped with the app and are not secure authentication.
- Light and dark themes, small screens, keyboard use, and long food descriptions
  require continued accessibility and responsive-layout testing.

## Changes since the last version

- **2026-09-23:** Established the Flutter project and converted the submitted
  palette and typography into a reusable Material 3 theme.
- **2026-09-27:** Chose `shared_preferences` plus JSON instead of Firebase for the
  MVP so journal data remains local and the persistence flow stays explainable.
- **2026-10-01:** Completed the end-to-end journal flow with FastAPI, Gemini,
  local history, demo login, settings, and automated tests.
- **2026-10-04:** Added GitHub Pages and Vercel deployment configuration, system
  dark mode, stronger input validation, and a clearer note-style interaction.

_(A few dated lines saying what changed and why. Worth writing even if you only
do it two or three times: it is the part that shows judgement.)_
