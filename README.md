# dbt sample projects

A curated collection of **medium-complexity dbt projects** for testing agentic workflows—especially **semantic layer / MetricFlow generation**. All third-party projects are vendored here **without nested git history** so this folder is the single source of truth.

**Stack focus:** [dbt](https://www.getdbt.com/) + [DuckDB](https://duckdb.org/) (local, easy to distribute). Most projects use seed CSVs or small data scripts; no cloud warehouse required.

## Quick start

### One-time setup (repository root)

This repo uses [mise](https://mise.jdx.dev/) and [uv](https://docs.astral.sh/uv/) for a **single shared environment** (Python 3.12, dbt Core 1.11, dbt-duckdb, MetricFlow, DuckDB CLI). All subprojects inherit it automatically when you work inside any folder under this tree.

```bash
cd sample-projects
mise trust          # first time only, if prompted
mise run setup      # installs tools, creates .venv, runs uv sync
mise run version
```

After changing dependencies in `pyproject.toml`:

```bash
mise run lock       # update uv.lock
mise run sync       # uv sync into .venv
```

### Run a dbt project

Each subfolder is an independent dbt project. With mise activated (`cd` into the repo or any subfolder), from that project directory:

```bash
dbt deps    # if the project uses packages
dbt seed    # load CSV seeds (where applicable)
dbt run
dbt parse   # validates semantic manifest when MetricFlow is configured
```

Per-project `requirements.txt` files are legacy upstream pins; use the root `pyproject.toml` / `uv.lock` unless you intentionally need an isolated venv.

Enable automatic activation in your shell (once per machine):

```bash
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc   # or bash/fish equivalent
```

After that, `cd` into any subfolder under this repo and `dbt`, `mf`, and `duckdb` are on your PATH.

See each project’s own `README.md` for project-specific setup (data generation scripts, profiles, etc.).

## Project index

| Folder | SQL models | Semantic layer | Best for |
|--------|------------|----------------|----------|
| [`semantic-layer-online-course/`](semantic-layer-online-course/) | 9 | **Partial** — marts only (legacy YAML) | Complete semantic definitions for staging from mart examples |
| [`data-modeling-example/`](data-modeling-example/) | 16 | **None** | Full semantic generation from scratch (multi-source e-commerce) |
| [`dbt-core-sample-duckdb/`](dbt-core-sample-duckdb/) | 11 | **None** | Full generation on retail star schema (IBM GO Sales) |
| [`dbt-ecommerce-analytics/`](dbt-ecommerce-analytics/) | 6 | **None** | Smaller baseline; synthetic data + data-quality edge cases |
| [`motherduck-metricflow-example/`](motherduck-metricflow-example/) | 2 | **Complete** | Smoke test / golden path for MetricFlow + DuckDB |

---

## Projects

### `semantic-layer-online-course`

- **Source:** [dbt-labs/Semantic-Layer-Online-Course](https://github.com/dbt-labs/Semantic-Layer-Online-Course)
- **Domain:** Jaffle Shop (orders, customers, supplies)
- **Layers:** staging → marts
- **Database:** DuckDB (designed for devcontainer / Codespaces)
- **Semantic coverage:** Staging models have **no** semantic layer. Mart models (`fct_orders`, `fct_order_items`, `dim_customers`) define **`semantic_model:` inline** in model YAML (older/course format), including measures and metrics.
- **Agent use case:** Infer semantic definitions for `stg_*` models from patterns in mart YAML; test legacy vs modern MetricFlow YAML handling.

### `data-modeling-example`

- **Source:** [astrafy/data-modeling-example](https://github.com/astrafy/data-modeling-example)
- **Domain:** Fictional e-commerce analytics (two sales systems + CRM)
- **Layers:** staging → intermediate → datamart → utilities
- **Database:** DuckDB, self-contained seed CSVs
- **Semantic coverage:** **None** — 16 SQL models, zero `semantic_models` / metrics.
- **Agent use case:** Primary **from-scratch** benchmark at realistic medium scale (unions, dims, facts, aggregates).

### `dbt-core-sample-duckdb`

- **Source:** [manz01/dbt-core-sample-duckdb](https://github.com/manz01/dbt-core-sample-duckdb)
- **Domain:** IBM GO Sales retail sample
- **Layers:** raw → staging → detail → mart
- **Database:** DuckDB
- **Semantic coverage:** **None** — 11 SQL models (dimensions + fact sales).
- **Agent use case:** Second **from-scratch** benchmark with a different domain and naming conventions (DET/MRT layers).

### `dbt-ecommerce-analytics`

- **Source:** [minimalmerlin/dbt-ecommerce-analytics](https://github.com/minimalmerlin/dbt-ecommerce-analytics)
- **Domain:** E-commerce / SaaS-style analytics
- **Layers:** staging → intermediate (cohorts) → marts
- **Database:** DuckDB; run `generate_data.py` to create synthetic data
- **Semantic coverage:** **None** — 6 SQL models.
- **Agent use case:** Smaller, fast runs; window functions and intentional data-quality issues in generated data.

### `motherduck-metricflow-example`

- **Source:** [motherduckdb/motherduck-examples](https://github.com/motherduckdb/motherduck-examples) (`dbt-metricflow/` subtree only)
- **Domain:** Minimal e-commerce orders
- **Entry point:** `metricflow-example/ecommerce_metrics/`
- **Database:** DuckDB (optional MotherDuck target in upstream docs)
- **Semantic coverage:** **Fully defined** — single `semantic_models.yml` with measures and metrics (including a derived metric).
- **Agent use case:** Validate MetricFlow install and query path; **not** suitable for generation benchmarks (too few models).

---

## Upstream licenses

Each subfolder retains its upstream `LICENSE` / `README` where provided. Refer to those files for attribution and license terms.

## Repository layout

```
sample-projects/
├── README.md                          # this file
├── mise.toml                          # shared Python 3.12 + uv + DuckDB CLI
├── pyproject.toml                     # shared Python deps (dbt, MetricFlow)
├── uv.lock                            # locked versions for uv sync
├── .gitignore
├── semantic-layer-online-course/
├── data-modeling-example/
├── dbt-core-sample-duckdb/
├── dbt-ecommerce-analytics/
└── motherduck-metricflow-example/
    └── metricflow-example/
        └── ecommerce_metrics/         # actual dbt project
```
