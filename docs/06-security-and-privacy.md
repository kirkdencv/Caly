# Security and privacy

This repository is public. Fill this in honestly and date it; it is checked as
part of grading.

**Last checked:** 2026-10-04

## What this app stores

| Data | Where it lives | Who can see it |
| --- | --- | --- |
| Food journal dates, entries, meal categories, calories, and timestamps | JSON in `shared_preferences` in the device or browser profile | Anyone with access to that local device/browser profile |
| Daily calorie goal | `shared_preferences` in the device or browser profile | Anyone with access to that local device/browser profile |
| Demo signed-in flag | `shared_preferences` in the device or browser profile | Anyone with access to that local device/browser profile |
| Food text being interpreted | Sent over HTTPS to FastAPI, then to Gemini; it is not stored in a Caly server database | The user, the deployed backend, and the AI provider while processing the request |

## Secrets

- Values my app needs at run time: `GEMINI_API_KEY`, `GEMINI_MODEL`,
  `GEMINI_TIMEOUT_SECONDS`, `CALY_ALLOWED_ORIGINS`, and `CALY_API_BASE_URL`.
  Only `GEMINI_API_KEY` is a secret.
- Where they live locally: backend values live in `backend/.env`, which is
  git-ignored. Flutter uses the non-secret API URL through
  `--dart-define=CALY_API_BASE_URL=...`.
- Where the deploy workflow gets them: Vercel stores the Gemini key, model,
  timeout, and allowed frontend origin as project environment variables. GitHub
  Actions reads the public `CALY_API_BASE_URL` from a repository variable in
  Settings > Secrets and variables > Actions.
- Anything my deployed web build carries that a visitor could read, and why that
  is acceptable: the Vercel API base URL is compiled into the web build. It is
  intentionally public because browsers need it to call the service. The Gemini
  key is never compiled into Flutter and remains in the backend environment.
- The local demo email and password are constants shipped in the client. They are
  public demo credentials, not a secret or secure authentication mechanism.

## What protects the data on the service side

- Firestore rules / Supabase RLS policies: N/A. Caly uses neither Firebase nor
  Supabase and has no server-side journal database.
- Saved journal data, the calorie goal, and the demo session stay in local
  `shared_preferences`. Only the food text leaves the device for interpretation.
- FastAPI validates food text length and meal values with Pydantic, keeps the
  Gemini key server-side, validates Gemini's structured response, applies
  timeouts, and permits browser CORS requests only from configured production
  origins and local development origins.
- CORS is not authentication. The interpretation route is publicly reachable
  and currently has no user authentication or rate limiting, so this deployment
  is a classroom demonstration and not a production public API.
- Gemini results are estimates. Users can correct or remove an entry before
  relying on the saved total.

## Checklist

- [x] `.env` (or `env.json`) is in `.gitignore`, and `.env.example` is committed
- [x] `git log -p | grep -i "api_key\|secret\|password\|token"` finds nothing real; matches are placeholders, variable names, documentation, and the disclosed demo-only password
- [x] No service account file, keystore or `service_role` key anywhere in the repo
- [x] Security rules or RLS policies written and tested, not left open - N/A because Caly has no Firestore, Supabase, or server-side journal database
- [x] No real personal data in sample data, screenshots or the video
- [x] No course or university credentials anywhere
- [x] Anyone whose data appears in a test was asked first - N/A because all test and sample people/data are invented

If you found and revoked a key while doing this, say so here. Catching it is the
right outcome, not an embarrassment.

No live credential was found during this check, so no key needed to be revoked.
The scan did find the intentional demo password and environment-variable names;
they are documented above and are not used as private production credentials.
