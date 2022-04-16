/// spatial rift
/// Basically a BoH Tear, but weaker because it spawns after nullifying a tesloose or singlo and those have done enough damage
/obj/singularity/spatial_rift
	name = "a small tear in the fabric of reality, a good place to stuff problems"
	desc = "Your own comprehension of reality starts bending as you stare this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	is_real = FALSE
	pixel_x = -32
	pixel_y = -32
	dissipate = 0
	move_self = 0
	consume_range = 1
	grav_pull = 2
	current_size = STAGE_FIVE
	allowed_size = STAGE_FIVE
	var/ghosts = list()
	var/old_loc

/obj/singularity/spatial_rift/Initialize(mapload)
	. = ..()
	old_loc = get_turf(src)
	addtimer(CALLBACK(src, /atom/movable.proc/moveToNullspace), 5 SECONDS) // vanishes after 5 seconds
	QDEL_IN(src, 10 MINUTES)

/// Retrieve all the items consumed
/obj/singularity/spatial_rift/proc/retrieve_consumed_items()
	for(var/atom/movable/content in contents)
		content.forceMove(old_loc)
		if(ismob(content))
			var/mob/M = content
			if(!M.mind)
				continue
			for(var/mob/dead/observer/ghost in ghosts)
				if(ghost.mind == M.mind)
					ghosts -= ghost
					ghost.can_reenter_corpse = TRUE
					ghost.reenter_corpse()
					break
	qdel(src)

/obj/singularity/spatial_rift/process()
	eat()

/obj/singularity/spatial_rift/consume(atom/A)
	if(isturf(A))
		A.singularity_act()
		return
	var/atom/movable/AM = A
	var/turf/T = get_turf(src)
	if(!istype(AM))
		return
	if(isliving(AM))
		var/mob/living/M = AM
		investigate_log("([key_name(A)]) has been consumed by the Spatial rift at [AREACOORD(T)].", INVESTIGATE_ENGINES)
		M.ghostize(FALSE)
	else if(istype(AM, /obj/singularity))
		investigate_log("([key_name(A)]) has been consumed by the Spatial rift at [AREACOORD(T)].", INVESTIGATE_ENGINES)
		return
	AM.forceMove(src)

/obj/singularity/spatial_rift/admin_investigate_setup()
	var/turf/T = get_turf(src)
	message_admins("A Spatial rift has been created at [ADMIN_VERBOSEJMP(T)]. [ADMIN_RETRIEVE_BOH_ITEMS(src)]")
	investigate_log("was created at [AREACOORD(T)].", INVESTIGATE_ENGINES)

/obj/singularity/spatial_rift/attack_tk(mob/living/user)
	if(!istype(user))
		return
	to_chat(user, "<span class='userdanger'>You don't feel like you are real anymore.</span>")
	user.dust_animation()
	user.spawn_dust()
	addtimer(CALLBACK(src, .proc/consume, user), 5)
