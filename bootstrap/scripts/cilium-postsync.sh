#!/usr/bin/env bash
wait_for_crds() {
    local crds=(
        "ciliuml2announcementpolicies.cilium.io"
        "ciliumbgppeeringpolicies.cilium.io"
        "ciliumloadbalancerippools.cilium.io"
    )
    for crd in "${crds[@]}"; do
        until kubectl get crd "$crd" &>/dev/null; do
            sleep 5
        done
    done
}

apply_kustomize_config() {
    kubectl apply \
        --context ${CLUSTER} \
        --namespace=kube-system \
        --server-side \
        --field-manager=kustomize-controller \
        --kustomize \
        "${APPS_DIR}/kube-system/cilium/config"
}

apply_cluster_configmap() {
    kubectl apply \
        --context ${CLUSTER} \
        --namespace=flux-system \
        --server-side \
        ----filename \
        "${CLUSTER_DIR}/secrets/cluster-settings.yaml"
}

main() {
    wait_for_crds
    apply_kustomize_config
    apply_cluster_configmap
}

main
