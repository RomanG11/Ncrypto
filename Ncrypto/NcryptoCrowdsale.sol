/*
the contract will be amended and updated. This is not the final version.
 It is intended more to familiarize with the structure of the contract.
 */
pragma solidity ^0.4.19;
library SafeMath { //standart library for uint
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0){
        return 0;
    }
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable { //standart contract to identify owner

  address public owner;

  address public newOwner;

  address public techSupport;

  address public newTechSupport;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyTechSupport() {
    require(msg.sender == techSupport);
    _;
  }

  function Ownable() public {
    owner = msg.sender;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      owner = newOwner;
    }
  }

  function transferTechSupport (address _newSupport) public{
    require (msg.sender == owner || msg.sender == techSupport);
    newTechSupport = _newSupport;
  }

  function acceptSupport() public{
    if(msg.sender == newTechSupport){
      techSupport = newTechSupport;
    }
  }
}

contract NCRYPTOToken{
  function sendTokens(address, uint256)  public;
  function setCrowdsaleContract (address) public;
  function totalSupply() public constant returns (uint256);
  function balanceOf(address) public constant returns (uint256);

}

contract Crowdsale is Ownable{

  using SafeMath for uint;

  function pow(uint256 a, uint256 b) internal pure returns (uint256){ //power function
   return (a**b);
  }

  uint decimals = 2;
  // Token contract address
  NCRYPTOToken public token;

  // Constructor
  function Crowdsale(address _tokenAddress ,address[5] addresses) public{
    token = NCRYPTOToken(_tokenAddress);
    //will be changed
    owner = msg.sender;
    techSupport = msg.sender;

    token.setCrowdsaleContract(this);

    distribution1 = addresses[0];
    distribution2 = addresses[1];

    bountyAccount = addresses[2];
    projectTeam = addresses[3];
    advisors = addresses[4];
  }

  uint ethCollected;
  uint tokensSold;

  /* Destribution addresses */
  address distribution1;
  address distribution2;

  address bountyAccount;
  address projectTeam;
  address advisors;


    // Buy constants
  uint public tokenPrice = 0.0002 ether/pow(10,decimals); //idk about decimals
  uint minDeposit = 0.02 ether;

    // Ico constants
  uint public icoStart = 1523952000; //17.04.2018 1523952000
  uint public icoFinish = 1529279940; //17.06.2018

  function setIcoFinish (uint _time) public onlyOwner{
    icoFinish = _time;
  }
  

  function timeBasedBonus (uint _time) public view returns(uint) {
    if(_time <= icoStart + 15 days){
      return 100;
    }
    if(_time <= icoStart + 30 days){
      return 90;
    }
    if(_time <= icoStart + 45 days){
      return 80;
    }
    if(_time <= icoStart + 60 days){
      return 70;
    }
    if(_time <= icoStart + 75 days){
      return 60;
    }
    if(_time <= icoStart + 90 days){
      return 50;
    }
    if(_time <= icoStart + 105 days){
      return 40;
    }
    if(_time <= icoStart + 120 days){
      return 30;
    }
    if(_time <= icoStart + 135 days){
      return 20;
    }
    if(_time <= icoStart + 150 days){
      return 10;
    }
    return 0;
  }
  
  function volumeBasedBonus (uint _value) public pure returns(uint) {
    if (_value >= 1 ether && _value < 3 ether){
      return 20;
    }
    if (_value >= 3 ether && _value < 5 ether){
      return 30;
    }
    if (_value >= 5 ether){
      return 40;
    }
    return 0;
  }
  
  function () public payable {
    require (now >= icoStart && now <= icoFinish);
    require (msg.value >= minDeposit);
    require (buy(msg.sender, msg.value, now));
  }
  
  function buy (address _address, uint _value, uint _time) internal returns(bool res) {
    //21% of all Tokens Reserved for distribution
    require (tokensSold < 7900000*pow(10,decimals));
    uint bonusPercent;
    uint tokensForSend = 0;
    bonusPercent = timeBasedBonus(_time).add(volumeBasedBonus(_value));

    tokensForSend = _value.div(tokenPrice);

    tokensForSend = tokensForSend.add(tokensForSend.mul(bonusPercent).div(100));

    if(tokensSold.add(tokensForSend) > 7900000*pow(10,decimals)){
      uint allTokens = token.balanceOf(token).sub(2100000*pow(10,decimals));
      uint ethRequire = allTokens.mul(tokenPrice);

      ethCollected = ethCollected.add(ethRequire);

      tokensSold = tokensSold.add(allTokens);

      token.sendTokens(_address,allTokens);

      _address.transfer(_value.sub(ethRequire));

      distribution1.transfer(this.balance/2);
      distribution2.transfer(this.balance);

    }

    tokensSold = tokensSold.add(tokensForSend);

    ethCollected = ethCollected.add(_value);

    token.sendTokens(_address, tokensForSend);

    distribution1.transfer(this.balance/2);
    distribution2.transfer(this.balance);

    return true;
  }
  
  function tokenDistribution () public onlyOwner {
    require (icoFinish + 3 days <= now);
    uint percent3 = tokensSold.mul(3).div(100);
    uint percent15 = tokensSold.mul(15).div(100);
    token.sendTokens(bountyAccount,percent3);
    token.sendTokens(advisors,percent3);
    token.sendTokens(projectTeam,percent15);     
  }
}
