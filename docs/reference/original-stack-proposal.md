# A modern Codex-first stack for your retro Gnostic RPG

## Bottom line

I dug through the current engine releases, Godot tooling, VS Code integration, Codex documentation, dialogue systems, testing frameworks, Aseprite, and AI-specific pixel-art tooling as they stand on **September 30, 2026**.

For the game we have been talking about, I would build it like this:

| Layer | Recommendation | Version / status |
|---|---|---|
| Engine | **Godot Standard** | **4.7.2** |
| Game language | **Typed GDScript** | Bundled with Godot |
| Code editor | **VS Code** | Current stable |
| Godot VS Code integration | **Godot Tools** | **2.7.1** |
| Coding agent | **OpenAI Codex extension** | Current extension |
| Version control | **Git** | Current stable |
| Pixel-art editor | **Aseprite** | **1.3.18.6** |
| AI pixel-art generation | **PixelLab** | Optional, current cloud/API |
| Dialogue | **Dialogue Manager** | **4.1.0 for Godot 4.7** |
| Automated tests | **GUT** | **9.7.0 for Godot 4.7 compatibility** |
| Runtime backend | **None** | Seriously |
| Node / npm | **None for the game** | Add only if a later tooling need justifies it |
| Database | **None** | Godot resources/files are enough |
| Runtime LLM | **None initially** | Generate content offline instead |

That is the stack I would actually use rather than giving you a giant menu of possibilities.

**Godot 4.7.2 is the current stable maintenance release** as of this research. Godot explicitly says 4.7.2 has no known incompatibilities with 4.7.1 and encourages users on the 4.7 line to upgrade. citeturn20view2

And I would specifically use the **standard Godot build with GDScript**, not the .NET build. Godot has a dedicated 2D renderer and its own game-specific scripting language, so adding C#, Node, TypeScript, Electron, Vite, or some browser-game framework would mostly create additional moving parts for this particular project rather than solving a problem you presently have. citeturn13search0turn20view2

The basic architecture I am recommending is therefore:

```text
                         YOUR GAME
                            │
              ┌─────────────┴─────────────┐
              │                           │
         Godot 4.7.2                 Asset pipeline
              │                           │
        typed GDScript            ┌───────┴────────┐
              │                   │                │
       ┌──────┴──────┐       PixelLab         Aseprite
       │             │        optional           │
    gameplay      narrative       │               │
       │             │            └───────┬───────┘
       │      Dialogue Manager            │
       │             │                  PNGs
       └──────┬──────┘                    │
              │                           │
          Godot scenes ◄──────────────────┘
              │
          desktop/web
             build


                  DEVELOPMENT SIDE

     VS Code + Godot Tools + Codex
                  │
             AGENTS.md
                  │
               Git
                  │
         automated smoke/tests
```

This keeps the **actual shipped game completely independent of AI services**. AI helps manufacture the game; the player does not need an AI service for the game to work.

That distinction is important.

## Why Godot and GDScript are the right center of gravity

Your instinct about JavaScript/Node makes sense because you're already a programmer and that ecosystem is familiar to a lot of full-stack developers. But for this project, I would deliberately **not use JavaScript as the runtime language**.

Godot already supplies the things that would otherwise cause you to assemble a small framework ecosystem yourself: scenes, nodes, 2D physics, input, animation, cameras, audio, UI, navigation, tile maps, resource importing, exporters, and a dedicated 2D renderer. Godot specifically describes its 2D engine as using real 2D coordinates and dedicated 2D nodes rather than treating 2D as a thin layer over a 3D engine. citeturn13search0

That matters for a game visually resembling the Mega Drive screenshot you posted.

### The tile system is already the thing you are imagining

Modern Godot uses `TileMapLayer`; the older `TileMap` approach has been deprecated in favor of composing multiple tile-map layers. The tile system can associate tiles with collision, navigation, terrain relationships, occlusion, and other metadata. citeturn1search1turn1search9

Your world can therefore look conceptually like this:

```text
World
├── Ground            TileMapLayer
│   ├── sand
│   ├── stone
│   ├── cracked earth
│   └── ritual flooring
│
├── Terrain           TileMapLayer
│   ├── cliffs
│   ├── walls
│   ├── fences
│   └── ruins
│
├── Decoration        TileMapLayer
│   ├── vegetation
│   ├── corpses
│   ├── statues
│   └── occult debris
│
├── Actors
│   ├── Player
│   ├── NPCs
│   └── Enemies
│
├── Interactables
│   ├── Doors
│   ├── Books
│   ├── Altars
│   └── Machines
│
└── Systems
    ├── WorldState
    ├── PlayerKnowledge
    ├── Dialogue
    ├── Quests
    └── SaveSystem
```

That is a much better abstraction than manually positioning thousands of individual sprites.

### Use typed GDScript

GDScript supports optional static typing on variables, constants, parameters, return values, and other declarations. Godot's own documentation says static typing can catch bugs earlier and improve editor support. citeturn14search0

So I would tell Codex to write this:

```gdscript
class_name PlayerKnowledge
extends Node

signal fact_discovered(fact_id: StringName)

var discovered_facts: Dictionary[StringName, bool] = {}
var gnosis: int = 0


func discover_fact(fact_id: StringName, gnosis_gain: int = 0) -> void:
    if discovered_facts.has(fact_id):
        return

    discovered_facts[fact_id] = true
    gnosis += gnosis_gain
    fact_discovered.emit(fact_id)


func knows(fact_id: StringName) -> bool:
    return discovered_facts.get(fact_id, false)
```

rather than loose dynamically typed code everywhere.

GDScript will probably feel trivial syntactically to you. The part you actually need to learn is **Godot's object model**:

```text
Node
Scene
Resource
Signal
Autoload
PackedScene
TileSet
TileMapLayer
AnimationPlayer
CharacterBody2D
Control
```

That's the conceptual vocabulary Codex should help you learn rather than conceal from you.

### VS Code is fully viable

Godot officially supports using VS Code as an external editor. citeturn14search4 The Godot organization's own **Godot Tools** VS Code extension supports Godot 4, typed GDScript, autocomplete, navigation, diagnostics, formatting, debugging, scene-resource navigation and a headless language-server mode. citeturn14search9

The current Godot Tools release I found is **2.7.1**, and its release notes explicitly say it is compatible with Godot 4.x. citeturn14search16

So you don't need to choose between Codex and a proper Godot development environment.

Use:

```text
Godot editor
    ↓
visual scene construction
TileSet editing
animations
collision geometry
inspector configuration

VS Code
    ↓
GDScript
data files
dialogue
tests
documentation
Git
Codex
```

That's actually an excellent division of labor.

## Codex should act like an engineer, not a slot machine

Your $20 ChatGPT subscription is useful here precisely because this is a **bounded software repository** where Codex can see files, modify them, run commands, inspect failures, and iterate.

OpenAI's current Codex documentation explicitly supports the extension in VS Code and compatible editors. It can work from editor context, and OpenAI recommends creating Git checkpoints before and after agent tasks so changes remain easy to revert. citeturn21view3

One correction to the way people often describe this: your Plus entitlement isn't best thought of as a pile of literal “Codex tokens” waiting in an account. Codex usage is governed by the current plan's usage limits; OpenAI exposes remaining usage through its usage tooling, and additional credits can be purchased once included usage is exhausted. Limits can change, so I would not architect your workflow around a fixed number that may become obsolete. citeturn7view0turn7view3

### The single most important Codex file

Put an `AGENTS.md` in the repository root.

Codex is specifically designed to read `AGENTS.md` instructions, including repository-level and more-local instructions, before working in a codebase. citeturn6view3

I would start yours approximately like this:

```markdown
# Project instructions

## Technology

- Engine: Godot 4.7.2 Standard.
- Language: typed GDScript.
- Editor integration: Godot Tools for VS Code.
- Target: 2D retro-style narrative RPG/adventure game.
- Prefer Godot built-in functionality over third-party dependencies.

## Dependency policy

Do not introduce:
- Node.js or npm dependencies
- C#/.NET
- GDExtension
- a database
- a networking backend
- additional Godot addons

unless the task explicitly requires one and the reason is explained first.

Approved addons:
- Dialogue Manager 4.1.x for Godot 4.7
- GUT 9.7.x when automated testing is introduced

## Godot conventions

- Use TileMapLayer, not deprecated TileMap.
- Use typed GDScript whenever practical.
- Prefer signals over direct coupling between unrelated scenes.
- Prefer composition over large inheritance trees.
- Keep gameplay code out of UI scenes.
- Keep narrative state separate from presentation.
- Do not modify files inside .godot/.
- Do not manually invent Godot resource UIDs.
- Do not modify imported/generated asset metadata unnecessarily.
- Never remove a working system to replace it with a framework
  without an explicit request.

## Architecture

Game systems live under:
- res://game/core/
- res://game/world/
- res://game/actors/
- res://game/interaction/
- res://game/narrative/
- res://game/ui/

Game content lives under:
- res://data/

Source art lives under:
- art/source/

Imported game-ready art lives under:
- assets/

Tests live under:
- res://tests/

## Workflow

Before changing code:
1. Inspect the relevant existing files.
2. Explain the smallest implementation approach.
3. Do not add speculative abstractions.

After changing code:
1. Parse/run the project.
2. Report errors exactly.
3. Fix regressions introduced by the change.
4. Summarize changed files.

Keep commits and changes small enough to review.
```

That file is going to save you **a ridiculous amount of agent drift**.

The crucial instruction is:

> **Do not introduce speculative abstractions.**

Agents are perfectly capable of seeing “retro RPG” and spontaneously inventing:

```text
AbstractEntityFactory
IQuestRepository
GameDomainEventMediator
ServiceLocator
EntityComponentRegistry
NarrativeDependencyContainer
```

when what you needed was a dude who walks into a temple and talks to a priest.

😂

Don't let it.

### Give Codex tasks that terminate in observable behavior

Bad task:

> Build the RPG architecture.

Much better:

> Add a `CharacterBody2D` player that moves in eight directions, stops on collision, and has an `AnimatedSprite2D`. Use typed GDScript. Do not add dependencies. Run the project after making the change.

Then:

> Add one interactable NPC. When the player enters interaction range and presses the interact action, display a dialogue balloon containing three lines of placeholder dialogue.

Then:

> Add a player knowledge state containing discovered fact IDs. Make one dialogue response appear only if `player_knows("temple_lie")` is true.

Each result is **reviewable**.

That is how I'd spend your Codex allocation rather than dropping a 6,000-word design document on the agent and telling it to build civilization.

## The asset pipeline has gotten legitimately crazy

This is the part where your original intuition turned out to be especially correct.

There are now AI systems explicitly designed to generate **pixel-game assets rather than merely producing an image that vaguely looks pixelated**.

### PixelLab is almost absurdly aligned with your use case

PixelLab's current tooling says it can create characters, objects, environments, maps, tilesets, sprites and UI while using reference images to preserve visual consistency. Its map tools specifically support top-down and side-scrolling tilesets. citeturn17view1

More interestingly, its API currently exposes dedicated game-asset operations, including:

```text
text → pixel-art image
image → pixel art
transparent-background extraction
inpainting/editing
animation from text
skeleton-driven animation
8-direction sprite generation
top-down tileset generation
palette-constrained generation
```

The dedicated tileset endpoint generates **seamlessly connecting top-down tiles**, currently including 16×16 and 32×32 tile configurations. Its character tooling can generate eight directional views, while animation endpoints can produce multiple frames from a reference sprite. citeturn17view2

So, yes:

> “Surely AI can generate the damn tiles at this point.”

**It literally has a tileset API now.** citeturn17view2

For example, the art workflow I'd use is:

```text
                ART BIBLE
                    │
      ┌─────────────┼─────────────┐
      │             │             │
 palette       proportions     lighting
      │             │             │
      └─────────────┼─────────────┘
                    ▼
                PixelLab
                    │
       ┌────────────┼─────────────┐
       │            │             │
    tilesets     objects       characters
       │            │             │
       └────────────┼─────────────┘
                    ▼
                 Aseprite
                    │
             human cleanup
                    │
          palette normalization
                    │
             seam checking
                    │
           animation cleanup
                    │
                    ▼
               exported PNG
                    │
                    ▼
              Godot TileSet
```

I would **not** make live PixelLab API calls from the shipped game.

Use the AI as an offline art-production system.

Then the resulting PNG files belong to the project like ordinary assets. Your game is deterministic, works offline, doesn't inherit a cloud-service dependency, and remains buildable if the AI vendor disappears.

PixelLab's current terms state that users retain rights to the creations/output and permit commercial as well as non-commercial use, while also placing responsibility on the user to avoid third-party infringement and subjecting use to additional license terms. Treat that as the vendor's contractual position, not as some magical guarantee that every generated image can never raise an IP dispute. citeturn17view0

### Aseprite remains the finishing tool

The newest official Aseprite release I found is **1.3.18.6**, released September 22, 2026. The 1.3.18 line includes ongoing tile-map fixes and sprite-sheet tooling improvements. citeturn18search3

Aseprite supports sprite sheets, palettes, tiled drawing, animations, Lua scripting and command-line automation. citeturn17view3

That's why I would never ask AI to be your final asset authority.

AI:

> “Here are 30 occult statues.”

You:

> “These six don't suck.”

Aseprite:

> normalize palette → repair silhouette → remove garbage pixels → make seams actually tile → export

Godot:

> import.

That is enormously faster than drawing every single object from scratch without giving up artistic control.

### Lock an art bible before generating hundreds of things

I'd make this before serious generation:

```yaml
visual_identity:
  perspective: "3/4 top-down / oblique"
  era_target: "16-bit console-inspired"
  tone: "desert occultism / decayed sacred technology"

canvas:
  internal_resolution: "320x180 or comparable low-resolution viewport"
  tile_size: 32
  character_box: "32x48 or 32x64"

palette:
  maximum_working_colors: 32
  shadows: "warm dark"
  highlights: "desaturated pale"
  forbidden:
    - smooth gradients
    - anti-aliased edges
    - photoreal texture

lighting:
  world_direction: "upper-left"
  contrast: "high"

characters:
  directions: 8
  idle_frames: 2-4
  walk_frames: 4-8
  attack_frames: 4-8

environment:
  reusable_tiles: true
  unique_landmarks: sparse
```

The numbers can change after experimentation. The important thing is **having constraints**.

Otherwise AI produces:

```text
sprite 1 = SNES
sprite 2 = modern indie
sprite 3 = fake pixel-art watercolor
sprite 4 = PlayStation
sprite 5 = who the fuck knows
```

and technically every individual asset looks fine while the game looks incoherent.

## Build the narrative around knowledge, not conventional morality meters

This is where I think the project can become more than a neat retro demo.

The technological implementation should mirror the philosophical premise.

Instead of making the central variable:

```text
karma = +67
```

make the central system **what the player has grounds to believe**.

I would begin with four concepts:

```text
WORLD FACT
    objective game-world state

CLAIM
    what somebody says is true

EVIDENCE
    something the player discovers

KNOWLEDGE
    what the player has learned or inferred
```

And intentionally **do not expose every `WORLD FACT` to the player**.

Something like:

```gdscript
class_name KnowledgeState
extends Resource

@export var discovered_evidence: Array[StringName] = []
@export var learned_claims: Array[StringName] = []
@export var resolved_insights: Array[StringName] = []
@export var gnosis: int = 0
```

Then:

```text
Temple doctrine:
    "The Seven descended and created mankind."

Forbidden manuscript:
    "The Seven found mankind already sleeping."

Archaeological evidence:
    humanoid ruins predate the Temple calendar.

Mystic testimony:
    "There were never Seven. There was only one thing
     appearing seven ways."

Ancient machine:
    refers to "operators" with the same names as the Seven.
```

The engine never has to display:

```text
CORRECT ANSWER:
B
```

Instead, discoveries unlock **possibilities of interpretation**.

That becomes your game's mechanical analogue of gnosis.

### Don't make Gnosis a simple XP stat

You certainly *can* have a numeric Gnosis value for progression, but I wouldn't let that be the whole mechanic.

Use explicit knowledge prerequisites:

```gdscript
func can_perceive_archon_mark() -> bool:
    return (
        knowledge.knows(&"temple_creation_account")
        and knowledge.knows(&"pretemple_human_remains")
        and knowledge.knows(&"seven_operator_inscription")
    )
```

Then the world can transform based on what the character understands.

Before:

```text
[A statue]
```

After obtaining enough evidence:

```text
[A statue bearing seven geometric marks]
```

Later:

```text
[The marks match the control glyphs beneath the Temple.]
```

Later still:

```text
[Interact]

You realize the "halo" isn't decorative.
It's a schematic.
```

Same fucking sprite.

Different **epistemic context**.

That's incredibly inexpensive game development compared with producing another cinematic, while potentially being far more memorable.

### Your data should reflect contradictory traditions

I'd put lore in plain data rather than burying everything inside scripts:

```json
{
  "id": "origin_of_mortality",
  "claims": [
    {
      "id": "temple_creation",
      "speaker_group": "solar_temple",
      "position": "Mortality was a divine gift."
    },
    {
      "id": "serpent_teaching",
      "speaker_group": "hidden_school",
      "position": "Mortality was imposed as containment."
    },
    {
      "id": "old_machine_record",
      "speaker_group": "unknown",
      "position": "Embodiment was voluntarily instantiated."
    }
  ]
}
```

Notice that **the JSON doesn't need a `correct_claim` property**.

That's intentional.

The actual physical rules of the world can constrain interpretations without turning the metaphysics into a multiple-choice exam.

This is very close to the thing you were saying about Elder Scrolls: not “copy Gnosticism,” but **metabolize its questions into another mythology**.

### Dialogue Manager is unusually well-timed for this

I compared the current Godot narrative options.

For your project, **Nathan Hoad's Dialogue Manager is the one I'd choose**.

The current release is **Dialogue Manager 4.1.0 specifically for Godot 4.7**, released September 4, 2026. It includes support around localization/static IDs, contexts, debugger functionality and dialogue tooling. citeturn21view0

That alignment is unusually clean:

```text
Godot              4.7.2
Dialogue Manager   4.1.0 for Godot 4.7
```

There are other choices, but I wouldn't choose them here. The current Yarn Spinner GDScript integration describes itself as alpha and explicitly warns against relying on it to ship a game yet; its Godot C# integration has likewise been described as work in progress rather than an officially supported mature path. citeturn11search0turn11search2

Dialogic is capable, but its current release notes include more migration/save-state caveats than I want in a brand-new Codex-driven project whose narrative system needs to stay boring and dependable. citeturn10search10

Dialogue Manager lets the architecture remain:

```text
Dialogue text
      │
      ▼
Dialogue Manager
      │
      ├── asks PlayerKnowledge questions
      │
      ├── reads quest/world flags
      │
      └── invokes explicit gameplay methods
```

rather than:

```text
Dialogue Manager owns the universe
```

Keep it as the **presentation and branching layer**, not the canonical source of all game state.

## A repository structure that Codex won't destroy

I would initialize the project approximately like this:

```text
gnostic-rpg/
│
├── AGENTS.md
├── README.md
├── project.godot
├── .gitignore
│
├── docs/
│   ├── GAME_VISION.md
│   ├── ART_BIBLE.md
│   ├── LORE_BIBLE.md
│   ├── NARRATIVE_RULES.md
│   └── ARCHITECTURE.md
│
├── game/
│   ├── core/
│   │   ├── game_state.gd
│   │   ├── save_manager.gd
│   │   └── scene_router.gd
│   │
│   ├── actors/
│   │   ├── player/
│   │   └── npc/
│   │
│   ├── world/
│   │   ├── maps/
│   │   ├── interaction/
│   │   └── perception/
│   │
│   ├── narrative/
│   │   ├── knowledge/
│   │   ├── dialogue/
│   │   └── quests/
│   │
│   └── ui/
│       ├── dialogue/
│       ├── inventory/
│       └── journal/
│
├── data/
│   ├── items/
│   ├── npcs/
│   ├── lore/
│   ├── quests/
│   └── world/
│
├── assets/
│   ├── sprites/
│   ├── tiles/
│   ├── ui/
│   ├── fonts/
│   ├── audio/
│   └── music/
│
├── art/
│   └── source/
│       ├── characters/
│       ├── environments/
│       └── ui/
│
└── tests/
    ├── unit/
    └── integration/
```

I would also keep `.aseprite` originals under `art/source/` and put exported PNGs under `assets/`.

The principle is:

```text
SOURCE MATERIAL != RUNTIME MATERIAL
```

so you can regenerate or replace things without confusing Godot's import pipeline.

### Keep global state tiny

I would initially allow only a few autoload/global services:

```text
GameState
SaveManager
PlayerKnowledge
```

Maybe an audio manager later.

I would **not** create thirteen global managers because an agent told us that's “scalable.”

Game code should mostly live with the scene that owns the behavior.

For example:

```text
NPC scene
├── AnimatedSprite2D
├── CollisionShape2D
├── InteractionArea
└── NPC.gd
```

rather than:

```text
GlobalNPCManagerFactorySingleton
```

### Signals are your friend

Godot's signal model lends itself well to decoupled game interactions:

```text
NPC
 │
 ├─ interaction_started
 │
 ▼
Dialogue UI

PlayerKnowledge
 │
 ├─ fact_discovered
 │
 ▼
Journal UI

Quest
 │
 ├─ state_changed
 │
 ▼
World object
```

That's enough architecture for a game this size.

You do **not** need React-style state management transplanted into a Godot project.

### Don't begin with a Node toolchain

This is probably the strongest technical recommendation I came away with.

You *could* add:

```text
Node 26
TypeScript
Zod
Vite
custom JSON generators
custom content compiler
```

and make an extraordinarily respectable development environment.

You would also have **two ecosystems instead of one before your character can walk**.

There is currently no technical requirement for Node in this project.

Use native Godot resources, `.dialogue` files, JSON where machine-readable content is useful, and GDScript tooling.

Later, if you have:

```text
7,000 dialogue nodes
400 lore documents
automatic consistency checking
procedural content compilation
localization pipelines
```

then a separate TypeScript content tool may become justified.

At that point we'll choose **the current LTS Node version and compatible packages at that date**, rather than prematurely freezing September 2026 JavaScript dependencies into a project that doesn't need them.

That is better dependency management than installing them simply because they exist.

## The exact first implementation I would give Codex

Don't ask Codex to make the whole game tonight.

Ask it to create a **vertical micro-slice proving the weird part of the idea**.

### First milestone

```text
ONE MAP

ONE PLAYER

ONE NPC

ONE DOOR

ONE PIECE OF EVIDENCE

ONE GNOSIS/PERCEPTION CHANGE

ONE DIALOGUE BRANCH
```

That's it.

Your loop:

```text
                         ┌──────────────┐
                         │ Explore map  │
                         └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │ Talk to NPC  │
                         └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │ Hear claim A │
                         └──────┬───────┘
                                │
                                ▼
                      ┌────────────────────┐
                      │ Discover evidence B│
                      └─────────┬──────────┘
                                │
                                ▼
                      ┌────────────────────┐
                      │ Knowledge changes  │
                      └─────────┬──────────┘
                                │
                                ▼
                     ┌──────────────────────┐
                     │ Revisit same NPC     │
                     └──────────┬───────────┘
                                │
                                ▼
                   ┌──────────────────────────┐
                   │ New response is visible │
                   └────────────┬─────────────┘
                                │
                                ▼
                  ┌────────────────────────────┐
                  │ World reveals new meaning │
                  └────────────────────────────┘
```

If **that is fun**, you have the seed of the game.

If it isn't, adding crafting, twenty gods and 150 square kilometers of desert will not rescue it.

### Paste this into Codex after creating the empty Godot project

```text
We are building a small 2D narrative RPG prototype in Godot 4.7.2
Standard using typed GDScript.

First inspect AGENTS.md and project.godot.

Do not add any dependency, addon, Node package, C# project, GDExtension,
database, network service, or architectural framework.

Build only the first gameplay slice.

Requirements:

1. Create a player scene based on CharacterBody2D.
2. Support 8-direction movement from Godot InputMap actions.
3. Add collision.
4. Create a very small test world scene.
5. The world should support layered tile-based scenery, using
   TileMapLayer rather than deprecated TileMap.
6. Add one interactable NPC.
7. Add a reusable interaction component/area only if it materially
   reduces duplication.
8. Add PlayerKnowledge as a small typed GDScript system that can:
   - discover a fact by StringName ID
   - check whether a fact is known
   - emit a signal when a new fact is discovered
9. Give the NPC one dialogue interaction using placeholder UI for now.
10. If the player knows "temple_lie", expose one additional response.
11. Do not implement inventory, combat, quests, saving, AI enemies,
    procedural generation, or anything not required above.

Use placeholder graphics where art is unavailable.

Keep scenes small and compositional.

After implementation:
- run the project
- identify any parse/runtime errors
- fix errors caused by the changes
- summarize every new or modified file
- tell me what still requires manual Godot editor configuration
```

That prompt establishes **scope boundaries**, which is the difference between agentic development being magic and agentic development creating a 19-file abstraction catastrophe.

### Then install Dialogue Manager

Once the placeholder conversation works, replace only that part with **Dialogue Manager 4.1.0**, whose current release explicitly targets Godot 4.7. citeturn21view0

Then your next Codex task becomes:

```text
Replace the placeholder dialogue implementation with Dialogue Manager
4.1.0 while preserving PlayerKnowledge as the authoritative source of
knowledge state.

Do not move knowledge state into the dialogue addon.

The dialogue should:

Priest:
"The heavens were forged by the Seven."

Responses:
- "Tell me about the Seven."
- "Leave."

If PlayerKnowledge knows "pretemple_ruins", additionally show:
- "[GNOSIS] Then explain the ruins beneath your foundation."

Keep all gameplay effects explicit and reviewable.
```

That is already your game's core philosophical mechanic.

### Add testing after the mechanic settles

Godot itself is command-line friendly and supports headless execution, which makes it suitable for agent validation and CI-style workflows. citeturn14search15

For a real unit-test layer, the interesting versioning detail I found is that **GUT 9.7.0 contains explicit compatibility changes for Godot 4.7**. The repository currently also labels 9.6.1 as its “Latest” release even though the 9.7 line contains the 4.7-specific changes, so I would deliberately pin the Godot-4.7-compatible line rather than blindly telling Codex to download whatever carries the generic latest badge. citeturn20view0

That's exactly the kind of dependency mismatch your request was trying to avoid.

Tests worth having are not “does the player sprite look cool?”

They're deterministic rules:

```text
discovering an unknown fact adds it
discovering the same fact twice does not duplicate it
knowledge conditions correctly unlock dialogue
quest transitions reject invalid state changes
save → load preserves knowledge
dead NPCs cannot initiate dialogue
required evidence unlocks an insight
```

Those tests are perfect agent guardrails.

## What I would install tonight

There are surprisingly few things.

**Install Godot 4.7.2 Standard.** It is the current stable maintenance release, and Godot says the 4.7.2 upgrade has no known compatibility problems with 4.7.1. citeturn20view2

**Install Aseprite 1.3.18.6.** That is the current official Aseprite release as of September 30, 2026. citeturn18search3

**In VS Code, install Godot Tools 2.7.1 and the Codex extension.** Godot Tools 2.7.1 supports Godot 4.x, and OpenAI's current Codex documentation explicitly supports VS Code through its Codex extension. citeturn14search16turn21view3

**Initialize Git before Codex starts editing.** Both Godot's own release guidance and OpenAI's Codex guidance emphasize version control/checkpoints around changes. citeturn20view2turn21view3

Then:

```bash
git init
git add .
git commit -m "Initialize Godot 4.7.2 project"
```

Create:

```text
AGENTS.md
docs/GAME_VISION.md
docs/ART_BIBLE.md
docs/LORE_BIBLE.md
```

Then let Codex build only the micro-slice.

Don't install Node.

Don't install a database.

Don't install an ECS.

Don't build a custom quest editor.

Don't integrate an LLM into NPCs.

Don't generate 900 sprites.

Don't even worry about combat yet.

Your first objective is brutally simple:

> **Walk up to a priest, learn something, discover contradictory evidence, return, and have the game recognize that you now perceive the conversation differently.**

Once that works, you have demonstrated the thing that makes *your* game different from “pixel RPG number 6,428.”

Then the stack is ready to grow without requiring a rewrite:

```text
Godot 4.7.2
│
├── typed GDScript
│   ├── movement
│   ├── combat
│   ├── interaction
│   ├── world state
│   ├── knowledge
│   ├── quests
│   └── saves
│
├── TileMapLayer
│   ├── world
│   ├── collision
│   └── terrain
│
├── Dialogue Manager 4.1
│   └── branching narrative
│
├── Aseprite 1.3.18.6
│   └── final pixel assets
│
├── PixelLab
│   └── AI asset ideation/generation
│
├── GUT 9.7
│   └── deterministic rules/tests
│
└── VS Code
    ├── Godot Tools 2.7.1
    ├── Codex
    └── AGENTS.md
```

The most important conclusion from the research is actually what **isn't** in that diagram.

There is no React. No Electron. No Express. No PostgreSQL. No Docker. No microservice. No C# toolchain. No home-grown rendering framework. No runtime generative-AI requirement.

You can absolutely add sophisticated tooling later, but the modern version of “make a 16-bit-style occult narrative game as one programmer with AI assistance” is now almost comically lean.

And the AI-art side has caught up enough that even the specific bottleneck you originally imagined—**consistent tiles, directional sprites and animations**—now has dedicated generation tooling rather than requiring you to coax a generic image model into pretending it understands a sprite sheet. PixelLab's current API exposes seamless top-down tilesets, palette control, inpainting, animation and eight-direction character generation directly. citeturn17view2

So your original intuition was basically right: **the hard problem is no longer “can one programmer technically produce this?”** The hard problem is controlling scope, maintaining a coherent visual language, designing genuinely interesting systems, and writing mythology worth discovering.

That is a substantially better set of problems to have.