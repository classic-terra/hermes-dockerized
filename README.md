# Hermes. Dockerized.

This is a Dockerfile and compose file to spin a [Hermes Relay](https://github.com/informalsystems/hermes) for two Terra based testchains.

## Build Instructions

Assume you have two files `a_mnemonic` and `b_mnemonic` containing the clear text passphrase of the relaying accounts for the both testchains. You should then be able to follow these setup steps:

- Place the files `a_mnemonic` and `b_mnemonic` inside the `init` folder.
- Provide the docker compose environment with various RPC, GRPC and WEBSOCKET URLs of the involved chains (see compose file)
- `docker-compose up -d`
