%lang cairo2

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_le_felt

from contracts.interfaces.ilottery_round import ILotteryRound
from contracts.core.treasury import ITreasury
from contracts.libraries.array_utils import ArrayUtils
from contracts.libraries.fee_lib import FeeLib
from contracts.libraries.math import MathLib
from contracts.interfaces.irandom_provider import IRandomProvider

# --------------------------------------------
# Storage Variables
# --------------------------------------------
@storage_var
func round_id() -> (res: felt):
end

@storage_var
func players_len() -> (res: felt):
end

@storage_var
func players(i: felt) -> (res: felt):
end

@storage_var
func entry_fee() -> (res: Uint256):
end

@storage_var
func max_players() -> (res: felt):
end

@storage_var
func prize_pool() -> (res: Uint256):
end

@storage_var
func winner() -> (res: felt):
end

@storage_var
func closed() -> (res: felt):
end

@storage_var
func treasury_address() -> (res: felt):
end

@storage_var
func rng_provider() -> (res: felt):
end

# --------------------------------------------
# Events
# --------------------------------------------
@event
func PlayerJoined(player: felt):
end

@event
func WinnerSelected(winner: felt, prize: Uint256):
end

@event
func RefundIssued(player: felt, amount: Uint256):
end

# --------------------------------------------
# Constructor
# --------------------------------------------
@constructor
func constructor{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(
        _round_id: felt,
        _entry_fee: Uint256,
        _max_players: felt,
        _treasury: felt,
        _rng_provider: felt
    ):
    round_id.write(_round_id)
    entry_fee.write(_entry_fee)
    max_players.write(_max_players)
    treasury_address.write(_treasury)
    rng_provider.write(_rng_provider)

    players_len.write(0)
    prize_pool.write(Uint256(0, 0))
    winner.write(0)
    closed.write(0)

    return ()
end

# --------------------------------------------
# Player joins the lottery
# --------------------------------------------
@external
func enter{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(player: felt):

    # Check if round is closed
    let is_closed = closed.read()
    assert is_closed == 0, 'ROUND_CLOSED'

    # Add player to array
    let players_ptr: felt* = players
    let len_ptr: felt* = players_len
    let max_p = max_players.read()
    ArrayUtils.append(players_ptr, len_ptr, max_p, player)

    # Update prize pool
    let fee = entry_fee.read()
    let (new_prize_pool) = MathLib.add(prize_pool.read(), fee)
    prize_pool.write(new_prize_pool)

    emit PlayerJoined(player)

    # Auto-close if max players reached
    let curr_len = players_len.read()
    if curr_len == max_p:
        close()
    end

    return ()
end

# --------------------------------------------
# Close round manually
# --------------------------------------------
@external
func close{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }():
    let is_closed = closed.read()
    assert is_closed == 0, 'ROUND_ALREADY_CLOSED'
    closed.write(1)

    # Request randomness for winner selection
    let rng = rng_provider.read()
    IRandomProvider.request_randomness(rng, round_id.read())
    return ()
end

# --------------------------------------------
# Fulfill randomness & select winner
# --------------------------------------------
@external
func fulfill_randomness{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(random: felt):

    let is_closed = closed.read()
    assert is_closed == 1, 'ROUND_NOT_CLOSED'

    let len = players_len.read()
    assert len > 0, 'NO_PLAYERS'

    # Compute winner index
    let winner_index = random % len
    let winner_addr = players.read(winner_index)
    winner.write(winner_addr)

    # Calculate platform fee (2% assumed, can be dynamic)
    let pool = prize_pool.read()
    let treasury = treasury_address.read()
    let (fee_amount) = FeeLib.calculate_fee(pool, 2)

    # Deposit fee to treasury
    ITreasury.deposit(treasury, fee_amount, 0)  # player=0 for internal

    # Update prize pool after fee
    let (net_prize) = FeeLib.net_amount(pool, 2)
    prize_pool.write(net_prize)

    emit WinnerSelected(winner_addr, net_prize)
    return ()
end

# --------------------------------------------
# Claim prize (manual payout)
# --------------------------------------------
@external
func claim_prize{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(player: felt):
    let w = winner.read()
    assert w == player, 'NOT_WINNER'

    let prize = prize_pool.read()
    prize_pool.write(Uint256(0, 0))

    # TODO: Transfer prize to player (replace with Starknet transfer logic)
    return ()
end

# --------------------------------------------
# Refund if round didn't fill
# --------------------------------------------
@external
func claim_refund{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(player: felt):
    let is_closed = closed.read()
    assert is_closed == 0, 'ROUND_CLOSED'

    # Check if player exists
    let len = players_len.read()
    let exists = ArrayUtils.contains(players, len, player)
    assert exists == 1, 'PLAYER_NOT_FOUND'

    # Refund logic
    let fee = entry_fee.read()
    # TODO: Transfer fee back to player

    emit RefundIssued(player, fee)
    return ()
end

# --------------------------------------------
# View Functions
# --------------------------------------------
@view
func get_round_id() -> (rid: felt):
    let rid = round_id.read()
    return (rid)
end

@view
func get_prize_pool() -> (pool: Uint256):
    let pool = prize_pool.read()
    return (pool)
end

@view
func get_winner() -> (w: felt):
    let w = winner.read()
    return (w)
end

@view
func get_players() -> (players_len_out: felt, players_ptr_out: felt*):
    let len = players_len.read()
    return (players_len_out=len, players_ptr_out=players)
end

@view
func is_closed() -> (c: felt):
    let c = closed.read()
    return (c)
end

@view
func get_entry_fee() -> (fee: Uint256):
    let fee = entry_fee.read()
    return (fee)
end

@view
func get_max_players() -> (max: felt):
    let max = max_players.read()
    return (max)
end
