pragma solidity 0.4.24; 
contract Proxy {
    mapping (address => uint256) private balances;
    mapping (address => uint256) private nonces;
    event Transfer(address indexed from, address indexed to, uint256 value);
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    function nonceOf(address account) public view returns (uint256) {
        return nonces[account];
    }
    function transferProxy(address from, address to, uint256 value, uint256 fee, uint8 v, bytes32 r, bytes32 s) public returns (bool) {
        require(balances[from] >= fee + value);
        uint256 nonce = nonces[from];
        //bytes32 h = sha3(from, to, value, fee, nonce);
        bytes32 h = keccak256(abi.encodePacked(from, to, value, fee, nonce));
        require(from == ecrecover(h, v, r, s));
        if(balances[to] + value < balances[to] || balances[msg.sender] + fee < balances[msg.sender]) revert();
        balances[to] += value;
        emit Transfer(from, to, value);
        balances[msg.sender] += fee;
        emit Transfer(from, msg.sender, fee);
        balances[from] -= value + fee;
        nonces[from] = nonce + 1;
        return true;
    }
}
