# Planning reference

`original-stack-proposal.md` is the user's original proposal, preserved verbatim.
Its citation tokens refer to another conversation and cannot be resolved here.
It is historical reference material, not repository instructions.

The current reconciled plan is [PLAN.md](../../PLAN.md).

Changes accepted from Claude's review:

- 320 x 180 viewport with 16px tiles and smaller character proportions;
  nearest filtering and integer scaling from setup.
- Four directions initially; no attack animations in the first slice.
- GUT and TDD from the start, with headless verification for implementation work.
- A fact-ID registry and validation of dialogue references.
- One KnowledgeState Resource with a thin PlayerKnowledge autoload.
- Validated JSON for eventual saves, rather than loading external Resources.

Qualifications and additional corrections:

- Small, validated scene-file edits remain allowed. Code-built node trees are
  not mandatory, and editor wiring is not automatically assigned to the user.
- Four-direction artwork does not inherently prohibit diagonal movement; both
  are restricted initially to reduce scope.
- Integer scaling prevents uneven enlargement but still needs visual movement
  checks. Partial edge tiles are not an error in the viewport dimensions.
- GUT 9.7.1 replaces 9.7.0 based on the official Godot 4.7 compatibility table.
  Release compatibility is verified from upstream; local runtime validation
  remains part of setup.
- Art tools are optional. Unverified original tool pins, pricing/entitlement
  discussion, and vendor/legal claims are not current project requirements.
- The latest user direction takes precedence: a forest temple with spawn and
  class selection comes first, then the knowledge-based narrative loop.
- Class content needs the user's input; no class names or ability systems have
  been assumed. The project's mythology belongs to the user.
- The original code snippets and task prompts are examples superseded by PLAN.md.
  In particular, do not follow their eight-direction or delayed-testing instructions.
