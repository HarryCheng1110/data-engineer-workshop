# pipeline

## 什麼是 uv

`uv` 是用 Rust 寫的 Python 套件與專案管理工具，由 Astral（Ruff 的作者）開發。
它把過去需要靠 `pip` + `venv` + `pip-tools` + `pyenv` 好幾個工具才能做到的事情，
整合成一個單一的執行檔：

- 建立與管理虛擬環境
- 安裝 / 解析套件相依性（lockfile）
- 管理專案的 `pyproject.toml`
- 管理多個 Python 版本（不需要另外裝 pyenv）
- 執行專案指令（`uv run`）

## 跟 venv 的差別

`venv` 只做一件事：建立一個獨立的虛擬環境資料夾，讓套件安裝彼此隔離。
它**不負責**安裝套件、解析相依性或管理 Python 版本，這些都要另外靠 `pip` 完成。

`uv` 則是把 venv 建立、套件安裝、相依解析、lockfile 都包在一起，而且底層是用 Rust 實作。

| | venv (+ pip) | uv |
|---|---|---|
| 建立虛擬環境 | ✅ `python -m venv .venv` | ✅ `uv venv`（或 `uv sync` 自動建立） |
| 安裝套件 | 要靠 pip，速度較慢 | 內建，速度快非常多（平行下載、Rust 實作） |
| 相依解析 / lockfile | 沒有內建，要另裝 pip-tools / poetry | 內建 `uv.lock`，解析速度快且結果確定 |
| Python 版本管理 | 沒有，要另裝 pyenv | 內建 `uv python install` |
| 專案管理（pyproject.toml） | 沒有 | 內建，`uv add` / `uv remove` 自動更新 |
| 快取機制 | 無特別設計 | 全域套件快取，多專案共用同一份下載，省空間又省時間 |

一句話：**venv 只是虛擬環境，uv 是虛擬環境 + pip + pip-tools + pyenv 的整合版，而且快很多。**

## 優點（Pro）

- **速度快**：安裝/解析套件比 pip 快 10~100 倍（Rust 實作 + 平行處理）
- **一個工具打天下**：不用同時記 pip、venv、pyenv、poetry 的用法
- **有 lockfile（`uv.lock`）**：確保團隊每個人、CI、正式環境裝到完全相同版本的套件，重現性好
- **內建 Python 版本管理**：`uv python install 3.13` 不用額外裝 pyenv
- **相容 pip 生態**：可以讀 `requirements.txt`，也支援 `pyproject.toml` 標準格式
- **全域快取**：多個專案共用下載快取，重複建立環境時幾乎瞬間完成

## 缺點（Con）

- **相對年輕**：2024 年才推出，生態圈與踩坑經驗不如 pip/poetry 成熟
- **進階功能仍在演進**：例如 workspace（monorepo 多套件管理）等功能還在持續變動
- **團隊需要重新學習**：習慣 pip/poetry 流程的人需要花時間切換心智模型
- **部分老舊/小眾套件**：極少數對 build 環境有特殊需求的套件可能相容性問題要自行排查

## 基本指令

```bash
# 初始化一個新專案（會產生 pyproject.toml、.python-version、README.md、src/ 等）
uv init --python 3.13

# 安裝/切換指定 Python 版本（不用額外裝 pyenv）
uv python install 3.13
uv python list

# 新增一個相依套件（會自動寫進 pyproject.toml 並更新 uv.lock）
uv add requests
uv add --dev pytest

# 移除套件
uv remove requests

# 依 pyproject.toml / uv.lock 同步安裝所有相依套件（建立/更新虛擬環境）
uv sync

# 在專案的虛擬環境中執行指令，不用手動 activate
uv run python pipeline.py
uv run pytest

# 單純建立一個虛擬環境（類似 python -m venv）
uv venv

# 鎖定目前的相依版本，產生/更新 uv.lock
uv lock

# 用 pip 相容介面安裝套件（不透過 pyproject.toml）
uv pip install requests
```
