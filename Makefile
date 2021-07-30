all: check

check:
	./scripts/test

docker:
	docker build -t alphahydrae/scide-tests . && docker run --rm alphahydrae/scide-tests
