# Read-only support preflight probe

Date: 2026-10-16. Current version: [root VERSION](../VERSION). **Implemented diagnostic; offline-tested only. Native/dedicated execution NOT TESTED.** This implements the smallest non-mutating prototype identified by the military audit. It does not implement credential equipment, authorization, support missions or player menus. MS01-MS04 still block those features. The user's resume instruction authorizes this source/offline implementation; no engine launch, deployment or publication is authorized.

## Scope, version and configuration

Advance 0.1.0-dev.3 to 0.1.0-dev.4 as an additive development checkpoint within the pending initial 0.1.0 feature line. Existing audio configuration/protocol and saves remain compatible; no persistence/schema migration. No stable release version is established here. Artwork is unchanged.

Server sandbox `B47HE.EnableSupportPreflightProbe`: boolean, default false; separate Military Support Diagnostics page, localized English name/tooltip. Only literal server true enables item reads; missing/invalid/false disables them in existing saves. Client settings do not authorize inspection. Disabling takes effect on the next request; a previously returned observation remains a timestamped historical sample for at most five seconds, never permission. Existing audio settings remain independent and default disabled. Other translations use the existing English fallback policy, whose native behavior remains NOT TESTED.

Technical constants stay internal: direct inventory cap 1024 items, one request per authenticated player per two server seconds, four outstanding/cached local-player entries, five-second client lifetime, two-second server timestamp tolerance, bounded ASCII nonce and flat protocol. They limit diagnostic work and stale presentation, not configurable gameplay. No inventory scan runs every frame; the developer explicitly invokes each query. The only periodic client callback marks normal-tick readiness.

## Source modules and manual interface

- `shared/B47HESupportProbe/Protocol.lua`: strict scalar envelopes, native ID bounds, response shape and bounded direct-inventory lookup.
- `server/B47HESupportProbe/Preflight.lua`: dedicated-only OnClientCommand service; actual requesting player determines inventory and reply recipient.
- `client/B47HESupportProbe/Client.lua`: manual developer interface, correlation, expiry and disconnect cleanup. No menu/action, automatic query, retry, item creation or diagnostics log containing item/player data.

After separately authorized installation and native testing, a developer with actual local `player` and directly owned native `radio` objects may invoke:

```lua
local accepted, nonceOrReason = B47HESupportProbe.request(player, radio)
local observation = B47HESupportProbe.result(player) -- nil while pending/expired/invalid
```

No such invocation was executed in PZ here. The helper exists only on remote multiplayer clients, after a normal tick and a valid synchronized native clock. SP and hosted modes do not expose the helper; server rejects nondedicated execution. Native split-screen player routing remains a dedicated test gate, even though the fake model exercises four independent entries. All developer-visible statuses are diagnostic codes, not player-facing menu text.

## Authority and lifecycle

Request namespace `B47HESupportProbe`, command `InspectRadio`, exactly `{protocolVersion=1, clientNonce, itemID}`. IDs are signed 32-bit native lookup hints, not stable/sealed authorization identities. Unknown keys (including ownership, clearance or authorization flags), nested payloads, nonfinite values and invalid tokens are rejected. Valid payloads contain three keys; responses at most ten; every string/key is bounded to 64 ASCII bytes. Even the conservative 12*(64+64+32)+32 bound is below 4096 bytes excluding native framing. This does not constrain malicious packets before engine deserialization.

The server rates malformed requests before inventory work, reads its own sandbox, and resolves only the connection-associated player's direct inventory. It caps native list size before the nonrecursive lookup, requires exact `Base.WalkieTalkie5`, exact current container/item ID and a living requesting player. It reads native power/channel/device flags and re-resolves the same item, container and DeviceData before sending. A changed binding yields `changed` without device fields. Other replies include disabled/dead/not_owned/wrong_type/inventory_limit/invalid_device. Invalid native data yields no observation; native exceptions halt the diagnostic for that server process. No additional actor is created.

The reply `RadioObservation` goes to that player's connection; a nonce unique within the client module lifetime routes the corresponding local slot. Completed replies cannot overwrite another pending entry. Results are copied, expire five seconds after request, require a server timestamp within two seconds of current synchronized time, and are invalidated when the local observed item is no longer the same owned radio. No new request occurs automatically. Connected/disconnect/main-menu transitions clear pending results while preserving the nonce serial. Client API failure disables the diagnostic helper for that Lua lifetime. Server invalid/regressing time halts the service; weak per-player rate keys hold no item reference, receipt or durable state.

This is a best-effort observation during one handler, not a transfer/save lock. A transfer after the final server read may make the sample stale. Numeric ID reuse, duplicate inventory IDs, wrapper identity, connection lifecycle and the actual native send/readiness behavior remain runtime gates. Replies are never authority input to future menus or support dispatch. Last accepted nonce suppression is transient, not full replay protection or an exactly-once transaction. Restart starts fresh; no mission, authorization, pending operation or observation is saved/replayed/refunded.

## Exact evidence and limitations

[Source fingerprints](SUPPORT_PREFLIGHT_SOURCE_INDEX.json) bind this inspection to Steam build 25485521, reported Build 42.21 and the existing packaged JAR SHA. It remains the modified local installation, not an authenticated clean depot. No installed files were changed. Reuse [radio API signatures N01-N04](MILITARY_RADIO_DESIGN.md) and [native command/clock/event/option signatures](AUDIO_API_EVIDENCE.md); their engine invocation remains NOT TESTED.

[VERIFIED: source] `media/lua/server/ClientCommands.lua:210` calls `player:getInventory():getItemWithID(args.emptyBag)`; 407 and 1228 are additional server lookup callers. Lines 279-284 use container `getItems():size()`/`get(0)`. These establish observed Lua call forms, not a mutation permission or a native inventory transaction.

[VERIFIED: packaged bytecode] `InventoryItem ItemContainer.getItemWithID(int)` offsets 0-42 inspect only its own `items` ArrayList and compare the native int ID; no recursive call or mutation. Public `ArrayList<InventoryItem> ItemContainer.getItems()` exposes the list getter. N03 supplies `int InventoryItem.getID()`, `String getFullType()`, `ItemContainer getContainer()`; N01 supplies `DeviceData Radio.getDeviceData()`; N02 supplies `boolean DeviceData.getIsTurnedOn()`, `boolean getIsBatteryPowered()`, `float getPower()`, `int getChannel()`. Re-inspection of these four DeviceData getters confirms direct field reads without calls or writes. Prior registered class evidence and vanilla callers support Lua candidates, not tested overload dispatch. Native inspection used javap only; no engine classes were instantiated or native implementation redistributed.

The prototype intentionally observes powered-off/empty-battery radios rather than claiming mission eligibility. It excludes nested bags, placed/vehicle/world radios and custom future radio types; those remain required future scope, not silently supported. It neither consumes credentials nor marks SPENT, persists state, changes tuning/battery, hooks loot, starts aircraft, plays audio, attracts/damages zombies or alters vanilla helicopter state. Source evidence does not clear custody/durability/combat blockers. Full five-level/map/laser/aiming requirements remain unimplemented and require their unresolved audits.

[TESTED: offline] Lua 5.1 fake boundaries and adapter tests are in `scripts/test_support_probe.py`; existing audio regressions run separately. See [validation](VALIDATION.md). Dedicated cases P-R01..08 in [support test plan](SUPPORT_MP_TEST_PLAN.md) are all NOT TESTED. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Next safe engine milestone is isolated read-only verification after separate launch authorization; real card insertion/spending or combat still requires its own supported contract before implementation.
