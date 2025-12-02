FROM python:3.9-slim-bullseye


RUN apt-get update && apt-get install -y \
    git \
    default-libmysqlclient-dev \
    gcc \
    python3-dev \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /usr/app

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    "protobuf>=4.0.0,<5.0.0" \
    dbt-core==1.7.9 \
    dbt-mysql==1.7.0

CMD ["tail", "-f", "/dev/null"]