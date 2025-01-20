# CrimDoc Script

A QBCore criminal doctor script providing alternative healing locations for players when EMS is unavailable.

## Features

- Multiple configurable doctor locations
- Server synced doctor availability status
- Optional item requirements for treatment
- Configurable costs and payment methods
- Society payment integration
- Optional email notifications
- Blip configuration for each location
- Treatment animations with progress bar
- Target integration for easy interaction

## Requirements

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target)
- [ox_lib](https://github.com/overextended/ox_lib)
- [qb-phone](https://github.com/qbcore-framework/qb-phone) (optional, for email notifications)

## Installation

1. Download the script
2. Place `sg-crimdoc` into your `resources` folder or `[sg]` directory (remove `-main` from folder if necessary)
3. Add `ensure sg-crimdoc` to your server.cfg (after qb-core and dependencies)
4. Configure options in `config.lua` to your liking
5. Restart your server

## Configuration

All configuration options can be found in the `config.lua` file.

Some key options:

- `Config.Locations` - Set up doctor locations, models, and treatment options
- `Config.Mail` - Configure email notification settings
- `Config.Debug` - Toggle debug mode for troubleshooting
- Cost and payment settings per location:
  - Treatment cost
  - Payment method (cash/bank/crypto)
  - Society payment options

- Email Trigger
  - If you need to modify the email to fit your phone script, this can be done in the `sendBillEmail` function
  - Lines 28-33 are the event to send the main, adjust as needed.

- Revive Trigger
  - If using a different ambulance script, other than qb-ambulance, and need to change the Revive trigger
  - Client/main.lua, line 118

## Usage

Walk up to any configured doctor location and:
1. Interact with the doctor using the target system
2. Pay the configured fee
3. Receive treatment with visual feedback
4. Receive optional email confirmation

## Credits

- [Nicky](https://forum.cfx.re/u/Sanriku)
- [SG Scripts Discord](https://discord.gg/uEDNgAwhey)

## Maps Used

- Default locations in confir are for the below maps:
  - [Tunnel Hideout](https://forum.cfx.re/t/free-mlo-tunnel-hideout/5158677)
  - [Blood Bank](https://forum.cfx.re/t/free-mlo-blood-bank/4830236)