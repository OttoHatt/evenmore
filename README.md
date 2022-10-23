<div align="center">
	<img src=".moonwave/static/logo.svg" height="80" alt="Evenmore logo"/>
	<hr/>
</div>

<!--moonwave-hide-before-this-line-->

A collection of yet *even more* [Nevermore](https://github.com/Quenty/NevermoreEngine) packages.

The packages in this monorepo are more than just utilities, each provides a complete-ish feature. They're generic enough to be used in (almost) any game! Hopefully this will make your game development easier and funner.

## Packages
| Name | Description |
| --- | --- |
| Soundscape | Drop-in soundscapes with a library of existing sounds. Automatically switches between soundscapes when inside tagged `BasePart`/`Model` triggers. Included format is simple with examples -  you can easily design your own soundscapes! |
| Storybar | Provides labelled sliders and buttons; slot them together to create specialised tests for your Hoareckat stories. Integrates with existing Nevermore classes like `BasicPane`. |

## Usage
Modules above the top level of a package are considered private. Requiring them is not intended; they're undocumented, and will receive breaking changes.

Nevermore's module loader requires `.lua` files via their name, rather than some kind of local path. This is a great convenience feature but it may cause naming conflicts when this repo is dropped into your existing code. If this is a problem, please open an issue to get files renamed!

Packages prefixed with an underscore (i.e. `_evenmoreui`) provide functionality for other packages. They are not intended for end users.

## Installation
Installing as a git submodule is reccomended. Support for the [Wally](https://github.com/UpliftGames/wally) package manager is not planned.
```
git submodule add https://github.com/ottohatt/evenmore lib/evenmore
```
The synced files must be placed inside your boostrapped folder, adjacent to Nevermore packages. For example, in your [Rojo](https://github.com/rojo-rbx/rojo) `project.json` file.
```json
"packages": {
	"$className": "Folder",
	"@quenty": {
		"$path": "lib/nevermore/"
	},
	"@ottohatt": {
		"$path": "lib/evenmore/"
	},
	"game": {
		"$path": "src/"
	}
}
```

## Contributions
PRs and issues welcome!