##
## POSTGRES
##
DISTRO:=jessie
PG_MAJOR:=9
PG_MINOR:=3
PG_DATA:=/var/lib/postgresql/$(PG_MAJOR).$(PG_MINOR)/main
PG_HOME:=/var/lib/postgresql
PG_PORT:=5432
SECRETS:=/run/secrets
DOCKER_TAG:=tekii/postgres:$(PG_MAJOR).$(PG_MINOR)


##
## M4
##
M4= $(shell which m4)
M4_FLAGS= -P \
	-D __DISTRO__=$(DISTRO) \
	-D __PG_MAJOR__=$(PG_MAJOR) \
	-D __PG_MINOR__=$(PG_MINOR) \
	-D __PG_DATA__=$(PG_DATA) \
	-D __PG_HOME__=$(PG_HOME) \
	-D __PG_PORT__=$(PG_PORT) \
	-D __SECRETS__=$(SECRETS) \
	-D __DOCKER_TAG__=$(DOCKER_TAG)

#.SECONDARY
Dockerfile: Dockerfile.m4 Makefile
	$(M4) $(M4_FLAGS) $< >$@


PHONY += update-patch
update-patch:
	diff -ruN original/ $(POSTGRES_ROOT)/  > config.patch; [ $$? -eq 1 ]

PHONY += image
image: Dockerfile #$(POSTGRES_ROOT)
	docker build --no-cache=false --rm=true --tag=$(DOCKER_TAG) .

PHONY+= run
run: #image
	docker run --rm -it -p $(PG_PORT):$(PG_PORT) -v $(shell pwd)/volume:$(PG_HOME) -v $(shell pwd)/secrets:$(SECRETS) $(DOCKER_TAG) /bin/bash

PHONY+= push-to-docker
push-to-docker: image
	docker push $(DOCKER_TAG)

PHONY += push-to-google
push-to-google: image
	docker tag $(DOCKER_TAG) gcr.io/mrg-teky/postgres:$(PG_MAJOR).$(PG_MINOR)
	gcloud docker push gcr.io/mrg-teky/postgres:$(PG_MAJOR).$(PG_MINOR)

PHONY += git-tag git-push
git-tag:
	-git tag -d $(PG_MAJOR).$(PG_MINOR)
	git tag $(PG_MAJOR).$(PG_MINOR)

git-push:
	-git push origin :refs/tags/$(PG_MAJOR).$(PG_MINOR)
	git push origin
	git push --tags origin

PHONY += clean
clean:
	rm -f Dokerfile

PHONY += realclean
realclean: clean

PHONY += all
all: image

.PHONY: $(PHONY)
.DEFAULT_GOAL := all
