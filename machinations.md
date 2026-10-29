# The Machinations Row — how card-buying works in D:V

(Renamed from "Imperium Row" — this doc was `imperium_row.md`, now `machinations.md`.)

Source for the reference mechanic: `DuneManuals/DUNE_IMPERIUM_Rules.pdf` ("Player Turn —
Reveal Turn", "Acquiring Cards") and `DuneManuals/DUNE_IMPERIUM_UPRISING_rules.pdf`
("Acquiring Cards"). D:V's Machinations Row is *inspired by* the Imperium Row but
deliberately diverges from it — see "Decisions made" below for what's different and why.

---

## 1. The reference mechanic (Dune Imperium / Uprising, for context)

Persuasion (D:V: Influence) is gained during a round, mainly from Reveal boxes, pooled from
any source, and lost entirely if unspent at the end of the Reveal turn. Spending happens only
during a player's own Reveal turn, interleaved freely with other Reveal effects. Two pools
exist: the **Imperium Row** (5 face-up cards, refilled immediately from the deck whenever one
is bought) and the **Reserve** (a couple of unlimited-copy stacks beside the Row, always
buyable). Acquired cards go straight to the buyer's own discard pile — not their hand — and
are shuffled in the next time that player's deck empties. Some cards have a one-time **Acquire
box** effect that fires the instant they're bought.

The core complaint driving D:V's redesign: **the Row has no pressure-release valve.** A bad
deal (5 cards nobody wants, or all priced out of reach) just sits there for the rest of the
game with no way to churn it.

## 2. What D:V already has that fits this model

- **`CardData` already has full Acquire-lifecycle scaffolding** — `acquire_cost`,
  `acquire_cost_amount`, `acquire_requirement`, `acquire_requirement_amount`,
  `acquire_effects`, `acquire_auto_execute`, `acquire_effective_auto_execute` — the same
  five-lifecycle-action shape as Agent/Reveal/Discard/Trash, already validated by
  `status_check`. It has never been wired to anything (no trigger call site exists yet).
- **`PlayerState.influence`** already exists and already resets to 0 in `_end_round()` — though
  see Open Questions below on *when exactly* it should reset, and see Decision below on it
  needing to become more than a flat int.
- **The "resolve effects in any order, pool across sources" philosophy is already
  established** in D:V for Agent-effect resolution (see CLAUDE.md's
  `[[auto-execute-effect-resolution]]`) — the Machinations Row reuses this same principle for
  Acquire/Discard resolution, not a new one.
- **`GainResource.INFLUENCE`** can already be attached to any lifecycle action's effects array
  (Agent, Reveal, etc.) — no engine change needed to grant baseline Influence.
- **`GameState.trash_card()`** (added for `TrashSelf`/Ronin Vampire) is the existing "remove a
  card from the game permanently" primitive, reusable if a Machinations effect ever needs to
  trash rather than discard a Row card.

## 3. Decisions made so far

### Scope
- **The Machinations Row/Deck contains Plan cards only.** Minions are acquired through
  separate, unique mechanisms spread around the board — not part of this system. (Confirms and
  finalizes the original doc's recommended-but-open Question 1.)

### The churn mechanic (the core fix)
- At the start of a player's Reveal, they may **discard one card from the Machinations Row for
  free.** Each *additional* discard that same Reveal turn costs escalating Influence: 1 for the
  2nd discard, 2 for the 3rd, 3 for the 4th, and so on.
- **Discarding and Acquiring are freely interleaved** — no fixed phase order. A player can
  discard, then buy, then discard again, in any sequence, as long as they can afford each step
  at the moment they choose it (same "any order, re-check affordability after each action"
  philosophy as the existing Agent pending-action system).
- Whenever a Row slot empties (bought *or* discarded), it's **immediately refilled** from the
  top of the Machinations deck — so a freshly-revealed replacement can also be bought/discarded
  in the same turn if the player still has resources.

### Discard pile is a shared, first-class zone
- Discarded Row cards go to a **shared Machinations discard pile** (not a per-player zone).
- It **reshuffles into the Machinations deck** once the deck runs dry — mirrors the existing
  per-player `plan_discard` → `plan_draw_pile` reshuffle pattern, just scoped to the shared
  deck. This also answers the original doc's Question 5 (what happens when the deck runs dry).
- Built explicitly as something **future effects can read/manipulate**, not just a sink — e.g.
  "acquire a card from the discard pile" or "look at the top 3 of the discard" should be
  buildable later without rearchitecting this zone.

### Influence becomes tagged grants, not a flat int
- `PlayerState.influence` needs to become a **list of tagged grants** (`amount` +
  `restriction`), not a single number. Restrictions narrow what a grant may be spent on — e.g.
  "usable only for discarding," "usable only to buy from the discard pile." The plan is to keep
  inventing new restriction flavors over time, so the underlying model needs to support
  arbitrary/growing restriction types, not just a fixed enum of two or three.
- **"Purchase or Discard" is the common/general-purpose restriction** — Influence that can fund
  either buying from the Row or the escalating discard cost. This is the baseline most Reveal
  effects will grant.
- **Spending prefers the most-restricted-eligible grant** for whatever action is being paid
  for, so general-purpose Influence is conserved for later use in the same turn.
- **Display:** the PlayerPanel Influence icon shows only the player's total "Purchase or
  Discard" (general-purpose) Influence as its plain number. If the player is also holding any
  more narrowly-restricted grant (e.g. discard-only, or discard-pile-only), the **icon turns
  gold**, and a **long-press opens a detailed breakdown** of every grant and its restriction.

### Reserve (Manipulate-style powers)
- A Reserve effect moves a Plan out of the public Row into a **personal Reserve zone**: visible
  to every player, but **purchasable only by the reserving player**.
- **Duration and expiry behavior are per-effect, not global.** Different Reserve effects can
  say different things — e.g. "reserve until the end of your next Reveal phase; if unbought,
  return it to the Machinations row," while another effect might trash the card on expiry, and
  another might shuffle it back into the deck instead. This means a Reserve `Effect` subclass
  needs its own configurable duration + on-expiry-behavior fields, following this codebase's
  existing convention of putting that kind of configurability on the Effect resource itself
  (see CLAUDE.md's Effects section) rather than a single hardcoded global rule.

### Row-slot attached bonuses — stack, and can target either party
- Effects like "put 2 Money on a Row card; whoever acquires it also gains that Money" can't be
  stored on `CardData` itself, since a `CardData` resource is shared/reused across every copy
  of that card in the game (a bonus attached to one specific instance in the Row must not leak
  onto every other copy elsewhere).
- This requires a **per-slot wrapper** around each Row card — something like a
  `MachinationsSlot` holding the `CardData` reference plus an **array** of attached
  effects/resources for that specific slot instance. This is new `GameState`-level shared
  state, and is also where a reserved card's slot-level data would need to live.
- **Bonuses stack** — multiple attachments can pile up on the same slot over time (different
  players, different effects, all landing on the same card before someone finally buys it).
  Deliberately a tactical tool: bait an opponent into buying a card they wouldn't otherwise
  want by loading it with a reward, or stack value onto a card you're already planning to buy
  yourself.
- **Beneficiary is per-attachment, not fixed** — a bonus can be written to reward whoever
  eventually *buys* the card, or to reward the *player who attached it* regardless of who ends
  up buying (a "plant a trap/investment" pattern). Each attachment needs its own beneficiary
  field (buyer vs. attaching player), and the attaching player's identity must be stored with
  the attachment so it can be resolved later, independent of who triggers the purchase.

### Deck-lookahead / preview effects
- General pattern: **"Reveal the top X cards of the Machinations deck. You may buy up to Y of
  them. Put the rest on the bottom of the deck."** X and Y are independent effect parameters
  (Y can be less than X, forcing a choice among the revealed cards).
- **No searching/tutoring for a specific card, ever** — explicit ruling. Preview effects only
  ever work off however many cards luck reveals next; they narrow *when* you see cards, not
  *which* cards you see.

### Cost-reduction effects
- **"-Y cost to cards of type X" is a valid, distinct effect family** — X can be a single pip
  (an Origin/Action/Aspect/Faction), "all cards," or some other subset. This is a **cost
  modifier applied at calculation time**, not a resource grant — mechanically different from
  the tagged-Influence-grant system even though both end up making a card cheaper to acquire.
  Reducing the cost of *one* card plays like gaining a bit more Influence; reducing the cost of
  a whole category is a much bigger lever.

### Row width can be expanded — globally or personally
- Effects/Spaces can **unlock additional Row slots**, and both flavors are wanted: a **global**
  extra slot (everyone can see and buy from it, like a temporarily-widened public Row) and a
  **personal** extra slot (only the player who unlocked it can see/buy from it — effectively a
  private extra peek into the deck). Row width is therefore not a fixed shared constant; it's a
  shared base width plus possible per-player additions.

### Free-discard count is upgradeable
- The baseline "1 free discard per Reveal" is **not a fixed constant** — it can be increased by
  board Spaces, leader-board powers, Minion Reveal powers, and likely other sources still to be
  designed. Needs to be computed per-player at Reveal time (base 1 + modifiers), the same way
  `actions_per_round` is already meant to be upgradeable rather than hardcoded.

### Reserve zone holds multiple cards
- A player's Reserve zone is **not single-slot** — a player can hold several reserved cards
  simultaneously, each with its own independent duration/expiry (per the earlier per-effect
  expiry decision). Reserving a new card does not bump or replace an existing reservation.

### Discard pile is always publicly browsable
- The shared Machinations discard pile can **always be long-pressed to view its full contents**
  — same `CardArrayPopup` pattern already used for `PlanDeck`/`PlanInPlay`/`PlanDiscard` icons
  in `PlayerPanel` — regardless of whether any effect currently interacts with it. Future powers
  that let a player actually *take from* or otherwise manipulate the discard pile build on top
  of this baseline visibility, not instead of it.

### Explicitly deferred / skipped
- **No unlimited-copy "Reserve stack"** (Prepare-the-Way/Spice-Must-Flow-style always-buyable
  filler) for v1 — the free-plus-escalating discard mechanic already solves "Row full of stuff
  nobody wants," making a floor option redundant.
- **Card pool stays automatic for now**: any Plan `.tres` not in the active
  `StartingDeckConfig` is Machinations-eligible, no curation step. Future direction (not being
  built yet): curated, savable "deck lists," with one or more selected and combined into the
  actual Machinations deck at game setup — a shared-deck analog to `StartingDeckConfig`. Keep
  this shape in mind while building the current mechanics so it isn't a rearchitecture later.

## 4. What's still missing (engine-level)

- **`GameEnums.CostType.INFLUENCE` doesn't exist** — `CostType` currently has
  MONEY/BLOOD/SECRET/RAPPORT/NONE only. Needed once `acquire_cost` wiring starts.
- **No shared/global card zone exists anywhere in `GameState` yet.** Every zone today lives on
  `PlayerState`. The Machinations Row + deck + discard pile is the first genuinely shared pool.
- **Acquire lifecycle has never been wired to a trigger call site.** Agent/Reveal have real
  pipelines; Acquire doesn't yet.
- **Not enough authored Plan content to make a Row meaningful.** Only 7 Plan `.tres` files
  exist total, and 5 are already claimed by the default starting deck — 2 Plans left over is
  nowhere near enough to fill and refill a 5-card Row for a full game.

## 5. Remaining open questions

1. **Exactly when does unspent general-purpose Influence get lost** — at round end (today's
   code) or immediately at the end of each player's own Reveal turn (rulebook-accurate, and
   would make more sense once restricted grants exist too, since a leftover discard-only grant
   sitting idle "available" during another player's turn would be misleading)?
2. **Exact data shape for tagged Influence grants** — a `String` restriction tag matched loosely
   against spend-context tags, or a small closed enum with room to grow, or something else?
   Needs a concrete design once the first restricted-grant card is actually authored.
3. **Exact shape of `MachinationsSlot`** and how its attached effects hook into the existing
   effect-trigger pipeline (`GameState._trigger_effects()`) — does an attached bonus fire
   *in addition to* the card's own `acquire_effects`, and does it need to survive a Reserve
   (i.e. if a slot bonus exists and the card gets reserved, does the bonus travel with it)?
4. **How is a personal (non-global) extra Row slot represented in the UI?** — a private strip
   only that player's client renders alongside the shared Row, a modal, something else? Needs a
   concrete answer once the first slot-unlocking effect is actually authored.
5. **Cost-modifier system shape** — do "-Y cost to cards of type X" effects apply as a
   live-recomputed discount whenever cost is checked/paid (like the existing pip/requirement
   matching in `Availability`), or as a value baked in at the moment the modifier is granted?
   Recomputed seems safer (matches this codebase's general preference for derived state over
   cached values) but needs confirming once the first cost-reduction card is authored.
6. **Deck-preview effect UI** — "reveal X, buy up to Y, rest to bottom" needs some kind of
   temporary popup/selection UI distinct from the persistent Row (the revealed cards aren't a
   permanent zone, they resolve and vanish within one effect). Likely reuses `CardArrayPopup`
   with buy buttons rather than a new widget, but not designed yet.
7. **Free-discard-count modifier tracking** — same open shape question as `actions_per_round`
   upgrades in CLAUDE.md's Open Questions: is a granted extra free discard permanent once
   unlocked, or per-round/per-source? No mechanism exists yet for either.

---

*(Superseded content from the original `imperium_row.md` — the reference-mechanic writeup in
§1 and the "what D:V has/is missing" sections in §2/§4 — has been preserved above rather than
dropped, since it's still accurate context.)*
