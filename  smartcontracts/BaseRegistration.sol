pragma solidity ^0.4.18;
import "./SP8Token.sol";

contract AbstractRegistration {
    //get registration contract
    function getRegistration() public view returns(string, address, string, string, uint, string, string, address[5], uint[5]);
}

contract BaseRegistration is AbstractRegistration{
    using SafeMath for *;
    address deployer = address(0xF7cC551106A1f4E2843A3DA0C477B6f77FA4a09d);
    address public owner;//address copyright Owner
    string public songTitle; //title of song
    string public hash; // has of song
    string public digitalSignature; // Owner sign his work
    string public professionalName; // name of artist;
    string public duration; //duration of song
    string dateOfPublish; //format MM/dd/yyyy
    uint rtype; // 1 is song, 2 is work, 3 is mass
    
    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }
    
    modifier onlyOwnerOfSong() {
        require(msg.sender == owner);
        _;
    }
    
    function BaseRegistration() public{
        
    }
    
    //verify digital signatures
    // ------------------------------------------------------------------------
    // @param _songOwner         address         The address of the song registration
    // @param _hashOfSong        bytes32         hash of song
    // @param r                  bytes32         r of digital signatures
    // @param s                  bytes32         s of digital signatures
    // @param v                  uint8           v of digital signatures
    // @return                   bool            return true if digital signatures successed
    // ------------------------------------------------------------------------
    function verifyDigitalSignatureOfSong(
        address _songOwner, 
        bytes32 _hashOfSong, 
        bytes32 r, 
        bytes32 s,
        uint8 v) external pure returns(bool){
        require(_songOwner != address(0));
        return ecrecover(_hashOfSong, v, r, s) == _songOwner;
    }
    
    //get copyrightOwnerName
    // ------------------------------------------------------------------------
    // @return address            The address of song owner
    // ------------------------------------------------------------------------
    function getOwnerAddress() external constant returns (address){
        return owner;
    }
    
    //change owner of song registration
    // ------------------------------------------------------------------------
    // @param _owner                address                 The address of new owner
    // ------------------------------------------------------------------------
    function changeOwnerAddress(address _owner) onlyDeployer internal {
        require(_owner != 0x0);
        require(owner != _owner);
        owner = _owner;
    }
    
    // ------------------------------------------------------------------------
    // @return param1                address             The address of the song owner
    // @return param2                string              The hash of song
    // @return param3                string              The digital signatures
    // @return param4                uint                The type of registration: 1 is song registration, 2 is work registration
    // @return param5                string              The name of artist
    // @return param6                address[5]          Array address of royalty partners
    // @return param7                uint[5]             Array percent of royalty partners
    // ------------------------------------------------------------------------
    function getRegistration() public view returns(string, address, string, string, uint, string, string, address[5], uint[5]){}
}