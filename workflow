You have two agents, and Copilot's normal **Agent mode** does the building. The workflow:

**1. Spec.** Run `@spec-writer` (Copilot chat in IntelliJ).
> `@spec-writer` Spec <feature>. Context: <one or two lines>.

- Answer the questions one at a time. Reply with a letter, or with "skip", "your call" or "just draft it".
- Read the draft it writes to `.ai/specs/<feature>.md`. Check that an engineer could build from it without asking you anything.
- Approve it with "approved". The spec is now the contract.

**2. Build.** Use plain Copilot **Agent mode**, since there's no builder agent yet.
> Implement `.ai/specs/<feature>.md` v1. Write the tests from its worked examples and boundaries first, then the code, then run `mvn verify`. Don't change behaviour the spec doesn't define. If something is unclear, stop and ask.

- Look over the diff yourself. Nothing is committed yet.

**3. Review.** Open a **new chat** with `@reviewer`, on a different model from step 2.
> `@reviewer` Review the working copy against `.ai/specs/<feature>.md` v1.

- You get PASS, FAIL or INCONCLUSIVE, plus a spec coverage table and findings, each with a counterexample.

**4. Fix.**
- **`(code)` and `(test)` findings:** paste them into the build chat from step 2. Ask for a regression test per finding, then the fix, then `mvn verify`.
- **`(spec)` findings:** take them back to `@spec-writer`. It produces spec v2, which you approve, and then the build updates for v2.
- Repeat step 3 in **another new chat** until the verdict is PASS.

**5. Commit.** Review the final diff and commit it yourself. If the review caught something worth checking every time, add one line to `.ai/lessons.md` or to the matching domain pack.

**Other uses**

| You want to… | Do this |
| --- | --- |
| Review a PR | New chat: `@reviewer Review main...<branch> against .ai/specs/<feature>.md` |
| Review existing code that has no spec | `@spec-writer Spec the existing <component> as built` → answer its questions about what's unintended → approve → new chat: `@reviewer Review <path> as a whole against that spec` |
| Make a change that doesn't alter behaviour (refactor, speed-up) | Skip the spec. Agent mode with acceptance criteria ("all existing tests unchanged and green"), then `@reviewer Review the working copy; this claims no behaviour change` |

**One-time setup**
- Copy `spec-writer.agent.md` and `reviewer.agent.md` into `.github/agents/`, or into `~/.copilot/agents/` for personal use.
- Copy `.ai/spec-areas/execution.md`.
- Create an empty `.ai/specs/` folder and an empty `.ai/lessons.md`.
- `AGENTS.md` is optional; both agents read it if it's there.
