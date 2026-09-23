# AI usage

This project was built with AI assistance. This file is the record of how I used AI during development, what I kept or changed, and what I learned from checking the AI's suggestions.

I am updating this file while I build the project instead of writing it all at the end.

---

## 1. How I used AI

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

> More entries will be added as the project continues. The final submission requires at least six real uses, and these entries should continue to be updated if later commits better represent the work.

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

---

## 3. Who wrote what

At least a fifth of the final project must be code I wrote myself and can explain. I will keep updating this section as I build the actual Caly screens, widgets, state, and integrations.

### Written by me

- **File:** `lib/theme/caly_theme.dart`
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0
- **What I wrote:** I implemented the `calyTheme` `ThemeData` section that connects Caly's color scheme, text theme, scaffold background, divider color, filled button styling, and input decoration styling into one reusable app theme.
- **What it does and why it is built this way:** `calyTheme` is the main theme used by `MaterialApp`. It brings together the visual rules that I defined for Caly so the rest of the app can reuse the same colors, typography, button style, and text field style. I kept the theme in `caly_theme.dart` instead of putting everything inside `main.dart` so the project stays organized and future screens can use the same design without repeating the same styling code.
- **How AI assisted:** ChatGPT helped explain how Flutter `ThemeData`, `ColorScheme`, and `Theme.of(context)` work and suggested a possible structure. I reviewed the code, implemented the theme in my project, changed parts of it such as the named color constants, and tested it in the running app.

### The AI-written part I understand best

- **File:** `lib/theme/caly_theme.dart`
- **Commit:** https://github.com/kirkdencv/Caly/commit/d7835c0
- **What it does and why we kept it:** This file contains the first version of Caly's visual design system in Flutter. It defines named colors, creates the light `ColorScheme`, defines shared text styles, and configures common button and input field styling. I understand how `calyTheme` is passed to `MaterialApp`, how widgets retrieve the active theme using `Theme.of(context)`, and why keeping shared visual rules in one theme file is easier to maintain than repeating the same styles in every screen. I kept this structure because it makes future Caly screens use the same visual identity consistently.

---
