%lang cairo2

from starkware.cairo.common.uint256 import Uint256

# --------------------------------------------
# Global Configuration Storage
# --------------------------------------------
@storage_var
func default_entry_fee() -> (res: Uint256):
end

@storage_var
func default_max_players() -> (res: felt):
end

@storage_var
func default_round_duration() -> (res: felt):
end

@storage_var
func default_treasury() -> (res: felt):
end

@storage_var
func default_rng_provider() -> (res: felt):
end

@storage_var
func default_fee_percentage() -> (res: felt):
end

# --------------------------------------------
# Constructor
# --------------------------------------------
@constructor
func constructor{
        syscall_ptr: felt*, range_check_ptr
    }(
        entry_fee: Uint256,
        max_players: felt,
        round_duration: felt,
        treasury: felt,
        rng_provider: felt,
        fee_percentage: felt
    ):
    default_entry_fee.write(entry_fee)
    default_max_players.write(max_players)
    default_round_duration.write(round_duration)
    default_treasury.write(treasury)
    default_rng_provider.write(rng_provider)
    default_fee_percentage.write(fee_percentage)
    return ()
end

# --------------------------------------------
# Update Global Config (admin only)
# --------------------------------------------
@external
func set_entry_fee(entry_fee: Uint256):
    default_entry_fee.write(entry_fee)
    return ()
end

@external
func set_max_players(max_players: felt):
    default_max_players.write(max_players)
    return ()
end

@external
func set_round_duration(duration: felt):
    default_round_duration.write(duration)
    return ()
end

@external
func set_treasury(treasury: felt):
    default_treasury.write(treasury)
    return ()
end

@external
func set_rng_provider(rng_provider: felt):
    default_rng_provider.write(rng_provider)
    return ()
end

@external
func set_fee_percentage(fee_percentage: felt):
    default_fee_percentage.write(fee_percentage)
    return ()
end

# --------------------------------------------
# View Functions
# --------------------------------------------
@view
func get_entry_fee() -> (fee: Uint256):
    let fee = default_entry_fee.read()
    return (fee)
end

@view
func get_max_players() -> (max: felt):
    let max = default_max_players.read()
    return (max)
end

@view
func get_round_duration() -> (duration: felt):
    let duration = default_round_duration.read()
    return (duration)
end

@view
func get_treasury() -> (treasury: felt):
    let treasury = default_treasury.read()
    return (treasury)
end

@view
func get_rng_provider() -> (rng_provider: felt):
    let rng_provider = default_rng_provider.read()
    return (rng_provider)
end

@view
func get_fee_percentage() -> (fee: felt):
    let fee = default_fee_percentage.read()
    return (fee)
end
