# 使用官方輕量版 Python 3.13.15 image 當底層基礎環境
FROM python:3.13.15-slim

# 把 uv 官方 image 裡已經 build 好的 uv 執行檔複製過來，不用另外安裝
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

# 後續指令的工作目錄，之後的相對路徑都是相對於這裡
WORKDIR /code
# 把虛擬環境的 bin 目錄加進 PATH，這樣可以直接下指令（例如 python、pipeline）而不用 uv run
ENV PATH="/code/.venv/bin:$PATH"

# 先只複製相依套件定義相關的檔案（還不含原始碼），讓下一行的安裝結果可以被 Docker layer cache 住
COPY pyproject.toml .python-version uv.lock ./

# 依 uv.lock 安裝相依套件；--no-install-project 代表先不 build/安裝 pipeline 這個 package 本身
# 這樣只要原始碼變動、相依套件沒變，這一層就能重複使用 cache，不用重新下載套件
RUN uv sync --locked --no-install-project

# pyproject.toml 裡 readme 欄位指到這個檔案，build package 時需要它存在
COPY README.md ./
# 複製實際的原始碼（src/pipeline 這個 package）進去
COPY src ./src
# 這次原始碼齊全了，正式把 pipeline 這個 package 本身也 build/安裝進虛擬環境
RUN uv sync --locked

# 複製獨立的執行腳本 pipeline.py 進 image（跟 src/pipeline package 是不同東西）
COPY pipeline.py .

# 容器啟動時預設執行的指令：用虛擬環境裡的 python 執行 pipeline.py
ENTRYPOINT ["python", "pipeline.py"]