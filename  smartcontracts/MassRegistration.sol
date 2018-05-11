pragma solidity ^0.4.18;

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