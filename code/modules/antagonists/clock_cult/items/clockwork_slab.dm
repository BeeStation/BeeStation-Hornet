GLOBAL_LIST_INIT(clockwork_slabs, list())

/obj/item/clockwork/clockwork_slab
	name = "Clockwork Slab"
	desc = "A mechanical-looking device filled with intricate cogs that swirl to their own accord."
	clockwork_desc = span_brass("A beautiful work of art, harnessing mechanical energy for a variety of useful powers.")
	icon_state = "dread_ipad"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	item_flags = NOBLUDGEON

	/// The scripture currently being invoked
	var/datum/clockcult/scripture/invoking_scripture
	/// The current slab empowerment scripture being invoked
	var/datum/clockcult/scripture/slab/active_scripture
	/// A list of all the scriptures this slab has unlocked
	var/list/scriptures = list()
	/// A list of quickbound actions that are linked to scriptures
	var/list/quick_bound_scriptures = list()
	/// The max amount of quickbinds a slab can have
	var/max_quickbind_slots = 5
	/// The current overlay that the active scripture has
	var/charge_overlay
	/// Total number of integration cogs the clock cult has made
	var/cogs = 0
	/// Reference to the trap that we are linking
	var/datum/component/clockwork_trap/buffer

	/// List of default scriptures, these get quickbinds
	var/static/list/default_scriptures = list(
		/datum/clockcult/scripture/abscond,
		/datum/clockcult/scripture/integration_cog,
		/datum/clockcult/scripture/clockwork_armaments
	)

/obj/item/clockwork/clockwork_slab/Initialize(mapload)
	. = ..()
	if(!length(GLOB.clockcult_all_scriptures))
		generate_clockcult_scriptures()

	// Get current cog count and add ourselves to the list of slabs
	cogs = GLOB.installed_integration_cogs

	GLOB.clockwork_slabs += src

	// Set default scriptures
	for(var/datum/clockcult/scripture/scripture_type as anything in default_scriptures)
		var/datum/clockcult/scripture/default_scripture = new scripture_type(src)
		scriptures[scripture_type] = default_scripture

		bind_spell(binder = null, scripture = default_scripture)

/obj/item/clockwork/clockwork_slab/Destroy()
	GLOB.clockwork_slabs -= src
	return ..()

/obj/item/clockwork/clockwork_slab/dropped(mob/user)
	. = ..()
	// Clear quickbinds
	for(var/datum/action/innate/clockcult/quick_bind/bind in quick_bound_scriptures)
		bind.Remove(user)

	// Clear slab empowerment and buffer
	if(active_scripture)
		active_scripture.end_invocation()

	if(buffer)
		buffer = null

/obj/item/clockwork/clockwork_slab/pickup(mob/user)
	if(!IS_SERVANT_OF_RATVAR(user))
		return
	. = ..()

	// Grant quickbound spells
	for(var/datum/action/innate/clockcult/quick_bind/script in quick_bound_scriptures)
		script.Grant(user)

	user.update_action_buttons()

/obj/item/clockwork/clockwork_slab/update_icon()
	. = ..()
	cut_overlays()
	if(charge_overlay)
		add_overlay(charge_overlay)

/obj/item/clockwork/clockwork_slab/proc/bind_spell(mob/living/binder, datum/clockcult/scripture/scripture)
	// Check if we already have this scripture bound, if so, unbind it
	for(var/datum/action/innate/clockcult/quick_bind/bind in quick_bound_scriptures)
		if(bind.scripture.type == scripture.type)
			quick_bound_scriptures -= bind
			bind.Remove(binder)
			return

	if(length(quick_bound_scriptures) >= max_quickbind_slots)
		if(binder)
			var/response = tgui_input_list(binder, "Scripture to unbind", "Quickbound Scriptures", quick_bound_scriptures)
			if(!response)
				return

			quick_bound_scriptures -= response
			quick_bound_scriptures.Remove(binder)
		else
			return

	// Instantiate the quickbind and add to list of other quickbound scriptures
	var/datum/action/innate/clockcult/quick_bind/quickbound = new(scripture, src)
	quick_bound_scriptures += quickbound

	// Give our binder the quickbind
	if(binder)
		quickbound.Grant(binder)

/obj/item/clockwork/clockwork_slab/attack_self(mob/living/user)
	. = ..()
	// Blood cultist reaction
	if(IS_CULTIST(user))
		to_chat(user, span_bigbrass("You shouldn't be playing with my toys..."))
		user.Stun(6 SECONDS)
		user.adjust_blindness(15 SECONDS)
		user.electrocute_act(10, name)
		return
	// Non clock-cultist reaction
	if(!IS_SERVANT_OF_RATVAR(user))
		to_chat(user, span_warning("You cannot figure out what the device is used for!"))
		return

	// Clear slab empowerement
	if(active_scripture)
		active_scripture.end_invocation()
		return
	if(buffer)
		buffer = null
		to_chat(user, span_brass("You clear the [src]'s buffer."))
		return
	ui_interact(user)

/obj/item/clockwork/clockwork_slab/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClockworkSlab")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/clockwork/clockwork_slab/ui_state(mob/user)
	return GLOB.clockcult_held_state

/obj/item/clockwork/clockwork_slab/ui_data(mob/user)
	var/list/data = list()

	data["cogs"] = cogs
	data["vitality"] = GLOB.clockcult_vitality
	data["power"] = GLOB.clockcult_power
	data["scriptures"] = list()

	//2 scriptures accessable at the same time will cause issues
	for(var/scripture_type in GLOB.clockcult_all_scriptures)
		var/datum/clockcult/scripture/scripture_instance = GLOB.clockcult_all_scriptures[scripture_type]

		var/list/scripture_data = list(
			"name" = scripture_instance.name,
			"desc" = scripture_instance.desc,
			"type" = scripture_instance.category,
			"tip" = scripture_instance.tip,
			"cost" = scripture_instance.power_cost,
			"purchased" = !!scriptures[scripture_type],
			"cog_cost" = scripture_instance.cogs_required,
		)

		data["scriptures"] += list(scripture_data)
	return data

/obj/item/clockwork/clockwork_slab/ui_act(action, params)
	if(!isliving(usr))
		return FALSE

	var/mob/living/living_user = usr

	switch(action)
		if("invoke")
			var/datum/clockcult/scripture/chosen_scripture = GLOB.clockcult_all_scriptures[params["scriptureName"]]
			if(!chosen_scripture)
				return FALSE

			if(scriptures[chosen_scripture.type])
				// We have the scripture unlocked, lets try to invoke it
				if(invoking_scripture)
					living_user.balloon_alert(living_user, "already invoking [invoking_scripture]!")
					return FALSE

				var/datum/clockcult/scripture/target_scripture = scriptures[chosen_scripture.type]
				target_scripture.try_to_invoke(living_user)
			else
				// Try to purchase scripture
				if(cogs >= chosen_scripture.cogs_required)
					cogs -= chosen_scripture.cogs_required

					// Add scripture
					var/datum/clockcult/scripture/new_scripture = new chosen_scripture.type(src)
					scriptures[chosen_scripture.type] = new_scripture

					living_user.balloon_alert(living_user, "[chosen_scripture] purchased!")
					log_game("[chosen_scripture.name] purchased by [ADMIN_LOOKUP(living_user)] for [chosen_scripture.cogs_required] cogs, [cogs] cogs remaining.")
				else
					living_user.balloon_alert(living_user, "not enough cogs!")

			return TRUE

		if("quickbind")
			var/datum/clockcult/scripture/chosen_scripture = GLOB.clockcult_all_scriptures[params["scriptureName"]]
			if(!chosen_scripture)
				return FALSE

			// Make sure we actually have the scripture unlocked
			if(!scriptures[chosen_scripture.type])
				return FALSE

			// Bind scripture
			var/datum/clockcult/scripture/target_scripture = scriptures[chosen_scripture.type]
			bind_spell(living_user, target_scripture)
