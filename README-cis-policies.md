# CIS GKE-EKS-AKS Generic Foundation Policies for Red Hat Advanced Cluster Security

This directory contains Red Hat Advanced Cluster Security (RHACS) SecurityPolicy Custom Resources that implement the common foundation policies shared across EKS, GKE, and AKS CIS benchmarks. All policies are prefixed with `cis-gke-eks-aks-generic` to clearly identify them as cross-cloud compatible security controls.

## Overview

These policies were derived from analyzing the common security controls found across all three major cloud Kubernetes services (Amazon EKS, Google GKE, and Azure AKS). They represent the **60% common foundation** that applies regardless of the cloud provider.

## Created Policies

### 1. RBAC and Access Control Policies

#### `cis-gke-eks-aks-generic-rbac-4.1.1-cluster-admin-role-minimization.yaml`
- **CIS Reference**: 4.1.1 - Ensure cluster-admin role is only used where required
- **Severity**: HIGH
- **Purpose**: Prevents excessive use of cluster-admin role
- **MITRE**: T1078 (Valid Accounts), T1068 (Exploitation for Privilege Escalation)

#### `cis-gke-eks-aks-generic-rbac-4.1.2-minimize-secrets-access.yaml`
- **CIS Reference**: 4.1.2 - Minimize access to secrets
- **Severity**: HIGH  
- **Purpose**: Restricts access to Kubernetes secrets containing sensitive data
- **MITRE**: T1552 (Unsecured Credentials), T1078 (Valid Accounts)

#### `cis-gke-eks-aks-generic-rbac-4.1.3-minimize-wildcard-usage.yaml`
- **CIS Reference**: 4.1.3 - Minimize wildcard use in Roles and ClusterRoles
- **Severity**: MEDIUM
- **Purpose**: Prevents overly broad RBAC permissions using wildcards
- **MITRE**: T1078 (Valid Accounts), T1068 (Exploitation for Privilege Escalation)

#### `cis-gke-eks-aks-generic-rbac-4.1.4-minimize-pod-creation-access.yaml`
- **CIS Reference**: 4.1.4 - Minimize access to create pods
- **Severity**: MEDIUM
- **Purpose**: Restricts pod creation permissions to prevent privilege escalation
- **MITRE**: T1078 (Valid Accounts), T1053 (Scheduled Task/Job)

### 2. Container Security Policies

#### `cis-gke-eks-aks-generic-network-5.9-host-network-namespace-isolation.yaml`
- **CIS Reference**: 5.9 - Ensure host's network namespace is not shared
- **Severity**: HIGH
- **Purpose**: Prevents containers from sharing the host's network namespace
- **MITRE**: T1611 (Escape to Host), T1021 (Remote Services)

#### `cis-gke-eks-aks-generic-container-privileged-prevention.yaml`
- **CIS Reference**: Container Security - Prevent privileged containers
- **Severity**: HIGH
- **Purpose**: Blocks containers running in privileged mode
- **MITRE**: T1611 (Escape to Host), T1068 (Exploitation for Privilege Escalation)

### 3. Image and Vulnerability Management

#### `cis-gke-eks-aks-generic-image-5.1.1-vulnerability-scanning.yaml`
- **CIS Reference**: 5.1.1 - Ensure Image Vulnerability Scanning is enabled
- **Severity**: MEDIUM
- **Purpose**: Enforces vulnerability scanning for container images
- **MITRE**: T1190 (Exploit Public-Facing Application), T1203 (Exploitation for Client Execution)

## Deployment Instructions

1. **Apply all policies to your RHACS cluster**:
   ```bash
   kubectl apply -f compliance/cis-gke-eks-aks-generic-*.yaml
   ```

2. **Verify policies are loaded**:
   ```bash
   kubectl get securitypolicy -n stackrox
   ```

3. **Check policy violations in RHACS UI**:
   - Navigate to Platform Configuration → Policy Management
   - Filter by categories: "Security Best Practices", "RBAC", "Container Security"

## Cross-Cloud Provider Compatibility

These policies are designed to work across all major cloud Kubernetes services:

| Policy | EKS | GKE | AKS | Notes |
|--------|-----|-----|-----|-------|
| Cluster-admin minimization | ✅ | ✅ | ✅ | Universal RBAC concern |
| Secrets access control | ✅ | ✅ | ✅ | Common across all platforms |
| Wildcard RBAC usage | ✅ | ✅ | ✅ | Standard Kubernetes RBAC |
| Host network isolation | ✅ | ✅ | ✅ | Container security fundamental |
| Privileged container prevention | ✅ | ✅ | ✅ | Critical security control |
| Image vulnerability scanning | ✅ | ✅ | ✅ | Adapted per cloud provider registry |
| Pod creation access | ✅ | ✅ | ✅ | Workload security control |

## Customization for Cloud Providers

While these policies provide a common foundation, you may want to customize them based on your specific cloud provider:

### AWS EKS Specific
- Update image scanning references to ECR
- Add IAM role-specific checks
- Consider EKS-specific service account configurations

### Google GKE Specific  
- Update image scanning references to GCR/Artifact Registry
- Add GCP IAM integration checks
- Consider GKE Autopilot constraints

### Azure AKS Specific
- Update image scanning references to ACR
- Add Azure RBAC integration
- Consider AKS-specific security features

## Policy Maintenance

- **Regular Updates**: Review and update policies as CIS benchmarks evolve
- **Exception Management**: Use RHACS policy exclusions for legitimate use cases
- **Monitoring**: Set up alerts for policy violations
- **Testing**: Validate policies in development environments before production deployment

## Related Documentation

- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [RHACS Policy Management](https://docs.openshift.com/acs/operating/manage-security-policies.html)
- [MITRE ATT&CK Framework](https://attack.mitre.org/) 