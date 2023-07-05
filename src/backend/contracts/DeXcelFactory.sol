// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IDeXcelFactory.sol";
import "./DeXcelPair.sol";
import "./interfaces/IERC20.sol";

contract DeXcelFactory is IDeXcelFactory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {
        require(tokenA != tokenB, "DeXcelerate factory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "DeXcelerate factory: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "DeXcelerate factory: PAIR_EXISTS"
        ); // single check is sufficient

        // getting bytecode of the contract to create
        bytes memory bytecode = type(DeXcelPair).creationCode;
        // creating salt
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(
                0, // value we want to sent
                add(bytecode, 32), //code start after skipping first 32 bytes
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                salt // salt
            )
        }
        IDeXcelPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);

        // Get token names
        string memory name0 = IERC20(token0).name();
        string memory name1 = IERC20(token1).name();

        emit PairCreated(token0, token1, pair, name0, name1, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "DeXcelerate factory: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "DeXcelerate factory: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
