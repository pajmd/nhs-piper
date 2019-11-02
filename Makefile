#
# This Makefile build the nhs-piper image, tags it and pushes it to local docker repos
#
# make
#
NAME   := pjmd-ubuntu.com/nhs_piper
TAG    := $$(git describe --tag)
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

build:
	@docker build -t ${IMG} --build-arg GIT_VERSION=${TAG} .
	@docker tag ${IMG} ${LATEST}

push:
	@docker push ${IMG}

# login:
#   @docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}
