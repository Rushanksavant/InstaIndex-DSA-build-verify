certoraRun ./contracts/InstaIndex.sol ./contracts/InstaAccount.sol ./contracts/InstaList.sol --link InstaIndex:accountContract=InstaAccount InstaIndex:listContract=InstaList --verify InstaIndex:all.spec --solc solc76 --rule_sanity