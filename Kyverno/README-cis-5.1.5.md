# CIS-5.1.5 Kyverno Policy: Prevent Default Service Account Usage

## Overview

This Kyverno policy implements **CIS Kubernetes Benchmark Control 5.1.5**: "Ensure that default service accounts are not actively used."

The default service account should not be used to ensure that rights granted to applications can be more easily audited and reviewed.

## Policy Details

- **Policy Name**: `cis-5.1.5-prevent-default-service-account`
- **CIS Control**: 5.1.5
- **Severity**: Medium
- **Action**: Enforce (blocks non-compliant resources)
- **Scope**: Cluster-wide

## What This Policy Does

### 🚫 **Blocks:**
1. **Explicit default service account usage**:
   ```yaml
   spec:
     serviceAccountName: default  # ❌ Blocked
   ```

2. **Implicit default service account usage**:
   ```yaml
   spec:
     # ❌ Blocked - no serviceAccountName specified
     containers: [...]
   ```

3. **Default service account with automatic token mounting**:
   ```yaml
   spec:
     serviceAccountName: default
     automountServiceAccountToken: true  # ❌ Blocked
   ```

### ✅ **Allows:**
1. **Dedicated service accounts**:
   ```yaml
   spec:
     serviceAccountName: my-app-service-account  # ✅ Allowed
   ```

2. **Proper RBAC configuration**:
   ```yaml
   spec:
     serviceAccountName: webapp-sa
     automountServiceAccountToken: false  # ✅ Recommended
   ```

## Rationale

Using the default service account violates the principle of least privilege because:
- Default service accounts often have broad, undefined permissions
- It's difficult to audit which applications are using what permissions
- Service account permissions become mixed across different applications
- Compliance auditing becomes complex

## Remediation

### 1. Create Dedicated Service Accounts

```bash
# Create a service account for your application
kubectl create serviceaccount webapp-service-account

# Optionally disable automatic token mounting
kubectl patch serviceaccount webapp-service-account \
  -p '{"automountServiceAccountToken": false}'
```

### 2. Update Pod Specifications

**Before (❌ Non-compliant):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: nginx
```

**After (✅ Compliant):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: webapp-service-account
  automountServiceAccountToken: false  # If API access not needed
  containers:
  - name: app
    image: nginx
```

### 3. Configure RBAC (if API access needed)

```yaml
# Minimal role with only required permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: webapp-role
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]

---
# Bind the role to your service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: webapp-role-binding
subjects:
- kind: ServiceAccount
  name: webapp-service-account
roleRef:
  kind: Role
  name: webapp-role
  apiGroup: rbac.authorization.k8s.io
```

## Testing the Policy

### Deploy the Policy
```bash
kubectl apply -f cis-5.1.5-prevent-default-service-account.yaml
```

### Test with Examples
```bash
# This should be blocked
kubectl apply -f cis-5.1.5-examples.yaml

# Check policy violations
kubectl get events --field-selector reason=PolicyViolation
```

### Verify Policy Status
```bash
# Check if policy is active
kubectl get clusterpolicy cis-5.1.5-prevent-default-service-account

# View policy details
kubectl describe clusterpolicy cis-5.1.5-prevent-default-service-account
```

## Exemptions

If you need to temporarily exempt certain workloads, you can use Kyverno policy exceptions:

```yaml
apiVersion: kyverno.io/v2alpha1
kind: PolicyException
metadata:
  name: legacy-app-exception
spec:
  exceptions:
  - policyName: cis-5.1.5-prevent-default-service-account
    ruleNames:
    - prevent-default-service-account
  match:
  - any:
    - resources:
        kinds:
        - Pod
        names:
        - legacy-application-*
        namespaces:
        - legacy-namespace
```

## Monitoring and Compliance

### Check Compliance Status
```bash
# View policy reports
kubectl get policyreport -A

# Check for violations
kubectl get clusterpolicyreport
```

### Metrics and Alerting
Monitor these metrics in your observability stack:
- `kyverno_policy_results_total{policy="cis-5.1.5-prevent-default-service-account"}`
- Failed admission requests due to default service account usage

## Best Practices

1. **🔐 Principle of Least Privilege**: Only grant the minimum permissions required
2. **📋 Regular Audits**: Review service account permissions regularly
3. **🏷️ Naming Convention**: Use descriptive names for service accounts (e.g., `webapp-reader-sa`)
4. **🔍 Monitoring**: Set up alerts for policy violations
5. **📚 Documentation**: Document the purpose and permissions of each service account

## Related CIS Controls

- **5.1.1**: Ensure that the cluster-admin role is only used where required
- **5.1.2**: Minimize access to secrets
- **5.1.3**: Minimize wildcard use in Roles and ClusterRoles
- **5.1.4**: Minimize access to create pods

## References

- [CIS Kubernetes Benchmark v1.7.0](https://www.cisecurity.org/benchmark/kubernetes)
- [Kubernetes Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [Kyverno Policy Documentation](https://kyverno.io/docs/writing-policies/)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
