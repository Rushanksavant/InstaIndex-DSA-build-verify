certoraRun ./contracts/InstaIndex.sol --verify InstaIndex:all.spec --solc solc76
certoraRun ./contracts/InstaIndex.sol ./contracts/InstaAccount.sol ./contracts/InstaList.sol --link InstaIndex:accountContract=InstaAccount InstaIndex:listContract=InstaList --verify InstaIndex:all.spec --solc solc76

certoraRun ./contracts/InstaIndex1.sol ./contracts/InstaList.sol --link InstaIndex1:accountContract=InstaAccount InstaIndex1:listContract=InstaList --verify InstaIndex1:all.spec --solc solc76