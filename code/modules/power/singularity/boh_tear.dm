/// BoH tear
/// The BoH tear is a stationary singularity with a really high gravitational pull, which collapses briefly after being created
/// The BoH isn't deleted for 10 minutes (only moved to nullspace) so that admins may retrieve the things back in case of a grief
#define BOH_TEAR_CONSUME_RANGE 1
#define BOH_TEAR_GRAV_PULL 25

/obj/boh_tear
	name = "tear in the fabric of reality"
	desc = "Your own comprehension of reality starts bending as you stare this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1
	var/list/ghosts = list()
	var/old_loc

/obj/boh_tear/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, moveToNullspace)), 5 SECONDS) // vanishes after 5 seconds
	QDEL_IN(src, 10 MINUTES)
	AddComponent(
		/datum/component/singularity, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		admin_investigate_callback = CALLBACK(src, PROC_REF(admin_investigate_setup)), \
		consume_range = BOH_TEAR_CONSUME_RANGE, \
		grav_pull = BOH_TEAR_GRAV_PULL, \
		roaming = FALSE, \
		singularity_size = STAGE_SIX, \
	)

/// Retrieve all the items consumed
/obj/boh_tear/proc/retrieve_consumed_items()
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

/obj/boh_tear/Destroy()
	ghosts.Cut()
	old_loc = null
	return ..()

/obj/boh_tear/proc/consume(atom/A)
	if(isturf(A))
		A.singularity_act()
		return
	var/atom/movable/AM = A
	if(!istype(AM))
		return
	if(isliving(AM))
		var/mob/living/M = AM
		var/turf/T = get_turf(src)
		investigate_log("([key_name(A)]) has been consumed by the BoH tear at [AREACOORD(T)].", INVESTIGATE_ENGINES)
		ghosts += M.ghostize(FALSE)
	else if(!isobj(AM))
		return
	AM.forceMove(src)

/obj/boh_tear/proc/admin_investigate_setup()
	var/turf/T = get_turf(src)
	message_admins("A BoH tear has been created at [ADMIN_VERBOSEJMP(T)]. [ADMIN_RETRIEVE_BOH_ITEMS(src)]")
	investigate_log("was created at [AREACOORD(T)].", INVESTIGATE_ENGINES)

/obj/boh_tear/attack_tk(mob/living/user)
	if(!istype(user))
		return
	to_chat(user, "<span class='userdanger'>You don't feel like you are real anymore.</span>")
	user.dust_animation()
	user.spawn_dust()
	addtimer(CALLBACK(src, PROC_REF(consume), user), 5)

#undef BOH_TEAR_CONSUME_RANGE
#undef BOH_TEAR_GRAV_PULL
