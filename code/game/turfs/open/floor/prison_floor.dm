#define MAX_PRISON_PLATES 4

/turf/open/floor/prison
	name = "secure floor"
	desc = "Prison break-proof!"
	icon = 'icons/turf/prisonfloor.dmi'
	icon_state = "prisonfloor_4"
	base_icon_state ="prisonfloor"
	max_integrity = 500
	holodeck_compatible = TRUE
	thermal_conductivity = 0.025
	heat_capacity = INFINITY
	floor_tile = /obj/item/stack/sheet/plasteel
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	baseturfs = /turf/open/floor/plating
	var/plates_type = /obj/item/stack/tile/iron
	var/plates = MAX_PRISON_PLATES
	var/wrenching = FALSE

/turf/open/floor/prison/examine(mob/user)
	. = ..()
	. += span_notice("The reinforcement plates are <b>wrenched</b> firmly in place.")

/turf/open/floor/prison/break_tile()
	return //unbreakable

/turf/open/floor/prison/burn_tile() // consider changing this
	return //unburnable

/turf/open/floor/prison/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/prison/crowbar_act(mob/living/user, obj/item/I)
	if(plates != 0)
		to_chat(user, span_danger(" The reinforcement plates are still firmly in place!"))
		return TRUE
	else
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		to_chat(user, span_notice("You begin prying open the tile..."))
		if(do_after(user, 4 SECONDS))
			return ..()

/turf/open/floor/prison/wrench_act(mob/living/user, obj/item/I)
	if(!wrenching && plates >0)
		wrenching = TRUE
		if(I.use_tool(src, user, 50, volume=80))
			to_chat(user, span_notice("You begin removing some of the plates..."))
			plates -= 1
			update_icon_state()
			wrenching = FALSE
			new plates_type(src, 1)
			return TRUE
		else
			wrenching = FALSE

/turf/open/floor/prison/update_icon_state()
	icon_state = "[base_icon_state]_[plates]"
	return ..()

/turf/open/floor/prison/attackby(obj/item/object, mob/living/user, params)
	if(plates< MAX_PRISON_PLATES && istype(object, plates_type))
		var/obj/item/stack/sheet/I = object
		I.use(1)
		plates += 1
		update_icon_state()
		return
	return ..()

/turf/open/floor/prison/dark
	icon_state = "prisonfloordark_4"
	base_icon_state ="prisonfloordark"

#undef MAX_PRISON_PLATES
