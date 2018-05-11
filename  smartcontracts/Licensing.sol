pragma solidity ^0.4.18;

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