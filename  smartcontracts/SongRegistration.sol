pragma solidity ^0.4.18;

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