FROM python:3.11-alpine

WORKDIR /usr/src/app

COPY . .
RUN apk add --no-cache wget

RUN wget -O /usr/src/app/rds-combined-ca-bundle.pem \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

RUN python -m venv venv && pip install --no-cache-dir -r requirements.txt

ENV MONGODB_URL="mongodb://db:27017"

COPY . .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
