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

    uint productCount;

    mapping(address => User) public users;
    mapping(uint => Product) public products;

    function register(string memory _name, bool _isSeller) public {
        require(users[msg.sender].userId == address(0), "User already exists");

        users[msg.sender] = User(msg.sender, _name, _isSeller);
    }

    function addProduct(
        string memory _name,
        string memory _description,
        uint price,
        uint quantity
    ) public {
        require(users[msg.sender].isSeller, "User is not a seller");

        productCount++;
        products[productCount] = Product(
            payable(msg.sender),
            productCount,
            _name,
            _description,
            price,
            quantity
        );
    }

    function buyProduct(uint _productId) public {
        require(users[msg.sender].userId != address(0), "User does not exist");
        require(products[_productId].id != 0, "Product does not exist");
        require(products[_productId].quantity > 0, "Product is out of stock");
        require(
            products[_productId].sellerId != msg.sender,
            "User cannot buy their own product"
        );
        require(
            products[_productId].price <= msg.sender.balance,
            "User does not have enough balance"
        );

        products[_productId].quantity--;
        products[_productId].sellerId.transfer(products[_productId].price);
    }

    function getBalance() public view returns (uint) {
        return msg.sender.balance;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function listProducts() public view returns (Product[] memory) {
        Product[] memory _products = new Product[](productCount);

        for (uint i = 1; i <= productCount; i++) {
            _products[i - 1] = products[i];
        }

        return _products;
    }

    function listProductsBySeller(
        address _sellerId
    ) public view returns (Product[] memory) {
        uint count = 0;

        for (uint i = 1; i <= productCount; i++) {
            if (products[i].sellerId == _sellerId) {
                count++;
            }
        }

        Product[] memory _products = new Product[](count);
        uint index = 0;

        for (uint i = 1; i <= productCount; i++) {
            if (products[i].sellerId == _sellerId) {
                _products[index] = products[i];
                index++;
            }
        }

        return _products;
    }
}
