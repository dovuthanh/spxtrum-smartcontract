pragma solidity ^0.4.18;
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        //emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract SPXTROSInterface{
    function totalSupply() public constant returns (uint);
    function balanceOf(address _owner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    
    //custom interface function
    function transferTokens(address _recipient, uint256 _value, uint256 _ratePerETH) public returns (bool);
    function getExchangeRate() public constant returns(uint256); 
    function tokens2Vouchers(string _txHash, bytes32 _message, bytes32 r, bytes32 s, uint8 v, uint256 _value) public returns(bool);
    function vouchers2Tokens(string _txHash, address _recipient, uint _amount) public returns(bool);
    function buy() payable public;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract BasicToken is SPXTROSInterface, Owned {
    using SafeMath for uint256;
    
    uint256 public exchangeRate = 38417; // 1 ETH = 38417 SP8
    string public symbol; // the symbol of token
    string public name; // the name of token
    uint public decimals = 18; 
    uint public totalSupply; // the total token
    address icoAddress; // the ico address

    mapping(address => uint) balances; // balance of address in token
    mapping(address => mapping(address => uint)) allowed;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function BasicToken(uint256 _initialSupply, string _name, string _symbol) public {
        symbol = _symbol;
        name = _name;
        totalSupply = _initialSupply * 10**uint(decimals);
        balances[owner] = totalSupply;
        //emit Transfer(address(0), owner, totalSupply);
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return totalSupply - balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(tokens > 0);
        require(to != 0x0);
        balances[tx.origin] = balances[tx.origin].sub(tokens);
        balances[to] = balances[to].add(tokens);
        //emit Transfer(tx.origin, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        //emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) internal returns (bool success) {
        require(tokens > 0);
        require(balanceOf(from) > tokens);
        balances[from] = balances[from].sub(tokens);
        // allowed[from][tx.origin] = allowed[from][tx.origin].sub(tokens);
        balances[to] = balances[to].add(tokens);
        //emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[tx.origin][spender] = tokens;
        //emit Approval(tx.origin, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(tx.origin, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return SPXTROSInterface(tokenAddress).transfer(owner, tokens);
    }
}

contract SP8Token is BasicToken{
    string public version = "1.0"; // current version of contract
    
    struct Voucher{
        address vBuyer; // the address of buyer voucher
        uint vAmount; // the value have to pay
    }

    mapping(string => Voucher) vouchers; // list history of voucher
    
    function SP8Token(
        uint256 _initialSupply, 
        string _name, 
        string _symbol
        ) BasicToken(_initialSupply, _name, _symbol) public{}
    
    function transferTokens(address _recipient, uint256 _value, uint256 _ratePerETH) public returns (bool) {
        // require(msg.sender == icoAddress);
        uint256 finalAmount = _value.mul(_ratePerETH);
        transfer(_recipient, finalAmount);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // @notice Buy tokens from contract by sending ether
    // function buy()
    // call if someone want to buy token (must to pay with ether)
    // ------------------------------------------------------------------------
    function buy() payable public {
        require(exchangeRate > 0);
        require(tx.origin != 0x0);
        require(msg.value != 0);
        uint toEther = msg.value.div(1 ether);
        uint amount = toEther.mul(exchangeRate*10**decimals);               // calculates the amount
        owner.transfer(msg.value); // owner of contract receive ether
        balances[owner] = balances[owner].sub(amount);
        balances[tx.origin] = balances[tx.origin].add(amount);
    }
    
    // ------------------------------------------------------------------------
    // Fallback function when receiving Ether.
    // ------------------------------------------------------------------------
    function() payable public{
        buy();
    }
    
    // ------------------------------------------------------------------------
    // function tokens2Vouchers
    // use token to buy vouchers.
    // owner will give token and refund voucher for investor
    // @param _txtHash          string                  the hash of transaction
    // @param _message          bytes32                 the message buyer signature
    // @param r,s,v                                     the signatures of transaction
    // @param _value            uint256                 the value need to pay
    // @return param1           bool                    status of transaction
    // ------------------------------------------------------------------------
    function tokens2Vouchers(string _txHash, bytes32 _message, bytes32 r, bytes32 s, uint8 v, uint256 _value) public returns(bool) {
        Voucher memory _voucher = vouchers[_txHash];
        require(_voucher.vBuyer == 0x0);
        address _recipient = ecrecover(_message, v, r, s);
        require(tx.origin == owner);
        require(_value > 0);
        uint256 _finalValue = _value;
        require(balanceOf(_recipient) > _finalValue);
        balances[_recipient] -= _finalValue;
        balances[owner] += _finalValue; //owner receive token from sender
        vouchers[_txHash] = Voucher(_recipient, _finalValue); // save transaction history
        return true;
    }
    
    // ------------------------------------------------------------------------
    // function vouchers2Token
    // call if owner refund token for investor
    // @param _txtHash          string                  the hash of transaction
    // @param _recepient        address                 the address receive token
    // @param _amount           uint256                 the token need to refund
    // @return param1           bool                    status of transaction
    // ------------------------------------------------------------------------
    function vouchers2Tokens(string _txHash, address _recipient, uint256 _amount) onlyOwner public returns(bool) {
        require(_recipient != 0x0);
        require(_amount >= 0);
        require(tx.origin == owner);
        Voucher storage voucher = vouchers[_txHash];
        require(_recipient == voucher.vBuyer);
        require(voucher.vAmount - _amount >= 0);
        voucher.vAmount -= _amount;
        balances[owner] -= _amount; // owner send token to receiver
        balances[_recipient] += _amount; // recipient receive token
        return true;
    }
    
    /// @notice owner can change this address
    /// @param _icoAddress new ico contract
    function setIcoAddress(address _icoAddress) onlyOwner public returns(bool){
        require(_icoAddress != 0x0);
        icoAddress = _icoAddress;
        return true;
    }
    
    /// @notice onlyOwner can get ico address
    function getIcoAddress() external constant returns(address)  {
        if(tx.origin != owner){
            return 0x0;
        }
        return icoAddress;
    }
    
    // ------------------------------------------------------------------------
    // function setExchangeRate
    // use when owner want to set new exchange rate for token
    // only owner can call function
    // @param _newExchangeRate          uint256             the new exchange rate of token
    // @return param1                   bool                status of transaction
    // ------------------------------------------------------------------------
    function setExchangeRate(uint256 _newExchangeRate) onlyOwner public returns(bool){
        require(_newExchangeRate > 0);
        exchangeRate = _newExchangeRate;
    }
    
    // ------------------------------------------------------------------------
    // function getExchangeRate
    // return the current exchange rate of token
    // @return param1                   uint256             the current exchange rate
    // ------------------------------------------------------------------------
    function getExchangeRate() public constant returns(uint256) {
        return exchangeRate;
    }
}

