pragma solidity ^0.4.23;


contract ProductManagement {
    struct Part {
        address manufacturer;
        string serial_number;
        string part_type;
        uint256 creation_date;
        bool used;
    }

    struct Product {
        address manufacturer;
        string serial_number;
        string product_type;
        uint256 creation_date;
        bytes32[6] parts;
    }

    mapping(bytes32 => Part) public parts;
    mapping(bytes32 => Product) public products;

    constructor() public {}

    function buildPart(string memory serial_number, string memory part_type)
        public
        returns (bytes32)
    {
        bytes32 part_hash = keccak256(serial_number);

        uint256 creation_date = now;

        require(
            parts[part_hash].manufacturer == address(0), "Part already exists.."
        );
        

        Part memory new_part = Part(
            msg.sender,
            serial_number,
            part_type,
            creation_date,
            false
        );
        parts[part_hash] = new_part;
        return part_hash;
    }

    function buildProduct(
        string memory serial_number,
        string memory product_type,
        bytes32[6] memory parts_arr
    ) public returns (bytes32) {
        bytes32 product_hash = keccak256(serial_number);

        uint256 creation_date = now;

        require(
            products[product_hash].manufacturer == address(0),"Product already exists.."
        );
        
        for(uint i=0;i<parts_arr.length;i++){
            require(
            parts[parts_arr[i]].manufacturer != address(0),"Part does not exists.."
        );
        require(parts[parts_arr[i]].used != true, "Part already used");
        }
        
        for(uint j=0;j<parts_arr.length;j++){
            parts[parts_arr[j]].used = true;
        
        }
        Product memory new_product = Product(
            msg.sender,
            serial_number,
            product_type,
            creation_date,
            parts_arr
        );
        products[product_hash] = new_product;
        return product_hash;
    }

    function getParts(bytes32 product_hash) public view returns (bytes32[6] memory){
        //The automatic getter does not return arrays, so lets create a function for that
        require(products[product_hash].manufacturer != address(0));
        return products[product_hash].parts;
    }
}
