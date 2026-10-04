# Reviewing the initial RPG PR

The first PR includes the previously uncommitted playable foundation. Most files
are the bundled GUT dependency, not new custom gameplay code. Vendoring makes
source snapshots and test runs work without a separate package download.

## Review in two parts

- `9961aca`: existing playable foundation plus initial planning documents.
- `9a7c78f`: Vigor and the temple training encounter (32 changed files).
- Later review-only commits change diff presentation/documentation, not gameplay.

For the encounter changes alone, compare `9961aca..9a7c78f`. For a complete review
of our game code, compare `main...HEAD` and exclude the paths below. Do not mistake
the encounter-only patch for a review of the entire initial foundation.

```bash
git diff 9961aca..9a7c78f -- . \
  ':(exclude)addons/gut/**' \
  ':(exclude)*.uid' \
  ':(exclude)*.import' \
  ':(exclude)docs/reference/race-sprites/*.png'
```

GUT's source/version/license are documented in addons/README.md. Review dependency
updates separately, including upstream release notes and integrity. We keep the
whole upstream addon rather than guessing which internal files the runner needs.

.gitattributes marks the bundled addon as vendored and uses GitHub's
linguist-generated flag to collapse it in diffs. The same collapse flag covers
Godot .uid/.import metadata. These files are still in Git and can be expanded.
Raw git/PR API diffs and some AI tools do not honor those display attributes;
use explicit path exclusions or the encounter-only commit comparison for them.

No builds, executable exports, .godot caches, or personal character saves are
committed. Larger binary art references are design inputs under docs/reference,
not shipped runtime art. A pinned dependency-download step is a future option,
but it adds setup/network requirements and is not needed to reduce review noise.