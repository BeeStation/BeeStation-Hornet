/**
 * ## catwalk flooring
 *
 * They show what's underneath their catwalk flooring (pipes and the like)
 * you can crowbar it to interact with the underneath stuff without destroying the tile...
 * unless you want to!
 */
/turf/open/floor/catwalk_floor
	icon = 'icons/turf/floors/catwalk_plating.dmi'
	icon_state = "catwalk_below"
	name = "catwalk floor"
	desc = "Flooring that shows its contents underneath. Engineers love it!"
	baseturfs = /turf/open/floor/plating
	floor_tile = /obj/item/stack/tile/catwalk_tile
	footstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	clawfootstep = FOOTSTEP_CATWALK
	heavyfootstep = FOOTSTEP_CATWALK
	var/covered = TRUE

/turf/open/floor/catwalk_floor/Initialize()
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/turf/open/floor/catwalk_floor/update_overlays()
	. = ..()
	var/static/catwalk_overlay
	if(isnull(catwalk_overlay))
		catwalk_overlay = iconstate2appearance(icon, "catwalk_above")
	if(covered)
		. += catwalk_overlay

/turf/open/floor/catwalk_floor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	covered = !covered
	user.balloon_alert(user, "[!covered ? "cover removed" : "cover added"]")
	update_icon(UPDATE_OVERLAYS)

/turf/open/floor/catwalk_floor/crowbar_act(mob/user, obj/item/crowbar)
	if(covered)
		user.balloon_alert(user, "remove cover first!")
		return FALSE
	. = ..()
