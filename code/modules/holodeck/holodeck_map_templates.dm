//   --------------------
// -- HOLODECK TEMPLATES --
//   --------------------

/datum/map_template/holodeck
	var/template_id = "id"
	var/restricted = FALSE
	var/datum/parsed_map/lastparsed

	should_place_on_top = FALSE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/obj/machinery/computer/holodeck/linked

/datum/map_template/holodeck/offline
	name = "Holodeck - Offline"
	template_id = "offline"
	mappath = "_maps/holodeck/offline.dmm"

/datum/map_template/holodeck/emptycourt
	name = "Holodeck - Empty Court"
	template_id = "emptycourt"
	mappath = "_maps/holodeck/emptycourt.dmm"

/datum/map_template/holodeck/dodgeball
	name = "Holodeck - Dodgeball Court"
	template_id = "dodgeball"
	mappath = "_maps/holodeck/dodgeball.dmm"

/datum/map_template/holodeck/basketball
	name = "Holodeck - Basketball Court"
	template_id = "basketball"
	mappath = "_maps/holodeck/basketball.dmm"

/datum/map_template/holodeck/thunderdome
	name = "Holodeck - Thunderdome Arena"
	template_id = "thunderdome"
	mappath = "_maps/holodeck/thunderdome.dmm"

/datum/map_template/holodeck/beach
	name = "Holodeck - Beach"
	template_id = "beach"
	mappath = "_maps/holodeck/beach.dmm"

/datum/map_template/holodeck/lounge
	name = "Holodeck - Lounge"
	template_id = "lounge"
	mappath = "_maps/holodeck/lounge.dmm"

/datum/map_template/holodeck/petpark
	name = "Holodeck - Pet Park"
	template_id = "petpark"
	mappath = "_maps/holodeck/petpark.dmm"

/datum/map_template/holodeck/firingrange
	name = "Holodeck - Firing Range"
	template_id = "firingrange"
	mappath = "_maps/holodeck/firingrange.dmm"

/datum/map_template/holodeck/anime_school
	name = "Holodeck - Anime School"
	template_id = "animeschool"
	mappath = "_maps/holodeck/animeschool.dmm"

/datum/map_template/holodeck/chapelcourt
	name = "Holodeck - Chapel Courtroom"
	template_id = "chapelcourt"
	mappath = "_maps/holodeck/chapelcourt.dmm"

/datum/map_template/holodeck/spacechess
	name = "Holodeck - Space Chess"
	template_id = "spacechess"
	mappath = "_maps/holodeck/spacechess.dmm"

/datum/map_template/holodeck/spacecheckers
	name = "Holodeck - Space Checkers"
	template_id = "spacecheckers"
	mappath = "_maps/holodeck/spacecheckers.dmm"

/datum/map_template/holodeck/kobayashi
	name = "Holodeck - Kobayashi Maru"
	template_id = "kobayashi"
	mappath = "_maps/holodeck/kobayashi.dmm"

/datum/map_template/holodeck/winterwonderland
	name = "Holodeck - Winter Wonderland"
	template_id = "winterwonderland"
	mappath = "_maps/holodeck/winterwonderland.dmm"

/datum/map_template/holodeck/photobooth
	name = "Holodeck - Photobooth"
	template_id = "photobooth"
	mappath = "_maps/holodeck/photobooth.dmm"

/datum/map_template/holodeck/skatepark
	name = "Holodeck - Skatepark"
	template_id = "skatepark"
	mappath = "_maps/holodeck/skatepark.dmm"

/datum/map_template/holodeck/teahouse
	name = "Holodeck - Japanese Tea House"
	template_id = "holodeck_teahouse"
	mappath = "_maps/templates/holodeck_teahouse.dmm"

/datum/map_template/holodeck/kitchen
	name = "Holodeck - Holo-Kitchen"
	template_id = "holodeck_kitchen"
	mappath = "_maps/templates/holodeck_kitchen.dmm"

//bad evil no good programs

/datum/map_template/holodeck/medicalsim
	name = "Holodeck - Emergency Medical"
	template_id = "medicalsim"
	mappath = "_maps/holodeck/medicalsim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/thunderdome1218
	name = "Holodeck - 1218 AD"
	template_id = "thunderdome1218"
	mappath = "_maps/holodeck/thunderdome1218.dmm"
	restricted = TRUE

/datum/map_template/holodeck/burntest
	name = "Holodeck - Atmospheric Burn Test"
	template_id = "burntest"
	mappath = "_maps/holodeck/burntest.dmm"
	restricted = TRUE

/datum/map_template/holodeck/wildlifesim
	name = "Holodeck - Wildlife Simulation"
	template_id = "wildlifesim"
	mappath = "_maps/holodeck/wildlifesim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/holdoutbunker
	name = "Holodeck - Holdout Bunker"
	template_id = "holdoutbunker"
	mappath = "_maps/holodeck/holdoutbunker.dmm"
	restricted = TRUE

/datum/map_template/holodeck/anthophillia
	name = "Holodeck - Anthophillia"
	template_id = "anthophillia"
	mappath = "_maps/holodeck/anthophillia.dmm"
	restricted = TRUE

/datum/map_template/holodeck/refuelingstation
	name = "Holodeck - Refueling Station"
	template_id = "refuelingstation"
	mappath = "_maps/holodeck/refuelingstation.dmm"
	restricted = TRUE

/datum/map_template/holodeck/asylum
	name = "Holodeck - Asylum"
	template_id = "holodeck_asylum"
	mappath = "_maps/templates/holodeck_asylum.dmm"
	restricted = TRUE

/datum/map_template/holodeck/clownworld
	name = "Holodeck - Clown World"
	template_id = "holodeck_clownworld"
	mappath = "_maps/templates/holodeck_clownworld.dmm"
	restricted = TRUE
