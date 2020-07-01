.PHONY: clean deploy

TAG := 0.1.1

deploy:
	docker-compose -f deployer.yml up --build

release:
	tar -czvf descartes-env-${TAG}.tar.gz --cd .. ./descartes-env

clean:
	rm -rf machines/*
	rm -rf ganache_data/*
	rm -rf blockchain/*
