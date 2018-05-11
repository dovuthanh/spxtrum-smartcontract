pragma solidity ^0.4.18;

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