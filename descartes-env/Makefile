.PHONY: clean deploy

TAG := 0.2.0

deploy:
	docker-compose -f deployer.yml up --build
	
deploy-arm:
	docker-compose -f deployer.yml up --build -e ARCH=ARM

release:
	cd .. && tar -czvf descartes-env-${TAG}.tar.gz ./descartes-env

clean:
	find ganache_data/ ! -path ganache_data/ ! -path ganache_data/.\* -name '*' -delete
	rm -rf machines/*
	rm -rf blockchain/*
	docker-compose down -v
