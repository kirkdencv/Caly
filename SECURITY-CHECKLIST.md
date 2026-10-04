# Security checklist template

Copy this into your workspace `project/SECURITY-CHECKLIST.md` and fill it in
before you make your project repository public.

Every row gets one of **Yes**, **No** or **N/A**, and one line of evidence in
your own words: what you checked, where, and what you found. "N/A" is a correct
answer when it is true, but it needs its reason. A blank row scores nothing, and
a Yes your repository contradicts scores nothing either.

Replace the example evidence with your own.

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | No | I searched the tracked `lib/` files and found no real API key or token, but `LocalDemoAuthService` intentionally contains the public demonstration password `calyuser123`. It is labelled as demo-only and does not protect private data. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | Yes | I checked `.gitignore` and confirmed that `backend/.env` is ignored while `backend/.env.example` documents the required variables using placeholders. Flutter receives only the non-secret API base URL through `--dart-define`. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | I searched all tracked filenames for `.jks`, `.keystore`, `key.properties`, service-account files, and signing credentials and found none. This repository currently builds Flutter web and has no Android signing configuration. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | I searched the complete Git patch history for credential keywords and key-shaped values. I found documentation, placeholders, variable names, and the intentionally public demo credential, but no real Gemini key, private key, or privileged token. |
| 5 | Any credential that was ever committed has been rotated | N/A | I found no evidence that a real Gemini key or other private credential was committed, so there is currently no exposed credential to rotate. |

## GitHub Actions

If your project has no workflows, mark every row N/A and say so once.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | I checked `.github/workflows/deploy-web.yml`. It contains no literal API key, password, service-account credential, or privileged token. It reads only the public `CALY_API_BASE_URL` repository variable. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | N/A | The Pages workflow does not require a private value. The Gemini key belongs in the Vercel backend environment and is not passed to GitHub Actions or compiled into Flutter. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | No | I found no workflow command that prints a secret, but I have not yet opened and manually reviewed a recent GitHub Actions run log. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | Caly currently has no Android platform directory, signing configuration, or signed-APK workflow. The submitted application is deployed as Flutter web. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The workflow uploads only `build/web`. The web build receives the public FastAPI URL but does not receive `GEMINI_API_KEY`, a keystore, `backend/.env`, or another private server configuration file. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | No | I checked the workflow and found movable version tags: `actions/checkout@v7`, `subosito/flutter-action@v2`, `actions/upload-pages-artifact@v5`, and `actions/deploy-pages@v5`. |
| 12 | Secret scanning and push protection are enabled on the repository | No | I have not yet confirmed Secret scanning and Push protection under the repository's Code security settings. |

## Backend and security rules

If your app is fully local with no backend, mark every row N/A and say so once.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | Caly does not use Firebase, Firestore, or Firebase Storage. Journal entries are stored locally with `shared_preferences`. |
| 14 | Rules restrict a user to their own documents where that makes sense | N/A | Caly has no cloud journal database or server-side user documents, so there are no database ownership rules to configure. |
| 15 | If Supabase: Row Level Security is on for every table | N/A | Caly does not use Supabase or any Supabase tables. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | No | Caly does not use Firebase, but the backend uses a Google Gemini API key. I have not yet verified its API restrictions, usage quota, or billing alerts in Google AI Studio or Google Cloud. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | No | Signing out returns the UI to Sign In, but this is only a local demonstration gate. Journal data remains in browser storage and can be inspected by someone with access to the same browser profile. |
| 18 | Seed and sample data is invented, not real people's data | Yes | I checked `lib/data/demo_journal_seed.dart`, the tests, screenshots, and examples. They use fictional food journals and do not contain a real person's health or nutrition records. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | Flutter prevents empty food drafts from being submitted. FastAPI and Pydantic trim and validate food text, restrict meal categories, validate Gemini output, and reject invalid quantities or calories. Local deserialization also validates saved JSON. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | I checked the Flutter source and Pages workflow. The API base URL and demo credentials are public by design, but the real Gemini key is read only from the FastAPI server environment and is not compiled into the web application. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | No | I found no student number, phone number, or home address in the project files or commit subjects. However, existing Git commit metadata contains my configured author email `kirkdencv14@gmail.com`. The `caly.user@gmail.com` address is fictional demo data. |
| 22 | No classmate's personal data in the repository | Yes | I searched the tracked project files and found no classmate names, student numbers, messages, contact details, or other personal data. The journal seed data is fictional. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | Flutter dependencies are declared in `pubspec.yaml` and come from the Flutter SDK or pub.dev. Python backend dependencies are declared in `backend/requirements.txt`. `.gitignore` excludes `build/`, `.dart_tool/`, `.pytest_cache/`, `backend/.venv/`, and backend environment files. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | No | The repository includes the Caly mascot, square project image, app screenshot, PDFs, and generated diagrams. `AI-USAGE.md` describes the mascot as AI-assisted, but the source and usage rights for every image and submitted PDF are not yet documented together in a complete asset-credit section. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | Yes | The repository is intentionally public at `https://github.com/kirkdencv/Caly`, its `main` branch is reachable from the configured remote, and the Flutter application is published through GitHub Pages. |

## Anything I found and fixed

This review caught that the earlier checklist still described an old workflow configuration. I updated the evidence to reflect the current Pages workflow, its public `CALY_API_BASE_URL` variable, the Vercel-hosted Gemini backend, the missing Android platform, and the newly added project images. The remaining issues are the personal email stored in existing commit metadata, incomplete asset attribution, movable GitHub Action tags, and GitHub or Google security settings that still need manual verification.
