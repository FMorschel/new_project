# PRD — Project Creator

## 1. Overview

A minimal Flutter desktop application that creates new projects from user-defined templates. It is primarily invoked via the OS file explorer context menu, receiving the output folder and the template name as launch arguments. It can also be launched standalone, in which case it prompts for both.

---

## 2. Goals

- Provide a fast, guided UI to scaffold new projects from local templates.
- Support any scripting language for the template entry point.
- Allow templates to declare typed, ordered parameters with full control over how they are passed to the script.
- Remember the user's last-used values per parameter per template.
- Run on Windows, macOS, and Linux.

---

## 3. Context Menu Integration

The app receives two pieces of information at launch:

| Data | Source |
|---|---|
| Output folder path | The folder on which the user right-clicked |
| Template name | The submenu item the user selected (e.g. "Flutter", "Dart") |

### Passing mechanism

CLI arguments are used on all platforms. The app receives them as positional arguments:

```
app <folder_path> <template_name>
```

| Platform | How arguments are supplied |
|---|---|
| Windows | Registry `shell\<entry>\command` key: `"<app.exe>" "%V" "<TemplateName>"` |
| macOS | Quick Action / Automator shell script calls the app with the selected folder path and template name |
| Linux | File manager custom action (Nautilus, Thunar, etc.) using `%f` / `%F` substitution variables |

### Fallback (standalone launch)

If the app is launched without receiving the output folder or template name, it must:
- Show a folder picker for the output folder.
- Show a template selector listing all available templates.

---

## 4. Template Structure

Templates are stored under `getApplicationCacheDirectory()/templates/`.

```
templates/
  flutter_app/
    main.sh          ← entry point (see §4.1)
    _parameters.json ← required (see §5)
    icon.ico         ← used to represent the template in the UI - both app and context menu (optional)
  dart_cli/
    main.ps1
    _parameters.json
```

- The folder name is the template name (matched against the launch argument).
- Any other files inside the template folder are ignored by the app.

### 4.1 Entry point (`main`)

The app looks for a `main` file with one of the following extensions. Priority is OS-dependent:

| Priority | Windows | macOS / Linux |
|---|---|---|
| 1 | `.dart` | `.dart` |
| 2 | `.ps1` | `.sh` |
| 3 | `.bat` | `.ps1` |
| 4 | `.sh` | `.bat` |

`.dart` is always first because it is cross-platform. The remaining order prefers the shell native to each OS.

Additional extensions may be added in the future. If no `main` file is found, the app shows an error.

---

## 5. `_parameters.json` Specification

This file is **required**. If absent, the app shows a clear error: *"This template is missing a `_parameters.json` file."*

### 5.1 Top-level structure

```json
{
  "parameters": [ /* ordered array of parameter objects */ ]
}
```

The order of entries in the array defines:
1. The order of wizard steps shown to the user.
2. The order in which arguments are appended to the command.

### 5.2 Parameter object

| Field | Type | Required | Description |
|---|---|---|---|
| `key` | string | yes | Unique identifier. Use `projectTitle` and `projectPath` for the built-ins (see §5.4). |
| `label` | string | yes | Human-readable label shown in the UI. |
| `description` | string | no | Optional helper text shown below the field. |
| `type` | string | yes | One of: `string`, `integer`, `num`, `options`, `boolean`. |
| `options` | string[] | if `type=options` | List of allowed values shown as a searchable dropdown with checkboxes. |
| `multiSelect` | boolean | no | If `true`, the user may select multiple values. Only valid when `type=options`. Defaults to `false`. |
| `required` | boolean | yes | Whether the parameter must be filled before proceeding. |
| `passing` | object | yes | Defines how this parameter is appended to the command (see §5.3). |
| `dependsOn` | object[] | no | Array of conditions that must all be true for this parameter to be active (see §5.5). All `key` references must point to parameters declared earlier in the array. |

### 5.3 `passing` object

| Field | Type | Required | Description |
|---|---|---|---|
| `style` | string | yes | One of: `flag`, `flag_space_value`, `flag_equals_value`, `positional`. |
| `flag` | string | if style ≠ `positional` | The flag name including prefix, e.g. `--name`, `-n`. |
| `separator` | string | no | For `multiSelect` parameters: string used to join selected values. Defaults to `" "`. |
| `prefix` | string | no | For `multiSelect` parameters: string prepended to the joined values, e.g. `"["`. Defaults to `""`. |
| `suffix` | string | no | For `multiSelect` parameters: string appended to the joined values, e.g. `"]"`. Defaults to `""`. |

#### Passing styles

| Style | Example output |
|---|---|
| `flag` | `--verbose` — boolean only; flag is present when `true`, omitted when `false`. |
| `flag_space_value` | `--name my_app` |
| `flag_equals_value` | `--name=my_app` |
| `positional` | `my_app` — value appended as-is, in the order defined by the array. |

#### Multi-select value formatting

When `multiSelect: true`, selected values are joined using `separator`, then wrapped with `prefix` and `suffix`, and the result is treated as a single value token for the passing style. Examples:

| separator | prefix | suffix | Selected | Output token |
|---|---|---|---|---|
| `" "` (default) | | | `android`, `ios` | `android ios` |
| `","` | | | `android`, `ios` | `android,ios` |
| `", "` | `"["` | `"]"` | `android`, `ios` | `[android, ios]` |

### 5.4 `dependsOn` conditions

Each entry in the `dependsOn` array is a condition object. All conditions are AND-ed: the parameter is active only when every condition is true.

| Field | Type | Required | Description |
|---|---|---|---|
| `key` | string | yes | The key of another parameter declared earlier in the array. |
| `op` | string | yes | One of: `set`, `unset`, `eq`, `neq`. |
| `value` | string | if `op=eq` or `op=neq` | The value to compare against. |

#### Operators

| Op | Active when… |
|---|---|
| `set` | The referenced parameter has any non-empty value. |
| `unset` | The referenced parameter has no value (not filled or skipped). |
| `eq` | The referenced parameter's value equals `value`. |
| `neq` | The referenced parameter's value does not equal `value`. |

#### UI behavior for inactive parameters

When one or more conditions are not met, the parameter's input is **disabled** but the step is still shown. Below the input, an auto-generated note lists each unmet condition, e.g.:

- *"Requires 'Organization' to be set."*
- *"Not available when 'Target Platforms' is 'web'."*
- *"Requires 'Output Folder' to not be set."*

The stepper nav bar shows the step normally; reachability rules (§6.4) still apply based on `required`, ignoring whether the step is currently active or inactive.

#### Command assembly

A parameter with any unmet `dependsOn` condition is **omitted entirely** from the command, regardless of its value.

#### Validation

During template validation, the app checks that every `key` in every `dependsOn` array refers to a parameter declared earlier in the `parameters` array. A forward reference is reported as a template error.

### 5.5 Built-in parameters

Two parameter keys are reserved and handled specially by the app:

| Key | Description | UI behavior |
|---|---|---|
| `projectTitle` | The name of the project to create. | Always shown as the **first** wizard step, regardless of position in the array. When encountered again in the array, that step is skipped. Its value is **never** saved to shared preferences. |
| `projectPath` | The output folder path. | Pre-filled from the launch argument (or folder picker). Never shown as a wizard step. When encountered in the array, that step is skipped. Its value is **never** saved to shared preferences. |

Both must be declared in `_parameters.json` so their `passing` configuration is known.

### 5.6 Example

```json
{
  "parameters": [
    {
      "key": "projectTitle",
      "label": "Project Name",
      "type": "string",
      "required": true,
      "passing": { "style": "flag_space_value", "flag": "--project-name" }
    },
    {
      "key": "projectPath",
      "label": "Output Folder",
      "type": "string",
      "required": true,
      "passing": { "style": "positional" }
    },
    {
      "key": "organization",
      "label": "Organization",
      "description": "Reverse domain, e.g. dev.fmorschel",
      "type": "string",
      "required": false,
      "passing": { "style": "flag_space_value", "flag": "--org" }
    },
    {
      "key": "platforms",
      "label": "Target Platforms",
      "type": "options",
      "options": ["android", "ios", "web", "windows", "macos", "linux"],
      "multiSelect": true,
      "required": true,
      "passing": { "style": "flag_space_value", "flag": "--platforms", "separator": ",", "prefix": "[", "suffix": "]" }
    },
    {
      "key": "pub",
      "label": "Run pub get",
      "type": "boolean",
      "required": false,
      "passing": { "style": "flag", "flag": "--pub" }
    },
    {
      "key": "offlinePackages",
      "label": "Use offline packages",
      "type": "boolean",
      "required": false,
      "passing": { "style": "flag", "flag": "--offline" },
      "dependsOn": [
        { "key": "pub", "op": "eq", "value": "true" }
      ]
    }
  ]
}
```

This would produce a command similar to:

```
main.sh --project-name my_app --org dev.fmorschel --platforms [android,ios] --pub --offline my_app_path
```

`offlinePackages` is inactive (and omitted) unless `pub` is `true`.

---

## 6. App Screens & Flow

### 6.1 Flow diagram

```
Launch
  │
  ├─ Has folder + template? ──No──► Folder picker + template selector
  │
  ▼
Template validation
  │
  ├─ main file missing?         ──► Error screen
  ├─ _parameters.json missing?  ──► Error screen
  ├─ _parameters.json invalid?  ──► Error screen (details)
  │
  ▼
[Step 0] Project Title  ← always first
  │
  ▼
[Step 1..N] One screen per parameter (skipping projectTitle / projectPath)
  │
  ▼
Loading screen (command executing)
  │
  ▼
Result screen (success or error)
```

### 6.2 Template validation screen

Shown briefly while the app validates the template. If any validation fails, the screen persists showing:
- Which file or field is missing/invalid.
- A "Close" button.

### 6.3 Project Title step (Step 0)

- Text field labelled with `projectTitle.label`.
- No "Skip" button (always required).
- "Next" button proceeds to Step 1.

### 6.4 Parameter wizard steps (Steps 1–N)

Each step occupies its own screen and shows:

- **Header**: parameter `label` (and optional `description` below it).
- **Input widget** — mapped by type:

  | Type | `multiSelect` | Widget |
  |---|---|---|
  | `string` | — | Single-line text field |
  | `integer` | — | Numeric text field (digits only) |
  | `num` | — | Numeric text field (digits and `.` only) |
  | `options` | `false` | Searchable dropdown (single selection) |
  | `options` | `true` | Searchable dropdown with checkboxes; closed state shows selected values as a comma-separated summary |
  | `boolean` | — | Toggle / checkbox |

- **Navigation bar** (stepper at the top): shows all parameter step names in order. Stepper navigation rules:
  - Clicking any **previous** step always navigates there.
  - A future step is **reachable** if every required step before it has already been answered. It is **blocked** otherwise.
  - Reachable steps are clickable — this lets the user jump forward through optional steps, or land directly on the next unanswered required step.
  - Blocked steps are greyed out and non-interactive.
  - The current step is highlighted. Answered steps, reachable steps, and blocked steps are each visually distinct.
- **Bottom actions**:
  - "Back" — go to previous step.
  - "Skip" — visible only when `required: false`. Clears any value and moves to the next step.
  - "Skip Optional" — visible only when one or more remaining steps are all optional. Skips all remaining optional steps and proceeds to the next unvisited required step, or to "Create" if none remain.
  - "Next" / "Create" (last step) — proceeds; disabled if the field is empty and `required: true`.

### 6.5 Loading screen

- Full-screen spinner/progress indicator.
- Label: *"Creating project…"*
- The command is assembled and executed as a subprocess.
- Not cancellable (v1).

### 6.6 Result screen

- **Success**: prominent success message.
- **Error**: prominent error message + non-zero exit code.
- **Foldable section** — always present:
  - Shows `stdout` and `stderr` with distinct labels.
  - Collapsed by default on success, expanded by default on error.
- **Actions**:
  - "Close" — exits the app.
  - "Edit and retry" — returns to Step 0 (Project Title), restoring all previously entered values for editing.

---

## 7. Command Assembly

The final command is built by iterating `parameters` in array order and appending each argument according to its `passing` style and current value:

- `flag` (`boolean`): append the flag string if value is `true`; omit entirely if `false` or skipped.
- `flag_space_value`: append `<flag> <value>`. Omit entirely if skipped.
- `flag_equals_value`: append `<flag>=<value>`. Omit entirely if skipped.
- `positional`: append `<value>`. Omit entirely if skipped.

For `multiSelect` parameters, `<value>` is computed as `<prefix><v1><separator><v2>…<suffix>` before being substituted into the style above. If no values are selected the parameter is omitted entirely.

A parameter with any unmet `dependsOn` condition is omitted entirely, regardless of its value.

`projectPath` is pre-filled and always included (it is `required: true` by convention).

---

## 8. Shared Preferences

| Data | Scope | Persisted? |
|---|---|---|
| Last-used value for a parameter | Per template + per parameter `key` | Yes |
| `projectTitle` value | — | No |
| `projectPath` value | — | No |

On wizard entry, each field is pre-filled with the last saved value for that template + key combination (if any).

---

## 9. Error Cases

| Condition | Behavior |
|---|---|
| Template folder not found | Error screen: *"Template '<name>' not found."* |
| `main` file not found | Error screen: *"No entry point found in template '<name>'."* |
| `_parameters.json` not found | Error screen: *"This template is missing a `_parameters.json` file."* |
| `_parameters.json` malformed | Error screen with parse details. |
| `projectTitle` or `projectPath` absent from `_parameters.json` | Error screen: *"parameters.json must define both `projectTitle` and `projectPath`."* |
| `dependsOn` references a key not declared earlier in the array | Error screen: *"Parameter '<key>' has a dependsOn reference to '<ref>' which is not declared before it."* |
| `multiSelect: true` on a non-`options` type | Error screen with field details. |
| Script exits with non-zero code | Result screen in error state, stdout/stderr expanded. |

---

## 10. Out of Scope (v1)

- Template creation, editing, or deletion from within the app.
- Cancelling an in-progress command.
- Automatic installation of context menu entries (documented separately, performed manually).
- Remote/cloud templates.
- Template versioning.
