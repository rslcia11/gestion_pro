# Accent Contrast Tokens Specification

## Purpose

Provide a documented, reusable way to render accent colors as text/icon
directly on white/paper-white surfaces while meeting WCAG AA (4.5:1) contrast,
replacing ad-hoc hardcoded fixes.

## Requirements

### Requirement: Contrast-safe accent variants exist for accents used as text-on-white

For every accent color that `my_cards_screen.dart` renders as text or icon
directly on a white/paper-white surface (purple, pink, amber, green), the
design system MUST provide a documented darkened variant meeting a 4.5:1
contrast ratio against white.

#### Scenario: Amber variant meets contrast floor

- GIVEN `AppColors.accentAmberOnLight` is rendered as text on `paper-white`
- WHEN its contrast ratio against white is computed
- THEN the ratio is ≥ 4.5:1

#### Scenario: Green variant meets contrast floor

- GIVEN `AppColors.accentGreenOnLight` is rendered as text on `paper-white`
- WHEN its contrast ratio against white is computed
- THEN the ratio is ≥ 4.5:1

#### Scenario: Lookup returns the documented variant for a known accent

- GIVEN a known accent color (`accentPurple`, `accentPink`, `accentAmber`, or
  `accentGreen`)
- WHEN `AppColors.onLightOf(accent)` is called with it
- THEN it returns that accent's documented `*OnLight` constant

#### Scenario: Lookup is safe for an unmapped color

- GIVEN a color with no documented `*OnLight` variant
- WHEN `AppColors.onLightOf(color)` is called with it
- THEN it returns the input color unchanged (no crash, no silent wrong color)

### Requirement: My Cards screen uses the tokens instead of ad-hoc hex

`my_cards_screen.dart` MUST NOT hardcode contrast-fix hex values; every place
an accent renders as text/icon on a white card surface MUST go through
`AppColors.onLightOf()` or a named `*OnLight` constant.

#### Scenario: Reward banner no longer hardcodes a hex value

- GIVEN `_RewardBanner`'s title text previously used `Color(0xFF8A6D00)`
  directly
- WHEN the change ships
- THEN it uses `AppColors.accentAmberOnLight` instead

#### Scenario: Progress percentage and mini-stat text use the safe variant

- GIVEN a loyalty card renders its progress percentage and mini-stat
  icon/value in an accent color
- WHEN that accent is one of the four rotating card accents
- THEN the rendered color is `AppColors.onLightOf(accent)`, not the raw
  accent

### Requirement: New tokens are documented in DESIGN.md

`DESIGN.md`'s color section MUST list the new `*OnLight` tokens with their
hex values and intended usage (text/icon on light surfaces only).

#### Scenario: Design system reviewer looks up the new tokens

- GIVEN a reviewer opens `DESIGN.md`'s Colors section
- WHEN they look for a contrast-safe variant of an accent
- THEN they find the `*OnLight` token names, hex values, and usage guidance
