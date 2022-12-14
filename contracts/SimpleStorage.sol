// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    string public yourName;

    constructor() {
        yourName = "Unknown";
    }

    function setName(string memory name) public {
        yourName = name;
    }
}
