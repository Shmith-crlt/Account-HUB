# Account-HUB

Account-HUB is a World of Warcraft Retail addon focused on account-wide Mythic+, Great Vault, season currency, guild key sharing, KeystoneLoot imports, and MDT route support.

## Features

- Mythic+ overview with total score and seasonal dungeon rows
- Party Keys and Guild panels
- Great Vault progress grid with tooltips
- Season Portals, Season Currencies, and Dungeon item level reference
- Character tabs for account-wide snapshots
- KeystoneLoot import panel for loot targets
- MDT-based Next Pull panel with manual advance, back, reset, and popout support

## Repository Layout

- `Core/` bootstrap and localization
- `UI/` frames, styling, minimap button, and panel layout
- `Modules/` gameplay features and feature-specific logic
- `Data/` static import and lookup data
- `Assets/Branding/` logo and addon artwork
- `dist/` built release archives

## Optional Addons

The addon works best with these optional addons installed:

- `MythicDungeonTools`
- `TomTom`
- `HandyNotes`

## Slash Commands

- `/hub`
- `/hub pull`
- `/hub pull refresh`
- `/hub pull detach`
- `/hub pull dock`
- `/hub ksl`

## Packaging Notes

- This repository is prepared for CurseForge/WowAce packaging with `.pkgmeta`.
- The release package is built as `Account-HUB` and includes `Account-HUB.toc`.
- The visible in-game addon title is `Account-HUB`.

## Retail Version

- Interface: `120000`
- Flavor: `World of Warcraft Retail`
