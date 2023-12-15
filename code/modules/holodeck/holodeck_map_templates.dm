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

/datum/map_template/holodeck/meeting
	name = "Holodeck - Meeting"
	template_id = "meeting"
	mappath = "_maps/holodeck/meeting.dmm"

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

//   ------------------------------
// -- SMALL HOLODECK TEMPLATES 7x7 --
//   ------------------------------

/datum/map_template/holodeck/small
	linked = /obj/machinery/computer/holodeck/small

/datum/map_template/holodeck/small/offline
	name = "Holodeck - Offline"
	template_id = "offline"
	mappath = "_maps/holodeck/small/offline.dmm"

/datum/map_template/holodeck/small/emptycourt
	name = "Holodeck - Empty Court"
	template_id = "emptycourt"
	mappath = "_maps/holodeck/small/emptycourt.dmm"

/datum/map_template/holodeck/small/dodgeball
	name = "Holodeck - Dodgeball Court"
	template_id = "dodgeball"
	mappath = "_maps/holodeck/small/dodgeball.dmm"

/datum/map_template/holodeck/small/basketball
	name = "Holodeck - Basketball Court"
	template_id = "basketball"
	mappath = "_maps/holodeck/small/basketball.dmm"

/datum/map_template/holodeck/small/thunderdome
	name = "Holodeck - Thunderdome Arena"
	template_id = "thunderdome"
	mappath = "_maps/holodeck/small/thunderdome.dmm"

/datum/map_template/holodeck/small/beach
	name = "Holodeck - Beach"
	template_id = "beach"
	mappath = "_maps/holodeck/small/beach.dmm"

/datum/map_template/holodeck/small/lounge
	name = "Holodeck - Lounge"
	template_id = "lounge"
	mappath = "_maps/holodeck/small/lounge.dmm"

/datum/map_template/holodeck/small/petpark
	name = "Holodeck - Pet Park"
	template_id = "petpark"
	mappath = "_maps/holodeck/small/petpark.dmm"

/datum/map_template/holodeck/small/firingrange
	name = "Holodeck - Firing Range"
	template_id = "firingrange"
	mappath = "_maps/holodeck/small/firingrange.dmm"

/datum/map_template/holodeck/small/anime_school
	name = "Holodeck - Anime School"
	template_id = "animeschool"
	mappath = "_maps/holodeck/small/animeschool.dmm"

/datum/map_template/holodeck/small/chapelcourt
	name = "Holodeck - Chapel Courtroom"
	template_id = "chapelcourt"
	mappath = "_maps/holodeck/small/chapelcourt.dmm"

/datum/map_template/holodeck/small/spacechess
	name = "Holodeck - Space Chess"
	template_id = "spacechess"
	mappath = "_maps/holodeck/small/spacechess.dmm"

/datum/map_template/holodeck/small/spacecheckers
	name = "Holodeck - Space Checkers"
	template_id = "spacecheckers"
	mappath = "_maps/holodeck/small/spacecheckers.dmm"

/datum/map_template/holodeck/small/kobayashi
	name = "Holodeck - Kobayashi Maru"
	template_id = "kobayashi"
	mappath = "_maps/holodeck/small/kobayashi.dmm"

/datum/map_template/holodeck/small/winterwonderland
	name = "Holodeck - Winter Wonderland"
	template_id = "winterwonderland"
	mappath = "_maps/holodeck/small/winterwonderland.dmm"

/datum/map_template/holodeck/small/photobooth
	name = "Holodeck - Photobooth"
	template_id = "photobooth"
	mappath = "_maps/holodeck/small/photobooth.dmm"

/datum/map_template/holodeck/small/skatepark
	name = "Holodeck - Skatepark"
	template_id = "skatepark"
	mappath = "_maps/holodeck/small/skatepark.dmm"

/datum/map_template/holodeck/small/teahouse
	name = "Holodeck - Japanese Tea House"
	template_id = "teahouse"
	mappath = "_maps/holodeck/small/teahouse.dmm"

/datum/map_template/holodeck/small/kitchen
	name = "Holodeck - Kitchen"
	template_id = "kitchen"
	mappath = "_maps/holodeck/small/kitchen.dmm"

/datum/map_template/holodeck/small/meeting
	name = "Holodeck - Meeting"
	template_id = "meeting"
	mappath = "_maps/holodeck/small/meeting.dmm"

//bad evil no good programs

/datum/map_template/holodeck/small/medicalsim
	name = "Holodeck - Emergency Medical"
	template_id = "medicalsim"
	mappath = "_maps/holodeck/small/medicalsim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/thunderdome1218
	name = "Holodeck - 1218 AD"
	template_id = "thunderdome1218"
	mappath = "_maps/holodeck/small/thunderdome1218.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/burntest
	name = "Holodeck - Atmospheric Burn Test"
	template_id = "burntest"
	mappath = "_maps/holodeck/small/burntest.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/wildlifesim
	name = "Holodeck - Wildlife Simulation"
	template_id = "wildlifesim"
	mappath = "_maps/holodeck/small/wildlifesim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/holdoutbunker
	name = "Holodeck - Holdout Bunker"
	template_id = "holdoutbunker"
	mappath = "_maps/holodeck/small/holdoutbunker.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/anthophillia
	name = "Holodeck - Anthophillia"
	template_id = "anthophillia"
	mappath = "_maps/holodeck/small/anthophillia.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/refuelingstation
	name = "Holodeck - Refueling Station"
	template_id = "refuelingstation"
	mappath = "_maps/holodeck/small/refuelingstation.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/asylum
	name = "Holodeck - Asylum"
	template_id = "asylum"
	mappath = "_maps/holodeck/asylum.dmm"
	restricted = TRUE

/datum/map_template/holodeck/small/clownworld
	name = "Holodeck - Clown World"
	template_id = "clownworld"
	mappath = "_maps/holodeck/clownworld.dmm"
	restricted = TRUE
