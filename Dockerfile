# Stage 1 - generate recipe for dependencies
FROM rust:1.60.0 AS planner
WORKDIR /app
RUN cargo install cargo-chef
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# Stage 2 - build dependencies
FROM rust:1.60.0 AS cacher
WORKDIR /app
RUN cargo install cargo-chef
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# Stage 3 - build app
FROM rust:1.60.0 AS builder
WORKDIR /app
COPY . .

COPY --from=cacher /app/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo 

#build the app
RUN cargo build --release


FROM debian:10.12

COPY --from=builder /app/target/release/githook /app/githook
RUN mkdir /app/updates
USER 1000

CMD [ "/app/githook" ]