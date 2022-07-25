rule starter{
    address _master;
    require _master != 0;
    address _account;
    address _connectors;

    address owner;
    require owner != 0;


    env e;
    setBasics(e, _master, _account, _connectors);
    address dsa = build(e, owner, 2, 0);
    assert dsa == 0, "not";
    # assert dsa != 0, "not";
}