FROM docker.io/nginx:latest as nginx

ARG NGINX_PLUS_VERSION

RUN --mount=type=secret,id=nginx-crt,dst=/run/secrets/nginx-crt \
    --mount=type=secret,id=nginx-key,dst=/run/secrets/nginx-key \
    set -x \
    && . /etc/os-release \
    && apt-get remove -y --purge nginx \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg2 \
    && curl -fs https://cs.nginx.com/static/keys/nginx_signing.key | /usr/bin/gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null \
    && printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/debian ${VERSION_CODENAME} nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list \
    && curl -fs -o /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx \
    && mkdir -p /etc/ssl/nginx \
    && cat /run/secrets/nginx-crt >/etc/ssl/nginx/nginx-repo.crt \
    && cat /run/secrets/nginx-key >/etc/ssl/nginx/nginx-repo.key \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y nginx-plus=${NGINX_PLUS_VERSION}-1~${VERSION_CODENAME} \
    && rm -rf /etc/ssl/nginx \
    && rm -f /etc/apt/apt.conf.d/90pkgs-nginx /etc/apt/sources.list.d/nginx-plus.list \
    && dpkg -P gnupg2 \
    && apt-get autoremove -y --purge \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
