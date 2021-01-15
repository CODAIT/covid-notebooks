FROM continuumio/anaconda3:latest

RUN apt-get update
RUN apt install -y curl git-core build-essential

COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt

RUN conda install -c anaconda numpy && \
    pip install --upgrade pip && \
    pip install --upgrade notebook nbclient jupyter-client nbconvert nbformat && \
    pip install --upgrade --requirement /tmp/requirements.txt

