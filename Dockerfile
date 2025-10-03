FROM python:3.10

WORKDIR /app

COPY requirements_docker.txt .

RUN pip install -r requirements_docker.txt
COPY saved_models ./saved_models
COPY data ./data
COPY main.py ./main.py
COPY config.json ./config.json
COPY lib ./lib

CMD [ "uvicorn",  "main:app", "--host", "0.0.0.0", "--port", "5000", "--workers", "2"]