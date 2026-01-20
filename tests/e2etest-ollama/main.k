import datetime
import math
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# E2E Test for Ollama XRD (Kubernetes-only)
#
# This test uses the Helm provider with ProviderConfig which uses
# injected identity (no credentials needed - runs in-cluster).
# ==============================================================================

# Generate unique name using timestamp to avoid CI conflicts
_now = str(int(math.floor(datetime.ticks())))
_test_name = "e2e-ollama-" + _now

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "ollama-helm"
        spec = {
            crossplane = {
                autoUpgrade.channel = "Rapid"
            }
            defaultConditions = ["Ready"]
            timeoutSeconds = 1800
            cleanupTimeoutSeconds = 1800
            skipDelete = False

            # ==============================================================
            # extraResources: RBAC and Helm ProviderConfig
            # These are NOT deleted during cleanup
            # ==============================================================
            extraResources = [
                # Grant cluster-admin to all SAs in crossplane-system namespace
                # This allows the Helm provider to create namespaces and install charts
                {
                    apiVersion = "rbac.authorization.k8s.io/v1"
                    kind = "ClusterRoleBinding"
                    metadata.name = "crossplane-system-cluster-admin"
                    roleRef = {
                        apiGroup = "rbac.authorization.k8s.io"
                        kind = "ClusterRole"
                        name = "cluster-admin"
                    }
                    subjects = [
                        {
                            kind = "Group"
                            name = "system:serviceaccounts:crossplane-system"
                            apiGroup = "rbac.authorization.k8s.io"
                        }
                    ]
                }
                # Helm ProviderConfig - uses in-cluster identity
                # Must use helm.m.crossplane.io to match the Release API
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = "default"
                    }
                    spec = {
                        credentials = {
                            source = "InjectedIdentity"
                        }
                    }
                }
            ]

            # ==============================================================
            # manifests: The Ollama XR to test
            # ==============================================================
            manifests = [
                {
                    apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                    kind = "Ollama"
                    metadata = {
                        name = _test_name
                        namespace = "default"
                    }
                    spec = {
                        clusterName = _test_name
                        labels = {
                            "hops.ops.com.ai/e2etest" = "true"
                            "hops.ops.com.ai/test-run" = _now
                        }
                        providerConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                        values = {
                            # Minimal resources for E2E test
                            resources = {
                                requests = {
                                    cpu = "10m"
                                    memory = "256Mi"
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
]
items = _items
