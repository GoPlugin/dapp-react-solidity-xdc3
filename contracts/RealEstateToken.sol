// SPDX-License-Identifier: MI
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@goplugin/contracts/src/v0.8/PluginClient.sol";

//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

// add status of property - not rented, rented, for sale
// allow for shared property, multiple tenants, remove selected tenant based on index
// 3. put for sale
// 4. buy nft
// 5. burn the token at end of sale

contract RealEstateToken is PluginClient,ERC20, Ownable, ERC721Holder {
    using SafeMath for uint256;
    // using Plugin for Plugin.Request;

    address[] public stakeholders;

    mapping(address => uint256) public revenues;

    // status, can change to enum
    uint public status;
    // 0-> unrented
    // 1-> rented
    // 2 -> for sale

    uint256 public tokenPrice;
    uint256 public accumulated;
    // uint256 public rent;
    mapping(address => uint) rent;
    address[] public tenantAddresses;

    IERC721 public collection;
    uint256 public tokenId;
    bool public initialized = false;

    struct sellStake {
        address sellerAddress;
        address buyerAddress;
        uint sellValue;
    }
    // buyer address to struct
    mapping(address => sellStake) sellRequest;

    constructor(address _ownerr, string memory name_, string memory symbol_, address _pli) ERC20(name_, symbol_)
    {   
        setPluginToken(_pli);
        stakeholders.push(_ownerr);
        // _mint(_owner, _supply);
    }

    // rent not in initialization, depends on tenant
    // function initialize(address _collection, uint256 _tokenId, uint256 _amount, uint256 _tokenPrice, uint256 _rent ) external onlyOwner {
    function initialize(address _collection, uint256 _tokenId, uint256 _amount, uint256 _tokenPrice) external onlyOwner {
        require(!initialized, "Already initialized");
        require(_amount > 0, "Amount needs to be more than 0");
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenId = _tokenId;
        initialized = true;
        tokenPrice = _tokenPrice;
        // rent = _rent*10**18;
        status = 0; // unrented
        _mint(msg.sender, _amount);
    }

    function addStakeholder(address _stakeholder)
        public
        onlyOwner
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) stakeholders.push(_stakeholder);
    }

    function removeStakeholder(address _stakeholder)
        public
        onlyOwner
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    // helper function to check Stakeholder
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function buy()
        public
        payable
        returns(bool)
    {
        uint256 money = msg.value;

        // stakeholders[0] is owner
        (bool sent, ) = stakeholders[0].call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        
        // owner transfers tokens
        _transfer(stakeholders[0], msg.sender, money/(tokenPrice*10**18));
        
        // if sender is not a stakeholder, add him
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        if (!_isStakeholder) stakeholders.push(msg.sender);
        return true;
    }

    function sellStakeRequest(address _buyer, uint _sellValue) public {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        require(_isStakeholder == true, "requester is not a stakeholder");

        // require >0 sellValue
        require(_sellValue > 0, "sellValue cannot be 0");

        sellRequest[_buyer] = sellStake(msg.sender, _buyer, _sellValue);
    }

    function buyStake() public payable {
        
        sellStake memory request = sellRequest[msg.sender];
        // check if request there
        require(request.sellValue != 0, "No stake sell request for this stake buyer");

        // if amount same
        require(msg.value == request.sellValue, "Invalid value for this request");

        // transfer tokens
        _transfer(request.sellerAddress, msg.sender, balanceOf(request.sellerAddress)); 

        // add new stakeholder, remove old stakeholder
        // incorrect, only owner can add/remove stakeholder
        addStakeholder(msg.sender);
        removeStakeholder(request.sellerAddress);
    }

    // only owner can rent out the estate
    function rentToTenant(address _tenantAddress, uint _rent) 
        public 
        onlyOwner
        returns(bool)
    {
        tenantAddresses.push(_tenantAddress);
        rent[_tenantAddress] = _rent*10**18; // rent in ether

        // change status to rented
        status = 1;
        return true;
    }

    // only tenant can pay the rent
    function rentPayment()
        public payable
    {
        uint256 money = msg.value;
        
        // check for isTenant
        bool isTenant = false;
        for(uint i = 0; i< tenantAddresses.length; i++){
            if(msg.sender == tenantAddresses[i]){
                isTenant = true;
            }
        }
        require(isTenant==true, "Only Tenant can pay rent");

        // check for exact rent
        // require(money==rent/tenantAddresses.length, "Send Exact Rent");
        require(money == rent[msg.sender], "Send Exact Rent");

        accumulated+=money;
    }

// FIXXX
    // // when 0 tenants, change status to unrented
    // function removeTenant(address _tenantAddress)
    //     public
    //     onlyOwner
    // {
    //     require(tenantAddresses[0]!=address(0));
    //     tenantAddress=address(0);
    // }

    // RENT IS DISTRIBUTED IN THE END
    function distribute()
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 revenue = address(this).balance * balanceOf(stakeholder) / totalSupply(); 
            accumulated = accumulated.sub(revenue);
            revenues[stakeholder] = revenues[stakeholder].add(revenue);
        }
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 revenue = revenues[stakeholder];
            revenues[stakeholder] = 0;
            payable(stakeholder).transfer(revenue);
        }
    }

    // function deposit()
    //     external
    //     payable
    // {
    //     accumulated += msg.value;
    // }

    // function withdrawStake()
    //     public
    // {
    //     uint256 index;
    //     for (uint256 s = 0; s < stakeholders.length; s += 1){
    //         if(stakeholders[s]==msg.sender){
    //             index = s;
    //         }
    //     }
    //     // payout(stakeholders[index])
    //     _transfer(msg.sender, stakeholders[0], balanceOf(stakeholders[index]));
    // }

    // function getShare(address _stakeholder)
    //     public
    //     view
    //     returns(uint256)
    // {
    //     return balanceOf(_stakeholder) / totalSupply();
    // }

}