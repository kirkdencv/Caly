# Mockup and wireframes

The visual plan for this app. Your wireframes answered what goes where; the
mockup shows what it looks like.

## Mockup

Put your mockup images or PDF in `assets/` and embed them here, one heading per
screen.

_(Embed your mockup here once it is in `assets/`.)_

[View the submitted high-level mockup (PDF)](assets/caly-high-level-mockup.pdf)

![Current Caly app shell](assets/caly-app-shell.png)

The submitted mockup defines a 390 x 844 mobile canvas, 24-pixel horizontal
margins, warm paper surfaces, gold actions, and a compact three-item bottom
navigation. The implementation keeps that visual hierarchy while replacing
modal add-food forms with faster inline note entry.

## Wireframes

Your earlier box-and-label sketches and the screen flow: which screen opens
first, and how a user moves between them. Photos of paper are fine.

_(Embed your flow diagram and sketches here once they are in `assets/`.)_

The implemented screen flow is:

1. **Sign In -> Today:** valid local demo credentials open the app shell; a saved
   demo session restores the same destination on reload.
2. **Today -> Correction -> Today:** tapping a calorie result opens the correction
   sheet; saving replaces the entry and recalculates the total.
3. **Today <-> History <-> Settings:** the bottom navigation changes tabs while
   preserving screen state.
4. **History -> saved date:** selecting a journal card returns to Today with that
   date loaded; edits are saved back to the selected day.
5. **Settings -> Sign In:** sign-out clears the local session and replaces the app
   shell with Sign In.

## Screens

One short section per screen: what is on it, what the user does, and where each
action goes.

### Sign In

The Caly cat mark, animated food-interpretation preview, email field, password
field, visibility icon, validation feedback, and primary Sign in button appear
in a centered narrow column. Successful demo credentials open Today; invalid
credentials stay on the form and show an error.

### Today

The selected journal date, Breakfast, Lunch, and Dinner note sections, calculated
daily total, goal, and progress indicator appear in one scrollable page. Typing a
food and pausing starts interpretation. Three moving dots show pending work;
calories replace them when ready. A failed line keeps its text for retry. Tapping
calories opens Correction, while swiping a completed line removes it with undo.

### Food Correction

A bottom sheet displays the original note, food name, quantity, unit, and calorie
fields. Cancel closes the sheet without changing the entry. Save validates the
fields, replaces the row, recalculates the daily total, and persists the day.

### History

A search field filters locally saved days by date, food text, food name, or
calories. Notes are ordered newest first and grouped into recent, previous-week,
and older sections. Selecting a card opens that saved day in Today.

### Settings

Settings shows the daily calorie goal, system appearance, local demo account, and
sign-out action. Goal changes are validated, persisted, and reflected immediately
on Today. Sign out clears the local session and returns to Sign In.
