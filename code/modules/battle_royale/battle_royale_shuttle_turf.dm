GLOBAL_LIST(shuttle_drop_turfs)
GLOBAL_VAR_INIT(shuttle_drop_min_x, 0)
GLOBAL_VAR_INIT(shuttle_drop_min_y, 0)
GLOBAL_VAR_INIT(shuttle_drop_max_x, 0)
GLOBAL_VAR_INIT(shuttle_drop_max_y, 0)

/turf/open/shuttle_drop_turf
	name = "open space"
	desc = "I can see my house from here!"
	icon_state = "transparent"
	baseturfs = /turf/open/shuttle_drop_turf
	intact = FALSE
	var/turf/target_turf

/turf/open/shuttle_drop_turf/Initialize()
	. = ..()
	plane = OPENSPACE_PLANE
	layer = OPENSPACE_LAYER

	vis_contents += GLOB.openspace_backdrop_one_for_all //Special grey square for projecting backdrop darkness filter on it.

	if(!GLOB.shuttle_drop_turfs)
		GLOB.shuttle_drop_turfs = list()
	GLOB.shuttle_drop_turfs += src
	return INITIALIZE_HINT_LATELOAD

/turf/open/shuttle_drop_turf/LateInitialize()
	. = ..()

	if(!GLOB.shuttle_drop_min_x)
		GLOB.shuttle_drop_min_x = x
	else
		GLOB.shuttle_drop_min_x = min(GLOB.shuttle_drop_min_x, x)

	if(!GLOB.shuttle_drop_max_x)
		GLOB.shuttle_drop_max_x = x
	else
		GLOB.shuttle_drop_max_x = max(GLOB.shuttle_drop_max_x, x)

	if(!GLOB.shuttle_drop_min_y)
		GLOB.shuttle_drop_min_y = y
	else
		GLOB.shuttle_drop_min_y = min(GLOB.shuttle_drop_min_y, y)

	if(!GLOB.shuttle_drop_max_y)
		GLOB.shuttle_drop_max_y = y
	else
		GLOB.shuttle_drop_max_y = max(GLOB.shuttle_drop_max_y, y)

/turf/open/shuttle_drop_turf/proc/set_target_turf(turf/T)
	vis_contents.Cut()
	vis_contents += GLOB.openspace_backdrop_one_for_all //Special grey square for projecting backdrop darkness filter on it.
	vis_contents += T
	target_turf = T

/turf/open/shuttle_drop_turf/attackby(obj/item/C, mob/user, params)
	return

/turf/open/shuttle_drop_turf/ReplaceWithLattice()
	return

/turf/open/shuttle_drop_turf/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return

/turf/open/shuttle_drop_turf/Entered(atom/movable/A)
	. = ..()
	if(iseffect(A))
		return
	if(target_turf)
		var/mutable_appearance/balloon
		var/mutable_appearance/balloon3
		if(isliving(A))
			var/mob/living/M = A
			M.Paralyze(80) // Keep them from moving during the duration of the extraction
			M.buckled?.unbuckle_mob(M, TRUE) // Unbuckle them to prevent anchoring problems
			//Reset status flags
			M.status_flags = CANSTUN|CANKNOCKDOWN|CANUNCONSCIOUS|CANPUSH
			//You can no longer go through mobs
			M.pass_flags &= ~PASSMOB
			REMOVE_TRAIT(M, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
			to_chat(M, "<span class='greenannounce'>You are no longer a pacafist. Be the last [M.gender == MALE ? "man" : "woman"] standing.</span>")
		else
			A.anchored = TRUE
			A.density = FALSE
		var/obj/effect/extraction_holder/holder_obj = new(A.loc)
		holder_obj.appearance = A.appearance
		A.forceMove(holder_obj)
		balloon = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_balloon")
		balloon.pixel_y = 10
		holder_obj.pixel_z = 1000
		balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		holder_obj.add_overlay(balloon)
		playsound(holder_obj.loc, 'sound/items/fultext_deploy.ogg', 50, 1, -3)
		holder_obj.forceMove(target_turf)
		animate(holder_obj, pixel_z = 10, time = 50)
		sleep(50)
		animate(holder_obj, pixel_z = 15, time = 10)
		sleep(10)
		animate(holder_obj, pixel_z = 10, time = 10)
		sleep(10)
		balloon3 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_retract")
		balloon3.pixel_y = 10
		balloon3.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		holder_obj.cut_overlay(balloon)
		holder_obj.add_overlay(balloon3)
		sleep(4)
		holder_obj.cut_overlay(balloon3)
		A.anchored = FALSE // An item has to be unanchored to be extracted in the first place.
		A.density = initial(A.density)
		animate(holder_obj, pixel_z = 0, time = 5)
		sleep(5)
		A.forceMove(holder_obj.loc)
		qdel(holder_obj)
