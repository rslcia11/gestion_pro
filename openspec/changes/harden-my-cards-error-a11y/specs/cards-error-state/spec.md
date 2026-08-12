# Cards Error State Specification

## Purpose

Give the client's My Cards screen a distinct, persistent way to communicate a
failed fetch, so it can never be confused with "you have zero cards" (a new
user) or a normal loading spinner.

## Requirements

### Requirement: Distinct error state on failed initial load

When the cards list fails to load and no cards are held from a previous
successful load, the system MUST render a persistent error view instead of
the empty-state illustration or an indefinite spinner.

#### Scenario: Fetch fails on first load

- GIVEN a client opens My Cards for the first time in this session
- WHEN the initial cards fetch fails (e.g., backend unreachable)
- THEN the screen SHOWS a persistent error view with a plain-language message
  and a retry action
- AND the screen does NOT show the "¡Empieza tu colección!" empty-state
  illustration

#### Scenario: Zero cards with no error (true empty state, unaffected)

- GIVEN a client has zero loyalty cards
- WHEN the cards fetch succeeds and returns an empty list
- THEN the screen SHOWS the existing empty-state illustration and CTA
- AND the error view MUST NOT appear

### Requirement: Retry action recovers without navigation

The error view's retry action MUST re-trigger the cards fetch without
requiring the user to leave or reload the screen.

#### Scenario: User taps retry after a failed load

- GIVEN the error view is visible after a failed initial load
- WHEN the client taps "Reintentar"
- THEN the system re-invokes the cards fetch
- AND WHEN the fetch succeeds, the screen transitions to the cards list (or
  true empty state if the account genuinely has none)

### Requirement: Background refresh errors do not duplicate messaging

When cards are already loaded and a background refresh fails, the system
SHOULD NOT show the persistent error view (the user still has valid data on
screen), and MUST NOT surface the raw exception string to the user.

#### Scenario: Background refresh fails while cards are already visible

- GIVEN the client already sees a non-empty list of cards
- WHEN a background refresh (e.g., triggered by a realtime event) fails
- THEN the screen keeps showing the existing cards list
- AND a transient, plain-language notice MAY be shown
- AND the raw error string (`Error: ${next.error}`) MUST NOT be displayed
  verbatim to the user
