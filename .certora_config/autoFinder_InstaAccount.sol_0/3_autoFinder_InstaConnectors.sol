pragma solidity ^0.7.0;

/**
 * @title InstaConnectors
 * @dev Registry for Connectors.
 */

// import "./InstaIndex.sol";
import 'C:/Users/rssav/Desktop/InstaDapp Verify/Contracts/autoFinder_ConnectAuth.sol';

// interface IndexInterface {
//     function master() external view returns (address);
// }

// interface ConnectorInterface {
//     function connectorID() external view returns(uint _type, uint _id);
//     function name() external view returns (string memory);
// }


contract DSMathConnectors {

    function add(uint x, uint y) internal pure returns (uint z) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00040000, 1037618708484) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00040001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00041000, x) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00041001, y) }
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00050000, 1037618708485) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00050001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00051000, x) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00051001, y) }
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

}

contract Controllers is DSMathConnectors {
    // InstaIndex indexContract;
    ConnectAuth connectContract; 

    event LogAddController(address indexed addr);
    event LogRemoveController(address indexed addr);

    // InstaIndex Address.
    // address public immutable instaIndex;

    // constructor (address _instaIndex) {
    //     instaIndex = _instaIndex;
    // }

    // Enabled Chief(Address of Chief => bool).
    mapping(address => bool) public chief;
    // Enabled Connectors(Connector Address => bool).
    mapping(address => bool) public connectors;
    // Enabled Static Connectors(Connector Address => bool).
    mapping(address => bool) public staticConnectors;

    /**
    * @dev Throws if the sender not is Master Address from InstaIndex
    * or Enabled Chief.
    */
    modifier isChief {
        require(chief[msg.sender], "not-an-chief"); // removed `|| msg.sender == indexContract.master()` from require
        _;
    }

    /**
     * @dev Enable a Chief.
     * @param _userAddress Chief Address.
    */
    function enableChief(address _userAddress) external isChief {
        chief[_userAddress] = true;
        emit LogAddController(_userAddress);
    }

    /**
     * @dev Disables a Chief.
     * @param _userAddress Chief Address.
    */
    function disableChief(address _userAddress) external isChief {
        delete chief[_userAddress];
        emit LogRemoveController(_userAddress);
    }

}


contract Listings is Controllers {

    // constructor (address _instaIndex) Controllers(_instaIndex) {
    // }

    // Connectors Array.
    address[] public connectorArray;
    // Count of Connector's Enabled.
    uint public connectorCount;

    /**
     * @dev Add Connector to Connector's array.
     * @param _connector Connector Address.
    **/
    function addToArr(address _connector) internal {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00060000, 1037618708486) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00060001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00061000, _connector) }
        require(_connector != address(0), "Not-valid-connector");
        (, uint _id) = connectContract.connectorID();
        require(_id == (connectorArray.length+1),"ConnectorID-doesnt-match");
        connectContract.name(); // Checking if connector has function name()
        connectorArray.push(_connector);
    }

    // Static Connectors Array.
    address[] public staticConnectorArray;

    /**
     * @dev Add Connector to Static Connector's array.
     * @param _connector Static Connector Address.
    **/
    function addToArrStatic(address _connector) internal {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00070000, 1037618708487) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00070001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00071000, _connector) }
        require(_connector != address(0), "Not-valid-connector");
        (, uint _id) = connectContract.connectorID();
        require(_id == (staticConnectorArray.length+1),"ConnectorID-doesnt-match");
        connectContract.name(); // Checking if connector has function name()
        staticConnectorArray.push(_connector);
    }

}


contract InstaConnectors is Listings {

    // constructor (address _instaIndex) public Listings(_instaIndex) {
    // }

    event LogEnable(address indexed connector);
    event LogDisable(address indexed connector);
    event LogEnableStatic(address indexed connector);

    /**
     * @dev Enable Connector.
     * @param _connector Connector Address.
    */
    function enable(address _connector) external isChief {
        require(!connectors[_connector], "already-enabled");
        addToArr(_connector);
        connectors[_connector] = true;
        connectorCount++;
        emit LogEnable(_connector);
    }
    /**
     * @dev Disable Connector.
     * @param _connector Connector Address.
    */
    function disable(address _connector) external isChief {
        require(connectors[_connector], "already-disabled");
        delete connectors[_connector];
        connectorCount--;
        emit LogDisable(_connector);
    }

    /**
     * @dev Enable Static Connector.
     * @param _connector Static Connector Address.
    */
    function enableStatic(address _connector) external isChief {
        require(!staticConnectors[_connector], "already-enabled");
        addToArrStatic(_connector);
        staticConnectors[_connector] = true;
        emit LogEnableStatic(_connector);
    }

     /**
     * @dev Check if Connector addresses are enabled.
     * @param _connectors Array of Connector Addresses.
    */
    function isConnector(address[] calldata _connectors) external view returns (bool isOk) {
        isOk = true;
        for (uint i = 0; i < _connectors.length; i++) {
            if (!connectors[_connectors[i]]) {
                isOk = false;
                break;
            }
        }
    }

    /**
     * @dev Check if Connector addresses are static enabled.
     * @param _connectors Array of Connector Addresses.
    */
    function isStaticConnector(address[] calldata _connectors) external view returns (bool isOk) {
        isOk = true;
        for (uint i = 0; i < _connectors.length; i++) {
            if (!staticConnectors[_connectors[i]]) {
                isOk = false;
                break;
            }
        }
    }

    /**
     * @dev get Connector's Array length.
    */
    function connectorLength() external view returns (uint) {
        return connectorArray.length;
    }

    /**
     * @dev get Static Connector's Array length.
    */
    function staticConnectorLength() external view returns (uint) {
        return staticConnectorArray.length;
    }
}