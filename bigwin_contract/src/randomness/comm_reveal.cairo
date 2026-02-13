%lang cairo2

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.randomness.irandom_provider import IRandomProvider

# --------------------------------------------
# Pragma RNG Adapter
# --------------------------------------------
@storage_var
func rng_provider_address() -> (res: felt):
end

# --------------------------------------------
# Events
# --------------------------------------------
@event
func RandomnessRequested(round_id: felt):
end

@event
func RandomnessFulfilled(round_id: felt, random: felt):
end

# --------------------------------------------
# Constructor
# --------------------------------------------
@constructor
func constructor{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(_rng_provider: felt):
    rng_provider_address.write(_rng_provider)
    return ()
end

# --------------------------------------------
# Request randomness (called by LotteryRound)
# --------------------------------------------
@external
func request_randomness{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(round_id: felt):
    let rng = rng_provider_address.read()

    # Call RNG provider's commit/reveal request
    IRandomProvider.request_randomness(rng, round_id)

    emit RandomnessRequested(round_id)
    return ()
end

# --------------------------------------------
# Fulfill randomness (called by RNG provider)
# --------------------------------------------
@external
func fulfill_randomness{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(round_id: felt, random: felt):
    let rng = rng_provider_address.read()

    IRandomProvider.fulfill_randomness(rng, round_id, random)
    emit RandomnessFulfilled(round_id, random)
    return ()
end

# --------------------------------------------
# View functions
# --------------------------------------------
@view
func get_rng_provider() -> (rng: felt):
    let rng = rng_provider_address.read()
    return (rng)
end
