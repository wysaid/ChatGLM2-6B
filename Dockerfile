# y-tech gpu dockerfile

ARG from

FROM ubuntu:latest

# yes | unminimize

RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
    apt-utils \
    wget \
    curl \
    git \
    git-lfs \
    python3 \
    python3-pip

RUN rm -rf "/var/lib/apt/lists/*"

RUN git lfs install

RUN mkdir -p /data/chatglm2-6b
WORKDIR /data/chatglm2-6b

ADD . ./

WORKDIR /data/chatglm2-6b

RUN pip3 install -r requirements.txt

COPY <<EOF ./run_web_demo.sh
#!/usr/bin/env bash

thisDir=\$(cd dirname \$0; pwd)

echo "current dir = \$(pwd)"

mkdir -p /data && cd /data

if [[ ! -d "chatglm2-6b" ]]; then
    git clone https://github.com/THUDM/ChatGLM2-6B.git chatglm2-6b
fi

cd chatglm2-6b

git checkout main
git pull

pip3 install -r requirements.txt

python3 web_demo.py
EOF

EXPOSE 80

WORKDIR /data/chatglm2-6b

CMD ["bash", "run_web_demo.sh"]

# build:

# docker build -t wysaid/chatglm2-6b .

# run:

#  docker run --gpus all -d --restart unless-stopped --name chatglm2-6b-webdemo \
#         -v /var/run/docker.sock:/var/run/docker.sock \
#         -p 40080:80 \
#         -it \
#         wysaid/chatglm2-6b:latest