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

contract NCRYPTOToken is Ownable { //ERC - 20 token contract
  using SafeMath for uint;
  // Triggered when tokens are transferred.
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  // Triggered whenever approve(address _spender, uint256 _value) is called.
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  string public constant symbol = "NCR";
  string public constant name = "NCRYPTO";
  uint8 public constant decimals = 2;
  uint256 _totalSupply = 10000000*pow(10,decimals);

  // Owner of this contract
  address public owner;

  // Balances for each account
  mapping(address => uint256) balances;

  // Owner of account approves the transfer of an amount to another account
  mapping(address => mapping (address => uint256)) allowed;

  function pow(uint256 a, uint256 b) internal  pure returns (uint256){ //power function
    return (a**b);
  }

  function totalSupply() public constant returns (uint256) { //standart ERC-20 function
    return _totalSupply;
  }

  function balanceOf(address _address) public constant returns (uint256 balance) {//standart ERC-20 function
    return balances[_address];
  }

  function transfer(address _to, uint256 _amount) public returns (bool success) {//standart ERC-20 function
    require(this != _to);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(msg.sender,_to,_amount);
    return true;
  }

  address public crowdsaleContract;

  bool flag = false;
  //connect to crowdsaleContract, can be use once
  function setCrowdsaleContract (address _address) public{
    require (!flag);
    crowdsaleContract = _address;
    flag = true;
  }

  function sendTokens(address _to, uint256 _amount)  public { 
    require (msg.sender == crowdsaleContract);
    require(this != _to);
    
    balances[this] = balances[this].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(this,_to,_amount);
  }

  function transferFrom( //standart ERC-20 function
    address _from,
    address _to,
    uint256 _amount
    )public returns (bool success) {
      //  require(!locked);
      require(this != _to);

      if (balances[_from] >= _amount
       && allowed[_from][msg.sender] >= _amount
       && _amount > 0
       && balances[_to] + _amount > balances[_to]) {
       balances[_from] -= _amount;
       allowed[_from][msg.sender] -= _amount;
       balances[_to] += _amount;
       Transfer(_from, _to, _amount);
    return true;
    } else {
    return false;
    }
  }
  //standart ERC-20 function
  function approve(address _spender, uint256 _amount)public returns (bool success) { 
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  //standart ERC-20 function
  function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  //Constructor
  function NCRYPTOToken() public {
    owner = msg.sender;
    balances[this] = _totalSupply;
  }
}