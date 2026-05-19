# dbt sample projects

A curated collection of **medium-complexity dbt projects** for testing agentic workflows—especially **semantic layer / MetricFlow generation**. All third-party projects are vendored here **without nested git history** so this folder is the single source of truth.

**Stack focus:** [dbt](https://www.getdbt.com/) + [DuckDB](https://duckdb.org/) (local, easy to distribute). Most projects use seed CSVs or small data scripts; no cloud warehouse required.

## Quick start

Each subfolder is an independent dbt project. From a project directory:

```bash
python -m venv .venv && source .venv/bin/activate
pip install dbt-duckdb
# For semantic layer / MetricFlow projects, also:
pip install dbt-metricflow

dbt deps    # if the project uses packages
dbt seed    # load CSV seeds (where applicable)
dbt run
dbt parse   # validates semantic manifest when MetricFlow is configured
```

See each project’s own `README.md` for project-specific setup (data generation scripts, profiles, etc.).

## Project index

| Folder | SQL models | Semantic layer | Best for |
|--------|------------|----------------|----------|
| [`semantic-layer-online-course/`](semantic-layer-online-course/) | 9 | **Partial** — marts only (legacy YAML) | Complete semantic definitions for staging from mart examples |
| [`data-modeling-example/`](data-modeling-example/) | 16 | **None** | Full semantic generation from scratch (multi-source e-commerce) |
| [`dbt-core-sample-duckdb/`](dbt-core-sample-duckdb/) | 11 | **None** | Full generation on retail star schema (IBM GO Sales) |
| [`dbt-ecommerce-analytics/`](dbt-ecommerce-analytics/) | 6 | **None** | Smaller baseline; synthetic data + data-quality edge cases |
| [`motherduck-metricflow-example/`](motherduck-metricflow-example/) | 2 | **Complete** | Smoke test / golden path for MetricFlow + DuckDB |

### Recommended benchmark scenarios

| Scenario | Use this project |
|----------|------------------|
| Partial metrics (semantic model exists, metrics missing) | Add your own `test-shopify`-style project, or extend `semantic-layer-online-course` |
| Staging without semantic, marts with rich semantic | `semantic-layer-online-course` |
| Generate entire semantic layer (~medium scale) | `data-modeling-example` or `dbt-core-sample-duckdb` |
| Minimal MetricFlow correctness check | `motherduck-metricflow-example/metricflow-example/ecommerce_metrics/` |

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

## What makes a good semantic-generation benchmark

| Signal | Why it matters |
|--------|----------------|
| **8–20 SQL models** | Enough joins and grains without huge repos |
| **Mixed coverage** | Some models with semantic definitions, some without |
| **Incomplete semantic** | e.g. measures defined but no `metrics:` block |
| **DuckDB + seeds** | Runnable locally, easy to ship in CI |
| **YAML format variety** | Modern `semantic_models:` files vs legacy `semantic_model:` under `models:` |

## Adding `test-shopify` (optional)

A local **Shopify analytics** project (`test-shopify`) was previously used as the best **partial-coverage** benchmark (DuckDB, 5 staging models, MetricFlow semantic models with metrics on most entities, **`sem_products` missing metrics**). It is not vendored here because it was not tied to a public upstream repository.

To add it: copy your project into `test-shopify/`, ensure there is **no** `.git` directory inside, and commit from this repo root.

## Upstream licenses

Each subfolder retains its upstream `LICENSE` / `README` where provided. Refer to those files for attribution and license terms.

## Repository layout

```
sample-projects/
├── README.md                          # this file
├── .gitignore
├── semantic-layer-online-course/
├── data-modeling-example/
├── dbt-core-sample-duckdb/
├── dbt-ecommerce-analytics/
└── motherduck-metricflow-example/
    └── metricflow-example/
        └── ecommerce_metrics/         # actual dbt project
```
