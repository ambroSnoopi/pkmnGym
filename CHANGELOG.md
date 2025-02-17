# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added 
- Python Interface for Local and Online AI Models (v0.2)
- AI (with battler_idx=1) now use a ML Model for choosing a move
- Logging all Attributes that are also used by the Classic PBS AI (incl. Effects)
- Logger now keeps track about already seen Battlers
- support for double & triple battles
### Removed
### Changed
### Fixed
- situationID of turn ends

## [0.1.2]
### Added 
- gameVersion, rep, sid & label to logs
- DamageStateLog, PokemonLog
- level to battler log
- party to trainer log
- notification when your rep is high enough for an upgrade
- ML_VERSION
### Changed
- naming of logs
- MoveLog now relates to Pokemon_Move not Battle_Move
- Move in Choices is now logged using MoveLog not just the Symbol
### Fixed
- logger now records any battle regardless of the battle typ (incl. simulations)
- decision, choices, nested values, "#" & "nil" handling in logs
- EV capped as indended when using Vitamins (possibly also in battles)
- missleading msg when cancelling "Switch Type" at Prof Aid (RMXP-only)
- Vitamins shopkeeper dissapearing after 1st interaction (RMXP-only)

## [0.1.1]
### Added 
- Rank now shows as Badges on Trainer Card
- Forfeiting Trainer Battles is now allowed
- Roadblocks around the City (RMXP-only)
- Rewards for 4th and 5th Rank
### Fixed
- upgradeLicense now displays all inherent benefits and updates the box as intended
- switching type is preserved & displayed properly
- fixed new game intro (RMXP-only)

## [0.1.0] - 2023-03-02 - ALPHA
### Added
- Play as a Gym Leader with a Rank system
- Rules, Restrictions and Rewards based on your Rank
- Generate & fill box with adequate Pkmn
- Generate Challangers with adequate Pkmn
- Log Battles as JSON for future processing with Machine Learning


[unreleased]: https://github.com/ambroSnoopi/pkmnGym/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/ambroSnoopi/pkmnGym/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/ambroSnoopi/pkmnGym/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/ambroSnoopi/pkmnGym/releases/tag/v0.1.0
