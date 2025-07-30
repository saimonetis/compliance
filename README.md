# Compliance Dashboard

A comprehensive web-based dashboard for visualizing and managing Kubernetes compliance checks based on CIS (Center for Internet Security) benchmarks and security best practices.

## 🎯 Overview

This compliance dashboard provides an intuitive interface for viewing and managing compliance checks for Kubernetes environments. It features:

- **Interactive compliance check visualization**
- **Direct navigation to detailed check information** 
- **Real-time compliance status tracking**
- **Integration with Kyverno policy engine**
- **CIS Kubernetes Benchmark coverage**

## 🚀 Features

### 📊 Dashboard
- **Compliance Overview**: Visual representation of compliance status across different checks
- **Pass/Fail Status Indicators**: Clear visual indicators for check results
- **Compliance Percentage Bars**: Progress bars showing compliance rates
- **Resource Count Tracking**: Pod counts for different compliance states

### 🔍 Navigation
- **Direct Check Navigation**: Click any check name to view detailed information
- **Seamless Back Navigation**: Easy return to main dashboard from detail pages
- **Sidebar Navigation**: Consistent navigation experience across all pages
- **Breadcrumb Navigation**: Clear indication of current location

### 📋 Compliance Checks Included

#### CIS Kubernetes Benchmark 5.1.5
- **prevent-default-service-account**: Prevents pods from using default service accounts
- **prevent-default-service-account-automount**: Controls automatic token mounting
- **prevent-empty-service-account**: Ensures explicit service account specification

#### CIS Kubernetes Benchmark 5.1.6  
- **require-explicit-token-mounting-decision**: Requires explicit token mounting configuration
- **validate-api-access-annotation**: Validates API access annotations

## 🏗️ Project Structure

```
├── README.md                                           # This file
├── compliance-dashboard.html                           # Main dashboard
├── cis-5.1.5-prevent-default-service-account.html    # Detail page (enhanced navigation)
├── cis-5.1.5-prevent-default-service-account-automount.html
├── cis-5.1.5-prevent-empty-service-account.html
├── cis-5.1.6-require-explicit-token-mounting-decision.html
├── Kyverno/                                           # Kyverno policy files
│   ├── README-cis-5.1.5.md
│   ├── README-cis-5.1.6.md
│   ├── cis-5.1.5-examples.yaml
│   ├── cis-5.1.5-prevent-default-service-account.yaml
│   └── cis-5.1.6-*.yaml
└── ACS/                                               # Advanced Cluster Security policies
    └── *.yaml
```

## 🎨 Getting Started

### Prerequisites
- Web browser (Chrome, Firefox, Safari, Edge)
- Web server (optional, for local development)

### Usage

1. **Clone the repository**:
   ```bash
   git clone https://github.com/saimonetis/compliance.git
   cd compliance
   ```

2. **Open the dashboard**:
   - **Direct**: Open `compliance-dashboard.html` in your web browser
   - **Local Server**: Serve files using a web server for best experience

3. **Navigate the dashboard**:
   - View overall compliance status on the main page
   - Click any check name to view detailed information
   - Use "Workload Compliance" in sidebar to return to main dashboard
   - Use "← Back to Dashboard" button on detail pages

## 🔧 Technical Details

### Technologies Used
- **HTML5**: Semantic markup and structure
- **CSS3**: Modern styling with flexbox and grid layouts
- **JavaScript**: Interactive features and navigation
- **Red Hat PatternFly**: Design system components and styling

### Browser Support
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 📈 Recent Improvements

### Navigation Enhancements ✨
- **Removed popup interruptions**: Direct navigation to check details without "Viewing details for..." alerts
- **Enhanced sidebar navigation**: Clickable "Workload Compliance" link returns to main dashboard
- **Consistent user experience**: Seamless navigation flow across all pages

### User Experience
- **Faster navigation**: Immediate page transitions
- **Intuitive controls**: Clear navigation paths
- **Visual consistency**: Unified design across all pages

## 🔐 Compliance Coverage

### Supported Benchmarks
- **CIS Kubernetes Benchmark v1.6+**
- **CIS Docker Benchmark** (in development)
- **NIST Cybersecurity Framework** alignment
- **OWASP Kubernetes Security** best practices

### Policy Engines
- **Kyverno**: Policy definitions and examples
- **Red Hat Advanced Cluster Security**: Enterprise security policies
- **Open Policy Agent (OPA)**: Future support planned

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Report Issues**: Found a bug or have a feature request? Open an issue
2. **Add Compliance Checks**: Create new check definitions and detail pages
3. **Improve Documentation**: Help us make the docs better
4. **Enhance UI/UX**: Contribute to the dashboard design and usability

### Development Workflow
```bash
# Fork the repository
git clone https://github.com/saimonetis/compliance.git
cd compliance

# Make your changes
# Test in browser

# Commit and push
git add .
git commit -m "Description of changes"
git push origin main

# Create pull request
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/saimonetis/compliance/issues)
- **Documentation**: Check the individual README files in subdirectories
- **Community**: Contribute via pull requests and discussions

## 🏷️ Version

**Current Version**: 1.1.0
- Enhanced navigation experience
- Comprehensive compliance check coverage
- Improved user interface design

---

**Built with ❤️ for Kubernetes security and compliance** 