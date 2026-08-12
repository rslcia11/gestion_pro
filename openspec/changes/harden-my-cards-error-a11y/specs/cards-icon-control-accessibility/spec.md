# Cards Icon Control Accessibility Specification

## Purpose

Ensure the icon-only interactive controls on the My Cards AppBar are usable
by screen-reader users and meet platform minimum touch-target sizes.

## Requirements

### Requirement: Icon-only controls expose a semantic label

Every icon-only interactive control on the My Cards AppBar MUST expose a
non-empty `Semantics` label describing its action, so screen readers announce
intent instead of "button" or a jumble of nearby text.

#### Scenario: Screen reader focuses the back button

- GIVEN a screen-reader user navigates to the My Cards AppBar
- WHEN focus reaches the leading back control
- THEN the announced label describes the action (e.g., "Volver")

#### Scenario: Screen reader focuses the avatar-edit control

- GIVEN a screen-reader user navigates to the My Cards AppBar
- WHEN focus reaches the avatar/edit-profile control
- THEN the announced label describes the action (e.g., "Editar perfil")

### Requirement: Interactive AppBar icon controls meet minimum touch target

Icon-only interactive controls on the My Cards AppBar MUST have a tappable
area of at least 44×44 logical pixels, and SHOULD be 48×48 to satisfy both
iOS (44pt) and Android (48dp) minimums.

#### Scenario: Back button tap target

- GIVEN the My Cards AppBar is rendered
- WHEN the leading back control's rendered size is measured
- THEN its width and height are each ≥ 48 logical pixels

#### Scenario: Avatar-edit tap target

- GIVEN the My Cards AppBar is rendered
- WHEN the avatar/edit-profile control's rendered size is measured
- THEN its width and height are each ≥ 48 logical pixels

### Requirement: Shared component defaults are not changed without review

Because `IconActionButton`'s 40×40 default is relied upon by other screens,
touch-target fixes for My Cards MUST be applied via local `size:` overrides
on this screen's call sites, not by changing `IconActionButton`'s default.

#### Scenario: Other screens using IconActionButton are unaffected

- GIVEN other screens instantiate `IconActionButton` without a `size:` override
- WHEN this change ships
- THEN those screens continue rendering at the existing 40×40 default
