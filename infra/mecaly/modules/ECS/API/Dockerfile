FROM python:3.8-slim-buster as build

ENV PATH="/root/.local/bin:${PATH}"\
    DJANGO_SECRET_KEY="secret"

RUN apt-get update \
    && \
    apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        gdal-bin \
        python3-dev

COPY . /app
WORKDIR /app

RUN pip install --user -r requirements.txt && \
    python manage.py collectstatic --noinput

CMD gunicorn ddp_api.wsgi:application --reload --config gunicorn.conf.py

EXPOSE 8000