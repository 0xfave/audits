Prepared by: [Fave](https://Fave.io)
Lead Auditors: 
- Fave

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Disclaimer](#disclaimer)
- [Introduction](#introduction)
- [About **Fave**](#about-fave)
- [Protocol Summary](#protocol-summary)
- [Audit Details](#audit-details)
  - [Severity Criteria](#severity-criteria)
  - [Scope](#scope)
  - [Summary of Findings](#summary-of-findings)
  - [Tools Used](#tools-used)
- [Detailed Findings](#detailed-findings)
- [Medium](#medium)
  - [\[M-01\] {The contract includes pure methods for approval, transfer, and allowance methods (lines 117-135). `EcetGovernanceToken.sol`}](#m-01-the-contract-includes-pure-methods-for-approval-transfer-and-allowance-methods-lines-117-135-ecetgovernancetokensol)
    - [Severity](#severity)
    - [Description](#description)
    - [Recommendations](#recommendations)
- [Low](#low)
  - [\[L-01\] No checks if lockDuration is within the allowd duration](#l-01-no-checks-if-lockduration-is-within-the-allowd-duration)
    - [Description](#description-1)
    - [Recommendations](#recommendations-1)
  - [Discussion](#discussion)
- [Informational](#informational)
  - [\[I-01\] NATSPEC missing in the codes](#i-01-natspec-missing-in-the-codes)
- [Gas](#gas)
  - [\[G-01\] The getLockedAmount function (line 145) iterates through the whole array of locks which can lead to high gas consumption in the case of a long lock array.](#g-01-the-getlockedamount-function-line-145-iterates-through-the-whole-array-of-locks-which-can-lead-to-high-gas-consumption-in-the-case-of-a-long-lock-array)

# Disclaimer

A smart contract security review can never verify the complete absence of vulnerabilities. This is a time, resource and expertise bound effort where I try to find as many vulnerabilities as possible. I can not guarantee 100% security after the review or even if the review will find any problems with your smart contracts. Subsequent security reviews, bug bounty programs and on-chain monitoring are strongly recommended.

# Introduction

A time-boxed security review of the **Ecet** protocol was done by **fave**, with a focus on the security aspects of the application's implementation.

# About **Fave**

**Fave** is an independent smart contract security researcher. He does his best to contribute to the blockchain ecosystem and its protocols by putting time and effort into security research & reviews. Reach out on Twitter [@0xfave](https://twitter.com/0xfave)

# Protocol Summary
The project involves a token system that allows users to lock their tokens for a certain duration to receive LoECET tokens and earn a fixed percentage annual return based on the lock length. The system has predefined minimum and maximum lock durations, with a fixed annual percentage yield for each lock duration.

# Audit Details 

## Severity Criteria

| Severity               | Impact: High | Impact: Medium | Impact: Low |
| ---------------------- | ------------ | -------------- | ----------- |
| **Likelihood: High**   | Critical     | High           | Medium      |
| **Likelihood: Medium** | High         | Medium         | Low         |
| **Likelihood: Low**    | Medium       | Low            | Low         |

**Impact** - the technical, economic and reputation damage of a successful attack

**Likelihood** - the chance that a particular vulnerability gets discovered and exploited

**Severity** - the overall criticality of the risk

## Scope 

The following smart contracts were in scope of the audit:

- `EcetGovernanceToken`
- `EcetToken`

The following number of issues were found, categorized by their severity:

- Medium: 1 issues
- Low: 1 issues
- Gas: 1 issues
- Informational: 1 issues

---

## Summary of Findings

| ID     | Title                                                                                                                                  | Severity           |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| [M-01] | The contract includes pure methods for approval, transfer, and allowance methods (lines 117-135). `EcetGovernanceToken.sol`            | Medium             |
| [L-01] | No checks if lockDuration is within the allowd duration                                                                                | Low                |
| [I-01] | NATSPEC missing in the codes                                                                                                           | Informational      |
| [G-01] | getLockedAmount function iterates through the whole array of locks                                                                     | Gas                |

## Tools Used
Manual Review

# Detailed Findings

# Medium

## [M-01] {The contract includes pure methods for approval, transfer, and allowance methods (lines 117-135). `EcetGovernanceToken.sol`}

### Severity

**Impact:**
Low

**Likelihood:**
High

### Description

These methods should be removed or implemented to prevent confusion for users interacting with the token.

### Recommendations

Regarding the transfer, approve and allowance methods, they should be correctly implemented or override the appropriate internal methods like `_approve`, `_transfer`, and `_allowance`. Remove lines 117-135 and redefine methods as needed.

# Low

## [L-01] No checks if lockDuration is within the allowd duration

### Description

Check that the lockDuration is not greater or less than the allowed durations defined in the contract as this may miss lead the user thinking they can lock for a long time

### Recommendations

 ```solidity
 require(lockDuration >= MIN_LOCK_DURATION && lockDuration <= MAX_LOCK_DURATION, "Invalid lock duration");
 ```
if this is implemented change it from view to pure modifier

## Discussion


# Informational

## [I-01] NATSPEC missing in the codes

NatSpec was inspired by Doxygen and is a documentation format created by the solidity team which helps you describe the intent behind your solidity smart contracts.

# Gas 

## [G-01] The getLockedAmount function (line 145) iterates through the whole array of locks which can lead to high gas consumption in the case of a long lock array. 

Using a mapping that keeps track of the total locked amount for each account can optimize this function. Add a mapping like 'mapping(address => uint256) public totalLockedAmount;' and update the '_transfer' function to reflect these changes.