# Uber-Eleet player preference

## Why

Uber-Eleet is already supported by the client, but the server currently disables it for every mission. Players need a persistent, easily accessible choice instead of a hard-coded flag.

## Scope

This feature covers the player's Uber-Eleet preference and its use when a mission starts.

## Rules

### New players start in standard mode

`{#missions.uber-eleet.player-preference::default-disabled}`

A newly created player has Uber-Eleet disabled by default.

### The preference is persistent

`{#missions.uber-eleet.player-preference::persisted}`

Changing the preference before launching a mission updates the player's saved preference and affects later mission launches.

### Existing players default to standard mode

`{#missions.uber-eleet.player-preference::legacy-default-disabled}`

A player record created before this preference existed can still be loaded, and its missing preference is treated as disabled.

### The preference is accessible before launch

`{#missions.uber-eleet.player-preference::accessible-before-launch}`

The missions page displays a player-level checkbox showing the current preference. Saving it enabled selects Uber-Eleet for future missions; saving it unchecked selects standard mode.

### Mission startup receives the selected mode

`{#missions.uber-eleet.mission-start::profile-flag}`

When a mission starts, the serialized client profile contains `_leet: true` when the player's preference is enabled and `_leet: false` otherwise.

### The choice is fixed for the mission

`{#missions.uber-eleet.mission-start::fixed-at-start}`

Changing the preference applies to the next mission launch; this feature does not add an in-mission mode switch.

### First activation initializes safely

`{#missions.uber-eleet.client-startup::safe-first-activation}`

When Uber-Eleet is enabled for the first time in a mission, the client initializes the command line without requiring a command-line view to already exist.

### Typed commands are visible

`{#missions.uber-eleet.client-input::typed-characters-visible}`

While the command line has focus, typed printable characters are added to the visible command text. Control shortcuts remain available, and special non-character keys are not added as text.

### Command-line keys stay in the game

`{#missions.uber-eleet.client-input::prevent-browser-navigation}`

While an Uber-Eleet mission is active, non-modified keyboard commands, including Enter, are handled by the game instead of triggering browser navigation or link activation.

### Command text starts at the visible prompt

`{#missions.uber-eleet.client-input::text-aligned-with-bar}`

The visible command text starts at the left input position of the command bar, is vertically centered in the bar, and does not reserve space for an unavailable static prompt.

## Acceptance criteria

- Given a new player, when the player is created, then Uber-Eleet is disabled.
- Given a player record without an Uber-Eleet preference, when it is loaded, then Uber-Eleet is disabled.
- Given a player with Uber-Eleet disabled, when the missions-page setting is saved enabled, then the saved preference becomes enabled.
- Given a player with Uber-Eleet enabled, when the missions-page setting is saved unchecked, then the saved preference becomes disabled.
- Given an enabled player preference, when a mission starts, then the client profile enables Uber-Eleet.
- Given an enabled player preference and no existing command-line view, when the client initializes, then the mission starts without a null-reference error.
- Given a focused command line, when the player types a letter or space, then that character is visible in the command line.
- Given a focused command line, when the player presses a control shortcut or a navigation key, then it is not appended as command text.
- Given an active Uber-Eleet mission, when the player presses Enter without a modifier, then the browser does not navigate away from the mission.
- Given a visible command bar, when command text is displayed, then it starts at the bar's left input position and is vertically centered.
- Given a disabled player preference, when a mission starts, then the client profile disables Uber-Eleet.
- Given an existing mission started without a mode switch, when the preference changes later, then the running mission remains unchanged.

## Out of scope

- Toggling Uber-Eleet during an active mission.
- Replacing the existing client command parser; this feature only supplies visible keyboard input.
- Enabling Uber-Eleet for tutorial missions that the client currently forces into standard mode.
