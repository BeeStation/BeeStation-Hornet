FROM beestation/byond:513.1526 as base
ONBUILD ENV BYOND_MAJOR=513
ONBUILD ENV BYOND_MINOR=1526

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
    && git remote add origin https://github.com/tgstation/rust-g

COPY dependencies.sh .

RUN dos2unix dependencies.sh \
	&& /bin/bash -c "source dependencies.sh \
    && git fetch --depth 1 origin \$RUST_G_VERSION" \
    && git checkout FETCH_HEAD \
    && ~/.cargo/bin/cargo build --release \
	&& apt-get --purge remove -y dos2unix

FROM build_base as bsql

WORKDIR /bsql

RUN apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    cmake \
    make \
    g++-7 \
    libmariadb-client-lgpl-dev \
	dos2unix \
    && git init \
    && git remote add origin https://github.com/tgstation/BSQL

COPY dependencies.sh .

RUN dos2unix dependencies.sh \
	&& /bin/bash -c "source dependencies.sh \
    && git fetch --depth 1 origin \$BSQL_VERSION" \
    && git checkout FETCH_HEAD

WORKDIR /bsql/artifacts

ENV CC=gcc-7 CXX=g++-7

RUN ln -s /usr/include/mariadb /usr/include/mysql \
    && ln -s /usr/lib/i386-linux-gnu /root/MariaDB \
    && cmake .. \
    && make

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
    libmariadb3 \
    mariadb-client \
    libssl1.0.0 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/.byond/bin

COPY --from=rust_g /rust_g/target/release/librust_g.so /root/.byond/bin/rust_g
COPY --from=bsql /bsql/artifacts/src/BSQL/libBSQL.so ./
COPY --from=build /deploy ./

#bsql fexists memes
RUN ln -s /beestation/libBSQL.so /root/.byond/bin/libBSQL.so \
    && ln -s /beestation/libbyond-extools.so /root/.byond/bin/libbyond-extools.so

VOLUME [ "/beestation/config", "/beestation/data" ]

ENTRYPOINT [ "DreamDaemon", "beestation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]
