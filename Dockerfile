FROM python:3.10-slim

WORKDIR /app

ENV PYTHONPATH=/app

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /app/

RUN pip install -r requirements.txt --no-cache-dir

COPY ./src /app/src

COPY ./settings /app/settings

EXPOSE 8002

CMD ["uvicorn","src.main:app","--host","0.0.0.0","--port","8002","--reload"]

