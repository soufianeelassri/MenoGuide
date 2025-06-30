FROM python:3.12-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r agents/requirements.txt

RUN adduser --disabled-password --gecos "" myuser && \
    chown -R myuser:myuser /app
USER myuser

EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]