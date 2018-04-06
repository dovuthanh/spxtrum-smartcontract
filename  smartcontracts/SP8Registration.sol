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

contract SongRecordingRegistration is BaseRegistration{
    uint constant MAX_ROYALTY = 5;
    
    uint totalPercent = 0; //total percent of song 
    uint countRoyaltyPartner; // current number of royalty partners
    address addressDispute; // address dispute
    string public version = "1.0"; // current version of contract
    
    // ------------------------------------------------------------------------
    // @param percent                uint                Percent of royalty partners
    // @param confirmed              bool                royalty partners confirmed or not confirmed
    // @param exists                 bool                royalty partner already exists
    // ------------------------------------------------------------------------
    struct RoyaltyPartner{
        uint percent;
        bool confirmed;
        bool exists;
    }
    
    mapping(uint => address) royaltyIndex; // index of royalty partner in mapping
    mapping(address => RoyaltyPartner) royaltyPartners;
    mapping(address => uint256) tempRoyaltyPercent; // when change royalty, it should be add to temp first
    
    //contructor MusicRegistration and upto 5 Royalty partners
    // ------------------------------------------------------------------------
    // @param _hash                      string              The hash of song
    // @param _digital                   string              The digital signatures
    // @param _addrDispute               address             The address dispute
    // @param _dateOfPublish             string              Date publish song registration
    // @param _professionalName          string              The name of artist
    // @param _arrRoyaltyPercent         uint                Array of royalty partners percent
    // @param _arrRoyaltyAddress         address             Array of royalty partners address
    // ------------------------------------------------------------------------
    function  SongRecordingRegistration(
        address _owner,
        string _songTitle,
        string _hash,
        string _digital,
        address _addrDispute,
        string _dateOfPublish,
        string _professionalName,
        string _duration,
        uint[] _arrRoyaltyPercent,
        address[] _arrRoyaltyAddress) onlyDeployer public{
        owner = _owner;
        songTitle = _songTitle;
        hash = _hash;
        rtype = 1;
        digitalSignature = _digital;
        dateOfPublish = _dateOfPublish;
        professionalName = _professionalName;
        duration = _duration;
        checkingDispute(_addrDispute, address(this));
        assert(_arrRoyaltyAddress.length == _arrRoyaltyPercent.length);
        assert(_arrRoyaltyPercent.length <= uint(MAX_ROYALTY));
        for (uint i = 0; i < _arrRoyaltyAddress.length; i++){
            require(_arrRoyaltyAddress[i] != owner);
            require(totalPercent <= 100);
            royaltyIndex[i] = _arrRoyaltyAddress[i];
            royaltyPartners[_arrRoyaltyAddress[i]] = RoyaltyPartner(_arrRoyaltyPercent[i], false, true);
            totalPercent += _arrRoyaltyPercent[i];
            countRoyaltyPartner++;
        }
    }
    
    // get song registration
    // ------------------------------------------------------------------------
    // @return param1                address             The address of the song owner
    // @return param2                string              The hash of song
    // @return param3                string              The digital signatures
    // @return param4                uint                The type of registration: 1 is song registration, 2 is work registration
    // @return param5                string              The name of artist
    // @return param6                address[5]          Array address of royalty partners
    // @return param7                uint[5]             Array percent of royalty partners
    // ------------------------------------------------------------------------
    function getRegistration() public view returns(string _songTitle, address _owner, string _hash, string _digital, uint _type, string _professionalName, string _duration, address[5] _arrRoyaltyAddress, uint[5] _arrRoyaltyPercent){
        _owner = owner;
        _songTitle = songTitle;
        _hash = hash;
        _digital = digitalSignature;
        _type = rtype;
        _duration = duration;
        _professionalName = professionalName;
        for (uint i=0; i<5; i++){
            _arrRoyaltyAddress[i] = royaltyIndex[i];
            _arrRoyaltyPercent[i] = royaltyPartners[_arrRoyaltyAddress[i]].percent;
        }
        return (_songTitle, _owner, _hash, _digital, _type, _professionalName, _duration, _arrRoyaltyAddress, _arrRoyaltyPercent);
    }
    
    //royalty partner change percent
    // ------------------------------------------------------------------------
    // @param _addrRoyaltyAddress    address             The address of the royalty partner
    // @param _percent               uint256             The new percent of royalty partner
    // @return param1                bool                return true if add change success
    // ------------------------------------------------------------------------
    function royaltyChangePercent(address _addrRoyaltyAddress, uint256 _percent) onlyDeployer public returns(bool){
        require(_addrRoyaltyAddress != 0x0);
        require(_percent > 0);
        tempRoyaltyPercent[_addrRoyaltyAddress] = _percent;
        return true;
    }
    
    //royalty partner confirmed
    // after owner change royalty partner percent, royalty partner can accept or deny
    // ------------------------------------------------------------------------
    // @param message         byte32             The message confirmed royalty partner
    // @param r               byte32             The digital signature
    // @param s               byte32             The digital signature
    // @param v               uint8              The digital signature
    // @param _confirmed       bool               royalty partner accept or deny
    // @return param1         bool               return true if acction success
    // ------------------------------------------------------------------------
    function royaltyConfirmed(bytes32 message, bytes32 r, bytes32 s, uint8 v, bool _confirmed) onlyDeployer public returns(bool) {
        address _addrRoyalty = ecrecover(message, v, r, s);
        uint256 _percent = tempRoyaltyPercent[_addrRoyalty];
        require(_percent != 0);
        require(totalPercent.add(_percent) <= 100);
        if(_confirmed) {
            bool exists = getRoyaltyExists(_addrRoyalty);
            if(!exists){
                royaltyIndex[countRoyaltyPartner] = _addrRoyalty;
                countRoyaltyPartner++;
            }
            uint256 _curPercent = royaltyPartners[_addrRoyalty].percent;
            royaltyPartners[_addrRoyalty].percent = _percent;
            royaltyPartners[_addrRoyalty].confirmed = true;
            totalPercent = totalPercent.sub(_curPercent).add(_percent);
        }else{
            delete tempRoyaltyPercent[_addrRoyalty];
        }
        return true;
    } 
    
    //get percent of royalty partner
    // ------------------------------------------------------------------------
    // @param _toRoyaltyPartner              address         The address of royalty partners 
    // @return param1                        uint            Percent of royalty partners
    // ------------------------------------------------------------------------
    function getRoyaltyPercent(address _toRoyaltyPartner) public constant returns(uint) {
        return royaltyPartners[_toRoyaltyPartner].percent;
    }
    
    //check royalty partner exists
    // ------------------------------------------------------------------------
    // @param _toRoyaltyPartner              address         The address of royalty partners 
    // @return param1                        bool            Royalty partners exists
    // ------------------------------------------------------------------------
    function getRoyaltyExists(address _toRoyaltyPartner) public constant returns(bool){
        return royaltyPartners[_toRoyaltyPartner].exists;
    }
    
    //get total percent of song
    // ------------------------------------------------------------------------
    // @return param1                        uint            Total percent of royalty partners
    // ------------------------------------------------------------------------
    function getTotalPercent() external constant returns(uint){
        return totalPercent;
    }
    
    // get royalty partner
    // ------------------------------------------------------------------------ 
    // @return param1                        address[5]              Array of royalty partners address
    // @return param2                        uint[5]                 Array of royalty partner percent
    // ------------------------------------------------------------------------
    function getRoyaltyPartners() public constant returns(address[5] _arrRoyaltyAddress, uint[5] _arrRoyaltyPercent){
        for (uint i = 0; i < MAX_ROYALTY; i++){
            _arrRoyaltyAddress[i] = royaltyIndex[i];
            _arrRoyaltyPercent[i] = royaltyPartners[royaltyIndex[i]].percent;
        }
        return (_arrRoyaltyAddress, _arrRoyaltyPercent);
    }
    
    //checking dispute if exists
    // ------------------------------------------------------------------------
    // @param _addrDispute               address             The address of dispute
    // @param _addrCurrent               address             The address of current
    // ------------------------------------------------------------------------
    function checkingDispute(address _addrDispute, address _addrCurrent) onlyDeployer public {
        if(_addrDispute != address(0)){
            addressDispute = _addrDispute;
            SongRecordingRegistration musicReg = SongRecordingRegistration(_addrDispute);
            assert(musicReg.getDispute() == address(0));
            musicReg.setDispute(_addrCurrent);
        }
    }
    
    //set dispute of contract address
    // ------------------------------------------------------------------------
    // @param _addrDispute              address         The address of dispute
    // ------------------------------------------------------------------------
    function setDispute(address _addrDispute) onlyDeployer public{
        addressDispute = _addrDispute;
    }
    
    //get dispute of contract address
    // ------------------------------------------------------------------------ 
    // @return param1                    address            Address of dispute
    // ------------------------------------------------------------------------
    function getDispute() public constant returns(address){
        return addressDispute;
    }
}

contract WorkRegistration is BaseRegistration{
    bool isTempRegistration = false; // work release
    string public version = "1.0"; // current version of contract
    
    // ------------------------------------------------------------------------
    // @param _hash                      string              The hash of work registration
    // @param _digital                   string              The digital of signatures
    // @param _dateOfPublish             string              Date publish work registration
    // @param _isTempRegistration        bool                Work registration release or not
    // ------------------------------------------------------------------------
    function WorkRegistration(
        address _owner,
        string _songTitle,
        string _hash,
        string _digital,
        string _dateOfPublish,
        bool _isTempRegistration) onlyDeployer public{
        owner = _owner;
        songTitle = _songTitle;
        hash = _hash;
        rtype = 2;
        digitalSignature = _digital;
        isTempRegistration = _isTempRegistration;
        dateOfPublish = _dateOfPublish;
    }
    
    //get work registration
    // ------------------------------------------------------------------------
    // @return param1                address             The address of the song owner
    // @return param2                string              The hash of song
    // @return param3                string              The digital signatures
    // @return param4                uint                The type of registration: 1 is song registration, 2 is work registration
    // @return param5                address[5]          Array address of royalty partners
    // @return param6                uint[5]             Array percent of royalty partners
    // ------------------------------------------------------------------------
    function getRegistration() public view returns(string _songTitle, address _owner, string _hash, string _digital, uint _type, string _professionalName, string, address[5], uint[5]){
        _owner = owner;
        _songTitle = songTitle;
        _hash = hash;
        _digital = digitalSignature;
        _type = rtype;
        _professionalName = "";
    }
    
    //get composer
    // ------------------------------------------------------------------------
    // @return _hash                     string              The hash of work registration
    // @return _digital                  string              The digital of signatures
    // @return _isTempRegistration       bool                Work registration release or not
    // ------------------------------------------------------------------------
    function getComposer() external constant returns(
        string _hash,
        string _digital,
        bool _isTempRegistration){
        _hash = hash;
        _digital = digitalSignature;
        _isTempRegistration = isTempRegistration;
    }
    
    //set temp registration
    // ------------------------------------------------------------------------
    // @param _isTempRegistration            bool            Work registration release or not
    // ------------------------------------------------------------------------
    function setTempRegistration(bool _isTempRegistration) onlyDeployer public{
        isTempRegistration = _isTempRegistration;
    }
}

contract MassRegistration is BaseRegistration {
    uint constant MAX_ROYALTY = 5; // max royalty partner of a song in mass
    string public version = "1.0"; // current version of contract
    
    // ------------------------------------------------------------------------
    // @param percent                uint                Percent of royalty partners
    // @param confirmed              bool                royalty partners confirmed or not confirmed
    // @param exists                 bool                royalty partner already exists
    // ------------------------------------------------------------------------
    struct RoyaltyPartner{
        address royaltyAddess;
        uint percent;
        bool confirmed;
        bool exists;
    }
    
    mapping(string => uint) royaltyTotalPercents; // total percent of royalty in a song
    mapping(string => RoyaltyPartner[]) royaltyPartners; // list royalty partners in the song
    mapping(string => mapping(address => uint256)) tempRoyaltyPercents; // when change royalty, it should be add to temp first
    
    //contructor MusicRegistration and upto 5 Royalty partners
    // ------------------------------------------------------------------------
    // @param _owner                     address             The address of mass
    // @param _hash                      string              The hash of mass
    // @param _digital                   string              The digital signatures
    // ------------------------------------------------------------------------
    function  MassRegistration(
        address _owner,
        string _hash,
        string _digital) onlyDeployer public{
        owner = _owner;
        hash = _hash;
        rtype = 3;
        digitalSignature = _digital;
    }
    
    // get song registration
    // ------------------------------------------------------------------------
    // @return param1                address             The address of the song owner
    // @return param2                string              The hash of song
    // @return param3                string              The digital signatures
    // @return param4                uint                The type of registration: 1 is song registration, 2 is work registration
    // @return param5                string              The name of artist
    // @return param6                address[5]          Array address of royalty partners
    // @return param7                uint[5]             Array percent of royalty partners
    // ------------------------------------------------------------------------
    function getRegistration(string _hashOfSong) public view returns(string _songTitle, address _owner, string _hash, string _digital, uint _type, string _professionalName, string _duration, address[5] _arrRoyaltyAddress, uint[5] _arrRoyaltyPercent){
        _owner = owner;
        _songTitle = '';
        _hash = hash;
        _digital = digitalSignature;
        _type = rtype;
        _duration = '';
        _professionalName = '';
        for (uint i=0; i<royaltyPartners[_hashOfSong].length; i++){
            _arrRoyaltyAddress[i] = royaltyPartners[_hashOfSong][i].royaltyAddess;
            _arrRoyaltyPercent[i] = royaltyPartners[_hashOfSong][i].percent;
        }
        return (_songTitle, _owner, _hash, _digital, _type, _professionalName, _duration, _arrRoyaltyAddress, _arrRoyaltyPercent);
    }
    
    //get percent of royalty partner
    // ------------------------------------------------------------------------
    // @param _toRoyaltyPartner              address         The address of royalty partners 
    // @return param1                        uint            Percent of royalty partners
    // ------------------------------------------------------------------------
    function getRoyaltyPercent(string _hashOfSong, uint8 idx) public constant returns(uint) {
        require(royaltyPartners[_hashOfSong].length <= idx.add(1));
        return royaltyPartners[_hashOfSong][idx].percent;
    }
    
    //check royalty partner exists
    // ------------------------------------------------------------------------
    // @param _toRoyaltyPartner              address         The address of royalty partners 
    // @return param1                        bool            Royalty partners exists
    // ------------------------------------------------------------------------
    function getRoyaltyExists(string _hashOfSong, address _toRoyaltyPartner) public constant returns(bool, uint){
        for(uint i=0; i<royaltyPartners[_hashOfSong].length; i++){
            if(royaltyPartners[_hashOfSong][i].royaltyAddess == _toRoyaltyPartner){
                return (royaltyPartners[_hashOfSong][i].exists, i);
                break;
            }
        }
        return (false,0);
    }
    
    //get total percent of song
    // ------------------------------------------------------------------------
    // @return param1                        uint            Total percent of royalty partners
    // ------------------------------------------------------------------------
    function getTotalPercent(string hashOfSong) external constant returns(uint){
        return royaltyTotalPercents[hashOfSong];
    }
    
    // get royalty partner
    // ------------------------------------------------------------------------
    // @return param1                        address[5]              Array of royalty partners address
    // @return param2                        uint[5]                 Array of royalty partner percent
    // ------------------------------------------------------------------------
    function getRoyaltyPartners(string _hashOfSong) public constant returns(address[5] _arrRoyaltyAddress, uint[5] _arrRoyaltyPercent){
        for (uint i = 0; i < [_hashOfSong].length; i++){
            _arrRoyaltyAddress[i] = royaltyPartners[_hashOfSong][i].royaltyAddess;
            _arrRoyaltyPercent[i] = royaltyPartners[_hashOfSong][i].percent;
        }
        return (_arrRoyaltyAddress, _arrRoyaltyPercent);
    }
    
    //royalty partner change percent
    // ------------------------------------------------------------------------
    // @param _hashOfSong            string              The hash of song
    // @param _addrRoyaltyAddress    address             The address of the royalty partner
    // @param _percent               uint256             The new percent of royalty partner
    // @return param1                bool                return true if add change success
    // ------------------------------------------------------------------------
    function royaltyChangePercent(string _hashOfSong, address _addrRoyaltyAddress, uint256 _percent) onlyDeployer public returns(bool){
        require(_addrRoyaltyAddress != 0x0);
        require(_percent > 0);
        tempRoyaltyPercents[_hashOfSong][_addrRoyaltyAddress] = _percent;
        return true;
    }
    
    //royalty partner confirmed
    // after owner change royalty partner percent, royalty partner can accept or deny
    // ------------------------------------------------------------------------
    // @param _hashOfSong     string             The hash of song
    // @param message         byte32             The message confirmed royalty partner
    // @param r               byte32             The digital signature
    // @param s               byte32             The digital signature
    // @param v               uint8              The digital signature
    // @param _confirmed       bool               royalty partner accept or deny
    // @return param1         bool               return true if acction success
    // ------------------------------------------------------------------------
    function royaltyConfirmed(string _hashOfSong, bytes32 message, bytes32 r, bytes32 s, uint8 v, bool _confirmed) onlyDeployer public returns(bool) {
        address _addrRoyalty = ecrecover(message, v, r, s);
        uint256 _percent = tempRoyaltyPercents[_hashOfSong][_addrRoyalty];
        require(_percent != 0);
        uint256 _totalPercent = royaltyTotalPercents[_hashOfSong];
        require(_totalPercent.add(_percent) <= 100);
        if(_confirmed) {
            bool exists; uint256 idx;
            (exists,idx) = getRoyaltyExists(_hashOfSong, _addrRoyalty);
            if(!exists) {
                require(royaltyPartners[_hashOfSong].length != MAX_ROYALTY);
            }
            uint256 _curPercent = royaltyPartners[_hashOfSong][idx].percent;
            royaltyPartners[_hashOfSong][idx].royaltyAddess = _addrRoyalty;
            royaltyPartners[_hashOfSong][idx].percent = _percent;
            royaltyPartners[_hashOfSong][idx].confirmed = true;
            royaltyTotalPercents[_hashOfSong] = _totalPercent.sub(_curPercent).add(_percent);
        }else{
            delete tempRoyaltyPercents[_hashOfSong][_addrRoyalty];
        }
        return true;
    }
}

contract Licensing {
    string public version = "1.0";
    address deployer = address(0xF7cC551106A1f4E2843A3DA0C477B6f77FA4a09d);
    //3 kind of licens status
    enum licensedState { Pending, Expired , Licensed }
    
    // Default Expired date will be 30 days
    //unit is second
    uint constant ExpiryTime = 30*24*60*60; 
    
    address  token; // address of scpetrum 8 token
    address  buyAddress; // address of buyer
    address  songAddress; // song contract address
    string  territority; // the territority of license
    string  right; // kind of right license
    uint  period; // time of license. Unit is months
    uint256 dateIssue; // start time will be the time we create contract.
    bool  isCompleted; // licensing completed or not
    uint price; // price of licensing
    string hashOfLicense; //hash of licensing
    
    modifier onlyDeployer() {
        require(msg.sender == buyAddress);
        _;
    }
    
    modifier onlyOwnerOfSong(){
        SongRecordingRegistration musicContract = SongRecordingRegistration(songAddress);
        require(msg.sender == musicContract.getOwnerAddress());
        _;
    }
    
    // ------------------------------------------------------------------------
    // @param _token                         address                 The address of token
    // @param addressOfSong                  address                 The address of song
    // @param territorityOfLicense           string                  The territority of license
    // @param rightOfLicense                 string                  The right of license
    // @param periodOfLicense                uint                    The period of license
    // ------------------------------------------------------------------------
    function Licensing(
        address _buyerAddress,
        address _token,
        address addressOfSong, 
        string territorityOfLicense, 
        string rightOfLicense, 
        uint periodOfLicense,
        string _hashOfLicense) onlyDeployer public{
        buyAddress = _buyerAddress;
        songAddress = addressOfSong;
        territority = territorityOfLicense;
        right = rightOfLicense;
        period = periodOfLicense;
        hashOfLicense = _hashOfLicense;
        isCompleted = false;
        dateIssue = block.timestamp;
        token = _token;
    }

    //get status of license - this is private function
    // ------------------------------------------------------------------------
    // @return param1                licensedState             The state of license
    // ------------------------------------------------------------------------
    function getStatus() constant private returns (licensedState){
        if(isCompleted == true){
            return licensedState.Licensed;
        }else {
            if(block.timestamp >  (dateIssue + ExpiryTime)){
                return licensedState.Expired;
            }else{
                return licensedState.Pending;
            }
        }
    }
    
    //get current license status, before
    // ------------------------------------------------------------------------
    // @return param1                string             The state string of license
    // ------------------------------------------------------------------------
    function getContractStatus() constant public returns (string){
        licensedState currentState = getStatus();
        if(currentState == licensedState.Pending){
            return "Pending";
        }else if(currentState == licensedState.Expired){
            return "Expired";
        }else {
            return "Licensed";
        }
    }
    
    //Copyright Owner will update price of license when someone issue it,
    // it must be completed in 30 days from issue date
    // ------------------------------------------------------------------------
    // @param priceOfLicense             uint                The new price of license 
    // ------------------------------------------------------------------------
    function updatePrice(uint priceOfLicense) onlyDeployer public{
        //find song with address
        assert(!isCompleted);
        //validate song address by checking publishPerson
        assert (priceOfLicense > 0);
        assert (block.timestamp <  (dateIssue + ExpiryTime));
        
        //update license price
        price = priceOfLicense;
    }
    
    //get current contract address
    // ------------------------------------------------------------------------
    // @return param1                address             The address of the contract
    // ------------------------------------------------------------------------
    function getContractAddress() external constant returns (address){
        return this;
    }
    
    //get owner of address
    // ------------------------------------------------------------------------
    // @return param1                address             The address of the owner
    // ------------------------------------------------------------------------
    function getOwnerAddress() external constant returns(address){
        return(buyAddress);
    }
    
    //fund license after owner updated price
    // ------------------------------------------------------------------------
    // @param _price                        uint256             The price have to fund
    // @return param1                       bool                the status of transaction
    // ------------------------------------------------------------------------
    function fundLicense(uint256 _price) public returns(bool){
       require(msg.sender == buyAddress);
       require(price > 0);
       require(_price == price);
       //get song owner
       SongRecordingRegistration musicContract = SongRecordingRegistration(songAddress);
       //pay token for song of owner.
       //bool success = SPXTROSInterface(token).fund(musicContract.getOwnerAddress(), _price);
       //if(success) isCompleted = true;
    }
   
    
    //check price of license
    // ------------------------------------------------------------------------
    // @param _price                 uint256                 The price want to check 
    // @return param1                bool                    return true if _price > price of license
    // ------------------------------------------------------------------------
    function checkPrice(uint256 _price) public constant returns(bool){
        require(msg.sender == token);
        return (_price >= price) ? true : false;
    }
}