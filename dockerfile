FROM jenkins/jenkins:lts-jdk11

USER root
# ติดตั้ง Docker CLI
RUN apt update && curl -fsSL https://get.docker.com | sh
# ให้ user jenkins ใช้ docker ได้
RUN usermod -aG docker jenkins

USER jenkins