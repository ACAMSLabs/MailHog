VERSION=1.0.0

DOCKERIMAGENAME := revhelix/mailhog:latest
DOCKERREPO := localhost:8082/$(DOCKERIMAGENAME)

all: fmt combined

combined:
	go install .

release: tag release-deps 
	gox -ldflags "-X main.version=${VERSION}" -output="build/{{.Dir}}_{{.OS}}_{{.Arch}}" .

fmt:
	go fmt ./...

release-deps:
	go get github.com/mitchellh/gox

pull:
	git pull
	cd ../data; git pull
	cd ../http; git pull
	cd ../MailHog-Server; git pull
	cd ../MailHog-UI; git pull
	cd ../smtp; git pull
	cd ../storage; git pull

tag:
	git tag -a -m 'v${VERSION}' v${VERSION} && git push origin v${VERSION}
	cd ../data; git tag -a -m 'v${VERSION}' v${VERSION} && git push origin v${VERSION}
	cd ../http; git tag -a -m 'v${VERSION}' v${VERSION} && git push origin v${VERSION}
	cd ../MailHog-Server; git tag -a -m 'v${VERSION}' v${VERSION} && git push origin v${VERSION}
	cd ../MailHog-UI; git tag -a -m 'v${VERSION}' v${VERSION} && git push origin v${VERSION}
	cd ../smtp; git tag -a -m 'v${VERSION}' v${VERSION} && git push origin v${VERSION}
	cd ../storage; git tag -a -m 'v${VERSION}' v${VERSION} && git push origin v${VERSION}

docker:
	@echo "Building multiarch $(DOCKERIMAGENAME)"
	@docker build --tag $(DOCKERREPO)-amd64 --build-arg ARCH=amd64 .
	@docker image tag $(DOCKERREPO)-amd64 $(DOCKERIMAGENAME)-amd64
	@docker push $(DOCKERREPO)-amd64
	@docker push $(DOCKERIMAGENAME)-amd64

	@docker build --tag $(DOCKERREPO)-i386 --build-arg ARCH=i386 .
	@docker image tag $(DOCKERREPO)-i386 $(DOCKERIMAGENAME)-i386
	@docker push $(DOCKERREPO)-i386
	@docker push $(DOCKERIMAGENAME)-i386

	@docker build --tag $(DOCKERREPO)-arm64v8 --build-arg ARCH=arm64v8 .
	@docker image tag $(DOCKERREPO)-arm64v8 $(DOCKERIMAGENAME)-arm64v8
	@docker push $(DOCKERREPO)-arm64v8
	@docker push $(DOCKERIMAGENAME)-arm64v8

	@docker build --tag $(DOCKERREPO)-arm32v7 --build-arg ARCH=arm32v7 .
	@docker image tag $(DOCKERREPO)-arm32v7 $(DOCKERIMAGENAME)-arm32v7
	@docker push $(DOCKERREPO)-arm32v7
	@docker push $(DOCKERIMAGENAME)-arm32v7

	@docker build --tag $(DOCKERREPO)-arm32v6 --build-arg ARCH=arm32v6 .
	@docker image tag $(DOCKERREPO)-arm32v6 $(DOCKERIMAGENAME)-arm32v6
	@docker push $(DOCKERREPO)-arm32v6
	@docker push $(DOCKERIMAGENAME)-arm32v6

	@docker build --tag $(DOCKERREPO)-ppc64le --build-arg ARCH=ppc64le .
	@docker image tag $(DOCKERREPO)-ppc64le $(DOCKERIMAGENAME)-ppc64le
	@docker push $(DOCKERREPO)-ppc64le
	@docker push $(DOCKERIMAGENAME)-ppc64le

	@docker build --tag $(DOCKERREPO)-s390x --build-arg ARCH=s390x .
	@docker image tag $(DOCKERREPO)-s390x $(DOCKERIMAGENAME)-s390x
	@docker push $(DOCKERREPO)-s390x
	@docker push $(DOCKERIMAGENAME)-s390x

	@docker manifest create $(DOCKERREPO) --amend $(DOCKERREPO)-amd64 --amend $(DOCKERREPO)-arm64v8 --amend $(DOCKERREPO)-arm32v7 --amend $(DOCKERREPO)-i386 --amend $(DOCKERREPO)-arm32v6 --amend $(DOCKERREPO)-ppc64le --amend $(DOCKERREPO)-s390x --insecure
	@docker manifest create $(DOCKERIMAGENAME) --amend $(DOCKERIMAGENAME)-amd64 --amend $(DOCKERIMAGENAME)-arm64v8 --amend $(DOCKERIMAGENAME)-arm32v7 --amend $(DOCKERIMAGENAME)-i386 --amend $(DOCKERIMAGENAME)-arm32v6 --amend $(DOCKERIMAGENAME)-ppc64le --amend $(DOCKERIMAGENAME)-s390x --insecure
	@docker manifest push $(DOCKERREPO)
	@docker manifest push $(DOCKERIMAGENAME)
	@echo "Built $(DOCKERIMAGENAME)"

.PHONY: all combined release fmt release-deps pull tag
