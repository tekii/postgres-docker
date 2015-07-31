##
## REFINE
##
PG_MAJOR:=9
PG_MINOR:=1
PG_DATA:=/var/lib/postgresql/$(PG_MAJOR).$(PG_MINOR)
PG_HOME:=/var/lib/postgresql
PG_PORT:=5432
DOCKER_TAG:=tekii/postgres:$(PG_MAJOR).$(PG_MINOR)

##
## M4
##
M4= $(shell which m4)
M4_FLAGS= -P \
	-D __PG_MAJOR__=$(PG_MAJOR) \
	-D __PG_MINOR__=$(PG_MINOR) \
	-D __PG_DATA__=$(PG_DATA) \
	-D __PG_HOME__=$(PG_HOME) \
	-D __PG_PORT__=$(PG_PORT) \
	-D __DOCKER_TAG__=$(DOCKER_TAG)

#.SECONDARY
Dockerfile: Dockerfile.m4 Makefile
	$(M4) $(M4_FLAGS) $< >$@


PHONY += update-patch
update-patch:
	diff -ruN original/ $(POSTGRES_ROOT)/  > config.patch; [ $$? -eq 1 ]

PHONY += image
image: Dockerfile #$(POSTGRES_ROOT)
	docker build -t $(DOCKER_TAG) .

PHONY+= run
run: #image
	docker run -it -p $(PG_PORT):$(PG_PORT) -v $(shell pwd)/volume:$(PG_HOME) $(DOCKER_TAG) /bin/bash

PHONY+= push-to-docker
push-to-docker: image
	docker push $(DOCKER_TAG)

PHONY += push-to-google
push-to-google: image
	docker tag $(DOCKER_TAG) gcr.io/test-teky/postgres:$(PG_MAJOR).$(PG_MINOR)
	gcloud docker push gcr.io/test-teky/postgres:$(PG_MAJOR).$(PG_MINOR)

PHONY += clean
clean:
	rm -f Dokerfile	

PHONY += realclean
realclean: clean

PHONY += all
all: image

.PHONY: $(PHONY)
.DEFAULT_GOAL := all
