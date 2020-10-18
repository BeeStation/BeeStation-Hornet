// Floor painter

/obj/item/floor_painter
	name = "floor painter"
	icon = 'icons/obj/device.dmi'
	icon_state = "floor_painter"
	item_state = "electronic"

	var/painting_speed = 5
	var/floor_icon
	var/floor_state = "floor"
	var/floor_dir = SOUTH

	materials = list(/datum/material/iron=50, /datum/material/glass=50)

	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = SLOT_BELT

	var/static/list/allowed_states = list("arrival", "arrivalcorner", "bar", "barber", "black", "blackcorner", "blue", "bluecorner",
		"bluefull", "bluered", "blueyellow", "blueyellowfull", "bot", "brown", "browncorner", "brownfull", "browncornerold", "brownold",
		"cafeteria", "caution", "cautioncorner", "cautionfull", "chapel", "cmo", "dark", "delivery", "escape", "escapecorner", "floor",
		"freezerfloor", "green", "greenblue", "greenbluefull", "greencorner", "greenfull", "greenyellow", "greenyellowfull", "grimy",
		"loadingarea", "neutral", "neutralcorner", "neutralfull", "orange", "orangecorner", "orangefull", "plaque", "purple", "purplecorner",
		"purplefull", "red", "redblue", "redbluefull", "darkredblue", "darkredbluefull", "redcorner", "redfull", "redgreen", "redgreenfull",
		"darkredgreen", "darkredgreenfull", "redyellow", "redyellowfull", "darkredyellow", "darkredyellowfull", "showroomfloor", "stage_bleft",
		"stage_bottom", "stage_left", "vault", "warning", "warningcorner", "warnwhite", "warnwhitecorner", "white",
		"whiteblue", "whitebluecorner", "whitebluefull", "whitebot", "whitecorner", "whitedelivery", "whitegreen", "whitegreencorner", "whitegreenfull",
		"whitehall", "whitepurple", "whitepurplecorner", "whitepurplefull", "whitered", "whiteredcorner", "whiteredfull", "whiteyellow", "whiteyellowcorner",
		"whiteyellowfull", "yellow", "yellowcorner", "yellowcornersiding", "yellowfull", "yellowsiding", "darkpurple", "darkpurplecorners", "darkpurplefull",
		"darkred", "darkredcorners", "darkredfull", "darkblue", "darkbluecorners", "darkbluefull", "darkgreen", "darkgreencorners", "darkgreenfull", "darkyellow",
		"darkyellowcorners", "darkyellowfull", "darkbrown", "darkbrowncorners", "darkbrownfull", "stairs-old", "stairs", "stairs-l", "stairs-m", "stairs-r",
		"ameridiner_kitchen", "tile_full", "cargo_one_full", "kafel_full", "steel_monofloor", "steel_monotile", "monotile_dark", "steel_grid", "steel_ridged",
		"techmaint", "tiled", "tiled_light", "ridged", "grid", "monotile", "monotile_light", "techfloor_gray", "techfloor_grid", "pinkblack", "darkfull",
		"checker", "darkcorner", "blackwhite")

/obj/item/floor_painter/afterattack(var/atom/A, var/mob/user, proximity, params)
	if(!proximity)
		return

	var/turf/open/floor/plasteel/F = A
	if(!istype(F))
		to_chat(user, "<span class='warning'>\The [src] can only be used on station flooring.</span>")
		return

	F.icon_state = floor_state
	F.icon_regular_floor = floor_state
	F.dir = floor_dir

/obj/item/floor_painter/attack_self(var/mob/user)
	if(!user)
		return 0
	user.set_machine(src)
	interact(user)
	return 1

/obj/item/floor_painter/interact(mob/user as mob)
	if(!floor_icon)
		floor_icon = icon('icons/turf/floors.dmi', floor_state, floor_dir,painting_speed = 5)
	user << browse_rsc(floor_icon, "floor.png")
	var/dat = {"
		<center>
		<a href="?src=[REF(src)];cycleleft=1">&lt;-</a>
		<img style="-ms-interpolation-mode: nearest-neighbor;" src="floor.png" width=128 height=128 border=4>
		<a href="?src=[REF(src)];cycleright=1">-&gt;</a>
		</center>
		<a href="?src=[REF(src)];choose_state=1">Choose Style</a>
		<div class='statusDisplay'>Style: [floor_state]</div>
		<a href="?src=[REF(src)];choose_dir=1">Choose Direction</a>
		<div class='statusDisplay'>Direction: [dir2text(floor_dir)]</div>
	"}

	var/datum/browser/popup = new(user, "floor_painter", name, 225, 300)
	popup.set_content(dat)
	popup.open()

/obj/item/floor_painter/Topic(href, href_list)
	if(..())
		return

	if(href_list["choose_state"])
		var/state = input("Please select a style", "[src]") as null|anything in allowed_states
		if(state)
			floor_state = state
			floor_dir = SOUTH // Reset dir, because some icon_states might not have that dir.
	if(href_list["choose_dir"])
		var/seldir = input("Please select a direction", "[src]") as null|anything in list("north", "south", "east", "west", "northeast", "northwest", "southeast", "southwest")
		if(seldir)
			floor_dir = text2dir(seldir)
	if(href_list["cycleleft"])
		var/index = allowed_states.Find(floor_state)
		index--
		if(index < 1)
			index = allowed_states.len
		floor_state = allowed_states[index]
		floor_dir = SOUTH
	if(href_list["cycleright"])
		var/index = allowed_states.Find(floor_state)
		index++
		if(index > allowed_states.len)
			index = 1
		floor_state = allowed_states[index]
		floor_dir = SOUTH

	floor_icon = icon('icons/turf/floors.dmi', floor_state, floor_dir)
	if(usr)
		attack_self(usr)