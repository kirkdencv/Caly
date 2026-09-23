# CALY

> Caly is a simple calorie tracking app that makes food logging feel more like writing a normal note. It is designed for people who want to track their calorie intake without using a complicated food logging interface.

**Live demo:** https://kirkdencv.github.io/Caly/

**Demo video:** Not available yet.

**Course:** Applications Development and Emerging Technologies (6ADET), Holy Angel University

This repository is public for the final project. No student number, email address, passwords, API keys, or other private information should be committed to this repository.

See `docs/06-security-and-privacy.md` for the project's security and privacy checklist.

---

## Screenshots

The project is still in development.

The current Flutter application shell and Caly theme are working. Screenshots of the completed screens will be added as each screen is implemented.

Current development screenshot:

```md
![Caly app shell](docs/assets/caly-app-shell.png)
```

Planned screenshots will include:

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
- Uses shared colors, typography, button styles, and input styles.

### Planned main features

- Log food under Breakfast, Lunch, or Dinner.
- Show the calorie value beside each food entry.
- Calculate the total calories for the day.
- Edit an incorrect food or calorie entry.
- View previously saved daily food notes.
- Sign in and save journal data to a user account.

The food logging and backend features are not implemented yet.

---

## Built with

| | |
| --- | --- |
| Framework | Flutter (Dart) |
| Flutter version | 3.44.4 |
| Dart version | 3.12.2 |
| State | `setState` for the current starter application; Caly's state structure will be developed as the app grows |
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

The current Flutter app shell does not require any environment variables.

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

Secrets such as API keys must not be committed to the repository. Local secrets will be stored outside the tracked source code, and server-side secrets will remain on the backend.

All sample data, screenshots, and the final demo should contain no real passwords, API keys, student numbers, email addresses, or other private information.

---

## Project documentation

| Document | |
| --- | --- |
| [Proposal](docs/01-proposal.md) | the problem, users, scope, and planned architecture |
| [Mockup and wireframes](docs/02-mockup.md) | the planned screens and user flow |
| [Design system](docs/03-design-system.md) | Caly's colors, typography, spacing, and components |
| [Weekly reports](docs/04-weekly-reports.md) | development progress for each week |
| [Demo video](docs/05-demo-video.md) | the final recording and what it demonstrates |
| [Start here](START-HERE.md) | instructions included with the course template |
| [Security and privacy](docs/06-security-and-privacy.md) | security and privacy checklist |

---

## Status and what is next

### Working

- Flutter project runs successfully.
- Dependencies install successfully using `flutter pub get`.
- Device Preview works.
- The Caly color scheme is connected to the Flutter application.
- The Caly typography system is connected.
- Shared `FilledButton` styling is working.
- Shared input field styling has been prepared.
- The project has a clean development baseline in Git.

### In progress

- Replacing the original starter application with the actual Caly interface.
- Building the first version of the Today's Food Note screen.
- Organizing the Flutter project into separate screens and reusable widgets.

### Not implemented yet

- Sign In and Registration
- Breakfast, Lunch, and Dinner food logging
- Daily calorie calculation
- Food Correction
- History
- Settings
- Firebase Authentication
- Cloud Firestore
- FastAPI backend
- Gemini integration
- Complete navigation
- Final screenshots
- Demo video

### Next development step

The next step is to build the Today's Food Note screen using Flutter with local data first.

The planned order after that is:

1. Today screen layout
2. Meal sections
3. Local food entry state
4. Daily calorie calculation
5. Other main screens
6. Navigation
7. Firebase Authentication
8. Cloud Firestore
9. FastAPI
10. Gemini
11. Full integration
12. Testing and polish

---

## Credits

- Flutter and Dart
- `device_preview` package
- Other packages will be added here when they are actually used.
- Any external assets, icons, images, or other resources will be credited here with their source and licence.

---

## AI use

![Built with AI assistance](https://img.shields.io/badge/built%20with-AI%20assistance-0b5fff)

ChatGPT was used as a development and learning assistant during the project. It was used to help explain Flutter concepts, review project structure, plan development steps, and support documentation.

The application is being developed and tested by the student, while AI assistance is documented throughout the project.

See [AI-USAGE.md](AI-USAGE.md) for the full record of AI assistance.

---

## Licence

MIT, see [LICENSE](LICENSE).
