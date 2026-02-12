%lang cairo2

from starkware.cairo.common.uint256 import Uint256

# ---------------------------------------
# LotteryRound Interface
# ---------------------------------------
@trait
namespace ILotteryRound:

    # Player enters the lottery round
    func enter(player: felt):
    end

    # Close the round manually (triggers winner selection)
    func close():
    end

    # Request randomness for winner selection
    func request_randomness():
    end

    # Fulfill randomness and select winner (called by RNG provider)
    func fulfill_randomness(random: felt):
    end

    # Claim prize (if not auto-paid)
    func claim_prize(player: felt):
    end

    # Refund entry fee if round didn't fill
    func claim_refund(player: felt):
    end

    # -------------------------
    # Read-only Views
    # -------------------------

    # Returns round ID
    func get_round_id() -> (round_id: felt):
    end

    # Returns prize pool
    func get_prize_pool() -> (prize: Uint256):
    end

    # Returns list of player addresses (optional for frontend)
    func get_players() -> (players_len: felt, players: felt*):
    end

    # Returns winner address (0 if not selected yet)
    func get_winner() -> (winner: felt):
    end

    # Returns whether the round is closed
    func is_closed() -> (closed: felt):
    end

    # Returns the entry fee
    func get_entry_fee() -> (fee: Uint256):
    end

    # Returns the max players allowed
    func get_max_players() -> (max_players: felt):
    end

end
