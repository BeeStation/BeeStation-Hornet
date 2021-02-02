
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
	RegisterSignal(owner, signalCache, .proc/on_signal)

/obj/item/organ/cyberimp/brain/anti_stun/proc/on_signal(datum/source, amount)
	if(!(organ_flags & ORGAN_FAILING) && amount > 0)
		addtimer(CALLBACK(src, .proc/clear_stuns), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

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
	addtimer(CALLBACK(src, .proc/reboot), 90 / severity)

/obj/item/organ/cyberimp/brain/anti_stun/proc/reboot()
	organ_flags &= ~ORGAN_FAILING

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

//SkillChips

/obj/item/organ/cyberimp/skillChip //Abstraction of the Skillchip Implants.
	name = "SkillChip"
	desc = "A piece of bleeding-edge tech which teaches the user various skills when installed."
	slot = ORGAN_SLOT_SKILLCHIP
	w_class = WEIGHT_CLASS_SMALL
	var/applied_traits = list()
	var/list/style = null

/obj/item/organ/cyberimp/skillChip/Insert(mob/living/carbon/M, special, drop_if_replaced)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(M))
		else
			qdel(replaced)

	SEND_SIGNAL(M, COMSIG_CARBON_GAIN_ORGAN, src)

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	for(var/trait in applied_traits)
		ADD_TRAIT(M, trait, "skillChip")
	moveToNullspace()
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)
	if(style)
		for(var/martialArt in style)
			var/datum/martial_art/S = new martialArt
			S.teach(M)
	STOP_PROCESSING(SSobj, src)

/obj/item/organ/cyberimp/skillChip/Remove(mob/living/carbon/M, special)
	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)
			for(var/trait in applied_traits)
				REMOVE_TRAIT(M, trait, "skillChip")
			if(style)
				for(var/martialArt in style)
					var/datum/martial_art/S = new martialArt
					S.remove(M)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
			to_chat(M, "<span class='warning>Your brain hurts as your neurons are forcefully rewired.</span>")
		if((organ_flags & ORGAN_VITAL) && !special && !(M.status_flags & GODMODE))
			M.death()
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)

	SEND_SIGNAL(M, COMSIG_CARBON_LOSE_ORGAN, src)

	START_PROCESSING(SSobj, src)

/obj/item/organ/cyberimp/skillChip/chemistry
	name = "Chemistry SkillChip"
	desc = "A piece of bleeding-edge tech which teaches the user how to efficiently use a Chem Dispenser."
	applied_traits = list(TRAIT_CHEMISTRY)

/obj/item/organ/cyberimp/skillChip/bartender
	name = "Bartending SkillChip"
	desc = "A piece of bleeding-edge tech which teaches the user how to efficiently use a Chem Dispenser and throw drinks without spilling them"
	applied_traits = list(TRAIT_CHEMISTRY, TRAIT_BOOZE_SLIDER)

/obj/item/organ/cyberimp/skillChip/engineering
	name = "Engineering SkillChip"
	desc = "A piece of bleeding-edge tech which memorizes the wire layouts for each departments doors."
	applied_traits = list(TRAIT_WIRESEEING)

/obj/item/organ/cyberimp/skillChip/surgical
	name = "Surgical Skillchip"
	desc = "A piece of bleeding-edge tech which teaches the user how to employ techniques to improve surgical outcomes."
	applied_traits = list(TRAIT_SURGICAL_EXPERT)

/obj/item/organ/cyberimp/skillChip/chiefMedical
	name = "Chief Medical Officer Skillchip"
	desc = "A piece of bleeding-edge tech which teaches the user how to efficiently use a chem dispenser and employ techniques to improve surgical outcomes."
	applied_traits = list(TRAIT_SURGICAL_EXPERT, TRAIT_CHEMISTRY)

/obj/item/organ/cyberimp/skillChip/chef
	name = "Chef SkillChip"
	desc = "A piece of bleeding-edge tech which teaches the user the art of close quarters cooking."
	style = list(/datum/martial_art/cqc/under_siege)

/obj/item/organ/cyberimp/skillChip/security
	name = "Security SkillChip"
	desc = "A piece of bleeding-edge tech which teaches the user about Nanotrasen approved methods for unarmed takedowns."
	style = list(/datum/martial_art/security_cqc)

/obj/item/organ/cyberimp/skillChip/omniChip //Parent type for all omni chips
	name = "OmniChip"
	desc = "A piece of bleeding-edge tech which teaches the user all the non-martial arts related skills from other SkillChips."
	applied_traits = list(TRAIT_CHEMISTRY, TRAIT_SURGICAL_EXPERT, TRAIT_WIRESEEING, TRAIT_BOOZE_SLIDER)

/obj/item/organ/cyberimp/skillChip/omniChip/omniChipChef
	name = "OmniChip Cooking Edition"
	desc = "A piece of bleeding-edge tech which teaches the user skills from other SkillChips in addition to close quarters cooking."
	style =  list(/datum/martial_art/cqc/under_siege)

/obj/item/organ/cyberimp/skillChip/omniChip/omniChipSecurity
	name = "OmniChip Security Edition"
	desc = "A piece of bleeding-edge tech which teaches the user skills from other SkillChips in addition to Nanotrasen approved methods for unarmed takedowns."
	style = list(/datum/martial_art/security_cqc)
