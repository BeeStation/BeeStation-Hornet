
/turf/open/floor/plating/airless
	icon_state = "plating"
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/lavaland
	icon_state = "plating"
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	tiled_dirt = FALSE
	max_integrity = 1800

/turf/open/floor/plating/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"


/turf/open/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"
	tiled_dirt = FALSE
	max_integrity = 1800

/turf/open/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/open/floor/plating/abductor2/burn_tile()
	return //unburnable

/turf/open/floor/plating/abductor2/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet
	icon = MAP_SWITCH('icons/turf/floors/ash.dmi', 'icons/turf/mining.dmi')
	icon_state = "ash"
	base_icon_state = "ash"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	// This is static
	// Done like this to avoid needing to make it dynamic and save cpu time
	// 4 to the left, 4 down
	transform = MAP_SWITCH(TRANSLATE_MATRIX(MINERAL_WALL_OFFSET, MINERAL_WALL_OFFSET), matrix())
	gender = PLURAL
	name = "ash"
	desc = "The ground is covered in volcanic ash."
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock //I assume this will be a chasm eventually, once this becomes an actual surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/plating/ashplanet/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet/break_tile()
	return

/turf/open/floor/plating/ashplanet/burn_tile()
	return

/turf/open/floor/plating/ashplanet/ash
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ASH, SMOOTH_GROUP_CLOSED_TURFS)
	layer = HIGH_TURF_LAYER
	slowdown = 1

/turf/open/floor/plating/ashplanet/rocky
	gender = PLURAL
	name = "rocky ground"
	icon = MAP_SWITCH('icons/turf/floors/rocky_ash.dmi', 'icons/turf/mining.dmi')
	icon_state = "rockyash"
	base_icon_state = null
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH_ROCKY)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ASH_ROCKY, SMOOTH_GROUP_CLOSED_TURFS)
	smoothing_flags = SMOOTH_CORNERS
	layer = MID_TURF_LAYER
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ashplanet/wateryrock
	gender = PLURAL
	name = "wet rocky ground"
	icon = 'icons/turf/mining.dmi'
	icon_state = "wateryrock"
	smoothing_flags = NONE
	canSmoothWith = null
	base_icon_state = null
	slowdown = 2
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	// Disable smoothing and remove the offset matrix
	smoothing_flags = NONE
	transform = matrix()

/turf/open/floor/plating/ashplanet/wateryrock/Initialize(mapload)
	icon_state = "[icon_state][rand(1, 9)]"
	. = ..()

/turf/open/floor/plating/grass //it's 100% real
	name = "lush grass"
	desc = "Green and warm, makes you want to lay down."
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	flags_1 = NONE
	bullet_bounce_sound = null
	layer = EDGED_TURF_LAYER
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_GRASS)
	tiled_dirt = FALSE
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-9, -9), matrix())
	resistance_flags = INDESTRUCTIBLE
	planetary_atmos = TRUE
	init_air = FALSE //grass should act almost like space tiles as has the entire plannets atmos to cycle with
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000


/turf/open/floor/plating/beach
	name = "beach"
	icon = 'icons/misc/beach/beach.dmi'
	flags_1 = NONE
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	attachment_holes = FALSE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	resistance_flags = INDESTRUCTIBLE

/turf/open/floor/plating/beach/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/beach/sand
	gender = PLURAL
	name = "sand"
	desc = "Surf's up."
	icon_state = "Water-0"
	baseturfs = /turf/open/floor/plating/beach/sand

/turf/open/floor/plating/beach/water
	name = "water"
	desc = "Ocean waves: Salty breeze, briny depths, endless blue expanse."
	icon = 'icons/misc/Beach/beach.dmi'
	icon_state = "Water-255"
	base_icon_state = "Water"
	baseturfs = /turf/open/floor/plating/beach/water
	slowdown = 3
	bullet_sizzle = TRUE
	bullet_bounce_sound = 'sound/effects/splash.ogg'
	footstep = FOOTSTEP_WATER
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)

// pool.dm copy paste

/turf/open/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //If you're swimming around, you don't really want to stop swimming just like that do you?
	if(S)
		return FALSE //If you're swimming, you can't swim into a regular turf, y'dig?
	. = ..()

/turf/open/floor/plating/beach/water/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
	return (isliving(mover)) ? S : ..() //So you can do stuff like throw beach balls around the pool!

/turf/open/floor/plating/beach/water/Entered(atom/movable/AM)
	. = ..()
	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT)
	if(isliving(AM))
		var/datum/component/swimming/S = AM.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
		if(!S)
			var/mob/living/carbon/C = AM
			var/component_type = /datum/component/swimming
			if(istype(C) && C?.dna?.species)
				component_type = C.dna.species.swimming_component
			AM.AddComponent(component_type)

/turf/open/floor/plating/beach/water/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(!istype(newloc, /turf/open/indestructible/sound/pool))
		var/datum/component/swimming/S = Obj.GetComponent(/datum/component/swimming) //Handling admin TPs here.
		S?.ClearFromParent()

/turf/open/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/atom/movable/AM = dropping
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming)
	if(S)
		if(do_after(user, 1 SECONDS, target = dropping))
			S.ClearFromParent()
			visible_message(span_notice("[dropping] climbs out of the pool."))
			AM.forceMove(src)
	else
		. = ..()

/turf/open/floor/plating/beach/water/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming) //If they're already swimming, don't let them start swimming again.
	if(S)
		return FALSE
	. = ..()
	if(user != dropping)
		dropping.visible_message(span_notice("[user] starts to lower [dropping] down into [src]."), \
			span_notice("You start to lower [dropping] down into [src]."))
	else
		to_chat(user, span_notice("You start climbing down into [src]..."))
	if(do_after(user, 4 SECONDS, target = dropping))
		splash(dropping)


/turf/open/floor/plating/beach/water/proc/splash(mob/user)
	user.forceMove(src)
	playsound(src, 'sound/effects/splosh.ogg', 100, 1) //Credit to hippiestation for this sound file!
	user.visible_message(span_boldwarning("SPLASH!"))
	var/zap = 0
	if(issilicon(user)) //Do not throw brick in a pool. Brick begs.
		zap = 1 //Sorry borgs! Swimming will come at a cost.
	if(ishuman(user))
		var/mob/living/carbon/human/F = user
		var/datum/species/SS = F.dna.species
		if(SS.inherent_biotypes & MOB_ROBOTIC)  //ZAP goes the IPC!
			zap = 2 //You can protect yourself from water damage with thick clothing.
		if(F.head && isclothing(F.head))
			var/obj/item/clothing/CH = F.head
			if (CH.clothing_flags & THICKMATERIAL) //Skinsuit should suffice! But IPCs are robots and probably not water-sealed.
				zap --
		if(F.wear_suit && isclothing(F.wear_suit))
			var/obj/item/clothing/CS = F.wear_suit
			if (CS.clothing_flags & THICKMATERIAL)
				zap --
	if(zap > 0)
		user.emp_act(zap)
		user.emote("scream") //Chad coders use M.say("*scream")
		do_sparks(zap, TRUE, user)
		to_chat(user, span_userdanger("WARNING: WATER DAMAGE DETECTED!"))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "robotpool", /datum/mood_event/robotpool)
	else
		if(!check_clothes(user))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolparty)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolwet)

//Largely a copypaste from shower.dm. Checks if the mob was stupid enough to enter a pool fully clothed. We allow masks as to not discriminate against clown and mime players.
/turf/open/floor/plating/beach/water/proc/check_clothes(mob/living/carbon/human/H)
	if(!istype(H) || iscatperson(H)) //Don't care about non humans.
		return FALSE
	if(H.wear_suit && (H.wear_suit.clothing_flags))
		// Do not check underclothing if the over-suit is suitable.
		// This stops people feeling dumb if they're showering
		// with a radiation suit on.
		return FALSE

	. = FALSE
	if(!(H.wear_suit?.clothing_flags))
		return TRUE
	if(!(H.w_uniform?.clothing_flags))
		return TRUE
	if(!(H.head?.clothing_flags))
		return TRUE

/turf/open/floor/plating/beach/deep_water
	desc = "Deep water. What if there's sharks?"
	icon_state = "water_deep"
	name = "deep water"
	density = 1 //no swimming
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)

/turf/open/floor/plating/ironsand
	gender = PLURAL
	name = "iron sand"
	desc = "Like sand, but more <i>iron</i>."
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/open/floor/plating/ironsand/burn_tile()
	return

/turf/open/floor/plating/ironsand/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice-0"
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/ice
	slowdown = 1
	attachment_holes = FALSE
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/floor/plating/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ice/smooth
	icon_state = "ice-255"
	base_icon_state = "ice"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ICE)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ICE)

/turf/open/floor/plating/ice/smooth/planetary
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/ice/smooth/red
	icon = 'icons/turf/floors/red_ice.dmi'
	icon_state = "red_ice-0"
	base_icon_state = "red_ice"

/turf/open/floor/plating/ice/colder
	temperature = 140

/turf/open/floor/plating/ice/temperate
	temperature = 255.37

/turf/open/floor/plating/ice/break_tile()
	return

/turf/open/floor/plating/ice/burn_tile()
	return


/turf/open/floor/plating/snowed
	name = "snowed-over plating"
	desc = "A section of heated plating, helps keep the snow from stacking up too high."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snowplating"
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	attachment_holes = FALSE
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/snowed/cavern
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE


/turf/open/floor/plating/snowed/smoothed
	planetary_atmos = TRUE
	icon = 'icons/turf/floors/snow_turf.dmi'
	icon_state = "snow_turf-0"
	base_icon_state = "snow_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_SNOWED)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_SNOWED)

/turf/open/floor/plating/snowed/smoothed/planetary
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/snowed/colder
	temperature = 140

/turf/open/floor/plating/snowed/temperate
	temperature = 255.37

/turf/open/floor/plating/elevatorshaft
	name = "elevator shaft"
	icon_state = "elevatorshaft"
	base_icon_state = "elevatorshaft"
