# Project artwork

Current authoring version: 0.1.0-dev.6

## Selected mod icon — 2026-10-18

The user selected the text-free helicopter extracted from the project thumbnail as the mod icon. The authoring PNG is [B47HE_HELICOPTER_ICON.png](../assets/branding/B47HE_HELICOPTER_ICON.png); an exact byte mirror at `src/B47ANCEDHelicopterEvents/42/media/ui/B47HE_HELICOPTER_ICON.png` is selected by `mod.info`'s `icon=` field. PNG: 1254x1254, 8-bit RGBA, 660,804 bytes, SHA-256 `2066c3aa38000c4c44a769646d04f36c9c9b3854fb9ff47be628be7e5d874135`. [Provenance receipt](../assets/branding/HELICOPTER_ICON.json) retains the built-in image_gen extraction prompt, approved output fingerprint and unchanged source-thumbnail fingerprint without machine-specific paths. Integration copies the selected result without resizing, redrawing or regeneration. No new sound or runtime Lua change.

The custom icon takes precedence over fallback branding. `B47_ICON_SMALL.png` remains byte-unchanged in authoring/source; the decorative wreck probe still uses that independent fallback marker. Poster, fallback thumbnail and selected root thumbnail remain byte-unchanged. This compatible artwork refinement stays within unreleased 0.1.0-dev.6; no gameplay/API/configuration/save or protocol change.

[VERIFIED: installed Lua inspection] Build 42.21 `media/lua/client/OptionScreens/ModSelector/ModSelectorModel.lua:69` reads `modInfo:getIcon()`, and `ModListBox.lua:200-203` draws that texture into the existing button-sized rectangle using `drawTextureScaled`. The selected full-resolution image is retained and the vanilla UI controls display sizing; a 64px replacement was not generated. [TESTED: offline] PNG decode, real alpha range 0..255, dimensions, exact authoring/source bytes and preserved artwork fingerprints pass. Actual icon loading/appearance in PZ is NOT TESTED. No game/server launch, deployment, package or Workshop publication.

## Selected project thumbnail — 2026-10-15

The user selected the helicopter artwork supplied in this session as the project thumbnail. The authoritative selected image is root [thumbnail.png](../thumbnail.png): PNG, RGB, 1254x1254, 1,532,650 bytes, SHA-256 `46dd0ab5bc851ca2443a182db3be35eb0c3e3a69a304ec8f2ae27183fd7beb69`. It is an exact byte copy of the supplied image; no resizing, cropping or regeneration. Provenance: user-supplied project artwork, selected explicitly for this role. No additional third-party asset or license claim is inferred.

At that thumbnail-selection checkpoint, the icon and poster, including their production mirrors, remained unchanged. The later mod-icon selection above supersedes only that icon role. The default thumbnail under assets/branding remains available as historical/fallback art; it must not overwrite this custom thumbnail. No uploader or package generator exists yet; any future authorized tooling must prefer root thumbnail.png and independently validate the selected distribution target's current image requirements. This records asset selection, not Workshop acceptance or publication. [TESTED: offline] PNG verification, dimensions, byte equality and SHA-256; visually inspected. In-game/Workshop rendering NOT TESTED.

## Earlier fallback artwork records

Use manually supplied artwork first, independently for each role. Only missing roles use assets/branding/B47_ICON_SMALL.png (64x64 mod icon) and B47_ICON.png (128x128 poster) and B47_THUMBNAIL.png (512x512 Workshop thumbnail). Copy bytes without resizing or regenerating. Existing Eyewear thumbnail and Buildable Fences poster are custom and preserved. Future custom replacements take precedence. No UI project is included.

User-provided art on 2026-10-14. SHA-256 small: 60e2a193a6c1e1190941e6c342ec23c673a561dbed895c80067fe2b89c7f7e83; large: 0e30a776c77dbf66eeb9acfa7596c7f850cb5b334e8873ef94acbb3b071582c3.

The 2026-10-14 addition was asset-only work; on 2026-10-15 the existing exact icon/poster bytes were copied to the authorized audio source layout. No custom art was replaced and no new assets were generated. The paragraph below describes the earlier artwork iteration.

This was asset-only work. Current version headers/mirrors identify this authoring iteration; all prior gameplay/API/runtime evidence remains historical at 0.1.0-dev.2 and its original source commits. No prior PASS is promoted to current evidence. No new game/dedicated tests, packages, deployment or publication. Projects without production mod.info retain these as authoring assets, not a fabricated runtime package.

Workshop thumbnail correction: B47_THUMBNAIL.png is a direct 512x512 resize of the user-supplied B47.png. Its SHA-256 is f775bff1783d59af91f331652740d5279fd5603f66d431c6349f38cbd2d9915b. Preserve custom thumbnails; the mod icon remains 64x64 and poster remains 128x128.
