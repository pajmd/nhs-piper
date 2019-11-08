#
# This Makefile build the nhs-piper image, tags it and pushes it to local docker repos
#
# make
#
APP    := nhs_piper
PUBLIC_REPO := pajmd
NAME   := pjmd-ubuntu.com/${APP}
TAG    := $$(git describe --tag)
IMG    := ${NAME}:${TAG}
PUBLIC_IMG := ${PUBLIC_REPO}/${APP}:${TAG}
LATEST := ${NAME}:latest

build:
	@docker build -t ${IMG} --build-arg GIT_VERSION=${TAG} .
	@docker tag ${IMG} ${LATEST}
	@docker tag ${IMG} ${PUBLIC_IMG}

push:
	@docker push ${IMG}

# login:
#   @docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}
