# CIS-5.1.6: Ensure that Service Account Tokens are only mounted where necessary

## 📋 Overview

This directory contains a Kyverno policy implementation for **CIS Kubernetes Benchmark control 5.1.6**, which ensures that service account tokens are only mounted in pods when the workload explicitly needs to communicate with the Kubernetes API server.

**Control Title**: "Ensure that Service Account Tokens are only mounted where necessary"

**Severity**: Medium

**Control ID**: 5.1.6

## 🎯 Policy Objective

By default, Kubernetes automatically mounts service account tokens into every pod, providing unnecessary API access to workloads that don't need it. This policy enforces explicit decision-making about service account token mounting to minimize security exposure.

## 📂 Files

- **`cis-5.1.6-limit-service-account-token-mounting.yaml`** - Main Kyverno policy
- **`cis-5.1.6-examples.yaml`** - Test resources (compliant and non-compliant examples)
- **`README-cis-5.1.6.md`** - This documentation

## 🛡️ Policy Details

### Main Policy: `cis-5.1.6-limit-service-account-token-mounting`

This ClusterPolicy contains three validation rules:

#### Rule 1: `require-explicit-token-mounting-decision`
- **Action**: `enforce`
- **Target**: Pods
- **Purpose**: Requires pods to explicitly set `automountServiceAccountToken`
- **Allowed patterns**:
  - `automountServiceAccountToken: false` (recommended for most workloads)
  - `automountServiceAccountToken: true` + annotation `security.kubernetes.io/api-access: "required"`

#### Rule 2: `validate-service-account-token-mounting`
- **Action**: `enforce`
- **Target**: Pods
- **Purpose**: Prevents use of default service account when token mounting is enabled
- **Blocks**: Pods that set `automountServiceAccountToken: true` and use `serviceAccountName: default`

#### Rule 3: `warn-about-implicit-token-mounting`
- **Action**: `enforce` (warning message)
- **Target**: Pods
- **Purpose**: Warns about pods that don't explicitly set `automountServiceAccountToken`

### Supporting Policy: `cis-5.1.6-service-account-token-best-practices`

This ClusterPolicy validates ServiceAccount resources:

#### Rule: `service-account-default-no-automount`
- **Action**: `audit`
- **Target**: ServiceAccounts
- **Purpose**: Encourages explicit `automountServiceAccountToken` settings on ServiceAccounts

## 🔍 Rationale

**Why this control matters:**

1. **Principle of Least Privilege**: Most workloads don't need Kubernetes API access
2. **Attack Surface Reduction**: Limits potential for token misuse if pods are compromised
3. **Explicit Security Decisions**: Forces teams to consciously decide about API access needs
4. **Audit Trail**: Annotations provide documentation of why API access was granted

**Default Kubernetes Behavior:**
- Service accounts have `automountServiceAccountToken: true` by default
- Pods inherit this setting, automatically mounting tokens
- This gives every pod potential API access unnecessarily

## 🚨 Common Violations

### ❌ Violation Examples

```yaml
# BAD: Uses default service account with token mounting
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: default
  automountServiceAccountToken: true  # ❌ Default SA + token = violation

# BAD: Enables token mounting without annotation
apiVersion: v1
kind: Pod
spec:
  automountServiceAccountToken: true  # ❌ No annotation explaining why

# BAD: Implicit token mounting behavior
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: some-sa
  # ❌ Missing explicit automountServiceAccountToken setting
```

### ✅ Compliant Examples

```yaml
# GOOD: Explicitly disables token mounting
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: webapp-sa
  automountServiceAccountToken: false  # ✅ Explicit and secure

# GOOD: API access with proper annotation and dedicated SA
apiVersion: v1
kind: Pod
metadata:
  annotations:
    security.kubernetes.io/api-access: "required"  # ✅ Documented need
spec:
  serviceAccountName: monitor-sa  # ✅ Dedicated SA
  automountServiceAccountToken: true
```

## 🔧 Remediation Guide

### For Application Developers

1. **Assess API Needs**:
   ```bash
   # Ask yourself: Does my application need to:
   # - List/watch Kubernetes resources?
   # - Create/update Kubernetes objects?
   # - Access Kubernetes APIs directly?
   ```

2. **For Non-API Workloads** (recommended for most apps):
   ```yaml
   apiVersion: v1
   kind: Pod
   spec:
     automountServiceAccountToken: false  # Disable token mounting
   ```

3. **For API-Accessing Workloads**:
   ```yaml
   # Step 1: Create dedicated ServiceAccount
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: my-api-client-sa
     annotations:
       security.kubernetes.io/api-access: "required"
   automountServiceAccountToken: true
   
   ---
   # Step 2: Create minimal RBAC
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     name: my-api-client-role
   rules:
   - apiGroups: [""]
     resources: ["pods"]
     verbs: ["get", "list"]  # Only what's needed
   
   ---
   # Step 3: Use in Pod
   apiVersion: v1
   kind: Pod
   metadata:
     annotations:
       security.kubernetes.io/api-access: "required"
   spec:
     serviceAccountName: my-api-client-sa
     automountServiceAccountToken: true
   ```

### For Platform Teams

1. **Update ServiceAccount Defaults**:
   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: default
     namespace: my-namespace
   automountServiceAccountToken: false  # Override default behavior
   ```

2. **Create Secure Templates**:
   ```yaml
   # Template for non-API workloads
   apiVersion: v1
   kind: Pod
   spec:
     automountServiceAccountToken: false
     # ... rest of spec
   ```

## 🧪 Testing the Policy

### 1. Deploy the Policy

```bash
kubectl apply -f cis-5.1.6-limit-service-account-token-mounting.yaml
```

### 2. Create Test Namespace

```bash
kubectl create namespace cis-test
```

### 3. Test with Examples

```bash
# Apply test resources
kubectl apply -f cis-5.1.6-examples.yaml

# Check what was created vs. blocked
kubectl get pods -n cis-test
kubectl get serviceaccounts -n cis-test
```

### 4. Expected Results

**Should be created** (compliant):
- `secure-pod-no-token` - Explicitly disables token mounting
- `api-client-pod` - Enables mounting with proper annotation and dedicated SA
- `secure-pod-inherited-no-token` - Explicit disable with secure SA

**Should be blocked** (violations):
- `bad-pod-default-sa-with-token` - Uses default SA with token mounting
- `bad-pod-token-no-annotation` - Enables mounting without annotation

### 5. View Policy Reports

```bash
# Check policy violations
kubectl get policyreport -n cis-test
kubectl describe policyreport -n cis-test

# Check cluster-wide reports
kubectl get clusterpolicyreport
```

## 📊 Monitoring and Reporting

### Policy Violation Queries

```bash
# Find pods with implicit token mounting
kubectl get pods --all-namespaces -o json | jq -r '
  .items[] | 
  select(.spec.automountServiceAccountToken == null) |
  "\(.metadata.namespace)/\(.metadata.name)"
'

# Find service accounts with automount enabled
kubectl get serviceaccounts --all-namespaces -o json | jq -r '
  .items[] | 
  select(.automountServiceAccountToken == true) |
  "\(.metadata.namespace)/\(.metadata.name)"
'
```

### Compliance Dashboard Metrics

- **Token Mounting Explicit Rate**: % of pods with explicit `automountServiceAccountToken` setting
- **Secure Default Rate**: % of pods with `automountServiceAccountToken: false`
- **Justified API Access Rate**: % of token-mounting pods with proper annotations

## 🎯 Best Practices

### 1. **Default to No Token Mounting**
```yaml
# Make this your default pod template
spec:
  automountServiceAccountToken: false
```

### 2. **Use Dedicated Service Accounts**
- Never enable token mounting with the `default` service account
- Create purpose-specific service accounts for API-accessing workloads

### 3. **Document API Access Needs**
```yaml
metadata:
  annotations:
    security.kubernetes.io/api-access: "required"
    security.kubernetes.io/api-purpose: "monitoring - lists pods for metrics"
```

### 4. **Implement Minimal RBAC**
```yaml
# Only grant necessary permissions
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]  # Not "get", "list", "create", "delete", "*"
```

### 5. **Regular Access Reviews**
- Periodically review which workloads have token mounting enabled
- Validate that API access is still necessary
- Remove unused permissions

## 🔍 Troubleshooting

### Common Issues

1. **Policy blocks legitimate workloads**:
   - Add the required annotation: `security.kubernetes.io/api-access: "required"`
   - Ensure using a dedicated service account (not `default`)

2. **Legacy applications failing**:
   - Gradually migrate by setting policy to `audit` mode first
   - Update applications to explicitly set `automountServiceAccountToken: false`

3. **ServiceAccount warnings**:
   - Add explicit `automountServiceAccountToken` setting to ServiceAccounts
   - Use annotations to document purpose

### Policy Debugging

```bash
# Check policy status
kubectl get clusterpolicy cis-5.1.6-limit-service-account-token-mounting

# View detailed policy reports
kubectl describe policyreport -n <namespace>

# Check Kyverno logs
kubectl logs -n kyverno deployment/kyverno-admission-controller
```

## 📚 Additional Resources

- [CIS Kubernetes Benchmark v1.7.0](https://www.cisecurity.org/benchmark/kubernetes)
- [Kubernetes ServiceAccount Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [Kubernetes RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kyverno Policy Documentation](https://kyverno.io/docs/writing-policies/)

## 🏷️ Tags

`kubernetes` `security` `cis-benchmark` `kyverno` `service-accounts` `rbac` `policy-as-code` `devsecops` 