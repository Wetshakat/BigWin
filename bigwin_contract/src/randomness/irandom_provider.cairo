%lang cairo2

# --------------------------------------------
# Randomness Provider Interface
# --------------------------------------------
@trait
namespace IRandomProvider:

    # Request randomness for a given round
    func request_randomness(round_id: felt):
    end

    # Fulfill randomness for a round (called by provider)
    func fulfill_randomness(round_id: felt, random: felt):
    end

    # View function: get committed randomness (optional)
    func get_commit(round_id: felt) -> (commitment: felt):
    end

    # View function: get revealed randomness (optional)
    func get_revealed(round_id: felt) -> (randomness: felt):
    end

end
