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
	/// What type of turf does this tile produce.
	var/turf_type = null
	/// Determines certain welder interactions.
	var/mineralType = null
	/// Cached associative lazy list to hold the radial options for tile reskinning. See tile_reskinning.dm for more information. Pattern: list[type] -> image
	var/list/tile_reskin_types

/obj/item/stack/tile/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little
	if(tile_reskin_types)
		tile_reskin_types = tile_reskin_list(tile_reskin_types)


/obj/item/stack/tile/attackby(obj/item/W, mob/user, params)

	if (W.tool_behaviour == TOOL_WELDER)
		if(get_amount() < 4)
			to_chat(user, "<span class='warning'>You need at least four tiles to do this!</span>")
			return

		if(!mineralType)
			to_chat(user, "<span class='warning'>You can not reform this!</span>")
			return

		if(W.use_tool(src, user, 0, volume=40))
			if(mineralType == "plasma")
				atmos_spawn_air("plasma=5;TEMP=1000")
				user.visible_message("<span class='warning'>[user.name] sets the plasma tiles on fire!</span>", \
									"<span class='warning'>You set the plasma tiles on fire!</span>")
				qdel(src)
				return

			if (mineralType == "iron")
				var/obj/item/stack/sheet/iron/new_item = new(user.loc)
				user.visible_message("[user.name] shaped [src] into iron with the welding tool.", \
							 "<span class='notice'>You shaped [src] into iron with the welding tool.</span>", \
							 "<span class='italics'>You hear welding.</span>")
				var/obj/item/stack/rods/R = src
				src = null
				var/replace = (user.get_inactive_held_item()==R)
				R.use(4)
				if (!R && replace)
					user.put_in_hands(new_item)

			else
				var/sheet_type = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
				var/obj/item/stack/sheet/mineral/new_item = new sheet_type(user.loc)
				user.visible_message("[user.name] shaped [src] into a sheet with the welding tool.", \
							 "<span class='notice'>You shaped [src] into a sheet with the welding tool.</span>", \
							 "<span class='italics'>You hear welding.</span>")
				var/obj/item/stack/rods/R = src
				src = null
				var/replace = (user.get_inactive_held_item()==R)
				R.use(4)
				if (!R && replace)
					user.put_in_hands(new_item)
	else
		return ..()

//Grass
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they use on space golf courses."
	icon_state = "tile_grass"
	item_state = "tile-grass"
	turf_type = /turf/open/floor/grass
	resistance_flags = FLAMMABLE

/obj/item/stack/tile/grass/attackby(obj/item/W, mob/user, params)
	if((W.tool_behaviour == TOOL_SHOVEL) && params)
		to_chat(user, "<span class='notice'>You start digging up [src].</span>")
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		if(do_after(user, 2 * get_amount(), target = src))
			new /obj/item/stack/ore/glass(get_turf(src), 2 * get_amount())
			user.visible_message("<span class='notice'>[user] digs up [src].</span>", "<span class='notice'>You uproot [src].</span>")
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
	item_state = "tile-fairygrass"
	turf_type = /turf/open/floor/grass/fairy
	resistance_flags = FLAMMABLE
	color = "#33CCFF"

/obj/item/stack/tile/fairygrass/white
	name = "white fairygrass tile"
	singular_name = "white fairygrass floor tile"
	desc = "A patch of odd, glowing white grass."
	turf_type = /turf/open/floor/grass/fairy/white
	color = "#FFFFFF"

/obj/item/stack/tile/fairygrass/red
	name = "red fairygrass tile"
	singular_name = "red fairygrass floor tile"
	desc = "A patch of odd, glowing red grass."
	turf_type = /turf/open/floor/grass/fairy/red
	color = "#FF3333"

/obj/item/stack/tile/fairygrass/orange
	name = "orange fairygrass tile"
	singular_name = "orange fairygrass floor tile"
	desc = "A patch of odd, glowing orange grass."
	turf_type = /turf/open/floor/grass/fairy/orange
	color = "#FFA500"

/obj/item/stack/tile/fairygrass/yellow
	name = "yellow fairygrass tile"
	singular_name = "yellow fairygrass floor tile"
	desc = "A patch of odd, glowing yellow grass."
	turf_type = /turf/open/floor/grass/fairy/yellow
	color = "#FFFF66"

/obj/item/stack/tile/fairygrass/green
	name = "green fairygrass tile"
	singular_name = "green fairygrass floor tile"
	desc = "A patch of odd, glowing green grass."
	turf_type = /turf/open/floor/grass/fairy/green
	color = "#99FF99"

/obj/item/stack/tile/fairygrass/blue
	name = "blue fairygrass tile"
	singular_name = "blue fairygrass floor tile"
	desc = "A patch of odd, glowing blue grass."
	turf_type = /turf/open/floor/grass/fairy/blue

/obj/item/stack/tile/fairygrass/purple
	name = "purple fairygrass tile"
	singular_name = "purple fairygrass floor tile"
	desc = "A patch of odd, glowing purple grass."
	turf_type = /turf/open/floor/grass/fairy/purple
	color = "#D966FF"

/obj/item/stack/tile/fairygrass/pink
	name = "pink fairygrass tile"
	singular_name = "pink fairygrass floor tile"
	desc = "A patch of odd, glowing pink grass."
	turf_type = /turf/open/floor/grass/fairy/pink
	color = "#FFB3DA"

/obj/item/stack/tile/fairygrass/dark
	name = "dark fairygrass tile"
	singular_name = "dark fairygrass floor tile"
	desc = "A patch of odd, light consuming grass."
	turf_type = /turf/open/floor/grass/fairy/dark
	color = "#410096"

//Wood
/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "An easy to fit wood floor tile."
	icon_state = "tile-wood"
	item_state = "tile-wood"
	turf_type = /turf/open/floor/wood
	resistance_flags = FLAMMABLE

//Bamboo
/obj/item/stack/tile/bamboo
	name = "bamboo mat pieces"
	singular_name = "bamboo mat piece"
	desc = "A piece of a bamboo mat with a decorative trim."
	icon_state = "tile-bamboo"
	item_state = "tile-bamboo"
	turf_type = /turf/open/floor/bamboo
	resistance_flags = FLAMMABLE

//Basalt
/obj/item/stack/tile/basalt
	name = "basalt tile"
	singular_name = "basalt floor tile"
	desc = "Artificially made ashy soil themed on a hostile environment."
	icon_state = "tile_basalt"
	item_state = "tile-basalt"
	turf_type = /turf/open/floor/grass/fakebasalt

//Carpets
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon_state = "tile-carpet"
	item_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet
	resistance_flags = FLAMMABLE
	tableVariant = /obj/structure/table/wood/fancy

/obj/item/stack/tile/carpet/black
	name = "black carpet"
	icon_state = "tile-carpet-black"
	item_state = "tile-carpet-black"
	merge_type = /obj/item/stack/tile/carpet/black
	turf_type = /turf/open/floor/carpet/black
	tableVariant = /obj/structure/table/wood/fancy/black

/obj/item/stack/tile/carpet/blue
	name = "blue carpet"
	icon_state = "tile-carpet-blue"
	item_state = "tile-carpet-blue"
	merge_type = /obj/item/stack/tile/carpet/blue
	turf_type = /turf/open/floor/carpet/blue
	tableVariant = /obj/structure/table/wood/fancy/blue

/obj/item/stack/tile/carpet/blue/thirtytwo
	amount = 32

/obj/item/stack/tile/carpet/cyan
	name = "cyan carpet"
	icon_state = "tile-carpet-cyan"
	item_state = "tile-carpet-cyan"
	merge_type = /obj/item/stack/tile/carpet/cyan
	turf_type = /turf/open/floor/carpet/cyan
	tableVariant = /obj/structure/table/wood/fancy/cyan

/obj/item/stack/tile/carpet/cyan/thirtytwo
	amount = 32

/obj/item/stack/tile/carpet/green
	name = "green carpet"
	icon_state = "tile-carpet-green"
	item_state = "tile-carpet-green"
	merge_type = /obj/item/stack/tile/carpet/green
	turf_type = /turf/open/floor/carpet/green
	tableVariant = /obj/structure/table/wood/fancy/green

/obj/item/stack/tile/carpet/orange
	name = "orange carpet"
	icon_state = "tile-carpet-orange"
	item_state = "tile-carpet-orange"
	merge_type = /obj/item/stack/tile/carpet/orange
	turf_type = /turf/open/floor/carpet/orange
	tableVariant = /obj/structure/table/wood/fancy/orange

/obj/item/stack/tile/carpet/purple
	name = "purple carpet"
	icon_state = "tile-carpet-purple"
	item_state = "tile-carpet-purple"
	merge_type = /obj/item/stack/tile/carpet/purple
	turf_type = /turf/open/floor/carpet/purple
	tableVariant = /obj/structure/table/wood/fancy/purple

/obj/item/stack/tile/carpet/red
	name = "red carpet"
	icon_state = "tile-carpet-red"
	item_state = "tile-carpet-red"
	merge_type = /obj/item/stack/tile/carpet/red
	turf_type = /turf/open/floor/carpet/red
	tableVariant = /obj/structure/table/wood/fancy/red

/obj/item/stack/tile/carpet/royalblack
	name = "royal black carpet"
	icon_state = "tile-carpet-royalblack"
	item_state = "tile-carpet-royalblack"
	merge_type = /obj/item/stack/tile/carpet/royalblack
	turf_type = /turf/open/floor/carpet/royalblack
	tableVariant = /obj/structure/table/wood/fancy/royalblack

/obj/item/stack/tile/carpet/royalblue
	name = "royal blue carpet"
	icon_state = "tile-carpet-royalblue"
	item_state = "tile-carpet-royalblue"
	merge_type = /obj/item/stack/tile/carpet/royalblue
	turf_type = /turf/open/floor/carpet/royalblue
	tableVariant = /obj/structure/table/wood/fancy/royalblue

/obj/item/stack/tile/carpet/grimy
	name = "grimy carpet"
	singular_name = "grimy carpet floor tile"
	desc = "A piece of carpet that feels more like floor tiles, sure it feels hard to the touch for being carpet..."
	icon_state = "tile-carpet-grimy"
	item_state = "tile-carpet-grimy"
	merge_type = /obj/item/stack/tile/carpet/grimy
	turf_type = /turf/open/floor/carpet/grimy

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
	item_state = "tile-space"
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
	item_state = "tile-basalt"
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
	item_state = "tile-noslip"
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
	item_state = "tile-bcircuit"
	turf_type = /turf/open/floor/circuit

/obj/item/stack/tile/circuit/green
	name = "green circuit tile"
	singular_name = "green circuit tile"
	desc = "A green circuit tile."
	icon_state = "tile_gcircuit"
	item_state = "tile-gcircuit"
	turf_type = /turf/open/floor/circuit/green

/obj/item/stack/tile/circuit/green/anim
	turf_type = /turf/open/floor/circuit/green/anim

/obj/item/stack/tile/circuit/red
	name = "red circuit tile"
	singular_name = "red circuit tile"
	desc = "A red circuit tile."
	icon_state = "tile_rcircuit"
	item_state = "tile-rcircuit"
	turf_type = /turf/open/floor/circuit/red

/obj/item/stack/tile/circuit/red/anim
	turf_type = /turf/open/floor/circuit/red/anim

//Pod floor
/obj/item/stack/tile/pod
	name = "pod floor tile"
	singular_name = "pod floor tile"
	desc = "A grooved floor tile."
	icon_state = "tile_pod"
	item_state = "tile-pod"
	turf_type = /turf/open/floor/pod

/obj/item/stack/tile/pod/light
	name = "light pod floor tile"
	singular_name = "light pod floor tile"
	desc = "A lightly colored grooved floor tile."
	icon_state = "tile_podlight"
	turf_type = /turf/open/floor/pod/light

/obj/item/stack/tile/pod/dark
	name = "dark pod floor tile"
	singular_name = "dark pod floor tile"
	desc = "A darkly colored grooved floor tile."
	icon_state = "tile_poddark"
	turf_type = /turf/open/floor/pod/dark

//Plasteel (normal)
/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon."
	icon_state = "tile"
	item_state = "tile"
	force = 6
	materials = list(/datum/material/iron=500)
	throwforce = 10
	flags_1 = CONDUCT_1
	turf_type = /turf/open/floor/plasteel
	mineralType = "iron"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF

/obj/item/stack/tile/plasteel/cyborg
	desc = "The ground you walk on." //Not the usual floor tile desc as that refers to throwing, Cyborgs can't do that - RR
	materials = list() // All other Borg versions of items have no Iron or Glass - RR
	is_cyborg = 1
	cost = 125

//Monotiles

/obj/item/stack/tile/mono
	name = "steel mono tile"
	singular_name = "steel mono tile"
	desc = "A really big steel tile compared to the standard station tiles."
	icon_state = "tile"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/monotile

/obj/item/stack/tile/mono/dark
	name = "dark mono tile"
	singular_name = "dark mono tile"
	desc = "A really big (dark) steel tile compared to the standard station tiles."
	icon_state = "tile"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/monotile/dark

/obj/item/stack/tile/mono/light
	name = "light mono tile"
	singular_name = "light mono tile"
	desc = "A really big (shiny) steel tile compared to the standard station tiles."
	icon_state = "tile"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/monotile/light

//Bay grids
/obj/item/stack/tile/grid
	name = "grey grid tile"
	singular_name = "grey grid tile"
	desc = "A gridded version of the standard station tiles."
	icon_state = "tile_grid"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/grid

/obj/item/stack/tile/ridge
	name = "grey ridge tile"
	singular_name = "grey ridge tile"
	desc = "A ridged version of the standard station tiles."
	icon_state = "tile_ridged"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/ridged

//Techtiles
/obj/item/stack/tile/techgrey
	name = "grey techfloor tile"
	singular_name = "grey techfloor tile"
	desc = "A fancy tile usually found in secure areas and engineering bays."
	icon_state = "tile_tech_grey"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/tech

/obj/item/stack/tile/techgrid
	name = "grid techfloor tile"
	singular_name = "grid techfloor tile"
	desc = "A fancy tile usually found in secure areas and engineering bays, this one has a grid pattern."
	icon_state = "tile_tech_grid"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/tech/grid

/obj/item/stack/tile/techmaint
	name = "dark techfloor tile"
	singular_name = "dark techfloor tile"
	desc = "A fancy tile usually found in secure areas and engineering bays, this one is dark."
	icon_state = "tile_tech_maint"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/techmaint

/obj/item/stack/tile/dock
	name = "dock tile"
	singular_name = "dock tile"
	desc = "A bulky chunk of flooring capable of holding the weight of a shuttle."
	icon_state = "tile_dock"
	materials = list(/datum/material/iron=500, /datum/material/plasma=500)
	turf_type = /turf/open/floor/dock

/obj/item/stack/tile/drydock
	name = "dry dock tile"
	singular_name = "dry dock tile"
	desc = "An extra-bulky chunk of flooring capable of supporting shuttle construction."
	icon_state = "tile_drydock"
	materials = list(/datum/material/iron=1000, /datum/material/plasma=1000)
	turf_type = /turf/open/floor/dock/drydock
