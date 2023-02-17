#!/bin/bash

function fill_template() {
	FILE=$1
	KEY=$2
	VALUE=$3
	sed -i "s|^$KEY =|$KEY = '$VALUE'|g" $FILE
}

set -e

if [ -f /home/hermes/init/a_mnemonic ] && [ -f /home/hermes/init/b_mnemonic ]; then
	
	echo "is uninitialized"
	
	rm -Rf /home/hermes/.hermes/*
	cp /home/hermes/init/config.toml /home/hermes/.hermes
	touch /home/hermes/.hermes/chain_a.toml
	touch /home/hermes/.hermes/chain_b.toml
	
	#setup chain A
	cp /home/hermes/init/chain_template /home/hermes/.hermes/chain_a.toml
	fill_template /home/hermes/.hermes/chain_a.toml id ${CHAIN_ID_A}
	fill_template /home/hermes/.hermes/chain_a.toml grpc_addr "${GRPC_ADDR_A}"
	fill_template /home/hermes/.hermes/chain_a.toml rpc_addr "${RPC_ADDR_A}"
	fill_template /home/hermes/.hermes/chain_a.toml websocket_addr "${WEBSOCK_ADDR_A}"
	fill_template /home/hermes/.hermes/chain_a.toml key_name "key_a"
	fill_template /home/hermes/.hermes/chain_a.toml account_prefix "${PREFIX_A}"
	
	#setup chain B
	cp /home/hermes/init/chain_template /home/hermes/.hermes/chain_b.toml
	fill_template /home/hermes/.hermes/chain_b.toml id ${CHAIN_ID_B}
	fill_template /home/hermes/.hermes/chain_b.toml grpc_addr "${GRPC_ADDR_B}"
	fill_template /home/hermes/.hermes/chain_b.toml rpc_addr "${RPC_ADDR_B}"
	fill_template /home/hermes/.hermes/chain_b.toml websocket_addr "${WEBSOCK_ADDR_B}"
	fill_template /home/hermes/.hermes/chain_b.toml key_name "key_b"
	fill_template /home/hermes/.hermes/chain_b.toml account_prefix "${PREFIX_B}"

	cat /home/hermes/.hermes/chain_a.toml >> /home/hermes/.hermes/config.toml
	cat /home/hermes/.hermes/chain_b.toml >> /home/hermes/.hermes/config.toml
	
	hermes keys add --chain ${CHAIN_ID_A} --mnemonic-file /home/hermes/init/a_mnemonic --hd-path "m/44'/"$COINTYPE_A"'/0'/0/0"
	hermes keys add --chain ${CHAIN_ID_B} --mnemonic-file /home/hermes/init/b_mnemonic --hd-path "m/44'/"$COINTYPE_B"'/0'/0/0"
	
	hermes health-check
	RES=$?
	if [ ${RES} -ne 0 ]; then
		echo "configuration seems to be malformed"
		exit -1
	fi
	
	# shred the user provided keys
	shred -n 100 -u /home/hermes/init/a_mnemonic
	shred -n 100 -u /home/hermes/init/b_mnemonic
	
fi

hermes start
