pragma solidity ^0.7.0;

// import "./InstaAccount.sol";

/**
 * @title InstaList
 * @dev Registry For DeFi Smart Account Authorised user.
 */


contract DSMath {

    function add(uint64 x, uint64 y) internal pure returns (uint64 z) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00150000, 1037618708501) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00150001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00151000, x) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00151001, y) }
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint64 x, uint64 y) internal pure returns (uint64 z) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00180000, 1037618708504) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00180001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00181000, x) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00181001, y) }
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

}


contract VariablesList is DSMath {

    // InstaIndex Address.
    // address public immutable instaIndex;

    // constructor (address _instaIndex) {
    //     instaIndex = _instaIndex;
    // }

    // Smart Account Count.
    uint64 public accounts;
    // Smart Account ID (Smart Account Address => Account ID).
    mapping (address => uint64) public accountID;
    // Smart Account Address (Smart Account ID => Smart Account Address).
    mapping (uint64 => address) public accountAddr;

    // User Link (User Address => UserLink(Account ID of First and Last And Count of Smart Accounts)).
    mapping (address => UserLink) public userLink;
    // Linked List of Users (User Address => Smart Account ID => UserList(Previous and next Account ID)).
    mapping (address => mapping(uint64 => UserList)) public userList;

    struct UserLink {
        uint64 first;
        uint64 last;
        uint64 count;
    }
    struct UserList {
        uint64 prev;
        uint64 next;
    }

    // Account Link (Smart Account ID => AccountLink).
    mapping (uint64 => AccountLink) public accountLink; // account => account linked list connection
    // Linked List of Accounts (Smart Account ID => Account Address => AccountList).
    mapping (uint64 => mapping (address => AccountList)) public accountList; // account => user address => list

    struct AccountLink {
        address first;
        address last;
        uint64 count;
    }
    struct AccountList {
        address prev;
        address next;
    }

}

contract Configure is VariablesList {

    // constructor (address _instaIndex) VariablesList(_instaIndex) {
    // }

    /**
     * @dev Add Account to User Linked List.
     * @param _owner Account Owner.
     * @param _account Smart Account Address.
    */
    function addAccount(address _owner, uint64 _account) internal {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00130000, 1037618708499) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00130001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00131000, _owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00131001, _account) }
        if (userLink[_owner].last != 0) {
            userList[_owner][_account].prev = userLink[_owner].last;
            userList[_owner][userLink[_owner].last].next = _account;
        }
        if (userLink[_owner].first == 0) userLink[_owner].first = _account;
        userLink[_owner].last = _account;
        userLink[_owner].count = add(userLink[_owner].count, 1);
    }

    /**
     * @dev Remove Account from User Linked List.
     * @param _owner Account Owner/User.
     * @param _account Smart Account Address.
    */
    function removeAccount(address _owner, uint64 _account) internal {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00140000, 1037618708500) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00140001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141000, _owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141001, _account) }
        uint64 _prev = userList[_owner][_account].prev;
        uint64 _next = userList[_owner][_account].next;
        if (_prev != 0) userList[_owner][_prev].next = _next;
        if (_next != 0) userList[_owner][_next].prev = _prev;
        if (_prev == 0) userLink[_owner].first = _next;
        if (_next == 0) userLink[_owner].last = _prev;
        userLink[_owner].count = sub(userLink[_owner].count, 1);
        delete userList[_owner][_account];
    }

    /**
     * @dev Add Owner to Account Linked List.
     * @param _owner Account Owner.
     * @param _account Smart Account Address.
    */
    function addUser(address _owner, uint64 _account) internal {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00160000, 1037618708502) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00160001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00161000, _owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00161001, _account) }
        if (accountLink[_account].last != address(0)) {
            accountList[_account][_owner].prev = accountLink[_account].last;
            accountList[_account][accountLink[_account].last].next = _owner;
        }
        if (accountLink[_account].first == address(0)) accountLink[_account].first = _owner;
        accountLink[_account].last = _owner;
        accountLink[_account].count = add(accountLink[_account].count, 1);
    }

    /**
     * @dev Remove Owner from Account Linked List.
     * @param _owner Account Owner.
     * @param _account Smart Account Address.
    */
    function removeUser(address _owner, uint64 _account) internal {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00170000, 1037618708503) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00170001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00171000, _owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00171001, _account) }
        address _prev = accountList[_account][_owner].prev;
        address _next = accountList[_account][_owner].next;
        if (_prev != address(0)) accountList[_account][_prev].next = _next;
        if (_next != address(0)) accountList[_account][_next].prev = _prev;
        if (_prev == address(0)) accountLink[_account].first = _next;
        if (_next == address(0)) accountLink[_account].last = _prev;
        accountLink[_account].count = sub(accountLink[_account].count, 1);
        delete accountList[_account][_owner];
    }

}

contract InstaList is Configure {
    // InstaAccount accountContract;
    // constructor (address _instaIndex) public Configure(_instaIndex) {}


    /**
     * @dev Enable Auth for Smart Account.
     * @param _owner Owner Address.
    */
    function addAuth(address _owner) external {
        require(accountID[msg.sender] != 0, "not-account");
        // require(accountContract.isAuth(_owner), "not-owner"); // *** Replaced AccountInterface(_account) with InstaAccount *** //
        addAccount(_owner, accountID[msg.sender]);
        addUser(_owner, accountID[msg.sender]);
    }

    /**
     * @dev Disable Auth for Smart Account.
     * @param _owner Owner Address.
    */
    function removeAuth(address _owner) external {
        require(accountID[msg.sender] != 0, "not-account");
        // require(!accountContract.isAuth(_owner), "already-owner"); // *** Replaced AccountInterface(_account) with InstaAccount *** //
        removeAccount(_owner, accountID[msg.sender]);
        removeUser(_owner, accountID[msg.sender]);
    }

    /**
     * @dev Setup Initial configuration of Smart Account.
     * @param _account Smart Account Address.
    */
    function init(address  _account) external {
        // require(msg.sender == instaIndex, "not-index");
        accounts++;
        accountID[_account] = accounts;
        accountAddr[accounts] = _account;
    }

}