# AI usage

This project was built with AI assistance. This file is the record of how I used AI during development, what I kept or changed, and what I learned from checking the AI's suggestions.

I am updating this file while I build the project instead of writing it all at the end.

---

## 1. How I used AI

### 2026-10-02 - Auditing the public repository and commit structure

- **Tool:** ChatGPT / Codex
- **What I asked for:** I asked for help reviewing the unusually large MVP commit, adopting consistent `feat:`, `fix:`, `docs:`, `test:`, and `chore:` naming, and keeping the README and AI record aligned with the real development timeline.
- **What it gave back:** The review confirmed that the 4,731-line, 41-file commit had already been merged publicly through pull request 3. It recommended preserving that public history, documenting a Conventional Commits standard, and splitting the current working tree by responsibility instead of backdating or force-rewriting merged commits.
- **What I kept, what I changed, and why:** I kept the public merge intact so existing pull-request links remain valid. I split the current work into focused backend, Today, visual-system, History, test, and documentation commits. I added `CONTRIBUTING.md` and corrected outdated README architecture details.
- **Commits:** `feat(backend): add grounded calorie lookup fallback`, `feat(today): refine note-style food logging`, `feat(ui): refresh Caly branding and theme`, `feat(history): group saved food notes`, `test(ui): cover journal interaction regressions`, and `docs: document development and commit conventions`

### 2026-10-02 - Improving the notes-style interface and QA coverage

- **Tool:** ChatGPT / Codex
- **What I asked for:** I asked for a complete UI and usability pass that kept Caly simple, note-like, and consistent with the calico branding.
- **What it gave back:** It helped identify premature food submission, stale asynchronous responses, accidental deletion risk, narrow-screen overflow, stale unit handling, History readability, dark-mode gaps, and missing regression coverage.
- **What I kept, what I changed, and why:** I kept the inline note interaction, added a 1.2-second debounce with stale-response protection, swipe-to-delete with Undo, editable serving units, a compact calorie summary, grouped History, system dark mode, and a simplified branded login. I verified the result with 35 Flutter tests, 25 backend tests, static analysis, and a release web build.
- **Commits:** [Today interaction](https://github.com/kirkdencv/Caly/commit/39d69968bb943bc62c36aa250d27871f2cb31e5e), [visual system](https://github.com/kirkdencv/Caly/commit/bcf55085c01a644944084a2186fed02535692bf0), [History](https://github.com/kirkdencv/Caly/commit/1c97c1624ae526cf2436ee19893112c4963ff171), and [UI tests](https://github.com/kirkdencv/Caly/commit/af081ebc4e5068573e6b1359644fd538ebdcac19)

### 2026-10-02 - Adding grounded calorie lookup with a safe fallback

- **Tool:** ChatGPT / Codex
- **What I asked for:** I asked how Caly could try to use current web nutrition information while still returning a useful estimate when Gemini search quota is unavailable.
- **What it gave back:** It suggested enabling Google Search grounding for the food interpretation request and retrying once without search only when the grounding request returns a quota error.
- **What I kept, what I changed, and why:** I kept the API response contract unchanged, added a targeted 429 fallback, and added backend tests that verify both grounded requests and the ungrounded fallback.
- **Commit:** [feat(backend): add grounded calorie lookup fallback](https://github.com/kirkdencv/Caly/commit/66a7586236bebcd279207fc29c90b0fbbd931fae)

### 2026-10-01 - Completing and reviewing the integrated MVP

- **Tool:** ChatGPT / Codex
- **What I asked for:** I asked for help completing the remaining phases, testing the combined Flutter and FastAPI flow, and reviewing whether the repository was safe to publish.
- **What it gave back:** It helped connect the food-entry flow, Gemini-backed FastAPI route, local persistence, History, demo login, Settings, and test coverage. It also identified that secrets must remain in the ignored backend `.env` file.
- **What I kept, what I changed, and why:** I completed the connected MVP, kept the Gemini key exclusively on the backend, and retained local JSON persistence for the classroom demo. The resulting integration was too large for one ideal commit, which is why later work follows the focused commit standard in `CONTRIBUTING.md`.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-30 - Debugging backend failures and preparing final tests

- **Tool:** ChatGPT
- **What I asked for:** I asked for help understanding FastAPI `503 Service Unavailable` responses from the food interpretation endpoint and for guidance on testing empty input, meal isolation, totals, correction, persistence, History, retry, and demo login behavior.
- **What it gave back:** It explained that the successful CORS `OPTIONS` response only confirmed browser permission, while the failing `POST` came from the Gemini/backend path. It also helped translate the required behaviors into independent service and widget tests.
- **What I kept, what I changed, and why:** I kept the user-facing retry flow, preserved typed food text after backend failures, and added regression coverage before treating the MVP as complete.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-29 - Connecting the completed TODO phases

- **Tool:** ChatGPT
- **What I asked for:** I asked for guidance while connecting the different parts of Caly after completing the TODOs from the revised phases.
- **What it gave back:** ChatGPT helped me understand how the local Flutter state, food models, FastAPI requests, Gemini responses, persistent journal storage, History screen, Settings screen, and local demo login fit together as one application flow.
- **What I kept, what I changed, and why:** I used the explanations to connect the parts I had implemented and to understand which layer is responsible for each task. Flutter handles the interface and local application state, local persistent storage keeps journal data between sessions, FastAPI handles the backend request, and Gemini interprets food information.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-29 - Working through the FastAPI and Gemini TODOs

- **Tool:** ChatGPT
- **What I asked for:** I asked ChatGPT to tutor me through the FastAPI and Gemini phases instead of writing the complete backend integration for me.
- **What it gave back:** ChatGPT explained FastAPI routes, request and response models, JSON, Pydantic validation, HTTP status codes, `async` behavior, environment variables, API secrets, structured Gemini output, and the request flow between Flutter, FastAPI, and Gemini.
- **What I kept, what I changed, and why:** I used the explanations and TODO structure to work through the backend tasks myself. ChatGPT assisted with the architecture, concepts, debugging, and review, while I worked on the implementation and integration. I kept the Gemini API behind FastAPI so the API key is not stored inside the Flutter application.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-29 - Implementing the local demo login

- **Tool:** ChatGPT
- **What I asked for:** I asked how I could keep the Sign In screen for the project without adding Firebase Authentication.
- **What it gave back:** ChatGPT explained how a simple local credential check could be used for a classroom demo and clearly explained that it should not be described as secure or production authentication.
- **What I kept, what I changed, and why:** I implemented a demo login that checks the entered credentials against the Caly demo account. I kept the login module because it preserves the intended application flow, but I documented it as a local demo login instead of claiming that it provides real authentication.
- **Demo email:** `caly.user@gmail.com`
- **Demo password:** `calyuser123`
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-28 - Implementing local persistent journal storage

- **Tool:** ChatGPT
- **What I asked for:** I asked ChatGPT to teach me how local persistence should work in Caly and how the existing `FoodEntry` and daily journal data could be saved without Firebase.
- **What it gave back:** ChatGPT explained the difference between in-memory state and persistent storage, and explained the flow of converting Dart objects into maps and JSON before saving them locally. It also explained how saved data can be decoded and converted back into model objects when the application starts again.
- **What I kept, what I changed, and why:** I implemented the local persistence flow for the Caly journal instead of relying only on temporary lists. I used the model and serialization concepts that were explained to me and connected the saved data to the Today, History, and Settings behavior required by the MVP.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-28 - Changing the storage architecture from Firebase to local persistence

- **Tool:** ChatGPT
- **What I asked for:** I discussed how Caly should store journal data and handle login for the final MVP because I only had a short amount of development time left.
- **What it gave back:** The earlier implementation plan was designed around Firebase Authentication and Cloud Firestore for user accounts and persistent journal storage.
- **What I kept, what I changed, and why:** I decided not to use Firebase for the final MVP. I corrected the planned architecture and changed Caly to use local persistent storage instead. I also replaced Firebase Authentication with a local demo login using fixed demo credentials. I made this change because Caly is being demonstrated as a single-user notes-style calorie tracker, and local persistence was simpler and more realistic to complete, understand, and test within the remaining project time.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-28 - Completing the new Caly implementation phases

- **Tool:** ChatGPT
- **What I asked for:** I asked ChatGPT to continue tutoring me through the new Caly implementation phases and TODO list. I wanted the project to be completed phase by phase while still letting me write and understand important parts of the Flutter code, FastAPI backend, Gemini integration, local persistence, and app behavior.
- **What it gave back:** ChatGPT first helped create the project skeleton and development structure, including the screens, reusable widgets, models, TODO comments, and the order of the implementation phases. After the skeleton was available, ChatGPT guided me through the TODO items by explaining the concepts, expected behavior, data flow, and what each part of the application was responsible for.
- **What I kept, what I changed, and why:** I used the skeleton and TODO structure as a guide, but I worked through and completed the implementation tasks myself while asking ChatGPT for explanations and debugging help when I reached concepts I did not understand yet. This helped me continue developing the project while still understanding how the different parts work instead of only copying finished code.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

### 2026-09-27 - Reviewing the project security checklist

- **Tool:** ChatGPT
- **What I asked for:** I asked ChatGPT to help me work through the course security checklist using my current GitHub Actions workflow, `.gitignore`, and repository checks.
- **What it gave back:** It explained which checklist items could already be answered and which ones still needed to be verified. It also gave me commands to search for hardcoded secrets, signing files, and credential-related terms in Git history.
- **What I kept, what I changed, and why:** I ran the checks myself and used the actual terminal results as evidence. The searches found no secret-related matches inside `lib/`, no tracked keystore or signing files, and only documentation or placeholder text in the Git history instead of real credentials. I kept unverified items as No or N/A instead of marking them Yes without evidence.
- **Commit:** [Updated project documentation](https://github.com/kirkdencv/Caly/commit/341a231)

### 2026-09-27 - Learning local food state with List and setState

- **Tool:** ChatGPT
- **What I asked for:** I asked how to move from one temporary Breakfast food String to storing multiple food entries on the Today screen.
- **What it gave back:** ChatGPT explained how a `List<String>` can hold multiple entries, why the list can still be modified when the variable is declared `final`, how `setState()` triggers a rebuild, and how a collection `for` can create one widget for each stored food.
- **What I kept, what I changed, and why:** I replaced the single Breakfast food value with `final List<String> _breakfastFoods = [];`, added `"1 cup of rice"` to the list inside `setState()`, and rendered each item using a collection `for` in the widget tree. I kept the hardcoded rice value only as a temporary local-state test before adding real food input.
- **Commit:** [feat: add local breakfast state](https://github.com/kirkdencv/Caly/commit/2e6403fa30ef5d1c8090e4c8190b9ff4804929e6)

### 2026-09-25 - Creating a reusable MealSection widget

- **Tool:** ChatGPT
- **What I asked for:** I asked how I should avoid repeating the same Breakfast, Lunch, and Dinner layout on the Today screen.
- **What it gave back:** ChatGPT explained reusable widgets, constructor parameters, `VoidCallback`, and how a parent widget can pass both data and behavior down to a child widget.
- **What I kept, what I changed, and why:** I created `lib/widgets/meal_section.dart` as a reusable `StatelessWidget`. I made the meal name and `onAddFood` callback required constructor parameters so the same widget can be used for all three meal sections without duplicating the same layout.
- **Commit:** https://github.com/kirkdencv/Caly/commit/2e6403fa30ef5d1c8090e4c8190b9ff4804929e6

### 2026-09-25 - Building the first Today screen

- **Tool:** ChatGPT
- **What I asked for:** I asked for guidance while building the first version of the Today food journal screen, but I wanted to write the code myself instead of receiving a finished implementation.
- **What it gave back:** ChatGPT explained the Flutter layout concepts I needed, including `Scaffold`, `SafeArea`, `Padding`, `Column`, `Row`, text styling through `Theme.of(context)`, and how the spacing constants should be used.
- **What I kept, what I changed, and why:** I used those concepts to build `TodayScreen` myself with the Today title, date, Breakfast, Lunch, Dinner, and the total row. I also created `caly_spacing.dart` and kept the spacing names as `xs`, `sm`, `md`, `lg`, and `xl` because those names match the design system I am using.
- **Commit:** https://github.com/kirkdencv/Caly/commit/9f6592a675d6dc87e10564816dc861f7ec70afe9

### 2026-09-23 - Reviewing the initial Caly repository

- **Tool:** ChatGPT
- **What I asked for:** I asked ChatGPT to analyze my Caly repository before I started making major changes.
- **What it gave back:** It reviewed the project structure and explained that the repository was still mostly the course starter template. It recommended that I first make sure the Flutter project runs correctly before adding Firebase, FastAPI, or Gemini.
- **What I kept, what I changed, and why:** I kept the recommendation to establish a clean Flutter baseline first. I checked my Flutter and Dart versions, installed the project dependencies, and ran the starter project before changing the application.
- **Commit:** https://github.com/kirkdencv/Caly/commit/7379fd0

### 2026-09-23 - Establishing a Flutter project baseline

- **Tool:** ChatGPT
- **What I asked for:** I asked what my first development step should be after opening the repository.
- **What it gave back:** ChatGPT guided me to check `flutter --version`, `dart --version`, run `flutter pub get`, and run the Flutter web project before adding any new features.
- **What I kept, what I changed, and why:** I followed the setup steps because I wanted to confirm that the project already worked before I started changing it. I also kept the generated `pubspec.lock` file in the repository so the application has a recorded dependency baseline.
- **Commit:** https://github.com/kirkdencv/Caly/commit/7379fd0

### 2026-09-23 - Planning the development order

- **Tool:** ChatGPT
- **What I asked for:** I asked for guidance on what I should build first and what technologies should come later.
- **What it gave back:** ChatGPT recommended building the Flutter interface and local state first, then adding Firebase, FastAPI, Gemini, and the full integration after the Flutter side is understandable and working.
- **What I kept, what I changed, and why:** I kept this development order because it lets me learn and test one part of the application at a time instead of adding several technologies at once. I started with the Caly application shell and theme instead of immediately connecting Firebase or Gemini.
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0

### 2026-09-23 - Separating the Caly theme from main.dart

- **Tool:** ChatGPT
- **What I asked for:** I asked how to implement my Caly design system using Flutter `ThemeData`.
- **What it gave back:** ChatGPT recommended placing the design system in a separate Dart file instead of keeping all of the theme code inside `main.dart`.
- **What I kept, what I changed, and why:** I kept the separate-file approach and created `lib/theme/caly_theme.dart`. I used a `theme` folder so the project has a clearer structure and the Caly visual identity is not mixed with the main application startup code.
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0

### 2026-09-23 - Building the first Caly ThemeData

- **Tool:** ChatGPT
- **What I asked for:** I asked how to code the Caly theme using the colors and typography from my design system.
- **What it gave back:** ChatGPT showed how the Caly colors could be represented as Flutter `Color` values, placed into a `ColorScheme`, and then connected to `ThemeData`. It also showed shared text, filled button, and input decoration styles.
- **What I kept, what I changed, and why:** I used the overall structure but typed and reviewed the implementation myself. I used descriptive constants such as `calyGold`, `calyInk`, and `calyWarmPaper` so the code is easier for me to understand and change later. I also used `calySoftGold` as a named constant instead of leaving the value directly inside the color scheme.
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0

### 2026-09-23 - Understanding ThemeData, MaterialApp, and BuildContext

- **Tool:** ChatGPT
- **What I asked for:** While implementing the theme, I asked what `Theme.of(context)` means, what `context` represents, and how it is related to `MaterialApp(theme: calyTheme)`.
- **What it gave back:** ChatGPT explained the relationship as create, provide, and retrieve: `ThemeData` creates the theme, `MaterialApp(theme:)` provides it to widgets below it, and `Theme.of(context)` retrieves the theme that applies to the current widget.
- **What I kept, what I changed, and why:** I used the explanation to understand the code instead of only copying it. This helped me understand why the current screen can use `theme.colorScheme` and `theme.textTheme` without directly importing every color into the screen.
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0

> This record is maintained as the project changes. Entries use the date the
> assistance occurred, while commit links point to the commit that eventually
> recorded the work; those dates can differ when work spans more than one day.

---

## 2. Where the AI got it wrong

I will only record real mistakes or unsuitable suggestions here. I will not invent cases just to complete the requirement.

### Case 1 - The guidance turned into a quiz instead of development guidance

- **What it gave me:** ChatGPT asked me to answer several questions about `main()`, `MaterialApp`, `StatefulWidget`, and `setState()` before continuing.
- **What was wrong with it:** The questions were not the learning style I wanted for this project. I wanted to learn the concepts while actually developing Caly, not stop development to answer quiz-style questions.
- **What I did instead:** I told ChatGPT to focus on guiding me through the development of the application and to explain the concepts when they become relevant. After that, the guidance changed to a step-by-step development workflow while still teaching me what the code means.
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0

### Case 2 - Setting the Soft Gold color as a named variable for readability

- **What it gave me:** In the first theme example, ChatGPT placed the Soft Gold value directly inside the `ColorScheme` as `secondary: const Color(0xFFFFF4C2)`.
- **What was wrong with it:** The code would still work, but this was inconsistent with the other Caly colors that were already stored as named constants. Keeping one raw color value inside the `ColorScheme` made the theme less consistent and would make that color harder to find and change later.
- **What I did instead:** I created `const calySoftGold = Color(0xFFFFF4C2);` with the other Caly color constants and changed the `secondary` value to `calySoftGold`. This keeps the color definitions together, makes the name explain what the color is used for, and lets me change it from one place later.
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0

### Case 3 - The original architecture used Firebase when I decided local persistence was better for the MVP

- **What it gave me:** The earlier ChatGPT development plan included Firebase Authentication and Cloud Firestore for login, food journal persistence, History, Settings, and user-specific data.
- **What was wrong with it:** Firebase was not technically wrong, but it was no longer the best architecture for the version of Caly I wanted to finish. With the remaining development time and the single-user notes-style behavior of the MVP, adding Firebase Authentication, Firestore, security rules, and cloud synchronization would add unnecessary complexity.
- **What I did instead:** I corrected the architecture and told ChatGPT that I wanted Caly to use local persistent storage and a local demo login instead. I removed the Firebase-related TODOs and replaced them with TODOs for local serialization, saved daily notes, local History data, saved settings, and demo login/session behavior. ChatGPT then adjusted its guidance to the architecture I selected.
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)

---

## 3. Who wrote what

At least a fifth of the final project must be code I wrote myself and can explain. I will keep updating this section as I build the actual Caly screens, widgets, state, and integrations.

### Written by me


#### Today screen and local state

- **File:** `lib/screens/today_screen.dart`
- **Commit:** https://github.com/kirkdencv/Caly/commit/2e6403fa30ef5d1c8090e4c8190b9ff4804929e6
- **What I wrote:** I built the first Today screen layout and converted it into a `StatefulWidget`. I added the Today title, date, meal sections, total row, local Breakfast food list, `setState()` behavior, and the collection `for` loop that displays the current Breakfast entries.
- **What it does and why it is built this way:** `TodayScreen` owns the changing food data because it will later coordinate Breakfast, Lunch, Dinner, and the daily calorie total. Keeping the changing state in the parent screen makes it easier for smaller widgets such as `MealSection` to stay reusable.
- **How AI assisted:** ChatGPT explained the Flutter concepts and guided the development order, but I typed, ran, adjusted, and debugged the implementation myself.

#### Reusable meal section

- **File:** `lib/widgets/meal_section.dart`
- **Commit:** https://github.com/kirkdencv/Caly/commit/2e6403fa30ef5d1c8090e4c8190b9ff4804929e6
- **What I wrote:** I created the reusable `MealSection` `StatelessWidget`, added a required meal name, added a required `VoidCallback`, and connected the `Add food...` action to an `InkWell`.
- **What it does and why it is built this way:** The widget represents the shared layout used by Breakfast, Lunch, and Dinner. Instead of repeating the same layout three times, `TodayScreen` passes the meal name and callback into the reusable widget. `MealSection` does not own the food journal state; it displays the section and reports taps back to its parent.
- **How AI assisted:** ChatGPT explained reusable widgets, constructor parameters, callbacks, and the parent-to-child data flow. I implemented and tested the widget in my project.

#### Caly spacing

- **File:** `lib/theme/caly_spacing.dart`
- **Commit:** https://github.com/kirkdencv/Caly/commit/2e6403fa30ef5d1c8090e4c8190b9ff4804929e6
- **What I wrote:** I created the shared spacing values `xs`, `sm`, `md`, `lg`, and `xl`.
- **What it does and why it is built this way:** The spacing file gives the app one consistent spacing scale instead of using random numbers throughout the interface. I kept the short names because they match the design system I am using and make spacing values easy to recognize while building screens.
- **How AI assisted:** ChatGPT explained the purpose of a spacing scale and different ways it could be organized. I chose the naming and implemented the constants in my project.


- **File:** `lib/theme/caly_theme.dart`
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0
- **What I wrote:** I implemented the `calyTheme` `ThemeData` section that connects Caly's color scheme, text theme, scaffold background, divider color, filled button styling, and input decoration styling into one reusable app theme.
- **What it does and why it is built this way:** `calyTheme` is the main theme used by `MaterialApp`. It brings together the visual rules that I defined for Caly so the rest of the app can reuse the same colors, typography, button style, and text field style. I kept the theme in `caly_theme.dart` instead of putting everything inside `main.dart` so the project stays organized and future screens can use the same design without repeating the same styling code.
- **How AI assisted:** ChatGPT helped explain how Flutter `ThemeData`, `ColorScheme`, and `Theme.of(context)` work and suggested a possible structure. I reviewed the code, implemented the theme in my project, changed parts of it such as the named color constants, and tested it in the running app.

#### Completing the revised Caly TODO phases

- **Files:** Multiple files across `lib/` and the FastAPI backend
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)
- **What I wrote:** I worked through the TODO items in the revised Caly phases and implemented the application behavior across the Today screen, food entry flow, local persistence, demo login, History, Settings, FastAPI integration, and Gemini-related backend flow.
- **What it does and why it is built this way:** The completed TODO phases connect the main Caly workflow. Flutter handles the user interface and food journal state, persistent local storage keeps journal data after the application is closed or refreshed, the local demo login provides the presentation login flow, FastAPI provides the backend boundary, and Gemini is used behind the backend for interpreting food information.
- **How AI assisted:** ChatGPT built and explained the initial skeleton and TODO structure, then acted as a tutor while I completed the TODOs. It explained concepts, architecture, data flow, errors, and implementation choices when I needed help. I still worked through the TODO implementation and made project decisions myself, including changing the proposed Firebase architecture to local persistent storage and a demo login.

### The AI-written part I understand best

- **File:** `lib/theme/caly_theme.dart`
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0
- **What it does and why we kept it:** This file contains the first version of Caly's visual design system in Flutter. It defines named colors, creates the light `ColorScheme`, defines shared text styles, and configures common button and input field styling. I understand how `calyTheme` is passed to `MaterialApp`, how widgets retrieve the active theme using `Theme.of(context)`, and why keeping shared visual rules in one theme file is easier to maintain than repeating the same styles in every screen. I kept this structure because it makes future Caly screens use the same visual identity consistently.

- **Part:** Initial Caly application skeleton and TODO structure
- **Commit:** [Complete Caly food journal MVP](https://github.com/kirkdencv/Caly/commit/f025511af1c4bd3e6ed9fe48e0c3ab1cdbae5461)
- **What it does and why we kept it:** ChatGPT helped create the initial structure used to continue the project, including screen organization, reusable widgets, models, TODO markers, and the phased implementation plan. The skeleton separated responsibilities so I could work through the application one part at a time instead of trying to implement the complete project at once.
- **What I understand about it:** I understand how the main screens connect through the application shell, why `TodayScreen` owns the journal state, how reusable widgets receive data and callbacks, how models represent food and journal data, and how the backend and persistence layers connect to the Flutter application. I also understand that the skeleton was only a starting structure and that I changed parts of its architecture as the project developed, including replacing Firebase with local persistent storage and a local demo login.

---
