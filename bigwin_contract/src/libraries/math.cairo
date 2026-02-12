%lang cairo2

from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub, uint256_mul, uint256_div

# --------------------------------------------
# Math Utilities Library
# --------------------------------------------
namespace MathLib:

    # Add two Uint256 numbers
    func add(a: Uint256, b: Uint256) -> (res: Uint256):
        let (res) = uint256_add(a, b)
        return (res)
    end

    # Subtract two Uint256 numbers
    func sub(a: Uint256, b: Uint256) -> (res: Uint256):
        let (res) = uint256_sub(a, b)
        return (res)
    end

    # Multiply two Uint256 numbers
    func mul(a: Uint256, b: Uint256) -> (res: Uint256):
        let (res) = uint256_mul(a, b)
        return (res)
    end

    # Divide two Uint256 numbers (integer division)
    func div(a: Uint256, b: Uint256) -> (res: Uint256):
        let (res) = uint256_div(a, b)
        return (res)
    end

    # Multiply Uint256 by a felt (for percentages)
    func mul_by_felt(a: Uint256, b: felt) -> (res: Uint256):
        let (b_uint) = Uint256(b, 0)
        let (res) = uint256_mul(a, b_uint)
        return (res)
    end

    # Divide Uint256 by a felt (for percentages)
    func div_by_felt(a: Uint256, b: felt) -> (res: Uint256):
        let (b_uint) = Uint256(b, 0)
        let (res) = uint256_div(a, b_uint)
        return (res)
    end

end
