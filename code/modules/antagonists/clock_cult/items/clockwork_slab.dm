GLOBAL_LIST_INIT(clockwork_slabs, list())

/obj/item/clockwork/clockwork_slab
	name = "Clockwork Slab"
	desc = "A mechanical-looking device filled with intricate cogs that swirl to their own accord."
	clockwork_desc = "A beautiful work of art, harnessing mechanical energy for a variety of useful powers."
	item_flags = NOBLUDGEON
	icon_state = "dread_ipad"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'

	var/datum/clockcult/scripture/invoking_scripture	//The scripture currently being invoked
	var/datum/clockcult/scripture/slab/active_scripture		//For scriptures that power the slab
	var/datum/progressbar/invokation_bar

	var/holder_class
	var/list/scriptures = list()

	var/charge_overlay

	var/calculated_cogs = 0
	var/cogs = 0
	var/list/purchased_scriptures = list(
		/datum/clockcult/scripture/ark_activation
	)

	//Initialise an empty list for quickbinding
	var/list/quick_bound_scriptures = list(
		1 = null,
		2 = null,
		3 = null,
		4 = null,
		5 = null
	)

	//The default scriptures that get auto-assigned.
	var/list/default_scriptures = list(
		/datum/clockcult/scripture/abscond,
		/datum/clockcult/scripture/integration_cog,
		/datum/clockcult/scripture/clockwork_armaments
	)

	//For trap linkage
	var/datum/component/clockwork_trap/buffer

/obj/item/clockwork/clockwork_slab/Initialize()
	if(!length(GLOB.clockcult_all_scriptures))
		generate_clockcult_scriptures()
	var/pos = 1
	cogs = GLOB.installed_integration_cogs
	GLOB.clockwork_slabs += src
	for(var/script in default_scriptures)
		if(!script)
			continue
		purchased_scriptures += script
		var/datum/clockcult/scripture/default_script = new script
		bind_spell(null, default_script, pos++)
	..()

/obj/item/clockwork/clockwork_slab/dropped(mob/user)
	//Clear quickbinds
	for(var/datum/action/innate/clockcult/quick_bind/script in quick_bound_scriptures)
		script.Remove(user)
	if(active_scripture)
		active_scripture.end_invokation()
	if(buffer)
		buffer = null
	. = ..()

/obj/item/clockwork/clockwork_slab/pickup(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	//Grant quickbound spells
	for(var/datum/action/innate/clockcult/quick_bind/script in quick_bound_scriptures)
		script.Grant(user)
	user.update_action_buttons()

/obj/item/clockwork/clockwork_slab/update_icon()
	. = ..()
	cut_overlays()
	if(charge_overlay)
		add_overlay(charge_overlay)

/obj/item/clockwork/clockwork_slab/proc/update_integration_cogs()
	//Calculate cogs
	if(calculated_cogs != GLOB.installed_integration_cogs)
		var/difference = GLOB.installed_integration_cogs - calculated_cogs
		calculated_cogs += difference
		cogs += difference

//==================================//
// !   Quick bind spell handling  ! //
//==================================//

/obj/item/clockwork/clockwork_slab/proc/bind_spell(mob/living/M, datum/clockcult/scripture/spell, position = 1)
	if(position > quick_bound_scriptures.len || position <= 0)
		return
	if(quick_bound_scriptures[position])
		//Unbind the scripture that is quickbound
		qdel(quick_bound_scriptures[position])
	//Put the quickbound action onto the slab, the slab should grant when picked up
	var/datum/action/innate/clockcult/quick_bind/quickbound = new
	quickbound.scripture = spell
	quickbound.activation_slab = src
	quick_bound_scriptures[position] = quickbound
	if(M)
		quickbound.Grant(M)

//==================================//
// ! UI HANDLING BELOW THIS POINT ! //
//==================================//
/obj/item/clockwork/clockwork_slab/attack_self(mob/living/user)
	. = ..()
	if(iscultist(user))
		to_chat(user, "<span class='big_brass'>You shouldn't be playing with my toys...</span>")
		user.Stun(60)
		user.adjust_blindness(150)
		user.electrocute_act(10, "[name]")
		return
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>You cannot figure out what the device is used for!</span>")
		return
	if(active_scripture)
		active_scripture.end_invokation()
		return
	if(buffer)
		buffer = null
		to_chat(user, "<span class='brass'>You clear the [src]'s buffer.</span>")
		return
	ui_interact(user)

/obj/item/clockwork/clockwork_slab/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClockworkSlab")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/clockwork/clockwork_slab/ui_state(mob/user)
	return GLOB.clockcult_state

/obj/item/clockwork/clockwork_slab/ui_data(mob/user)
	//Data
	var/list/data = list()
	data["cogs"] = cogs
	data["vitality"] = GLOB.clockcult_vitality
	data["power"] = GLOB.clockcult_power
	data["scriptures"] = list()
	//2 scriptures accessable at the same time will cause issues
	for(var/scripture_name in GLOB.clockcult_all_scriptures)
		var/datum/clockcult/scripture/scripture = GLOB.clockcult_all_scriptures[scripture_name]
		var/list/S = list(
			"name" = scripture.name,
			"desc" = scripture.desc,
			"type" = scripture.category,
			"tip" = scripture.tip,
			"cost" = scripture.power_cost,
			"purchased" = (scripture.type in purchased_scriptures),
			"cog_cost" = scripture.cogs_required
		)
		//Add it to the correct list
		data["scriptures"] += list(S)
	return data

/obj/item/clockwork/clockwork_slab/ui_act(action, params)
	var/mob/living/M = usr
	if(!istype(M))
		return FALSE
	switch(action)
		if("invoke")
			var/datum/clockcult/scripture/S = GLOB.clockcult_all_scriptures[params["scriptureName"]]
			if(!S)
				return FALSE
			if(S.type in purchased_scriptures)
				if(invoking_scripture)
					to_chat(M, "<span class='brass'>You fail to invoke [name].</span>")
					return FALSE
				if(S.power_cost > GLOB.clockcult_power)
					to_chat(M, "<span class='neovgre'>You need [S.power_cost]W to invoke [S.name].</span>")
					return FALSE
				if(S.vitality_cost > GLOB.clockcult_vitality)
					to_chat(M, "<span class='neovgre'>You need [S.vitality_cost] vitality to invoke [S.name].</span>")
					return FALSE
				var/datum/clockcult/scripture/new_scripture = new S.type()
				//Create a new scripture temporarilly to process, when it's done it will be qdeleted.
				new_scripture.qdel_on_completion = TRUE
				new_scripture.begin_invoke(M, src)
			else
				if(cogs >= S.cogs_required)
					cogs -= S.cogs_required
					to_chat(M, "<span class='brass'>You unlocked [S.name]. It can now be invoked and quickbound through your slab.</span>")
					purchased_scriptures += S.type
				else
					to_chat(M, "<span class='brass'>You need [S.cogs_required] cogs to unlock [S.name], you only have [cogs] left!</span>")
					to_chat(M, "<span class='brass'><b>Tip:</b> Invoke integration cog and insert the cog into APCs to get more.</span>")
			return TRUE
		if("quickbind")
			var/datum/clockcult/scripture/S = GLOB.clockcult_all_scriptures[params["scriptureName"]]
			if(!S)
				return FALSE
			var/list/positions = list()
			for(var/i in 1 to 5)
				var/datum/clockcult/scripture/QB = quick_bound_scriptures[i]
				if(!QB)
					positions += "([i])"
				else
					positions += "([i]) - [QB.name]"
			var/position = input("Where to quickbind to?", "Quickbind Slot", null) as null|anything in positions
			if(!position)
				return FALSE
			//Create and assign the quickbind
			var/datum/clockcult/scripture/new_scripture = new S.type()
			bind_spell(M, new_scripture, positions.Find(position))
