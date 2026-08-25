================================================================================
                                BIRDLE GAME
================================================================================

OVERVIEW
--------
Birdle is a 5-letter word-guessing game built using the Flutter framework and
Dart language. Inspired by Wordle, Birdle provides a responsive, intuitive, and
interactive interface where players attempt to uncover a hidden 5-letter word
within a maximum number of allowed attempts (default 5).

The application is structured cleanly with a strict separation between domain/
game logic (`lib/game.dart`) and UI components/widgets (`lib/main.dart`).


FEATURES
--------
* Word-Guessing Mechanics:
  - Validates user input against strict legal word dictionaries (`legalWords` and
    `legalGuesses`).
  - Implements two-pass evaluation logic to properly handle exact matches (Hits)
    and partial matches without duplicate-character miscounts.

* Interactive Virtual Keyboard & Physical Keyboard Support:
  - On-screen virtual keyboard dynamically reflects letter state feedback
    (Hit, Partial, Miss, Unused).
  - Listens to physical keyboard events (`KeyboardListener`), allowing hardware
    typing, Backspace, and Enter navigation.

* Theme & Responsive UI:
  - Clean, modern Material 3 styling supporting Light and Dark modes seamlessly.
  - Custom tile grid rendering guess history, active row inputs, and empty slots.
  - SnackBar notifications for feedback (e.g., short words, invalid word lists).
  - Win and Game Over dialogs with one-tap restart capability.

* Deterministic & Random Game Modes:
  - Supports seeded game initialization for repeatable puzzle generation and
    automated testing, alongside random word selection.


PROJECT STRUCTURE
-----------------
.
├── lib/
│   ├── main.dart       - Application entry point, UI widgets, keyboard handling,
│   │                     and theme configurations.
│   └── game.dart       - Domain model, state machine (`Game`), word logic (`Word`),
│                         letter hit types (`HitType`), and dictionary lists.
├── test/
│   ├── game_test.dart   - Unit tests covering `Game` engine, seed generation,
│   │                     word validation, and match evaluation.
│   └── widget_test.dart - Widget/UI tests covering rendering, virtual keyboard input,
│                         validation messages, and restart flows.
├── pubspec.yaml        - Flutter dependencies, SDK constraints, and project metadata.
├── analysis_options.yaml - Static analysis and linting configuration rules.
└── readme.txt          - Project documentation and technical guide.


GETTING STARTED
---------------
Prerequisites:
  - Flutter SDK version 3.11.0 or higher.
  - Dart SDK version 3.11.0 or higher.

Installation & Setup:
  1. Clone or download the project directory.
  2. Fetch all required dependencies by running:
     $ flutter pub get

Running the Application:
  - To launch on an available device/emulator:
    $ flutter run

  - To specify a particular target device (e.g., Chrome/Web, Linux, Desktop):
    $ flutter run -d chrome
    $ flutter run -d linux


RUNNING TESTS
-------------
Birdle maintains comprehensive test coverage across unit domain logic and UI
widgets.

To execute unit and widget test suites:
    $ flutter test

To run static analysis and lint checks:
    $ flutter analyze


ARCHITECTURE & IMPLEMENTATION
-----------------------------
* Game Engine (`lib/game.dart`):
  - `Game`: Manages state machine transitions, tracks active attempt index,
    evaluates win/loss conditions, and retains guess history.
  - `Word`: Immutable representation of a 5-letter sequence built from `Letter`
    records `(char: String, type: HitType)`.
  - `HitType`: Enum representing letter status (`none`, `hit`, `partial`, `miss`).
  - `WordUtils`: Contains core `evaluateGuess` logic. Ensures exact matches
    are prioritized before spending available hidden letters on partial matches.

* Presentation Layer (`lib/main.dart`):
  - `MainApp`: Root Material app supporting system brightness adaptation.
  - `GamePage`: Stateful UI container orchestrating user interactions and focus.
  - `Tile`: Reusable tile widget handling dynamic background colors and borders.
  - Virtual Keyboard: Map key hit types across previous guesses to colorize keys
    accurately (Hit overrides Partial/Miss; Partial overrides Miss).


LICENSE & CREDITS
-----------------
Developed with Flutter & Dart. All rights reserved.
