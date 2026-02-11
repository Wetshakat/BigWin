# BigWin — Smart Contract Architecture & Cairo Contracts README

## Overview

This document outlines the on‑chain architecture of **BigWin**, a Starknet‑based digital lottery platform. It details contract modularization, storage design, execution flow, and integration considerations for developers contributing to the protocol.

BigWin smart contracts are written in **Cairo** and deployed on **Starknet** to ensure transparency, automation, and verifiable fairness for every lottery round.

---

# 1. Architecture Summary

The protocol follows a modular contract design to ensure upgradeability, auditability, and separation of concerns.

## Core Components

1. **Round Manager Contract**
2. **Lottery Round Contract**
3. **Randomness Provider Interface**
4. **Treasury Contract**
5. **Fee Manager Contract**
6. **Refund Vault**

```
User → Round Manager → Lottery Round
                         ↓
                Randomness Provider
                         ↓
                      Winner
                         ↓
        Treasury → Fee Distribution
```

---

# 2. Contract Modules

## 2.1 Round Manager Contract

### Responsibility

The Round Manager orchestrates the lifecycle of all lottery rounds.

### Core Functions

* Create new rounds automatically
* Track active and completed rounds
* Route players to the current open round
* Enforce max player limits
* Trigger round closure

### Key Storage

```cairo
struct RoundManagerStorage {
    current_round_id: felt252,
    total_rounds: felt252,
    max_players_per_round: felt252,
    round_duration: felt252
}
```

---

## 2.2 Lottery Round Contract

Each round is instantiated as an isolated contract instance.

### Responsibility

* Accept player entries
* Store participants
* Manage prize pool
* Request randomness
* Execute winner selection
* Distribute rewards

### Key Storage

```cairo
struct RoundStorage {
    round_id: felt252,
    players: Array<ContractAddress>,
    entry_fee: u256,
    prize_pool: u256,
    start_time: u64,
    end_time: u64,
    is_closed: bool,
    winner: ContractAddress
}
```

---

## 2.3 Randomness Provider Interface

Fair winner selection requires verifiable randomness.

### Options

* Chainlink VRF (when available on Starknet)
* Pragma Oracle RNG
* Custom commit‑reveal scheme

### Interface Example

```cairo
trait IRandomnessProvider {
    fn request_randomness(round_id: felt252) -> felt252;
    fn fulfill_randomness(round_id: felt252, random: felt252);
}
```

---

## 2.4 Treasury Contract

### Responsibility

* Hold platform fees
* Receive fee cuts from rounds
* Manage withdrawals
* Route sponsorship funds

### Storage Example

```cairo
struct TreasuryStorage {
    total_fees_collected: u256,
    fee_percentage: felt252
}
```

---

## 2.5 Fee Manager

Separates fee logic from round execution.

### Functions

* Calculate platform fee
* Deduct fee from prize pool
* Forward remainder to winner

```cairo
fn calculate_fee(amount: u256, fee_percentage: felt252) -> u256;
```

---

## 2.6 Refund Vault

Handles failed or incomplete rounds.

### Trigger Conditions

* Round expires without minimum players
* Contract error
* Emergency cancellation

### Responsibilities

* Store refundable balances
* Allow players to withdraw funds

---

# 3. Round Lifecycle Flow

## Step 1 — Player Entry

1. User calls `enter_round()`
2. Entry fee is transferred
3. Player address stored
4. Prize pool updates

---

## Step 2 — Capacity / Time Check

Round closes when:

* Player count = 50
  **OR**
* `block_timestamp >= end_time`

---

## Step 3 — Randomness Request

```cairo
request_randomness(round_id)
```

Random value determines winner index.

---

## Step 4 — Winner Selection

```cairo
winner_index = random % players.len()
winner = players[winner_index]
```

---

## Step 5 — Prize Distribution

1. Platform fee deducted
2. Remaining prize sent to winner
3. Treasury receives fee

---

## Step 6 — New Round Creation

Round Manager automatically deploys the next round.

---

# 4. Entry & Prize Economics

| Parameter    | Value (Configurable) |
| ------------ | -------------------- |
| Max Players  | 50                   |
| Entry Fee    | Variable             |
| Platform Fee | ~2%                  |
| Prize Pool   | Entry × Players      |

---

# 5. Security Considerations

## 5.1 Sybil Resistance

* Optional wallet reputation checks
* Entry caps per wallet (future)

## 5.2 Randomness Integrity

* Use VRF where possible
* Prevent validator manipulation

## 5.3 Reentrancy Protection

* Checks‑effects‑interactions pattern
* Starknet syscall guards

## 5.4 Emergency Pause

Admin pause in case of exploit.

---

# 6. Events

Events enable frontend indexing and analytics.

```cairo
@event
fn PlayerEntered(round_id: felt252, player: ContractAddress);

@event
fn RoundClosed(round_id: felt252);

@event
fn WinnerSelected(round_id: felt252, winner: ContractAddress, prize: u256);
```

---

# 7. Developer Setup

## Prerequisites

* Scarb
* Starknet Foundry
* Cairo ≥ 2.x

## Install Dependencies

```bash
scarb build
```

## Run Tests

```bash
snforge test
```

## Deploy Contract

```bash
starknet deploy \
  --class-hash <compiled_hash> \
  --account <account> \
  --network alpha-mainnet
```

---

# 8. Frontend Integration

Frontend interacts via Starknet.js / Viem.

### Core Calls

* Enter Round
* Fetch Active Round
* Get Players
* View Prize Pool
* Claim Refund

---

# 9. Upgradeability Strategy

Options:

* Proxy pattern
* Class hash replacement
* Modular contract migration

Governance approval required for upgrades.

---

# 10. Future Contract Extensions

* Multi‑winner rounds
* NFT ticketing
* Referral rewards
* Staking pools
* DAO fee governance

---

**BigWin Smart Contracts power a fully automated, transparent, and scalable lottery ecosystem on Starknet.**
