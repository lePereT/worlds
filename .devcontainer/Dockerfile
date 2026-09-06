FROM alpine:3.24

# Worlds development is deliberately small and Lua-shaped. LuaJIT is built
# from a pinned upstream 2.1 snapshot rather than taking a distribution fork.
ARG LUAJIT_COMMIT=1ee778a4e37122d8ca7d5733c590a47dafd6b15c
ARG LUAJIT_SHA256=512cdb23dafa39c6247763ae15f29341734b1596067b067db0c0387bbebc7c55

RUN apk add --no-cache \
        build-base \
        ca-certificates \
        git \
        lua5.4 \
        zsh \
    && update-ca-certificates \
    && mkdir -p /tmp/luajit \
    && wget -q -O /tmp/luajit.tar.gz \
        "https://github.com/LuaJIT/LuaJIT/archive/${LUAJIT_COMMIT}.tar.gz" \
    && echo "${LUAJIT_SHA256}  /tmp/luajit.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/luajit.tar.gz -C /tmp/luajit --strip-components=1 \
    && make -C /tmp/luajit -j"$(getconf _NPROCESSORS_ONLN)" \
    && make -C /tmp/luajit install PREFIX=/usr/local \
    && rm -rf /tmp/luajit /tmp/luajit.tar.gz \
    && addgroup -S worlds \
    && adduser -S -G worlds -h /home/worlds -s /bin/zsh worlds \
    && mkdir -p /home/worlds/.cache/zsh \
    && chown -R worlds:worlds /home/worlds

COPY zshrc /home/worlds/.zshrc
RUN chown worlds:worlds /home/worlds/.zshrc
