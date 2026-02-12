%lang cairo2

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub
from contracts.interfaces.itreasury import ITreasury

# --------------------------------------------
# Storage Variables
# --------------------------------------------
@storage_var
func total_collected() -> (res: Uint256):
end

@storage_var
func fee_percentage() -> (res: felt):
end

@storage_var
func owner() -> (res: felt):
end

@storage_var
func paused() -> (res: felt):
end

# --------------------------------------------
# Events
# --------------------------------------------
@event
func Deposit(amount: Uint256, from_: felt):
end

@event
func Withdraw(amount: Uint256, to_: felt):
end

@event
func FeeUpdated(new_fee: felt):
end

@event
func Paused():
end

@event
func Unpaused():
end

# --------------------------------------------
# Constructor
# --------------------------------------------
@constructor
func constructor{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(
        initial_fee: felt,
        owner_address: felt
    ):
    fee_percentage.write(initial_fee)
    owner.write(owner_address)
    paused.write(0)
    total_collected.write(Uint256(0, 0))
    return ()
end

# --------------------------------------------
# Deposit funds into treasury
# --------------------------------------------
@external
func deposit{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(amount: Uint256, from_: felt):
    let is_paused = paused.read()
    assert is_paused == 0, 'TREASURY_PAUSED'

    let (current_total) = total_collected.read()
    let (new_total) = uint256_add(current_total, amount)
    total_collected.write(new_total)

    emit Deposit(amount, from_)
    return ()
end

# --------------------------------------------
# Withdraw funds (admin only)
# --------------------------------------------
@external
func withdraw{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(to_: felt, amount: Uint256):
    let caller = owner.read()  # Replace with msg.sender if using actual access control
    assert caller != 0, 'NOT_OWNER'

    let (current_total) = total_collected.read()
    let (new_total) = uint256_sub(current_total, amount)
    total_collected.write(new_total)

    emit Withdraw(amount, to_)
    return ()
end

# --------------------------------------------
# Set fee percentage (admin only)
# --------------------------------------------
@external
func set_fee_percentage{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(new_fee: felt):
    let caller = owner.read()  # Replace with msg.sender in production
    assert caller != 0, 'NOT_OWNER'

    fee_percentage.write(new_fee)
    emit FeeUpdated(new_fee)
    return ()
end

# --------------------------------------------
# Pause treasury (admin only)
# --------------------------------------------
@external
func pause{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }():
    let caller = owner.read()
    assert caller != 0, 'NOT_OWNER'

    paused.write(1)
    emit Paused()
    return ()
end

# --------------------------------------------
# Unpause treasury (admin only)
# --------------------------------------------
@external
func unpause{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }():
    let caller = owner.read()
    assert caller != 0, 'NOT_OWNER'

    paused.write(0)
    emit Unpaused()
    return ()
end

# --------------------------------------------
# View Functions
# --------------------------------------------
@view
func get_fee_percentage() -> (fee: felt):
    let fee = fee_percentage.read()
    return (fee)
end

@view
func get_total_collected() -> (total: Uint256):
    let total = total_collected.read()
    return (total)
end

@view
func is_paused() -> (paused_status: felt):
    let paused_status = paused.read()
    return (paused_status)
end
