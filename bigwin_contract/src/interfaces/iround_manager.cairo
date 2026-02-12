%lang cairo2

from starkware.cairo.common.uint256 import Uint256

# -----------------------------
# RoundManager Interface
# -----------------------------
@trait
namespace IRoundManager:

    # Create a new lottery round and return its address
    func create_round() -> (round_address: felt):
    end

    # Let a player join the current active round
    func enter_current_round(player: felt):
    end

    # Close the current active round manually
    func close_current_round():
    end

    # -------------------------
    # Admin / Configuration
    # -------------------------

    # Update the entry fee for rounds
    func set_entry_fee(new_fee: Uint256):
    end

    # Update maximum number of players per round
    func set_max_players(max_players: felt):
    end

    # Update the duration of each round (in seconds)
    func set_round_duration(duration: felt):
    end

    # Set the treasury contract address
    func set_treasury(treasury: felt):
    end

    # Set the randomness provider contract
    func set_randomness_provider(rng_provider: felt):
    end

    # -------------------------
    # Read-only Views
    # -------------------------

    # Returns the current active round address
    func get_active_round() -> (round_address: felt):
    end

    # Returns the current round ID
    func get_current_round_id() -> (round_id: felt):
    end

    # Returns total rounds created so far
    func get_total_rounds() -> (total: felt):
    end

    # Returns the entry fee
    func get_entry_fee() -> (fee: Uint256):
    end

    # Returns the maximum players per round
    func get_max_players() -> (max_players: felt):
    end

    # Returns the round duration
    func get_round_duration() -> (duration: felt):
    end

    # Returns the treasury address
    func get_treasury() -> (treasury: felt):
    end

    # Returns the randomness provider
    func get_randomness_provider() -> (rng_provider: felt):
    end

end
