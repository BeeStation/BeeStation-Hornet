GLOBAL_LIST_EMPTY(active_alternate_appearances)


/atom
	var/list/alternate_appearances

/atom/proc/remove_alt_appearance(key)
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			if(AA.appearance_key == key)
				AA.remove_from_hud(src)
				break

/atom/proc/add_alt_appearance(type, key, ...)
	if(!type || !key)
		return
	if(alternate_appearances && alternate_appearances[key])
		return
	var/list/arguments = args.Copy(2)
	return new type(arglist(arguments))

/mob/proc/update_alt_appearances()
	for (var/datum/atom_hud/alternate_appearance/alt_appearance in GLOB.active_alternate_appearances)
		if (alt_appearance.mobShouldSee(src))
			// If we don't see it already, then add it
			if (!alt_appearance.hudusers[src])
				alt_appearance.add_hud_to(src)
		else
			alt_appearance.remove_hud_from(src)

/datum/atom_hud/alternate_appearance
	var/appearance_key
	var/transfer_overlays = FALSE

/datum/atom_hud/alternate_appearance/New(key)
	..()
	GLOB.active_alternate_appearances += src
	appearance_key = key

/datum/atom_hud/alternate_appearance/Destroy()
	GLOB.active_alternate_appearances -= src
	return ..()

/datum/atom_hud/alternate_appearance/proc/onNewMob(mob/M)
	if(mobShouldSee(M))
		add_hud_to(M)

/datum/atom_hud/alternate_appearance/proc/mobShouldSee(mob/M)
	return FALSE

/datum/atom_hud/alternate_appearance/add_to_hud(atom/A, image/I)
	. = ..()
	if(.)
		LAZYINITLIST(A.alternate_appearances)
		A.alternate_appearances[appearance_key] = src

/datum/atom_hud/alternate_appearance/remove_from_hud(atom/A)
	. = ..()
	if(.)
		LAZYREMOVE(A.alternate_appearances, appearance_key)

/datum/atom_hud/alternate_appearance/proc/copy_overlays(atom/other, cut_old)
	return

//an alternate appearance that attaches a single image to a single atom
/datum/atom_hud/alternate_appearance/basic
	var/atom/target
	var/image/theImage
	var/add_ghost_version = FALSE
	var/ghost_appearance

/datum/atom_hud/alternate_appearance/basic/New(key, image/I, options = AA_TARGET_SEE_APPEARANCE)
	..()
	transfer_overlays = options & AA_MATCH_TARGET_OVERLAYS
	theImage = I
	target = I.loc
	if(transfer_overlays)
		I.copy_overlays(target)

	hud_icons = list(appearance_key)
	add_to_hud(target, I)
	if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
		add_hud_to(target)
	if(add_ghost_version)
		var/image/ghost_image = image(icon = I.icon , icon_state = I.icon_state, loc = I.loc)
		ghost_image.override = FALSE
		ghost_image.alpha = 128
		ghost_appearance = new /datum/atom_hud/alternate_appearance/basic/observers(key + "_observer", ghost_image, NONE)

/datum/atom_hud/alternate_appearance/basic/Destroy()
	. = ..()
	if(ghost_appearance)
		QDEL_NULL(ghost_appearance)

/datum/atom_hud/alternate_appearance/basic/add_to_hud(atom/A)
	LAZYINITLIST(A.hud_list)
	A.hud_list[appearance_key] = theImage
	. = ..()

/datum/atom_hud/alternate_appearance/basic/remove_from_hud(atom/A)
	. = ..()
	if(!.)
		return
	A.hud_list -= appearance_key
	if(!QDELETED(src))
		qdel(src)

/datum/atom_hud/alternate_appearance/basic/copy_overlays(atom/other, cut_old)
	theImage.copy_overlays(other, cut_old)

/datum/atom_hud/alternate_appearance/basic/everyone
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/everyone/New()
	..()
	for(var/mob in GLOB.mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/everyone/mobShouldSee(mob/M)
	return !isobserver(M)

/datum/atom_hud/alternate_appearance/basic/silicons

/datum/atom_hud/alternate_appearance/basic/silicons/New()
	..()
	for(var/mob as anything in GLOB.silicon_mobs)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/silicons/mobShouldSee(mob/M)
	if(issilicon(M))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/observers
	add_ghost_version = FALSE //just in case, to prevent infinite loops

/datum/atom_hud/alternate_appearance/basic/observers/New()
	..()
	for(var/mob in GLOB.dead_mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/observers/mobShouldSee(mob/M)
	return isobserver(M)

/datum/atom_hud/alternate_appearance/basic/noncult

/datum/atom_hud/alternate_appearance/basic/noncult/New()
	..()
	for(var/mob in GLOB.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/noncult/mobShouldSee(mob/M)
	if(!IS_CULTIST(M))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/cult

/datum/atom_hud/alternate_appearance/basic/cult/New()
	..()
	for(var/mob in GLOB.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/cult/mobShouldSee(mob/M)
	if(IS_CULTIST(M))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/blessedAware

/datum/atom_hud/alternate_appearance/basic/blessedAware/New()
	..()
	for(var/mob in GLOB.mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/blessedAware/mobShouldSee(mob/M)
	if(M.mind && M.mind?.holy_role)
		return TRUE
	if (IS_CULTIST(M))
		return TRUE
	if(isrevenant(M) || IS_WIZARD(M))
		return TRUE
	if (HAS_TRAIT(M, TRAIT_SEE_ANTIMAGIC))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/one_person
	var/datum/weakref/seer

/datum/atom_hud/alternate_appearance/basic/one_person/mobShouldSee(mob/M)
	var/mob/seer_reference = seer.resolve()
	if (!seer_reference)
		qdel(src)
		return FALSE
	if(M == seer_reference)
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/one_person/New(key, image/I, mob/living/M)
	..(key, I, FALSE)
	seer = WEAKREF(M)
	add_hud_to(seer)

/datum/atom_hud/alternate_appearance/basic/minds
	var/list/seers

/datum/atom_hud/alternate_appearance/basic/minds/mobShouldSee(mob/M)
	if(M.mind in seers)
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/minds/New(key, image/I, list/minds)
	..(key, I, FALSE)
	seers = list()
	for (var/datum/mind/mind in minds)
		seers += mind
		add_hud_to(mind.current)

/datum/atom_hud/alternate_appearance/basic/heretics
	add_ghost_version = FALSE //just in case, to prevent infinite loops

/datum/atom_hud/alternate_appearance/basic/heretics/New()
	..()
	for(var/mob in  GLOB.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/heretics/mobShouldSee(mob/M)
	return IS_HERETIC(M) || IS_HERETIC_MONSTER(M)

/datum/atom_hud/alternate_appearance/basic/mimites/New()
	..()
	for(var/mob in  GLOB.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/mimites/mobShouldSee(mob/M)
	return ismimite(M) || isobserver(M)
