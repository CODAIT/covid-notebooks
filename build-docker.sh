
# Shell script to build the main container image for running the notebooks in
# this project on Kubeflow Pipelines.
cp requirements.txt etc/docker
docker build -t codait/covid-notebooks-anaconda-py3:latest etc/docker --progress plain
rm etc/docker/requirements.txt
docker push codait/covid-notebooks-anaconda-py3:latest
