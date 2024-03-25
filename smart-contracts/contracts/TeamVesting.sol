//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract TeamVesting is ReentrancyGuard {
    IERC20 public grl;

    address public immutable admin;
    uint256 private vestedTokens;

    struct VestingSchedule {
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 slicePeriod;
        uint256 amountTotal;
        uint256 released;
    }

    mapping(address => mapping(uint256 => VestingSchedule))
        public vestedUserDetail;
    mapping(address => uint256) private holdersVestingCount;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TokensClaimed(
        address indexed claimer,
        uint256 releasableTokens,
        uint256 purchaseIndex
    );
    event TokenReleased(uint256 releaseable, uint256 claimed);

    constructor(address _grlAddress) {
        grl = IERC20(_grlAddress);
        admin = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "You're not authorized!");
        _;
    }

    function createVestingSchedule(
        address _beneficiary,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriod,
        uint256 _amount
    ) external onlyOwner {
        require(_duration >= _cliff, "TokenVesting: duration must be >= cliff");
        uint256 cliff = block.timestamp + (_cliff * 86400);

        uint256 currentVestingIndex = holdersVestingCount[_beneficiary]++;
        vestedUserDetail[_beneficiary][currentVestingIndex] = VestingSchedule(
            _beneficiary,
            cliff,
            block.timestamp,
            _duration * 86400,
            _slicePeriod * 86400,
            _amount * 10 ** 9,
            0
        );

        vestedTokens += _amount * 10 ** 9;
    }

    function getVestingUserCount(
        address _beneficiary
    ) external view returns (uint256) {
        return holdersVestingCount[_beneficiary];
    }

    function getReleaseableAmount(
        address beneficiary
    ) public view returns (uint256 totalReleasable, uint256 totalRemaining) {
        uint256 vestingCount = holdersVestingCount[beneficiary];
        for (uint256 i = 0; i < vestingCount; i++) {
            VestingSchedule storage vestingSchedule = vestedUserDetail[
                beneficiary
            ][i];
            (uint256 releasable, uint256 remaining) = _computeReleasableAmount(
                vestingSchedule
            );

            totalReleasable += releasable;
            totalRemaining += remaining;
        }
        return (totalReleasable, totalRemaining);
    }

    function claimReleasableTokens() public {
        uint256 totalReleasable;
        uint256 totalRemaining;
        uint256 vestingCount = holdersVestingCount[msg.sender];
        require(vestingCount > 0, "No tokens purchased");
        for (uint256 i = 0; i < vestingCount; i++) {
            VestingSchedule storage vestingSchedule = vestedUserDetail[
                msg.sender
            ][i];
            (uint256 releasable, uint256 remaining) = _computeReleasableAmount(
                vestingSchedule
            );
            totalReleasable += releasable;
            totalRemaining += remaining;

            vestingSchedule.released += releasable;
        }
        require(totalReleasable > 0, "NO tokens to claim!");
        grl.transfer(msg.sender, totalReleasable);
    }

    function _computeReleasableAmount(
        VestingSchedule memory vestingSchedule
    ) internal view returns (uint256 releasable, uint256 remaining) {
        uint256 currentTime = block.timestamp;
        uint256 totalVested = 0;
        if (currentTime < vestingSchedule.cliff) {
            return (0, vestingSchedule.amountTotal - vestingSchedule.released);
        } else if (
            currentTime >= vestingSchedule.start + vestingSchedule.duration
        ) {
            releasable = vestingSchedule.amountTotal - vestingSchedule.released;
            return (releasable, 0);
        } else {
            uint256 timeFromCliffEnd = currentTime - vestingSchedule.cliff;
            uint256 secondsPerSlice = vestingSchedule.slicePeriod;
            uint256 vestedSlicePeriods = timeFromCliffEnd / secondsPerSlice;
            uint256 vestedSeconds = vestedSlicePeriods * secondsPerSlice;

            totalVested =
                (vestingSchedule.amountTotal * vestedSeconds) /
                vestingSchedule.duration;
        }

        releasable = totalVested - vestingSchedule.released;
        remaining = vestingSchedule.amountTotal - totalVested;
        return (releasable, remaining);
    }

    function withdrawGrl() external onlyOwner {
        uint256 grlBalance = grl.balanceOf(address(this));
        uint256 tokensToWithdraw = grlBalance - vestedTokens;
        require(tokensToWithdraw > 0, "no grl in contract!");
        grl.transfer(admin, tokensToWithdraw);
    }

    function withdrawEth() external onlyOwner {
        (bool success, ) = admin.call{value: address(this).balance}("");
        require(success);
    }
}
