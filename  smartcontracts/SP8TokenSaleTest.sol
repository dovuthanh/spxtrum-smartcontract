pragma solidity ^0.4.18;
import "./SP8Token.sol";

contract ICOPhase {
    uint256 public phasePresale_From = 1522627200;//0h 16/01/2018 GMT (test 26/12/2017)
    uint256 public phasePresale_To = 1522713600;//0h 21/01/2018 GMT

    uint256 public phasePublicSale1_From = 1522713600;//0h 21/01/2018 GMT
    uint256 public phasePublicSale1_To = 1522800000;//0h 26/01/2018 GMT

    uint256 public phasePublicSale2_From = 1522800000;//0h 26/01/2018 GMT
    uint256 public phasePublicSale2_To = 1522800000;//0h 31/01/2018 GMT

    uint256 public phasePublicSale3_From = 1522800000;//0h 31/01/2018 GMT
    uint256 public phasePublicSale3_To = 1522972800;//0h 05/02/2018 GMT
}

// ------------------------------------------------------------------------
// @title Pausable
// @dev Base contract which allows children to implement an emergency stop mechanism.
// ------------------------------------------------------------------------
contract Pausable is Owned {
  event Pause();
  event Unpause();

  bool public paused = false;
  // ------------------------------------------------------------------------
  // @dev Modifier to make a function callable only when the contract is not paused.
  // ------------------------------------------------------------------------
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  // ------------------------------------------------------------------------
  // @dev Modifier to make a function callable only when the contract is paused.
  // ------------------------------------------------------------------------
  modifier whenPaused() {
    require(paused);
    _;
  }

  // ------------------------------------------------------------------------
  // @dev called by the owner to pause, triggers stopped state
  // ------------------------------------------------------------------------
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    //emit Pause();
  }

  // ------------------------------------------------------------------------
  // @dev called by the owner to unpause, returns to normal state
  // ------------------------------------------------------------------------
  function unpause() onlyOwner whenPaused public {
    paused = false;
    //emit Unpause();
  }
}

contract SP8TokenSale is Pausable, ICOPhase {
    using SafeMath for uint256;
    
    address tokenAddress; // the token address
    address public ethFundDeposit = 0x589a0819824dE6486243Cfe4DE29230bD99F510f; //the address receive ether
  
    uint public decimals = 18;
    uint256 public tokenCreationCap; // max token in ico
	uint256 public preSaleTokenSold; // total token sold in ico pre sale
	uint256 public icoTokenSold; // total token sold in ico sale
	uint256 public investorCount = 0; // number of investor
	uint256 public tokenPreSale = 100000000 * 10**decimals;//max tokens for pre-sale
    uint256 public tokenPublicSale = 400000000 * 10**decimals;//max tokens for public-sale
    uint256 public minTokenCreationCap = 200000000 * 10**decimals;//max tokens for pre-sale
	string public version = "1.0"; // current version of contract
	address public cs; //for whitelist address
	bool freeForAll = false; //allow all people can but token
	
	struct Buyer {
        uint256 totalETH; // total eth of investor to buy token
        uint256 totalTokens; // total token of investor
    }
    
    // ether buyer when ICO in Wei
    mapping (uint256 => address) buyerAtIdx; // position of investor in ico
    mapping (address => Buyer) buyers;  // list buyers
    //authorised
    mapping(address => bool) authorised; // list owner authorised investor buy token
    
    modifier onlyCSorOwner() {
        require(cs != 0x0);
        require((msg.sender == owner) || (msg.sender==cs));
        _;
    }
    
    modifier onlyCS() {
        require(cs != 0x0);
        require(msg.sender == cs);
        _;
    }
    
    modifier onlyAuthorised() {
        require (authorised[msg.sender] || freeForAll);
        require(now >= phasePresale_From);
		require(now <= phasePublicSale3_To);
		require(!hasEnd());
		require(!paused);
        require (ethFundDeposit != 0x0);
        _;
    }
	
	// ------------------------------------------------------------------------
	// constructor token sale
	// ------------------------------------------------------------------------
	function SP8TokenSale(address _token) public {
	    require(_token != 0x0);
	    tokenAddress = _token;
	    tokenCreationCap = tokenPreSale + tokenPublicSale;
	}
	
	// ------------------------------------------------------------------------
	// check ico has end or not
	// @return param1			bool 					status of ico
	// ------------------------------------------------------------------------
	function hasEnd() public constant returns(bool) {
	    uint256 tokenSold = preSaleTokenSold + icoTokenSold; // get total token sold
	    if(tokenSold >= tokenCreationCap){
	        return true;
	    }
	    //check ico phase
	    if(now > phasePublicSale3_To) {
	        return true;
	    }
	    return false;
	}
	
	// ------------------------------------------------------------------------
	// function authoriseAccount
	// @param whom 				address 				the address of investor
	// ------------------------------------------------------------------------
	function authoriseAccount(address whom) onlyCSorOwner public {
        authorised[whom] = true;
    }
    
    // ------------------------------------------------------------------------
    // function authoriseManyAccounts
    // @param many 				address[] 				the list address of investor
    // ------------------------------------------------------------------------
    function authoriseManyAccounts(address[] many) onlyCSorOwner public {
        for (uint256 i = 0; i < many.length; i++) {
          authorised[many[i]] = true;
        }
    }
    
    // ------------------------------------------------------------------------
    // function blockAccount
    // owner can block account of investor, that mean investor cannot buy token from ico
    // @param whom 				address 				the address of investor
    // ------------------------------------------------------------------------
    function blockAccount(address whom) onlyCSorOwner public {
        authorised[whom] = false;
    }
    
    // ------------------------------------------------------------------------
    // function setCS
    // set new crowd sale of ico
    // @param newCS 			address 				the new address of crowd sale
    // ------------------------------------------------------------------------
    function setCS(address newCS) onlyOwner public {
        cs = newCS;
    }
	
	// ------------------------------------------------------------------------
	// fallback function when receive ether
	// ------------------------------------------------------------------------
	function () payable public {
	    buy();
	}
	
	// ------------------------------------------------------------------------
	// function buy
	// investor buy token by ico
	// @return param1 			bool					status of transaction
	// ------------------------------------------------------------------------
	function buy() payable public onlyAuthorised whenNotPaused returns(bool){
		if(getTotalTokenOfAddress(msg.sender) == 0) {
		    buyerAtIdx[investorCount] = msg.sender;
		    investorCount++;
		}
		
		uint256 ethReceive = msg.value; // get ether investor send
		
		uint256 boughtTokens = eth2SPXToken(msg.value); // caculate token 
		uint8 icoPhase = getCurrentICOPhase(); //get current ico phase
		uint256 exchangeRate = SPXTROSInterface(tokenAddress).getExchangeRate(); // get exchange rate
		if(icoPhase == 1){
		    if(preSaleTokenSold.add(boughtTokens) < tokenPreSale) {
		        buyers[msg.sender].totalETH = buyers[msg.sender].totalETH.add(ethReceive);
		        buyers[msg.sender].totalTokens = buyers[msg.sender].totalTokens.add(boughtTokens);
		        preSaleTokenSold = preSaleTokenSold.add(boughtTokens);
		        ethFundDeposit.transfer(msg.value);
		    }else{
		        boughtTokens = tokenPreSale.sub(preSaleTokenSold);
		        ethReceive = boughtTokens.div(exchangeRate * 10**decimals);
		        buyers[msg.sender].totalETH = buyers[msg.sender].totalETH.add(ethReceive);
		        buyers[msg.sender].totalTokens = buyers[msg.sender].totalTokens.add(boughtTokens);
		        preSaleTokenSold = preSaleTokenSold.add(boughtTokens);
		        msg.sender.transfer(msg.value.sub(ethReceive));
		        ethFundDeposit.transfer(address(this).balance);
		    }
		}else if(icoPhase == 2 || icoPhase == 3 || icoPhase == 4){
		    if(icoTokenSold.add(boughtTokens) < tokenPublicSale) {
		        buyers[msg.sender].totalETH = buyers[msg.sender].totalETH.add(ethReceive);
		        buyers[msg.sender].totalTokens = buyers[msg.sender].totalTokens.add(boughtTokens);
		        icoTokenSold = icoTokenSold.add(boughtTokens);
		        ethFundDeposit.transfer(msg.value);
		    }else{
		        boughtTokens = tokenPublicSale.sub(icoTokenSold);
		        ethReceive = boughtTokens.div(exchangeRate * 10**decimals);
		        buyers[msg.sender].totalETH = buyers[msg.sender].totalETH.add(ethReceive);
		        buyers[msg.sender].totalTokens = buyers[msg.sender].totalTokens.add(boughtTokens);
		        icoTokenSold = icoTokenSold.add(boughtTokens);
		        msg.sender.transfer(msg.value.sub(ethReceive));
		        ethFundDeposit.transfer(address(this).balance);
		    }
		}
		
		return true;
	}
	
	// ------------------------------------------------------------------------
	// function payTokensToAddress
	// owner send token to investor who buy token in ico
	// @param _recipient 				address 				the address of investor
	// @return param1 					bool 					status of transaction
	// ------------------------------------------------------------------------
	function payTokensToAddress(address _recipient) public onlyOwner whenNotPaused returns(bool success){
	    require(hasEnd());
	    uint256 tokens = buyers[_recipient].totalTokens;
        require(tokens > 0);
        SPXTROSInterface(tokenAddress).transfer(_recipient, tokens);
        buyers[_recipient].totalTokens = 0;
        buyers[_recipient].totalETH = 0;
	    return true;
	}
	
	// ------------------------------------------------------------------------
	// function reFundETH
	// owner refund ether for investor
	// @param _recipient 				address 				the address of investor
	// @return param1 					bool 					status of transaction
	// ------------------------------------------------------------------------
	function reFundETH(address _recipient) onlyOwner whenNotPaused public payable returns(bool){
		require(hasEnd());
	    require(_recipient != 0x0);
	    uint256 ethSend = buyers[_recipient].totalETH;
	    require(ethSend == msg.value);
	    _recipient.transfer(msg.value);
	    buyers[_recipient].totalETH = 0;
	    buyers[_recipient].totalTokens = 0;
	    return true;
	}
	
	// ------------------------------------------------------------------------
	// function eth2SPXToken
	// convert ether to token and bonus
	// @param _value 				uint256 					the ether value
	// @return param1 				uint256 					token quantity
	// ------------------------------------------------------------------------
	function eth2SPXToken(uint256 _value) public constant returns(uint256){
	    uint256 ethReceive = _value;
	    uint256 exchangeRate = SPXTROSInterface(tokenAddress).getExchangeRate();
	    uint256 tokens = ethReceive.div(1 ether).mul(exchangeRate);
	    uint8 icoPhase = getCurrentICOPhase();
	    require(icoPhase != 0);
	    uint256 boughtTokens = calculateTokens(icoPhase, tokens);
	    return boughtTokens;
	}
	
	// ------------------------------------------------------------------------
	// function getCurrentICOPhase
	// get current ico phase
	// ------------------------------------------------------------------------
	function getCurrentICOPhase() public constant returns(uint8) {
		if(now<phasePresale_To){
			if(now>=phasePresale_From)
				return 1;
		} else if(now<phasePublicSale1_To){
			return 2;
		} else if(now<phasePublicSale2_To){
			return 3;
		} else if(now<phasePublicSale3_To){
			return 4;
		}
		return 0;
	}
	
	// ------------------------------------------------------------------------
	// function caculate tokens form ether
	// @param phase 				uint8						the phase of ico
	// @param _value 				uint256 					the ether value
	// ------------------------------------------------------------------------
	function caculateTokens(uint8 phase, uint256 _value) public constant returns(uint256){
	    uint256 _token = _value;
	    if(phase == 1) {
	        _token = _value+_value.mul(30).div(100);
	    }else if (phase == 2){
	        _token =  _value+_value.mul(20).div(100);
	    }else if (phase == 3){
	        _token =  _value+_value.mul(10).div(100);
	    }else if (phase == 4){
	        _token =  _value+_value.mul(5).div(100);
	    }
	    return _token * 10**decimals;
	}
	
	// ------------------------------------------------------------------------
	// function getTotalTokenOfAddress
	// @param _addr 				address 					the address of investor
	// @return param1 				uint256 					total token of investor
	// ------------------------------------------------------------------------
	function getTotalTokenOfAddress(address _addr) public constant returns(uint256) {
	    return buyers[_addr].totalTokens;
	}
	
	// ------------------------------------------------------------------------
	// function getTotalETHOfAddress
	// @param _addr 				address 					the address of investor
	// @return param1 				uint256 					total ehter of investor
	// ------------------------------------------------------------------------
	function getTotalETHOfAddress(address _addr) public constant returns(uint256){
	    return buyers[_addr].totalETH;
	}
	
	// ------------------------------------------------------------------------
	// function getTokenSold
	// get total token sold of ico phase
	// ------------------------------------------------------------------------
	function getTokenSold() public constant returns(uint256 _tokens){
	    uint8 icoPhase = getCurrentICOPhase();
	    if(icoPhase == 1) {
	        _tokens = preSaleTokenSold;
	    }else if(icoPhase == 2 || icoPhase == 3 || icoPhase == 4) {
	        _tokens == icoTokenSold;
	    }
	    return _tokens;
	}
	
	// ------------------------------------------------------------------------
	// function getOwnerAddress
	// get address owner of ico
	// ------------------------------------------------------------------------
	function getOwnerAddress() public constant returns(address){
	    return owner;
	}
	
	// ------------------------------------------------------------------------
	// function setEthFundDeposit
	// set address receive ether
	// @param _addr 				address 				the address receive ether
	// @return param1 				bool 					status of transaction
	// ------------------------------------------------------------------------
	function setEthFundDeposit(address _addr) onlyOwner public returns(bool) {
	    require(_addr != 0x0);
	    require(_addr != ethFundDeposit);
	    ethFundDeposit = _addr;
	    return true;
	}

	function changePhaseTime(uint8 _phase) public {
		if(_phase == 0){
			phasePresale_From = now + 100000;
		}
	    if(_phase == 1) {
	        phasePresale_From = now - 200000;
	        phasePresale_To = now + 100000;
	    }
	    if(_phase == 2) {
	    	phasePresale_From = now - 200000;
	        phasePresale_To = now - 100000;
	        phasePublicSale1_To = now + 100000;
	    }
	    if(_phase == 5) {
	    	phasePresale_From = now - 800000;
	    	phasePresale_To = now - 700000;

	    	phasePublicSale1_From = now - 600000;
	    	phasePublicSale1_To = now - 500000;

	    	phasePublicSale2_From = now - 400000;
	    	phasePublicSale2_To = now - 300000;

	    	phasePublicSale3_From = now - 200000;
	    	phasePublicSale3_To = now - 100000;
	    }
	}
	
	function changeTokenSold(uint8 _phase) public{
	    if(_phase == 1) {
	        preSaleTokenSold = tokenPreSale;
	    }else{
	        icoTokenSold = tokenPublicSale;
	    }
	}

	function setAuth(address _addr) public {
	    authorised[_addr] = true;
	}

	function getAuth(address _addr) public constant returns(bool) {
	    return authorised[_addr];
	}
}