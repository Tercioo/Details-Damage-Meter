# Picture / Image System

## Overview

The picture system provides a wrapper around WoW's native `Texture` object. It creates a plain Lua table (`df_image`) that holds a reference to the underlying texture in `object.image` (aliased as `object.widget`), then sets a metatable (`ImageMetaFunctions`) so that dot‑syntax reads and writes are routed through getter/setter member tables, and any unknown method call is forwarded to the native texture.

In addition to the wrapper object, the file provides a set of standalone utility functions for working with textures, atlases, gradients, masks, and texture‑escape strings. These utilities operate on raw WoW `Texture` objects and do **not** require the wrapper.

---

## Creating a Texture Object

### Entry Point

Three names point to the same function:

| Function | Signature |
|---|---|
| `detailsFramework:NewImage(parent, texture, width, height, layer, texCoord, member, name)` | Primary implementation |
| `detailsFramework:CreateTexture(parent, texture, width, height, layer, coords, member, name)` | Alias – calls `NewImage` |
| `detailsFramework:CreateImage(parent, texture, width, height, layer, coords, member, name)` | Alias – calls `NewImage` |

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame` | Yes | The WoW frame that will own the texture. May be a raw frame or a DF wrapper (if `parent.dframework` is truthy the wrapper's `.widget` is used). |
| 2 | `texture` | `string \| number \| table \| nil` | No | Texture path, texture file ID, atlas name, color table, HTML color string, gradient table (`df_gradienttable`), or `nil`/`""`. |
| 3 | `width` | `number?` | No | Width in pixels. Applied after texture assignment. |
| 4 | `height` | `number?` | No | Height in pixels. Applied after texture assignment. |
| 5 | `layer` | `drawlayer?` | No | Draw layer string (`"OVERLAY"`, `"ARTWORK"`, etc.). Defaults to `"overlay"`. |
| 6 | `texCoord` | `table?` | No | Four‑element array `{left, right, top, bottom}`. Applied only if element `[4]` exists. |
| 7 | `member` | `string?` | No | If provided, the created object is stored on `parent[member]`. |
| 8 | `name` | `string?` | No | Global name for the texture. Auto‑generated from `PictureNameCounter` if omitted. Supports `$parent` substitution. |

### Return Value — `df_image`

A plain table with the following fields set during creation:

| Key | Type | Description |
|---|---|---|
| `type` | `string` | Always `"image"`. |
| `dframework` | `boolean` | Always `true`. |
| `image` | `Texture` | The native WoW Texture object. |
| `widget` | `Texture` | Same reference as `image`. |
| `HookList` | `table` | Empty table; used by `ScriptHookMixin` for event hooks. |

The metatable is set to `ImageMetaFunctions`, which provides `__index`, `__newindex`, and `__call`.

### Texture Resolution During Creation

The `texture` parameter is resolved in this order:

1. **`nil` or `""`** — no texture is set; creates a blank texture.
2. **Table with `.gradient`** — treated as `df_gradienttable`. Sets a white `ColorTexture` then applies a gradient (uses `SetGradient` on Dragonflight+, `SetGradientAlpha` on older clients). The `.invert` flag swaps `fromColor`/`toColor`.
3. **Table without `.gradient`** — treated as a color table. Parsed via `ParseColors` and applied with `SetColorTexture`.
4. **String** — checked in order:
   - `C_Texture.GetAtlasInfo(texture)` — if it resolves, applied via `SetAtlas`.
   - `IsHtmlColor(texture)` — if true, parsed and applied with `SetColorTexture`.
   - Otherwise applied with `SetTexture` (assumed to be a file path).
5. **Number** — applied directly with `SetTexture` (texture file ID).

### API Forwarding

On the first `NewImage` call, every method on the native `Texture` metatable that is **not** already defined on `ImageMetaFunctions` is copied as a forwarding function. The forwarding function looks up the underlying texture by global name and calls the method on it. This means any native `Texture` method (e.g. `SetBlendMode`, `Show`, `Hide`) is available directly on the wrapper object.

### Widget ↔ Wrapper Link

- `ImageObject.image` / `ImageObject.widget` → the native Texture
- `ImageObject.image.MyObject` → back‑reference to the wrapper table
- The native texture is also mixed in with `WidgetFunctions`, providing `GetCapsule()` / `GetObject()` which return the wrapper.

---

## ImageMetaFunctions

The metatable applied to every `df_image` instance. It is stored in the global `_G["DF_ImageMetaFunctions"]` and is versioned (`dversion`). On subsequent loads, existing entries are updated only if the new version is higher.

### Mixins Applied

| Mixin | Source | Purpose |
|---|---|---|
| `SetPointMixin` | `Libs/DF/mixins.lua` | Adds `SetPoint` / `SetPoints` with extended anchor names (`"lefts"`, `"rights"`, `"tops"`, `"bottoms"`, diagonal pairs). |
| `ScriptHookMixin` | `Libs/DF/mixins.lua` | Adds `RunHooksForWidget`, `SetHook`, `HasHook`, `ClearHooks`. Requires `HookList`. |

### `__call`

```lua
texture(value)
```

Calls `object.image:SetTexture(value)`. Allows setting a texture path/ID by calling the wrapper as a function.

### `__index` — Reading Properties

When you read `object.someKey`:

1. Look up `someKey` in `ImageMetaFunctions.GetMembers`. If found, call the getter function and return its result.
2. Try `rawget(object, key)`. If found, return it.
3. Fall back to `ImageMetaFunctions[key]` (methods, constants).

### `__newindex` — Writing Properties

When you write `object.someKey = value`:

1. Look up `someKey` in `ImageMetaFunctions.SetMembers`. If found, call the setter function.
2. Otherwise, `rawset(object, key, value)`.

---

### Readable Properties (GetMembers)

These are available via dot‑syntax reads on the wrapper object.

#### From `DefaultMetaFunctionsGet`

| Key | Returns |
|---|---|
| `parent` | `object:GetParent()` |
| `shown` | `object:IsShown()` |

#### From `LayeredRegionMetaFunctionsGet`

| Key | Returns |
|---|---|
| `drawlayer` | `object.image:GetDrawLayer()` |
| `sublevel` | Sub‑level from `object.image:GetDrawLayer()` (second return value). |

#### Image‑Specific

| Key | Alias | Returns |
|---|---|---|
| `width` | — | `object.image:GetWidth()` |
| `height` | — | `object.image:GetHeight()` |
| `texture` | — | `object.image:GetTexture()` |
| `alpha` | — | `object.image:GetAlpha()` |
| `blackwhite` | alias for `desaturated` | `object.image:GetDesaturated()` |
| `desaturated` | — | `object.image:GetDesaturated()` |
| `atlas` | — | `object.image:GetAtlas()` |
| `texcoord` | — | `object.image:GetTexCoord()` |

---

### Writable Properties (SetMembers)

These are available via dot‑syntax writes on the wrapper object.

#### From `DefaultMetaFunctionsSet`

| Key | Alias | Behavior |
|---|---|---|
| `parent` | — | `object:SetParent(value)` |
| `show` | `shown` | If truthy → `Show()`, if falsy → `Hide()`. |
| `hide` | — | If truthy → `Hide()`, if falsy → `Show()`. |

#### From `LayeredRegionMetaFunctionsSet`

| Key | Behavior |
|---|---|
| `drawlayer` | `object.image:SetDrawLayer(value)` |
| `sublevel` | Reads current draw layer, then calls `SetDrawLayer(drawLayer, value)`. |

#### Image‑Specific

| Key | Accepted Value | Behavior |
|---|---|---|
| `width` | `number` | `object.image:SetWidth(value)` |
| `height` | `number` | `object.image:SetHeight(value)` |
| `texture` | `string`, `number`, `table`, or HTML color | If table or HTML color → parsed via `ParseColors` then `SetTexture(r,g,b,a)`. Otherwise `SetTexture(value)`. |
| `alpha` | `number` | `object.image:SetAlpha(value)` |
| `color` | any value accepted by `ParseColors` | Parsed then applied via `SetColorTexture(r,g,b,a)`. |
| `vertexcolor` | any value accepted by `ParseColors` | Parsed then applied via `SetVertexColor(r,g,b,a)`. |
| `blackwhite` | `boolean` | Alias for `desaturated`. `true` → `SetDesaturated(true)`. |
| `desaturated` | `boolean` | `true` → `SetDesaturated(true)`, `false` → `SetDesaturated(false)`. |
| `texcoord` | `table` or falsy | If table → `SetTexCoord(unpack(value))`. If falsy → resets to `0, 1, 0, 1`. |
| `atlas` | `string` | `SetAtlas(value)` if truthy. |
| `gradient` | `table` | Must contain `{ gradient, fromColor, toColor }`. Sets a white `ColorTexture` then applies `SetGradient(gradient, fromColor, toColor)`. Errors if the table is invalid. |

---

### Explicit Methods

| Method | Signature | Behavior |
|---|---|---|
| `SetSize` | `(width, height)` | Sets width and/or height on `self.image`. Either parameter may be `nil` to skip. |
| `SetGradient` | `(gradientType, fromColor, toColor, bInvert)` | Colors are formatted via `FormatColor("tablemembers", ...)`. If `bInvert` is truthy, `fromColor` and `toColor` are swapped before calling `self.image:SetGradient(...)`. |

All native `Texture` methods are also available on the wrapper through API forwarding (see above).

---

## Gradient Table (`df_gradienttable`)

A table describing a gradient fill:

| Key | Type | Required | Description |
|---|---|---|---|
| `gradient` | `"vertical" \| "horizontal"` | Yes | Direction of the gradient. |
| `fromColor` | `table \| string` | Yes | Start color, any format accepted by `ParseColors` / `FormatColor`. |
| `toColor` | `table \| string` | Yes | End color. |
| `invert` | `boolean?` | No | If true, swap `fromColor` and `toColor`. |

---

## Atlas System

### What Is an Atlas

In this system, an "atlas" is either:

1. A **WoW atlas name** (string) — resolved at runtime via `C_Texture.GetAtlasInfo(name)`.
2. A **`df_atlasinfo` table** — a custom structure that extends the WoW `atlasinfo` with vertex colors, desaturation, and native dimensions.

### `df_atlasinfo` Structure

| Key | Type | Description |
|---|---|---|
| `file` | `string \| number` | Texture path or file ID. |
| `filename` | `string?` | Alternative to `file`. |
| `width` | `number` | Display width (defaults to 64 in `CreateAtlas`). |
| `height` | `number` | Display height (defaults to 64 in `CreateAtlas`). |
| `leftTexCoord` | `number` | Left tex coord (default 0). |
| `rightTexCoord` | `number` | Right tex coord (default 1). |
| `topTexCoord` | `number` | Top tex coord (default 0). |
| `bottomTexCoord` | `number` | Bottom tex coord (default 1). |
| `tilesHorizontally` | `boolean` | Horizontal tiling flag. |
| `tilesVertically` | `boolean` | Vertical tiling flag. |
| `vertexRed` | `number?` | Red vertex color component. |
| `vertexGreen` | `number?` | Green vertex color component. |
| `vertexBlue` | `number?` | Blue vertex color component. |
| `vertexAlpha` | `number?` | Alpha vertex color component. |
| `colorName` | `string?` | Named color; if present, parsed via `ParseColors` instead of vertex components. |
| `nativeWidth` | `number?` | Native pixel width of the texture file (used by `CreateAtlasString`). |
| `nativeHeight` | `number?` | Native pixel height of the texture file (used by `CreateAtlasString`). |
| `desaturated` | `boolean?` | If true, fully desaturate. |
| `desaturation` | `number?` | Partial desaturation amount (only used if `desaturated` is false). |
| `alpha` | `number?` | Alpha value. |
| `atlas` | `string?` | A WoW atlas name; if present and valid, `SetAtlas` uses it directly. |

---

### `detailsFramework:SetAtlas(textureObject, atlas, useAtlasSize, filterMode, resetTexCoords)`

Applies an atlas to a native `Texture` object (not a wrapper).

| Parameter | Type | Description |
|---|---|---|
| `textureObject` | `Texture` | The native WoW texture to modify. |
| `atlas` | `string \| df_atlasinfo` | Atlas name or atlas info table. |
| `useAtlasSize` | `boolean?` | If true, resize the texture to atlas dimensions. |
| `filterMode` | `string?` | Texture filter mode. Defaults to `"LINEAR"` for table atlas. |
| `resetTexCoords` | `boolean?` | Passed to native `SetAtlas` for string atlases. |

**Resolution order:**

1. If `atlas` is a string and resolves via `C_Texture.GetAtlasInfo` → call native `textureObject:SetAtlas(atlas, ...)`.
2. If `atlas` is a table with an `.atlas` key that resolves → call native `textureObject:SetAtlas(atlasName, ...)`.
3. If `atlas` is a table (custom `df_atlasinfo`):
   - Optionally apply width/height if `useAtlasSize`.
   - Set horizontal/vertical tiling.
   - Call `SetTexture` with the file and wrap/filter modes.
   - Apply tex coords.
   - Apply desaturation or partial desaturation.
   - Apply vertex color (from `colorName` or individual RGBA components).
4. If `atlas` is a string or number (non‑atlas) → call `textureObject:SetTexture(atlas)`.

---

### `detailsFramework:CreateAtlas(file, width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, tilesHorizontally, tilesVertically, vertexRed, vertexGreen, vertexBlue, vertexAlpha, desaturated, desaturation, alpha)`

Constructs and returns a `df_atlasinfo` table from individual arguments. Does **not** create or modify any texture object.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `file` | `any` | — | Texture path or file ID. |
| `width` | `number?` | `64` | Display width. |
| `height` | `number?` | `64` | Display height. |
| `leftTexCoord` | `number?` | `0` | Left tex coord. |
| `rightTexCoord` | `number?` | `1` | Right tex coord. |
| `topTexCoord` | `number?` | `0` | Top tex coord. |
| `bottomTexCoord` | `number?` | `1` | Bottom tex coord. |
| `tilesHorizontally` | `boolean?` | `false` | Horizontal tiling. |
| `tilesVertically` | `boolean?` | `false` | Vertical tiling. |
| `vertexRed` | `number \| string?` | — | Red component or a color name string. If string, stored as `colorName`. |
| `vertexGreen` | `number?` | — | Green component. |
| `vertexBlue` | `number?` | — | Blue component. |
| `vertexAlpha` | `number?` | — | Alpha component. |
| `desaturated` | `boolean?` | — | Full desaturation flag. |
| `desaturation` | `number?` | — | Partial desaturation amount. |
| `alpha` | `number?` | — | Alpha value. |

**Returns:** `df_atlasinfo`

---

### `detailsFramework:CreateAtlasString(atlas, textureHeight, textureWidth)`

Converts an atlas or texture reference into a WoW **texture escape sequence** string (`|T...|t`) suitable for embedding in chat messages, tooltips, or other formatted text.

| Parameter | Type | Description |
|---|---|---|
| `atlas` | `string \| table` | Atlas name, texture path, or `df_atlasinfo`. Parsed via `ParseTexture`. |
| `textureHeight` | `number?` | Overrides the height in the escape string. |
| `textureWidth` | `number?` | Overrides the width in the escape string. |

**Returns:** `string` — a `|T...|t` escape sequence.

The output format depends on how much data `ParseTexture` returns:

| Available Data | Output Format |
|---|---|
| file only | `\|Tfile\|t` |
| file + height | `\|Tfile:height\|t` |
| file + height + width | `\|Tfile:height:width\|t` |
| file + dims + texCoords | `\|Tfile:h:w:0:0:nW:nH:l:r:t:b\|t` (coords multiplied by native dims and floored) |
| file + dims + texCoords + color | Same as above with `:r:g:b` appended |

---

### `detailsFramework:TableIsAtlas(atlasTable)`

Returns `true` if the given table looks like an atlas info (has a `.file` or `.filename` key).

| Parameter | Type | Description |
|---|---|---|
| `atlasTable` | `table` | The table to check. |

**Returns:** `boolean`

---

## Texture Parsing

### `detailsFramework:ParseTexture(texture, width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, vertexRed, vertexGreen, vertexBlue, vertexAlpha)`

Universal texture resolver. Accepts any supported texture format and returns normalized components.

| Parameter | Type | Description |
|---|---|---|
| `texture` | `string \| number \| table` | The texture input. |
| `width`–`vertexAlpha` | various | Override values. Explicit values take precedence over atlas‑provided ones for `width`/`height`. |

**Returns** (up to 13 values):

| # | Name | Description |
|---|---|---|
| 1 | `texture` | Resolved file path, file ID, or texture ID. |
| 2 | `width` | Width (override or from atlas). |
| 3 | `height` | Height (override or from atlas). |
| 4 | `leftTexCoord` | Left tex coord (defaults to 0). |
| 5 | `rightTexCoord` | Right tex coord (defaults to 1). |
| 6 | `topTexCoord` | Top tex coord (defaults to 0). |
| 7 | `bottomTexCoord` | Bottom tex coord (defaults to 1). |
| 8 | `red` | Vertex red component. |
| 9 | `green` | Vertex green component. |
| 10 | `blue` | Vertex blue component. |
| 11 | `alpha` | Vertex alpha component. |
| 12 | `nativeWidth` | Native texture width (from `df_atlasinfo` only). |
| 13 | `nativeHeight` | Native texture height (from `df_atlasinfo` only). |

**Resolution logic:**

1. **String** → check `C_Texture.GetAtlasInfo`. If it resolves, return the atlas file/filename plus atlas dimensions and tex coords.
2. **Table** → treated as `df_atlasinfo`. Returns `file` or `filename`, dims, tex coords (defaulting to 0/1), color (from `colorName` or individual components), and native dims.
3. **String or number (non‑atlas)** → returned as‑is with override values and default tex coords `0, 1, 0, 1`. If `vertexRed` is a string or table, it is parsed via `ParseColors`.

---

### `detailsFramework:IsTexture(texture, bCheckTextureObject)`

Validates whether a value can be used as a texture input.

| Parameter | Type | Description |
|---|---|---|
| `texture` | `any` | Value to check. |
| `bCheckTextureObject` | `boolean?` | If true, also accept native WoW `Texture` userdata objects. |

**Returns:** `boolean`

Accepted types:

| Input Type | Condition | Result |
|---|---|---|
| `string` | always | `true` (path, atlas name, or HTML color) |
| `number` | always | `true` (file ID) |
| `table` with `.gradient` | — | `true` (gradient table) |
| `table` with `.file` or `.filename` | — | `true` (atlas info) |
| `table` with `GetTexture` + `GetObjectType() == "Texture"` | only if `bCheckTextureObject` is true | `true` (native Texture) |
| anything else | — | `false` |

---

## Texture Manipulation Utilities

### `detailsFramework:SetTexture(object, texture)`

Applies a texture to a **native** WoW `Texture` object. Handles all supported input formats.

| Parameter | Type | Description |
|---|---|---|
| `object` | `Texture` | The native texture to modify. |
| `texture` | `string \| number \| table` | Texture input. |

**Resolution order:**

1. String atlas name → `C_Texture.GetAtlasInfo` check → `object:SetAtlas(texture)`.
2. Table with `.file` → delegates to `detailsFramework:SetAtlas(object, textureInfo)`.
3. Table with `.gradient` → `df_gradienttable` processing (white ColorTexture + gradient, with `invert` support and client‑version branching).
4. Table (other) → parsed as color via `ParseColors` → `SetColorTexture`.
5. String or number → `object:SetTexture(texture)`.
6. Other → error.

---

### `detailsFramework:SetMask(texture, maskTexture)`

Applies a mask texture to a native `Texture` object. The mask restricts which pixels of the texture are visible.

| Parameter | Type | Description |
|---|---|---|
| `texture` | `Texture` | The native texture (or DF wrapper with `.widget`) to mask. |
| `maskTexture` | `string \| number \| table` | The mask texture input. |

**Behavior:**

- On the first call, creates a `MaskTexture` on the texture's parent (`CreateMaskTexture`), anchors it to fill the texture, adds it via `AddMaskTexture`, and stores it in `texture.MaskTexture`.
- Subsequent calls reuse the existing `MaskTexture`.
- If `maskTexture` is a string that resolves as a WoW atlas → `SetAtlas`.
- If `maskTexture` is a table that passes `TableIsAtlas` → `SetAtlas` via `detailsFramework:SetAtlas`.
- Otherwise → `SetTexture(maskTexture)`.

---

### `detailsFramework:CreateHighlightTexture(parent, parentKey, alpha, name, texture)`

Creates a simple highlight texture on a frame. This is a raw WoW `Texture` object on the `"highlight"` draw layer — **not** a `df_image` wrapper.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `parent` | `frame` | — | The frame to attach the highlight to. |
| `parentKey` | `string?` | — | If provided, stored as `parent[parentKey]`. |
| `alpha` | `number?` | `0.1` | Alpha value for the highlight. |
| `name` | `string?` | auto | Global name. Auto‑generated from `PictureNameCounter` if omitted. |
| `texture` | `string?` | `Interface\Buttons\WHITE8X8` | Texture path. |

**Returns:** `Texture` (native WoW texture, not a `df_image`).

The highlight texture:

- Uses the `"highlight"` draw layer (shown only on mouseover).
- Blend mode is set to `"ADD"`.
- Anchored to fill the parent (`SetAllPoints`).

---

## Supported Texture Input Formats

The system accepts textures in multiple formats throughout its API. This table summarizes all recognized formats:

| Format | Type | Example | How It Is Applied |
|---|---|---|---|
| File path | `string` | `"Interface\\Icons\\INV_Misc_Gem_01"` | `SetTexture(path)` |
| File ID | `number` | `134400` | `SetTexture(id)` |
| WoW atlas name | `string` | `"UI-HUD-MicroMenu-Abilities-Mouseover"` | `SetAtlas(name)` |
| HTML color | `string` | `"#FF0000"` | Parsed → `SetColorTexture(r,g,b)` |
| Color table | `table` | `{1, 0, 0, 1}` | Parsed → `SetColorTexture(r,g,b,a)` |
| Gradient table | `df_gradienttable` | `{gradient="horizontal", fromColor={1,0,0}, toColor={0,0,1}}` | White ColorTexture + `SetGradient` |
| Atlas info table | `df_atlasinfo` | `{file=path, width=32, height=32, ...}` | Full atlas application via `SetAtlas` utility |

---

## Data Flow

```
Input (string / number / table)
        │
        ▼
  ┌─────────────┐
  │ ParseTexture │  ← normalizes any input into: file, dims, coords, color, native dims
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │  IsTexture   │  ← validates that the input is usable (optional check)
  └──────┬──────┘
         │
         ▼
  ┌──────────────────┐
  │ NewImage /       │  ← creates the df_image wrapper table
  │ CreateTexture    │     • parent:CreateTexture(name, layer) → native Texture
  │                  │     • resolves texture input (atlas / gradient / color / path)
  │                  │     • applies texCoord, width, height
  │                  │     • sets metatable to ImageMetaFunctions
  └──────┬───────────┘
         │
         ▼
  ┌──────────────────┐
  │   df_image       │  ← wrapper object
  │   .image/.widget │──→ native Texture (rendering)
  │   metatable:     │
  │   ImageMeta      │  ← dot-syntax property access
  │   Functions      │  ← method forwarding
  └──────────────────┘
```

For standalone texture manipulation (no wrapper):

```
  Input
    │
    ▼
  SetTexture(object, texture)   ← resolves format, applies to native Texture
  SetAtlas(object, atlas, ...)  ← applies atlas (string or df_atlasinfo) to native Texture
  SetMask(texture, mask)        ← creates/applies a mask texture
```

---

## Usage Examples

### Creating a basic texture

```lua
local myTexture = detailsFramework:CreateTexture(myFrame, "Interface\\Icons\\INV_Misc_Gem_01", 32, 32)
-- myTexture is a df_image wrapper
-- myTexture.image / myTexture.widget is the native Texture
```

### Creating a texture from a file ID

```lua
local myTexture = detailsFramework:CreateTexture(myFrame, 134400, 64, 64, "ARTWORK")
```

### Creating a gradient texture

```lua
local gradient = detailsFramework:CreateTexture(myFrame, {
    gradient = "horizontal",
    fromColor = {1, 0, 0, 1},
    toColor = {0, 0, 1, 1},
    invert = false,
}, 200, 20)
```

### Creating a texture from an atlas name

```lua
local tex = detailsFramework:CreateTexture(myFrame, "UI-HUD-MicroMenu-Abilities-Mouseover", 24, 24)
```

### Using dot-syntax properties

```lua
-- Read
local w = myTexture.width
local h = myTexture.height
local a = myTexture.alpha
local isBW = myTexture.desaturated

-- Write
myTexture.width = 64
myTexture.height = 64
myTexture.alpha = 0.5
myTexture.desaturated = true
myTexture.texture = "Interface\\Icons\\Spell_Nature_Rejuvenation"
myTexture.color = {0.5, 0, 0, 1}
myTexture.vertexcolor = "red"
myTexture.texcoord = {0.1, 0.9, 0.1, 0.9}
myTexture.gradient = {gradient = "vertical", fromColor = {1,1,1}, toColor = {0,0,0}}
```

### Using __call

```lua
myTexture("Interface\\Icons\\INV_Misc_Gem_02")  -- sets texture via SetTexture
```

### Building a df_atlasinfo and applying it

```lua
local atlas = detailsFramework:CreateAtlas(
    "Interface\\AddOns\\MyAddon\\Textures\\icons",
    32, 32,          -- width, height
    0.25, 0.5,       -- leftTexCoord, rightTexCoord
    0, 0.25,         -- topTexCoord, bottomTexCoord
    false, false,     -- tiling
    1, 1, 1, 1        -- vertex color RGBA
)

detailsFramework:SetAtlas(someNativeTexture, atlas, true)
```

### Creating an inline texture string

```lua
local str = detailsFramework:CreateAtlasString("achievement-shield-2", 16, 16)
-- Returns something like "|Tfileid:16:16:0:0:64:64:0:63:0:63|t"
```

### Creating a highlight texture

```lua
local highlight = detailsFramework:CreateHighlightTexture(myButton, "highlightTex", 0.2)
-- highlight is a native Texture on the "highlight" layer
-- myButton.highlightTex references it
```

### Applying a mask

```lua
detailsFramework:SetMask(myTexture.image, "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
```

### Checking if something is a valid texture

```lua
if detailsFramework:IsTexture(someInput) then
    detailsFramework:SetTexture(nativeTexture, someInput)
end
```

### Setting a texture on a native object

```lua
-- Handles all formats automatically
detailsFramework:SetTexture(nativeTexture, "Interface\\Icons\\Spell_Fire_Fireball")
detailsFramework:SetTexture(nativeTexture, {gradient = "vertical", fromColor = "white", toColor = "black"})
detailsFramework:SetTexture(nativeTexture, {1, 0, 0, 0.5})  -- red semi-transparent
```
