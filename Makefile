#!/usr/bin/make -f

# could be nginx or nginx-plus
NGINX ?= nginx

default:
	@echo "try make trigger"

build:
	docker compose -f compose.yml build

env:
	docker compose -f compose.yml up -d $(NGINX)

trigger: env
	curl -i http://127.0.0.1:8080/api/nginx/one/namespaces/foo/data-plane-keys/a/b/c/
	curl -i http://127.0.0.1:8080/api/v1/a/b/c/
	docker logs $(NGINX) 2>&1 | fgrep -- 'using uninitialized'

clean:
	docker compose -f compose.yml down

.PHONY: env trigger clean
