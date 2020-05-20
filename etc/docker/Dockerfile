FROM continuumio/anaconda3:latest

RUN apt-get update
RUN apt install -y curl git-core build-essential

RUN conda install -c anaconda numpy && \
    pip install --upgrade pip && \
    pip install --upgrade notebook nbclient jupyter-client nbconvert nbformat \
                          pandas==1.0.3 xlrd regex matplotlib==3.2.1 cython grpcio-tools \
                          scikit-learn pyarrow fastparquet plotly memoized-property \
                          opt-einsum==2.3.2 seaborn scipy && \
    pip install --upgrade git+https://github.com/frreiss/text-extensions-for-pandas
