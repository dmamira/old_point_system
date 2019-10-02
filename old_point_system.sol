pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
contract point_system {

struct product{
  string name;
  uint stock;
  uint price;
  uint items;
  uint conNo;
}
struct seller{
  string name;
  address sellerAddress;
  uint good;
  uint bad;
  uint processed;
}
mapping(uint=>uint) productToSeller;
mapping(address=>uint) veriousTypes;
mapping(address=>uint) buyerToPoint;
mapping(address=>product[]) cart_contents;
mapping(address=>uint) cart_price;
product[] public products;
seller[] public sellers;
uint rateOfReduction = 20;

function setRateOfReduction(uint newRateOfReduction) public {
  rateOfReduction = newRateOfReduction;
}
function addSeller(string calldata name) external dupCheck(msg.sender){
  sellers.push(seller(name,msg.sender,0,0,0));
}
  function addItem(string calldata _productName, uint _price, uint _stock) external exiCheck(msg.sender){
    uint productId = products.push(product(_productName,_stock,_price,0,now*114514)) - 1; //乱数の精製方法を変えるかも
    for(uint i=0; i<sellers.length; i++){
      if(sellers[i].sellerAddress == msg.sender){
        productToSeller[productId] = i;
      }
    }
  }
  function cart(uint _productId,uint _items) external enoughStock(_productId,_items){
    product memory  buyProduct;
    buyProduct = product(products[_productId].name,products[_productId].stock,products[_productId].price,_items,products[_productId].conNo);
    cart_contents[msg.sender].push(buyProduct);
    cart_price[msg.sender] += buyProduct.price * _items;
  }
  function cartView() external view returns(product[] memory){
    product[] memory show = new product[](100);
    uint count = 0;
    for(uint i=veriousTypes[msg.sender]; i<cart_contents[msg.sender].length; i++){
      show[count] = cart_contents[msg.sender][i];
      count++;
    }
    product[] memory finishedShow = new product[](count);
    for(uint i=0; i<count; i++){
      finishedShow[i] = show[i];
    }
    return finishedShow;
  }
  function acceptPayment() external payable returns(bool){
    require(cart_price[msg.sender]<=msg.value);
    sub(msg.sender);
    addPoint(cart_price[msg.sender]);
    addProcessed(msg.sender);
    cart_price[msg.sender] = 0;
    veriousTypes[msg.sender] = cart_contents[msg.sender].length;
    return true;
  }
  function getCartPrice() public view returns(uint){
      return cart_price[msg.sender];
  }
  function addProcessed(address buyer_address) private returns(uint){
     for(uint m=0; m<cart_contents[buyer_address].length; m++){
      for(uint i=0; i<products.length; i++){
        if(products[i].conNo == cart_contents[buyer_address][m].conNo){
        sellers[productToSeller[i]].processed += cart_contents[buyer_address][m].items * products[i].price;
      }
     }
    }
   }
  function sub(address buyer) private{ //バグが起きているため修正　二個目以降の在庫数がきちんと引かれない
    for(uint i=0; i<cart_contents[buyer].length; i++){
      uint b = cart_contents[buyer][i].items;
      cart_contents[buyer][i].stock -= b;
      for(uint m=0; i<products.length; i++){
      if(products[m].conNo == cart_contents[buyer][i].conNo){
        products[m].stock -= b;
      }
    }
   }
  }
  function addPoint(uint _totalValue) private{
    buyerToPoint[msg.sender] += _totalValue*rateOfReduction;
  }
  function usepoint(uint _amount) external{
    require(buyerToPoint[msg.sender]>=_amount);
    cart_price[msg.sender] -= _amount;
    buyerToPoint[msg.sender] -= _amount;
  }

  modifier enoughStock(uint _productId,uint _items){
    require(products[_productId].stock>=_items);
    _;
  }
  modifier dupCheck(address seller1){
    int check = -5;
    for(int i=0;i<int(sellers.length);i++){
      if(sellers[uint(i)].sellerAddress == seller1){
        check =  -1;
      }
    }
    require(check!=-1);
    _;
  }
modifier exiCheck(address seller2){
    int check2 = -1;
    for(int i=0; i<int(sellers.length); i++){
      if(sellers[uint(i)].sellerAddress == seller2){
        check2 =  i;
      }
    }
    require(check2!=-1);
    _;
  }
 }
