pragma solidity ^0.4.24;

import './F_ICO.sol';

contract killable is ICO {
    
    function killContract() public ownerOnly{
        selfdestruct(owner);
    }
}