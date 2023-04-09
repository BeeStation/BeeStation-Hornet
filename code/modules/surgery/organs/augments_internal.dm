
/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

/obj/item/organ/cyberimp/New(var/mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()



//[[[[BRAIN]]]]

/obj/item/organ/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "Injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/brain/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/stun_amount = 200/severity
	owner.Stun(stun_amount)
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")


/obj/item/organ/cyberimp/brain/anti_drop
	name = "anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = 0
	var/list/stored_items = list()
	implant_color = "#DE7E00"
	slot = ORGAN_SLOT_BRAIN_ANTIDROP
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		for(var/obj/item/I in owner.held_items)
			stored_items += I

		var/list/L = owner.get_empty_held_indexes()
		if(LAZYLEN(L) == owner.held_items.len)
			to_chat(owner, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = 0
			stored_items = list()
		else
			for(var/obj/item/I in stored_items)
				to_chat(owner, "<span class='notice'>Your [owner.get_held_index_name(owner.get_held_index_of_item(I))]'s grip tightens.</span>")
				ADD_TRAIT(I, TRAIT_NODROP, ANTI_DROP_IMPLANT_TRAIT)

	else
		release_items()
		to_chat(owner, "<span class='notice'>Your hands relax...</span>")


/obj/item/organ/cyberimp/brain/anti_drop/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	if(active)
		release_items()
	for(var/obj/item/I in stored_items)
		A = pick(oview(range))
		I.throw_at(A, range, 2)
		to_chat(owner, "<span class='warning'>Your [owner.get_held_index_name(owner.get_held_index_of_item(I))] spasms and throws the [I.name]!</span>")
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/proc/release_items()
	for(var/obj/item/I in stored_items)
		REMOVE_TRAIT(I, TRAIT_NODROP, ANTI_DROP_IMPLANT_TRAIT)
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/Remove(var/mob/living/carbon/M, special = 0)
	if(active)
		ui_action_click()
	..()

/obj/item/organ/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	slot = ORGAN_SLOT_BRAIN_ANTISTUN

	var/static/list/signalCache = list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_PARALYZE,
	)

	var/stun_cap_amount = 40

/obj/item/organ/cyberimp/brain/anti_stun/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	UnregisterSignal(M, signalCache)

/obj/item/organ/cyberimp/brain/anti_stun/Insert()
	. = ..()
	RegisterSignal(owner, signalCache, PROC_REF(on_signal))

/obj/item/organ/cyberimp/brain/anti_stun/proc/on_signal(datum/source, amount)
	SIGNAL_HANDLER

	if(!(organ_flags & ORGAN_FAILING) && amount > 0)
		addtimer(CALLBACK(src, PROC_REF(clear_stuns)), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/cyberimp/brain/anti_stun/proc/clear_stuns()
	if(owner || !(organ_flags & ORGAN_FAILING))
		owner.SetStun(0)
		owner.SetKnockdown(0)
		owner.SetImmobilized(0)
		owner.SetParalyzed(0)

/obj/item/organ/cyberimp/brain/anti_stun/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/cyberimp/brain/anti_stun/proc/reboot()
	organ_flags &= ~ORGAN_FAILING

/obj/item/organ/cyberimp/brain/anti_stun/syndicate
	syndicate_implant = TRUE


/obj/item/organ/cyberimp/brain/linkedsurgery
	name = "surgical serverlink brain implant"
	desc = "A brain implant with a bluespace technology that lets you perform an advanced surgery through your station research server."
	slot = ORGAN_SLOT_BRAIN_SURGICAL_IMPLANT
	actions_types = list(/datum/action/item_action/update_linkedsurgery)
	var/list/advanced_surgeries = list()
	var/static/datum/techweb/linked_techweb
	var/number_of_surgeries

/obj/item/organ/cyberimp/brain/linkedsurgery/Initialize()
	. = ..()
	if(isnull(linked_techweb))
		linked_techweb = SSresearch.science_tech
	number_of_surgeries = 0

/obj/item/organ/cyberimp/brain/linkedsurgery/proc/update_surgery()
	var/list/old_advanced_surgeries = advanced_surgeries.Copy()
	advanced_surgeries.Cut()
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/surgery/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		advanced_surgeries += D.surgery
	for(var/held_item in owner.held_items)
		if(!held_item)
			continue
		var/list/surgeries_to_add = list()
		var/new_surgeries = 0
		if(istype(held_item, /obj/item/disk/surgery))
			var/obj/item/disk/surgery/surgery_disk = held_item
			for(var/surgery in surgery_disk.surgeries)
				if(!(surgery in old_advanced_surgeries) && !(surgery in advanced_surgeries))
					surgeries_to_add |= surgery
					new_surgeries++
		else if(istype(held_item, /obj/item/disk/tech_disk))
			var/obj/item/disk/tech_disk/tech_disk = held_item
			for(var/D in tech_disk.stored_research.researched_designs)
				var/datum/design/surgery/surgery_design = SSresearch.techweb_design_by_id(D)
				if(!istype(surgery_design))
					continue
				if(!(surgery_design.surgery in old_advanced_surgeries) && !(surgery_design.surgery in advanced_surgeries))
					surgeries_to_add |= surgery_design.surgery
					new_surgeries++
		else if(istype(held_item, /obj/item/disk/nuclear))
			// funny joke message
			to_chat(owner, "<span class='warning'>Do you <i>want</i> to explode? You can't get surgery data from \the [held_item]!</span>")
			continue
		else
			continue
		var/hand_name = owner.get_held_index_name(owner.get_held_index_of_item(held_item))
		if(!new_surgeries)
			to_chat(owner, "<span class='notice'>No new surgical programs detected on \the [held_item] in your [hand_name].</span>")
			continue
		to_chat(owner, "<span class='notice'><b>[new_surgeries]</b> new surgical program\s detected on \the [held_item] in your [hand_name]! Please hold still while the surgical program is being downloaded...</span>")
		if(!do_after(owner, 5 SECONDS, held_item))
			to_chat(owner, "<span class='warning'>Surgical program transfer interrupted!</span>")
			return
		to_chat(owner, "<span class='notice'><b>[new_surgeries]</b> new surgical program\s were transferred from \the [held_item] in your [hand_name] to \the [src]!</span>")
		advanced_surgeries |= surgeries_to_add

/obj/item/organ/cyberimp/brain/linkedsurgery/proc/check_surgery_update()
	if(number_of_surgeries<length(advanced_surgeries))
		to_chat(usr, "<span class='notice'>Surgical Implant updated.</span>")
		number_of_surgeries = length(advanced_surgeries)
	else
		to_chat(usr, "<span class='notice'>None of new surgical programs detected.</span>")

/datum/action/item_action/update_linkedsurgery
	name = "Update Surgical Implant"

/datum/action/item_action/update_linkedsurgery/Trigger()
	if(istype(target, /obj/item/organ/cyberimp/brain/linkedsurgery))
		var/obj/item/organ/cyberimp/brain/linkedsurgery/I = target
		I.update_surgery()
		I.check_surgery_update()
	return ..()

//[[[[MOUTH]]]]
/obj/item/organ/cyberimp/mouth
	zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/mouth/breathing_tube/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(60/severity))
		to_chat(owner, "<span class='warning'>Your breathing tube suddenly closes!</span>")
		owner.losebreath += 2

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implants"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"
	var/list/boxed = list(
		/obj/item/autosurgeon/syndicate/thermal_eyes,
		/obj/item/autosurgeon/syndicate/xray_eyes,
		/obj/item/autosurgeon/syndicate/anti_stun,
		/obj/item/autosurgeon/syndicate/reviver)
	var/amount = 5

/obj/item/storage/box/cyber_implants/PopulateContents()
	var/implant
	while(contents.len <= amount)
		implant = pick(boxed)
		new implant(src)
