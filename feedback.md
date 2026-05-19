# Databao — UX Feedback

## Table of Contents

- [Splash Screen](#splash-screen)
- [Agent Hangs Without Logs](#agent-hangs-without-logs)
- [Init Menu](#init-menu)
- [Startup State Report](#startup-state-report)
- [Semantic Layer Questions](#semantic-layer-questions)
- [What's Next Menu](#whats-next-menu)
- [Test Results](#test-results)
- [GitHub Repo Offer](#github-repo-offer)
- [Deploy Output](#deploy-output)
- [Repeat Deploy Prompt](#repeat-deploy-prompt)
- [No dbt Project Detected](#no-dbt-project-detected)

---

## Splash Screen

```
╭─── Databao v0.1.0 ───────────────────────────────────╮
│                       .-""""-.                       │
│                    .-'        '-.                    │
│                   /              \                   │
│                  |    ●     ●     |                  │
│                  |      ◡◡        |                 │
│                   \              /                   │
│                    '-.________.-'                    │
│        shopify_analytics  ·  Alberto Barcelos        │
╰──────────────────────────────────────────────────────╯
```

**Feedback**

- Adapt ASCII art to match Slack's visual style
- Use Slack brand colors

---

## Agent Hangs Without Logs

```bash
(databao-qa-agent)
❯ databao
...HANGING FOREVER...
```

**Feedback**

- No logs → no way to diagnose what's happening
- Waiting 10+ minutes with zero visibility is nerve-racking

---

## Init Menu

**Feedback**

- Menu options are too thin — currently only "Cloud Code" or "customize skill"
- Replace vague options with deterministic user intentions (the actions we _know_ users will perform in the lifecycle):
  - "Develop the semantic layer" → opens Claude Code automatically
  - "Run metadata refresh" → runs job, shows deploy link, runs tests
  - etc.
- Label should describe the _goal_, not the mechanism. E.g. instead of "Enter Claude Code" → "Develop semantic layer (in Claude Code)"

---

## Startup State Report

```
Read 1 file, listed 2 directories
```

**Feedback**

- Don't surface low-level internals (git checks, file reads). Instead, show intent:
  - Good: "Initializing repository" or "Evaluating project state"
  - Bad: showing raw `git status` checks

---

## Semantic Layer Questions

```
● Here 5 questions for semantic layer:

  ┌─────┬───────────────────────────────────────┬───────────────────────────┬─────────────────────────────────────────────┐
  │  #  │               Question                │          Metric           │                   Formula                   │
  ├─────┼───────────────────────────────────────┼───────────────────────────┼─────────────────────────────────────────────┤
  │ 1   │ Total revenue from successful sales   │ monthly_gross_revenue     │ SUM(amount) WHERE kind='sale' AND           │
  │     │ per month?                            │                           │ status='success'                            │
  ├─────┼───────────────────────────────────────┼───────────────────────────┼─────────────────────────────────────────────┤
  │ 2   │ How many new customers acquired each  │ monthly_new_customers     │ COUNT(DISTINCT id) GROUP BY                 │
  │     │ month?                                │                           │ month(created_at)                           │
  ├─────┼───────────────────────────────────────┼───────────────────────────┼─────────────────────────────────────────────┤
  │ 3   │ Total refund amount processed per     │ monthly_refund_amount     │ SUM(amount) WHERE kind='refund' AND         │
  │     │ month?                                │                           │ status='success'                            │
  ├─────┼───────────────────────────────────────┼───────────────────────────┼─────────────────────────────────────────────┤
  │ 4   │ Average order value per month?        │ avg_order_value           │ AVG(total_price) GROUP BY month(created_at) │
  ├─────┼───────────────────────────────────────┼───────────────────────────┼─────────────────────────────────────────────┤
  │ 5   │ How many orders used discount code    │ monthly_discounted_orders │ COUNT(DISTINCT order_id) GROUP BY month     │
  │     │ each month?                           │                           │                                             │
  └─────┴───────────────────────────────────────┴───────────────────────────┴─────────────────────────────────────────────┘

  Options:
  - ok → proceed all
  - remove N, M → drop some
  - add: <question> → add new
  - more (optional hint) → generate additional
```

**Feedback**

- Replace free-text options with `QuestionAsk` / `TodoWrite` — users should _select_, not type commands
- Suggested option order:
  - **Continue with all** (proceed)
  - **Remove questions** (pick which to drop)
  - **Add a question** (free text — label it "Write your own")
- Use `QuestionAsk` + `TodoWrite` as the interaction pattern going forward

---

## What's Next Menu

```
  1. Commit     — Record this cycle in git and continue
  2. Refine     — Describe what to change; iterate within this cycle
  3. Revert     — Undo this cycle, restore pre-cycle state
❯ 4. Leave      — Continue without committing this cycle
  5. Type something.
```

**Feedback**

- "Leave" vs "Revert" is confusing — leaving means not committing _this_ cycle, reverting means undoing it entirely. Clarify the distinction or merge them
- Replace "Type something." with "Tell me what's next." (or just an open prompt)
- Open questions:
  - What happens if git is not installed?

---

## Test Results

```
● User answered: Run the test set before deploying? → Run tests

  ┌─────────┬───────┐
  │ Outcome │ Count │
  ├─────────┼───────┤
  │ OK      │ 10    │
  │ Broken  │ 0     │
  │ Gap     │ 0     │
  └─────────┴───────┘

  All 10 tests pass.
```

**Feedback**

- Show per-question results, not just a summary — e.g. `✅ monthly_gross_revenue` / `❌ avg_order_value`
- Users need to see _which_ tests ran and whether each passed or failed

---

## GitHub Repo Offer

```
● User answered: Create new GitHub repo `albertoprb/test-shopify` — public or private? → Private
```

**Feedback**

- When no upstream remote is detected, proactively offer to initialize a GitHub repo — good pattern, keep it

---

## Deploy Output

```
● [ok] Everything is pushed.

  Open this URL in your browser to deploy:
  https://databao-platform.labs.jb.gg/import

  Repo: https://github.com/albertoprb/test-shopify (private). Coverage: 10/10 metrics pass
```

**Feedback**

- Too many URLs — user loses focus on the call to action
- Ideal output: one link, one action, goal-oriented copy. Example:

  > All changes deployed. [Import your project to start asking questions in Slack →](https://databao-platform.labs.jb.gg/import)

- Drop the repo URL from this screen — it's noise at this stage
- Render the link as Markdown (hyperlink text, not raw URL)

---

## Repeat Deploy Prompt

```
● ┌────────────────┬───────────────────────────────────┐
  │ Project status │               Value               │
  ├────────────────┼───────────────────────────────────┤
  │ Semantic layer │ 5 models / metrics defined inline │
  │ Test coverage  │ 10 questions  →  push-ready       │
  │ Working tree   │ logs only (gitignored noise)      │
  └────────────────┴───────────────────────────────────┘

  10 questions covered. Deploy now?

❯ 1. Deploy       — Open web console to deploy what we have
  2. Keep building — Add a question, describe a metric, or test how I'd answer something
  3. Type something.
  4. Chat about this
```

**Feedback**

- After a successful deploy with no new changes, "Deploy" should not be the first option
- Detect state: if nothing changed since last deploy, skip the deploy prompt entirely and drop the user straight into the build loop
- Default first option should be "Keep building" — deploying again immediately is almost never what the user wants

---

## No dbt Project Detected

```bash
❯ databao
Error: No dbt project found at /home/Alberto.Barcelos/Projects/jetbrains/sample-projects/test/dbt_project.yml
```

**Feedback**

- Replace the raw error with a friendly message:
  > "I could not detect a dbt project in this folder. Please run databao inside a dbt project."
