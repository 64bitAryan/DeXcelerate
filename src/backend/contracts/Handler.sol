pragma solidity ^0.8.0;
import "./interfaces/IDeXcelRouter.sol";
import "./interfaces/IDeXcelFactory.sol";
import "./interfaces/IERC20.sol";

contract Handler {
    IDeXcelRouter router;
    IDeXcelFactory factory;

    constructor(address _router, address _factory) {
        router = IDeXcelRouter(_router);
        factory = IDeXcelFactory(_factory);
    }

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired,
        address _to
    ) public returns (bool) {
        uint time = block.timestamp + 3600;
        IERC20 tokenA = IERC20(_tokenA);
        IERC20 tokenB = IERC20(_tokenB);
        tokenA.approve(address(router), _amountADesired);
        tokenB.approve(address(router), _amountBDesired);
        router.addLiquidity(
            _tokenA,
            _tokenB,
            _amountADesired,
            _amountBDesired,
            0,
            0,
            _to,
            time
        );
        return true;
    }

    function addEthLiquidity(
        address _token,
        uint _amountTokenDesired,
        uint _amountEthMin,
        address _to
    ) public returns (bool) {
        IERC20 token = IERC20(_token);
        uint time = block.timestamp + 3600;
        token.approve(address(router), _amountTokenDesired);
        router.addLiquidityETH(
            _token,
            _amountTokenDesired,
            0,
            _amountEthMin,
            _to,
            time
        );
        return true;
    }

    function swapExactTokensForTokens(
        uint _amountIn,
        uint _amountOut,
        address[] calldata _path,
        address _to
    ) public returns (bool) {
        // Transfer 5 tokens b4 the swap
        IERC20 token = IERC20(_path[0]);
        token.approve(address(router), _amountIn);
        uint time = block.timestamp + 3600;
        router.swapExactTokensForTokens(
            _amountIn,
            _amountOut,
            _path,
            _to,
            time
        );
        return true;
    }

    function swapEthForExactTokens(
        uint _amountOut,
        address[] calldata _path,
        address _to
    ) public returns (bool) {
        uint time = block.timestamp + 3600;
        router.swapETHForExactTokens(_amountOut, _path, _to, time);
        return true;
    }
}
