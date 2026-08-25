# Docker

## 什麼是 Docker

Docker 是一個**容器化（containerization）平台**，讓你把應用程式跟它所需要的執行環境
（程式碼、函式庫、系統相依套件、設定）一起打包成一個獨立、可攜帶的單位，
不管在哪台機器上執行，行為都一致 —— 解決「在我電腦上明明可以跑」的問題。

### 核心概念

- **Image**：唯讀模板，打包好的應用程式與環境（詳見下方 Docker Image 章節）
- **Container**：Image 執行起來的實例，彼此互相隔離
- **Dockerfile**：描述如何一步步建立 Image 的腳本
- **Registry**（如 Docker Hub）：存放與分享 Image 的地方
- **Docker Engine**：安裝在主機上、負責 build/run/管理 container 的背景服務（daemon）

### 跟傳統虛擬機（VM）的差異

| | Docker Container | 虛擬機（VM） |
|---|---|---|
| 虛擬化層級 | 作業系統層級（共用 host 的 kernel） | 硬體層級（每台都有自己的 Guest OS） |
| 啟動速度 | 秒級 | 分鐘級 |
| 資源開銷 | 小，多個 container 可共用資源 | 大，每台 VM 都要占用完整資源 |
| 隔離性 | 較弱（共用 kernel） | 較強（完全獨立的 OS） |

### 為什麼資料工程會用到 Docker

- 快速在本機起一套 Kafka / Elasticsearch / Spark / 資料庫，不用手動安裝設定
- 用 `docker-compose` 一次拉起多個服務並定義好彼此的網路關係
- 開發、測試、正式環境使用同一份 Image，減少「環境不一致」造成的問題

---

# Docker Image

## 是什麼

Docker Image 是一個**唯讀的模板**，裡面打包了執行一個應用程式所需要的一切：
程式碼、runtime、系統工具、函式庫、環境變數與設定檔。

可以把它想成「軟體的安裝光碟」或「class」；
而 **Container** 是把這個 Image 實際跑起來的**執行實例**，相當於「instance」。

- Image：唯讀、靜態、可以被重複使用
- Container：Image + 一層可寫入的層（read-write layer），跑起來後才存在

同一個 Image 可以同時啟動多個 Container，彼此互不影響。

## Image 的取得方式

1. **從 Docker Hub / registry 拉取現成的 image**
   ```
   docker pull ubuntu
   docker pull ubuntu:22.04
   ```
2. **自己用 Dockerfile build**
   ```
   docker build -t myapp:1.0 .
   ```

## 命名規則：`repository:tag`

例如 `ubuntu:22.04`

- `repository`：image 的名稱（可包含 registry / namespace，如 `myregistry.com/team/app`）
- `tag`：版本標籤，省略時預設是 `latest`（**latest 不代表「最新」，只是預設 tag 名稱**）
- 每個 tag 底層對應到一個唯一的 **image ID（digest）**

## 常用指令

| 指令 | 說明 |
|---|---|
| `docker images` | 列出本機所有 image |
| `docker pull <image>` | 從 registry 下載 image |
| `docker build -t <name>:<tag> .` | 依 Dockerfile 建立 image |
| `docker tag <image> <new-name>` | 幫 image 加上新的名稱/標籤 |
| `docker push <image>` | 上傳 image 到 registry |
| `docker rmi <image>` | 刪除本機的 image |
| `docker history <image>` | 查看 image 的分層歷史 |
| `docker inspect <image>` | 查看 image 詳細 metadata |

## 與 Container 的關係一句話總結

> Image 是模板（唯讀），Container 是把模板跑起來後、加上一層可寫層的實體。
> 刪除 Container 不會影響 Image；但 Image 被刪除前，必須先移除所有以它建立的 Container。

---

# Q&A 筆記（pipeline 專案）2026-08-25

- `docker build -t test:pandas .`：用當前目錄的 Dockerfile build image，命名 `test`、標籤 `pandas`，`.` 是 build context（`COPY` 指令的相對路徑基準）。
- `docker run -it --rm test:pandas 123`：
  - `-it`：`-i`（保留 stdin）+ `-t`（分配 tty），讓容器可互動、即時看輸出。
  - `--rm`：容器跑完自動刪除，不留殘留的 stopped container。
  - `123` 會傳給 `ENTRYPOINT ["python", "pipeline.py"]` 當參數，等同 `python pipeline.py 123`。
- `uv add --dev pgcli`：`--dev` 代表加進 dev 相依（開發用工具，如 `pgcli`、`jupyter`、`pytest`），不是 production 執行時需要的套件。
  - production image 用 `uv sync --locked --no-install-project` 這類指令預設不會裝 dev 相依，image 更小。
  - 判斷標準：pipeline 程式碼會 `import` 的 → 一般相依；只是開發時自己用（如用 Jupyter 做資料探索）→ `--dev`。
- `uv run jupyter nbconvert --to=script notebook.ipynb`：把 `notebook.ipynb` 轉成純 `.py` 腳本（`--to=script`），方便把 Jupyter 上寫好的邏輯搬進正式的 pipeline 程式碼；`uv run` 會確保在專案的虛擬環境裡執行（自動用到 `--dev` 裝的 jupyter）。
- `uv run pgcli -h localhost -p 5431 -u root -d ny_taxi`：用 `pgcli`（比 `psql` 更好用、有語法高亮/自動完成的 CLI）連線到本機 Postgres：
  - `-h localhost`：連線主機
  - `-p 5431`：連線埠（對應到跑 postgres container 時對外映射的 port）
  - `-u root`：登入使用者
  - `-d ny_taxi`：要連線的資料庫名稱
  - 一樣透過 `uv run` 執行，用到的是 `uv add --dev pgcli` 裝進虛擬環境的那個工具。
- `click`：Python 的 CLI 框架套件，用 decorator（`@click.command()` / `@click.option()`）就能把一支腳本的變數變成可從指令列傳入的參數，並自動產生 `--help` 說明、型別轉換（`type=int`）、預設值（`default=`）等功能，不用自己手刻 `argparse`。用 `uv add click` 裝成正式相依（因為 `ingest_data.py` 執行時會 `import click`，不是開發用工具）。
- `uv run python .\ingest_data.py --help`：在專案虛擬環境裡執行 `ingest_data.py` 並顯示 `--help`，列出 `click` 幫忙自動產生的所有參數說明（`--pg-user`、`--pg-password`、`--pg-host`、`--pg-port`、`--pg-db`、`--target-table`、`--year`、`--month`、`--chunk-size`），可以用來確認參數是否有被正確定義，也可以拿掉 `--help`、帶上實際的值來執行腳本。
