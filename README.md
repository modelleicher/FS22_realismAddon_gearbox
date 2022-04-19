# FS22_realismAddon_gearbox
This is it, RMT (real manual transmission) for FS22 is back. Well kind of.
The goal with this mod is to fix all the large and little problems realism players have with the default FS22 transmissions, mainly aimed and made for players with steering wheel and pedals. 
As of right now this is a work in progress and BETA so don't get mad at me if some problem might arise. Anyways, we've played this on Multiplayer for several hours and in Singleplayer as well so all should be fine though smaller issues might still exist.
If you have any issues or any improvement ideas please feel free to open a issue :)

Currently this isn't compatible with VCA due to overwriting the same function. If you need 4WD and other features that VCA has you can use Enhanced Vehicle for now, but I hope I can work out a way to make it compatible to VCA.
 

# Credits
- mainly me, Modelleicher
- bases on Giants stuff 
 
# Changelog:

###### V 0.5.0.0
- Initial Github Release for FS22, 19th or April 2022 



# Features of the initial Release V 0.5
- displayed and sound-rpm is as close to the actual/physical rpm as possible, no fake rpm drop and lagging behind anymore 
- clutch and engine rpm is matched if clutch is released
- new clutch calculation that allows the clutch to actually slip, clutch feel of RMT is back 
- new rpm calculation, 50% throttle means 50% rpm as long as the engine has the power for it (linear throttle pedal)
- idle rpm is kept even if vehicle is under load or clutch is released (no need to hit the throttle in order for the vehicle to start moving anymore) 
- if in neutral or clutch pressed engine can archieve load when accelerating (hitting the throttle while down/upshifting for nice sound like IRL)
- hand throttle added thats physically identical to throttle pedal so it works like it should (buttons for up/down and alternative axis input)
- implements don't raise RPM automatically, you have to set whatever rpm you want to work at manually with the hand throttle 
- gear-shift-axis for FPS transmissions added (to use an axis for shifting through the gears on old FPS transmissions) 

All of that should be familier with people who player RMT in FS19 as it is pretty much the same :)
