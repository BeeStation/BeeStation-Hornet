/datum/slimecolor
	var/color // visual color of slime, sprite is grey by default
	var/obj/item/slime_extract/extract_color // color of extract

	var/max_hunger = 1000 // default max hunger, can be changed

	var/max_aggression = 250 // default max aggression, can be changed
	var/list/aggression_rate = list(-5,-2,-1,0,1,2) // aggression rates for starving, very hungry, hungry, sated, full, and stuffed respectively, can be changed

	var/regen = 1 // how much health the node/core regains every metabolize()

	var/tier // what tier the slime is, should determine how strong it is. not sure if this will be useful
	var/list/possible_mutations // list of mutations that this color can have, should be just itself if it can't mutate

	var/buckle_timer = 30 // How long it takes a (non bio-protected) mob to get buckled the slime's creep in deciseconds
	var/eat_damage = 10 // How much damage this slime deals to a buckled mob

/datum/slimecolor/proc/effect(var/mob/living/M, var/obj/structure/xenoblob/creep/C) // Override this for all colors
	M.visible_message("<span class='notice'>Something went wrong with [C], tell coders</span>")

/datum/slimecolor/grey // grey is very weak, T1 slimes will have default stuff
	extract_color = /obj/item/slime_extract/grey

	max_aggression = 100
	aggression_rate = list(-3,-1,-0.5,0,1,2)

	tier = 0
	possible_mutations = list()

	buckle_timer = 45
	eat_damage = 5

/datum/slimecolor/grey/effect(M, C) // No effect
	return

/*
"orange" "#FFA500"
"purple" "#B19CD9"
"blue" "#ADD8E6"
"metal" "#7E7E7E"
"yellow" "#FFFF00"
"dark purple" "#551A8B"
 "dark blue" "#0000FF"
"silver" "#D3D3D3"
"bluespace" "#32CD32"
"sepia" "#704214"
"cerulean" "#2956B2"
"pyrite" "#FAFAD2"
"red" "#FF0000"
"green" "#00FF00"
"pink" "#FF69B4"
"gold" "#FFD700"
"oil" "#505050"
"black" "#000000"
"light pink" "#FFB6C1"
"adamantine" "#008B8B"
*/
