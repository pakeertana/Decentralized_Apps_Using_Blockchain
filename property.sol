// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PropertyMarket {
    struct Property {
        uint256 id;
        string name;
        uint256 price;
        address owner;
        bool forSale;
    }

    uint256 public nextPropertyId = 1;
    mapping(uint256 => Property) public properties;
    mapping(address => uint256) public balances;

    event BalanceUpdated(address user, uint256 newBalance);
    event PropertyListed(uint256 id, string name, uint256 price, address owner);
    event PropertySold(uint256 id, address from, address to, uint256 price);

    function addBalance(uint256 amount) external {
        balances[msg.sender] += amount;
        emit BalanceUpdated(msg.sender, balances[msg.sender]);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function listProperty(string memory name, uint256 price) external {
        require(price > 0, "Price must be greater than zero");

        properties[nextPropertyId] = Property({
            id: nextPropertyId,
            name: name,
            price: price,
            owner: msg.sender,
            forSale: true
        });

        emit PropertyListed(nextPropertyId, name, price, msg.sender);
        nextPropertyId++;
    }

    function getProperty(uint256 propertyId) external view returns (Property memory) {
        return properties[propertyId];
    }

    function buyProperty(uint256 propertyId) external {
        Property storage prop = properties[propertyId];
        require(prop.forSale, "Property not for sale");
        require(balances[msg.sender] >= prop.price, "Insufficient balance");

        balances[msg.sender] -= prop.price;
        balances[prop.owner] += prop.price;

        address previousOwner = prop.owner;
        prop.owner = msg.sender;
        prop.forSale = false;

        emit PropertySold(propertyId, previousOwner, msg.sender, prop.price);
    }
}
