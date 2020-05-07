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

    function getParts(bytes32) public pure returns (bytes32[6] memory){}
}
contract ChangeOwnership{
  ProductManagement private pm ;
  constructor(address pm_addr) public {
    pm = ProductManagement(pm_addr);
  }
  enum OperationType{Part,Product}

  mapping(bytes32 => address) CurrentPartOwner ;
  mapping(bytes32 => address) CurrentProductOwner ;

  event TransferPartOwnership(bytes32 indexed p, address indexed account);
    event TransferProductOwnership(bytes32 indexed p, address indexed account);

  function addOwnership(uint op_type, bytes32 p_hash) public returns (bool) {
    address manufacturer;

        if(op_type == uint(OperationType.Part)){
            
            (manufacturer, , , ,) = pm.parts(p_hash);
            require(CurrentPartOwner[p_hash] == address(0), "Part was already registered");
            require(manufacturer == msg.sender, "Part was not made by requester");
            CurrentPartOwner[p_hash] = msg.sender;
            emit TransferPartOwnership(p_hash, msg.sender);
            return true;
        } else if (op_type == uint(OperationType.Product)){
            
            (manufacturer, , , , ) = pm.products(p_hash);
            require(CurrentProductOwner[p_hash] == address(0), "Product was already registered");
            require(manufacturer == msg.sender, "Product was not made by requester");
            bytes32[6] memory part_list = pm.getParts(p_hash);
            for(uint j=0;j<part_list.length;j++)
            {
                require(CurrentPartOwner[part_list[j]]==msg.sender,"Part not owned by requester");
            }
            CurrentProductOwner[p_hash] = msg.sender;
            emit TransferProductOwnership(p_hash, msg.sender);
            return true;
        }
    }


    function changeOwnership(uint op_type, bytes32 p_hash, address to) public returns (bool) {
      //Check if the element exists and belongs to the user requesting ownership change
        if(op_type == uint(OperationType.Part)){
            require(CurrentPartOwner[p_hash] == msg.sender, "Part is not owned by requester");
            CurrentPartOwner[p_hash] = to;
            emit TransferPartOwnership(p_hash, to);
            return true;
        } else if (op_type == uint(OperationType.Product)){
            require(CurrentProductOwner[p_hash] == msg.sender, "Product is not owned by requester");
            CurrentProductOwner[p_hash] = to;
            emit TransferProductOwnership(p_hash, to);
            //Change part ownership too
            bytes32[6] memory part_list = pm.getParts(p_hash);
            for(uint i = 0; i < part_list.length; i++){
                CurrentPartOwner[part_list[i]] = to;
                emit TransferPartOwnership(part_list[i], to);
                return true;
            }

        }
    }
}