//caravan ambush

/obj/item/wrench/caravan
	color = COLOR_RED
	desc = "A prototype of a new wrench design, allegedly the red color scheme makes it go faster."
	name = "experimental wrench"
	toolspeed = 0.3

/obj/item/screwdriver/caravan
	color = COLOR_RED
	desc = "A prototype of a new screwdriver design, allegedly the red color scheme makes it go faster."
	name = "experimental screwdriver"
	toolspeed = 0.3
	random_color = FALSE

/obj/item/wirecutters/caravan
	color = COLOR_RED
	desc = "A prototype of a new wirecutter design, allegedly the red color scheme makes it go faster."
	name = "experimental wirecutters"
	toolspeed = 0.3
	random_color = FALSE

/obj/item/crowbar/red/caravan
	color = COLOR_RED
	desc = "A prototype of a new crowbar design, allegedly the red color scheme makes it go faster."
	name = "experimental crowbar"
	toolspeed = 0.3

/obj/machinery/computer/shuttle_flight/caravan

/obj/item/circuitboard/computer/shuttle/caravan
	build_path = /obj/machinery/computer/shuttle_flight/caravan

/obj/item/circuitboard/computer/shuttle/caravan/trade1
	build_path = /obj/machinery/computer/shuttle_flight/caravan/trade1

/obj/item/circuitboard/computer/shuttle/caravan/pirate
	build_path = /obj/machinery/computer/shuttle_flight/caravan/pirate

/obj/item/circuitboard/computer/shuttle/caravan/syndicate1
	build_path = /obj/machinery/computer/shuttle_flight/caravan/syndicate1

/obj/item/circuitboard/computer/shuttle/caravan/syndicate2
	build_path = /obj/machinery/computer/shuttle_flight/caravan/syndicate2

/obj/item/circuitboard/computer/shuttle/caravan/syndicate3
	build_path = /obj/machinery/computer/shuttle_flight/caravan/syndicate3

/obj/machinery/computer/shuttle_flight/caravan/trade1
	name = "Small Freighter Shuttle Console"
	desc = "Used to control the Small Freighter."
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/trade1
	shuttleId = "caravantrade1"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;caravantrade1_custom;caravantrade1_ambush"

/obj/machinery/computer/shuttle_flight/caravan/pirate
	name = "Pirate Cutter Shuttle Console"
	desc = "Used to control the Pirate Cutter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/pirate
	shuttleId = "caravanpirate"
	possible_destinations = "caravanpirate_custom;caravanpirate_ambush"

/obj/machinery/computer/shuttle_flight/caravan/syndicate1
	name = "Syndicate Fighter Shuttle Console"
	desc = "Used to control the Syndicate Fighter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_SYNDICATE)
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/syndicate1
	shuttleId = "caravansyndicate1"
	possible_destinations = "caravansyndicate1_custom;caravansyndicate1_ambush;caravansyndicate1_listeningpost"

/obj/machinery/computer/shuttle_flight/caravan/syndicate2
	name = "Syndicate Fighter Shuttle Console"
	desc = "Used to control the Syndicate Fighter."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_SYNDICATE)
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/syndicate2
	shuttleId = "caravansyndicate2"
	possible_destinations = "caravansyndicate2_custom;caravansyndicate2_ambush;caravansyndicate1_listeningpost"

/obj/machinery/computer/shuttle_flight/caravan/syndicate3
	name = "Syndicate Drop Ship Console"
	desc = "Used to control the Syndicate Drop Ship."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_SYNDICATE)
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/syndicate3
	shuttleId = "caravansyndicate3"
	possible_destinations = "caravansyndicate3_custom;caravansyndicate3_ambush;caravansyndicate3_listeningpost"
