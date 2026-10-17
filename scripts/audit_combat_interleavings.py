"""Offline integer-state counterexamples; no PZ API, network or runtime code.

These bounded schedules test stated assumptions, not all Lua protocols or native
damage semantics. A counterexample reproduced successfully is not combat PASS.
"""

import argparse
import json
from itertools import permutations


def evaluate():
    cases = []

    def record(name, actual, required, expected_preservation):
        preserved = actual == required
        if preserved != expected_preservation:
            raise AssertionError((name, actual, required, expected_preservation))
        cases.append(dict(case=name, actual=actual, required=required,
                          preserves_damage=preserved))

    # Nonlethal integer deltas commute only if each executes once on one state.
    for order in permutations(("support", "player")):
        health = 100
        for event in order:
            health -= {"support": 20, "player": 10}[event]
        record("stable_delta/" + "/".join(order), health, 70, True)

    for order in permutations(("support", "replay", "player")):
        health, applied = 100, False
        for event in order:
            if event == "player":
                health -= 10
            elif not applied:
                health -= 20
                applied = True  # Assumed intact local dedup state; no handoff.
        record("stable_dedup/" + "/".join(order), health, 70, True)

    for order in permutations(("support", "player")):
        health = 100
        for event in order:
            health = 80 if event == "support" else health - 10
        record("absolute/" + "/".join(order), health, 70,
               order[0] == "support")

    for player_damage in (10, 40):
        for order in permutations(("support", "player")):
            health = 100
            for event in order:
                health = min(health, 80) if event == "support" else health - player_damage
            record(f"minimum/{player_damage}/" + "/".join(order),
                   health, 80 - player_damage, order[0] == "support")

    def accept_snapshot(health, current_owner, sender, snapshot):
        # Models only the inspected identity check plus health assignment.
        return snapshot if current_owner == sender else health

    record("native/same_owner_stale_after_custom_ack",
           accept_snapshot(80, "A", "A", 100), 80, False)
    record("native/old_A_rejected_while_B_current",
           accept_snapshot(80, "B", "A", 100), 80, True)
    health = 80
    for owner in ("B", "A"):
        health = accept_snapshot(health, owner, "A", 100)
    record("native/A_B_A_connection_reuse",
           health, 80, False)

    # Both B baselines include the player's 10 damage. The transferred support
    # marker is unknown, so neither unconditional retry nor skip works in both.
    for support_in_baseline in (False, True):
        baseline = 70 if support_in_baseline else 90
        for retry in (False, True):
            record(f"handoff/included={support_in_baseline}/retry={retry}",
                   baseline - (20 if retry else 0), 70,
                   support_in_baseline != retry)

    # Same observed prefix (health 80) may include S or P (both 20). H1 has
    # native P pending; H2 includes P already. No native operation watermark
    # is assumed. This refutes these three heuristics, not every algorithm.
    for history, pending_player in (("includes_support", 20), ("includes_player", 0)):
        for policy in ("retry", "skip", "absolute"):
            health = {"retry": 60, "skip": 80, "absolute": 60}[policy]
            health -= pending_player
            preserved = ((policy == "skip") == (history == "includes_support"))
            record(f"ambiguous_prefix/{history}/{policy}", health, 60, preserved)

    # Any chosen finite wait admits a later old packet unless an independently
    # verified transport/drain bound or native generation check excludes it.
    wait = 2000
    arrival = wait + 1
    health = accept_snapshot(80, "A", "A", 100) if arrival > wait else 80
    record("timeout/no_verified_drain_bound", health, 80, False)
    return cases


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    cases = evaluate()
    result = dict(environment="offline abstract integer model; PZ NOT TESTED",
                  cases=len(cases),
                  preserving_under_assumptions=sum(c["preserves_damage"] for c in cases),
                  counterexamples=sum(not c["preserves_damage"] for c in cases),
                  results=cases)
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"MODEL ASSERTIONS PASS: {result['cases']} schedules; "
              f"{result['preserving_under_assumptions']} preserve assumed deltas; "
              f"{result['counterexamples']} counterexamples reproduced.")
        print(result["environment"])


if __name__ == "__main__":
    main()
