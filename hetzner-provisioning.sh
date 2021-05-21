#!/bin/bash

# This script orders the ressources required to launch the cluster on a
# Hetzner account using the hcloud cli.

# config
DATACENTER="nbg1"

# colors
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

# check if hcloud is installed
if ! [ -x "$(command -v hcloud)" ]; then
	echo 'Error: hcloud is not installed.' >&2
	exit 1
fi

hcloud_context=$(hcloud context active)

# check if there is an active context
if [[ -z $hcloud_context ]]; then
	echo "Error: no active hcloud context." >&2
	exit 1
fi

# ask user to confirm the use of active context
echo "🚨 You are about to provision a Hetzner project with the context \"$hcloud_context\", this will cost money."
echo ""
read -p "❓ Are you sure (y/n)? " -n 1 -r
echo "\n"
if [[ ! ($REPLY =~ ^[Yy]$) ]]
then
	echo "⛔️ Aborting."
	exit 1
fi

hcloud_ssh="$hcloud_context-ssh"
hcloud_net="$hcloud_context-net"

# create directory for ssh keys
mkdir -p build

# generate ssh-key
echo "🔐 Generating ssh key pair at \"build/ssh-$hcloud_context\"."
echo "${GREEN}"
ssh-keygen -t ed25519 -C "$hcloud_ssh" -f "build/$hcloud_ssh" -N ""
echo "${NOCOLOR}\n"

# add ssh-key to hcloud project
echo "🔒 Uploading the public key to hcloud."
echo "${GREEN}"
hcloud ssh-key create --name "$hcloud_ssh" --public-key-from-file "build/$hcloud_ssh.pub"
echo "${NOCOLOR}\n"

# create network and subnet for cluster
echo "🌐 Creating an internal network for the cluster."
echo "${GREEN}"
hcloud network create --name "$hcloud_net" --ip-range 10.8.0.0/16
hcloud network add-subnet "$hcloud_net" --network-zone eu-central --type server --ip-range 10.8.0.0/24
echo "${NOCOLOR}\n"


# create master node
echo "🎛  Creating the master node."
echo "${GREEN}"
hcloud server create --type cpx11 --name master-0 --image ubuntu-18.04 --ssh-key "$hcloud_ssh" --network "$hcloud_net" --location "$DATACENTER"
echo "${NOCOLOR}\n"

# create worker nodes
echo "🛠 Creating the 2 worker nodes."
hcloud server create --type cx21 --name worker-0 --image ubuntu-18.04 --ssh-key "$hcloud_ssh" --network "$hcloud_net" --location "$DATACENTER"
hcloud server create --type cx21 --name worker-1 --image ubuntu-18.04 --ssh-key "$hcloud_ssh" --network "$hcloud_net" --location "$DATACENTER"
echo "${NOCOLOR}\n"

echo "✅ All done!"
