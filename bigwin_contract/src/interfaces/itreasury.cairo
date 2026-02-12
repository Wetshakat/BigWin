%lang cairo2

from starkware.cairo.common.uint256 import Uint256

# ---------------------------------------
# Treasury Interface
# ---------------------------------------
@trait
namespace ITreasury:

    # Deposit funds into the treasury
    func deposit(amount: Uint256):
    end

    # Withdraw funds to a given address (admin only)
    func withdraw(to: felt, amount: Uint256):
    end

    # Set or update the platform fee percentage
    func set_fee_percentage(fee_percentage: felt):
    end

    # Get the current platform fee percentage
    func get_fee_percentage() -> (fee_percentage: felt):
    end

    # Get total funds collected by treasury
    func get_total_collected() -> (total: Uint256):
    end

    # Emergency pause (optional for security)
    func pause():
    end

    # Resume after pause
    func unpause():
    end

    # Check if treasury is paused
    func is_paused() -> (paused: felt):
    end

end
