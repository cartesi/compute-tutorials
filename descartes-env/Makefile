.PHONY: clean deploy

TAG := 0.2.0

deploy:
	docker-compose -f deployer.yml up --build

release:
	cd .. && tar -czvf descartes-env-${TAG}.tar.gz ./descartes-env

clean:
	rm -rf machines/*
	rm -rf ganache_data/*
	rm -rf blockchain/*
