/obj/item/clockwork/clockwork_slab
	name = "Clockwork Slab"
	desc = "A mechanical-looking device filled with intricate cogs that swirl to their own accord."
	clockwork_desc = "A beautiful work of art, harnessing mechanical energy for a variety of useful powers."
	icon_state = "dread_ipad"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'

	var/datum/clockcult/scripture/invoking_scripture
	var/datum/progressbar/invokation_bar

	var/holder_class
	var/list/scriptures = list()

	var/charge_overlay

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
		/datum/clockcult/scripture/slab/kindle,
		/datum/clockcult/scripture/slab/hateful_manacles,
		/datum/clockcult/scripture/create_structure/sigil_submission,
		/datum/clockcult/scripture/ark_activation
	)

/obj/item/clockwork/clockwork_slab/Initialize()
	var/pos = 1
	for(var/script in default_scriptures)
		if(!script)
			continue
		var/datum/clockcult/scripture/default_script = new script
		message_admins("Assigning [default_script.name] to [name]")
		bind_spell(null, default_script, pos++)
	..()

/obj/item/clockwork/clockwork_slab/dropped(mob/user)
	//Clear quickbinds
	for(var/datum/action/innate/clockcult/quick_bind/script in quick_bound_scriptures)
		script.Remove(user)
	. = ..()

/obj/item/clockwork/clockwork_slab/pickup(mob/user)
	. = ..()
	//Grant quickbound spells
	for(var/datum/action/innate/clockcult/quick_bind/script in quick_bound_scriptures)
		message_admins("Granting [script.name] to [user.ckey]")
		script.Grant(user)

/obj/item/clockwork/clockwork_slab/update_icon()
	. = ..()
	cut_overlays()
	if(charge_overlay)
		add_overlay(charge_overlay)

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
	ui_interact(user)

/obj/item/clockwork/clockwork_slab/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ClockworkSlab", name, 800, 420, master_ui, state)
		ui.set_autoupdate(FALSE) //we'll update this occasionally, but not as often as possible
		ui.open()

/obj/item/clockwork/clockwork_slab/ui_static_data(mob/user)
	var/list/data = list()
	data["servant_classes"] = GLOB.servant_classes
	return data

/obj/item/clockwork/clockwork_slab/ui_act(action, params)
	switch(action)
		if("setClass")
			var/mob/living/M = usr
			if(!istype(M))
				return FALSE
			var/datum/antagonist/servant_of_ratvar/S = is_servant_of_ratvar(M)
			if(!S)
				return FALSE
			if(S.servant_class != /datum/clockcult/servant_class)
				return FALSE
			S.servant_class = params["class"]
			to_chat(usr, "<span class='brass'>You call upon [S.servant_class.class_name] and are blessed with their knowledge and might!</span>")
			return TRUE
