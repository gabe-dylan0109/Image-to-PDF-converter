# Image-to-PDF Converter: Mobile & Web Security Audit Lab

## 📌 Project Overview
A cross-platform image-to-PDF application built with Flutter/Dart and a Python prototype. Rather than just a utility application, this project served as a controlled laboratory for practicing full-cycle application security auditing: build, test, break, fix, and document. 

**Core Technologies & Tools Used:**
- Flutter / Dart
- Python
- ADB (Android Debug Bridge)
- APK Decompilation & Static Analysis
- CSP (Content Security Policy) Implementation

---

## ⚠️ Security Audit Findings
During the offensive testing phase (simulating both local device access and web-based threat vectors), the following vulnerabilities were identified:
*   **Temporary file disclosure:** Sensitive generated PDFs were written to insecure directories, making them accessible via ADB without root permissions.
*   **Client-side DoS vulnerability:** The application lacked unbounded file input restrictions, allowing memory exhaustion via massive image payloads.
*   **Missing Content Security Policy (CSP):** The web build lacked basic CSP headers, leaving it vulnerable to potential cross-site scripting/data exfiltration.
*   **HTTPS certificate validation gaps:** Discovered insecure network request configurations during the application's build analysis.

---

## 🛡️ Mitigations Implemented
Following the audit, the codebase was remediated to enforce secure development lifecycles (SDLC):
*   **Secure temp-file handling:** Implemented immediate cryptographic wiping/cleanup of temporary files immediately after the PDF export process completes.
*   **Memory Safety:** Enforced strict input size limits and utilized streaming processing to prevent memory exhaustion and DoS conditions.
*   **Header Hardening:** Implemented strict CSP and HTTP security headers on the web deployment architecture.
*   **Documentation:** All reproducible lab steps and audit trails were documented for stakeholder review.

---

## ⚖️ Disclaimer
This repository contains notes and code from a controlled security auditing environment. It is intended strictly for educational purposes, secure code review practice, and professional portfolio demonstration.
