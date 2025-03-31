// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.13;

contract Walnut {
    uint256 initialShellStrength; // The initial shell strength for resets.
    uint256 shellStrength; // The current shell strength.
    uint256 round; // The current round number.

    uint256 initialKernel; // The initial hidden kernel value for resets.
    uint256 kernel; // The current hidden kernel value.

    // Tracks the number of hits per player per round.
    mapping(uint256 => mapping(address => uint256)) hitsPerRound;

    // Events to log hits, shakes, and resets.
    event Hit(uint256 indexed round, address indexed hitter, uint256 remaining);
    event Shake(uint256 indexed round, address indexed shaker);
    event Reset(uint256 indexed newRound, uint256 remainingShellStrength);

    constructor(uint256 _shellStrength, uint256 _kernel) {
        initialShellStrength = _shellStrength;
        shellStrength = _shellStrength;

        initialKernel = _kernel;
        kernel = _kernel;

        round = 1;
    }

    // Get the current shell strength.
    function getShellStrength() public view returns (uint256) {
        return shellStrength;
    }

    // Hit the Walnut to reduce its shell strength.
    function hit() public requireIntact {
        shellStrength--;
        hitsPerRound[round][msg.sender]++;
        emit Hit(round, msg.sender, shellStrength);
    }

    function shake(uint256 _numShakes) public requireIntact {
        kernel += _numShakes;
        emit Shake(round, msg.sender);
    }

    // Reset the Walnut for a new round.
    function reset() public requireCracked {
        shellStrength = initialShellStrength;
        kernel = initialKernel;
        round++;
        emit Reset(round, shellStrength);
    }

    // Look at the kernel if the shell is cracked and the caller contributed.
    function look() public view requireCracked onlyContributor returns (uint256) {
        return kernel;
    }

    // Modifier to ensure the shell is fully cracked.
    modifier requireCracked() {
        require(shellStrength == 0, "SHELL_INTACT");
        _;
    }

    // Modifier to ensure the shell is not cracked.
    modifier requireIntact() {
        require(shellStrength > 0, "SHELL_ALREADY_CRACKED");
        _;
    }

    // Modifier to ensure the caller has contributed in the current round.
    modifier onlyContributor() {
        require(hitsPerRound[round][msg.sender] > 0, "NOT_A_CONTRIBUTOR");
        _;
    }
}
