/datum/clockcult/scripture/create_structure/tinkerers_cache
	name = "Tinkerer's Cache"
	desc = "Creates a tinkerer's cache, a powerful forge capable of crafting elite equipment."
	tip = "Use the cache to create more powerful equipment with a cooldown."
	invokation_text = list("Guide my hand and we shall create greatness.")
	invokation_time = 5 SECONDS
	button_icon_state = "Tinkerer's Cache"
	power_cost = 700
	cogs_required = 4
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	category = SPELLTYPE_STRUCTURES

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	name = "tinkerer's cache"
	desc = "A bronze store filled with parts and components."
	clockwork_desc = "A bronze store filled with parts and components. Can be used to forge powerful Ratvarian items."
	icon_state = "tinkerers_cache"
	anchored = TRUE
	break_message = span_warning("The tinkerer's cache melts into a pile of brass.")

	/// How long in between enchants
	var/cooldown_time = 4 MINUTES

	COOLDOWN_DECLARE(craft_cooldown)

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!IS_SERVANT_OF_RATVAR(user))
		to_chat(user, span_warning("You try to put your hand into [src], but almost burn yourself!"))
		return
	if(!anchored)
		balloon_alert(user, "not anchored!")
		return
	if(!COOLDOWN_FINISHED(src, craft_cooldown))
		balloon_alert(user, "on cooldown!")
		return

	// Radial menu to choose what items you want
	var/list/items = list(
		"Robes of Divinity" = image(icon = 'icons/obj/clothing/clockwork_garb.dmi', icon_state = "clockwork_cuirass_speed"),
		"Shrouding Cloak" = image(icon = 'icons/obj/clothing/clockwork_garb.dmi', icon_state = "clockwork_cloak"),
		"Wraith Spectacles" = image(icon = 'icons/obj/clothing/clockwork_garb.dmi', icon_state = "wraith_specs")
	)

	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!choice)
		return

	var/obj/item/clothing/picked
	switch(choice)
		if("Robes of Divinity")
			picked = /obj/item/clothing/suit/clockwork/speed
		if("Shrouding Cloak")
			picked = /obj/item/clothing/suit/clockwork/cloak
		if("Wraith Spectacles")
			picked = /obj/item/clothing/glasses/clockwork/wraith_spectacles

	// Spawn item and start cooldown
	new picked(get_turf(src))

	balloon_alert(user, "[choice] crafted!")

	COOLDOWN_START(src, craft_cooldown, cooldown_time)

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE
