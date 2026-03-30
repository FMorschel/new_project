# Implementation Plan — Project Creator

Each phase starts with tests derived from the PRD. Check off steps as they are completed. End each phase with a full `dart analyze` and full `dart test` run. Everything must pass before moving to the next phase. The final phase is integration and wiring, which should be done only after all components are fully tested in isolation.

---

## Phase 1 — Data Models & Template Parsing

### 1.1 — Parameter model
- [x] Write unit tests for `TemplateParameter`:
  - [x] Deserializes all fields from JSON (key, label, description, type, options, multiSelect, required, passing, dependsOn)
  - [x] `multiSelect` defaults to `false` when absent
  - [x] `passing.separator` defaults to `" "`, `prefix`/`suffix` default to `""`
  - [x] Unknown `type` value throws a parse error
  - [x] `multiSelect: true` on non-`options` type throws a parse error
- [x] Implement `TemplateParameter` model with `fromJson`

### 1.2 — `passing` model
- [x] Write unit tests for `PassingConfig`:
  - [x] Parses `flag`, `flag_space_value`, `flag_equals_value`, `positional` styles
  - [x] `flag` field is optional when style is `positional`
- [x] Implement `PassingConfig` model with `fromJson`
 
### 1.3 — `dependsOn` model
- [x] Write unit tests for `DependsOnCondition`:
  - [x] Parses `set`, `unset`, `eq`, `neq` operators
  - [x] `value` field is present for `eq`/`neq`, absent for `set`/`unset`
- [x] Implement `DependsOnCondition` model with `fromJson`

### 1.4 — Template model
- [x] Write unit tests for `Template`:
  - [x] Parses `_parameters.json` with valid content
  - [x] Reports error when `projectTitle` is absent from parameters array
  - [x] Reports error when `projectPath` is absent from parameters array
  - [x] Reports error when a `dependsOn` key references a parameter declared later (forward reference)
  - [x] `projectTitle` step is always placed first regardless of position in array
- [x] Implement `Template` model

---

## Phase 2 — Template Discovery & Validation

### 2.1 — Template loader
- [x] Write unit tests for `TemplateLoader`:
  - [x] Lists all subfolders under `<cache>/templates/` as available templates
  - [x] Returns template-not-found error when folder is missing
  - [x] Returns `_parameters.json` missing error when file is absent
  - [x] Returns parse error (with details) when `_parameters.json` is malformed JSON
  - [x] Returns parse error when model validation fails (e.g., forward `dependsOn` ref)
- [x] Implement `TemplateLoader` using `path_provider`

### 2.2 — Entry point resolver
- [x] Write unit tests for `EntryPointResolver`:
  - [x] On Windows, resolves in order: `.dart`, `.ps1`, `.bat`, `.sh`
  - [x] On macOS/Linux, resolves in order: `.dart`, `.sh`, `.ps1`, `.bat`
  - [x] Returns error when no `main.*` file is found
  - [x] Returns the first match (does not return all matches)
- [x] Implement `EntryPointResolver` with platform-aware priority

---

## Phase 3 — Wizard Input Widgets

Each widget must:
- Accept a `TemplateParameter` for its config
- Emit its current value via a callback
- Render a disabled + explanation state when `isActive: false`

### 3.1 — `StringInputWidget`
- [x] Widget test: renders label and optional description
- [x] Widget test: calls `onChanged` with text value
- [x] Widget test: shows disabled state with dependency explanation text when `isActive: false`
- [x] Implement `StringInputWidget`

### 3.2 — `IntegerInputWidget`
- [x] Widget test: accepts only digit characters (rejects letters and `.`)
- [x] Widget test: calls `onChanged` with integer string
- [x] Widget test: disabled state
- [x] Implement `IntegerInputWidget`

### 3.3 — `NumInputWidget`
- [x] Widget test: accepts digits and `.` (rejects letters)
- [x] Widget test: rejects multiple `.` characters
- [x] Widget test: calls `onChanged` with numeric string
- [x] Widget test: disabled state
- [x] Implement `NumInputWidget`

### 3.4 — `BooleanInputWidget`
- [x] Widget test: renders a toggle/checkbox with the parameter label
- [x] Widget test: calls `onChanged(true/false)` on tap
- [x] Widget test: disabled state
- [x] Implement `BooleanInputWidget`

### 3.5 — `SingleOptionsInputWidget` (`options`, `multiSelect: false`)
- [x] Widget test: renders all options in a searchable dropdown
- [x] Widget test: typing in search field filters the option list
- [x] Widget test: selecting an option calls `onChanged` with that value
- [x] Widget test: only one option can be selected at a time
- [x] Widget test: disabled state
- [x] Implement `SingleOptionsInputWidget`

### 3.6 — `MultiOptionsInputWidget` (`options`, `multiSelect: true`)
- [x] Widget test: renders all options as checkbox list in a searchable dropdown
- [x] Widget test: typing filters options
- [x] Widget test: multiple items can be selected simultaneously
- [x] Widget test: closed state shows comma-separated summary of selected values
- [x] Widget test: selecting/deselecting calls `onChanged` with updated list
- [x] Widget test: disabled state
- [x] Implement `MultiOptionsInputWidget`

### 3.7 — Dependency explanation text
- [x] Unit tests for `dependsOnExplanation(condition, parameterLabel)`:
  - [x] `set` → *"Requires '<label>' to be set."*
  - [x] `unset` → *"Requires '<label>' to not be set."*
  - [x] `eq` → *"Requires '<label>' to be '<value>'."* (or equivalent)
  - [x] `neq` → *"Not available when '<label>' is '<value>'."*
- [x] Implement the explanation helper

---

## Phase 4 — Wizard Step Screen

### 4.1 — `WizardStepScreen`
- [x] Widget test: renders parameter label and description
- [x] Widget test: renders the correct input widget for each parameter type
- [x] Widget test: "Next" button is disabled when field is empty and `required: true`
- [x] Widget test: "Next" button is enabled when field has a value
- [x] Widget test: "Skip" button is visible only when `required: false`
- [x] Widget test: "Skip" clears the current value and calls `onNext`
- [x] Widget test: "Skip Optional" button is visible only when all remaining steps are optional
- [x] Widget test: "Skip Optional" calls `onSkipAllOptional`
- [x] Widget test: "Back" button calls `onBack`
- [x] Widget test: last step shows "Create" instead of "Next"
- [x] Implement `WizardStepScreen`

### 4.2 — Stepper nav bar
- [x] Widget test: all step labels are rendered in order
- [x] Widget test: current step is visually highlighted
- [x] Widget test: previous steps are clickable and call `onNavigateTo`
- [x] Widget test: a future step whose all prior required steps are answered is clickable
- [x] Widget test: a future step with an unanswered prior required step is greyed out and non-interactive
- [x] Implement `WizardStepperBar`

---

## Phase 5 — App Flow & Screens

### 5.1 — Launch argument parsing
- [x] Unit test: parses `<folder_path> <template_name>` from `args`
- [x] Unit test: returns null folder+template when args are absent/incomplete
- [x] Implement `LaunchArgs.parse(List<String> args)`

### 5.2 — Standalone launch screen (no args)
- [x] Widget test: folder picker button is shown
- [x] Widget test: template list shows all discovered templates
- [x] Widget test: selecting a template and folder enables "Continue"
- [x] Implement `StandaloneLaunchScreen`

### 5.3 — Template validation screen
- [x] Widget test: shows a loading/spinner state while validating
- [x] Widget test: disappears automatically on success and navigates to wizard
- [x] Widget test: persists with error details and a "Close" button on any validation failure
- [x] Implement `TemplateValidationScreen`

### 5.4 — Project Title step (Step 0)
- [x] Widget test: always shown as the first step
- [x] Widget test: no "Skip" button present
- [x] Widget test: "Next" is disabled when field is empty
- [x] Implement as a specialised first step in the wizard flow

### 5.5 — Loading screen
- [x] Widget test: shows full-screen spinner with *"Creating project…"* label
- [x] Widget test: no cancel button is present
- [x] Implement `LoadingScreen`

### 5.6 — Result screen
- [x] Widget test: shows success message on exit code 0
- [x] Widget test: shows error message and non-zero exit code on failure
- [x] Widget test: stdout/stderr foldable section is collapsed on success by default
- [x] Widget test: stdout/stderr foldable section is expanded on error by default
- [x] Widget test: "Close" button exits the app
- [x] Widget test: "Edit and retry" navigates back to Step 0 with all values restored
- [x] Implement `ResultScreen`

---

## Phase 6 — Command Assembly

### 6.1 — Command builder
- [x] Unit test: `flag` style — flag present when `true`, omitted when `false`
- [x] Unit test: `flag_space_value` style — `--name value`
- [x] Unit test: `flag_equals_value` style — `--name=value`
- [x] Unit test: `positional` style — bare value in array order
- [x] Unit test: skipped (null) parameters are omitted entirely
- [x] Unit test: multi-select with default separator — `android ios`
- [x] Unit test: multi-select with `","` separator — `android,ios`
- [x] Unit test: multi-select with separator + prefix + suffix — `[android,ios]`
- [x] Unit test: multi-select with no selections — parameter omitted entirely
- [x] Unit test: parameter with unmet `dependsOn` condition is omitted entirely
- [x] Unit test: all conditions in `dependsOn` are AND-ed
- [x] Unit test: `projectPath` is always included
- [x] Implement `CommandBuilder`

### 6.2 — `dependsOn` evaluator
- [x] Unit test: `set` — true when referenced param has any non-empty value
- [x] Unit test: `unset` — true when referenced param has no value
- [x] Unit test: `eq` — true when value matches exactly
- [x] Unit test: `neq` — true when value does not match
- [x] Implement `DependsOnEvaluator`

---

## Phase 7 — Script Execution

### 7.1 — Process runner
- [x] Unit test (mock): command is assembled and passed to `Process.run` / `Process.start`
- [x] Unit test (mock): non-zero exit code surfaces as error result
- [x] Unit test (mock): stdout and stderr are captured and returned
- [x] Implement `ScriptRunner` using `dart:io`

---

## Phase 8 — Shared Preferences

### 8.1 — Preferences service
- [x] Unit test: saves last-used value keyed by `<templateName>/<paramKey>`
- [x] Unit test: retrieves last-used value for a given template + key
- [x] Unit test: `projectTitle` and `projectPath` are never saved
- [x] Unit test: returns null (no pre-fill) when no saved value exists
- [x] Add `shared_preferences` package
- [x] Implement `PreferencesService`

---

## Phase 9 — Integration & Wiring

- [x] Wire `LaunchArgs` → `TemplateValidationScreen` → wizard steps → `LoadingScreen` → `ResultScreen`
- [x] Wire `StandaloneLaunchScreen` for the no-args case
- [x] Pre-fill each wizard field from `PreferencesService` on step entry
- [x] Save each answered value to `PreferencesService` on "Next" / "Create"
- [x] Integration test: full happy-path flow with a mock template and mock script runner
- [x] Integration test: "Edit and retry" restores all previously entered values

---

## Phase 10 — Polish & Edge Cases

- [x] Verify all §9 error cases surface the correct message
- [x] Confirm `projectTitle` step always renders first regardless of array position
- [x] Confirm `projectPath` step is never shown in the wizard
- [x] Confirm template folder icon (`icon.ico`) is loaded and shown in the template selector
- [x] Manual smoke test on Windows (context menu args)
- [x] Manual smoke test on macOS (Quick Action args)
- [x] Manual smoke test on Linux (file manager custom action args)
