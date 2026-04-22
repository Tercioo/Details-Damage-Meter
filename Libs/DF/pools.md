# Pools

This document describes the object pooling utilities provided by Details! Framework.

## Overview

Pools are used to recycle objects to reduce allocation overhead and avoid frequent object creation and destruction.

A pool instance stores objects in two lists:
- `inUse`: objects currently acquired from the pool.
- `notUse`: objects available for reuse.

When `Acquire()` is called, the pool returns an object from `notUse` if available; otherwise it creates a new object using the configured factory function.

## Pool factory

### `DetailsFramework:CreatePool(newObjectFunc, ...)`

Creates a new pool object.

- `newObjectFunc(self, ...)`: factory function used to create a new object when the pool is empty.
- additional `...` arguments are stored as `payload` and forwarded to `newObjectFunc` when a new object is created.

Returns a pool object with the standard pool methods and callbacks.

### `DF:CreateObjectPool(newObjectFunc, ...)`

Alias for `DetailsFramework:CreatePool`.

## Core methods

### `Pool:Get()` / `Pool:Acquire()`

Acquire an object from the pool.

- If a free object exists in `notUse`, it is moved to `inUse` and returned.
- Otherwise `newObjectFunc(self, unpack(self.payload))` is called to create a new object.
- `objectsCreated` is incremented for each newly created object.
- If `onAcquire` is defined, it is invoked with the acquired object.

Returns:
- the acquired object
- a boolean indicating whether a new object was created (`true` when created, `false` when reused)

### `Pool:Release(object)`

Return an object to the pool.

- The object is removed from `inUse` and inserted into `notUse`.
- If `onRelease` is defined, it is invoked with the object.

### `Pool:Reset()` / `Pool:ReleaseAll()`

Return all active objects to the pool.

- Iterates through all objects in `inUse`, moves them into `notUse`.
- If `onReset` is defined, it is invoked for each returned object.

### `Pool:GetAllInUse()`

Returns the `inUse` list.

### `Pool:Sort(func)`

Sorts the objects currently in use.

- If `func` is provided, it is used.
- Otherwise `self.sortFunc` is used.

### `Pool:Hide()`

Calls `:Hide()` on every object currently in use.

### `Pool:Show()`

Calls `:Show()` on every object currently in use.

### `Pool:GetAmount()`

Returns three values:
1. total number of objects managed by the pool (`#notUse + #inUse`)
2. number of objects available for reuse (`#notUse`)
3. number of objects currently in use (`#inUse`)

### `Pool:RunForInUse(func)`

Runs `func(object)` for each object currently in use.

## Callback setters

### `Pool:SetSortFunction(func)`

Assigns the sort function used by `Sort()`.

### `Pool:SetOnRelease(func)` / `Pool:SetCallbackOnRelease(func)`

Sets a callback invoked when an object is released with `Release()`.

### `Pool:SetOnReset(func)` / `Pool:SetCallbackOnReleaseAll(func)`

Sets a callback invoked when the pool is reset with `Reset()` / `ReleaseAll()`.

### `Pool:SetOnAcquire(func)` / `Pool:SetCallbackOnGet(func)`

Sets a callback invoked when an object is acquired with `Get()` / `Acquire()`.

## Pool constructor

### `Pool:PoolConstructor(newObjectFunc, ...)

Initializes the pool state.

- `objectsCreated = 0`
- `inUse = {}`
- `notUse = {}`
- `payload = {...}`
- `newObjectFunc = newObjectFunc`

This is used internally by `CreatePool` and can be called manually to make an existing table behave like a pool.

## Example

```lua
local function CreateFrame(self, parent)
    local frame = CreateFrame("frame", nil, parent)
    frame:SetSize(100, 20)
    return frame
end

local pool = DetailsFramework:CreatePool(CreateFrame, UIParent)
pool:SetCallbackOnAcquire(function(object)
    object:Show()
end)
pool:SetCallbackOnRelease(function(object)
    object:Hide()
end)

local object = pool:Acquire()
object:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

-- later
pool:Release(object)
```

## Notes

- Pools are useful for UI objects or other reusable values that are created frequently.
- `SetCallbackOnGet` / `SetOnAcquire` and `SetCallbackOnRelease` / `SetOnRelease` make it easy to reset object state when reusing.
- `Hide()` and `Show()` operate only on objects currently in use, not on the idle objects in `notUse`.
- `Sort()` affects only the active order in `inUse`.
