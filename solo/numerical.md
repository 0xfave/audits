```
Prepared by:FaveLead Auditors: - Fave
```
# Table of Contents

- Table of Contents
- Disclaimer
- Introduction
- About **Fave**
- Protocol Summary
- Audit Details
    **-** Severity Criteria
    **-** Scope
    **-** Summary of Findings
    **-** Tools Used
- Detailed Findings
- Medium
    **-** [M-01] {Division by zero not prevented (lines 834).NumericalVault.sol}
       ∗Severity
       ∗Description
       ∗Recommendations
- Low
    **-** [L-01] Lack of two step ownership
       ∗Description
       ∗Recommendations
    **-** [L-02] Use a locked Pragma
       ∗Description
       ∗Recommendations
    **-** Discussion
- Informational
    **-** [I-01] NATSPEC missing in the codes
- Gas
    **-** [G-01] Costly Loop. Costly operations inside a loop might waste gas,
       so optimizations are justified.

# Disclaimer

A smart contract security review can never verify the complete absence of vul-
nerabilities. This is a time, resource and expertise bound effort where I try to
find as many vulnerabilities as possible. I can not guarantee 100% security after
the review or even if the review will find any problems with your smart contracts.
Subsequent security reviews, bug bounty programs and on-chain monitoring are
strongly recommended.


# Introduction

A time-boxed security review of the **Numerical** protocol was done by **fave** , with a
focus on the security aspects of the application’s implementation.

# About Fave

```
Fave is an independent smart contract security researcher. He does his best to
contribute to the blockchain ecosystem and its protocols by putting time and
effort into security research & reviews. Reach out on Twitter@0xfave
```
# Protocol Summary

The project involves a token system that allows users to lock their tokens for a
certain duration to receive LoECET tokens and earn a fixed percentage annual
return based on the lock length. The system has predefined minimum and
maximum lock durations, with a fixed annual percentage yield for each lock
duration.

# Audit Details

## Severity Criteria

```
## Severity Criteria

| Severity               | Impact: High | Impact: Medium | Impact: Low |
| ---------------------- | ------------ | -------------- | ----------- |
| **Likelihood: High**   | Critical     | High           | Medium      |
| **Likelihood: Medium** | High         | Medium         | Low         |
| **Likelihood: Low**    | Medium       | Low            | Low         |

**Impact** - the technical, economic and reputation damage of a successful attack

**Likelihood** - the chance that a particular vulnerability gets discovered and exploited

**Severity** - the overall criticality of the risk
```

## Scope

The following smart contracts were in scope of the audit:

- numericalVault

The following number of issues were found, categorized by their severity:

- Medium: 1 issues
- Low: 2 issues


- Gas: 1 issues

## Summary of Findings

| ID     | Title                                                                                                                       | Severity      |
| ------ | --------------------------------------------------------------------------------------------------------------------------- | ------------- |
| [M-01] | Division by zero not prevented (lines 834). NumericalVault.sol | Medium        |
| [L-01] | Lack of two step ownership                                     | Low           |
| [L-02] | Use a locked Pragma                                     | Low           |
| [L-02] | NATSPEC missing in the codes                                     | Informational |
| [G-01] | Costly Loop. Costly operations inside a loop might                                                          | Gas           |

## Tools Used

```
Manual Review
```
# Detailed Findings

# Medium

## [M-01] {Division by zero not prevented (lines 834).

## NumericalVault.sol}

```
Severity
```
```
Impact: Low
Likelihood: High
```
```
Description
```
The divisions below take an input parameter that does not have any zero-value
checks, which may lead to the functions reverting when zero is passed.

```
Recommendations
```
Add a zero-value check.


# Low

## [L-01] Lack of two step ownership

```
Description
```
The contracts lack two-step role transfer. The ownership of the Numerical vault
is implemented as a single-step function. The basic validation of whether the
address is not a zero address for a market is performed, however, the case when
the address receiving the role is inaccessible is not covered properly.

```
Recommendations
```
```
It is recommended to implement a two-step role transfer where the role recipient
is set and then the recipient has to claim that role to finalize the role transfer.
```
## [L-02] Use a locked Pragma

```
Description
```
The smart contract uses a floating pragma (pragma solidity ^0.8.24;) on
line 593. Floating pragmas are known to introduce potential security risks
because they allow the contract to be compiled with multiple versions of the
Solidity compiler. This can lead to inconsistencies and unexpected behavior,
especially if there are breaking changes or security vulnerabilities in newer com-
piler versions.

```
Recommendations
Lock the pragma to a specific compiler version thoroughly tested and verified.
For example, if the contract was tested with Solidity 0.8.24, the pragma should
be:
```
## Discussion

# Informational

## [I-01] NATSPEC missing in the codes

```
NatSpec was inspired by Doxygen and is a documentation format created by
the solidity team which helps you describe the intent behind your solidity smart
contracts.
```

# Gas

## [G-01] Costly Loop. Costly operations inside a loop might

## waste gas, so optimizations are justified.

Using a mapping that keeps track of the total locked amount for each account
can optimize this function. Add a mapping like Use a local variable to hold the
loop computation result.
