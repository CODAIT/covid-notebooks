FROM continuumio/anaconda3:latest

RUN apt-get update
RUN apt install -y curl git-core build-essential

RUN pip install --upgrade pip && \
    pip install --upgrade notebook nbclient jupyter-client nbconvert nbformat
