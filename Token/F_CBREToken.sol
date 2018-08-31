pragma solidity ^0.4.24;

import './F_ICO.sol';
import './F_MiscFeatures.sol';
import './F_Multiround.sol';

contract CBREToken is ICO,killable,MultiRound {
    
    constructor() public {
        symbol = "CBRE";
        name = "CBRE Property Token";
        decimals = 18;
        multiplier = base ** decimals;

        totalSupply = 3000000000 * multiplier; //3 bn-- extra 18 zeroes are for the wallets which use decimal variable to show the balance 
        owner = msg.sender;

        balances[owner] = totalSupply;
    }

    function () payable public {
        createTokens();
    }   
    
    function createTokens() public payable {
		
		require (currentICOPhase > 0);
		
        ICOPhase storage i = icoPhases[currentICOPhase]; 
        require(msg.value > 0 && i.saleOn == true);

        uint256 tokens = msg.value.mul(i.RATE);
		require(balances[owner] >= tokens);
		
        balances[owner] = balances[owner].sub(tokens);
        
        owner.transfer(msg.value);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        i.tokensAllocated = i.tokensAllocated.add(tokens);

        ethContributedBy[msg.sender] = ethContributedBy[msg.sender].add(msg.value);
        totalEthRaised = totalEthRaised.add(msg.value);
        totalTokensSoldTillNow = totalTokensSoldTillNow.add(tokens);
		
		emit Emission(msg.sender, tokens, i.RATE);

        if(i.tokensAllocated>=i.tokensStaged || now>i.deadline ){
            i.saleOn = !i.saleOn; 
            currentICOPhase++;
        }
    }
    
    function transfer(address _to, uint _value) public onlyWhenTokenIsOn onlyPayloadSize(2 * 32) returns (bool success){
        require(
            balances[msg.sender]>=_value 
            && _value > 0
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) public onlyWhenTokenIsOn onlyPayloadSize(3 * 32) returns (bool success){
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value > 0 
        );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

	event Emission(address indexed _to, uint256 _value, uint256 _rate);
}


