%lang cairo2

from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub
from contracts.interfaces.itreasury import ITreasury

# --------------------------------------------
# Storage Variables
# --------------------------------------------
@storage_var
func refunds(player: felt, round_id: felt) -> (res: Uint256):
end

@storage_var
func treasury_address() -> (res: felt):
end

# --------------------------------------------
# Events
# --------------------------------------------
@event
func RefundDeposited(player: felt, round_id: felt, amount: Uint256):
end

@event
func RefundClaimed(player: felt, round_id: felt, amount: Uint256):
end

# --------------------------------------------
# Constructor
# --------------------------------------------
@constructor
func constructor{
        syscall_ptr: felt*, range_check_ptr
    }(_treasury: felt):
    treasury_address.write(_treasury)
    return ()
end

# --------------------------------------------
# Deposit refund for a player
# --------------------------------------------
@external
func deposit_refund{
        syscall_ptr: felt*, range_check_ptr
    }(player: felt, round_id: felt, amount: Uint256):
    let current_refund = refunds.read(player, round_id)
    let new_refund = Uint256(current_refund.low + amount.low, current_refund.high + amount.high)
    refunds.write(player, round_id, new_refund)

    emit RefundDeposited(player, round_id, amount)
    return ()
end

# --------------------------------------------
# Claim refund
# --------------------------------------------
@external
func claim_refund{
        syscall_ptr: felt*, range_check_ptr
    }(player: felt, round_id: felt):
    let amount = refunds.read(player, round_id)
    assert amount.low + amount.high > 0, 'NO_REFUND'

    # Reset refund
    refunds.write(player, round_id, Uint256(0, 0))

    # Transfer amount to player (placeholder for actual Starknet transfer)
    # TODO: Implement transfer logic

    emit RefundClaimed(player, round_id, amount)
    return ()
end

# --------------------------------------------
# View Functions
# --------------------------------------------
@view
func get_refund(player: felt, round_id: felt) -> (amount: Uint256):
    let amount = refunds.read(player, round_id)
    return (amount)
end

@view
func get_treasury() -> (treasury: felt):
    let treasury = treasury_address.read()
    return (treasury)
end
