# Dexor (DevTools Hub) — Design System

## Vibe & Atmosphere
Dexor is an offline-first utility workspace for developers and power users. The UI should feel precise, calm, and efficient: dark-friendly surfaces, clear hierarchy, dense but readable information, and minimal visual noise. Interactions should communicate trust and local control (no cloud dependency), with a single clear primary action per view.

## Colour Palette
### Core dark mode tokens
| Token | Hex | Role |
|---|---|---|
| Primary | #00E5CC | Primary CTA, active controls, focus accent (default accent) |
| Primary Hover | #00B8A3 | Hover/pressed primary |
| Surface | #0D0D0F | App/page background (dark) |
| Surface+1 | #131317 | App bars, panels, raised layout surfaces |
| Surface+2 | #18181D | Cards and input fill (dark) |
| Border | #1E1E24 | Borders, dividers, inactive outlines |
| Text | #FFFFFF | Primary text on dark surfaces |
| Text Muted | #6B7280 | Secondary metadata, hints, subdued labels |
| Destructive | #FF4D4D | Errors, destructive actions |
| Success | #00D68F | Success state, “local processing active” indicators |
| Warning | #FFB830 | Caution/warning states |
| Info | #4D9FFF | Informational badges, secondary status accents |

### Core light mode tokens
| Token | Hex | Role |
|---|---|---|
| Surface | #F5F5F7 | App/page background (light) |
| Surface+1 | #FFFFFF | App bars, panels, elevated cards |
| Surface+2 | #F0F0F4 | Card/input fill in light mode |
| Border | #E2E2E8 | Borders/dividers |
| Text | #101114 | Primary text on light surfaces |
| Text Muted | #9CA3AF | Muted labels and captions |

### Accent options (user-selectable)
| Token | Hex | Role |
|---|---|---|
| Accent / Cyan (default) | #00E5CC | Default app accent |
| Accent / Blue | #4D9FFF | Alternate accent |
| Accent / Green | #00D68F | Alternate accent |
| Accent / Amber | #FFB830 | Alternate accent |
| Accent / Pink | #FF5C93 | Alternate accent |

## Typography
- Font family: Material 3 system sans-serif (platform default)
- Body baseline: 14–16px equivalent (Flutter bodyMedium/bodyLarge)
- Heading pattern: headlineSmall/headlineMedium with semibold-to-bold emphasis (600–700)
- Utility text: labelMedium/labelLarge for chips, tab labels, metadata
- Suggested token scale for generated screens: 11 / 13 / 15 / 17 / 20 / 24 / 30 / 38
- Tone: direct, concise, developer-oriented (sentence case body copy)

## Spacing & Layout
- Base grid unit: 4px
- Typical paddings: 8, 12, 16, 24
- Page horizontal margin: 16px compact/mobile, 24px standard, wider via centered constrained content where needed
- Card internal padding: 16px
- Section gap: 16px compact, 24px standard
- Desktop behavior: sidebar + content split layouts for dashboard/tools when width permits
- Responsive checkpoints to validate: xs (<480), md (768+), xl (1280+)

## Shape, Elevation, Borders
- Corner radius: 16px default; 12px in compact mode
- Chips/tiles: 12–14px radii commonly used
- Card elevation: flat (0) with explicit border for separation
- Border style: 1px outlines using Border token
- Inputs: filled containers with bordered outline, focused border in active accent (1.5px)

## Component Patterns
- Navigation shell:
  - Desktop: persistent sidebar + top app bar actions.
  - Mobile/tablet: drawer/bottom-sheet patterns with same information hierarchy.
- Buttons:
  - Primary: FilledButton using accent.
  - Secondary: FilledButton.tonal / OutlinedButton.
  - Tertiary: TextButton for low-emphasis actions (e.g., Home link).
- Cards/Panels:
  - Bordered rounded cards for grouped actions and status.
  - Tool screens commonly use two-column or split-pane layouts on desktop.
- Inputs/editors:
  - Multiline code-like editors for text transforms.
  - Helper and status text near controls.
- Status indicators:
  - Small colored dot + concise status label (success/info/warn/error semantics).

## Interaction & Motion
- Use Material 3 interaction states (hover, focus, pressed, disabled) for all controls.
- Transition style: subtle and fast; avoid decorative motion.
- Page transitions: Android zoom, iOS Cupertino, desktop fade-upward.
- Loading indicators: linear progress for long PDF/tool operations; local status text updates.
- Feedback: SnackBar for action confirmations/errors; keep copy short and actionable.

## Accessibility & UX Rules
- Exactly one primary CTA in each viewport section where actions compete.
- Contrast target: WCAG AA minimum (4.5:1 body text, 3:1 large text).
- Every input has a visible label (never placeholder-only).
- Error states include both color + text explanation.
- Touch targets minimum 44x44 where relevant.
- Keyboard reachable controls across desktop/web flows.

## Product Context Rules (Dexor-specific)
- Communicate “Offline-first” and “Local processing” consistently.
- Avoid cloud upload metaphors unless explicitly optional.
- Tool screens should emphasize:
  1. Input/source area
  2. Operation controls
  3. Output/preview area
  4. Copy/export/share actions
- Keep terminology technical but friendly (developer utility tone).

