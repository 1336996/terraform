FROM python:3.8-slim-buster as build

ARG ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs"]'

WORKDIR /srv
COPY . /srv/

SHELL ["/bin/bash", "--login", "-c"]
RUN apt update \
    && apt install wget ffmpeg -y --no-install-recommends \
    && wget https://github.com/mozilla/sops/releases/download/v3.5.0/sops-v3.5.0.linux \
    && mv sops-v3.5.0.linux /bin/sops \
    && chmod +x /bin/sops \
	&& wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && sh Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && rm -rf /var/lib/apt/lists/* \
    && source /root/miniconda3/etc/profile.d/conda.sh \
	&& conda activate \
	&& conda install --yes -c conda-forge/label/cf202003 entwine \
    && pip install -r requirements.txt \
	&& conda clean -i -a -t -y \
	&& find /root/miniconda3/ -follow -type f -name '*.a' -delete \
    && find /root/miniconda3/ -follow -type f -name '*.pyc' -delete \
    && echo "source /root/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc \
	&& echo "conda activate base" >> ~/.bashrc

WORKDIR /srv/src
ENV ENV="~/.bashrc"


CMD celery worker --app=worker.tasks -l info
