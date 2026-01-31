/datum/mutation/tongue_spike
	name = "Tongue Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as a deadly weapon."
	quality = POSITIVE
	text_gain_indication = ("<span class='notice'>Your feel like you can throw your voice.</span>")
	instability = 15
	power_path = /datum/action/spell/tongue_spike

	energy_coeff = 1
	synchronizer_coeff = 1

/datum/action/spell/tongue_spike
	name = "Launch spike"
	desc = "Shoot your tongue out in the direction you're facing, embedding it and dealing damage until they remove it."
	button_icon = 'icons/hud/unused/actions_genetic.dmi'
	button_icon_state = "spike"
	mindbound = FALSE
	cooldown_time = 10 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN

	/// The type-path to what projectile we spawn to throw at someone.
	var/spike_path = /obj/item/hardened_spike

/datum/action/spell/tongue_spike/is_valid_spell(mob/user, atom/target)
	return iscarbon(user)

/datum/action/spell/tongue_spike/on_cast(mob/living/carbon/user, atom/target)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_NODISMEMBER))
		to_chat(user, ("<span class='notice'>You concentrate really hard, but nothing happens.</span>"))
		return

	var/obj/item/organ/tongue/to_fire = locate() in user.organs
	if(!to_fire)
		to_chat(user, ("<span class='notice'>You don't have a tongue to shoot!</span>"))
		return

	to_fire.Remove(user, special = TRUE)
	var/obj/item/hardened_spike/spike = new spike_path(get_turf(user), user)
	to_fire.forceMove(spike)
	spike.throw_at(get_edge_target_turf(user, user.dir), 14, 4, user)

/obj/item/hardened_spike
	name = "biomass spike"
	desc = "Hardened biomass, shaped into a spike. Very pointy!"
	icon_state = "tonguespike"
	force = 2
	throwforce = 15 //15 + 2 (WEIGHT_CLASS_SMALL) * 4 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = i didnt do the math
	throw_speed = 4
	embedding = list(
		"embedded_pain_multiplier" = 4,
		"embed_chance" = 100,
		"embedded_fall_chance" = 0,
		"embedded_ignore_throwspeed_threshold" = TRUE,
	)
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP
	custom_materials = list(/datum/material/biomass = 500)
	/// What mob "fired" our tongue
	var/datum/weakref/fired_by_ref
	/// if we missed our target
	var/missed = TRUE

/obj/item/hardened_spike/Initialize(mapload, mob/living/carbon/source)
	. = ..()
	src.fired_by_ref = WEAKREF(source)
	addtimer(CALLBACK(src, PROC_REF(check_embedded)), 5 SECONDS)

/obj/item/hardened_spike/proc/check_embedded()
	if(missed)
		unembedded()

/obj/item/hardened_spike/embedded(atom/target)
	if(isbodypart(target))
		missed = FALSE

/obj/item/hardened_spike/unembedded()
	visible_message(("<span class='warning'>[src] cracks and twists, changing shape!</span>"))
	for(var/obj/tongue as anything in contents)
		tongue.forceMove(get_turf(src))

	qdel(src)

/datum/mutation/tongue_spike/chem
	name = "Chem Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as biomass, allowing a long range transfer of chemicals."
	quality = POSITIVE
	text_gain_indication = ("<span class='notice'>Your feel like you can really connect with people by throwing your voice.</span>")
	instability = 15
	locked = TRUE
	power_path = /datum/action/spell/tongue_spike/chem
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/action/spell/tongue_spike/chem
	name = "Launch chem spike"
	desc = "Shoot your tongue out in the direction you're facing, \
		embedding it for a very small amount of damage. \
		While the other person has the spike embedded, \
		you can transfer your chemicals to them."
	button_icon_state = "spikechem"

	spike_path = /obj/item/hardened_spike/chem

/obj/item/hardened_spike/chem
	name = "chem spike"
	desc = "Hardened biomass, shaped into... something."
	icon_state = "tonguespikechem"
	throwforce = 2 //2 + 2 (WEIGHT_CLASS_SMALL) * 0 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = i didnt do the math again but very low or smthin
	embedding = list(
		"embedded_pain_multiplier" = 0,
		"embed_chance" = 100,
		"embedded_fall_chance" = 0,
		"embedded_pain_chance" = 0,
		"embedded_ignore_throwspeed_threshold" = TRUE,  //never hurts once it's in you
	)
	/// Whether the tongue's already embedded in a target once before
	var/embedded_once_alread = FALSE

/obj/item/hardened_spike/chem/embedded(mob/living/carbon/human/embedded_mob)
	if(embedded_once_alread)
		return
	embedded_once_alread = TRUE

	var/mob/living/carbon/fired_by = fired_by_ref?.resolve()
	if(!fired_by)
		return

	var/datum/action/send_chems/chem_action = new(src)
	chem_action.transfered_ref = WEAKREF(embedded_mob)
	chem_action.Grant(fired_by)

	to_chat(fired_by, ("<span class='notice'>Link established! Use the \"Transfer Chemicals\" ability \
		to send your chemicals to the linked target!</span>"))

/obj/item/hardened_spike/chem/unembedded()
	var/mob/living/carbon/fired_by = fired_by_ref?.resolve()
	if(fired_by)
		to_chat(fired_by, ("<span class='warning'>Link lost!</span>"))
		var/datum/action/send_chems/chem_action = locate() in fired_by.actions
		QDEL_NULL(chem_action)

	return ..()

/datum/action/send_chems
	name = "Transfer Chemicals"
	desc = "Send all of your reagents into whomever the chem spike is embedded in. One use."
	background_icon_state = "bg_spell"
	button_icon = 'icons/hud/unused/actions_genetic.dmi'
	button_icon_state = "spikechemswap"
	check_flags = AB_CHECK_CONSCIOUS

	/// Weakref to the mob target that we transfer chemicals to on activation
	var/datum/weakref/transfered_ref

/datum/action/send_chems/New(master)
	. = ..()
	if(!istype(master, /obj/item/hardened_spike/chem))
		qdel(src)

/datum/action/send_chems/on_activate(mob/user, atom/target)
	if(!ishuman(owner) || !owner.reagents)
		return FALSE
	var/mob/living/carbon/human/transferer = owner
	var/mob/living/carbon/human/transfered = transfered_ref?.resolve()
	if(!ishuman(transfered))
		return FALSE

	to_chat(transfered, ("<span class='warning'>You feel a tiny prick!</span>"))
	transferer.reagents.trans_to(transfered, transferer.reagents.total_volume, 1, 1, 0, transfered_by = transferer)

	var/obj/item/hardened_spike/chem/chem_spike = target
	var/obj/item/bodypart/spike_location = chem_spike.check_embedded()

	//this is where it would deal damage, if it transfers chems it removes itself so no damage
	chem_spike.forceMove(get_turf(spike_location))
	chem_spike.visible_message(("<span class='notice'>[chem_spike] falls out of [spike_location]!</span>"))
	return TRUE
