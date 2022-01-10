

pragma solidity >=0.5.0 <0.6.0; 

library SafeMath {
    
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    
}


contract AliliceToken {
    
    using SafeMath for uint256;

    //=====================================================================================================================
    //==SECTION-1, Standard ERC20-TOKEN with Bancor-Pool.
    //=====================================================================================================================
    
    string constant private _name = "AliceToken";
    string constant private _symbol = "AliceToken";
    uint8 constant private _decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _special;
    
    // TODO There is a strange problem here: 10**(_decimals) == 0, so we have to use 10**18 instead !!!
    uint256 constant private _totalSupply = 2000*(10**4)*(10**18); // Do not use (10**_decimals) !!!
    uint256 public bancorPool;
    address private _owner;
    
    constructor() public {
        _owner = msg.sender;
        bancorPool = 20*(10**4)*(10**18);
        _balances[msg.sender] = _totalSupply - bancorPool;
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount); 
        return true;
    }
    
    function batchTransfer(address[] memory recipients , uint256[] memory amounts) public returns (bool) {
        require(recipients.length == amounts.length);
        for(uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
 
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    //=====================================================================================================================
    //==SECTION-2, BANCOR-TOKEN
    //=====================================================================================================================
    
    // TODO There is a strange problem here: 10**(_decimals) == 0, so 10**18 should be used instead !!!
    uint256 constant public BASE_UNIT = 10**18; // Do not use 10**(_decimals) !!!
    uint256 constant public BASE_AMOUNT = 100;
    uint256 constant public INIT_PRICE = 1; // The amount of token 1 EHT could buy.
    uint256 constant public RCW = 2;  // Reciprocal CW, CW is 0.5 (50%, 1/2).
    uint256 constant public baseBalance = BASE_AMOUNT * BASE_UNIT;
    uint256 constant public baseSupply = baseBalance * RCW * INIT_PRICE;
    uint256 public virtualSupply = baseSupply;
    uint256 public virtualBalance = baseBalance;
    uint256 constant public TO_INT = 1000000; // Price could be 0.abc..., it should be amplified by a big factor.
    
    
    function realSupply() public view returns (uint256) {
        return virtualSupply.sub(baseSupply);
    }
    
    function realBanlance() public view returns (uint256) {
        return virtualBalance.sub(baseBalance);
    }
    
    // TODO overflow test.
    function sqrt(uint256 a) public pure returns (uint256 b) {
        uint256 c = (a+1)/2;
        b = a;
        while (c<b) {
            b = c;
            c = (a/c+c)/2;
        }
    }
    
    function PriceAsToken() public view returns (uint256) {
        return TO_INT.mul(virtualSupply).div(virtualBalance.mul(2));
    }
    
    function PriceAsETH() public view returns (uint256) {
        return TO_INT.mul(virtualBalance).div(virtualSupply.div(2));
    }
    
    /*****************************************************************
    tknWei = supply*((1+ethWei/ethBlance)^(1/2)-1)
           = supply*(sqrt((ethBlance+ethWei)/ethBlance)-1);
           = supply*sqrt((ethBlance+ethWei)/ethBlance)-supply;
           = sqrt(supply*supply*(ethBlance+ethWei)/ethBlance)-supply;
           = sqrt(supply*supply*sum/ethBlance)-supply;
    *****************************************************************/  
    // When ethWei is ZERO, tknWei might be NON-ZERO.
    // This is because sell function retun eth value is less than precise value.
    // So it will Accumulate small amount of differences.
    function _bancorBuy(uint256 ethWei) internal returns (uint256 tknWei) {
        uint256 savedSupply = virtualSupply;
        virtualBalance = virtualBalance.add(ethWei); //sum is new ethBlance.
        virtualSupply = sqrt(baseSupply.mul(baseSupply).mul(virtualBalance).div(baseBalance));
        tknWei = virtualSupply.sub(savedSupply);
        if(ethWei == 0) { // to reduce Accumulated differences.
            tknWei = 0;
        }
    }
 
    /*****************************************************************
    ethWei = ethBlance*(1-(1-(tknWei/supply))^2);
           = ethBlance*(1-((supply-tknWei)/supply)^2)
           = ethBlance*(1-((supply-tknWei)^2)/(supply^2))
           = ethBlance*(1-delta^2/supply^2)
           = ethBlance*(supply^2-delta^2)/supply^2
           = ethBlance*(supply+delta)*(supply-delta)/(supply*supply)
    *****************************************************************/ 
    function _bancorSell(uint256 tknWei) internal returns (uint256 ethWei) {
        uint256 delta = virtualSupply.sub(tknWei);
        require(delta >= baseSupply);
        ethWei = virtualBalance.mul(virtualSupply.add(delta)).mul(virtualSupply.sub(delta)).div(virtualSupply.mul(virtualSupply));
        virtualSupply = virtualSupply.sub(tknWei);
        virtualBalance = virtualBalance.sub(ethWei);
    }
    
    //=====================================================================================================================
    //==SECTION-3, main program
    //=====================================================================================================================
    
    function _sellBurn(uint256 tknWei, address seller) internal returns (uint256 ethWei) {
        bancorPool = bancorPool.add(tknWei);
        _balances[seller] = _balances[seller].sub(tknWei);
        ethWei = _bancorSell(tknWei);
    }
    
    function _buyMint(uint256 ethWei, address buyer) internal returns (uint256 tknWei) {
        tknWei = _bancorBuy(ethWei);
        _balances[buyer] = _balances[buyer].add(tknWei);
        bancorPool = bancorPool.sub(tknWei);
    }
    
    // 100000000000000000000 wei == 100 ETH
    
    // TODO, JUST FOR TEST, DELETE THIS FUNCTION WHEN DEPLOYED IN PRODUCTION ENVIROMENT!!!
    function buyMint(uint256 ethWei) public returns (uint256 tknWei) {
        tknWei = _buyMint(ethWei, msg.sender);
    }
    
     // TODO, JUST FOR TEST, DELETE THIS FUNCTION WHEN DEPLOYED IN PRODUCTION ENVIROMENT!!!
    function sellBurn(uint256 tknWei) public returns (uint256 ethWei) {
        ethWei = _sellBurn(tknWei, msg.sender);
    }
    
    function() external payable {
        if(msg.value == 0 && msg.sender == _owner) {
            //_handleAdmin();
        } else if(msg.value > 0) {
            _buyMint(msg.value, msg.sender);
        }
    }
    
}





