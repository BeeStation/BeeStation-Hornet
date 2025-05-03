/obj/item/borg/ratvar
	name = "ratvarian borg module"
	desc = "cool."
	icon = 'icons/hud/actions/actions_clockcult.dmi'
	icon_state = "Replicant"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = NOBLUDGEON

	/// The scripture this module invokes
	var/datum/clockcult/scripture/scripture_datum

/obj/item/borg/ratvar/Initialize(mapload)
	. = ..()

	name = scripture_datum.name
	desc = scripture_datum.desc
	icon_state = scripture_datum.button_icon_state

/obj/item/borg/ratvar/attack_self(mob/user)
	..()

	if(!IS_SERVANT_OF_RATVAR(user))
		return
	if(!scripture_datum)
		return
	if(!iscyborg(user))
		return

	var/mob/living/silicon/robot/robot_user = user

	var/obj/item/clockwork/clockwork_slab/internal_slab = robot_user.internal_clock_slab
	if(!internal_slab)
		return

	if(internal_slab.invoking_scripture)
		user.balloon_alert(user, "already invoking scripture!")
		return

	// Time to invoke the scripture
	var/datum/clockcult/scripture/new_scripture = new scripture_datum(internal_slab, bypass_unlock_checks = TRUE)

	//Create a new scripture temporarilly to process, when it's done it will be qdeleted.
	new_scripture.qdel_on_completion = TRUE
	new_scripture.try_to_invoke(user)

/obj/item/borg/ratvar/abscond
	scripture_datum = /datum/clockcult/scripture/abscond

/obj/item/borg/ratvar/kindle
	scripture_datum = /datum/clockcult/scripture/slab/kindle

/obj/item/borg/ratvar/abstraction_crystal
	scripture_datum = /datum/clockcult/scripture/create_structure/abstraction_crystal

/obj/item/borg/ratvar/sentinels_compromise
	scripture_datum = /datum/clockcult/scripture/slab/sentinelscompromise

/obj/item/borg/ratvar/prosperity_prism
	scripture_datum = /datum/clockcult/scripture/create_structure/prosperityprism

/obj/item/borg/ratvar/ocular_warden
	scripture_datum = /datum/clockcult/scripture/create_structure/ocular_warden

/obj/item/borg/ratvar/tinkerers_cache
	scripture_datum = /datum/clockcult/scripture/create_structure/tinkerers_cache

/obj/item/borg/ratvar/stargazer
	scripture_datum = /datum/clockcult/scripture/create_structure/stargazer

/obj/item/borg/ratvar/vanguard
	scripture_datum = /datum/clockcult/scripture/slab/vanguard

/obj/item/borg/ratvar/sigil_submission
	scripture_datum = /datum/clockcult/scripture/create_structure/sigil_submission
