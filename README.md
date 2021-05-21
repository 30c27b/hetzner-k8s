# Hetzner Kubernetes provisioning
Provision a Kubernetes cluster using Hetzner's cloud api.

## About

This script will:
- Generate a new ssh keypair
- Upload the public key to your project
- Create an internal network at 10.8.0.0/16
- Provision 1 master node (cpx11) and 2 worker nodes (cx21)

## Usage

- Create a project from the [Hetzner cloud console](https://console.hetzner.cloud).

- Inside your newly created project, go to `Security > API tokens` and generate an api token with the `Read & Write` permissions.

- Install [hcloud](https://github.com/hetznercloud/cli).

- Generate a context:
```bash
$ hcloud context create [name]
Token: [Paste your api token]
```

- Run the script to generate the cluster:
```bash
$ sh ./hetzner-provisioning.sh
```

- The ssh keypair to access your nodes is now available at `build/[name]-ssh` and `build/[name]-ssh.pub`.
