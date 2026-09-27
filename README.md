# CALY

> Caly is a simple calorie tracking app that makes food logging feel more like writing a normal note. It is designed for people who want to track their calorie intake without using a complicated food logging interface.

**Live demo:** https://kirkdencv.github.io/Caly/

**Demo video:** Not available yet.

**Course:** Applications Development and Emerging Technologies (6ADET), Holy Angel University

This repository is public for the final project. No student number, personal email address, passwords, API keys, or other private information should be committed to this repository.

See `SECURITY-CHECKLIST.md` and `docs/06-security-and-privacy.md` for the current security and privacy documentation.

---

## Screenshots

The project is still in development.

The current version includes the first working Today food journal screen, reusable meal sections, and local Breakfast state.

Add the latest development screenshot here after saving it inside `docs/assets/`.

Example:

```md
![Caly Today screen](docs/assets/caly-today-screen.png)
```

Planned final screenshots will include:

- Sign In
- Today's Food Note
- Food Correction
- Food History
- Settings

---

## What it does

Caly is currently in development.

### Currently working

- Runs as a Flutter web application.
- Uses Device Preview to display the app in a phone-sized layout.
- Uses a custom Caly light theme.
- Uses shared colors, typography, spacing, button styles, and input styles.
- Displays the first version of the Today food journal screen.
- Displays Breakfast, Lunch, and Dinner using a reusable `MealSection` widget.
- Uses callbacks so `MealSection` can report an `Add food...` tap back to `TodayScreen`.
- Uses `StatefulWidget`, `setState()`, and a local `List<String>` to store temporary Breakfast food entries.
- Renders local Breakfast entries from the current list state.
- Displays the current daily total placeholder as `0 kcal`.

### In development

- Separate local food lists for Breakfast, Lunch, and Dinner.
- Passing food entries into the reusable `MealSection`.
- Replacing temporary hard-coded food entries with real user input.
- Adding calorie values and daily calorie calculation.

### Planned main features

- Log food under Breakfast, Lunch, or Dinner.
- Show the calorie value beside each food entry.
- Calculate the total calories for the day.
- Edit an incorrect food or calorie entry.
- View previously saved daily food notes.
- Sign in and save journal data to a user account.

Firebase, FastAPI, Gemini, and persistent food storage are not connected yet.

---

## Built with

| | |
| --- | --- |
| Framework | Flutter (Dart) |
| Flutter version | 3.44.4 |
| Dart version | 3.12.2 |
| State | Local Flutter state using `StatefulWidget` and `setState()` |
| Storage | Not connected yet. Firebase Authentication and Cloud Firestore are planned |
| Backend | Not implemented yet. FastAPI is planned |
| AI | Not connected yet. Gemini is planned for interpreting food input and returning calorie information |
| Other packages | `device_preview` — used to preview the Flutter app at phone size in the browser |

---

## Running it yourself

Make sure Flutter is installed first:

```bash
flutter --version
```

The version currently used to develop Caly is:

```text
Flutter 3.44.4
Dart 3.12.2
```

Clone the repository:

```bash
git clone https://github.com/kirkdencv/Caly.git
cd Caly
```

Install the dependencies:

```bash
flutter pub get
```

Run the Flutter web application:

```bash
flutter run -d web-server --web-port 8080
```

Then open:

```text
http://localhost:8080
```

When it is working, the application should appear inside Device Preview using a phone-sized layout.

---

### Environment variables

The current Flutter version of Caly does not require runtime environment variables.

Firebase, FastAPI, and Gemini have not been connected yet.

When backend configuration is added later, real API keys and secrets will not be committed to this repository. Example configuration values will be documented using placeholders only.

The planned architecture is:

```text
Flutter
   |
   | HTTP request
   v
FastAPI
   |
   v
Gemini API

Firebase Authentication + Cloud Firestore
will handle user accounts and saved journal data.
```

The Gemini API key will stay on the FastAPI server and will not be placed inside the Flutter application.

---

## Privacy and secrets

The current development version does not store real user information.

Firebase Authentication and Cloud Firestore are planned for account and journal storage later in development. When they are implemented, access to stored data will be controlled using Firebase security rules.

Secrets such as API keys must not be committed to the repository. Local secret files are excluded through `.gitignore`, and server-side secrets will remain on the backend.

The current security review found no hardcoded API key, token, or password in the tracked `lib/` files and no tracked keystore or signing credential. Git history searches found only documentation, comments, and placeholder values rather than real credentials.

All sample data, screenshots, and the final demo should contain no real passwords, API keys, student numbers, personal email addresses, or other private information.

---

## Project structure

Current important Flutter files:

```text
lib/
├── main.dart
├── screens/
│   └── today_screen.dart
├── theme/
│   ├── caly_theme.dart
│   └── caly_spacing.dart
└── widgets/
    └── meal_section.dart
```

### `lib/main.dart`

Starts the Flutter application, configures Device Preview, creates `MaterialApp`, and connects the Caly theme and current home screen.

### `lib/theme/caly_theme.dart`

Contains Caly's color scheme, typography, button styling, input styling, and other shared theme settings.

### `lib/theme/caly_spacing.dart`

Contains the shared spacing scale used by the interface: `xs`, `sm`, `md`, `lg`, and `xl`.

### `lib/screens/today_screen.dart`

Contains the current Today food journal screen and owns the temporary local Breakfast state.

### `lib/widgets/meal_section.dart`

Reusable widget for Breakfast, Lunch, and Dinner. It receives the meal name and an `onAddFood` callback from its parent.

---

## Project documentation

| Document | |
| --- | --- |
| [Proposal](docs/01-proposal.md) | the problem, users, scope, and planned architecture |
| [Mockup and wireframes](docs/02-mockup.md) | the planned screens and user flow |
| [Design system](docs/03-design-system.md) | Caly's colors, typography, spacing, and components |
| [Weekly reports](docs/04-weekly-reports.md) | development progress for each week |
| [Demo video](docs/05-demo-video.md) | the final recording and what it demonstrates |
| [Security and privacy](docs/06-security-and-privacy.md) | privacy and security documentation |
| [Security checklist](SECURITY-CHECKLIST.md) | security checks and current evidence |
| [AI usage](AI-USAGE.md) | the record of AI assistance during development |

---

## Status and what is next

### Working

- Flutter project runs successfully.
- Dependencies install successfully using `flutter pub get`.
- Device Preview works.
- The Caly color scheme and typography are connected to the application.
- Shared spacing values are available through `caly_spacing.dart`.
- Shared `FilledButton` and input styling are prepared.
- The Today screen has been created.
- Breakfast, Lunch, and Dinner use the reusable `MealSection` widget.
- `MealSection` uses a callback for the `Add food...` action.
- `TodayScreen` uses local state with `setState()`.
- Breakfast currently stores and displays temporary food entries using `List<String>`.

### In progress

- Passing food lists into `MealSection` so each meal section owns its display layout while `TodayScreen` continues to own the state.
- Separating Breakfast, Lunch, and Dinner state.
- Replacing hard-coded test food with actual user input.
- Adding a proper food entry model.
- Adding calorie values and calculating the daily total.
- Continuing to compare the Today screen with the Caly mockup.

### Not implemented yet

- Real food text input
- Food calorie values
- Daily calorie calculation
- Sign In and Registration
- Food Correction
- History
- Settings
- Complete navigation
- Firebase Authentication
- Cloud Firestore
- FastAPI backend
- Gemini integration
- Persistent journal data
- Final screenshots
- Demo video

### Next development step

The next development step is to pass the Breakfast food list into `MealSection`, then create separate local state for Breakfast, Lunch, and Dinner.

After the local meal state works correctly, the next steps are:

1. Add real food text input
2. Create a proper food entry model
3. Add calorie values
4. Calculate the daily total
5. Build the remaining core screens
6. Add navigation
7. Add Firebase Authentication
8. Add Cloud Firestore
9. Build the FastAPI backend
10. Connect FastAPI to Gemini
11. Connect the complete Flutter food logging flow
12. Test, polish, document, and deploy

---

## Credits

- Flutter and Dart
- `device_preview` package
- Other packages will be added here when they are actually used.
- Any external assets, icons, images, or other resources will be credited here with their source and licence.

---

## AI use

![Built with AI assistance](https://img.shields.io/badge/built%20with-AI%20assistance-0b5fff)

ChatGPT was used as a development and learning assistant during the project. It was used to explain Flutter concepts, review project structure, guide development steps, help identify errors, and support documentation.

The application is being developed and tested by the student, while AI assistance is documented throughout the project.

See [AI-USAGE.md](AI-USAGE.md) for the full record of AI assistance.

---

## Licence

MIT, see [LICENSE](LICENSE).
