FROM rust:1.60.0 AS builder
WORKDIR /usr/src

# Ajout de musl pour une image light
RUN rustup target add x86_64-unknown-linux-musl

RUN USER=root cargo new githook
WORKDIR /usr/src/githook
COPY Cargo.lock Cargo.toml ./
RUN cargo build --release


COPY ./src ./src
RUN cargo install --target x86_64-unknown-linux-musl --path .
RUN mkdir updates


FROM scratch

COPY --from=builder /usr/local/cargo/bin/githook .
COPY --from=builder /usr/src/githook/updates .
EXPOSE 8000
USER 1000

CMD [ "/githook" ]