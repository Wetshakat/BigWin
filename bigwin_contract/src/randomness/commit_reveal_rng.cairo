%lang cairo2

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

# --------------------------------------------
# Storage Variables
# --------------------------------------------
@storage_var
func commits(round_id: felt) -> (commitment: felt):
end

@storage_var
func revealed(round_id: felt) -> (revealed: felt):
end

# --------------------------------------------
# Events
# --------------------------------------------
@event
func RandomnessCommitted(round_id: felt, commitment: felt):
end

@event
func RandomnessRevealed(round_id: felt, randomness: felt):
end

# --------------------------------------------
# Commit randomness (player or admin)
# --------------------------------------------
@external
func commit_randomness{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(round_id: felt, commitment: felt):
    commits.write(round_id, commitment)
    emit RandomnessCommitted(round_id, commitment)
    return ()
end

# --------------------------------------------
# Reveal randomness
# --------------------------------------------
@external
func reveal_randomness{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(round_id: felt, randomness: felt, salt: felt):
    # Verify commitment
    let stored_commit = commits.read(round_id)
    let calc_commit = pedersen_hash(randomness, salt)
    assert stored_commit == calc_commit, 'INVALID_REVEAL'

    revealed.write(round_id, randomness)
    emit RandomnessRevealed(round_id, randomness)
    return ()
end

# --------------------------------------------
# View functions
# --------------------------------------------
@view
func get_commit(round_id: felt) -> (commitment: felt):
    let commitment = commits.read(round_id)
    return (commitment)
end

@view
func get_revealed(round_id: felt) -> (randomness: felt):
    let randomness = revealed.read(round_id)
    return (randomness)
end

# --------------------------------------------
# Pedersen Hash Helper
# --------------------------------------------
func pedersen_hash(a: felt, b: felt) -> (res: felt):
    # Simple wrapper (replace with Starkware pedersen if needed)
    let res = a + b  # Placeholder, replace with proper pedersen hash
    return (res)
end
