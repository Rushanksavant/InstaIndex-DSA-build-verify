pragma solidity ^0.7.0;

/**
 * @title ConnectAuth.
 * @dev Connector For Adding Auth.
 */
import 'C:/Users/rssav/Desktop/InstaDapp Verify/Contracts/autoFinder_InstaAccount.sol';

// interface AccountInterface {
//     function enable(address user) external;
//     function disable(address user) external;
// }

// interface EventInterface {
//     function emitEvent(uint _connectorType, uint _connectorID, bytes32 _eventCode, bytes calldata _eventData) external;
// }


contract Basics {

    InstaAccount accountContract;

    /**
     * @dev InstaEvent Address.
     */
    // address public immutable instaEventAddress;
    // constructor (address _instaEventAddress) {
    //     instaEventAddress = _instaEventAddress;
    // }

     /**
     * @dev Connector ID and Type.
     */
    function connectorID() public pure returns(uint _type, uint _id) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f0000, 1037618708495) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f0001, 0) }
        (_type, _id) = (1, 1);
    }

}


contract Auth is Basics {

    // constructor (address _instaEventAddress) Basics(_instaEventAddress) {}

    event LogAddAuth(address indexed _msgSender, address indexed _auth);
    event LogRemoveAuth(address indexed _msgSender, address indexed _auth);

    /**
     * @dev Add New Owner
     * @param user User Address.
     */
    function addModule(address user) public payable {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000e0000, 1037618708494) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000e0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000e1000, user) }
        accountContract.enable(user);

        emit LogAddAuth(msg.sender, user);

        bytes32 _eventCode = keccak256("LogAddAuth(address,address)");
        bytes memory _eventParam = abi.encode(msg.sender, user);
        (uint _type, uint _id) = connectorID();
        // EventInterface(instaEventAddress).emitEvent(_type, _id, _eventCode, _eventParam); // not including events.sol for now //
    }

    /**
     * @dev Remove New Owner
     * @param user User Address.
     */
    function removeModule(address user) public payable {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00100000, 1037618708496) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00100001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00101000, user) }
        accountContract.disable(user);

        emit LogRemoveAuth(msg.sender, user);

        bytes32 _eventCode = keccak256("LogRemoveAuth(address,address)");
        bytes memory _eventParam = abi.encode(msg.sender, user);
        (uint _type, uint _id) = connectorID();
        // EventInterface(instaEventAddress).emitEvent(_type, _id, _eventCode, _eventParam); // not including events.sol for now //
    }

}


contract ConnectAuth is Auth {

    // constructor (address _instaEventAddress) public Auth(_instaEventAddress) {}
    string constant public name = "Auth-v1";
}