# Databao — UX Feedback

> **Launch note:** The import flow does not exist in the dashboard yet for the first release. The deploy action currently deep-links to a URL that will be invalid. This is a known gap — the link should either be hidden or replaced with a placeholder until the import flow is live.
>
> **Open question:** Will `databao-platform.labs.jb.gg` be updated to a Databao-owned domain before launch?

> **Concern:** Costs and time performance. A run on a mid complexity sample that might not ressemble real-world complexity took 10+ minutes before it could give me 5 sample qquestions

## Table of Contents

### Blockers
- [Bug: Multi-Dimension Query Encoding](#bug-multi-dimension-query-encoding)
- [Bug: mf query --group-by Malformed](#bug-mf-query---group-by-malformed)

### Important
- [Init Menu](#init-menu)
- [What's Next Menu](#whats-next-menu)
- [Test Results](#test-results)
- [No dbt Project Detected](#no-dbt-project-detected)
- [Bootstrap Cycle Messaging](#bootstrap-cycle-messaging)
- [Monitor Event Format](#monitor-event-format)
- [Cycle Summary Detail](#cycle-summary-detail)
- [Refinement Loop Focus](#refinement-loop-focus)
- [Post-Commit Prompt](#post-commit-prompt)
- [Uncommitted Files Before Deploy](#uncommitted-files-before-deploy)
- [Deploy Without Upstream](#deploy-without-upstream)
- [Testing the Semantic Layer](#testing-the-semantic-layer)
- [Bug: DuckDB Lock Contention](#bug-duckdb-lock-contention)
- [QuestionAsk: No Simultaneous Select + Type](#questionask-no-simultaneous-select--type)

### Nice to Have
- [Splash Screen](#splash-screen)
- [Semantic Layer Questions](#semantic-layer-questions)
- [GitHub Repo Offer](#github-repo-offer)
- [Deploy Output](#deploy-output)
- [Repeat Deploy Prompt](#repeat-deploy-prompt)
- [Startup Output Order](#startup-output-order)
- [Metric Resolution Messaging](#metric-resolution-messaging)
- [Coverage Summary After Commit](#coverage-summary-after-commit)

---

# Blockers

## Bug: Multi-Dimension Query Encoding

![](https://img.shields.io/badge/-Blocker_for_Release_1-B60205) 

```
● Test results

  ┌─────────┬───────┐
  │ Outcome │ Count │
  ├─────────┼───────┤
  │ OK      │ 5     │
  ├─────────┼───────┤
  │ Broken  │ 6     │
  ├─────────┼───────┤
  │ Gap     │ 0     │
  └─────────┴───────┘

  ▎ Structural check — verifies each metric resolves and returns non-empty results. Does not compare against a trusted baseline.

  Non-OK rows:

  ┌─────┬─────────────────────────────────────────────────────────┬────────────────────────────┬─────────┬──────────────────────────────────────┐
  │  #  │                        Question                         │           Metric           │ Outcome │                Detail                │
  ├─────┼─────────────────────────────────────────────────────────┼────────────────────────────┼─────────┼──────────────────────────────────────┤
  │ 3   │ Which product categories drive the most revenue each    │ monthly_category_revenue   │ Broken  │ mf query failed: Usage: mf query     │
  │     │ month?                                                  │                            │         │ [OPTIONS]                            │
  ├─────┼─────────────────────────────────────────────────────────┼────────────────────────────┼─────────┼──────────────────────────────────────┤
  │ 5   │ Which referral codes generate the most revenue each     │ total_revenue              │ Broken  │ mf query failed: Usage: mf query     │
  │     │ month?                                                  │                            │         │ [OPTIONS]                            │
  ├─────┼─────────────────────────────────────────────────────────┼────────────────────────────┼─────────┼──────────────────────────────────────┤
  │ 6   │ How does order volume split across device types each    │ order_count                │ Broken  │ mf query failed: Usage: mf query     │
  │     │ month?                                                  │                            │         │ [OPTIONS]                            │
  ├─────┼─────────────────────────────────────────────────────────┼────────────────────────────┼─────────┼──────────────────────────────────────┤
  │ 7   │ How much revenue does each customer cohort generate per │ cohort_monthly_revenue     │ Broken  │ mf query failed: Usage: mf query     │
  │     │  month?                                                 │                            │         │ [OPTIONS]                            │
  ├─────┼─────────────────────────────────────────────────────────┼────────────────────────────┼─────────┼──────────────────────────────────────┤
  │ 8   │ How does revenue compare between source systems each    │ total_revenue              │ Broken  │ mf query failed: Usage: mf query     │
  │     │ month?                                                  │                            │         │ [OPTIONS]                            │
  ├─────┼─────────────────────────────────────────────────────────┼────────────────────────────┼─────────┼──────────────────────────────────────┤
  │ 9   │ Which products generate the most revenue from           │ high_value_product_revenue │ Broken  │ mf query failed: Usage: mf query     │
  │     │ high-value orders?                                      │                            │         │ [OPTIONS]                            │
  └─────┴─────────────────────────────────────────────────────────┴────────────────────────────┴─────────┴──────────────────────────────────────┘

  Pattern: all 6 broken queries use multiple group-by dimensions in the mf_query column — space-separated instead of repeated --group-by flags.
  Likely a CSV encoding bug, not a broken metric.
```

**Potential bug**

- All 6 failures share the same pattern: queries with multiple `group-by` dimensions fail
- Root cause: dimensions appear space-separated in the CSV (`metric_time__month order__referral_code`) instead of as repeated `--group-by` flags (`--group-by metric_time__month --group-by order__referral_code`)
- Metrics themselves are likely correct. This is likely a CSV encoding bug in how `mf_query` commands are serialised to `test_questions.csv`

---

## Bug: mf query --group-by Malformed

![](https://img.shields.io/badge/-Blocker_for_Release_1-B60205)

```
│ 14  │ What is total revenue by source system each month?               │ total_revenue │ Broken  │ mf query failed: Usage: mf query [OPTIONS] │
│ 16  │ What is the revenue lift from referral codes vs organic each     │ total_revenue │ Broken  │ mf query failed: Usage: mf query [OPTIONS] │
│     │ month?                                                           │               │         │                                            │
```

**Feedback**

- Generated `mf query` commands use space-separated `--group-by` args instead of repeated flags
- Wrong: `--group-by metric_time source_system`
- Right: `--group-by metric_time --group-by source_system`
- Any multi-dimension query will break until fixed

---

# Important

## Init Menu

![](https://img.shields.io/badge/-Important-D93F0B) 

**Feedback**

- Menu options are too few (seems like a cumbersome way to enter claude code)
- Options should describe the _goal_, not the mechanism. E.g. instead of "Enter Claude Code" → "Keep building semantic context"
- Options should consider the state of the project
- There should be a reason to keep using the Databao CLI after "installing" it in a project

**Proposal**
- I recommend we we replace vague options with deterministic user intentions (the actions we _know_ users will perform in the lifecycle):
  - "Keep building semantic context" → opens Claude Code automatically
  - "Run test set"
  - "Ask questions"
  - "Deploy to Databao console" --> When we have it
  - "Advanced"
    - "Introspect metadata" → When we have it

---

## What's Next Menu

![](https://img.shields.io/badge/-Important-D93F0B) 

```bash
 ☐ Next step

What's next?

  1. Commit
     Record this bootstrap cycle in git and continue
  2. Refine
     Describe what to change — I'll iterate within this cycle
  3. Revert
     Undo all changes, restore pre-cycle state
  4. Leave
     Keep files on disk uncommitted, decide later
❯ 5. Type something.
──────────────────────────────────────────────
  6. Chat about this
```

**Feedback**

- **"Commit"** is alarming if the user has existing uncommitted work — they'll worry Databao is touching their changes. As far as I tested the the cycle changes are isolated (stashed separately) but users won't know until they use it for a while, so please rename to 
  - Accept & commit changes
    Files with changes created by this cycle will be committed. Doesn't affect other files.
- "Chat about this" (6) is a `QuestionAsk` tool option that can't be suppressed? — if so, remove "5. Type something." instead since they overlap; one open input is enough

---

## Test Results

![](https://img.shields.io/badge/-Important-D93F0B) 

``` bash
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

## No dbt Project Detected

![](https://img.shields.io/badge/-Important-D93F0B) 


```bash
❯ databao
Error: No dbt project found at /home/Alberto.Barcelos/Projects/jetbrains/sample-projects/test/dbt_project.yml
```

**Feedback**

- Replace the raw error with a friendly message:
  > "I could not detect a dbt project in this folder. Please run databao at the root folder of a dbt project."

---

## Bootstrap Cycle Messaging

![](https://img.shields.io/badge/-Important-D93F0B) 

```
● Starting bootstrap cycle. Snapshotting first.

● Bash(git stash create && echo "STASH_DONE" && git status --porcelain)
  ⎿  ok stash create
     STASH_DONE
      M README.md
     … +4 lines (ctrl+o to expand)

● Bash(rtk proxy git stash create 2>&1)
  ⎿  eed794fd402a05f6fad087f40fbb9ca8b7ad90bd

● Snapshot SHA: eed794fd402a05f6fad087f40fbb9ca8b7ad90bd. Pre-cycle untracked: .databao/, uv.lock.
```

**Feedback**

- Stash is created silently
- Explain upfront that every change cycle is atomic and fully reversible, e.g.:
  > "Every change Databao makes can be rolled back. Creating a git based snapshot before we start..."

---

## Monitor Event Format

![](https://img.shields.io/badge/-Important-D93F0B) 

**Current** — event label repeated before every line, noisy:

```
● Monitor running — waiting for events from the semantic layer agent.
● Monitor event: "Monitoring semantic layer generation"
● Agent started — exploring project structure.
● Monitor event: "Monitoring semantic layer generation"
● Project explored — agent reading mart models (fct_sales, util_date_spine, etc.)
● Monitor event: "Monitoring semantic layer generation"
● Schema fully understood — agent now creating semantic layer YAML files.
```

**Expected** — one header, then prefixed stream:

```
● Starting semantic layer agent 🤖
● 🤖 Semantic layer agent — Agent started. Exploring project structure.
● 🤖 Semantic layer agent — Project explored. Reading mart models (fct_sales, util_date_spine, etc.)
● 🤖 Semantic layer agent — Schema fully understood. Now creating semantic layer YAML files.
```

**Feedback**

- Emit the agent name once at the start, not before every event
- Each subsequent update: single line, prefixed with `🤖 <agent name> —`
- Drop the repeated `Monitor event: "..."` label entirely if Claude allows us to control it

---

## Cycle Summary Detail

![](https://img.shields.io/badge/-Important-D93F0B) 

```bash
Cycle summary
  ─────────────
  Intent:         "bootstrap semantic layer with 9 metrics covering 10 questions"
  Files added:    4
    models/semantic/time_spine_daily.sql
    models/semantic/time_spine_daily.yml
    models/semantic/sem_mrt_sales.yml
    .databao/test_questions.csv
  Files modified: 0
  Test set:       10 questions covered (was 0)
  Validation:     dbt parse OK, mf validate-configs OK (0 errors)

  Questions added/touched:

  1. What is the total revenue generated per month across all transactions?
     Metric: total_revenue  |  Formula: SUM(quantity * unit_sale_price)
     | metric_time__month   | total_revenue |
     |----------------------|---------------|
     | 2023-01-01           | 854.93        |
     | 2023-02-01           | 809.87        |
     | 2023-03-01           | 734.92        |
     | 2023-04-01           | 935.9         |
     | 2023-05-01           | 787.9         |

  2. How many units were sold per product line each month?
     Metric: units_sold  |  Formula: SUM(quantity)
     | metric_time__month   | sale__product_line       | units_sold |
     |----------------------|--------------------------|------------|
     | 2023-01-01           | Camping Equipment        | 5          |
     | 2023-01-01           | Golf Equipment           | 2          |
     | 2023-02-01           | Camping Equipment        | 10         |
     | 2023-02-01           | Mountaineering Equipment | 3          |
     | 2023-03-01           | Golf Equipment           | 1          |

  3. What is the average discount rate applied to products over time?
     Metric: avg_discount_rate  |  Formula: SUM(discount) / SUM(gross_revenue)
     | metric_time__month   | avg_discount_rate |
     |----------------------|-------------------|
     | 2023-01-01           | 0.0807            |
     | 2023-02-01           | 0.1000            |
     | 2023-03-01           | 0.0455            |
     | 2023-04-01           | 0.1000            |
     | 2023-05-01           | 0.0390            |

  4. How many distinct orders per order method each month?
     Metric: order_count  |  Formula: COUNT(DISTINCT fct_sales_sk)
     | metric_time__month   | sale__order_method_type | order_count |
     |----------------------|-------------------------|-------------|
     | 2023-01-01           | Web                     | 1           |
     | 2023-01-01           | Phone                   | 1           |
     | 2023-02-01           | Direct                  | 1           |
     | 2023-02-01           | Web                     | 1           |
     | 2023-03-01           | Web                     | 1           |

  5. Total revenue by retailer country per month?
     Metric: total_revenue  |  Formula: SUM(quantity * unit_sale_price)
     | metric_time__month   | sale__retailer_country | total_revenue |
     |----------------------|------------------------|---------------|
     | 2023-01-01           | United States          | 674.95        |
     | 2023-01-01           | Canada                 | 179.98        |
     | 2023-02-01           | Germany                | 539.97        |
     | 2023-02-01           | United Kingdom         | 269.9         |
     | 2023-03-01           | United States          | 419.93        |

  6–10. gross_revenue, total_discount_amount, avg_order_quantity, distinct_products_sold, active_retailer_count — all queries return data ✓
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 ☐ Next step

What's next?

❯ 1. Commit
     Record this bootstrap cycle in git and continue to Step 3
  2. Refine
     Describe what to change — I'll iterate within this cycle
  3. Revert
     Undo this cycle, restore pre-cycle state
  4. Leave
     Continue without committing — decide later
  5. Type something.
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  6. Chat about this
```

**Feedback**

- Truncated sample results are impossible to judge. User can't tell if the metric is correct, and then they are being asked to commit.
- For bulk changes, keep the top-level summary table, then expand each question below it in a readable format:

  ```bash
  ① Total revenue each day?
     Metric: total_revenue
     Files:  models/semantic/sem_fct_sales.yml
     Result:
       2024-01-01: 1,204.50
       2024-01-02:   890.00
       2024-01-03: 2,100.75

  ② Orders per month?
     Metric: order_count
     Files:  models/semantic/sem_fct_sales.yml
     Result:
       Jan 2024: 3
       Feb 2024: 4
       Mar 2024: 4
  ```

- Ideally map each question to the specific file(s) it produced — lets users verify scope of each change

---

## Refinement Loop Focus

```bash
● Cycle summary (updated)
  Intent: bootstrap semantic layer with 10 metrics
  ...all 9 questions listed...

● What would you like to change?
❯ I would like to create a metric for measuring product revenue for high value orders only...
```

**Feedback**

- After bootstrap, every refinement resurfaces the full question list — but the user only cares about what just changed
- The full summary is useful once (at bootstrap end); in the refinement loop it's noise
- When the user adds, removes, or changes a question, show only the diff:
  - What was added/removed/changed
  - Sample result for the affected question(s)
  - Validation status for those specific metrics
- Reserve the full summary for an explicit "show all" action or the final accept step

---

## Post-Commit Prompt after Bootstrap

![](https://img.shields.io/badge/-Important-D93F0B) 

```
● Committed. Coverage: 11 questions across 10 metrics (total_revenue, order_count, avg_order_value, monthly_category_revenue, monthly_new_customers,
   monthly_referral_revenue*, monthly_orders_by_device*, cohort_monthly_revenue, monthly_customer_churn, high_value_product_revenue).

  * sliced via dimensions on existing metrics

  What would you like to add next? Or type done if coverage looks good.

✻ Worked for 3m 56s
```

**Feedback**

- "What would you like to add next?" assumes the user wants to add something — but in an existing project they may want to do something entirely different
- This is the moment to educate: explain what's possible. Replace with a `QuestionAsk` offering concrete options, e.g.:

  ```
  What would you like to do?
  » Request a new metric       e.g. "gross revenue filtered to orders where amount > avg(amount), grouped by month"
    Add a question             e.g. "how many churned customers per month?"
    Test the semantic layer    run a question locally and inspect the result
    I'm done                   coverage looks good
  ```

- The options should reflect the full capability of the tool, not just "add more", and be contextualized to this project.

---

## Uncommitted Files Before Deploy

![](https://img.shields.io/badge/-Important-D93F0B) 

```
● There are 6 uncommitted files. None are semantic layer files — they look like pre-existing edits and generated artifacts (README.md,
  pyproject.toml, feedback.md, uv.lock, .databao/.gitignore, explain.md).
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 ☐ Uncommitted files

There are 6 uncommitted files. Commit them together before deploying?

  1. Commit all
     Single straggler commit covering README.md, pyproject.toml, feedback.md, uv.lock, .databao/.gitignore, explain.md
  2. Cancel
     Stop and review manually before deploying
❯ 3. Type something.
──────────────────────────
```

**Feedback**

- No option to deploy without committing — user should be able to skip unrelated files and deploy anyway. The instructions are constricting too much UX.
- The warning message doesn't explain the consequence clearly
- Suggested options:

  ```bash
  There are 6 uncommitted files unrelated to the semantic layer.

  Only committed & pushed changes get deployed as Databao console reads from your remote repo.

  » Deploy anyway       uncommitted semantic layer changes won't be available to agents using it to answer questions
    Commit all          include all uncommitted files in a single commit, then deploy
    Cancel              stop and review manually
  ```

- "Deploy anyway" should be the default when none of the uncommitted files are semantic layer files

---

## Deploy Without Upstream

![](https://img.shields.io/badge/-Important-D93F0B) 

```
❯ deploy

● Bash(git rev-parse --abbrev-ref @{u} 2>/dev/null && echo "HAS_UPSTREAM" || echo "NO_UPSTREAM")
  ⎿  NO_UPSTREAM

● Still no upstream. Branch needs one before deploy can proceed. Run this in your terminal:

  git push -u origin main

  Then type deploy again.

✻ Cogitated for 6s

❯ I want to deploy without pushing

● The web console deploys by pulling from the remote repo — it has no way to access local-only commits. Without pushing, the semantic layer files
  won't be there for it to import.

  Two options:

  1. Push first — git push -u origin main — then open the console. This is the only way the import will work.
  2. Skip deploy for now — keep building locally and push when ready.

  Want to push, or continue adding to the semantic layer?

✻ Crunched for 11s
```

**Feedback**

- Hard-blocking deploy without a push is too strict — should warn but not block
- Explain clearly *why* a push is needed (web console pulls from remote), then let the user decide
- Even if they proceed without pushing, still show the import deep link so they have it ready for when they do push
- Suggested flow:

  ```
  ⚠ No upstream branch detected.

  The web console deploys by pulling from your remote repo. Local-only
  commits won't be visible until you push.

  » Push and open import link    git push -u origin main, then open console
    Open import link anyway       I'll push separately
    Cancel
  ```

- "Open import link anyway" should open (or display) the deep link regardless — don't gate the URL behind a successful push
- Deploy anyways should always be a choice

---

## Testing the Semantic Layer

![](https://img.shields.io/badge/-Important-D93F0B) 

```
❯ I want to test the semantic layer with alternative questions

● What would you like to ask? Examples:

  - "How would you answer: top 5 products by revenue last quarter?"
  - "What's the average order value by customer country?"
  - "How many repeat customers did we have last month?"

  Type your question — I'll check if the semantic layer can answer it, show the result, and ask whether to add it to the test set.

✻ Churned for 6s
```

**Feedback**

- The only way to reach this flow was to break out of the main loop and ask explicitly — it's not discoverable
- Testing should be a first-class option surfaced every time by Databao. Once claude Code starts in a project with existing semantic layer, alongside keep building and deploy:

  ```
  What would you like to do?
  » Keep building        add or refine metrics and questions
    Test the semantic layer   ask a question and inspect the result
    Run the full test set     validate all questions in test_questions.csv
    Deploy                    push and open the import link
  ```

- "Test the semantic layer" → user types a free-form question, Claude runs it and shows the result
- "Run the full test set" → runs all questions in `test_questions.csv` non-interactively and shows pass/fail per question
- Both options should also be available directly from the `databao` CLI, before Claude Code is invoked

---

## Bug: DuckDB Lock Contention

![](https://img.shields.io/badge/-Important-D93F0B) 
Relevant for demos and isolated customer tests.

```bash
● Monitor event: "Monitoring semantic layer generation for repeat_purchase_rate"

● mf validate-configs returned exit code 1 — waiting for full error output.

✻ Worked for 5s · 1 monitor still running

● Monitor event: "Monitoring semantic layer generation for repeat_purchase_rate"

● Validation passed semantically — DuckDB lock from dbt MCP (PID 1405348) blocking model run. Agent handling it.

✻ Worked for 3s · 1 monitor still running

● Monitor event: "Monitoring semantic layer generation for repeat_purchase_rate"

● PID 1405348 is the databao-metagen process itself — it holds the DuckDB lock internally. Agent working around it.

✻ Sautéed for 7s · 1 monitor still running

● Monitor event: "Monitoring semantic layer generation for repeat_purchase_rate"

● Agent trying dbt show to reuse the existing MCP connection instead of acquiring a new lock.
```

**Bug**

- `databao-metagen` holds a DuckDB lock internally, which then blocks `mf validate-configs` from acquiring its own lock 

---

## QuestionAsk: No Simultaneous Select + Type

![](https://img.shields.io/badge/-Important-D93F0B) 

```
What's next for cycle #3?

❯ 1. Commit
     Record and continue to #4 (referral lift)
  2. Refine
     Describe what to change
  3. Revert
     Undo
  4. Leave
     Keep uncommitted, move to #4
  5. Type something.
──────────────────────
```

**Feedback**

- In every `QuestionAsk` menu, selecting an option and typing free-form input are mutually exclusive — you must pick one then wait for Claude to 'think' then type.
- Other agents (e.g. Cursor CLI) allow selecting a choice and appending typed context in the same interaction
- Is this a Claude Code `QuestionAsk` tool limitation, or a configurable behaviour?

---

# Nice to Have

## Splash Screen

![](https://img.shields.io/badge/-Nice_to_have-0075CA)

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

- If we can make the ASCII art match the Databao logo more closely it'd be great!
- Use brand purple (`#8B5CF6`) 

---

## Semantic Layer Questions

![](https://img.shields.io/badge/-Nice_to_have-0075CA)

```bash
● Here are 5 questions I can build a semantic layer for:

   #  Question                                                    Metric                    Formula
  ─────────────────────────────────────────────────────────────────────────────────────────────────────
   1  What is the total revenue generated each day?               daily_total_revenue        SUM(total_revenue)
   2  How many orders are placed each month?                      monthly_order_count        COUNT(order_id)
   3  What is the average order value per month?                  monthly_avg_order_value    AVG(amount)
   4  Which product categories drive the most revenue each month? monthly_category_revenue   SUM(line_total)
   5  How many new customers sign up each month?                  monthly_new_customers      COUNT(customer_id)

  These questions will define your semantic layer. You can:
  - Type ok to proceed with all of them
  - Remove some, e.g. remove 3, 7
  - Add new ones, e.g. add: what's our average order value?
  - Type more to generate additional questions (optionally with a hint, e.g. more: focus on retention)
```

**Feedback**

- Replace free-text options with `QuestionAsk` tool — users should _select_, not type commands
- Suggested option order:
  - **Continue with all** (proceed)
  - **Remove questions** (pick which to drop)
  - **Add a question** (free text — label it "Write your own")

---

## GitHub Repo Offer

![](https://img.shields.io/badge/-Nice_to_have-0075CA)


``` bash
● User answered: Create new GitHub repo `albertoprb/test-shopify` — public or private? → Private
```

**Feedback**

- When no upstream remote is detected, proactively offer to initialize a GitHub repo and explain why. In the last version I did not see this option anymore. This is valuable given it's expected for deploy. 

---

## Deploy Output

![](https://img.shields.io/badge/-Nice_to_have-0075CA)


```bash
● Bash(echo "${DATABAO_WEB_URL:-https://databao-platform.labs.jb.gg}")
  ⎿  https://databao-platform.labs.jb.gg

● [ok] Everything is pushed.

  Open this URL in your browser to deploy:

  https://databao-platform.labs.jb.gg/import

  ---
  Coverage: 19 questions / 26 metrics / push-ready. Two broken CSV entries (rows 14 & 16) have malformed mf_query args — worth fixing after deploy
  if the Slack bot surfaces those questions.
```

**Feedback**

- Clearer call to action: "Finish deployment in the Databao web console: https://databao-platform.labs.jb.gg/import"

---

## Repeat Deploy Prompt

![](https://img.shields.io/badge/-Nice_to_have-0075CA)

```bash
● Project status

  ┌────────────────┬───────────────────────────────────────────────────────────────┐
  │ Project status │                             Value                             │
  ├────────────────┼───────────────────────────────────────────────────────────────┤
  │ Semantic layer │ 7 models / 19 metrics                                         │
  ├────────────────┼───────────────────────────────────────────────────────────────┤
  │ Test coverage  │ 19 questions → push-ready                                     │
  ├────────────────┼───────────────────────────────────────────────────────────────┤
  │ Working tree   │ 1 uncommitted file (feedback.md, unrelated to semantic layer) │
  └────────────────┴───────────────────────────────────────────────────────────────┘
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 ☐ What next?

You have 19 questions covered across 19 metrics. Deploy now?

❯ 1. Deploy
     Open the web console to deploy
  2. Keep building
     Add a question, describe a metric, or test how I'd answer something
  3. Type something.
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  4. Chat about this
```

**Feedback**

- After a successful deploy with no new changes, "Deploy" should not be the first option
- Detect state: if nothing changed since last deploy, skip the deploy prompt entirely and make the Keep building loop the first action

---

## Startup Output Order

![](https://img.shields.io/badge/-Nice_to_have-0075CA)

**Current** — auth messages appear before the splash screen:

```bash
❯ databao
Refresh token expired. Re-authentication required.
No valid token found. Running device auth flow...

Open: https://databao-platform-auth-dev.labs.jb.gg/realms/databao-platform/device?user_code=KTFN-VWCM
Opening in existing browser session.
Login successful!
Logged in as Alberto Barcelos
╭─── Databao v0.1.0 ─── ...splash... ───╮
╰────────────────────────────────────────╯
```

**Expected** — splash first, then auth:

```bash
❯ databao
╭─── Databao v0.1.0 ─── ...splash... ───╮
╰────────────────────────────────────────╯
Refresh token expired. Re-authentication required.
...auth flow...
Login successful!

? What would you like to do?
 » Start Databao in Claude Code
   Advanced settings
   Quit
```

**Feedback**

- Show the splash screen immediately on launch, then trigger auth underneath it

---

## Metric Resolution Messaging

![](https://img.shields.io/badge/-Nice_to_have-0075CA)

```
❯ Avg basket size by category

● Classifying: Business Question — average basket size broken down by product category.

  Checking if existing metrics cover this.

  Called plugin:databao:databao (ctrl+o to expand)

● Grounded. Checking if avg_order_value can be grouped by category via existing dimensions.

  Read 2 files (ctrl+o to expand)

● No existing metric covers avg basket size by category. avg_order_value lives on fct_sales (order grain, no category dimension). Need a new derived
   metric on fct_order_items: SUM(line_total) / COUNT_DISTINCT(order_id) grouped by category.
```

**Feedback**

- "Grounded" is an internal technical term — end users won't understand it
- The flow is also confusing: it first says "Grounded" (implying the metric exists), then immediately says a new metric is needed — contradictory
- Replace "Grounded" in instruction with plain language that reflects what was actually found, e.g.:
  - If metric exists: "A metric to answer this exists — checking if `avg_order_value` can be grouped by category via existing dimensions."
  - If metric is missing: "No existing metric covers this. A new derived metric is needed: `SUM(line_total) / COUNT_DISTINCT(order_id)` grouped by category on `fct_order_items`."
- The resolution check (exists vs. needs new metric) should produce a single clear verdict, not two contradictory statements

---

## Coverage Summary After Commit

```
● Committed. Coverage: 19 questions / 14 metrics.

  ---
  All 6 intents processed:
```

**Feedback**

- "19 questions / 14 metrics" doesn't tell you enough — how many metrics exist in the project total?
- Should show: `19 questions / 14 metrics covered / N metrics total` so the user can judge completeness at a glance
- Example:
  ```
  Coverage: 19 questions · 14 of 18 metrics covered (4 uncovered)
  ```
- Ideally list the uncovered metrics so the user knows what's still missing
