# StakingRewards::_decreaseUserShare - User's share and virtual rewards should have different rounding directions

## Lines of code
https://github.com/code-423n4/2024-01-salty/blob/53516c2cdfdfacb662cdea6417c52f23c94d5b5b/src/staking/StakingRewards.sol#L113-L118

## Vulnerability details
### Impact
The issue may negatively impact the platform's overall stability over time due to the leaks

### Proof of Concept
calculations of the protocol and user rewards currently do not round in favour of the protocol, which means that value may leak from the system in favour of the users.

### Tools Used
Manual Analysis

### Recommended Mitigation Steps
Ensure that the rewardsForAmount should be rounded down and virtualRewardsToRemove be rounded up to prevent leaking value from the system.

### Assessed type
Math
