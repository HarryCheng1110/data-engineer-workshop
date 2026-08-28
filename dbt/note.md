# dbt + DuckDB 本機環境建置紀錄 2026-08-28

- `uv init --app --python 3.13 --name dbt_project --no-readme`：在 `dbt/` 目錄下用 uv 建一個新專案（`--app` 代表這是一支應用程式，不是要被別人 import 的函式庫）。
  - 產生 `pyproject.toml`、`.python-version`、`src/` 這些檔案；因為 dbt 專案本身不需要被打包成 python package，後續把 `src/` 整個刪掉，`pyproject.toml` 也手動精簡成只留 `[project]` 區塊。
- `uv add dbt-duckdb`：安裝 dbt 的 DuckDB adapter，這個套件會自動一併裝好 `dbt-core`。
  - DuckDB 是一個「嵌入式」的分析型資料庫（跟 SQLite 類似的概念），不用另外開 container/server，資料就是本機的一個 `.duckdb` 檔案，很適合本機練習/開發用。
- `uv run dbt --version`：確認 dbt 有裝成功，並列出目前用的 adapter（`duckdb`）版本。
- `uv run dbt init my_dbt_project --skip-profile-setup`：用 dbt 官方指令產生一個新的 dbt 專案骨架（`models/`、`seeds/`、`macros/`、`dbt_project.yml` 等）。
  - `--skip-profile-setup`：跳過互動式問答，不要讓它自動把連線設定寫進 `~/.dbt/profiles.yml`，改成自己手動寫一份放在專案裡（見下方 `profiles.yml`）。
- 手動新增 `my_dbt_project/profiles.yml`，指定 `type: duckdb`、`path: dev.duckdb`：
  - dbt 的連線設定（要連哪個資料庫、帳密等）預設放在 `~/.dbt/profiles.yml`（跟專案分開，通常是因為裡面可能有密碼，不想進 git）。
  - 這裡因為 DuckDB 是本機檔案、沒有密碼，直接放在專案資料夾裡更方便攜帶；用環境變數 `DBT_PROFILES_DIR` 告訴 dbt 要去哪裡找這份設定，而不是用預設的 `~/.dbt`。
- `DBT_PROFILES_DIR=. uv run --project .. dbt debug`：檢查 dbt 專案設定跟資料庫連線是否正常。
  - `DBT_PROFILES_DIR=.`：因為指令是在 `my_dbt_project/` 目錄下執行，所以指定「當前目錄」去找 `profiles.yml`。
  - `uv run --project ..`：因為 uv 專案（`pyproject.toml`/`.venv`）是放在上一層的 `dbt/` 目錄，用 `--project ..` 告訴 uv 去那裡找虛擬環境，但指令本身還是在 `my_dbt_project/` 目錄下執行。
- `DBT_PROFILES_DIR=. uv run --project .. dbt build`：執行 dbt 專案裡的所有 model（建表/建 view）並跑資料測試（如 not_null、unique）。
  - dbt 官方骨架內建的範例 model 會故意塞一筆 null 資料來示範測試失敗的樣子，所以第一次跑 `dbt build` 看到 1 個測試 FAIL 是預期行為，不是設定有問題。
- 新增 `dbt/.gitignore`，排除 `.venv/`、`logs/`、`*.duckdb`：虛擬環境、dbt 執行紀錄、本機的 DuckDB 資料庫檔案都不需要（也不應該）進版控。
