# Demo video

**File:** Hosted externally: https://tinyurl.com/CalyPresentation
**Length:** 23 minutes and 9 seconds
**Recorded on:** Laptop browser using the Caly application deployed through GitHub Pages

## What it shows

A short list, in order, so a viewer can skip to what they need:

- 00:00–04:42 — Complete Caly user journey: login, food logging, calorie calculation, correction, deletion, History, and Settings.
- 04:43–08:53 — Today screen state, meal separation, calorie totals, debouncing, async requests, stale-response protection, and local saving.
- 08:56–10:59 — Flutter-to-FastAPI communication, JSON requests, response decoding, timeouts, and error handling.
- 11:00–12:52 — FastAPI food interpretation endpoint, Gemini integration, error mapping, and response construction.
- 13:09–14:30 — Pydantic validation for food text, meal categories, quantity, calories, and structured Gemini output.
- 14:31–16:50 — Local journal persistence using shared_preferences, JSON serialization, date-based loading, and calorie-goal storage.
- 16:50–23:09 — AI usage, AI mistakes and corrections, personal contributions, deployment decisions, limitations, and future improvements.

Cover, in this order: the main user journey end to end, anything that only works
on a real device (camera, GPS, sensors), and the thing you are proudest of.

## Getting it into the repo

GitHub **blocks any file over 100 MB** and warns over 50 MB, so compress before
you commit:

```bash
ffmpeg -i raw.mp4 -vcodec libx264 -crf 28 -preset slow \
       -vf scale=-2:720 -acodec aac -b:a 96k demo.mp4
```

Raise `-crf` (28 to 32) or drop to `-2:480` if it is still too large. If it still
does not fit, attach it to a **GitHub Release** or upload it unlisted and link it
here. Never commit the raw capture: git keeps it forever even after you delete
it.

## Before you record

- Real data off the screen: no classmates' names, numbers, faces or messages.
- Notifications off.
- Sensible sample data, not "asdf".
- One unbroken take per feature. Say what you are doing while you do it.
