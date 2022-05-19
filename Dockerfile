FROM rust:1.60.0 AS builder
WORKDIR /usr/src/app

RUN rustup target add x86_64-unknown-linux-gnu
COPY Cargo.lock Cargo.toml ./
RUN cargo build --release

COPY ./src ./src

RUN cargo build --release

FROM debian:buster-slim

COPY --from=builder /usr/src/app/target/release/githook /app/githook
RUN mkdir /app/githook/updates
EXPOSE 8000