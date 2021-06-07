# Changelog 

## 4.0.0 (2021-06-08)

* Updated to support new Plasma 5.21 design and features

## 2.8.4 (2019-12-5)

* Fixes various spacing issues, especially with scaling enabled.

## 2.8.2 (2019-5-25)

Adds support for some things added in 1.30 HUE API, namely:
* new types of rooms
* entertainment groups (limited support, can't be edited, but can be controlled or removed)
* zones (full support, but not throughout tested)

## 2.8.0 (2018-11-17)

* This release finally adds shippable translations for Get new plasmoids / .plasmoid methods.
* Non-undoable deletion of actions, lights, groups and schedules now asks for confirmation.

## 2.6.2 (2018-3-1)

* Fix a bug caused by a hue update, so it no longer immediately returns up to date info about a group or light. 

## 2.6.0 (2017-02-08) 

* Add coloured icons for all types
* Change the editAction GUI to make icon and colour easier to pick

## 2.4.4 (2017-02-01)

* Fix a bug in ActionEditor when "All lights" is selected
* Add some placeholder texts in bridge config
* Add http as a default protocol when none is given

## 2.4.2 (2017-01-30) 

* Existing action commands can now be edited
* Fix a bug that prevented weekly schedules to be filled correctly
* Fix a bug that prevented action editor from loading an "off" state correctly
* Workaround a plasma bug that makes configuration unavailable
* Update tooltip as soon as data is initially available

## 2.2.0 (2017-01-28)

* ActionEditor now can load existing actions, thus you can modify existing schedule commands
* Added Swiss German as translation
* Bug fixes 
* Translation updates

## 2.0.2 (2017-01-22)

* Fix potential bug when opening the config before the plasmoid
* Update translations 

## 2.0.0 (2017-01-20)

* Lights can be added and edited (renamed)
* Groups can be added and edited
* Actions allow fading, effects and blinking
* Schedules can be added and edited
* Bug fixes all over the place
* 100% translated to German

## 1.0.0 (2017-01-14) 

* Actions
  * Show two default actions, turn on and off all lamps
  * Offer a GUI to add and remove actions

* Lights
  * Show all lights with curent status, coloured
  * Switch lights on / off
  * Adjustable brightness
  * Adjustable colour
  * Adjustable white temperature
  * Show detailled light info 

* Groups
  * Show all groups with curent status, coloured, with room type icon
  * Lights of a group are children items, with the same possibilites as "Lights"
  * Switch groups on / off
  * Adjustable brightness
  * Adjustable colour
  * Adjustable white temperature
  * Show detailled group info 
  
* Bridge
  * Configurable bridge address, auto-discoverable via Philips Server
  * Authentication with bridge from config dialogue
  * Alt address can be set including http basic auth, only used when main address is unreachable

* Translations
  * Prepared for translations
