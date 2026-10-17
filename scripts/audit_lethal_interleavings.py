"""Offline branch model of native terminal-result observations; never runs PZ.

Assumes serialized, successful native completion for a loaded, eligible target.
Does not emulate Hit, callbacks, Kahlua, transport, animation, streaming or saves.
Counterexamples concern stated branch assumptions, not measured engine failures.
"""

import argparse
from dataclasses import dataclass
import json


@dataclass
class Server:
    health: int = 100
    mapped: bool = True
    kill_done: bool = False
    body: bool = False
    corpses: int = 0
    publications: int = 0
    player_hits: int = 0
    killer: str | None = None

    def finalize(self, killer):
        # Abstracts successful Kill + die + constructor + listener completion.
        self.health = 0
        if not self.kill_done:
            self.killer = killer
            self.kill_done = True
        if not self.body:
            self.mapped = False
            self.body = True
            self.corpses += 1
            self.publications += 1

    def support(self):
        # Candidate requires a live mapped target; does not touch completed kills.
        if self.mapped and self.health > 0 and not self.kill_done:
            self.finalize(None)

    def player(self, damage):
        if self.mapped and self.health > 0:
            self.player_hits += 1
            self.health -= damage
            if self.health <= 0:
                self.finalize("player")

    def owner_snapshot(self, health):
        # Assumes the sender is the current owner; missing map entry rejects it.
        if self.mapped:
            self.health = health


@dataclass
class Client:
    live: bool = True
    corpse: bool = False
    age_hours: float = 0

    def death(self):
        # Assumes native postponement/animation/square order eventually complete.
        if self.live:
            self.live = False
            self.corpse = True

    def snapshot(self):
        if not self.live and not (self.corpse and self.age_hours < 0.1):
            self.live = True


def evaluate():
    cases = []

    def record(name, passed, counterexample=False):
        if not passed:
            raise AssertionError(name)
        cases.append(dict(case=name, expected_counterexample=counterexample))

    for damage in (10, 100):
        for player_first in (True, False):
            state = Server()
            if player_first:
                state.player(damage)
                state.support()
            else:
                state.support()
                state.player(damage)
            expected_killer = "player" if player_first and damage == 100 else None
            record(f"server/player={damage}/player_first={player_first}",
                   state.corpses == state.publications == 1 and not state.mapped
                   and state.killer == expected_killer
                   and state.player_hits == int(player_first))

    state = Server()
    state.support()
    state.owner_snapshot(100)
    record("server/old_owner_after_finalization", state.health == 0 and not state.mapped)
    state.support()
    record("server/support_replay_rejected", state.corpses == state.publications == 1)

    raw = Server(health=0)
    record("counter/setter_is_not_completion", raw.mapped and not raw.body, True)
    raw.owner_snapshot(100)
    record("counter/setter_then_owner_snapshot", raw.health == 100 and not raw.body, True)
    reused = Server(health=80)  # A different target reused the old short ID/owner.
    reused.owner_snapshot(100)
    record("counter/short_id_reuse_is_not_a_tombstone", reused.health == 100, True)

    for death_first in (True, False):
        client = Client()
        if death_first:
            client.death()
            client.snapshot()
        else:
            client.snapshot()
            client.death()
        record(f"client/recent_loaded/death_first={death_first}", client.corpse and not client.live)
    client.death()
    record("client/duplicate_death_requires_live_target", client.corpse and not client.live)

    for age in (0.1, 0.2):
        client = Client()
        client.death()
        client.age_hours = age
        client.snapshot()
        record(f"counter/client_guard_expired/age={age}", client.live and client.corpse, True)
    client = Client()
    client.death()
    client.corpse = False  # No registered body remains visible to isDead(short).
    client.snapshot()
    record("counter/client_guard_body_absent", client.live, True)
    client = Client(live=False)
    client.death()  # No resolvable target: death packet alone cannot create it.
    record("counter/client_death_target_missing", not client.corpse, True)
    client.corpse = True  # Assumes a later authoritative chunk includes the corpse.
    record("client/chunk_contains_body", client.corpse and not client.live)
    return cases


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    cases = evaluate()
    result = dict(environment="offline abstract branch model; PZ NOT TESTED",
                  cases=len(cases),
                  counterexamples=sum(c["expected_counterexample"] for c in cases),
                  results=cases)
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"MODEL ASSERTIONS PASS: {result['cases']} cases, "
              f"{result['counterexamples']} expected limitation counterexamples.")
        print(result["environment"])


if __name__ == "__main__":
    main()
