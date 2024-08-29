// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {UD60x18, ud} from "@prb/math/src/UD60x18.sol";

contract StakerV2 is ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant BASE_REWARD_AMOUNT = 1000e18;
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant DURATION = 1 days;

    // 1.1 => 1.1e18
    UD60x18 public interestMultiplierPoints;

    struct StakeItem {
        address account;
        uint256 stakeTime;
        uint256 claimedAmount;
    }

    address public stakeNFT;
    address public rewardToken;

    mapping(uint256 => StakeItem) private _stakes;

    error AlreadyStaked(uint256 tokenID);
    error NotStaked(uint256 tokenID);
    error NotNFTOwner(uint256 tokenID);

    event Stake(uint256 indexed tokenID, address account, uint256 stakeTime);
    event UnStake(uint256 indexed tokenID, address account);
    event Claim(uint256 indexed tokenID, address account, uint256 rewardAmount);

    constructor(
        address stakeNFT_,
        address rewardToken_,
        uint256 interestMultiplierPoints_
    ) {
        stakeNFT = stakeNFT_;
        rewardToken = rewardToken_;
        interestMultiplierPoints = ud(interestMultiplierPoints_);
    }

    function stake(uint256 _tokenID) external nonReentrant {
        _stake(msg.sender, stakeNFT, _tokenID);
    }

    function unstake(uint256 _tokenID) external nonReentrant {
        _unstake(msg.sender, stakeNFT, _tokenID);
    }

    function claimRewards(uint256 _tokenID) external nonReentrant {
        _claimRewards(msg.sender, _tokenID);
    }

    function claimableReward(uint256 tokenID) external view returns (uint256) {
        StakeItem memory stakeItem = _stakes[tokenID];
        return _claimableReward(stakeItem.stakeTime, stakeItem.claimedAmount);
    }

    function _stake(
        address _account,
        address _stakeNFT,
        uint256 _tokenID
    ) private {
        address nftOwner = IERC721(_stakeNFT).ownerOf(_tokenID);
        if (nftOwner != _account) {
            revert NotNFTOwner(_tokenID);
        }

        IERC721(_stakeNFT).transferFrom(_account, address(this), _tokenID);

        StakeItem memory stakeItem = _stakes[_tokenID];

        if (stakeItem.account != address(0)) {
            revert AlreadyStaked(_tokenID);
        }
        _stakes[_tokenID] = StakeItem(_account, block.timestamp, 0);

        emit Stake(_tokenID, _account, block.timestamp);
    }

    function _unstake(
        address _account,
        address _stakeNFT,
        uint256 _tokenID
    ) private {
        _claimRewards(_account, _tokenID);
        delete _stakes[_tokenID];

        IERC721(_stakeNFT).transferFrom(address(this), _account, _tokenID);

        emit UnStake(_tokenID, _account);
    }

    function _claimRewards(address _account, uint256 _tokenID) private {
        StakeItem memory stakeItem = _stakes[_tokenID];

        if (stakeItem.account == address(0)) {
            revert NotStaked(_tokenID);
        }

        if (stakeItem.account != _account) {
            revert NotNFTOwner(_tokenID);
        }

        uint256 claimableAmount = _claimableReward(
            stakeItem.stakeTime,
            stakeItem.claimedAmount
        );
        stakeItem.claimedAmount += claimableAmount;
        _stakes[_tokenID] = stakeItem;

        IERC20(rewardToken).safeTransfer(_account, claimableAmount);

        emit Claim(_tokenID, _account, claimableAmount);
    }

    function _claimableReward(
        uint256 _stakeTime,
        uint256 _claimedAmount
    ) private view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 cycle = (currentTime - _stakeTime) / DURATION;

        if (cycle == 0) return 0;

        uint256 totalReward = BASE_REWARD_AMOUNT;
        UD60x18 interestMultiplierPoints_ = interestMultiplierPoints;
        totalReward = interestMultiplierPoints_
            .powu(cycle)
            .mul(ud(BASE_REWARD_AMOUNT))
            .intoUint256();

        return totalReward - BASE_REWARD_AMOUNT - _claimedAmount;
    }

    function stakeInfo(
        uint256 tokenID
    )
        external
        view
        returns (address account, uint256 stakeTime, uint256 claimedAmount)
    {
        StakeItem memory stakeItem = _stakes[tokenID];
        account = stakeItem.account;
        stakeTime = stakeItem.stakeTime;
        claimedAmount = stakeItem.claimedAmount;
    }
}
