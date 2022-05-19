FROM rust:1.60.0 AS builder
WORKDIR /usr/src


RUN USER=root cargo new githook
WORKDIR /usr/src/githook
COPY Cargo.lock Cargo.toml ./
RUN cargo build --release


COPY ./src ./src
RUN cargo build --release


FROM debian:stretch-slim

COPY --from=builder /usr/src/githook/target/release/githook /app
RUN mkdir /app/updates
EXPOSE 8000
USER 1000

CMD [ "/app/githook" ]