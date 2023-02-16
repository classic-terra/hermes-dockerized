#!/bin/bash

function fill_template() {
	FILE=$1
	KEY=$2
	VALUE=$3
	sed -i "s|^$KEY =|$KEY = '$VALUE'|g" $FILE
}

set -e

if [ -f /hermes/init/a_mnemonic ] && [ -f /hermes/init/b_mnemonic ]; then
	
	echo "is uninitialized"
	
	rm -Rf /hermes/.hermes/*
	cp /hermes/init/config.toml /hermes/.hermes
	touch /hermes/.hermes/chain_a.toml
	touch /hermes/.hermes/chain_b.toml
	
	#setup chain A
	cp /hermes/init/chain_template /hermes/.hermes/chain_a.toml
	fill_template /hermes/.hermes/chain_a.toml id ${CHAIN_ID_A}
	fill_template /hermes/.hermes/chain_a.toml grpc_addr "${GRPC_ADDR_A}:${GRPC_PORT_A}"
	fill_template /hermes/.hermes/chain_a.toml rpc_addr "${RPC_ADDR_A}:${RPC_PORT_A}"
	fill_template /hermes/.hermes/chain_a.toml websocket_addr "${WEBSOCK_ADDR_A}:${WEBSOCK_PORT_A}"
	fill_template /hermes/.hermes/chain_a.toml key_name "key_a"
	
	#setup chain B
	cp /hermes/init/chain_template /hermes/.hermes/chain_b.toml
	fill_template /hermes/.hermes/chain_b.toml id ${CHAIN_ID_B}
	fill_template /hermes/.hermes/chain_b.toml grpc_addr "${GRPC_ADDR_B}:${GRPC_PORT_B}"
	fill_template /hermes/.hermes/chain_b.toml rpc_addr "${RPC_ADDR_B}:${RPC_PORT_B}"
	fill_template /hermes/.hermes/chain_b.toml websocket_addr "${WEBSOCK_ADDR_B}:${WEBSOCK_PORT_B}"
	fill_template /hermes/.hermes/chain_b.toml key_name "key_b"
	
	cat /hermes/.hermes/chain_a.toml >> /hermes/.hermes/config.toml
	cat /hermes/.hermes/chain_b.toml >> /hermes/.hermes/config.toml
	
	hermes --config /hermes/.hermes/config.toml keys add --chain ${CHAIN_ID_A} --mnemonic-file /hermes/init/a_mnemonic --hd-path "m/44'/330'/0'/0/0"
	hermes --config /hermes/.hermes/config.toml keys add --chain ${CHAIN_ID_B} --mnemonic-file /hermes/init/b_mnemonic --hd-path "m/44'/330'/0'/0/0"
	
	RES=$(hermes health-check)
	if [ ${RES} -ne 0 ]; then
		echo "configuration seems to be malformed"
		exit -1
	fi
	
	# shred the user provided keys
	shred -n 100 -u /hermes/init/a_mnemonic
	shred -n 100 -u /hermes/init/b_mnemonic
	
fi

hermes start
