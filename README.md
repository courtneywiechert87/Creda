# Creda: Decentralized Digital Identity Protocol

A blockchain-based platform for managing verified digital identity through smart contracts, enabling users to own, control, and share credentials securely across applications and jurisdictions.

---

## Overview

This system consists of ten modular smart contracts written in Clarity, each handling a specific aspect of decentralized identity:

1. **CredaRegistry** – Manages identity profiles linked to wallet addresses
2. **VerifierHub** – Allows authorized entities to verify and issue credentials
3. **AccessKeys** – Grants permission-based access to user identity data
4. **CredToken** – Issues reusable identity credentials as verifiable tokens
5. **ProofLayer** – Enables zero-knowledge verification of identity attributes
6. **TrustScore** – Tracks reputation of users and verifiers
7. **DisputeEngine** – Handles credential challenges and verification disputes
8. **RewardStream** – Incentivizes trusted behavior and re-use of credentials
9. **AuditLog** – Records immutable history of identity interactions
10. **ComplianceRouter** – Applies jurisdictional rules to credential access

---

## Features

- Self-sovereign identity management  
- Selective disclosure with ZK proofs  
- Reusable, verifiable credentials  
- Multi-jurisdictional compliance enforcement  
- On-chain verifier ecosystem  
- Transparent credential usage history  
- Incentive mechanisms for network participants

---

## Smart Contracts

### **CredaRegistry**

- Registers user identity profiles (off-chain data encrypted)
- Binds wallet addresses to DID-like records
- Supports multi-profile management

### **VerifierHub**

- Allows whitelisted entities to verify identities
- Stores verifier reputations and history
- Manages verifier slashing for misconduct

### **AccessKeys**

- Role-based access control to identity attributes
- Expiration and revocation of access grants
- Data request logging

### **CredToken**

- Issues credentials as NFTs or soulbound tokens
- Supports expiration, metadata, and proof anchors
- Compatible with W3C Verifiable Credentials

### **ProofLayer**

- Verifies identity claims using ZK-SNARKs
- Age, residency, income proofs without full data disclosure
- Integrated with AccessKeys for disclosure control

### **TrustScore**

- Tracks decentralized reputation for users and verifiers
- Weighted scoring based on verifier trust and usage
- Decay and fraud resistance mechanisms

### **DisputeEngine**

- On-chain credential challenge system
- Escalation paths to governance or arbitration DAO
- Slashing and appeal logic included

### **RewardStream**

- Token incentives for credential reuse and validation
- Verifier reward pools and usage bonuses
- Optional staking for reputation boosting

### **AuditLog**

- Tamper-proof logging of all identity interactions
- Includes access requests, verifications, and updates
- Supports privacy-preserving indexing

### **ComplianceRouter**

- Smart routing of identity data based on jurisdiction
- Integrates compliance logic (GDPR, KYC, etc.)
- Region-specific credential enforcement

---

## Installation

1. Install Clarinet CLI  
2. Clone this repository  
3. Run tests: `npm run test`  

---

## Usage

Each contract is independently deployable and can integrate with existing dApps or Web3 identity flows. Users maintain full control over access to their data. Verifiers must be registered in `VerifierHub` before issuing credentials.

Refer to each contract’s documentation for specific interface functions and schema details.

---

## Testing

Tests are written using the Clarinet testing suite.

Run all tests with:

```bash
clarinet test
```

## License

MIT License