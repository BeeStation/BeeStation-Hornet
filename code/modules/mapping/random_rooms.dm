/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 1 //how many times this room can appear in a round

/datum/map_template/random_room/sk_rdm001
	name = "Maintenance Storage"
	room_id = "sk_rdm001_9storage"
	mappath = "_maps/RandomRooms/3x3/sk_rdm001_9storage.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2


/datum/map_template/random_room/sk_rdm002
	name = "Maintenance Shrine"
	room_id = "sk_rdm002_shrine"
	mappath = "_maps/RandomRooms/3x3/sk_rdm002_shrine.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm003
	name = "Maintenance"
	room_id = "sk_rdm003_plasma"
	mappath = "_maps/RandomRooms/3x3/sk_rdm003_plasma.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm004
	name = "Maintenance Tanning Booth"
	room_id = "sk_rdm004_tanning"
	mappath = "_maps/RandomRooms/3x3/sk_rdm004_tanning.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm005
	name = "Maintenance Washroom"
	room_id = "sk_rdm005_wash"
	mappath = "_maps/RandomRooms/3x3/sk_rdm005_wash.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm006
	name = "Maintenance"
	room_id = "sk_rdm006_gibs"
	mappath = "_maps/RandomRooms/3x3/sk_rdm006_gibs.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm007
	name = "Maintenance"
	room_id = "sk_rdm007_radspill"
	mappath = "_maps/RandomRooms/3x3/sk_rdm007_radspill.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm008
	name = "Maintenance Storage"
	room_id = "sk_rdm008_2storage"
	mappath = "_maps/RandomRooms/3x3/sk_rdm008_2storage.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm009
	name = "Air Refilling Station"
	room_id = "sk_rdm009_airstation"
	mappath = "_maps/RandomRooms/3x3/sk_rdm009_airstation.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm010
	name = "Maintenance HAZMAT"
	room_id = "sk_rdm010_hazmat"
	mappath = "_maps/RandomRooms/3x3/sk_rdm010_hazmat.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm011
	name = "Barber Shop"
	room_id = "sk_rdm011_barbershop"
	mappath = "_maps/RandomRooms/10x5/sk_rdm011_barbershop.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm012
	name = "Box Bar"
	room_id = "sk_rdm012_boxbar"
	mappath = "_maps/RandomRooms/5x4/sk_rdm012_boxbar.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm013
	name = "Box Kitchen"
	room_id = "sk_rdm013_boxkitchen"
	mappath = "_maps/RandomRooms/3x5/sk_rdm013_boxkitchen.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm014
	name = "Box Window"
	room_id = "sk_rdm014_boxwindow"
	mappath = "_maps/RandomRooms/3x3/sk_rdm014_boxwindow.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm015
	name = "Box Clutter 1"
	room_id = "sk_rdm015_boxclutter1"
	mappath = "_maps/RandomRooms/5x3/sk_rdm015_boxclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm016
	name = "Box Clutter 2"
	room_id = "sk_rdm016_boxclutter2"
	mappath = "_maps/RandomRooms/3x3/sk_rdm016_boxclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm017
	name = "Box Clutter 3"
	room_id = "sk_rdm017_boxclutter3"
	mappath = "_maps/RandomRooms/3x3/sk_rdm017_boxclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm018
	name = "Box Clutter 4"
	room_id = "sk_rdm018_boxclutter4"
	mappath = "_maps/RandomRooms/3x3/sk_rdm018_boxclutter4.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm019
	name = "Box Clutter 5"
	room_id = "sk_rdm019_boxclutter5"
	mappath = "_maps/RandomRooms/3x3/sk_rdm019_boxclutter5.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm020
	name = "Box Clutter 6"
	room_id = "sk_rdm020_boxclutter6"
	mappath = "_maps/RandomRooms/3x3/sk_rdm020_boxclutter6.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm021
	name = "Box Dinner"
	room_id = "sk_rdm021_boxdinner"
	mappath = "_maps/RandomRooms/5x4/sk_rdm021_boxdinner.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm022
	name = "Box Chem Closet"
	room_id = "sk_rdm022_boxchemcloset"
	mappath = "_maps/RandomRooms/3x3/sk_rdm022_boxchemcloset.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 7

/datum/map_template/random_room/sk_rdm023
	name = "Box Clutter 7"
	room_id = "sk_rdm023_boxclutter7"
	mappath = "_maps/RandomRooms/3x5/sk_rdm023_boxclutter7.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm024
	name = "Box Bedroom"
	room_id = "sk_rdm024_boxbedroom"
	mappath = "_maps/RandomRooms/3x3/sk_rdm024_boxbedroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm025
	name = "Box Clutter 8"
	room_id = "sk_rdm025_boxclutter8"
	mappath = "_maps/RandomRooms/3x3/sk_rdm025_boxclutter8.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm026
	name = "Box Clutter 8"
	room_id = "sk_rdm026_boxsurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm026_boxsurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/*/datum/map_template/random_room/sk_rdm027
	name = "Box Hull Breach"
	room_id = "sk_rdm027_hullbreach"
	mappath = "_maps/RandomRooms/3x3/sk_rdm027_hullbreach.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3 */

/datum/map_template/random_room/sk_rdm028
	name = "Tranquility"
	room_id = "sk_rdm028_tranquility"
	mappath = "_maps/RandomRooms/3x3/sk_rdm028_tranquility.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm029
	name = "Delta Bar"
	room_id = "sk_rdm029_deltabar"
	mappath = "_maps/RandomRooms/5x4/sk_rdm029_deltabar.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm030
	name = "Delta Lounge"
	room_id = "sk_rdm030_deltalounge"
	mappath = "_maps/RandomRooms/5x4/sk_rdm030_deltalounge.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm031
	name = "Delta Robotics"
	room_id = "sk_rdm031_deltarobotics"
	mappath = "_maps/RandomRooms/10x5/sk_rdm031_deltarobotics.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 5

/datum/map_template/random_room/sk_rdm032
	name = "Delta EVA"
	room_id = "sk_rdm032_deltaEVA"
	mappath = "_maps/RandomRooms/5x4/sk_rdm032_deltaEVA.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 3

/datum/map_template/random_room/sk_rdm033
	name = "Delta Library"
	room_id = "sk_rdm033_deltalibrary"
	mappath = "_maps/RandomRooms/10x10/sk_rdm033_deltalibrary.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 7

/datum/map_template/random_room/sk_rdm034
	name = "Delta Detective Office"
	room_id = "sk_rdm034_deltadetective"
	mappath = "_maps/RandomRooms/5x4/sk_rdm034_deltadetective.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm035
	name = "Delta Surgery"
	room_id = "sk_rdm035_deltasurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm035_deltasurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm036
	name = "Delta Owl Office"
	room_id = "sk_rdm036_owloffice"
	mappath = "_maps/RandomRooms/3x3/sk_rdm036_owloffice.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 7

/datum/map_template/random_room/sk_rdm037
	name = "Delta Janitor Closet"
	room_id = "sk_rdm037_deltajanniecloset"
	mappath = "_maps/RandomRooms/3x3/sk_rdm037_deltajanniecloset.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm038
	name = "Delta Dressing Room"
	room_id = "sk_rdm038_deltadressing"
	mappath = "_maps/RandomRooms/5x4/sk_rdm038_deltadressing.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm039
	name = "Delta Clutter 1"
	room_id = "sk_rdm039_deltaclutter1"
	mappath = "_maps/RandomRooms/10x5/sk_rdm039_deltaclutter1.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm040
	name = "Delta Botany"
	room_id = "sk_rdm040_deltabotnis"
	mappath = "_maps/RandomRooms/10x5/sk_rdm040_deltabotnis.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 9

/datum/map_template/random_room/sk_rdm041
	name = "Delta Gambling Den"
	room_id = "sk_rdm041_deltagamble"
	mappath = "_maps/RandomRooms/5x4/sk_rdm041_deltagamble.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm042
	name = "Delta Clutter 2"
	room_id = "sk_rdm042_deltaclutter2"
	mappath = "_maps/RandomRooms/5x3/sk_rdm042_deltaclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm043
	name = "Delta Clutter 3"
	room_id = "sk_rdm043_deltaclutter3"
	mappath = "_maps/RandomRooms/5x3/sk_rdm043_deltaclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/*/datum/map_template/random_room/sk_rdm044
	name = "Delta Organ Trade"
	room_id = "sk_rdm044_deltaorgantrade"
	mappath = "_maps/RandomRooms/3x3/sk_rdm044_deltaorgantrade.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3*/

/datum/map_template/random_room/sk_rdm045
	name = "Delta Cafeteria"
	room_id = "sk_rdm045_deltacafeteria"
	mappath = "_maps/RandomRooms/10x5/sk_rdm045_deltacafeteria.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 7

/datum/map_template/random_room/sk_rdm046
	name = "Delta Arcade"
	room_id = "sk_rdm046_deltaarcade"
	mappath = "_maps/RandomRooms/10x5/sk_rdm046_deltaarcade.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm047
	name = "Meta Robotics"
	room_id = "sk_rdm047_metarobotics"
	mappath = "_maps/RandomRooms/5x4/sk_rdm047_metarobotics.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 5

/datum/map_template/random_room/sk_rdm048
	name = "Meta Theatre"
	room_id = "sk_rdm048_metatheatre"
	mappath = "_maps/RandomRooms/5x4/sk_rdm048_metatheatre.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm049
	name = "Meta Kitchen"
	room_id = "sk_rdm049_metakitchen"
	mappath = "_maps/RandomRooms/5x4/sk_rdm049_metakitchen.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm050
	name = "Meta Medical Closet"
	room_id = "sk_rdm050_medicloset"
	mappath = "_maps/RandomRooms/3x3/sk_rdm050_medicloset.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm051
	name = "Meta Gamer Gear"
	room_id = "sk_rdm051_metagamergear"
	mappath = "_maps/RandomRooms/3x3/sk_rdm051_metagamergear.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm052
	name = "Meta Clutter 1"
	room_id = "sk_rdm052_metaclutter1"
	mappath = "_maps/RandomRooms/5x3/sk_rdm052_metaclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm053
	name = "Meta Clutter 2"
	room_id = "sk_rdm053_metaclutter2"
	mappath = "_maps/RandomRooms/3x3/sk_rdm053_metaclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm054
	name = "Meta Clutter 3"
	room_id = "sk_rdm054_metaclutter3"
	mappath = "_maps/RandomRooms/5x3/sk_rdm054_metaclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm055
	name = "Meta Medical"
	room_id = "sk_rdm055_metamedical"
	mappath = "_maps/RandomRooms/5x4/sk_rdm055_metamedical.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm056
	name = "Meta Clutter 4"
	room_id = "sk_rdm056_metaclutter4"
	mappath = "_maps/RandomRooms/3x3/sk_rdm056_metaclutter4.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm057
	name = "Pubby Clutter 1"
	room_id = "sk_rdm057_pubbyclutter1"
	mappath = "_maps/RandomRooms/3x3/sk_rdm057_pubbyclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm058
	name = "Pubby Clutter 2"
	room_id = "sk_rdm058_pubbyclutter2"
	mappath = "_maps/RandomRooms/3x3/sk_rdm058_pubbyclutter2.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm059
	name = "Pubby Clutter 3"
	room_id = "sk_rdm059_pubbyclutter3"
	mappath = "_maps/RandomRooms/3x3/sk_rdm059_pubbyclutter3.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm060
	name = "Pubby Research Pit"
	room_id = "sk_rdm060_snakefighter"
	mappath = "_maps/RandomRooms/10x10/sk_rdm060_snakefighter.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm061
	name = "Pubby Clutter 4"
	room_id = "sk_rdm061_pubbyclutter4"
	mappath = "_maps/RandomRooms/5x3/sk_rdm061_pubbyclutter4.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm062 //TODO: add cockfights
	name = "Pubby ROOSTERDOME"
	room_id = "sk_rdm062_roosterdome"
	mappath = "_maps/RandomRooms/10x10/sk_rdm062_roosterdome.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm063
	name = "Pubby Clutter 5"
	room_id = "sk_rdm063_pubbyclutter5"
	mappath = "_maps/RandomRooms/3x5/sk_rdm063_pubbyclutter5.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm064
	name = "Pubby Robotics"
	room_id = "sk_rdm064_pubbyrobotics"
	mappath = "_maps/RandomRooms/3x5/sk_rdm064_pubbyrobotics.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm065
	name = "Pubby Clutter 6"
	room_id = "sk_rdm065_pubbyclutter6"
	mappath = "_maps/RandomRooms/3x5/sk_rdm065_pubbyclutter6.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm066
	name = "Pubby Bedroom"
	room_id = "sk_rdm066_pubbybedroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm066_pubbybedroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm067
	name = "Pubby Surgery"
	room_id = "sk_rdm067_pubbysurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm067_pubbysurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm068
	name = "Pubby Clutter 7"
	room_id = "sk_rdm068_pubbyclutter7"
	mappath = "_maps/RandomRooms/5x3/sk_rdm068_pubbyclutter7.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm069
	name = "Pubby Art Room"
	room_id = "sk_rdm069_pubbyartism"
	mappath = "_maps/RandomRooms/3x3/sk_rdm069_pubbyartism.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm070
	name = "Pubby Bar"
	room_id = "sk_rdm070_pubbybar"
	mappath = "_maps/RandomRooms/10x10/sk_rdm070_pubbybar.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10

/datum/map_template/random_room/sk_rdm071
	name = "Pubby Kitchen"
	room_id = "sk_rdm071_pubbykitchen"
	mappath = "_maps/RandomRooms/5x3/sk_rdm071_pubbykitchen.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm072 //donut is such a shit map, this was the ONLY room in its maintenance that was suitable.
	name = "Donut Capgun"
	room_id = "sk_rdm072_donutcapgun"
	mappath = "_maps/RandomRooms/3x3/sk_rdm072_donutcapgun.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm073
	name = "Kilo Mech Recharger"
	room_id = "sk_rdm073_kilomechcharger"
	mappath = "_maps/RandomRooms/3x3/sk_rdm073_kilomechcharger.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm074
	name = "Kilo Theatre"
	room_id = "sk_rdm074_kilotheatre"
	mappath = "_maps/RandomRooms/3x3/sk_rdm074_kilotheatre.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm075 //the bane of all unprepared greytiders who value their humanity. Though, it's mostly nonlethal...
	name = "Kilo Surgery"
	room_id = "sk_rdm075_kilosurgery"
	mappath = "_maps/RandomRooms/5x4/sk_rdm075_kilosurgery.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 6
	stock = 2 //because i hate you

/datum/map_template/random_room/sk_rdm076
	name = "Kilo Haunted Library"
	room_id = "sk_rdm076_kilohauntedlibrary"
	mappath = "_maps/RandomRooms/5x4/sk_rdm076_kilohauntedlibrary.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 4

/datum/map_template/random_room/sk_rdm077
	name = "Kilo Maid Den"
	room_id = "sk_rdm077_kilolustymaid"
	mappath = "_maps/RandomRooms/3x3/sk_rdm077_kilolustymaid.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm078
	name = "Kilo Clutter"
	room_id = "sk_rdm078_kiloclutter1"
	mappath = "_maps/RandomRooms/5x3/sk_rdm078_kiloclutter1.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm079 //comment this out if you want to avoid tiders dying to a simplemob once in awhile
	name = "Kilo Mob Den"
	room_id = "sk_rdm079_kilomobden"
	mappath = "_maps/RandomRooms/3x5/sk_rdm079_kilomobden.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 3
	stock = 2

/datum/map_template/random_room/sk_rdm080
	name = "Ancient Cloner"
	room_id = "sk_rdm080_cloner"
	mappath = "_maps/RandomRooms/5x3/sk_rdm080_cloner.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 1

/datum/map_template/random_room/sk_rdm081
	name = "Maint Viro"
	room_id = "sk_rdm081_biohazard"
	mappath = "_maps/RandomRooms/3x3/sk_rdm081_biohazard.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 3

/datum/map_template/random_room/sk_rdm082
	name = "Maint Chemistry"
	room_id = "sk_rdm082_maintmedical"
	mappath = "_maps/RandomRooms/10x5/sk_rdm082_maintmedical.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm083
	name = "Big Theatre"
	room_id = "sk_rdm083_bigtheatre"
	mappath = "_maps/RandomRooms/10x10/sk_rdm083_bigtheatre.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 9

/datum/map_template/random_room/sk_rdm084
	name = "Monky Paradise"
	room_id = "sk_rdm084_monky"
	mappath = "_maps/RandomRooms/3x5/sk_rdm084_monky.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm085
	name = "Hank's Room"
	room_id = "sk_rdm085_hank"
	mappath = "_maps/RandomRooms/3x5/sk_rdm085_hank.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm086
	name = "Max Tide's Last Stand"
	room_id = "sk_rdm086_laststand"
	mappath = "_maps/RandomRooms/3x5/sk_rdm086_laststand.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 3

/datum/map_template/random_room/sk_rdm087
	name = "Junk Closet"
	room_id = "sk_rdm087_junkcloset"
	mappath = "_maps/RandomRooms/3x5/sk_rdm087_junkcloset.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm088
	name = "Construction Zone"
	room_id = "sk_rdm088_bigconstruction"
	mappath = "_maps/RandomRooms/10x10/sk_rdm088_bigconstruction.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 5

/datum/map_template/random_room/sk_rdm089
	name = "Nasty Trap"
	room_id = "sk_rdm089_nastytrap"
	mappath = "_maps/RandomRooms/5x3/sk_rdm089_nastytrap.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 4

/datum/map_template/random_room/sk_rdm090
	name = "Tiny Barber's Shop"
	room_id = "sk_rdm090_tinybarbershop"
	mappath = "_maps/RandomRooms/5x4/sk_rdm090_tinybarbershop.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 7


/datum/map_template/random_room/sk_rdm091
	name = "Trash Room"
	room_id = "sk_rdm091_skidrow"
	mappath = "_maps/RandomRooms/10x5/sk_rdm091_skidrow.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10

/datum/map_template/random_room/sk_rdm092
	name = "Hobo Den"
	room_id = "sk_rdm092_hobohut"
	mappath = "_maps/RandomRooms/3x3/sk_rdm092_hobohut.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm093
	name = "Bubblegum Altar"
	room_id = "sk_rdm093_bubblegumaltar"
	mappath = "_maps/RandomRooms/3x3/sk_rdm093_bubblegumaltar.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm094
	name = "Canister Room"
	room_id = "sk_rdm094_canisterroom"
	mappath = "_maps/RandomRooms/3x5/sk_rdm094_canisterroom.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm095
	name = "Durand Wreck"
	room_id = "sk_rdm095_durandwreck"
	mappath = "_maps/RandomRooms/3x5/sk_rdm095_durandwreck.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm096
	name = "Computer Room"
	room_id = "sk_rdm096_comproom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm096_comproom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm097
	name = "Fire Room"
	room_id = "sk_rdm097_firemanroom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm097_firemanroom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm098
	name = "Graffiti room"
	room_id = "sk_rdm098_graffitiroom"
	mappath = "_maps/RandomRooms/10x10/sk_rdm098_graffitiroom.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm099
	name = "Broken Floor"
	room_id = "sk_rdm099_incompletefloor"
	mappath = "_maps/RandomRooms/5x3/sk_rdm099_incompletefloor.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm100
	name = "Meeting Room"
	room_id = "sk_rdm100_meetingroom"
	mappath = "_maps/RandomRooms/10x5/sk_rdm100_meetingroom.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm101
	name = "Small Breakroom"
	room_id = "sk_rdm101_minibreakroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm101_minibreakroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm102
	name = "Repair Bay"
	room_id = "sk_rdm102_podrepairbay"
	mappath = "_maps/RandomRooms/10x10/sk_rdm102_podrepairbay.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm103
	name = "'stroreroom'"
	room_id = "sk_rdm103_stroreroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm103_stroreroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm104
	name = "pill lottery"
	room_id = "sk_rdm104_pills"
	mappath = "_maps/RandomRooms/5x3/sk_rdm104_pills.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 1

/datum/map_template/random_room/sk_rdm105
	name = "biohazard exclusion zone"
	room_id = "sk_rdm105_phage"
	mappath = "_maps/RandomRooms/10x5/sk_rdm105_phage.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm106
	name = "Psychiatrist's Office"
	room_id = "sk_rdm106_sanitarium"
	mappath = "_maps/RandomRooms/10x10/sk_rdm106_sanitarium.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10

/datum/map_template/random_room/sk_rdm107
	name = "banan"
	room_id = "sk_rdm107_banana"
	mappath = "_maps/RandomRooms/3x3/sk_rdm107_banana.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm108
	name = "dirtycommies"
	room_id = "sk_rdm108_communism"
	mappath = "_maps/RandomRooms/3x3/sk_rdm108_communism.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm109
	name = "clown hardsuit"
	room_id = "sk_rdm109_hardclown"
	mappath = "_maps/RandomRooms/3x3/sk_rdm109_hardclown.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm110
	name = "lipid chamber"
	room_id = "sk_rdm110_lipidchamber"
	mappath = "_maps/RandomRooms/3x3/sk_rdm110_lipidchamber.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm111
	name = "bad"
	room_id = "sk_rdm111_naughtyroom"
	mappath = "_maps/RandomRooms/3x3/sk_rdm111_naughtyroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm112
	name = "geebillhowcomeyougetthreechromosomes"
	room_id = "sk_rdm112_chromosomes"
	mappath = "_maps/RandomRooms/3x5/sk_rdm112_chromosomes.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm113
	name = "organroom"
	room_id = "sk_rdm113_dissection"
	mappath = "_maps/RandomRooms/3x5/sk_rdm113_dissection.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm114
	name = "oxygen room"
	room_id = "sk_rdm114_emergencyoxy"
	mappath = "_maps/RandomRooms/3x5/sk_rdm114_emergencyoxy.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm115
	name = "crab"
	room_id = "sk_rdm115_krebs"
	mappath = "_maps/RandomRooms/3x5/sk_rdm115_krebs.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm116
	name = "ore"
	room_id = "sk_rdm116_oreboxes"
	mappath = "_maps/RandomRooms/3x5/sk_rdm116_oreboxes.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm117
	name = "ayylmoa"
	room_id = "sk_rdm117_chestburst"
	mappath = "_maps/RandomRooms/5x3/sk_rdm117_chestburst.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 3

/datum/map_template/random_room/sk_rdm118
	name = "gloveroom"
	room_id = "sk_rdm118_gloveroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm118_gloveroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 4//it has insuls and maybe a hostile spessman

/datum/map_template/random_room/sk_rdm119
	name = "parts"
	room_id = "sk_rdm119_spareparts"
	mappath = "_maps/RandomRooms/5x3/sk_rdm119_spareparts.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 8

/datum/map_template/random_room/sk_rdm120
	name = "cheeeeeese"
	room_id = "sk_rdm120_cheese"
	mappath = "_maps/RandomRooms/5x4/sk_rdm120_cheese.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 1

/datum/map_template/random_room/sk_rdm121
	name = "homk"
	room_id = "sk_rdm121_honkaccident"
	mappath = "_maps/RandomRooms/5x4/sk_rdm121_honkaccident.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 2


/datum/map_template/random_room/sk_rdm122
	name = "musicks"
	room_id = "sk_rdm122_musicroom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm122_musicroom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 8

/datum/map_template/random_room/sk_rdm123
	name = "musicks"
	room_id = "sk_rdm123_nanitechamber"
	mappath = "_maps/RandomRooms/5x4/sk_rdm123_nanitechamber.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5
	weight = 8

/datum/map_template/random_room/sk_rdm124
	name = "cryogenics"
	room_id = "sk_rdm124_oldcryoroom"
	mappath = "_maps/RandomRooms/5x4/sk_rdm124_oldcryoroom.dmm"
	centerspawner = FALSE
	template_height = 4
	template_width = 5

/datum/map_template/random_room/sk_rdm125
	name = "courtroom"
	room_id = "sk_rdm125_courtroom"
	mappath = "_maps/RandomRooms/10x5/sk_rdm125_courtroom.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 5

/datum/map_template/random_room/sk_rdm126
	name = "gas chamber"
	room_id = "sk_rdm126_gaschamber"
	mappath = "_maps/RandomRooms/10x5/sk_rdm126_gaschamber.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm127
	name = "ai core"
	room_id = "sk_rdm127_oldaichamber"
	mappath = "_maps/RandomRooms/10x5/sk_rdm127_oldaichamber.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm128
	name = "rad room"
	room_id = "sk_rdm128_radiationtherapy"
	mappath = "_maps/RandomRooms/10x5/sk_rdm128_radiationtherapy.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm129
	name = "Beach"
	room_id = "sk_rdm129_beach"
	mappath = "_maps/RandomRooms/10x10/sk_rdm129_beach.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm130 //several tricky xeno spawners, and four two-percent egg spawners. this spawning a live xeno egg will be somewhat rare
	name = "xenos"
	room_id = "sk_rdm130_benoegg"
	mappath = "_maps/RandomRooms/10x10/sk_rdm130_benoegg.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm131 //contains several cells with the same spawners psychologist has, each of which has a chance to spawn a doorbolt trap
	name = "prison"
	room_id = "sk_rdm131_confinementroom"
	mappath = "_maps/RandomRooms/10x10/sk_rdm131_confinementroom.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm132
	name = "conveyor room"
	room_id = "sk_rdm132_conveyorroom"
	mappath = "_maps/RandomRooms/10x10/sk_rdm132_conveyorroom.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 8

/datum/map_template/random_room/sk_rdm133
	name = "abandoned office"
	room_id = "sk_rdm133_oldoffice"
	mappath = "_maps/RandomRooms/10x10/sk_rdm133_oldoffice.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 6

/datum/map_template/random_room/sk_rdm134 //contains a few traps, which can cause darkness and spawn angry trees
	name = "snow forest"
	room_id = "sk_rdm134_snowforest"
	mappath = "_maps/RandomRooms/10x10/sk_rdm134_snowforest.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm137
	name = "Tiny psych ward"
	room_id = "sk_rdm137_tinyshrink"
	mappath = "_maps/RandomRooms/3x5/sk_rdm137_tinyshrink.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm138
	name = "Dressing Room"
	room_id = "sk_rdm138_magicroom"
	mappath = "_maps/RandomRooms/5x3/sk_rdm138_magicroom.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 5
	weight = 4

/datum/map_template/random_room/sk_rdm139
	name = "containment cell"
	room_id = "sk_rdm139_containmentcell"
	mappath = "_maps/RandomRooms/3x3/containmentcell.dmm"
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 3

/datum/map_template/random_room/sk_rdm140 //this is hilarious
	name = "confusing crossroads"
	room_id = "sk_rdm140_crossroads"
	mappath = "_maps/RandomRooms/3x5/sk_rdm140_crossroads.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm141
	name = "the place 6 sectors down"
	room_id = "sk_rdm141_6sectorsdown"
	mappath = "_maps/RandomRooms/10x10/sk_rdm141_6sectorsdown.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm142
	name = "old diner"
	room_id = "sk_rdm142_olddiner"
	mappath = "_maps/RandomRooms/10x10/sk_rdm142_olddiner.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4

/datum/map_template/random_room/sk_rdm143
	name = "gamer cave"
	room_id = "sk_rdm143_gamercave"
	mappath = "_maps/RandomRooms/10x10/sk_rdm143_gamercave.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm144 //has Stage Magician Spawner
	name = "small stage and bar"
	room_id = "sk_rdm144_smallmagician"
	mappath = "_maps/RandomRooms/10x10/sk_rdm144_smallmagician.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm145 //has tela anchor
	name = "lady tesla altar"
	room_id = "sk_rdm145_ladytesla_altar"
	mappath = "_maps/RandomRooms/10x10/sk_rdm145_ladytesla_altar.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 1 //rare

/datum/map_template/random_room/sk_rdm146
	name = "blastdoor interchange"
	room_id = "sk_rdm146_blastdoor_interchange"
	mappath = "_maps/RandomRooms/10x10/sk_rdm146_blastdoor_interchange.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 4 //common

/datum/map_template/random_room/sk_rdm147
	name = "advanced micro botany"
	room_id = "sk_rdm147_advbotany"
	mappath = "_maps/RandomRooms/10x10/sk_rdm147_advbotany.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm148
	name = "maintenance apiary"
	room_id = "sk_rdm148_botany_apiary"
	mappath = "_maps/RandomRooms/10x10/sk_rdm148_botany_apiary.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm149
	name = "space window with crates"
	room_id = "sk_rdm149_cratewindow"
	mappath = "_maps/RandomRooms/10x5/sk_rdm149_cratewindow.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 3

/datum/map_template/random_room/sk_rdm150
	name = "small medical lobby"
	room_id = "sk_rdm150_smallmedlobby"
	mappath = "_maps/RandomRooms/10x5/sk_rdm150_smallmedlobby.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 3 //common

/datum/map_template/random_room/sk_rdm151 //delicious
	name = "small medical lobby"
	room_id = "sk_rdm151_ratburger"
	mappath = "_maps/RandomRooms/10x5/sk_rdm151_ratburger.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 1 //rare

/datum/map_template/random_room/sk_rdm152
	name = "old genetics office"
	room_id = "sk_rdm152_geneticsoffice"
	mappath = "_maps/RandomRooms/10x5/sk_rdm152_geneticsoffice.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm153 //its a hobo den featuring Peter the pet frog. Includes a debtor spawn
	name = "peters room"
	room_id = "sk_rdm153_hobowithpeter"
	mappath = "_maps/RandomRooms/10x5/sk_rdm153_hobowithpeter.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 2

/datum/map_template/random_room/sk_rdm154 //rare, has a cleaver.
	name = "butchers den"
	room_id = "sk_rdm154_butchersden"
	mappath = "_maps/RandomRooms/10x5/sk_rdm154_butchersden.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm155
	name = "punji stick conveyor trap"
	room_id = "sk_rdm155_punjiconveyor"
	mappath = "_maps/RandomRooms/10x5/sk_rdm155_punjiconveyor.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 1

/datum/map_template/random_room/sk_rdm156
	name = "ancient interchange"
	room_id = "sk_rdm156_oldairlock_interchange"
	mappath = "_maps/RandomRooms/10x5/sk_rdm156_oldairlock_interchange.dmm"
	centerspawner = FALSE
	template_height = 5
	template_width = 10
	weight = 4
	stock = 2

/datum/map_template/random_room/sk_rdm157
	name = "Space Chess"
	room_id = "sk_rdm157_chess"
	mappath = "_maps/RandomRooms/10x10/sk_rdm157_chess.dmm"
	centerspawner = FALSE
	template_height = 10
	template_width = 10
