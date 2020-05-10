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
        bytes32[5] parts;
    }

    mapping(bytes32 => Part) public parts;
    mapping(bytes32 => Product) public products;

    constructor() public {}

    function buildPart(string memory serial_number, string memory part_type)public
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
    }

    function buildProduct(
        string memory serial_number,
        string memory product_type,
        string memory part1,
        string memory part2,
        string memory part3,
        string memory part4,
        string memory part5
    ) public  {
        bytes32 product_hash = keccak256(serial_number);

        uint256 creation_date = now;

        require(
            products[product_hash].manufacturer == address(0),"Product already exists.."
        );
        bytes32[5] memory parts_arr = [keccak256(part1),keccak256(part2),keccak256(part3),keccak256(part4),keccak256(part5)];
        for(uint i = 0;i<parts_arr.length;i++){
            require(
            parts[parts_arr[i]].manufacturer != address(0),"Part does not exists.."
        );
        require(parts[parts_arr[i]].used != true, "Part already used");
        }
        for(uint j = 0;j<parts_arr.length;j++){
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
    }
function showPart(string serial_number) public view returns(address,string,string,uint256,bool)
{
    bytes32 part_hash = keccak256(serial_number);
    return (parts[part_hash].manufacturer,parts[part_hash].serial_number,parts[part_hash].part_type,parts[part_hash].creation_date,parts[part_hash].used);
}

function showProduct(string serial_number) public view returns(address,string,string,uint256)
{
    bytes32 product_hash = keccak256(serial_number);
    return (products[product_hash].manufacturer,products[product_hash].serial_number,products[product_hash].product_type,products[product_hash].creation_date);
}
    function getParts(string serial_number) public view returns (string,string,string,string,string){
        bytes32 product_hash = keccak256(serial_number);
        //The automatic getter does not return arrays, so lets create a function for that
        require(products[product_hash].manufacturer != address(0));
        return(parts[products[product_hash].parts[0]].serial_number,parts[products[product_hash].parts[1]].serial_number,parts[products[product_hash].parts[2]].serial_number,parts[products[product_hash].parts[3]].serial_number,parts[products[product_hash].parts[4]].serial_number);
    }
}
