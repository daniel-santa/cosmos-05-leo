# Agnostic Development Environment
# Depends on docker-compose.yml and .env files

ARG VARIANT
ARG OS_IMG
FROM ${OS_IMG}:${VARIANT}
LABEL mantainer="juan.pineda@pyxisportal.co"

ARG WORKDIR
WORKDIR /${WORKDIR}

# User configuration
ARG DOCKER_USER
ARG USER_ID
ARG GROUP_ID
ARG BIN_DIR

# Tools versions
ARG HADOLINT_VERSION
ARG SHELLCHECK_VERSION

# Terraform tools versions
ARG TF_VERSION
ARG TFGRUNT_VERSION
ARG TFDOCS_VERSION
ARG TFSEC_VERSION
ARG TSCAN_VERSION

# Golang
ARG GO_VERSION

# Install apt dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends emacs-nox=1:27.1+1-3.1 \
    wget=1.21-1+deb11u1 unzip=6.0-26+deb11u1 xz-utils=5.2.5-2.1~deb11u1 mlocate=0.26-5 \
    less=551-2 sudo=1.9.5p2-3 bat=0.12.1-6+b2 bash-completion=1:2.11-2 jq=1.6-2.1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install python dependencies with pip
COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    && rm -rf /tmp/pip-tmp

# Install DooD
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget --progress=dot:mega -O - https://get.docker.com/ | sh

# Create dev user
RUN echo "${DOCKER_USER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${DOCKER_USER} \
    && if id ${DOCKER_USER} 2>/dev/null; then userdel -f ${DOCKER_USER}; fi \
    && if getent group ${DOCKER_USER}; then groupdel ${DOCKER_USER}; fi \
    && groupadd -g ${GROUP_ID} ${DOCKER_USER} \
    && useradd -l -u ${USER_ID} -g ${DOCKER_USER} ${DOCKER_USER} \
    && install -d -m 0755 -o ${DOCKER_USER} -g ${DOCKER_USER} /home/${DOCKER_USER} \
    && usermod -a -G docker ${DOCKER_USER} \
    && usermod -a -G sudo ${DOCKER_USER}

# Other tools like ansible, localstack, awslocal, tflocal and others are pip3 dependencies.
# Please consider change the version on requirements.txt

# Install dev tools and aws cli
RUN wget --progress=dot:mega https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && echo "complete -C /usr/local/bin/aws_completer aws" >> ~/.bashrc \
    && rm -rf aws/ awscliv2.zip \
    && wget --progress=dot:mega https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 \
    -O ${BIN_DIR}/hadolint \
    && chmod 755 ${BIN_DIR}/hadolint \
    && wget --progress=dot:mega https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && tar xvf shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && cp shellcheck-v${SHELLCHECK_VERSION}/shellcheck ${BIN_DIR}/ \
    && chmod 755 ${BIN_DIR}/shellcheck \
    && rm -rf shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz shellcheck-v${SHELLCHECK_VERSION} \
    && wget --progress=dot:mega https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -O /etc/bash_completion.d/docker \
    && chmod 755 /etc/bash_completion.d/docker

# Install terraform tools
 RUN wget --progress=dot:mega https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
    && wget --progress=dot:mega https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS \
    && sed -n "/terraform_${TF_VERSION}_linux_amd64.zip/p" terraform_${TF_VERSION}_SHA256SUMS | sha256sum -c \
    && unzip terraform_${TF_VERSION}_linux_amd64.zip \
    && mv terraform ${BIN_DIR}/terraform \
    && echo "complete -C /usr/local/bin/terraform terraform" >> ~/.bashrc \
    && rm -rf terraform_${TF_VERSION}_linux_amd64.zip terraform_${TF_VERSION}_SHA256SUMS \
    && wget --progress=dot:mega https://github.com/gruntwork-io/terragrunt/releases/download/v${TFGRUNT_VERSION}/terragrunt_linux_amd64 \
    && wget --progress=dot:mega https://github.com/gruntwork-io/terragrunt/releases/download/v${TFGRUNT_VERSION}/SHA256SUMS \
    && sed -n "/terragrunt_linux_amd64/p" SHA256SUMS | sha256sum -c \
    && chmod +x terragrunt_linux_amd64 \
    && mv terragrunt_linux_amd64 ${BIN_DIR}/terragrunt \
    && rm -rf SHA256SUMS \
    && wget --progress=dot:mega https://github.com/terraform-docs/terraform-docs/releases/download/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz \
    && wget --progress=dot:mega https://github.com/terraform-docs/terraform-docs/releases/download/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}.sha256sum \
    && sed -n "/terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz/p" terraform-docs-v${TFDOCS_VERSION}.sha256sum | sha256sum -c \
    && tar xvf terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz \
    && mv terraform-docs ${BIN_DIR}/ \
    && chmod 755 ${BIN_DIR}/terraform-docs \
    && rm -rf terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz README.md LICENSE terraform-docs-v${TFDOCS_VERSION}.sha256sum \
    && wget --progress=dot:mega -O - https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash \
    && wget --progress=dot:mega https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_linux_amd64.tar.gz \
    && wget --progress=dot:mega https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_checksums.txt \
    && sed -n "/tfsec_${TFSEC_VERSION}_linux_amd64.tar.gz/p" tfsec_${TFSEC_VERSION}_checksums.txt | sha256sum -c \
    && tar xvf tfsec_${TFSEC_VERSION}_linux_amd64.tar.gz \
    && mv tfsec tfsec-checkgen ${BIN_DIR}/ \
    && chmod 755 ${BIN_DIR}/tfsec ${BIN_DIR}/tfsec-checkgen \
    && rm -rf LICENSE README.md tfsec_${TFSEC_VERSION}_checksums.txt tfsec_${TFSEC_VERSION}_linux_amd64.tar.gz \
    && wget --progress=dot:mega -O - https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash \
    && wget --progress=dot:mega https://github.com/accurics/terrascan/releases/download/v${TSCAN_VERSION}/terrascan_${TSCAN_VERSION}_Linux_x86_64.tar.gz \
    && wget --progress=dot:mega https://github.com/accurics/terrascan/releases/download/v${TSCAN_VERSION}/checksums.txt \
    && sed -n "/terrascan_${TSCAN_VERSION}_Linux_x86_64.tar.gz/p" checksums.txt | sha256sum -c \
    && tar xvf terrascan_${TSCAN_VERSION}_Linux_x86_64.tar.gz \
    && mv terrascan ${BIN_DIR}/ \
    && chmod 755 ${BIN_DIR}/terrascan \
    && rm -rf CHANGELOG.md LICENSE README.md checksums.txt terrascan_${TSCAN_VERSION}_Linux_x86_64.tar.gz 

# Install Go Language
RUN wget --progress=dot:mega https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar xvf go${GO_VERSION}.linux-amd64.tar.gz  -C /opt/ \
    && ln -s /opt/go/bin/go ${BIN_DIR}/go \
    && ln -s /opt/go/bin/gofmt ${BIN_DIR}/gofmt 

# Change to dev user
USER ${DOCKER_USER}
# @TODO: change /workspaces for WORKDIR env var
ENTRYPOINT [ "/workspaces/entrypoint.sh" ]
CMD [ "sleep", "infinity" ]
