%lang cairo2

from starkware.cairo.common.uint256 import Uint256

# --------------------------------------------
# Round Storage Variables
# --------------------------------------------
@storage_var
func round_prize_pool(round_id: felt) -> (res: Uint256):
end

@storage_var
func round_players_len(round_id: felt) -> (res: felt):
end

@storage_var
func round_players(round_id: felt, index: felt) -> (res: felt):
end

@storage_var
func round_winner(round_id: felt) -> (res: felt):
end

@storage_var
func round_closed(round_id: felt) -> (res: felt):
end

# --------------------------------------------
# Player Management
# --------------------------------------------
@external
func add_player(round_id: felt, player: felt):
    let len = round_players_len.read(round_id)
    round_players.write(round_id, len, player)
    round_players_len.write(round_id, len + 1)
    return ()
end

@view
func get_players(round_id: felt) -> (players_len: felt, players_ptr: felt*):
    let len = round_players_len.read(round_id)
    return (players_len=len, players_ptr=cast(0, felt*))  # Storage pointer placeholder
end

# --------------------------------------------
# Prize Pool Management
# --------------------------------------------
@external
func add_to_prize_pool(round_id: felt, amount: Uint256):
    let current_pool = round_prize_pool.read(round_id)
    let new_pool = Uint256(current_pool.low + amount.low, current_pool.high + amount.high)
    round_prize_pool.write(round_id, new_pool)
    return ()
end

@view
func get_prize_pool(round_id: felt) -> (pool: Uint256):
    let pool = round_prize_pool.read(round_id)
    return (pool)
end

# --------------------------------------------
# Winner Management
# --------------------------------------------
@external
func set_winner(round_id: felt, winner: felt):
    round_winner.write(round_id, winner)
    return ()
end

@view
func get_winner(round_id: felt) -> (winner: felt):
    let w = round_winner.read(round_id)
    return (w)
end

# --------------------------------------------
# Round Status
# --------------------------------------------
@external
func close_round(round_id: felt):
    round_closed.write(round_id, 1)
    return ()
end

@view
func is_closed(round_id: felt) -> (closed: felt):
    let c = round_closed.read(round_id)
    return (c)
end
