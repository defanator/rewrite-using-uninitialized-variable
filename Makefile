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
	curl -fsSi http://127.0.0.1:8080/api/nginx/one/namespaces/foo/data-plane-keys/a/b/c/
	curl -fsSi http://127.0.0.1:8080/api/v1/a/b/c/
	docker logs $(NGINX) 2>&1 | awk 'BEGIN {rc=0}; /using uninitialized/ {print; rc=1; next}; END {exit rc}'

clean:
	docker compose -f compose.yml down

.PHONY: env trigger clean
