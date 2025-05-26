//Programs that buff the host in generally passive ways.

/datum/nanite_program/nervous
	name = "Nerve Support"
	desc = "The nanites act as a secondary nervous system, completely absorbing stuns while the user is active."
	use_rate = 1.5
	maximum_duration = 30 SECONDS
	trigger_cooldown = 2 MINUTES
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/nervous/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_STUNIMMUNE, SOURCE_NANITE_NERVOUS)
	ADD_VALUE_TRAIT(host_mob, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_NANITE_NERVOUS, "deb440", SKIN_PRIORITY_NANITES)

/datum/nanite_program/nervous/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_STUNIMMUNE, SOURCE_NANITE_NERVOUS)
	REMOVE_TRAIT(host_mob, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_NANITE_NERVOUS)

/datum/nanite_program/adrenaline
	name = "Adrenaline Burst"
	desc = "The nanites cause a burst of adrenaline when triggered, allowing the user to push their body past its normal limits."
	can_trigger = TRUE
	trigger_cost = 20
	trigger_cooldown = 2 MINUTES
	rogue_types = list(/datum/nanite_program/toxic, /datum/nanite_program/nerve_decay)

/datum/nanite_program/adrenaline/on_trigger()
	to_chat(host_mob, span_notice("You feel a sudden surge of energy!"))
	host_mob.SetAllImmobility(0)
	host_mob.adjustStaminaLoss(-75)
	host_mob.set_resting(FALSE)

/datum/nanite_program/hardening
	name = "Dermal Hardening"
	desc = "The nanites form a mesh under the host's skin, protecting them from melee and bullet impacts for 20 seconds."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/skin_decay)
	trigger_cooldown = 120 SECONDS
	maximum_duration = 40 SECONDS
	var/datum/armor/nanite_armor = /datum/armor/hardening_armor

/datum/armor/hardening_armor
	melee = 30
	bullet = 30

/datum/nanite_program/hardening/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
<<<<<<< HEAD
		H.physiology.physio_armor.add_other_armor(nanite_armor)
=======
		H.physiology.armor.melee += 20
		H.physiology.armor.bullet += 35
>>>>>>> ad5c662e9e9 (Ties nanites directly to food)
		ADD_VALUE_TRAIT(H, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_NANITE_HARDENING, "111111", SKIN_PRIORITY_NANITES)

/datum/nanite_program/hardening/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
<<<<<<< HEAD
		H.physiology.physio_armor.subtract_other_armor(nanite_armor)
=======
		H.physiology.armor.melee -= 20
		H.physiology.armor.bullet -= 35
>>>>>>> ad5c662e9e9 (Ties nanites directly to food)
		REMOVE_TRAIT(H, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_NANITE_HARDENING)

/datum/nanite_program/refractive
	name = "Dermal Refractive Surface"
	desc = "The nanites form a membrane above the host's skin, reducing the effect of laser and energy impacts."
	use_rate = 0.50
	rogue_types = list(/datum/nanite_program/skin_decay)
	trigger_cooldown = 120 SECONDS
	maximum_duration = 40 SECONDS
	var/datum/armor/nanite_armor = /datum/armor/refractive_armor

/datum/armor/refractive_armor
	laser = 30
	energy = 30

/datum/nanite_program/refractive/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.physio_armor.add_other_armor(nanite_armor)
		ADD_VALUE_TRAIT(H, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_NANITE_REFRACTION, "c0faff", SKIN_PRIORITY_NANITES)

/datum/nanite_program/refractive/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.physio_armor.subtract_other_armor(nanite_armor)
		REMOVE_TRAIT(H, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_NANITE_REFRACTION)

/datum/nanite_program/coagulating
	name = "Rapid Coagulation"
	desc = "The nanites induce rapid coagulation when the host is wounded, dramatically reducing bleeding rate."
	use_rate = 0.10
	rogue_types = list(/datum/nanite_program/suffocating)
	maximum_duration = 1 MINUTES
	trigger_cooldown = 90 SECONDS

/datum/nanite_program/coagulating/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_NO_BLEEDING, SOURCE_NANITE_BLOOD)

/datum/nanite_program/coagulating/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_NO_BLEEDING, SOURCE_NANITE_BLOOD)

/datum/nanite_program/conductive
	name = "Electric Conduction"
	desc = "The nanites act as a grounding rod for electric shocks, protecting the host. Shocks can still damage the nanites themselves."
	use_rate = 0.20
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/nerve_decay)
	maximum_duration = 20 SECONDS
	trigger_cooldown = 120 SECONDS

/datum/nanite_program/conductive/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/conductive/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/haste
	name = "Combat Chemical Injection"
	desc = "The nanites synthesize a combination of hormones and chemicals when triggered, making the host resistant to stuns and reduces the impact of pain."
	can_trigger = TRUE
	trigger_cost = 10
	trigger_cooldown = 120 SECONDS
	rogue_types = list(/datum/nanite_program/toxic, /datum/nanite_program/nerve_decay)

/datum/nanite_program/haste/on_trigger()
	to_chat(host_mob, span_notice("Your body feels lighter and your legs feel relaxed!"))
	host_mob.set_resting(FALSE)
	host_mob.reagents.add_reagent(/datum/reagent/medicine/pumpup, 5)

/datum/nanite_program/armblade
	name = "Nanite Blade"
	desc = "The nanites form a sharp blade around the user's arm when activated."
	use_rate = 1
	maximum_duration = 60 SECONDS
	trigger_cooldown = 15 SECONDS
	rogue_types = list(/datum/nanite_program/necrotic, /datum/nanite_program/skin_decay)
	var/obj/item/melee/arm_blade/nanite/blade

/datum/nanite_program/armblade/enable_passive_effect()
	. = ..()
	if(blade)
		QDEL_NULL(blade)
	if(!host_mob)
		return
	blade = new(host_mob)
	host_mob.dropItemToGround(host_mob.get_active_held_item())
	if(!host_mob.put_in_hands(blade))
		to_chat(host_mob, span_danger("You feel an intense pain as your nanites fail to form a blade!"))
		host_mob.adjustBruteLoss(10)
		QDEL_NULL(blade)
		return
	host_mob.visible_message(span_danger("A metallic blade rapidly forms around [host_mob]'s arm!"), span_warning("A nanite blade quickly forms around our arm!"))

/datum/nanite_program/armblade/disable_passive_effect()
	. = ..()
	if(blade)
		host_mob.visible_message(span_danger("The metallic blade around [host_mob]'s arm retracts and dissolves!"), span_warning("Our nanite blade dissipates."))
		QDEL_NULL(blade)

/obj/item/melee/arm_blade/nanite
	name = "metallic armblade"
	desc = "Nanites have formed this extremely sharp blade around your arm. Owie."
	force = 20
	sharpness = SHARP_DISMEMBER
	icon = 'icons/obj/nanite.dmi'
	icon_state = "nanite_blade"
	item_state = "nanite_blade"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
