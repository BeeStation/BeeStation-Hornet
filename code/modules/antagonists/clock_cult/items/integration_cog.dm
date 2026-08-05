/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cog that seems to spin by its own acord when left alone."
	icon_state = "integration_cog"
	clockwork_desc = span_brass("A sharp cog that can cut through and be inserted into APCs to extract power for the gateway.")
	item_flags = ISWEAPON

/obj/item/clockwork/integration_cog/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(!IS_SERVANT_OF_RATVAR(user))
		return ..()
	if(!istype(attacked_atom, /obj/machinery/power/apc))
		return ..()

	var/obj/machinery/power/apc/target_apc = attacked_atom

	if(target_apc.integration_cog)
		to_chat(user, span_brass("There is already \an [src] in \the [target_apc]."))
		return

	// Cut open APC
	if(!target_apc.panel_open)
		user.balloon_alert(user, "cutting open APC...")
		if(!do_after(user, 5 SECONDS, target=target_apc))
			return

		user.balloon_alert(user, "APC cut open")
		target_apc.panel_open = TRUE
		target_apc.update_icon()
		return

	// Insert the cog
	user.balloon_alert(user, "inserting [src]...")
	if(!do_after(user, 4 SECONDS, target = target_apc))
		user.balloon_alert(user, "interrupted!")
		return

	user.balloon_alert(user, "integration cog inserted")
	playsound(get_turf(user), 'sound/machines/clockcult/integration_cog_install.ogg', 20)

	// Put cog inside APC
	target_apc.integration_cog = src
	forceMove(target_apc)
	target_apc.panel_open = FALSE
	target_apc.update_icon()


	if(!target_apc.clock_cog_rewarded)
		GLOB.installed_integration_cogs++
		target_apc.clock_cog_rewarded = TRUE

		hierophant_message("<b>[user]</b> has installed an integration cog into \an [target_apc]", span="<span class='nzcrentr'>", use_sanitisation = FALSE)

		// Update cog counts
		for(var/obj/item/clockwork/clockwork_slab/slab in GLOB.clockwork_slabs)
			slab.cogs++

		if(GLOB.clockcult_eminence)
			var/mob/living/simple_animal/eminence/eminence = GLOB.clockcult_eminence
			eminence.cogs++
