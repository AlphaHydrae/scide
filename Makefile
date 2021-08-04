all: check

check:
	./scripts/test

check-watch:
	./scripts/test --watch

check-docker: docker
	docker run -it --rm alphahydrae/scide-tests

check-docker-watch: docker
	docker run -it --rm --volume "$$PWD/bin:/code/bin:ro" --volume "$$PWD/tests:/code/tests:ro" alphahydrae/scide-tests check-watch

docker:
	docker build --quiet -t alphahydrae/scide-tests .
