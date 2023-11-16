VERSION=1.0.0

DOCKERIMAGENAME := revhelix/mailhog
DOCKERIMAGEVERSION := 1.0.0

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
	@echo "Building multiarch $(DOCKERIMAGENAME):$(DOCKERIMAGEVERSION)"
	@docker buildx rm --force mailhogbuilder | true
	@docker buildx create --name mailhogbuilder --bootstrap --use
	@docker buildx build --progress auto --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6,linux/ppc64le,linux/s390x -t $(DOCKERIMAGENAME):$(DOCKERIMAGEVERSION) --push .
	# This second build command will used cached materials and tag the current build as latest.
	@docker buildx build --progress auto --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6,linux/ppc64le,linux/s390x -t $(DOCKERIMAGENAME):latest --push .
	@docker buildx rm --force mailhogbuilder
	@echo "Built $(DOCKERIMAGENAME):$(DOCKERIMAGEVERSION)"

.PHONY: all combined release fmt release-deps pull tag
