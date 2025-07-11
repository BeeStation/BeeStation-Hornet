//==================================//
// !      Tinkerer's Cache     ! //
//==================================//
/datum/clockcult/scripture/create_structure/tinkerers_cache
	name = "Tinkerer's Cache"
	desc = "Creates a tinkerer's cache, a powerful forge capable of crafting elite equipment."
	tip = "Use the cache to create more powerful equipment with a cooldown."
	button_icon_state = "Tinkerer's Cache"
	power_cost = 700
	invokation_time = 50
	invokation_text = list("Guide my hand and we shall create greatness.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES

//===============
//Tinkerer's Cache Structure
//===============

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	name = "tinkerer's cache"
	desc = "A bronze store filled with parts and components."
	clockwork_desc = "A bronze store filled with parts and components. Can be used to forge powerful Ratvarian items."
	default_icon_state = "tinkerers_cache"
	anchored = TRUE
	break_message = span_warning("The tinkerer's cache melts into a pile of brass.")
	var/cooldowntime = 0

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!IS_SERVANT_OF_RATVAR(user))
		to_chat(user, span_warning("You try to put your hand into [src], but almost burn yourself!"))
		return
	if(!anchored)
		to_chat(user, span_brass("You need to anchor [src] to the floor first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_brass("[src] is still warming up, it will be ready in [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/choice = alert(user,"You begin putting components together in the forge.",,"Robes of Divinity","Shrouding Cloak","Wraith Spectacles")
	var/list/pickedtype = list()
	switch(choice)
		if("Robes of Divinity")
			pickedtype += /obj/item/clothing/suit/clockwork/speed
		if("Shrouding Cloak")
			pickedtype += /obj/item/clothing/suit/clockwork/cloak
		if("Wraith Spectacles")
			pickedtype += /obj/item/clothing/glasses/clockwork/wraith_spectacles
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && IS_SERVANT_OF_RATVAR(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_brass("You craft a [choice] to near perfection, [src] burning down."))

