.PHONY: clean deploy

TAG := 0.2.0

deploy:
	docker-compose -f deployer.yml up --build

release:
	cd .. && tar -czvf descartes-env-${TAG}.tar.gz ./descartes-env

clean:
	find ganache_data/ ! -path ganache_data/ ! -path ganache_data/.\* -name '*' -delete
	rm -rf blockchain/*
	docker-compose down -v

clean-all: clean
	rm -rf machines/*
