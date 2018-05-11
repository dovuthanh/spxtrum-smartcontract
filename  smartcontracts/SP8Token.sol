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
        emit OwnershipTransferred(owner, newOwner);
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
    function tokens2Vouchers(bytes32 _message, bytes32 r, bytes32 s, uint8 v, uint256[] _value, bytes32[] _voucherIDs) public returns(bytes32[]);
    function vouchers2Tokens(address _recipient, bytes32[] _voucherIDs) public returns(bytes32[]);
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
    string public symbol;
    string public name;
    uint public decimals = 18;
    uint public totalSupply;
    address icoAddress;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function BasicToken(uint256 _initialSupply, string _name, string _symbol) public {
        symbol = _symbol;
        name = _name;
        totalSupply = _initialSupply * 10**uint(decimals);
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
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
        emit Transfer(tx.origin, to, tokens);
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
        emit Approval(msg.sender, spender, tokens);
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
        allowed[from][tx.origin] = allowed[from][tx.origin].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
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
        emit Approval(tx.origin, spender, tokens);
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
    string public version = "1.0";
    
    struct Voucher{
        uint vAmount;
        bool vStatus;
    }
    
    mapping(address => uint256) totalTokenVouchers;
    mapping(address => mapping(bytes32 => Voucher)) vouchers;
    
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
    
    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        require(exchangeRate > 0);
        require(tx.origin != 0x0);
        require(msg.value != 0);
        uint toEther = msg.value.div(1 ether);
        uint amount = toEther.mul(exchangeRate*10**decimals);               // calculates the amount
        owner.transfer(msg.value);
        balances[owner] = balances[owner].sub(amount);
        balances[tx.origin] = balances[tx.origin].add(amount);
    }
    
    //Fallback function when receiving Ether.
    function() payable public{
        buy();
    }
    
    function tokens2Vouchers(bytes32 _message, bytes32 r, bytes32 s, uint8 v, uint256[] _value, bytes32[] _voucherIDs) public returns(bytes32[]) {
        require(_voucherIDs.length <= 100);
        require(tx.origin == owner);
        address _recipient = ecrecover(_message, v, r, s);
        require(_recipient != owner);
        require(_value.length == _voucherIDs.length);
        uint256 _finalValue = 0;
        for(uint i = 0; i < _voucherIDs.length; i++) {
            Voucher storage _voucher = vouchers[_recipient][_voucherIDs[i]];
            require(_voucher.vAmount == 0);
            _voucher.vAmount = _value[i];
            _voucher.vStatus = true;
            _finalValue = _finalValue.add(_value[i]);
        }
        require(balanceOf(_recipient) > _finalValue);
        totalTokenVouchers[_recipient] = totalTokenVouchers[_recipient].add(_finalValue);
        balances[_recipient] = balances[_recipient].sub(_finalValue);
        balances[owner] = balances[owner].add(_finalValue);
        return _voucherIDs;
    }
    
    function vouchers2Tokens(address _recipient, bytes32[] _voucherIDs) onlyOwner public returns(bytes32[]) {
        require(_voucherIDs.length <= 100);
        uint256 _total = totalTokenVouchers[_recipient];
        require(_total > 0);
        uint256 _finalValue = 0;
        for(uint i = 0; i < _voucherIDs.length; i++){
            Voucher storage _voucher = vouchers[_recipient][_voucherIDs[i]];
            require(_voucher.vStatus);
            require(_voucher.vAmount != 0);
            _finalValue = _finalValue.add(_voucher.vAmount);
        }
        balances[owner] = balances[owner].sub(_finalValue);
        balances[_recipient] = balances[_recipient].add(_finalValue);
        return _voucherIDs;
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
    
    function setExchangeRate(uint256 _newExchangeRate) onlyOwner public returns(bool){
        require(_newExchangeRate > 0);
        exchangeRate = _newExchangeRate;
    }
    
    function getExchangeRate() public constant returns(uint256) {
        return exchangeRate;
    }
}

