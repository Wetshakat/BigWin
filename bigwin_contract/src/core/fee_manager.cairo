%lang cairo2

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from contracts.libraries.fee_lib import FeeLib
from contracts.core.treasury import ITreasury

# --------------------------------------------
# Storage Variables
# --------------------------------------------
@storage_var
func treasury_address() -> (res: felt):
end

@storage_var
func fee_percentage() -> (res: felt):
end

# --------------------------------------------
# Events
# --------------------------------------------
@event
func FeeDeposited(amount: Uint256, treasury: felt):
end

@event
func FeeUpdated(new_fee: felt):
end

# --------------------------------------------
# Constructor
# --------------------------------------------
@constructor
func constructor{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(_treasury: felt, _fee_percentage: felt):
    treasury_address.write(_treasury)
    fee_percentage.write(_fee_percentage)
    return ()
end

# --------------------------------------------
# Deposit fee to treasury
# --------------------------------------------
@external
func deposit_fee{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(amount: Uint256):
    let treasury = treasury_address.read()
    let fee_pct = fee_percentage.read()

    # Calculate fee
    let (fee_amount) = FeeLib.calculate_fee(amount, fee_pct)

    # Deposit to treasury
    ITreasury.deposit(treasury, fee_amount, 0)  # 0 as internal sender

    emit FeeDeposited(fee_amount, treasury)
    return ()
end

# --------------------------------------------
# Update fee percentage (admin)
# --------------------------------------------
@external
func set_fee_percentage{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(_fee_percentage: felt):
    fee_percentage.write(_fee_percentage)
    emit FeeUpdated(_fee_percentage)
    return ()
end

# --------------------------------------------
# View functions
# --------------------------------------------
@view
func get_fee_percentage() -> (fee: felt):
    let fee = fee_percentage.read()
    return (fee)
end

@view
func get_treasury() -> (treasury: felt):
    let treasury = treasury_address.read()
    return (treasury)
end
