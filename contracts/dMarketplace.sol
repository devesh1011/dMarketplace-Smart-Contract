// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract dMarketPlace {
    address public owner;

    struct Product {
        address payable sellerId;
        uint256 id;
        string name;
        string description;
        uint256 price;
        uint256 quantity;
    }

    struct User {
        address userId;
        string name;
        bool isSeller;
    }

    uint256 productCount;

    mapping(uint256 => Product) public products;
    mapping(address => User) public users;

    constructor() {
        owner = msg.sender;
    }

    function register(string memory _name, bool _isSeller)
        public
        returns (bool)
    {
        users[msg.sender] = User({
            userId: msg.sender,
            name: _name,
            isSeller: _isSeller
        });
        return true;
    }

    function addProduct(
        string memory _name,
        string memory _description,
        uint256 _price,
        uint256 _quantity
    ) public {
        require(users[msg.sender].isSeller == true, "You are not a seller");

        products[productCount] = Product({
            sellerId: payable(msg.sender),
            id: productCount + 1,
            name: _name,
            description: _description,
            price: _price,
            quantity: _quantity
        });
    }

    function buyProduct(uint256 _productId, uint256 _quantity) public payable {
        _productId -= 1;
        require(
            products[_productId].quantity >= _quantity,
            "product is out of stock"
        );
        require(
            msg.value >= (products[_productId].price * _quantity),
            "pay equal amount"
        );

        products[_productId].quantity -= _quantity;

        address payable seller = products[_productId].sellerId;

        sendMoney(seller, address(this).balance);
    }

    function sendMoney(address to, uint256 value) private {
        address payable receiver = payable(to);
        receiver.transfer(value);
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }
}
