// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduContentCoCreation {
    struct Content {
        string title;
        string description;
        address creator;
        uint256 reward;
        bool isCompleted;
        address[] contributors;
    }

    Content[] public contents;
    mapping(address => uint256) public contributorTokens;

    event ContentCreated(
        uint256 contentId,
        string title,
        string description,
        address creator,
        uint256 reward
    );

    event ContributionMade(
        uint256 contentId,
        address contributor
    );

    event TokensDistributed(
        uint256 contentId,
        uint256 reward
    );

    event TokensClaimed(
        address contributor,
        uint256 amount
    );

    // Create a new content project
    function createContent(
        string memory title,
        string memory description,
        uint256 reward
    ) public payable {
        require(msg.value == reward, "Reward amount must be funded.");

        address[] memory contributors;
        contents.push(Content({
            title: title,
            description: description,
            creator: msg.sender,
            reward: reward,
            isCompleted: false,
            contributors: contributors
        }));

        emit ContentCreated(contents.length - 1, title, description, msg.sender, reward);
    }

    // Make a contribution to an educational content
    function contributeToContent(uint256 contentId) public {
        Content storage content = contents[contentId];
        require(!content.isCompleted, "Content creation is already completed.");

        content.contributors.push(msg.sender);

        emit ContributionMade(contentId, msg.sender);
    }

    // Mark content as completed and distribute rewards
    function completeContent(uint256 contentId) public {
        Content storage content = contents[contentId];
        require(msg.sender == content.creator, "Only the creator can mark this content as completed.");
        require(!content.isCompleted, "Content is already completed.");
        require(content.contributors.length > 0, "No contributors to reward.");

        content.isCompleted = true;
        uint256 rewardPerContributor = content.reward / content.contributors.length;

        for (uint256 i = 0; i < content.contributors.length; i++) {
            contributorTokens[content.contributors[i]] += rewardPerContributor;
        }

        emit TokensDistributed(contentId, content.reward);
    }

    // Claim tokens
    function claimTokens() public {
        uint256 amount = contributorTokens[msg.sender];
        require(amount > 0, "No tokens to claim.");

        contributorTokens[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit TokensClaimed(msg.sender, amount);
    }

    // Get all contents
    function getAllContents() public view returns (Content[] memory) {
        return contents;
    }
}