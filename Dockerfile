FROM beestation/byond:513.1536 as base
ONBUILD ENV BYOND_MAJOR=513
ONBUILD ENV BYOND_MINOR=1536

FROM base as build_base

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git \
	dos2unix\
    ca-certificates

FROM build_base as rust_g

WORKDIR /rust_g

RUN apt-get install -y --no-install-recommends \
    libssl-dev \
    pkg-config \
    curl \
    gcc-multilib \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu \
    && git init \
    && git remote add origin https://github.com/BeeStation/rust-g

COPY dependencies.sh .

RUN dos2unix dependencies.sh \
	&& /bin/bash -c "source dependencies.sh \
    && git fetch --depth 1 origin \$RUST_G_VERSION" \
    && git checkout FETCH_HEAD \
    && ~/.cargo/bin/cargo build --release --all-features \
	&& apt-get --purge remove -y dos2unix

FROM base as dm_base

WORKDIR /beestation

FROM dm_base as build

COPY . .

RUN apt-get update \
    && apt-get install -y --no-install-recommends dos2unix \
    && rm -rf /var/lib/apt/lists/* \
    && DreamMaker -max_errors 0 beestation.dme && dos2unix tools/deploy.sh && tools/deploy.sh /deploy

FROM dm_base

EXPOSE 1337

RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
    mariadb-client \
    libssl1.0.0 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/.byond/bin

COPY --from=rust_g /rust_g/target/release/librust_g.so /root/.byond/bin/rust_g
COPY --from=build /deploy ./

#extools fexists memes
RUN ln -s /beestation/libbyond-extools.so /root/.byond/bin/libbyond-extools.so

VOLUME [ "/beestation/config", "/beestation/data" ]

ENTRYPOINT [ "DreamDaemon", "beestation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]
