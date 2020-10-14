// Effects
/obj/effect/oneway
	name = "one way effect"
	desc = "Only lets things in from it's dir."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE

/obj/effect/oneway/CanPass(atom/movable/mover, turf/target)
	var/turf/T = get_turf(src)
	var/turf/MT = get_turf(mover)
	return ..() && (T == MT || get_dir(MT,T) == dir)


/obj/effect/wind
	name = "wind effect"
	desc = "Creates pressure effect in it's direction. Use sparingly."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"
	invisibility = INVISIBILITY_MAXIMUM
	var/strength = 30

/obj/effect/wind/Initialize()
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/effect/wind/process()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.consider_pressure_difference(get_step(T,dir),strength)

//Keep these rare due to cost of doing these checks
/obj/effect/path_blocker
	name = "magic barrier"
	desc = "You shall not pass."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "blocker" //todo make this actually look fine when visible
	anchored = TRUE
	var/list/blocked_types = list()
	var/reverse = FALSE //Block if path not present

/obj/effect/path_blocker/Initialize()
	. = ..()
	if(blocked_types.len)
		blocked_types = typecacheof(blocked_types)

/obj/effect/path_blocker/CanPass(atom/movable/mover, turf/target)
	if(blocked_types.len)
		var/list/mover_contents = mover.GetAllContents()
		for(var/atom/movable/thing in mover_contents)
			if(blocked_types[thing.type])
				return reverse
	return !reverse

// Items

/obj/item/awaymaploader
	name = "debug away mission loader - report this!"
	desc = "A disk containing a set of data codes needed to lock onto an away mission. Insert it into the station gateway to lock onto the mission."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk0"
	var/map = null
	var/mapcode = "MAIN_MISSION" // This is the code the user must enter into the gateway to journey to your map

/obj/item/awaymaploader/beach
	name = "away mission data disk: Beach"
	map = '_maps/RandomZLevels/TheBeach.dmm'
	mapcode = "BEACH"


