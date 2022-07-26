// pragma solidity ^0.7.0;
// pragma experimental ABIEncoderV2;
// import "./InstaList.sol";


// interface ConnectorsInterface {
//     function isConnector(address[] calldata logicAddr) external view returns (bool);
//     function isStaticConnector(address[] calldata logicAddr) external view returns (bool);
// }

// interface CheckInterface {
//     function isOk() external view returns (bool);
// }



// contract Record {
//     InstaIndex indexContract;
//     InstaList listContract;

//     event LogEnable(address indexed user);
//     event LogDisable(address indexed user);
//     event LogSwitchShield(bool _shield);

//     // InstaIndex Address.
//     address public immutable instaIndex;
//     // The Account Module Version.
//     uint public constant version = 1;
//     // Auth Module(Address of Auth => bool).
//     mapping (address => bool) private auth;
//     // Is shield true/false.
//     bool public shield;

//     // constructor (address _instaIndex) {
//     //     instaIndex = _instaIndex;
//     // }

//     /**
//      * @dev Check for Auth if enabled.
//      * @param user address/user/owner.
//      */
//     function isAuth(address user) public view returns (bool) {
//         return auth[user];
//     }

//     /**
//      * @dev Change Shield State.
//     */
//     function switchShield(bool _shield) external {
//         require(auth[msg.sender], "not-self");
//         require(shield != _shield, "shield is set");
//         shield = _shield;
//         emit LogSwitchShield(shield);
//     }

//     /**
//      * @dev Enable New User.
//      * @param user Owner of the Smart Account.
//     */
//     function enable(address user) public {
//         require(msg.sender == address(this) || msg.sender == instaIndex, "not-self-index");
//         require(user != address(0), "not-valid");
//         require(!auth[user], "already-enabled");
//         auth[user] = true;
//         listContract.addAuth(user);
//         emit LogEnable(user);
//     }

//     /**
//      * @dev Disable User.
//      * @param user Owner of the Smart Account.
//     */
//     function disable(address user) public {
//         require(msg.sender == address(this), "not-self");
//         require(user != address(0), "not-valid");
//         require(auth[user], "already-disabled");
//         delete auth[user];
//         listContract.removeAuth(user);
//         emit LogDisable(user);
//     }

// }

// contract InstaAccount is Record {

//     constructor (address _instaIndex) public Record(_instaIndex) {
//     }

//     event LogCast(address indexed origin, address indexed sender, uint value);

//     receive() external payable {}

//      /**
//      * @dev Delegate the calls to Connector And this function is ran by cast().
//      * @param _target Target to of Connector.
//      * @param _data CallData of function in Connector.
//     */
//     function spell(address _target, bytes memory _data) internal {
//         require(_target != address(0), "target-invalid");
//         assembly {
//             let succeeded := delegatecall(gas(), _target, add(_data, 0x20), mload(_data), 0, 0)

//             switch iszero(succeeded)
//                 case 1 {
//                     // throw if delegatecall failed
//                     let size := returndatasize()
//                     returndatacopy(0x00, 0x00, size)
//                     revert(0x00, size)
//                 }
//         }
//     }

//     /**
//      * @dev This is the main function, Where all the different functions are called
//      * from Smart Account.
//      * @param _targets Array of Target(s) to of Connector.
//      * @param _datas Array of Calldata(S) of function.
//     */
//     function cast(
//         address[] calldata _targets,
//         bytes[] calldata _datas,
//         address _origin
//     )
//     external
//     payable
//     {
//         require(isAuth(msg.sender) || msg.sender == instaIndex, "permission-denied");
//         require(_targets.length == _datas.length , "array-length-invalid");
//         // IndexInterface indexContract = IndexInterface(instaIndex);
//         bool isShield = shield;
//         if (!isShield) {
//             require(ConnectorsInterface(indexContract.connectors(version)).isConnector(_targets), "not-connector");
//         } else {
//             require(ConnectorsInterface(indexContract.connectors(version)).isStaticConnector(_targets), "not-static-connector");
//         }
//         for (uint i = 0; i < _targets.length; i++) {
//             spell(_targets[i], _datas[i]);
//         }
//         address _check = indexContract.check(version);
//         if (_check != address(0) && !isShield) require(CheckInterface(_check).isOk(), "not-ok");
//         emit LogCast(_origin, msg.sender, msg.value);
//     }

// }


// // --------------------------------------------------------------------------------------------------------------------------------------------- //


// /**
//  * @title InstaIndex
//  * @dev Main Contract For DeFi Smart Accounts. This is also a factory contract, Which deploys new Smart Account.
//  * Also Registry for DeFi Smart Accounts.
//  */

// contract AddressIndex {

//     // *** implementation pointers *** //
//     InstaAccount accountContract;
//     InstaList listContract;

//     event LogNewMaster(address indexed master);
//     event LogUpdateMaster(address indexed master);
//     event LogNewCheck(uint256 indexed accountVersion, address indexed check);
//     event LogNewAccount(
//         address indexed _newAccount,
//         address indexed _connectors,
//         address indexed _check
//     );

//     // New Master Address.
//     address private newMaster;
//     // Master Address.
//     address public master;
//     // List Registry Address.
//     // address public list;

//     // Connectors Modules(Account Module Version => Connectors Registry Module Address).
//     mapping(uint256 => address) public connectors;
//     // Check Modules(Account Module Version => Check Module Address).
//     mapping(uint256 => address) public check;
//     // Account Modules(Account Module Version => Account Module Address).
//     mapping(uint256 => address) public account;
//     // Version Count of Account Modules.
//     uint256 public versionCount;

//     /**
//      * @dev Throws if the sender not is Master Address.
//      */
//     modifier isMaster() {
//         require(msg.sender == master, "not-master");
//         _;
//     }

//     /**
//      * @dev Change the Master Address.
//      * @param _newMaster New Master Address.
//      */
//     function changeMaster(address _newMaster) external isMaster {
//         require(_newMaster != master, "already-a-master");
//         require(_newMaster != address(0), "not-valid-address");
//         require(newMaster != _newMaster, "already-a-new-master");
//         newMaster = _newMaster;
//         emit LogNewMaster(_newMaster);
//     }

//     function updateMaster() external {
//         require(newMaster != address(0), "not-valid-address");
//         require(msg.sender == newMaster, "not-master");
//         master = newMaster;
//         newMaster = address(0);
//         emit LogUpdateMaster(master);
//     }

//     /**
//      * @dev Change the Check Address of a specific Account Module version.
//      * @param accountVersion Account Module version.
//      * @param _newCheck The New Check Address.
//      */
//     function changeCheck(uint256 accountVersion, address _newCheck)
//         external
//         isMaster
//     {
//         require(_newCheck != check[accountVersion], "already-a-check");
//         check[accountVersion] = _newCheck;
//         emit LogNewCheck(accountVersion, _newCheck);
//     }

//     /**
//      * @dev Add New Account Module.
//      * @param _newAccount The New Account Module Address.
//      * @param _connectors Connectors Registry Module Address.
//      * @param _check Check Module Address.
//      */
//     function addNewAccount(
//         address _newAccount,
//         address _connectors,
//         address _check
//     ) external isMaster {
//         require(_newAccount != address(0), "not-valid-address");
//         versionCount++;
//         require(
//             accountContract.version() == versionCount,
//             "not-valid-version"
//         );
//         account[versionCount] = _newAccount;
//         if (_connectors != address(0)) connectors[versionCount] = _connectors;
//         if (_check != address(0)) check[versionCount] = _check;
//         emit LogNewAccount(_newAccount, _connectors, _check);
//     }
// }

// contract CloneFactory is AddressIndex {
//     /**
//      * @dev Clone a new Account Module.
//      * @param version Account Module version to clone.
//      */
//     function createClone(uint256 version) internal returns (address result) {
//         bytes20 targetBytes = bytes20(account[version]);
//         // solium-disable-next-line security/no-inline-assembly
//         assembly {
//             let clone := mload(0x40)
//             mstore(
//                 clone,
//                 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
//             )
//             mstore(add(clone, 0x14), targetBytes)
//             mstore(
//                 add(clone, 0x28),
//                 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
//             )
//             result := create(0, clone, 0x37)
//         }
//     }

//     /**
//      * @dev Check if Account Module is a clone.
//      * @param version Account Module version.
//      * @param query Account Module Address.
//      */
//     function isClone(uint256 version, address query)
//         external
//         view
//         returns (bool result)
//     {
//         bytes20 targetBytes = bytes20(account[version]);
//         // solium-disable-next-line security/no-inline-assembly
//         assembly {
//             let clone := mload(0x40)
//             mstore(
//                 clone,
//                 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
//             )
//             mstore(add(clone, 0xa), targetBytes)
//             mstore(
//                 add(clone, 0x1e),
//                 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
//             )

//             let other := add(clone, 0x40)
//             extcodecopy(query, other, 0, 0x2d)
//             result := and(
//                 eq(mload(clone), mload(other)),
//                 eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
//             )
//         }
//     }
// }

// contract InstaIndex is CloneFactory {
//     event LogAccountCreated(
//         address sender,
//         address indexed owner,
//         address indexed account,
//         address indexed origin
//     );

//     /**
//      * @dev Create a new DeFi Smart Account for a user and run cast function in the new Smart Account.
//      * @param _owner Owner of the Smart Account.
//      * @param accountVersion Account Module version.
//      * @param _targets Array of Target to run cast function.
//      * @param _datas Array of Data(callData) to run cast function.
//      * @param _origin Where Smart Account is created.
//      */
//     function buildWithCast(
//         address _owner,
//         uint256 accountVersion,
//         address[] calldata _targets,
//         bytes[] calldata _datas,
//         address _origin
//     ) external payable returns (address _account) {
//         _account = build(_owner, accountVersion, _origin);
//         if (_targets.length > 0)
//             accountContract.cast{value: msg.value}( // *** Replaced AccountInterface(_account) with InstaAccount *** //
//                 _targets,
//                 _datas,
//                 _origin
//             );
//     }

//     /**
//      * @dev Create a new DeFi Smart Account for a user.
//      * @param _owner Owner of the Smart Account.
//      * @param accountVersion Account Module version.
//      * @param _origin Where Smart Account is created.
//      */
//     function build(
//         address _owner,
//         uint256 accountVersion,
//         address _origin
//     ) public returns (address _account) {
//         require(
//             accountVersion != 0 && accountVersion <= versionCount,
//             "not-valid-account"
//         );
//         _account = createClone(accountVersion);
//         listContract.init(_account);    // *** Relaced interface with implementation *** //
//         accountContract.enable(_owner);
//         emit LogAccountCreated(msg.sender, _owner, _account, _origin);
//     }

//     /**
//      * @dev Setup Initial things for InstaIndex, after its been deployed and can be only run once.
//      * @param _master The Master Address.
//      * @param _account The Account Module Address.
//      * @param _connectors The Connectors Registry Module Address.
//      */
//     function setBasics(
//         address _master,
//         // address _list,
//         address _account,
//         address _connectors
//     ) external {
//         require(
//             master == address(0) &&
//                 // list == address(0) &&
//                 account[1] == address(0) &&
//                 connectors[1] == address(0) &&
//                 versionCount == 0,
//             "already-defined"
//         );
//         master = _master;
//         // list = _list;
//         versionCount++;
//         account[versionCount] = _account;
//         connectors[versionCount] = _connectors;
//     }
// }
