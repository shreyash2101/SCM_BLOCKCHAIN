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

    function getParts(string serial_number)
        public
        view
        returns (string, string, string, string, string)
    {}
}


contract ChangeOwnership {
    ProductManagement private pm;
    mapping(bytes32 => address[]) public partHistory;
    mapping(bytes32 => address[]) public productHistory;

    constructor(address pm_addr) public {
        pm = ProductManagement(pm_addr);
    }

    enum OperationType {Part, Product}

    mapping(bytes32 => address) CurrentPartOwner;
    mapping(bytes32 => address) CurrentProductOwner;

    event TransferPartOwnership(bytes32 indexed p, address indexed account);
    event TransferProductOwnership(bytes32 indexed p, address indexed account);

    function getPartHistory(string serial_number)
        public
        view
        returns (address[])
    {
        bytes32 p_hash = keccak256(serial_number);
        return (partHistory[p_hash]);
    }

    function getProductHistory(string serial_number)
        public
        view
        returns (address[])
    {
        bytes32 p_hash = keccak256(serial_number);
        return (productHistory[p_hash]);
    }

    function getPartList(string serial_number)
        private
        view
        returns (bytes32[5])
    {
        string memory p1;
        string memory p2;
        string memory p3;
        string memory p4;
        string memory p5;
        (p1, p2, p3, p4, p5) = pm.getParts(serial_number);
        bytes32[5] memory part_list;
        part_list[0] = keccak256(p1);
        part_list[1] = keccak256(p2);
        part_list[2] = keccak256(p3);
        part_list[3] = keccak256(p4);
        part_list[4] = keccak256(p5);
        return part_list;
    }

    function addOwnership(uint256 op_type, string serial_number) public {
        address manufacturer;
        bytes32 p_hash = keccak256(serial_number);

        if (op_type == uint256(OperationType.Part)) {
            (manufacturer, , , , ) = pm.parts(p_hash);
            require(
                CurrentPartOwner[p_hash] == address(0),
                "Part was already registered"
            );
            require(
                manufacturer == msg.sender,
                "Part was not made by requester"
            );
            CurrentPartOwner[p_hash] = msg.sender;
            partHistory[p_hash].push(msg.sender);
            emit TransferPartOwnership(p_hash, msg.sender);
        } else if (op_type == uint256(OperationType.Product)) {
            (manufacturer, , , , ) = pm.products(p_hash);
            require(
                CurrentProductOwner[p_hash] == address(0),
                "Product was already registered"
            );
            require(
                manufacturer == msg.sender,
                "Product was not made by requester"
            );
            bytes32[5] memory part_list = getPartList(serial_number);
            for (uint256 j = 0; j < part_list.length; j++) {
                require(
                    CurrentPartOwner[part_list[j]] == msg.sender,
                    "Part not owned by requester"
                );
            }
            CurrentProductOwner[p_hash] = msg.sender;
            productHistory[p_hash].push(msg.sender);

            emit TransferProductOwnership(p_hash, msg.sender);
        }
    }

    function changeOwnership(uint256 op_type, string serial_number, address to)
        public
    {
        bytes32 p_hash = keccak256(serial_number);
        //Check if the element exists and belongs to the user requesting ownership change
        if (op_type == uint256(OperationType.Part)) {
            require(
                CurrentPartOwner[p_hash] == msg.sender,
                "Part is not owned by requester"
            );
            CurrentPartOwner[p_hash] = to;
            partHistory[p_hash].push(to);

            emit TransferPartOwnership(p_hash, to);
        } else if (op_type == uint256(OperationType.Product)) {
            require(
                CurrentProductOwner[p_hash] == msg.sender,
                "Product is not owned by requester"
            );
            CurrentProductOwner[p_hash] = to;
            productHistory[p_hash].push(to);

            emit TransferProductOwnership(p_hash, to);
            //Change part ownership too
            bytes32[5] memory part_list = getPartList(serial_number);
            for (uint256 i = 0; i < part_list.length; i++) {
                CurrentPartOwner[part_list[i]] = to;
                partHistory[part_list[i]].push(to);

                emit TransferPartOwnership(part_list[i], to);
            }
        }
    }

    function currentOwner(uint256 op_type, string serial_number)
        public
        view
        returns (address)
    {
        bytes32 p_hash = keccak256(serial_number);
        if (op_type == uint256(OperationType.Part)) {
            return CurrentPartOwner[p_hash];
        } else if (op_type == uint256(OperationType.Product)) {
            return CurrentProductOwner[p_hash];
        }
    }
}
