FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y sudo netcat && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
  
RUN wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip && \
  unzip terraform_0.11.13_linux_amd64.zip && mv terraform /usr/local/bin/terraform && rm -rf terraform_0.11.13_linux_amd64.zip

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
