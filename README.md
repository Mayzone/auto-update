# Install instructions and big update log

Install instructions:

Download and install superBLT from https://superblt.znix.xyz/

Put hook and hookloc folder from hook.zip inside your mods folder usually located at "C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2"

This mod included MoreAFK mod. Remove MoreAFK if you have it.

Start game. All keybinds can be configured in "options" then "mod keybinds".

Optionally you can change your name back by writing this line into game chat "\steamn".

For more commands, checkout "\h".

----------------------------------------------------------------------
Update 10. 29.1.2022

Added \macro <remove/10/false> <Your command to macro> <Command arguments>
  
Added \tp <player id>
  
Added ap sentries script

Added mod option for hook, to enable/disable mods that will show for others
  
Fixed set infamy keybind, you now need to double press keybind fast to get a level (To prevent miss press)
  
Fixed lobby filter
  
Fixed hacker perk (Auto flasker is disabled for functionality)
  
Fixed kill/bag/grab
  
Fixed hud problem
  
Fixed blt errors
  
Fixed identifier. The mod will not detect others with the same mod.

Update 9. 31.10.2021

Removed replaced \leveln command with \rankn

Fixed \rankn command

Fixed crash on start after new update

Update 8. 25.08.2021

Fixed lag with previous issue

Added better special equipment stacker

Added spoof level and rank with /leveln and /rankn. The spoofer now spoofs everything except join message

Update 7. 24.08.2021

Fixed DLC unlocker crash caused by a conflicting mod

Update 6. 9.08.2021 (Require fresh install)

Added tag team now works through walls

Added drills can be melee hit without kickstarter skill

Added toggle for trainer buffs in main menu

Added breaking feds helper

Added better chat commands code, able to scroll throught more commands

Added auto stoic flask and stoic for armor (can be changed in stoic.lua)

Added first load check, to show your correct name before spoofing it

Added a anti spoofname check to find people who spoofname

Added infamy keybind

Added auto pickup sentries on low ammo or health

Added a better ecm spawning with settings in ecm.lua

Added fire aura to magic menu

Added command to spoof level and rank with \rankn 1 20 or \leveln 1 100

Added start/end assault in mission menu

Added new improved aimbot shoot/aim version, settings in aimbot1.lua

Fixed carrystacker client kicking you randomly

Fixed experience hud and cleaned it

Fixed crash related to not having weapon skin dlc and choosing a custom skin

Fixed xray removing converted highlight when toggled off

Fixed xray bugging on buluc

Update 5. 18.12.2020 (Require fresh install)

Fixed bugs and crashes

Added better anit cheats

Added more menu buttons

Update 4. 24.10.2020 (Require fresh install)

Improved \afk

Improved noclip, autosecure, automsg, crosshair

Improved cpu performance

Fixed crimespree level button

Added autocooker for rat lab

Added server checks to prevent crashes

Added crimespree reset button

Added halfass perk reset button

Removed persist script

Update 3. 26.09.2020

Added snatch pager projectile

Fixed \list and \steamn command

Fixed convert crash/disconnect

Graze skill ignores civilians

Kill all units, kills converted


Update 2. 28.06.2020 (Require fresh install)

Fixed sixth sense and chameleon skills

Added mask off as default state, civilian state can still interact with objects

Added \ps command (pager snitch)

Added custom join msg with command using \automsg host/client (any message)

Added answer pager client side in mission menu

Added auto pager when shooting while snitcher is on

Added car shop in misison menu

Added total secured loot display

Added mark and intimidate enemy in civilian mode


Update 1. 24.06.2020

Fixed unlock perks reseting when used

Fixed convert unit upgradestweakdata crashing players

Fixed |killloop command client crash

Fixed |auto command on heists that doesn't work

Fixed killbaggrab for cliient side

Fixed all magicmenu buttons working client side

Fixed slow all peers crash when leave game

Fixed not being able to run with cloaker bags

Fixed interaction with multiple cams working client side

Fixed xray contour fading crash

Added menu color changer in mainmenu, restart game after for full change

Added check for total meth on heist using autocooker

Added 100% chance to melee drill

Added 1.35 damage multiplier to melee to easier steal pagers

Added kill cameras if not host when using camera on/off in magic menu

Added secondary equipment option in mainmenu

Added murkystation and henrys rock to missionmenu

Added |steamn ref, for refresh name when ingame. Reset also reset easier

Added |r command to reply to someone sending you a |pm with same mod

Added |l does same as arrow key up to pick last used command

Added |noclip <1> and |killloop <1> for change speed, if no argument is used, it will turn on/off

Added |automsg <client/host/ref>, just |automsg turns auto message on/off

Added killall/killloop/killbaggrab support on breaking feds

Removed |lobbyn command and will only use |steamn, now saves name in command folder config
