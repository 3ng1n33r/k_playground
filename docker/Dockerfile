FROM python:3.12-alpine

ARG ANSIBLE_VERSION=11.4.0
ARG ANSIBLE_LINT_VERSION=25.4.0
ARG YAML_LINT_VERSION=1.37.0

RUN apk add --update --no-cache \
    openssh-client
RUN pip install --no-cache-dir --upgrade pip \ 
    && pip install --no-cache-dir ansible==${ANSIBLE_VERSION} ansible-lint==${ANSIBLE_LINT_VERSION} yamllint==${YAML_LINT_VERSION}

CMD [ "" ]
