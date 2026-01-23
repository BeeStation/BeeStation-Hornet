/**
 * TILE STACKS
 *
 * Allows us to place a turf on a plating.
 */
/obj/item/stack/tile
	name = "broken tile"
	singular_name = "broken tile"
	desc = "A broken tile. This should not exist."
	lefthand_file = 'icons/mob/inhands/misc/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/tiles_righthand.dmi'
	icon = 'icons/obj/tiles.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	novariants = TRUE
	material_flags = MATERIAL_EFFECTS
	/// What type of turf does this tile produce.
	var/turf_type = null
	/// What dir will the turf have?
	var/turf_dir = SOUTH
	/// Cached associative lazy list to hold the radial options for tile reskinning. See tile_reskinning.dm for more information. Pattern: list[type] -> image
	var/list/tile_reskin_types
	/// Cached associative lazy list to hold the radial options for tile dirs. See tile_reskinning.dm for more information.
	var/list/tile_rotate_dirs
	/// Allows us to replace the plating we are attacking if our baseturfs are the same.
	var/replace_plating = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/tile)

/obj/item/stack/tile/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little
	if(tile_reskin_types)
		tile_reskin_types = tile_reskin_list(tile_reskin_types)
	if(tile_rotate_dirs)
		var/list/values = list()
		for(var/set_dir in tile_rotate_dirs)
			values += dir2text(set_dir)
		tile_rotate_dirs = tile_dir_list(values, turf_type)

/obj/item/stack/tile/examine(mob/user)
	. = ..()
	if(tile_reskin_types || tile_rotate_dirs)
		. += span_notice("Use while in your hand to change what type of [src] you want.")
	if(throwforce && !is_cyborg) //do not want to divide by zero or show the message to borgs who can't throw
		var/verb
		switch(CEILING(MAX_LIVING_HEALTH / throwforce, 1)) //throws to crit a human
			if(1 to 3)
				verb = "superb"
			if(4 to 6)
				verb = "great"
			if(7 to 9)
				verb = "good"
			if(10 to 12)
				verb = "fairly decent"
			if(13 to 15)
				verb = "mediocre"
		if(!verb)
			return
		. += span_notice("Those could work as a [verb] throwing weapon.")

/**
 * Place our tile on a plating, or replace it.
 *
 * Arguments:
 * * target_plating - Instance of the plating we want to place on. Replaced during sucessful executions.
 * * user - The mob doing the placing.
 */
/obj/item/stack/tile/proc/place_tile(turf/open/floor/plating/target_plating, mob/user)
	var/turf/placed_turf_path = turf_type
	if(!ispath(placed_turf_path))
		return
	if(!istype(target_plating))
		return

	if(!replace_plating)
		if(!use(1))
			return
		target_plating = target_plating.PlaceOnTop(placed_turf_path, flags = CHANGETURF_INHERIT_AIR)
		target_plating.setDir(turf_dir)
		playsound(target_plating, 'sound/weapons/genhit.ogg', 50, TRUE)
		return target_plating // Most executions should end here.

	// If we and the target tile share the same initial baseturf and they consent, replace em.
	if(!target_plating.allow_replacement || initial(target_plating.baseturfs) != initial(placed_turf_path.baseturfs))
		to_chat(user, span_notice("You cannot place this tile here directly!"))
		return
	to_chat(user, span_notice("You begin replacing the floor with the tile..."))
	if(!do_after(user, 3 SECONDS, target_plating))
		return
	if(!istype(target_plating))
		return
	if(!use(1))
		return

	target_plating = target_plating.ChangeTurf(placed_turf_path, target_plating.baseturfs, CHANGETURF_INHERIT_AIR)
	target_plating.setDir(turf_dir)
	playsound(target_plating, 'sound/weapons/genhit.ogg', 50, TRUE)
	return target_plating

//Grass
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they use on space golf courses."
	icon_state = "tile_grass"
	inhand_icon_state = "tile-grass"
	turf_type = /turf/open/floor/grass
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/grass

/obj/item/stack/tile/grass/attackby(obj/item/W, mob/user, params)
	if((W.tool_behaviour == TOOL_SHOVEL) && params)
		to_chat(user, span_notice("You start digging up [src]."))
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		if(do_after(user, 2 * get_amount(), target = src))
			new /obj/item/stack/ore/glass(get_turf(src), 2 * get_amount())
			user.visible_message(span_notice("[user] digs up [src]."), span_notice("You uproot [src]."))
			playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
			qdel(src)
	else
		return ..()

//Fairygrass
/obj/item/stack/tile/fairygrass
	name = "fairygrass tile"
	singular_name = "fairygrass floor tile"
	desc = "A patch of odd, glowing blue grass."
	icon_state = "tile_fairygrass"
	inhand_icon_state = "tile-fairygrass"
	turf_type = /turf/open/floor/grass/fairy
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fairygrass
	color = "#33CCFF"

/obj/item/stack/tile/fairygrass/white
	name = "white fairygrass tile"
	singular_name = "white fairygrass floor tile"
	desc = "A patch of odd, glowing white grass."
	turf_type = /turf/open/floor/grass/fairy/white
	merge_type = /obj/item/stack/tile/fairygrass/white
	color = "#FFFFFF"

/obj/item/stack/tile/fairygrass/red
	name = "red fairygrass tile"
	singular_name = "red fairygrass floor tile"
	desc = "A patch of odd, glowing red grass."
	turf_type = /turf/open/floor/grass/fairy/red
	merge_type = /obj/item/stack/tile/fairygrass/red
	color = "#FF3333"

/obj/item/stack/tile/fairygrass/orange
	name = "orange fairygrass tile"
	singular_name = "orange fairygrass floor tile"
	desc = "A patch of odd, glowing orange grass."
	turf_type = /turf/open/floor/grass/fairy/orange
	merge_type = /obj/item/stack/tile/fairygrass/orange
	color = "#FFA500"

/obj/item/stack/tile/fairygrass/yellow
	name = "yellow fairygrass tile"
	singular_name = "yellow fairygrass floor tile"
	desc = "A patch of odd, glowing yellow grass."
	turf_type = /turf/open/floor/grass/fairy/yellow
	merge_type = /obj/item/stack/tile/fairygrass/blue
	color = "#FFFF66"

/obj/item/stack/tile/fairygrass/green
	name = "green fairygrass tile"
	singular_name = "green fairygrass floor tile"
	desc = "A patch of odd, glowing green grass."
	turf_type = /turf/open/floor/grass/fairy/green
	merge_type = /obj/item/stack/tile/fairygrass/blue
	color = "#99FF99"

/obj/item/stack/tile/fairygrass/blue
	name = "blue fairygrass tile"
	singular_name = "blue fairygrass floor tile"
	desc = "A patch of odd, glowing blue grass."
	turf_type = /turf/open/floor/grass/fairy/blue
	merge_type = /obj/item/stack/tile/fairygrass/blue

/obj/item/stack/tile/fairygrass/purple
	name = "purple fairygrass tile"
	singular_name = "purple fairygrass floor tile"
	desc = "A patch of odd, glowing purple grass."
	turf_type = /turf/open/floor/grass/fairy/purple
	merge_type = /obj/item/stack/tile/fairygrass/purple
	color = "#D966FF"

/obj/item/stack/tile/fairygrass/pink
	name = "pink fairygrass tile"
	singular_name = "pink fairygrass floor tile"
	desc = "A patch of odd, glowing pink grass."
	turf_type = /turf/open/floor/grass/fairy/pink
	merge_type = /obj/item/stack/tile/fairygrass/pink
	color = "#FFB3DA"

/obj/item/stack/tile/fairygrass/dark
	name = "dark fairygrass tile"
	singular_name = "dark fairygrass floor tile"
	desc = "A patch of odd, light consuming grass."
	turf_type = /turf/open/floor/grass/fairy/dark
	merge_type = /obj/item/stack/tile/fairygrass/dark
	color = "#410096"

//Wood
/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "An easy to fit wood floor tile."
	icon_state = "tile-wood"
	inhand_icon_state = "tile-wood"
	turf_type = /turf/open/floor/wood
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/wood

//Bamboo
/obj/item/stack/tile/bamboo
	name = "bamboo mat pieces"
	singular_name = "bamboo mat piece"
	desc = "A piece of a bamboo mat with a decorative trim."
	icon_state = "tile-bamboo"
	inhand_icon_state = "tile-bamboo"
	turf_type = /turf/open/floor/bamboo
	merge_type = /obj/item/stack/tile/bamboo
	resistance_flags = FLAMMABLE

//Basalt
/obj/item/stack/tile/basalt
	name = "basalt tile"
	singular_name = "basalt floor tile"
	desc = "Artificially made ashy soil themed on a hostile environment."
	icon_state = "tile_basalt"
	inhand_icon_state = "tile-basalt"
	turf_type = /turf/open/floor/grass/fakebasalt
	merge_type = /obj/item/stack/tile/basalt

//Carpets
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon_state = "tile-carpet"
	inhand_icon_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet
	resistance_flags = FLAMMABLE
	tableVariant = /obj/structure/table/wood/fancy
	merge_type = /obj/item/stack/tile/carpet
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet,
		/obj/item/stack/tile/carpet/symbol,
		/obj/item/stack/tile/carpet/star,
	)

/obj/item/stack/tile/carpet/symbol
	name = "symbol carpet"
	singular_name = "symbol carpet tile"
	icon_state = "tile-carpet-symbol"
	desc = "A piece of carpet. This one has a symbol on it."
	turf_type = /turf/open/floor/carpet/lone
	merge_type = /obj/item/stack/tile/carpet/symbol
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST, SOUTHEAST)

/obj/item/stack/tile/carpet/star
	name = "star carpet"
	singular_name = "star carpet tile"
	icon_state = "tile-carpet-star"
	desc = "A piece of carpet. This one has a star on it."
	turf_type = /turf/open/floor/carpet/lone/star
	merge_type = /obj/item/stack/tile/carpet/star

/obj/item/stack/tile/carpet/black
	name = "black carpet"
	icon_state = "tile-carpet-black"
	inhand_icon_state = "tile-carpet-black"
	merge_type = /obj/item/stack/tile/carpet/black
	turf_type = /turf/open/floor/carpet/black
	tableVariant = /obj/structure/table/wood/fancy/black

/obj/item/stack/tile/carpet/blue
	name = "blue carpet"
	icon_state = "tile-carpet-blue"
	inhand_icon_state = "tile-carpet-blue"
	merge_type = /obj/item/stack/tile/carpet/blue
	turf_type = /turf/open/floor/carpet/blue
	tableVariant = /obj/structure/table/wood/fancy/blue

/obj/item/stack/tile/carpet/blue/thirtytwo
	amount = 32

/obj/item/stack/tile/carpet/cyan
	name = "cyan carpet"
	icon_state = "tile-carpet-cyan"
	inhand_icon_state = "tile-carpet-cyan"
	merge_type = /obj/item/stack/tile/carpet/cyan
	turf_type = /turf/open/floor/carpet/cyan
	tableVariant = /obj/structure/table/wood/fancy/cyan

/obj/item/stack/tile/carpet/cyan/thirtytwo
	amount = 32

/obj/item/stack/tile/carpet/green
	name = "green carpet"
	icon_state = "tile-carpet-green"
	inhand_icon_state = "tile-carpet-green"
	merge_type = /obj/item/stack/tile/carpet/green
	turf_type = /turf/open/floor/carpet/green
	tableVariant = /obj/structure/table/wood/fancy/green

/obj/item/stack/tile/carpet/orange
	name = "orange carpet"
	icon_state = "tile-carpet-orange"
	inhand_icon_state = "tile-carpet-orange"
	merge_type = /obj/item/stack/tile/carpet/orange
	turf_type = /turf/open/floor/carpet/orange
	tableVariant = /obj/structure/table/wood/fancy/orange

/obj/item/stack/tile/carpet/purple
	name = "purple carpet"
	icon_state = "tile-carpet-purple"
	inhand_icon_state = "tile-carpet-purple"
	merge_type = /obj/item/stack/tile/carpet/purple
	turf_type = /turf/open/floor/carpet/purple
	tableVariant = /obj/structure/table/wood/fancy/purple

/obj/item/stack/tile/carpet/red
	name = "red carpet"
	icon_state = "tile-carpet-red"
	inhand_icon_state = "tile-carpet-red"
	merge_type = /obj/item/stack/tile/carpet/red
	turf_type = /turf/open/floor/carpet/red
	tableVariant = /obj/structure/table/wood/fancy/red

/obj/item/stack/tile/carpet/olive
	name = "olive carpet"
	icon_state = "tile-carpet-olive"
	inhand_icon_state = "tile-carpet-olive"
	merge_type = /obj/item/stack/tile/carpet/olive
	turf_type = /turf/open/floor/carpet/olive
	tableVariant = /obj/structure/table/wood/fancy/green

/obj/item/stack/tile/carpet/royalblack
	name = "royal black carpet"
	icon_state = "tile-carpet-royalblack"
	inhand_icon_state = "tile-carpet-royalblack"
	merge_type = /obj/item/stack/tile/carpet/royalblack
	turf_type = /turf/open/floor/carpet/royalblack
	tableVariant = /obj/structure/table/wood/fancy/royalblack

/obj/item/stack/tile/carpet/royalblue
	name = "royal blue carpet"
	icon_state = "tile-carpet-royalblue"
	inhand_icon_state = "tile-carpet-royalblue"
	merge_type = /obj/item/stack/tile/carpet/royalblue
	turf_type = /turf/open/floor/carpet/royalblue
	tableVariant = /obj/structure/table/wood/fancy/royalblue

/obj/item/stack/tile/carpet/grimy
	name = "grimy carpet"
	singular_name = "grimy carpet floor tile"
	desc = "A piece of carpet that feels more like floor tiles, sure it feels hard to the touch for being carpet..."
	icon_state = "tile-carpet-grimy"
	inhand_icon_state = "tile-carpet-grimy"
	merge_type = /obj/item/stack/tile/carpet/grimy
	turf_type = /turf/open/floor/carpet/grimy

/obj/item/stack/tile/material/place_tile(turf/open/target_plating, mob/user)
	. = ..()
	var/turf/open/floor/material/floor = .
	floor?.set_custom_materials(mats_per_unit)

/obj/item/stack/tile/eighties
	name = "retro tile"
	singular_name = "retro floor tile"
	desc = "A stack of floor tiles that remind you of simpler times.."
	icon_state = "tile_eighties"
	merge_type = /obj/item/stack/tile/eighties
	turf_type = /turf/open/floor/eighties

/obj/item/stack/tile/carpet/fifty
	amount = 50

/obj/item/stack/tile/carpet/black/fifty
	amount = 50

/obj/item/stack/tile/carpet/blue/fifty
	amount = 50

/obj/item/stack/tile/carpet/cyan/fifty
	amount = 50

/obj/item/stack/tile/carpet/green/fifty
	amount = 50

/obj/item/stack/tile/carpet/orange/fifty
	amount = 50

/obj/item/stack/tile/carpet/purple/fifty
	amount = 50

/obj/item/stack/tile/carpet/red/fifty
	amount = 50

/obj/item/stack/tile/carpet/olive/fifty
	amount = 50

/obj/item/stack/tile/carpet/royalblack/fifty
	amount = 50

/obj/item/stack/tile/carpet/royalblue/fifty
	amount = 50

/obj/item/stack/tile/carpet/grimy/fifty
	amount = 50

/obj/item/stack/tile/eighties/fifty
	amount = 50

/obj/item/stack/tile/eighties/loaded
	amount = 30

/obj/item/stack/tile/fakespace
	name = "astral carpet"
	singular_name = "astral carpet"
	desc = "A piece of carpet with a convincing star pattern."
	icon_state = "tile_space"
	inhand_icon_state = "tile-space"
	turf_type = /turf/open/floor/fakespace
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakespace

/obj/item/stack/tile/fakespace/loaded
	amount = 30

/obj/item/stack/tile/fakepit
	name = "fake pits"
	singular_name = "fake pit"
	desc = "A piece of carpet with a forced perspective illusion of a pit. No way this could fool anyone!"
	icon_state = "tile_pit"
	inhand_icon_state = "tile-basalt"
	turf_type = /turf/open/floor/fakepit
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakepit

/obj/item/stack/tile/fakepit/loaded
	amount = 30

//High-traction
/obj/item/stack/tile/noslip
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip"
	inhand_icon_state = "tile-noslip"
	turf_type = /turf/open/floor/noslip
	merge_type = /obj/item/stack/tile/noslip

/obj/item/stack/tile/noslip/standard
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip_standard"
	turf_type = /turf/open/floor/noslip/standard
	merge_type = /obj/item/stack/tile/noslip/standard

/obj/item/stack/tile/noslip/white
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip_white"
	turf_type = /turf/open/floor/noslip/white
	merge_type = /obj/item/stack/tile/noslip/white

/obj/item/stack/tile/noslip/blue
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip_blue"
	turf_type = /turf/open/floor/noslip/blue
	merge_type = /obj/item/stack/tile/noslip/blue

/obj/item/stack/tile/noslip/darkblue
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip_darkblue"
	turf_type = /turf/open/floor/noslip/darkblue
	merge_type = /obj/item/stack/tile/noslip/darkblue

/obj/item/stack/tile/noslip/dark
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip_dark"
	turf_type = /turf/open/floor/noslip/dark
	merge_type = /obj/item/stack/tile/noslip/dark

/obj/item/stack/tile/noslip/vaporwave
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip_pinkblack"
	turf_type = /turf/open/floor/noslip/vaporwave
	merge_type = /obj/item/stack/tile/noslip/vaporwave

/obj/item/stack/tile/noslip/thirty
	amount = 30

//Circuit
/obj/item/stack/tile/circuit
	name = "blue circuit tile"
	singular_name = "blue circuit tile"
	desc = "A blue circuit tile."
	icon_state = "tile_bcircuit"
	inhand_icon_state = "tile-bcircuit"
	turf_type = /turf/open/floor/circuit
	merge_type = /obj/item/stack/tile/circuit

/obj/item/stack/tile/circuit/green
	name = "green circuit tile"
	singular_name = "green circuit tile"
	desc = "A green circuit tile."
	icon_state = "tile_gcircuit"
	inhand_icon_state = "tile-gcircuit"
	turf_type = /turf/open/floor/circuit/green
	merge_type = /obj/item/stack/tile/circuit/green

/obj/item/stack/tile/circuit/green/anim
	turf_type = /turf/open/floor/circuit/green/anim
	merge_type = /obj/item/stack/tile/circuit/green/anim

/obj/item/stack/tile/circuit/red
	name = "red circuit tile"
	singular_name = "red circuit tile"
	desc = "A red circuit tile."
	icon_state = "tile_rcircuit"
	inhand_icon_state = "tile-rcircuit"
	turf_type = /turf/open/floor/circuit/red
	merge_type = /obj/item/stack/tile/circuit/red

/obj/item/stack/tile/circuit/red/anim
	turf_type = /turf/open/floor/circuit/red/anim
	merge_type = /obj/item/stack/tile/circuit/red/anim

//Pod floor
/obj/item/stack/tile/pod
	name = "pod floor tile"
	singular_name = "pod floor tile"
	desc = "A grooved floor tile."
	icon_state = "tile_pod"
	inhand_icon_state = "tile-pod"
	turf_type = /turf/open/floor/pod
	merge_type = /obj/item/stack/tile/pod
	tile_reskin_types = list(
		/obj/item/stack/tile/pod,
		/obj/item/stack/tile/pod/light,
		/obj/item/stack/tile/pod/dark,
		)

/obj/item/stack/tile/pod/light
	name = "light pod floor tile"
	singular_name = "light pod floor tile"
	desc = "A lightly colored grooved floor tile."
	icon_state = "tile_podlight"
	turf_type = /turf/open/floor/pod/light
	merge_type = /obj/item/stack/tile/pod/light

/obj/item/stack/tile/pod/dark
	name = "dark pod floor tile"
	singular_name = "dark pod floor tile"
	desc = "A darkly colored grooved floor tile."
	icon_state = "tile_poddark"
	turf_type = /turf/open/floor/pod/dark
	merge_type = /obj/item/stack/tile/pod/dark

//Monotiles

/obj/item/stack/tile/mono
	name = "steel mono tile"
	singular_name = "steel mono tile"
	desc = "A really big steel tile compared to the standard station tiles."
	icon_state = "tile"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/monotile
	merge_type = /obj/item/stack/tile/mono

/obj/item/stack/tile/mono/dark
	name = "dark mono tile"
	singular_name = "dark mono tile"
	desc = "A really big (dark) steel tile compared to the standard station tiles."
	icon_state = "tile"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/monotile/dark
	merge_type = /obj/item/stack/tile/mono/dark

/obj/item/stack/tile/mono/light
	name = "light mono tile"
	singular_name = "light mono tile"
	desc = "A really big (shiny) steel tile compared to the standard station tiles."
	icon_state = "tile"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/monotile/light
	merge_type = /obj/item/stack/tile/mono/light

//Bay grids
/obj/item/stack/tile/grid
	name = "grey grid tile"
	singular_name = "grey grid tile"
	desc = "A gridded version of the standard station tiles."
	icon_state = "tile_grid"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/iron/grid
	merge_type = /obj/item/stack/tile/grid

/obj/item/stack/tile/ridge
	name = "grey ridge tile"
	singular_name = "grey ridge tile"
	desc = "A ridged version of the standard station tiles."
	icon_state = "tile_ridged"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/iron/ridged
	merge_type = /obj/item/stack/tile/ridge

//Techtiles
/obj/item/stack/tile/techgrey
	name = "grey techfloor tile"
	singular_name = "grey techfloor tile"
	desc = "A fancy tile usually found in secure areas and engineering bays."
	icon_state = "tile_tech_grey"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/iron/tech
	merge_type = /obj/item/stack/tile/techgrey
/obj/item/stack/tile/techgrid
	name = "grid techfloor tile"
	singular_name = "grid techfloor tile"
	desc = "A fancy tile usually found in secure areas and engineering bays, this one has a grid pattern."
	icon_state = "tile_tech_grid"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/iron/tech/grid
	merge_type = /obj/item/stack/tile/techgrid

/obj/item/stack/tile/techmaint
	name = "dark techfloor tile"
	singular_name = "dark techfloor tile"
	desc = "A fancy tile usually found in secure areas and engineering bays, this one is dark."
	icon_state = "tile_tech_maint"
	custom_materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/iron/techmaint
	merge_type = /obj/item/stack/tile/techmaint

// Glass floors
/obj/item/stack/tile/glass
	name = "glass floor"
	singular_name = "glass floor tile"
	desc = "Glass window floors, to let you see... Whatever that is down there."
	icon_state = "tile_glass"
	turf_type = /turf/open/floor/glass
	inhand_icon_state = "tile-glass"
	merge_type = /obj/item/stack/tile/glass
	mats_per_unit = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT * 0.25) // 4 tiles per sheet
	replace_plating = TRUE

/obj/item/stack/tile/glass/sixty
	amount = 60

/obj/item/stack/tile/rglass
	name = "reinforced glass floor"
	singular_name = "reinforced glass floor tile"
	desc = "Reinforced glass window floors. These bad boys are 50% stronger than their predecessors!"
	icon_state = "tile_rglass"
	inhand_icon_state = "tile-rglass"
	turf_type = /turf/open/floor/glass/reinforced
	merge_type = /obj/item/stack/tile/rglass
	mats_per_unit = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT * 0.125, /datum/material/glass=MINERAL_MATERIAL_AMOUNT * 0.25) // 4 tiles per sheet
	replace_plating = TRUE

/obj/item/stack/tile/rglass/sixty
	amount = 60

/obj/item/stack/tile/dock
	name = "dock tile"
	singular_name = "dock tile"
	desc = "A bulky chunk of flooring capable of holding the weight of a shuttle."
	icon_state = "tile_dock"
	custom_materials = list(/datum/material/iron=500, /datum/material/plasma=500)
	turf_type = /turf/open/floor/dock
	merge_type = /obj/item/stack/tile/dock

/obj/item/stack/tile/drydock
	name = "dry dock tile"
	singular_name = "dry dock tile"
	desc = "An extra-bulky chunk of flooring capable of supporting shuttle construction."
	icon_state = "tile_drydock"
	custom_materials = list(/datum/material/iron=1000, /datum/material/plasma=1000)
	turf_type = /turf/open/floor/dock/drydock
	merge_type = /obj/item/stack/tile/drydock

/obj/item/stack/tile/material
	name = "floor tile"
	singular_name = "floor tile"
	desc = "The ground you walk on."
	throwforce = 10
	icon_state = "material_tile"
	turf_type = /turf/open/floor/material
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	merge_type = /obj/item/stack/tile/material

/obj/item/stack/tile/material/place_tile(turf/open/target_plating, mob/user)
	. = ..()
	var/turf/open/floor/material/floor = .
	floor?.set_custom_materials(mats_per_unit)

// Glass floors
/obj/item/stack/tile/glass
	name = "glass floor"
	singular_name = "glass floor tile"
	desc = "Glass window floors, to let you see... Whatever that is down there."
	icon_state = "tile_glass"
	turf_type = /turf/open/floor/glass
	merge_type = /obj/item/stack/tile/glass
	custom_materials = list(/datum/material/glass=500) // 4 tiles per sheet

/obj/item/stack/tile/glass/sixty
	amount = 60

/obj/item/stack/tile/rglass
	name = "reinforced glass floor"
	singular_name = "reinforced glass floor tile"
	desc = "Reinforced glass window floors. These bad boys are 50% stronger than their predecessors!"
	icon_state = "tile_rglass"
	turf_type = /turf/open/floor/glass/reinforced
	merge_type = /obj/item/stack/tile/rglass
	custom_materials = list(/datum/material/iron=250, /datum/material/glass=250) // 4 tiles per sheet

/obj/item/stack/tile/rglass/sixty
	amount = 60

/obj/item/stack/tile/glass/plasma
	name = "plasma glass floor"
	singular_name = "plasma glass floor tile"
	desc = "Plasma glass window floors, for when... Whatever is down there is too scary for normal glass."
	icon_state = "tile_pglass"
	turf_type = /turf/open/floor/glass/plasma
	merge_type = /obj/item/stack/tile/glass/plasma
	custom_materials = list(/datum/material/plasma =500)

/obj/item/stack/tile/glass/plasma
	amount = 60

/obj/item/stack/tile/rglass/plasma
	name = "reinforced plasma glass floor"
	singular_name = "reinforced plasma glass floor tile"
	desc = "Reinforced plasma glass window floors, because whatever's downstairs should really stay down there."
	icon_state = "tile_rpglass"
	turf_type = /turf/open/floor/glass/reinforced/plasma
	merge_type = /obj/item/stack/tile/rglass/plasma
	custom_materials = list(/datum/material/iron = 250, /datum/material/plasma = 250)

/obj/item/stack/tile/rglass/plasma
	amount = 60

//Catwalk Tiles
/obj/item/stack/tile/catwalk_tile //This is our base type, sprited to look maintenance-styled
	name = "catwalk floor"
	singular_name = "catwalk floor tile"
	desc = "Flooring that shows its contents underneath. Engineers love it!"
	icon_state = "maint_catwalk"
	inhand_icon_state = "tile-catwalk"
	turf_type = /turf/open/floor/catwalk_floor
	merge_type = /obj/item/stack/tile/catwalk_tile //Just to be cleaner, these all stack with eachother
	tile_reskin_types = list(
		/obj/item/stack/tile/catwalk_tile,
		/obj/item/stack/tile/catwalk_tile/iron,
		/obj/item/stack/tile/catwalk_tile/iron_white,
		/obj/item/stack/tile/catwalk_tile/iron_dark,
		/obj/item/stack/tile/catwalk_tile/flat_white,
		/obj/item/stack/tile/catwalk_tile/titanium,
		/obj/item/stack/tile/catwalk_tile/iron_smooth //this is the original greenish one
	)

/obj/item/stack/tile/catwalk_tile/sixty
	amount = 60

/obj/item/stack/tile/catwalk_tile/iron
	icon_state = "iron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron

/obj/item/stack/tile/catwalk_tile/iron_white
	icon_state = "whiteiron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron_white

/obj/item/stack/tile/catwalk_tile/iron_dark
	icon_state = "darkiron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron_dark

/obj/item/stack/tile/catwalk_tile/flat_white
	icon_state = "flatwhite_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/flat_white

/obj/item/stack/tile/catwalk_tile/titanium
	icon_state = "titanium_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/titanium

/obj/item/stack/tile/catwalk_tile/titanium/alt
	icon_state = "titanium_alt_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/titanium/alt

/obj/item/stack/tile/catwalk_tile/iron_smooth //this is the greenish one
	icon_state = "smoothiron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron_smooth
