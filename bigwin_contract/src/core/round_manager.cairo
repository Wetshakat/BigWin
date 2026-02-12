%lang cairo2

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_le_felt

from contracts.core.lottery_round import LotteryRound
from contracts.interfaces.irandom_provider import IRandomProvider
from contracts.core.treasury import Treasury

# --------------------------------------------
# Storage Variables
# --------------------------------------------
@storage_var
func current_round_id() -> (res: felt):
end

@storage_var
func total_rounds() -> (res: felt):
end

@storage_var
func max_players_per_round() -> (res: felt):
end

@storage_var
func round_duration() -> (res: felt):
end

@storage_var
func entry_fee() -> (res: Uint256):
end

@storage_var
func active_round() -> (res: felt):
end

@storage_var
func treasury_address() -> (res: felt):
end

@storage_var
func randomness_provider() -> (res: felt):
end

# --------------------------------------------
# Events
# --------------------------------------------
@event
func RoundCreated(round_id: felt, round_address: felt):
end

@event
func RoundClosed(round_id: felt):
end

@event
func PlayerEntered(round_id: felt, player: felt):
end

# --------------------------------------------
# Constructor
# --------------------------------------------
@constructor
func constructor{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(
        max_players: felt,
        duration: felt,
        fee: Uint256,
        treasury: felt,
        rng_provider: felt
    ):
    max_players_per_round.write(max_players)
    round_duration.write(duration)
    entry_fee.write(fee)
    treasury_address.write(treasury)
    randomness_provider.write(rng_provider)

    total_rounds.write(0)
    current_round_id.write(0)
    active_round.write(0)

    return ()
end

# --------------------------------------------
# Create a new lottery round
# --------------------------------------------
@external
func create_round{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }() -> (round_address: felt):

    let (round_id) = total_rounds.read()
    let new_round_id = round_id + 1

    # Read config
    let (fee) = entry_fee.read()
    let (max_players) = max_players_per_round.read()
    let (duration) = round_duration.read()
    let (treasury) = treasury_address.read()
    let (rng) = randomness_provider.read()

    # Deploy new round (placeholder)
    let (round_addr) = deploy_new_round(new_round_id, fee, max_players, duration, treasury, rng)

    # Update storage
    active_round.write(round_addr)
    total_rounds.write(new_round_id)
    current_round_id.write(new_round_id)

    emit RoundCreated(new_round_id, round_addr)
    return (round_address=round_addr)
end

# --------------------------------------------
# Deploy new LotteryRound (placeholder)
# --------------------------------------------
func deploy_new_round{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(
        round_id: felt,
        fee: Uint256,
        max_players: felt,
        duration: felt,
        treasury: felt,
        rng_provider: felt
    ) -> (round_address: felt):

    # TODO: Replace with actual Starknet deploy logic using class hash
    let round_address = 0
    return (round_address)
end

# --------------------------------------------
# Player joins the current active round
# --------------------------------------------
@external
func enter_current_round{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(player: felt):

    let (round_addr) = active_round.read()
    assert round_addr != 0, 'NO_ACTIVE_ROUND'

    # Call LotteryRound contract's enter function
    LotteryRound.enter(round_addr, player)

    # Emit event
    let (round_id) = current_round_id.read()
    emit PlayerEntered(round_id, player)
    return ()
end

# --------------------------------------------
# Close current round manually
# --------------------------------------------
@external
func close_current_round{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }():

    let (round_addr) = active_round.read()
    assert round_addr != 0, 'NO_ACTIVE_ROUND'

    LotteryRound.close(round_addr)
    let (round_id) = current_round_id.read()

    emit RoundClosed(round_id)

    active_round.write(0)
    return ()
end

# --------------------------------------------
# Admin Setters
# --------------------------------------------
@external
func set_entry_fee{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(new_fee: Uint256):
    entry_fee.write(new_fee)
    return ()
end

@external
func set_max_players{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(max_players: felt):
    max_players_per_round.write(max_players)
    return ()
end

@external
func set_round_duration{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(duration: felt):
    round_duration.write(duration)
    return ()
end

@external
func set_treasury{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(treasury: felt):
    treasury_address.write(treasury)
    return ()
end

@external
func set_randomness_provider{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(rng_provider: felt):
    randomness_provider.write(rng_provider)
    return ()
end
