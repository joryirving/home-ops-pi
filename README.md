## Overview

This is a test repository is for my home kubernetes clusters.

Please see my home-prod repo at [home-ops](https://github.com/joryirving/home-ops)

I try to adhere to Infrastructure as Code (IaC) and GitOps practices using tools like [Terraform](https://www.terraform.io/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate), and [GitHub Actions](https://github.com/features/actions).

The purpose here is to learn k8s, while practicing Gitops.

---

## ⛵ Kubernetes

My Kubernetes clusters are deployed with [Talos](https://www.talos.dev). One is a low-power utility cluster, running important services, and the other is a semi-hyper-converged cluster, workloads and block storage are sharing the same available resources on my nodes while I have a separate NAS with ZFS for NFS/SMB shares, bulk file storage and backups.

### Core Components

- [actions-runner-controller](https://github.com/actions/actions-runner-controller): self-hosted Github runners
- [cilium](https://github.com/cilium/cilium): internal Kubernetes networking plugin
- [cert-manager](https://cert-manager.io/docs/): creates SSL certificates for services in my cluster
- [external-dns](https://github.com/kubernetes-sigs/external-dns): automatically syncs DNS records from my cluster ingresses to a DNS provider
- [external-secrets](https://github.com/external-secrets/external-secrets/): managed Kubernetes secrets using [1Password](https://1password.com/).
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/): ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer
- [rook-ceph](https://rook.io/): Cloud native distributed block storage for Kubernetes
- [sops](https://toolkit.fluxcd.io/guides/mozilla-sops/): managed secrets for Talos, which are committed to Git
- [volsync](https://github.com/backube/volsync): backup and recovery of persistent volume claims

### GitOps

[Flux](https://github.com/fluxcd/flux2) watches the clusters in my [kubernetes](./kubernetes/) folder (see Directories below) and makes the changes to my clusters based on the state of my Git repository.

The way Flux works for me here is it will recursively search the `kubernetes/${cluster}/apps` folder until it finds the most top level `kustomization.yaml` per directory and then apply all the resources listed in it. That aforementioned `kustomization.yaml` will generally only have a namespace resource and one or many Flux kustomizations (`ks.yaml`). Under the control of those Flux kustomizations there will be a `HelmRelease` or other resources related to the application which will be applied.

[Renovate](https://github.com/renovatebot/renovate) watches my **entire** repository looking for dependency updates, when they are found a PR is automatically created. When some PRs are merged Flux applies the changes to my cluster.

### Directories

This Git repository contains the following directories under [Kubernetes](./kubernetes/).

```sh
📁 kubernetes
├── 📁 pi             # main cluster
│   ├── 📁 apps         # applications
│   ├── 📁 bootstrap    # bootstrap procedures
│   ├── 📁 flux         # core flux configuration
└── 📁 shared           # shared cluster resources
    ├── 📁 components   # re-useable components
    └── 📁 repositories # common reusable repositories
```

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are self-hosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

The alternative solution to these two problems would be to host a Kubernetes cluster in the cloud and deploy applications like [HCVault](https://www.vaultproject.io/), [Vaultwarden](https://github.com/dani-garcia/vaultwarden), [ntfy](https://ntfy.sh/), and [Gatus](https://gatus.io/). However, maintaining another cluster and monitoring another group of workloads is a lot more time and effort than I am willing to put in.

| Service                                     | Use                                                               | Cost          |
|---------------------------------------------|-------------------------------------------------------------------|---------------|
| [1Password](https://1PAssword.com/)         | Secrets with [External Secrets](https://external-secrets.io/)     | Free - Work   |
| [Cloudflare](https://www.cloudflare.com/)   | Domain and S4                                                     | ~$30/yr       |
| [GitHub](https://github.com/)               | Hosting this repository and continuous integration/deployments    | Free          |
| [Healthchecks.io](https://healthchecks.io/) | Monitoring internet connectivity and external facing applications | Free          |
|                                             |                                                                   | Total: ~$3/mo |

---

## 🌐 DNS

In my cluster there are two instances of [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) running. One for syncing private DNS records to my `UDM-SE` using [ExternalDNS webhook provider for UniFi](https://github.com/kashalls/external-dns-unifi-webhook), while another instance syncs public DNS to `Cloudflare`. This setup is managed by creating ingresses with two specific classes: `internal` for private DNS and `external` for public DNS. The `external-dns` instances then syncs the DNS records to their respective platforms accordingly.

---

## 🔧 Hardware

### Pi Kubernetes Cluster

| Name    | Device        | CPU        | OS Disk    | Data Disk | RAM | OS    | Purpose           |
|---------|---------------|------------|------------|-----------|-----|-------|-------------------|
| Citlali | Raspberry Pi5 | Cortex A76 | 512GB NVMe | N/A       | 8GB | Talos | k8s control-plane |
| Layla   | Raspberry Pi5 | Cortex A76 | 250GB NVMe | N/A       | 8GB | Talos | k8s worker        |

Total CPU: 8 threads
Total RAM: 16GB

### Supporting Hardware

| Name    | Device        | CPU        | OS Disk    | Data Disk     | RAM   | OS           | Purpose        |
|---------|---------------|------------|------------|---------------|-------|--------------|----------------|
| Voyager | MS-01         | i5-12600H  | 32GB USB   | 1.92TB U.2    | 96GB  | Unraid       | NAS/NFS/Backup |
| DAS     | Lenovo SA120  | -          | -          | 6x14TB Raidz2 | -     | -            | ZFS            |
| PiKVM   | Raspberry Pi4 | Cortex A72 | 64GB mSD   | -             | 4GB   | PiKVM (Arch) | KVM (Main)     |
| TESmart | 8 port KVM    | -          | -          | -             | -     | -            | Network KVM    |
| JetKVM  | JetKVM        | RV1106G3   | 8GB EMMC   | -             | 256MB | Linux 5.10   | KVM (Utility)  |

### Networking/UPS Hardware

| Device                      | Purpose          |
|-----------------------------|------------------|
| Unifi UDM-SE                | Network - Router |
| USW-Pro-24-POE              | Network - Switch |
| Back-UPS 600                | Network - UPS    |
| Unifi USW-Enterprise-24-PoE | Server - Switch  |
| Tripp Lite 1500             | Server - UPS     |
