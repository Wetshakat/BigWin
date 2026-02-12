%lang cairo2

from starkware.cairo.common.uint256 import Uint256, uint256_mul, uint256_div

# --------------------------------------------
# Fee Library
# --------------------------------------------
namespace FeeLib:

    # Calculate the platform fee based on a given amount and percentage
    # amount: Uint256 — the total prize pool
    # fee_percentage: felt — percentage in whole numbers (e.g., 2 for 2%)
    # Returns: Uint256 — the fee amount
    func calculate_fee(amount: Uint256, fee_percentage: felt) -> (fee: Uint256):
        # Multiply amount by fee_percentage
        let (mul_result) = uint256_mul(amount, Uint256(fee_percentage, 0))
        
        # Divide by 100 to get the percentage
        let (result) = uint256_div(mul_result, Uint256(100, 0))
        return (fee=result)
    end

    # Calculate the net amount after deducting the fee
    func net_amount(amount: Uint256, fee_percentage: felt) -> (net: Uint256):
        let (fee) = calculate_fee(amount, fee_percentage)
        let (net_amount) = uint256_sub(amount, fee)
        return (net=net_amount)
    end

end
