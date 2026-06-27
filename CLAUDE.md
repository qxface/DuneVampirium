# Project: Dune Vamperium

## What This Is
A digital worker-placement / deck-building board game built in Godot 4 using GDScript.
Mechanically derived from **Dune: Imperium — Uprising** (with spies as a core mechanic, not a
bolt-on expansion), but the **theme is gothic horror** — vampires as the central faction/identity,
alongside other classic gothic monsters. This is **not** a Dune reskin in flavor at all; only the
underlying worker-placement/deck-building mechanics are adapted, with original factions, resources,
and cards. This file gives Claude persistent context across sessions. Update it as the project evolves.

---

## Meta Instructions for Claude
- When we make a significant architectural or design decision during a session, add it to the relevant section of this file before the session ends.
- If a new system or scene is created, add it to the Project Structure section.
- Keep entries concise — one or two lines per decision is enough.
- Do not remove old decisions; mark them as superseded if replaced (e.g., "~~old approach~~ → new approach").

---

## Tech Stack
- **Engine:** Godot 4.x
- **Language:** GDScript
- **Platform target:** [e.g., PC / Windows / Mac — fill in]

---

## Design Reference: Dune Imperium / Uprising

This project's rulebooks live in `DuneManuals/` (base game, Rise of Ix, Immortality, Uprising,
Bloodlines). **Uprising is the baseline reference** for the round structure and core systems;
older-game-only mechanics (Mentat) are not used. The Dune Imperium family is a mechanical
reference only — none of its theme, names, or IP carry over.

### Core loop (adapted)
1. **Round Start** — reveal a Conflict-equivalent card; first player begins.
2. **Player Turns** — each player has **2 Actions per round** (baseline — whether this can be
   increased mid-game is an open question). Each Action is spent as one of:
   - **Place** — select **at least one Minion and at least one Plan** (multiples of either are
     optional) and send them as a set to an open board Space. The **union of pips** across every
     selected card must satisfy the Space's requirement clause. Gain Space + card effects.
   - **Hold** — reserve the Action to activate one Minion's Reveal power later, during the Reveal
     phase. The chosen Minion must still be in hand (not placed on a Space) when activated.
   - **Recall** — return any number (0 to all) of your Minions currently on the board back to your
     ready Minion hand. (Recalling 0 is legal but pointless.)
   A player who has spent/held all Actions must Reveal on their next turn; a player may also choose
   to Reveal early with unused Actions remaining (those are simply forfeited, unless held).
3. **Reveal** — every Plan still in hand automatically triggers its Reveal power for free; each
   *held* Action additionally activates the Reveal power of one chosen Minion still in hand; gain
   Reveal effects; spend pooled Money/Blood/Secret/Rapport to acquire new cards; set Combat strength.
4. **Combat** — players may play Combat Intrigue-equivalent cards, then rewards go out by strength
   (1st/2nd/3rd place).
5. **Makers** — bonus resource accumulates on unattended resource Spaces.
6. **Round End** — players draw Plans back up to hand size (Minions are **not** redrawn — see
   below), first-player marker passes, next round begins (or Endgame triggers at target Victory
   Points or when the Conflict deck empties).

### Adapted vs. base game — current mapping
| Dune Imperium / Uprising concept | This project's equivalent |
|---|---|
| Single card sent an Agent | **Minion/Plan set** sent per Action: ≥1 Minion + ≥1 Plan, multiples of either optional, union of all selected cards' pips must satisfy the Space |
| Agent meeples (fixed count, recalled automatically each round) | **Minions are a standing roster** — acquired once, never reshuffled/discarded by normal play, stay placed on a Space indefinitely until the player spends an Action on **Recall** |
| 2 (later 3) Agents per round | **2 Actions per round** baseline; each Action is Place / Hold / Recall (expandability TBD — open question) |
| Reveal turn reveals all remaining hand for free | **Plans** auto-reveal for free; **Minions** require spending 1 held Action each to activate their Reveal power |
| 8 pips: 3 action icons + 4 Faction icons + 1 Spy eye | **Action** pips (verbs: Negotiate, Fight, Hunt) · **Origin** pips (Vampire, Supernatural, Human) · **Aspect** pips (adjectives: Hideous, Insane, Arcane) · **Faction** pips (a large, swappable pool — see below) |
| Solari / Spice / Water / Persuasion | Money / Blood / Secret / Rapport (see `GameEnums.CostType`) |
| Four fixed Factions (Emperor, Spacing Guild, Bene Gesserit, Fremen) | **Many possible Factions** — Primori/Volupta/Vorace (the existing `GameEnums.RequirementType` Clans) are three of these Factions, not a separate system; which Factions are in play in a given game is determined by which Spaces are included on the board (a game could feature 0, 3, 7, or more Factions) |
| Board Space Agent-icon requirement | Space `requirement_clauses`: OR of AND-clauses over Origin + Action + Aspect (+ future Faction) pips, satisfied by the **union** of pips across an entire selected Minion/Plan set |
| Spies / observation posts / Infiltrate / Gather Intelligence | **Core mechanic from day one** (not deferred like an expansion) — design TBD |
| Sandworms, Shield Wall | Not yet planned — future consideration |
| CHOAM contracts module | Not yet planned — future consideration |
| Dreadnoughts, Tech tiles (Rise of Ix) | Not yet planned — future consideration |
| Sardaukar Commanders, Tech Module (Bloodlines) | Not yet planned — future consideration |

When implementing a system, check the matching rulebook in `DuneManuals/` for the exact mechanical
detail, then adapt names/resources/factions per the mapping above rather than copying Dune terminology.

---

## Project Structure
*(Update this as new scenes and scripts are added)*

```
res://
├── DuneManuals/         # Reference rulebooks (Dune Imperium base + 4 expansions) — design reference only, not shipped
├── addons/              # PaletteTools, Todo_Manager (editor plugins)
├── assets/              # Fonts, icons (origins/clans/resources/actions/aspects/tags/effects), styleboxes, card art
├── data/
│   ├── card_data/       # CardData resource script (Minion / Plan cards)
│   ├── space_data/      # SpaceData + SpaceRequirement resource scripts
│   ├── effects/         # Effect base class + concrete effects (draw_card, gain_resource, ...)
│   ├── minions/         # Minion card .tres instances
│   ├── plans/           # Plan card .tres instances
│   ├── spaces/          # Board Space .tres instances (moved here from project root)
│   └── game_enums.gd    # CostType, RequirementType enums + icon path lookups (static helpers cost_icon_path / requirement_icon_path)
├── game_pieces/         # Scenes/scripts for board, card, minion, plan, space (incl. zoom variants), card_scroller, action_display
│   └── long_press_button.gd  # LongPressButton extends Button — 0.5s hold triggers long_pressed signal with fill-progress animation
└── globals/             # availability, card_zoom, event_manager, helper, space_zoom (singletons/autoloads)
    ├── player_state.gd  # PlayerState (RefCounted) — per-player resources, VP, rapport, all card zones, action economy
    └── game_state.gd    # GameState autoload — 4 players, round/turn state machine, Place/Reveal/EndTurn methods
```

---

## Card System

### Card Data (`CardData` Resource, `data/card_data/card_data.gd`)
- Two `CardType`s: **PLAN** and **MINION**.
- **Origin** pips (Minion-side identity): Vampire, Supernatural, Human — a Minion must have at least
  one. Minions always carry at least one Origin pip; Plans typically don't.
- **Action** pips (verbs): Negotiate, Fight, Hunt. Plans tend to carry Action pips.
- **Aspect** pips (adjectives): Hideous, Insane, Arcane.
- **Faction** pips: not yet implemented in `CardData` — planned new pip category. Minions tend to
  carry Faction pips. There will eventually be many possible Factions, and **Primori/Volupta/Vorace
  (the existing Clans in `GameEnums.RequirementType`) are three of them** — Clans are not a separate
  system from Factions. Only a subset of all Factions is in play in any given game, determined by
  which Spaces are on the board.
- Five possible lifecycle actions per card, each independently configurable with cost / requirement / effects:
  **Acquire, Agent, Reveal, Discard, Trash** — mirrors Dune Imperium's Agent-box/Reveal-box split, extended
  with Discard and Trash actions (cf. Uprising's Discard icon and Immortality's Unload concept).
- Each action has: `*_cost` (`GameEnums.CostType`) + `*_cost_amount`, `*_requirement` (`GameEnums.RequirementType`)
  + `*_requirement_amount`, and an `Array[Effect]` of effects. An action is only "active" if its effects array
  is non-empty; the Resource has a built-in validator (`status_check`) that flags inconsistent cost/requirement
  configuration directly in the Inspector.
- `card_name` is derived from the resource's filename, not a separate field.
- Pip-naming convention: Action pips are verbs (Negotiate, Fight, Hunt), Aspect pips are adjectives
  (Hideous, Insane, Arcane) — keep new pips consistent with this pattern.

### Space Data (`SpaceData` Resource, `data/space_data/space_data.gd`)
- A Space has zero or more `SpaceRequirement` clauses (OR'd together; each clause ANDs together up to one
  Origin + one Action + one Aspect pip). An empty clause list = open space, any selected set qualifies.
- A Space currently exposes one action: **Agent** (cost/requirement/effects), matching the Dune Imperium board
  space model (cost to send a Minion/Plan set there, optional Influence-equivalent requirement).
- `is_satisfied_by(minion, plan)` currently takes a single Minion + single Plan; needs to generalize
  to a **set** (multiple Minions, multiple Plans) per the new design — see Systems In Progress.

### Availability (`globals/availability.gd`)
- Already implements the **new** selection rule ahead of the rest of the codebase: a Space is
  available only when at least one Minion AND at least one Plan are selected, and the **union of
  pips across all selected Minions and Plans** satisfies at least one of the Space's requirement
  clauses. This logic is correct for the current design and should be the reference implementation
  when `SpaceData`/`SpaceRequirement` are generalized to multi-card sets.

### Effects (`data/effects/`)
- `Effect` base class with concrete subclasses (`draw_card.gd`, `gain_resource.gd`, ...). Cards and Spaces both
  reference `Array[Effect]` rather than encoding behavior inline — keeps card/space data declarative and lets
  new effects be added without touching `CardData`/`SpaceData`.

### Card Visuals / Scenes (`game_pieces/`)
- `card.tscn` / `card.gd` — base card visual; `minion.tscn`, `plan.tscn`, `space.tscn` — type-specific scenes,
  each with a `_zoom` variant (`minion_zoom.tscn`, `plan_zoom.tscn`, `space_zoom.tscn`) for an enlarged inspect view.
- `board.tscn` — the game board container.
- `card_scroller.gd` — hand/row scrolling UI.
- `action_display.gd` — static utility class; `populate(panel, effects, cost, req)` finds the `IconMargin/IconContainer` path inside a Panel and fills it with icons; `populate_into(hbox, effects, cost, req)` accepts an HBoxContainer directly (used by Space/SpaceZoom). Icon order: requirement type → requirement.png → cost type → cost.png → effect icons.

### UI Layout
- *(Not yet documented — describe hand area / play field / board layout here once settled.)*

---

## Systems In Progress
*(Move items here when you start working on them; move to "Completed" when done)*

- [ ] Action economy (2 Actions/round; Place / Hold / Recall per Action) — Place and Reveal wired; Hold and Recall not yet implemented
- [ ] Minion standing-roster lifecycle (acquired once, placed/recalled, never auto-discarded/reshuffled)
- [ ] Plan deck-building lifecycle (drawn, played, discarded, reshuffled, refilled to hand size at round end)
- [ ] Faction pip category on `CardData` + swappable per-game Faction pool tied to which Spaces are on the board
      (Primori/Volupta/Vorace will become three Factions among many, not a separate Clan layer)
- [ ] Plan "In Play" area: a Plan moves from hand → In Play (not discard) when used in a Place action;
      at Reveal, both In Play Plans and any remaining-in-hand Plans (which auto-reveal) move to a
      discard pile; discard reshuffles into the deck when empty — mirrors Dune Imperium's standard
      card lifecycle
- [ ] Action-count upgrades: some card/board effect can grant a 3rd+ Action beyond the 2-Action baseline
      (mirrors Dune Imperium's Swordmaster/3rd-Agent unlock) — not yet designed
- [ ] Combat/troop system: separate troop tokens deployed to the Conflict track (per Dune Imperium),
      but many Minions will have Reveal powers that add Combat strength directly — not yet implemented
- [ ] Faction Tracks: each Faction has its own progress track, advanced via Faction-specific Spaces;
      some Factions grant unique effects at track milestones (e.g. the **Tenebris** clan — a
      stealth/spying-focused Faction analogous to Uprising's Bene Gesserit — has powers that place
      spies, and "Tenebris Spaces" often grant a spy-placement Effect when used)
- [ ] Multi-Minion Space representation: when multiple Minions are sent together in one Place Action,
      they collapse into a single player-colored meeple icon on that Space (cards visually "transform"
      into the meeple); long-press the meeple to expand and see the individual Minion cards it contains
- [ ] Game Setup / Configuration flow: before a game starts, players choose the Victory Point target,
      which Factions are active, which board Spaces/cards are in the pool, and whether optional
      mechanics (e.g. Spies) are enabled at all — full per-game configurability is a core design goal,
      not just a "nice to have"
- [ ] Multiplayer rollout (staged): **single-player → local hot-seat → async multiplayer** (each
      player "ends turn," the next player picks up and sees prior moves, moves are posted to a central
      server). Architecture recommendation: build the turn/action-resolution logic as a `GameState`
      data layer + serializable `Action` objects (Place/Hold/Recall/Reveal/Acquire) that don't depend on
      Godot nodes — UI (Card/Space, `Availability`) should call into this layer rather than being the
      source of truth. This makes hot-seat (swap active player index) and later async play (replay a
      logged sequence of Actions) straightforward instead of a rewrite.
- [ ] Spies (core mechanic, not deferred) — design not yet started
- [ ] Game state & turn management (Action economy / Reveal / Combat / Makers / Round End structure)
- [ ] Player actions / card play logic
- [ ] Win/loss conditions (target Victory Points / empty Conflict deck)

### Future considerations (not yet started, noted for roadmap)
- [ ] Sandworms / Shield Wall equivalent
- [ ] CHOAM-style contracts module
- [ ] Dreadnoughts / Tech tiles (Rise of Ix-style)
- [ ] Sardaukar Commanders-style recruitable unit + skills (Bloodlines-style)

---

## Completed Systems
- [x] Card data (Resources) — `CardData`, `SpaceData`, `SpaceRequirement`, `GameEnums`
- [x] Effect system scaffold (`Effect` base + `draw_card`, `gain_resource`)
- [x] Card visual scenes (card/minion/plan/space + zoom variants)
- [x] Basic UI layout (board, card_scroller)
- [x] Space-availability logic for multi-card sets (`globals/availability.gd`) — already matches the
      confirmed design (≥1 Minion + ≥1 Plan, union of pips)
- [x] Pip renaming pass: `politics`→`negotiate`, `battle`→`fight`, `madness`→`insane`,
      `sorcerous`→`arcane` across `CardData`, `SpaceRequirement` (enum + methods), `SpaceData`
      (comments), `Space` (icon path lookups), `Availability`, `Card`, affected `.tres` card data,
      and asset filenames (`battle.png`→`fight.png`, `intrigue.png`→`negotiate.png`)
- [x] `SpaceData.is_satisfied_by` / `SpaceRequirement.is_satisfied_by` generalized to accept arrays of CardData (≥1 Minion + ≥1 Plan) and union their pips — matches `Availability`'s logic
- [x] Action icon display system — `ActionDisplay` static class populates action panels (Acquire/Agent/Reveal/Discard/Trash on cards; Agent on spaces) with cost, requirement, and effect icons. Effect icons are class-level virtual `get_icon()` on each `Effect` subclass. `GameEnums` provides static icon-path helpers for cost and requirement types. Space uses `populate_into(action_container, ...)` with a scene-defined `ActionContainer` HBoxContainer; cards use `populate(panel, ...)` with a programmatically-created `IconMargin/IconContainer` hierarchy. Icons hidden on non-zoom cards; shown on PlanZoom, MinionZoom, Space, and SpaceZoom.
- [x] `PlayerState` class (`globals/player_state.gd`) — all per-player data: VP, Money/Blood/Secrets, Rapport dictionary (faction→int), all five card zones (ready_minions, placed_minions, plan_draw_pile, plan_hand, plan_in_play, plan_discard), actions_per_round/actions_remaining, has_revealed.
- [x] `GameState` autoload (`globals/game_state.gd`) — 4-player array, current_player_index, round_number, turn state machine; `execute_place()`, `execute_reveal()`, `end_turn()`, `_advance_player()`, `_end_round()`; emits `state_changed` signal after every mutation.
- [x] `LongPressButton` (`game_pieces/long_press_button.gd`) — extends Button; 0.5s hold emits `long_pressed`, animates a white fill overlay during hold; cancels cleanly on button_up. Assigned to SendMinionsButton, RevealButton, EndTurnButton in board.tscn.
- [x] Turn engine wired in `board.gd` — `_update_button_states()` drives disabled state of all 3 buttons; SendMinionsButton also requires a valid Minion+Plan+Space selection. `_do_place()` calls `GameState.execute_place()`, fires `Space.add_minion_meeple()`, and queue_frees placed card nodes. `_do_reveal()` and `_do_end_turn()` call through to GameState.
- [x] In Play panel — added programmatically in `board.gd`; shows top card image + count badge; hidden when pile is empty; long-press stubbed (TODO: zoom popup).
- [x] Meeple on Space — `Space.add_minion_meeple(card_datas)` places a 75×50 minion.png icon centered on the Space's upper-left corner; stores placed CardData for popup; own long-press opens CardArrayPopup; occupied spaces cannot be selected; `clear_meeple()` removes it.
- [x] `CardArrayPopup` autoload (`globals/card_array_popup.gd`) — reusable multi-card viewer: dark overlay, scrollable HBox of Minion/Plan scene instances, title label, Close button, Escape key support. Used by: meeple long-press (shows collected minions), In Play panel long-press (shows in-play plans). Future uses: buy/discard pickers, opponent hand reveals.

---

## Key Decisions Log
*(Claude: append decisions here as they are made, newest at the bottom)*

| Date | Decision | Reason |
|------|----------|--------|
| —    | Cards stored as Resources rather than raw dictionaries | Easier to edit in Godot Inspector, type-safe |
| —    | GDScript chosen over C# | Simpler, no compilation step, fits project scale |
| 2026-06-26 | Mechanically based on Dune: Imperium — Uprising, reskinned with original vampire theme/factions/resources (not Dune IP) | Keep proven worker-placement/deck-building structure while making the game legally and creatively our own |
| 2026-06-26 | ~~Every Agent turn requires playing a Minion + Plan pair together~~ → superseded same day, see below | — |
| 2026-06-26 | Spies are a core mechanic from the start, not a deferred expansion system | Confirmed direction — spies are central to this game's identity rather than optional depth |
| 2026-06-26 | Sandworms, CHOAM contracts, Dreadnoughts/Tech tiles, and Sardaukar Commanders are deferred to "future considerations" | Keep initial scope to core loop + Minion/Plan/Space system + spies before layering in expansion-style systems |
| 2026-06-26 | Theme finalized as **gothic horror** (vampires + other gothic monsters) — not a Dune reskin in flavor at all, only mechanics are adapted | Original IP, original tone; clean separation from Dune branding |
| 2026-06-26 | Sending a Minion/Plan set to a Space requires **at least one Minion and at least one Plan**, with optional multiples of either, and the **union of pips** across the whole set must satisfy the Space — supersedes the earlier "exactly one Minion + one Plan pair" decision | More flexible/strategic than a strict 1:1 pair; matches what `Availability` already implements |
| 2026-06-26 | Action pips renamed to verbs (Negotiate, Fight, Hunt); Aspect pips renamed to adjectives (Hideous, Insane, Arcane); new Faction pip category planned (large pool, board-configurable subset per game) | Clearer naming convention; avoids "Politics"/"Intrigue" confusion with Dune Imperium's Intrigue cards; "Sorcerous" → "Arcane" reads better as an adjective |
| 2026-06-26 | Players get **2 Actions per round** baseline; each Action is spent as **Place** (send a Minion/Plan set to a Space), **Hold** (bank the Action to activate one Minion's Reveal power later, card must stay in hand), or **Recall** (return 0–all placed Minions to hand) | Replaces the Dune Imperium Agent-meeple model; Minions are persistent board pieces, not single-use sends |
| 2026-06-26 | Minions are a **standing roster** (acquired once, never deck-built/discarded/reshuffled); Plans remain deck-built (drawn/played/discarded/reshuffled, refilled to hand size at round end) | Reflects that players accumulate Minions over the game rather than cycling them like a normal deck-builder card |
| 2026-06-26 | Renamed pips in code and assets to match new terminology: `politics`→`negotiate`, `battle`→`fight`, `madness`→`insane`, `sorcerous`→`arcane` (including `.tres` data and `battle.png`/`intrigue.png` asset renames) | Keep code/data in sync with finalized naming so Inspector and runtime match design docs |
| 2026-06-26 | Primori/Volupta/Vorace (existing Clans in `GameEnums.RequirementType`) ARE three of the many Faction pips — not a separate system from Factions | Avoids building two parallel faction-like systems; Clans simply become the first three entries in the larger Faction pool |
| 2026-06-26 | Plan cards used in a Place action move to an "In Play" area (not discarded immediately); at Reveal, In Play Plans and any auto-revealed in-hand Plans move to a discard pile that reshuffles when empty | Plans work like standard Dune Imperium cards — play → in play → discard → reshuffle → redraw to hand size each round |
| 2026-06-26 | Combat strength still comes from separate troop tokens deployed to the Conflict track (Dune Imperium model unchanged); however, many Minions will have Reveal powers that add Combat strength directly | Keeps the proven troop/Conflict structure while letting persistent Minions meaningfully contribute to Combat without redesigning the whole system |
| 2026-06-26 | The 2-Actions-per-round baseline can be increased via a card or board upgrade/effect (mirrors Dune Imperium's 3rd-Agent unlock) | Preserves a familiar progression hook from the reference game; exact upgrade mechanism TBD |
| 2026-06-26 | Multiple Minions sent together in one Place Action collapse into a single player-colored meeple icon on the Space (long-press expands to show contained Minion cards) | Avoids visual clutter from many cards piled on one Space; leans into the digital-only ability to transform cards into a compact token |
| 2026-06-26 | Some Factions (vampire clans) are stealth/spy-focused, analogous to Uprising's Bene Gesserit — e.g. the **Tenebris** clan has spy-placement powers, and "Tenebris Spaces" often grant a spy-placement Effect | Ties the Spy core-mechanic into the Faction system thematically and mechanically rather than bolting it on separately |
| 2026-06-26 | Victory Point target, active Factions, board Spaces, and available cards (and eventually whether mechanics like Spies are enabled at all) will be configurable at game setup, not fixed | Full per-game configurability is a core design goal — e.g. "play to 25 with 6 Factions" vs. "play to 4, no Spies" |
| 2026-06-26 | Multiplayer will roll out in stages: single-player first, then local hot-seat, then async multiplayer (moves posted to a central server, next player resumes and sees prior moves) | Incremental path to the eventual async-multiplayer goal; recommended to build turn/action resolution as a Godot-node-independent data layer (`GameState` + serializable Actions) now so each stage doesn't require a rewrite |
| 2026-06-26 | `GameState` + `PlayerState` built as a Godot-node-independent data layer from day one — 4 players always (AI stubs fill empty seats), real `current_player_index` and `players: Array[PlayerState]` from the start | Avoids a rewrite when hot-seat and async multiplayer arrive; AI stub = `is_ai = true`, switching UI is the only thing deferred |
| 2026-06-26 | Rapport modelled as `Dictionary` (String faction_name → int) on `PlayerState` | Faction pool is per-game-configurable so a fixed enum would be premature; String keys until Faction pips become an enum |
| 2026-06-26 | Turn order: each player takes 1 action (Place or Reveal) then passes; round ends when all 4 players have revealed — interleaved like Dune Imperium, not "all actions then all reveals" | Matches Dune Imperium Uprising's interleaved model |
| 2026-06-26 | All 3 board action buttons (SendMinions, Reveal, EndTurn) use `LongPressButton` with 0.5s hold + fill-progress animation to prevent accidental activation | Touch-friendly design; consistent with Space long-press zoom threshold |
| 2026-06-26 | After a Place action: minion scene nodes are queue_freed (meeple on Space is their visual proxy), plan scene nodes are queue_freed (In Play panel is their visual proxy) | Clean scene tree; data lives in GameState; nodes re-instantiated on Recall |

---

## Conventions & Patterns
*(Add coding conventions here so Claude stays consistent across sessions)*

- Use `snake_case` for variables and functions (GDScript standard)
- Card/Space Resources use `@tool` + a computed `status_check` property to surface data-validation
  warnings directly in the Inspector — follow this pattern for new Resource types where misconfiguration
  is easy (e.g. cost set but no effects).
- Cost/requirement/effect triples are repeated per lifecycle action (Acquire/Agent/Reveal/Discard/Trash)
  rather than using a generic nested struct — keep this flat pattern for consistency unless we decide to
  refactor it.
- Card and Space behavior is expressed via `Array[Effect]`, not inline logic — add new behaviors as new
  `Effect` subclasses in `data/effects/`.
- Pip naming: Action pips are verbs (Negotiate, Fight, Hunt); Aspect pips are adjectives (Hideous,
  Insane, Arcane); Origin pips are nouns (Vampire, Supernatural, Human). Keep new pips consistent
  with whichever part-of-speech pattern matches their category.
- *(Add: signal naming conventions, node naming, etc.)*

---

## What NOT To Do
*(Add gotchas, dead ends, or approaches already ruled out)*

- Don't model Space-sends as a strict single Minion + single Plan pair — the confirmed design is a
  **set** (≥1 Minion + ≥1 Plan, multiples allowed), matched against the union of pips.
- Don't model Minions like Dune Imperium Agent meeples that auto-return every round — Minions stay
  on their Space indefinitely until the player spends an Action on Recall.
- Don't treat Minions like deck-built cards (no automatic discard/reshuffle) — only Plans are
  deck-built; Minions are a standing roster.
- Don't copy Dune Imperium terminology directly into new content (Solari/Spice/Persuasion/Factions) —
  use this project's own resource names (Money/Blood/Secret/Rapport) and pip names (Negotiate/Fight/Hunt,
  Hideous/Insane/Arcane, Vampire/Supernatural/Human).
- Don't use "Intrigue" as a pip or mechanic name — it's reserved to avoid confusion with Dune
  Imperium's Intrigue cards; the asset/icon for this pip is now named `negotiate.png`.

---

## Open Questions
*(Things not yet decided — Claude should ask before assuming)*

- How will the Plan deck / discard / "In Play" area be represented at runtime? (Array of Resources?
  Separate Deck node? Where does "In Play" live relative to hand and discard?)
- What's the exact mechanism for the Action-count upgrade (specific card? board effect? permanent
  once granted, or per-round?)
- What do Minion Reveal powers that add Combat strength look like mechanically — a flat bonus, tied
  to the Space they're placed on, tied to their Faction, etc.?
- Will cards have animations, or static for now?
- Beyond Tenebris, which other Factions exist and what are their thematic/mechanical hooks?
- Exact shape of Faction Tracks: how many milestones, what do non-Tenebris Factions grant at each step?
- Exact shape of the Game Setup/Configuration flow: what's configurable (VP target, Factions, Spaces,
  card pool, optional mechanics) vs. fixed, and what's the UI for it?
- Victory Point target and end-game trigger (10 VP / empty Conflict-equivalent deck, per Uprising) is
  the default, but both are meant to be configurable per game — what are reasonable min/max bounds?
