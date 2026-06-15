# ABUZ8 Studio Handoff

Last updated: 2026-03-15

## Purpose

This document is the exact handoff for the current Studio build.

It covers:

- what was built
- what was changed
- what works
- what is broken
- what needs to be fixed next
- the shortest path to the simple studio originally requested

This is not a marketing summary. It is an incident + architecture handoff.

## Original Goal

Build one clean local studio GUI that:

- puts the existing tools in one place
- lets the operator create from:
  - a prompt
  - or a prompt + source image
- generates:
  - images
  - videos
  - longer 5 / 10 / 20 minute blocks
- allows stitching multiple blocks into a longer production
- keeps the workflow simple enough to feel like:
  - CapCut Studio
  - OpenArt
  - Krea / Higgsfield class UX

## What Was Actually Built

### 1. Local Studio Web App

Primary backend:

- `/home/user/.openclaw/workspace/council_table/studio_mvp.py`

Primary frontend:

- `/home/user/.openclaw/workspace/council_table/static/studio_mvp.html`

It currently exposes:

- health / inventory
- media browser
- project/job/manifest tracking
- local job execution API
- simplified `Quick Create` UI
- advanced builder UI

### 2. Worker Router

Router backend:

- `/mnt/c/Windows/System32/studio_worker_router.py`

Purpose:

- sits in front of the Studio app
- exposes worker status
- preserves `openclaw` / helper routing surface

### 3. StudioOS Root

Shared project root:

- `.\StudioOS`

Used for:

- projects
- logs
- packets
- outputs
- manifests
- launchers

### 4. Simple Creation Flow

Added:

- `POST /api/studio/simple`

This is the current minimal path.

Input:

- prompt
- optional `source_image_path`
- output type:
  - `image`
  - `video`
- duration minutes

### 5. Longform / Campaign / Packaging Layers

Built earlier during expansion:

- bundle generation
- sequence generation
- tutorial path
- campaign path
- publish pack
- release bundle
- client package
- export profiles
- continuity / shot library / family preset manifests

These exist, but they are not the right first surface for the product.

## What Changed Exactly

### Simplification Changes

1. Removed Sabina-specific defaults from the UI.
2. Added `Quick Create` section to the main page.
3. Added:
   - `Generate Image`
   - `Generate Video`
4. Hid the advanced builder behind a toggle.
5. Added backend fallback behavior so the image path still returns an output if ComfyUI rejects a prompt graph.
6. Fixed the quick video path so it assembles from the bundle it just generated instead of requiring a pre-existing project storyboard.

### Launcher Changes

The launcher originally used the wrong WSL distro name:

- wrong: `Ubuntu`
- correct: `Ubuntu-24.04`

Fixed files:

- `.\StudioOS\start_all_studioos.cmd`
- `~\Desktop\Start ABU StudioOS.cmd`

### Runtime Findings

The biggest engine issue found:

- ComfyUI was failing when launched with the wrong Windows Python install
- failure seen:
  - `AssertionError: Torch not compiled with CUDA enabled`

Correct verified GPU env:

- `E:\Miniconda3\envs\abu-comfyui\python.exe`

Verified in that env:

- Torch sees CUDA
- RTX 5090 is visible

## What Works Right Now

### Confirmed Working

1. Studio backend code loads and serves.
2. Simplified quick image flow works.
3. Quick image output was created successfully.
4. Simplified quick video path was repaired and a real video file was written.
5. Project/job files are being written into `StudioOS`.
6. WSL distro mismatch was identified and the launcher files were corrected.

### Verified Example Outputs

Quick image:

- `.\StudioOS\outputs\image\StudioOS_cinematic_portrait_of_a_confident_beauty_creator_in_01_1773546447.png`

Quick video:

- `.\StudioOS\outputs\video\cinematic_teaser_about_a_futuristic_city_at_sunrise_cinematic_teaser_about_a_futuristic_city_at_sunrise_simple_1773546760.mp4`

Sequence manifest for that quick video:

- `.\StudioOS\projects\cinematic_teaser_about_a_futuristic_city_at_sunrise\manifests\cinematic_teaser_about_a_futuristic_city_at_sunrise_sequence_1773546761.json`

Job record:

- `.\StudioOS\projects\cinematic_teaser_about_a_futuristic_city_at_sunrise\jobs\cinematic_teaser_about_a_futuristic_city_at_sunrise_1773546769_d114a64b.json`

## What Does Not Work Reliably Yet

### 1. ComfyUI Startup Reliability

This is the main unresolved infrastructure issue.

Current truth:

- ComfyUI is not reliably staying up on `8188`
- when it fails, the Studio falls back to placeholder / fallback imagery instead of true Comfy generation

Reason identified:

- wrong Python/Torch stack was used in some launches
- there are conflicting launch assumptions between:
  - `.\AI\ComfyUI`
  - `.\ComfyUI`

### 2. One-Click Startup Reliability

The desktop launcher is corrected for distro name, but the whole startup chain still needs to be treated as a service problem, not a UI problem.

Needs:

- one stable startup script
- one health check
- browser only opens after both services are actually alive

### 3. True High-Quality Video Generation

Current quick video behavior:

- bundle stills are generated
- then ffmpeg sequence video is built from those stills

This is usable as a block builder, but it is not yet the final “true local video model” lane.

Missing:

- stable one-click routing into the installed local image-to-video / video models for the main product path

### 4. Product Scope Is Still Too Large

There are too many advanced layers exposed in the codebase relative to what is needed for a working first product.

The simple studio should be:

- prompt
- optional image
- length
- create image
- create video
- stitch blocks

Everything else should be secondary.

## What Needs To Be Fixed Next

### Priority 1: ComfyUI

Lock ComfyUI startup to the correct runtime:

- working dir:
  - `.\AI\ComfyUI`
- python:
  - `E:\Miniconda3\envs\abu-comfyui\python.exe`

Required final command:

```powershell
& 'E:\Miniconda3\envs\abu-comfyui\python.exe' '.\AI\ComfyUI\main.py' --listen 0.0.0.0 --port 8188
```

Then verify:

```bash
curl http://172.21.32.1:8188/system_stats
```

Do not continue product work until this is reliable.

### Priority 2: Studio Startup

Make startup boring:

1. start ComfyUI
2. start `studio_mvp`
3. start `studio_worker_router`
4. wait for health
5. open browser

No browser tabs should open before health checks pass.

### Priority 3: Keep Only The Simple Product Surface

First-class UI should only show:

- prompt
- optional image
- duration: 1 / 5 / 10 / 20
- `Generate Image`
- `Generate Video`
- `Stitch Blocks`
- latest outputs

Everything else should move into:

- advanced mode

### Priority 4: True Video Engine Integration

Replace or augment the current still-sequence path with the real local video lane once ComfyUI is stable.

Goal:

- one block generator that can reliably create:
  - 1 min
  - 5 min
  - 10 min
  - 20 min

Then stitch blocks for longer productions.

## Current Distance From The Intended Product

### Prompt + Image -> Image

Status:

- mostly there

Estimated:

- 80% of the way to the intended first product

### Prompt + Image -> Video Block

Status:

- partially there
- works through bundle + sequence path
- not yet the polished final engine path

Estimated:

- 60% of the way to the intended first product

### One-Click “Simple Studio”

Status:

- partially there
- simplified UI exists
- startup/runtime still too fragile

Estimated:

- 55% of the way to the intended first product

### “Disney / DreamWorks / Pixar / A1 Studios” Level

Status:

- not close

Reason:

- that requires:
  - locked consistency engine
  - better shot coverage planning
  - stronger character continuity
  - sound design pipeline
  - review/reject workflow
  - editor-grade assembly
  - much tighter video generation quality

Current realistic status:

- this is a rough local studio foundation
- not a finished high-end animation studio

## Why It Took So Long

Two mistakes:

1. scope creep

- too many orchestration features were built before runtime was boring

2. startup/runtime was treated as secondary

- but startup/runtime is the product for something like this
- if engines do not come up cleanly, the rest does not matter

## Exact Files The Team Should Inspect First

### Product Surface

- `/home/user/.openclaw/workspace/council_table/static/studio_mvp.html`
- `/home/user/.openclaw/workspace/council_table/studio_mvp.py`

### Startup

- `.\StudioOS\start_all_studioos.cmd`
- `~\Desktop\Start ABU StudioOS.cmd`

### Studio Server Wrappers

- `.\StudioOS\bin\studio-mvp-server.sh`
- `.\StudioOS\bin\studio-router-server.sh`

### Engine Root

- `.\AI\ComfyUI`

### Evidence Of Wrong Runtime

- `.\AI\ComfyUI\startup_log.txt`

### Evidence Of GPU-Capable Runtime

Use:

```powershell
& 'E:\Miniconda3\envs\abu-comfyui\python.exe' -c "import torch; print(torch.__version__); print(torch.cuda.is_available()); print(torch.cuda.get_device_name(0))"
```

## If A New Team Takes Over

Recommended immediate sequence:

1. get ComfyUI stable on `8188`
2. verify Studio health on `29212`
3. verify router health on `29213`
4. test only `Quick Create -> Image`
5. test only `Quick Create -> Video`
6. remove / hide anything that is not needed for those two flows
7. only after that, continue with stitching and longer film blocks

## Bottom Line

What exists now is not the final simple studio you originally asked for.

But there is a real foundation:

- simple quick UI exists
- image flow works
- video block flow works in a basic sequence form
- project/job/output system exists

The missing part is not “ideas.”

The missing part is:

- stable ComfyUI runtime
- stable startup
- ruthless product simplification

That is the shortest path to the working studio.
