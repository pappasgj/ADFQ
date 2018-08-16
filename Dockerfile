FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install sudo git wget python-dev python3-dev libopenmpi-dev python-pip python3-pip zlib1g-dev cmake python-opencv tmux

RUN pip3 install pyyaml scipy numpy tensorflow-gpu tabulate

WORKDIR /tmp/

RUN export uid=1008 gid=1008 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

USER developer

ENV HOME /home/developer/Desktop/docker-code/
WORKDIR /home/developer/Desktop/docker-code/

RUN sudo git clone https://github.com/openai/baselines.git
WORKDIR /home/developer/Desktop/docker-code/baselines

RUN rm -rf __pycache__ && \
    find . -name "*.pyc" -delete && \
    sudo pip3 install -e .[test]

WORKDIR /home/developer/Desktop/docker-code/
RUN sudo git clone https://github.com/coco66/ADFQ.git
RUN sudo scp ADFQ/DeepADFQ/deepq_add/* baselines/baselines/deepq/
RUN sudo mv baselines/baselines/deepq/run* baselines/baselines/deepq/
experiments/
RUN export PYTHONPATH=/home/developer/Desktop/docker-code/ADFQ/:$PYTHONPATH

CMD ['python3', 'baselines/baselines/deepq/__init__.py']