/*
 * All the different ruin part types.
 * Beacuse I couldn't figure out how to read every file in a directory
 * General rule for decent levels.
 *  - Peices that have only 1 connection should be of low weight
 *  - Hallway Ts and Xs should be of low weight if they don't have rooms attached
 *  - Straight hallways should have a middle weight
 *  - Interesting rooms with multiple connections should have a higher weight.
 */

/datum/map_template/ruin_part/hallwaycross
	file_name = "5x5_0_hallwaycross"
	weight = 1

/datum/map_template/ruin_part/hallwayvertical_eastwest_room
	file_name = "5x5_1_hallwayvertical_eastwest_room"
	weight = 1

/datum/map_template/ruin_part/room_dorm
	file_name = "5x5_4_room-dorm"
	weight = 3

/datum/map_template/ruin_part/room_janitor
	file_name = "5x5_4_room-janitor_closet"
	weight = 3

/datum/map_template/ruin_part/room_storage
	file_name = "5x5_4_room-storage"
	weight = 3

/datum/map_template/ruin_part/room_toilet
	file_name = "5x5_4_room-toilet"
	weight = 3

/datum/map_template/ruin_part/hallwayroom_east
	file_name = "5x5_5_hallwayroom_east"
	weight = 4

/datum/map_template/ruin_part/hallwayroom_west
	file_name = "5x5_5_hallwayroom_west"
	weight = 4

/datum/map_template/ruin_part/hallwayvertical_westroom
	file_name = "5x5_6_hallwayvertical_west_room"
	weight = 4

/datum/map_template/ruin_part/hallwayvertical_eastroom
	file_name = "5x5_6_hallwayvertical_east_room"
	weight = 4

/datum/map_template/ruin_part/hallway_t_east
	file_name = "5x5_8_hallwayt-east"
	weight = 2

/datum/map_template/ruin_part/hallway_t_north
	file_name = "5x5_8_hallwayt-north"
	weight = 2

/datum/map_template/ruin_part/hallway_t_south
	file_name = "5x5_8_hallwayt-south"
	weight = 2

/datum/map_template/ruin_part/hallway_t_west
	file_name = "5x5_8_hallwayt-west"
	weight = 2

/datum/map_template/ruin_part/hallway_end_east
	file_name = "5x5_14_hallway-end-east"
	weight = 2

/datum/map_template/ruin_part/hallway_end_north
	file_name = "5x5_14_hallway-end-north"
	weight = 2

/datum/map_template/ruin_part/hallway_end_south
	file_name = "5x5_14_hallway-end-south"
	weight = 2

/datum/map_template/ruin_part/hallway_end_west
	file_name = "5x5_14_hallway-end-west"
	weight = 2

/datum/map_template/ruin_part/hallway_horizontal
	file_name = "5x5_20_hallwayhorizontal"
	weight = 2

/datum/map_template/ruin_part/hallway_vertical
	file_name = "5x5_20_hallwayvertical"
	weight = 2

/datum/map_template/ruin_part/separation
	file_name = "9x5_3_seperation"
	weight = 6

/datum/map_template/ruin_part/checkpoint
	file_name = "9x9_checkpoint"
	weight = 5

/datum/map_template/ruin_part/corgarmoury
	file_name = "13x13_corgarmoury"
	weight = 20
	loot_room = TRUE

/datum/map_template/ruin_part/corgrobotics
	file_name = "13x13_corgrobotics"
	weight = 4

/datum/map_template/ruin_part/windowroom
	file_name = "5x9_windowroom"
	weight = 5

/datum/map_template/ruin_part/cargoroom
	file_name = "17x13_cargo"
	weight = 2

/datum/map_template/ruin_part/donutroom
	file_name = "13x13_donutroom"
	weight = 4

/datum/map_template/ruin_part/singularity
	file_name = "21x21_singularity"
	weight = 3
	max_occurances = 1

/datum/map_template/ruin_part/maintroom
	file_name = "9x5_maintroom"
	weight = 4

/datum/map_template/ruin_part/shuttledock
	file_name = "13x17_shuttledock"
	weight = 2

/datum/map_template/ruin_part/kitchen
	file_name = "9x13_kitchen"
	weight = 6

/datum/map_template/ruin_part/sleeproom
	file_name = "9x13_sleeproom"
	weight = 4

/datum/map_template/ruin_part/cryo
	file_name = "5x5_cryo"
	weight = 2

/datum/map_template/ruin_part/solars
	file_name = "21x19_solars"
	weight = 3
	max_occurances = 2

/datum/map_template/ruin_part/permbrig
	file_name = "13x17_permabrig"
	weight = 3
	max_occurances = 2

/datum/map_template/ruin_part/shotelroom
	file_name = "13x13_shotelroom"
	weight = 2

/datum/map_template/ruin_part/supermattercontainment
	file_name = "13x13_supermatter_containment"
	weight = 4
	max_occurances = 1

/datum/map_template/ruin_part/gateway
	file_name = "5x9_gateway"
	weight = 1

/datum/map_template/ruin_part/shower
	file_name = "5x5_shower"
	weight = 2

//its 13x13 lol
// !! Map file uses broken turbo-lift components !!
/*/datum/map_template/ruin_part/elevator
	file_name = "9x9_elevator"
	weight = 4*/

/datum/map_template/ruin_part/hallwaymaints
	file_name = "9x5_hallwaymaints"
	weight = 4

/datum/map_template/ruin_part/toxinroom
	file_name = "9x9_toxinstorage"
	weight = 2

/datum/map_template/ruin_part/josito
	file_name = "13x9_josito"
	weight = 3
	max_occurances = 1

/datum/map_template/ruin_part/pizzaguard
	file_name = "13x17_pizzaguardian"
	weight = 20
	loot_room = TRUE

/datum/map_template/ruin_part/hern
	file_name = "5x5_hern"
	weight = 2

/datum/map_template/ruin_part/hernsw
	file_name = "5x5_hernsw"
	weight = 1

/datum/map_template/ruin_part/hernw
	file_name = "5x5_hernw"
	weight = 1

/datum/map_template/ruin_part/hers
	file_name = "5x5_hers"
	weight = 2

/datum/map_template/ruin_part/hersw
	file_name = "5x5_hersw"
	weight = 1

/datum/map_template/ruin_part/hesrnw
	file_name = "5x5_hesrnw"
	weight = 1

/datum/map_template/ruin_part/hewrn
	file_name = "5x5_hewrn"
	weight = 1

/datum/map_template/ruin_part/hewrns
	file_name = "5x5_hewrns"
	weight = 1

/datum/map_template/ruin_part/hewrs
	file_name = "5x5_hewrs"
	weight = 1

/datum/map_template/ruin_part/hnersw
	file_name = "5x5_hnersw"
	weight = 1

/datum/map_template/ruin_part/hnesrw
	file_name = "5x5_hnesrw"
	weight = 1

/datum/map_template/ruin_part/hnewrs
	file_name = "5x5_hnewrs"
	weight = 1

/datum/map_template/ruin_part/hnresw
	file_name = "5x5_hnresw"
	weight = 1

/datum/map_template/ruin_part/hnswre
	file_name = "5x5_hnswre"
	weight = 1

/datum/map_template/ruin_part/hnwres
	file_name = "5x5_hnwres"
	weight = 1

/datum/map_template/ruin_part/hsrnew
	file_name = "5x5_hsrnew"
	weight = 1

/datum/map_template/ruin_part/hswrne
	file_name = "5x5_hswrne"
	weight = 1

/datum/map_template/ruin_part/hwres
	file_name = "5x5_hwres"
	weight = 1

/datum/map_template/ruin_part/hwrn
	file_name = "5x5_hwrn"
	weight = 2

/datum/map_template/ruin_part/hwrne
	file_name = "5x5_hwrne"
	weight = 1

/datum/map_template/ruin_part/hwrnes
	file_name = "5x5_hwrnes"
	weight = 1

/datum/map_template/ruin_part/hwrns
	file_name = "5x5_hwrns"
	weight = 1

/datum/map_template/ruin_part/hwrs
	file_name = "5x5_hwrs"
	weight = 2

/datum/map_template/ruin_part/roomcross
	file_name = "5x5_roomcross"
	weight = 1
