FROM python:3.12

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# install build deps needed to compile wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    python3-dev \
    libssl-dev \
    libffi-dev \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

COPY poetry.lock pyproject.toml /app/

# copy source so editable build can find package files
COPY . /app/

# ensure modern build tooling then install the project (editable)
RUN pip install --upgrade pip setuptools wheel build && \
    pip install --no-cache-dir -e .

# remove build deps to shrink image (optional)
RUN apt-get purge -y --auto-remove build-essential gcc python3-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 5000

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

ENTRYPOINT ["/usr/local/bin/python"]
CMD ["-m", "evse_controller.app"]