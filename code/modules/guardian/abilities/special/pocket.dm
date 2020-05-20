GLOBAL_VAR_INIT(pocket_dim, 1)
GLOBAL_LIST_EMPTY(pocket_mirrors)

/area/pocket_dimension
	name = "??? INVALID COORDINATES ???"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY
	noteleport = TRUE
	unique = FALSE
	requires_power = FALSE

/datum/guardian_ability/major/special/pocket
	name = "Dimensional Manifestation"
	desc = "The guardian has access to a pocket dimension, which it can manifest in realspace at will."
	ui_icon = "door-open"
	cost = 5
	var/manifested_at_x
	var/manifested_at_y
	var/manifested_at_z
	var/mob/camera/aiEye/remote/pocket/eye
	var/manifesting = FALSE
	var/list/manifestations = list()
	var/obj/effect/proc_holder/spell/self/pocket_dim/PD
	var/obj/effect/proc_holder/spell/self/pocket_dim_move/PDM

/datum/guardian_ability/major/special/pocket/Apply()
	PD = new
	PD.guardian = guardian
	PDM = new
	PDM.guardian = guardian
	guardian.AddSpell(PD)
	guardian.AddSpell(PDM)
	if(!LAZYLEN(guardian.pocket_dim))
		var/list/errorList = list()
		var/pocket_dim = SSmapping.LoadGroup(errorList, "Pocket Dimension [GLOB.pocket_dim]", "templates", "pocket_dimension.dmm", default_traits = list(ZTRAIT_POCKETDIM = TRUE, "Pocket Dimension [GLOB.pocket_dim]" = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 0), silent = TRUE)
		if(errorList.len)	// reebe failed to load
			message_admins("A pocket dimension failed to load!")
			log_game("A pocket dimension failed to load!")
			return FALSE
		for(var/datum/parsed_map/PM in pocket_dim)
			PM.initTemplateBounds()
		guardian.pocket_dim = "Pocket Dimension [GLOB.pocket_dim++]"
		GLOB.pocket_mirrors[guardian.pocket_dim] = list()
		var/pz = get_pocket_z()
		eye = new
		eye.guardian = guardian
		eye.pocket_z = pz
		eye.PDS = src
		eye.name = "Inactive Guardian Eye ([guardian])"
		for(var/turf/open/indestructible/pocketspace/PS in world)
			if(PS.z == pz)
				GLOB.pocket_mirrors[guardian.pocket_dim] += PS

/datum/guardian_ability/major/special/pocket/Remove()
	guardian.RemoveSpell(PD)
	guardian.RemoveSpell(PDM)

/datum/guardian_ability/major/special/pocket/proc/get_pocket_z()
	if(!guardian.pocket_dim)
		return
	var/list/zs = SSmapping.levels_by_trait(guardian.pocket_dim)
	if(!LAZYLEN(zs))
		return null
	return zs[1]

/datum/guardian_ability/major/special/pocket/proc/manifest_dimension(pos_already_set = FALSE)
	var/pocket_z = get_pocket_z()
	if(!pocket_z)
		return
	destroy_pocket_mirror(pocket_z)
	manifesting = TRUE
	if(LAZYLEN(GLOB.pocket_mirrors[guardian.pocket_dim]))
		for(var/turf/open/indestructible/pocketspace/PS in GLOB.pocket_mirrors[guardian.pocket_dim])
			PS.vis_contents.Cut()
	var/corrected_max = manifested_at_x
	var/corrected_may = manifested_at_y
	if(!pos_already_set) // don't subtract 4 if the pos is set, because we will have already subtracted by 4.
		manifested_at_x = CLAMP(guardian.x - 4, 1, world.maxx)
		corrected_max = manifested_at_x
		manifested_at_y = CLAMP(guardian.y - 4, 1, world.maxy)
		corrected_may = manifested_at_y
		manifested_at_z = get_final_z(guardian)
	for(var/mx = 0 to 8)
		for(var/my = 0 to 8)
			var/turf/us = locate(corrected_max + mx, corrected_may + my, manifested_at_z)
			var/turf/them = locate(mx + 1, my + 1, pocket_z)
			if(us && them)
				var/obj/effect/manifestation/M = new(us)
				M.vis_contents += them
				manifestations += M
	addtimer(VARSET_CALLBACK(src, manifesting, FALSE), 3 SECONDS)

/datum/guardian_ability/major/special/pocket/proc/demanifest_dimension()
	manifesting = TRUE
	for(var/obj/effect/manifestation/M in manifestations)
		manifestations -= M
		animate(M, alpha = 0, time = 3 SECONDS, easing = LINEAR_EASING)
		QDEL_IN(M, 3 SECONDS)
	var/pocket_z = get_pocket_z()
	if(pocket_z)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/update_pocket_mirror, pocket_z, manifested_at_x, manifested_at_y, manifested_at_z), 3.5 SECONDS)
	addtimer(VARSET_CALLBACK(src, manifesting, FALSE), 3 SECONDS)

/datum/guardian_ability/major/special/pocket/proc/check_if_teleport(mob/living/L)
	var/list/pocket_z = get_pocket_z()
	if(!pocket_z)
		return
	if(get_final_z(L) != pocket_z)
		take_effects(L)

/datum/guardian_ability/major/special/pocket/proc/add_effects(mob/living/L)
	L.apply_status_effect(/datum/status_effect/dimensional_mending)
	ADD_TRAIT(L, TRAIT_NOHARDCRIT, GUARDIAN_TRAIT)
	ADD_TRAIT(L, TRAIT_NOSOFTCRIT, GUARDIAN_TRAIT)
	ADD_TRAIT(L, TRAIT_NODEATH, GUARDIAN_TRAIT)
	if(!isguardian(L))
		RegisterSignal(L, COMSIG_MOVABLE_MOVED, .proc/check_if_teleport)
	for(var/mob/living/simple_animal/hostile/guardian/G in L.hasparasites())
		G.status_flags |= GODMODE

/datum/guardian_ability/major/special/pocket/proc/take_effects(mob/living/L)
	L.remove_status_effect(/datum/status_effect/dimensional_mending)
	REMOVE_TRAIT(L, TRAIT_NOHARDCRIT, GUARDIAN_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOSOFTCRIT, GUARDIAN_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NODEATH, GUARDIAN_TRAIT)
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
	for(var/mob/living/simple_animal/hostile/guardian/G in L.hasparasites())
		G.status_flags &= ~GODMODE

/obj/effect/manifestation
	layer = ABOVE_LIGHTING_LAYER
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	alpha = 0
	mouse_opacity = FALSE
	var/next_animate = 0

/obj/effect/manifestation/Initialize()
	. = ..()
	var/X,Y,i,rsq
	for(i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	START_PROCESSING(SSobj, src)
	animate(src, alpha = 127, time = 3 SECONDS, easing = LINEAR_EASING)

/obj/effect/manifestation/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/manifestation/process()
	if(next_animate > world.time)
		return
	var/i,f
	for(i=1, i<=7, ++i)
		f = filters[i]
		var/next = rand()*20+10
		animate(f, offset=f:offset, time=0, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=next)
		next_animate = world.time + next

/obj/effect/proc_holder/spell/self/pocket_dim
	name = "Dimensional Intersection"
	desc = "(De)manifest a pocket dimension."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 45 SECONDS
	action_icon = 'icons/obj/objects.dmi'
	action_icon_state = "anom"
	var/mob/living/simple_animal/hostile/guardian/guardian

/obj/effect/proc_holder/spell/self/pocket_dim/Click()
	if(!guardian || !istype(guardian))
		return
	var/mob/living/summoner = guardian.summoner?.current
	if(!guardian.is_deployed())
		to_chat(guardian, "<span class='red bold'>You must be manifested to summon the pocket dimension!</span>")
		return
	var/datum/guardian_ability/major/special/pocket/PD = guardian?.stats?.ability
	if(!PD || !istype(PD))
		return
	var/pocket_z = PD.get_pocket_z()
	if(!pocket_z)
		to_chat(guardian, "<span class='red bold'>ERROR: You do not have a pocket dimension generated! Report this bug on Github!</span>")
		return
	if(PD.manifesting)
		to_chat(guardian, "<span class='red bold'>Wait! Your pocket dimension is currently (de)manifesting!</span>")
		return
	if(guardian.remote_control == PD.eye)
		for(var/V in PD.eye.visibleCameraChunks)
			var/datum/camerachunk/C = V
			C.remove(PD.eye)
		if(guardian.client)
			guardian.reset_perspective(null)
			if(PD.eye.visible_icon)
				guardian.client.images -= PD.eye.user_image
		PD.eye.eye_user = null
		guardian.remote_control = null
	if(LAZYLEN(PD.manifestations))
		guardian.visible_message("<span class='warning'>The distorted space surronding [guardian] is sucked in!</span>")
		var/list/people_to_suck_in = list(guardian)
		if(summoner)
			summoner.AdjustAllImmobility(-100, FALSE)
			summoner.health = max(summoner.health, HEALTH_THRESHOLD_CRIT + 1)
			summoner.update_mobility()
			people_to_suck_in += summoner
			for(var/mob/living/L in summoner.hasparasites())
				people_to_suck_in |= L
		var/real_max = PD.manifested_at_x
		var/real_may = PD.manifested_at_y
		for(var/mob/living/L in people_to_suck_in)
			if(L.x > real_max && L.y > PD.manifested_at_y && L.x < real_max + 8 && L.y < PD.manifested_at_y + 8 && L.z == PD.manifested_at_z)
				var/manifest_at_x = L.x - real_max + 1
				var/manifest_at_y = L.y - real_may + 1
				var/atom/movable/pull = L.pulling
				if(pull && ((isobj(pull) && !pull.anchored) || (isliving(pull) && L.grab_state == GRAB_NECK)))
					pull.forceMove(locate(manifest_at_x, manifest_at_y, pocket_z))
					if(isliving(pull))
						var/mob/living/LL = L
						to_chat(LL, "<span class='danger'>All of existence fades out for a moment...</span>")
						LL.Paralyze(5 SECONDS)
				L.forceMove(locate(manifest_at_x, manifest_at_y, pocket_z))
				PD.add_effects(L)
				if(pull)
					L.start_pulling(pull)
		PD.demanifest_dimension()
		charge_counter = 0
		start_recharge()
		action.UpdateButtonIcon()
	else
		if(get_final_z(guardian) == pocket_z)
			PD.manifest_dimension(TRUE)
			var/list/people_to_suck_out = list(guardian)
			if(summoner)
				people_to_suck_out += summoner
				for(var/mob/living/L in summoner.hasparasites())
					people_to_suck_out |= L
			for(var/mob/living/L in people_to_suck_out)
				var/manifest_at_x = PD.manifested_at_x + L.x - 1
				var/manifest_at_y = PD.manifested_at_y + L.y - 1
				var/atom/movable/pull = L.pulling
				if(pull && ((isobj(pull) && !pull.anchored) || (isliving(pull) && L.grab_state >= GRAB_NECK)))
					pull.forceMove(locate(manifest_at_x, manifest_at_y, PD.manifested_at_z))
					if(pull.alpha == 255)
						pull.alpha = 0
						animate(pull, alpha = 255, time = 3 SECONDS, easing = LINEAR_EASING)
					if(isliving(pull))
						var/mob/living/LL = L
						to_chat(LL, "<span class='danger'>All of existence fades out for a moment...</span>")
						LL.Paralyze(5 SECONDS)
				if(L.alpha == 255)
					L.alpha = 0
					animate(L, alpha = 255, time = 3 SECONDS, easing = LINEAR_EASING)
				PD.take_effects(L)
				L.forceMove(locate(manifest_at_x, manifest_at_y, PD.manifested_at_z))
				if(pull)
					L.start_pulling(pull)
		else
			guardian.visible_message("<span class='warning'>[guardian] emits a burst of energy, distorting the space around it!</span>")
			PD.manifest_dimension()
		charge_counter = max(0, charge_max - 3 SECONDS)
		start_recharge()
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/self/pocket_dim_move
	name = "Dimensional Movement"
	action_icon = 'icons/mob/actions/actions_silicon.dmi'
	action_icon_state = "camera_jump"
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 0
	var/mob/living/simple_animal/hostile/guardian/guardian


/obj/effect/proc_holder/spell/self/pocket_dim_move/cast(list/targets, mob/living/user)
	if(!guardian || !istype(guardian))
		return
	var/datum/guardian_ability/major/special/pocket/PD = guardian?.stats?.ability
	if(!PD || !istype(PD))
		return
	var/pocket_z = PD.get_pocket_z()
	if(!pocket_z)
		to_chat(guardian, "<span class='red bold'>ERROR: You do not have a pocket dimension generated! Report this bug on Github!</span>")
		return
	if(!PD.eye)
		to_chat(guardian, "<span class='red bold'>ERROR: You do not have a camera eye generated! Report this bug on Github!</span>")
		return
	var/turf/T = get_turf(guardian)
	if(T.z != pocket_z)
		to_chat(guardian, "<span class='notice bold'>You must be inside a demanifested pocket dimension to move it!</span>")
		return
	if(PD.manifesting)
		to_chat(guardian, "<span class='red bold'>Wait! Your pocket dimension is currently (de)manifesting!</span>")
		return
	var/mob/camera/aiEye/remote/pocket/eyeobj = PD.eye
	if(eyeobj.eye_user)
		for(var/V in eyeobj.visibleCameraChunks)
			var/datum/camerachunk/C = V
			C.remove(eyeobj)
		if(guardian.client)
			guardian.reset_perspective(null)
			if(eyeobj.visible_icon)
				guardian.client.images -= eyeobj.user_image
		eyeobj.eye_user = null
		guardian.remote_control = null
	else
		give_eye(eyeobj)
		eyeobj.setLoc(locate(PD.manifested_at_x || T.x, PD.manifested_at_y || T.y, PD.manifested_at_z || T.z))

/obj/effect/proc_holder/spell/self/pocket_dim_move/proc/give_eye(mob/camera/aiEye/remote/pocket/eyeobj)
	eyeobj.eye_user = guardian
	eyeobj.name = "Guardian Eye ([guardian.name])"
	guardian.remote_control = eyeobj

/turf/open/indestructible/pocketspace
	name = "interdimensional distortion"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	var/next_animate = 0

/turf/open/indestructible/pocketspace/Initialize()
	. = ..()
	var/X,Y,i,rsq
	for(i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	START_PROCESSING(SSobj, src)
	animate(src, alpha = 127, time = 3 SECONDS, easing = LINEAR_EASING)

/turf/open/indestructible/pocketspace/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/indestructible/pocketspace/process()
	if(next_animate > world.time)
		return
	var/i,f
	for(i=1, i<=7, ++i)
		f = filters[i]
		var/next = rand()*20+10
		animate(f, offset=f:offset, time=0, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=next)
		next_animate = world.time + next

/mob/camera/aiEye/remote/pocket
	name = "Inactive Guardian Eye"
	var/mob/living/simple_animal/hostile/guardian/guardian
	var/pocket_z
	var/datum/guardian_ability/major/special/pocket/PDS

/mob/camera/aiEye/remote/pocket/setLoc()
	. = ..()
	var/turf/T = get_turf(src)
	if(T)
		PDS.manifested_at_x = CLAMP(T.x, 1, world.maxx)
		PDS.manifested_at_y = CLAMP(T.y, 1, world.maxy)
		PDS.manifested_at_z = T.z
		if(pocket_z)
			if(PDS.manifesting || LAZYLEN(PDS.manifestations))
				destroy_pocket_mirror(pocket_z)
			else
				update_pocket_mirror(pocket_z, T.x, T.y, T.z)

/proc/update_pocket_mirror(pocket_z, sx, sy, sz)
	for(var/px = 1 to 7)
		for(var/py = 1 to 7)
			var/turf/open/indestructible/pocketspace/PS = locate(px + 1, py + 1, pocket_z)
			if(PS && istype(PS))
				PS.vis_contents.Cut()
				PS.vis_contents += locate(sx + px, sy + py, sz)

/proc/destroy_pocket_mirror(pocket_z)
	for(var/px = 1 to 7)
		for(var/py = 1 to 7)
			var/turf/open/indestructible/pocketspace/PS = locate(px + 1, py + 1, pocket_z)
			if(PS && istype(PS))
				PS.vis_contents.Cut()

/datum/status_effect/dimensional_mending
	id = "dim_mend"
	duration = -1
	tick_interval = 2
	alert_type = /obj/screen/alert/status_effect/dimensional_mending

/datum/status_effect/dimensional_mending/tick()
	if(!is_pocketdim_level(get_final_z(owner)))
		owner.remove_status_effect(src)
		return
	if(owner.health <= owner.crit_threshold)
		owner.heal_ordered_damage(abs(owner.health - owner.crit_threshold) + 1, list(CLONE, OXY, TOX, BURN, BRUTE, BRAIN, STAMINA))
	owner.AdjustAllImmobility(-100, FALSE)
	owner.stat = CONSCIOUS
	owner.update_mobility()

/datum/status_effect/dimensional_mending/on_apply()
	if(!is_pocketdim_level(get_final_z(owner)))
		return FALSE
	ADD_TRAIT(owner, TRAIT_NODEATH, id)
	ADD_TRAIT(owner, TRAIT_NOCRITDAMAGE, id)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, id)
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, id)
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	return ..()

/datum/status_effect/dimensional_mending/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NODEATH, id)
	REMOVE_TRAIT(owner, TRAIT_NOCRITDAMAGE, id)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, id)
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, id)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)

/obj/screen/alert/status_effect/dimensional_mending
	name = "Dimensional Mending"
	desc = "The very fabrics of reality that comprise this dimension wind themselves through your body, holding you together no matter what."
	icon_state = "dim_mend"
