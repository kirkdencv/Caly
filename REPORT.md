# Weekly Increment Report

## Week of: September 24-27, 2026

## What changed this week

- Created `lib/theme/caly_spacing.dart` to store the spacing values used by Caly's design system.
- Added the spacing scale using `xs`, `sm`, `md`, `lg`, and `xl`.
- Created `lib/screens/today_screen.dart` and started building the main Today food journal screen.
- Replaced the original starter screen with the first static version of the Caly Today screen.
- Added the Today title, date, Breakfast, Lunch, Dinner, and daily total layout.
- Used the existing Caly theme for text styles, colors, spacing, and screen styling.
- Created `lib/widgets/meal_section.dart` as a reusable widget for Breakfast, Lunch, and Dinner instead of repeating the same layout three times.
- Added constructor parameters to `MealSection` so the parent screen can provide the meal name.
- Added a `VoidCallback` to `MealSection` so tapping `Add food...` can send an event back to `TodayScreen`.
- Converted `TodayScreen` from a `StatelessWidget` into a `StatefulWidget` so it can remember changing food data.
- Added a local Breakfast food list using `List<String>`.
- Used `setState()` to add a temporary `"1 cup of rice"` entry when the Breakfast `Add food...` action is triggered.
- Used a collection `for` loop to create a `Text` widget for every item stored in the Breakfast food list.
- Confirmed that repeated taps can add multiple local food entries and rebuild the screen correctly.

## Why

I wanted to start building the main screen of Caly using Flutter only before connecting Firebase, FastAPI, or Gemini.

The Today screen is the center of the application, so I first focused on understanding how its layout should be structured using `Scaffold`, `SafeArea`, `Padding`, `Column`, `Row`, and the spacing and typography from my design system.

I created `MealSection` because Breakfast, Lunch, and Dinner use the same layout. Instead of repeating the same widgets three times, I made one reusable widget that receives different meal names.

I also wanted to understand how data and events move between Flutter widgets. `TodayScreen` now provides information to `MealSection` through constructor parameters, while `MealSection` can report an `Add food...` tap back to the parent through a callback.

I converted `TodayScreen` into a `StatefulWidget` because food entries are values that change while the user is using the app. The temporary Breakfast list lets me learn how local state, `setState()`, Dart lists, and widget rebuilding work before I create the real food input system.

## What broke or what I got stuck on

I initially had trouble applying the text styles from my Caly theme. I tried passing an entire `TextStyle` into a property that expected a `double`, which caused the error:

`The argument type 'TextStyle?' can't be assigned to the parameter type 'double?'`

I learned that a complete theme style should be passed directly to the `style:` property of a `Text` widget.

I also needed to understand how `.copyWith()` works when I wanted to keep an existing text style but change only its color.

While creating `MealSection`, an incorrect Dart internal library was accidentally imported:

`dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart`

This caused the Flutter web build to fail because the library is only for internal/native VM use and is not available in the browser. I removed the unnecessary import and kept only the packages actually needed by the widget.

I also initially tried to display `_breakfastFood` directly inside `MealSection`, even though that state belonged to `_TodayScreenState`. I learned that a child widget cannot directly access a variable owned by another class unless the parent passes the value to it.

Another issue I noticed is that Breakfast, Lunch, and Dinner currently use the same temporary callback, so tapping Lunch or Dinner can still affect the Breakfast state. This is only temporary while I learn the state flow and still needs to be corrected.

## What is left

The Today screen is still an early local Flutter version.

I still need to:

- Pass the Breakfast food list into `MealSection` instead of displaying it separately from the widget.
- Create separate food collections for Breakfast, Lunch, and Dinner.
- Make each meal's `Add food...` action update the correct meal.
- Replace temporary hard-coded `"1 cup of rice"` entries with actual user input.
- Create a proper food entry data model instead of storing only Strings.
- Add calorie values beside each food entry.
- Calculate the daily calorie total from the stored entries.
- Build reusable food entry rows.
- Add food correction/editing behavior.
- Finish the Today screen styling and compare it with the final Caly mockup.
- Build the Sign In, History, Food Correction, and Settings screens.
- Add navigation.
- Connect Firebase Authentication.
- Add Cloud Firestore persistence.
- Build the FastAPI backend.
- Connect FastAPI to Gemini for calorie interpretation.
- Connect the Flutter food input flow to the backend.
- Test the complete Caly flow and update the project documentation and screenshots.
  
## Week of: September 16-23, 2026

## What changed this week

- Verified that the final project Flutter repository runs correctly before starting Caly development.
- Checked my development environment and confirmed Flutter 3.44.4 and Dart 3.12.2.
- Ran `flutter pub get` successfully and added the generated `pubspec.lock` file to the repository.
- Ran the Flutter project using `flutter run -d web-server --web-port 8080`.
- Confirmed that Device Preview works and displays the app using an iPhone 13 frame.
- Created a clean baseline commit before changing the starter project.
- Created and pushed the `chore/caly-app-shell` branch.
- Created `lib/theme/caly_theme.dart` to separate Caly's visual design from `main.dart`.
- Added Caly's planned color scheme, including gold, ink, warm paper, muted gray, outline, soft gold, and error colors.
- Added the first Caly text theme using shared heading, title, body, and label styles.
- Added shared styling for filled buttons and input fields.
- Connected the new Caly theme to `MaterialApp`.
- Tested the starter screen again and confirmed that the Caly theme is applied correctly.

## Why

I wanted to start from a working Flutter project before adding any major features. This gives me a clean baseline and makes it easier to identify problems later.

I also wanted Caly's design settings to be organized from the beginning. Instead of putting colors and text styles directly inside every screen, I created a separate theme file so the same design can be reused throughout the app.

I decided to work on the Flutter side first before Firebase, FastAPI, and Gemini because I want to understand how the interface, widgets, and state work before connecting external services.

## What broke or what I got stuck on

There were no major errors that stopped development this week.

`flutter pub get` showed that some packages have newer versions available, but the dependencies still installed successfully. I decided not to update the packages yet because the current project is already working.

I also spent time understanding the relationship between `ThemeData`, `MaterialApp(theme:)`, `BuildContext`, and `Theme.of(context)`. At first, I was confused about whether `Theme.of(context)` created the theme or called the value directly from `MaterialApp`. I now understand that the theme is created first, provided through `MaterialApp`, and then retrieved by widgets using `Theme.of(context)`.

## What is left

The current project is still at the app-shell stage. The main Caly features are not implemented yet.

I still need to:

- Replace the starter counter screen with Caly's Today food journal screen.
- Create the Breakfast, Lunch, and Dinner sections.
- Add reusable widgets for food entries and meal sections.
- Add local Flutter state for adding and editing food entries.
- Calculate the daily calorie total.
- Build the Sign In, Food Correction, History, and Settings screens.
- Add navigation between the screens.
- Add Firebase Authentication.
- Add Cloud Firestore for saved journal data.
- Build the FastAPI backend.
- Connect Flutter to FastAPI.
- Connect FastAPI to Gemini for calorie interpretation.
- Test the complete food logging flow.
- Update screenshots and documentation as each real screen is completed.
