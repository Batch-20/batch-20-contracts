pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";

contract PayContract {
   address public owner;


  struct PaySlotStruct {
    address user;
    uint256 tokenValue;
  }
  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  modifier validateAproveToken(uint256 _amount, address _userAddress, address _tokenAddress){
        require(_amount <= IERC20(_tokenAddress).allowance(msg.sender, address(this)), "Value not aprove");
        _;
  }

  modifier validateAmountToken(uint256 _amount, PaySlotStruct[] memory _signersData){
      uint size = _signersData.length;
      uint value = 0;
      for(uint i = 0; i < size; i++) {
        value += _signersData[i].tokenValue;
      }
      require(value == _amount, "Invalid Amount");
      _;
  }

  event payment(address indexed payer, uint256 tokenAmount, address tokenAddress);

  function newTokenPayment(PaySlotStruct[] memory _signersData, uint256 _totalAmountToken, address _tokenAddress) public
    validateAproveToken(_totalAmountToken, msg.sender, _tokenAddress) validateAmountToken(_totalAmountToken, _signersData){
      for(uint i = 0; i < _signersData.length; i++) {
        if (!IERC20(_tokenAddress).transferFrom(msg.sender, _signersData[i].user, _signersData[i].tokenValue)) {
          revert(""); 
        }
      }
      emit payment(msg.sender, _totalAmountToken, _tokenAddress);
  }
}
