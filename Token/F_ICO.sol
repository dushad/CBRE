pragma solidity ^0.4.24;

import './F_BaseToken.sol';
import './F_DateTime.sol';

contract ICO is BaseToken,DateTimeEnabled{

    uint256 base = 10;
    uint256 multiplier;

    struct ICOPhase {
        string phaseName;
        uint256 tokensStaged;
        uint256 tokensAllocated;
        uint256 RATE;
        bool saleOn;
        uint deadline;
    }

    uint8 public currentICOPhase;
    
    mapping(address => uint256) public ethContributedBy;
    uint256 public totalEthRaised;
    uint256 public totalTokensSoldTillNow;

    mapping(uint8 => ICOPhase) public icoPhases;
    uint8 icoPhasesIndex = 1;
    
    function getEthContributedBy(address _address) public constant returns(uint256){
        return ethContributedBy[_address];
    }

    function getTotalEthRaised() public constant returns(uint256){
        return totalEthRaised;
    }

    function getTotalTokensSoldTillNow() public constant returns(uint256){
        return totalTokensSoldTillNow;
    }
    
    function addICOPhase(string _phaseName, uint256 _tokensStaged, uint256 _rate,uint _deadline) public ownerOnly{
        icoPhases[icoPhasesIndex].phaseName = _phaseName;
        icoPhases[icoPhasesIndex].tokensStaged = _tokensStaged;
        icoPhases[icoPhasesIndex].RATE = _rate;
        icoPhases[icoPhasesIndex].tokensAllocated = 0;
        icoPhases[icoPhasesIndex].saleOn = false;
        icoPhases[icoPhasesIndex].deadline = _deadline;
        icoPhasesIndex++;
    }

    function toggleSaleStatus() public ownerOnly{
        icoPhases[currentICOPhase].saleOn = !icoPhases[currentICOPhase].saleOn;
    }
	
    function changeRate(uint256 _rate) public ownerOnly{
        icoPhases[currentICOPhase].RATE = _rate;
    }
	
    function changeCurrentICOPhase(uint8 _newPhase) public ownerOnly{ //Only provided for exception handling in case some faulty phase has been added by the owner using addICOPhase
        currentICOPhase = _newPhase;
    }

    function changeCurrentPhaseDeadline(uint256 _timestamp) public ownerOnly{
        icoPhases[currentICOPhase].deadline = _timestamp; //sets deadline to timestamp
    }
	
    function changeCurrentPhaseLimit(uint256 _limit) public ownerOnly{
        icoPhases[currentICOPhase].tokensStaged = _limit;
    }	
    
    function transferOwnership(address newOwner) public ownerOnly{
        if (newOwner != address(0)) {
          owner = newOwner;
        }
    }
}
