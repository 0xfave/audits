// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./EcetToken.sol";

contract EcetGovernanceToken is EcetToken
{
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    uint256 public constant MAX_LOCK_DURATION = 36; // max lock duration in months
    uint256 public constant MIN_LOCK_DURATION = 12; // min lock duration in months

    uint256 public constant APY_SHORT_LOCK = 59; // 5.9% APY for 12 months lock
    uint256 public constant APY_MEDIUM_LOCK = 69; // 6.9% APY for 24 months lock
    uint256 public constant APY_LONG_LOCK = 89; // 8.9% APY for 36 months lock

    uint256 public buyTax = 5; // 0.5% buy tax
    uint256 public sellTax = 10; // 1% sell tax

    mapping(address => Lock[]) public locks;

    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensUnlocked(address indexed user, uint256 amount);

    constructor() EcetToken("LoECET", "LoECET")
    {

    }
    function lockTokens(uint256 amount, uint256 lockDuration) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(lockDuration >= MIN_LOCK_DURATION && lockDuration <= MAX_LOCK_DURATION, "Invalid lock duration");

        uint256 unlockTime = block.timestamp + (lockDuration * 30 days);
        _transfer(msg.sender, address(this), amount);
        locks[msg.sender].push(Lock(amount, unlockTime));
        emit TokensLocked(msg.sender, amount, unlockTime);
    }

    function unlockTokens(uint256 index) external {
        require(index < locks[msg.sender].length, "Invalid lock index");
        require(block.timestamp >= locks[msg.sender][index].unlockTime, "Tokens still locked");

        uint256 amount = locks[msg.sender][index].amount;
        locks[msg.sender][index] = locks[msg.sender][locks[msg.sender].length - 1];
        locks[msg.sender].pop();
        _transfer(address(this), msg.sender, amount);
        emit TokensUnlocked(msg.sender, amount);
    }

    function setBuyTax(uint256 tax) external onlyOwner {
        buyTax = tax;
    }

    function setSellTax(uint256 tax) external onlyOwner {
        sellTax = tax;
    }

    function getAPY(uint256 lockDuration) public pure returns (uint256) {
        if (lockDuration >= 36) {
            return APY_LONG_LOCK;
        } else if (lockDuration >= 24) {
            return APY_MEDIUM_LOCK;
        } else {
            return APY_SHORT_LOCK;
        }
    }


    function calculateInterest(uint256 amount, uint256 lockDuration) public view returns (uint256) {
        uint256 apy = getAPY(lockDuration);
        uint256 interest = amount * apy / 1000; // calculate interest (divided by 1000 to account for decimals)
        uint256 lockTime = lockDuration * 30 days;
        uint256 apyPerSecond = apy * 10 / 365 / 24 / 60 / 60; // calculate APY per second
        uint256 timeSinceLock = block.timestamp - lockTime;
        if (timeSinceLock >= lockTime) {
            return interest;
        } else {
            return interest * timeSinceLock / lockTime; // apply linear decay
        }
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        uint256 tax = isBuy(sender) ? buyTax : sellTax;
        uint256 lockedAmount = getLockedAmount(sender);
        uint256 unlockedAmount = amount;
        uint256 interest = 0;
        if (lockedAmount > 0) {
            uint256 lockDuration = getLockDuration(sender);
            interest = calculateInterest(lockedAmount, lockDuration);
            unlockedAmount = unlockedAmount + interest;
        }

        uint256 taxAmount = amount * tax / 1000;
        uint256 netAmount = amount - taxAmount;
        super._transfer(sender, owner(), taxAmount);
        super._transfer(sender, recipient, netAmount - interest);
    }

    function transfer(address to, uint256 amount)
        public
        pure
        virtual
        override
        returns (bool)
    {
        revert("Token is not transferable");
    }

    function allowance(address owner, address spender)
        public
        pure
        virtual
        override
        returns (uint256)
    {
        revert("Token is not transferable");
    }

    function approve(address spender, uint256 amount)
        public
        pure
        virtual
        override
        returns (bool)
    {
        revert("Token is not transferable");
    }
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public pure virtual override returns (bool) {
        revert("Token is not transferable");
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        pure
        virtual
        override
        returns (bool)
    {
        revert("Token is not transferable");
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        pure
        virtual
        override
        returns (bool)
    {
        revert("Token is not transferable");
    }
    

    function isBuy(address sender) internal view returns (bool) {
        return sender != address(this);
    }

    function getLockedAmount(address account) public view returns (uint256) {
        uint256 lockedAmount = 0;

        for (uint256 i = 0; i < locks[account].length; i++) {
            lockedAmount += locks[account][i].amount;
        }

        return lockedAmount;
    }

    function getLockDuration(address account) public view returns (uint256) {
        uint256 shortestLockTime = block.timestamp + (MAX_LOCK_DURATION * 30 days);

        for (uint256 i = 0; i < locks[account].length; i++) {
            if (locks[account][i].unlockTime < shortestLockTime) {
                shortestLockTime = locks[account][i].unlockTime;
            }
        }

        uint256 lockDuration = (shortestLockTime - block.timestamp) / 30 days;
        return lockDuration;
    }

    function getLocks(address account) public view returns (Lock[] memory) {
        return locks[account];
    }
    
}