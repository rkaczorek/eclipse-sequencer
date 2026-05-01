# Eclipse Sequencer
Eclipse Sequencer is a lua script for Magic Lantern, which automates imaging session of Total Solar Eclipse.

![Solar Eclipse](https://github.com/rkaczorek/eclipse-sequencer/blob/master/media/DiamondRingChile2019.jpg)

The script features:
- Configurable times for Contact 1 to 4
- All eclipse phases: Partial, Diamon Ring, Bailey's Beads, Totality, Earthshine
- Configurable lead and trail times (imaging before and after eclipse)
- Start time bound to real time clock
- UTC and local time support
- Test mode activated from Magic Lantern menu
- Session logging to file
- Stop and resume after battery change or camera restart

# How to use it?
Download the script and place it in ML/scripts directory on your SD card
Reconfigure the timing parameters of an eclipse
Reconfigure sequence parameters to fit your needs
Run the script from Magic Lantern menu

# How to reconfigure it?
Edit the script and change:
- timing parameters in lines 27-30
- other parameters in lines 39-47

Exposure times assume that the eclipse happens while the Sun is well above the horizon.
If any event happens while the Sun is close to a sunrise or a sunset, exposure times must be adjusted accordingly.

**Example** If the eclipse is ending just before sunset, set exposure times for the partial eclipse in the ending phase to 1/250 - 1/2 instead of standard 1/250 - 1/500.
This will handle the fact that the Sun will be getting darker (due to the sunset), even though it will be "opening" at the end of the eclipse.

# Issues
File any issues on https://github.com/rkaczorek/eclipse-sequencer/issues

