//Programs that buff the host in generally passive ways.

/datum/nanite_program/nervous
	name = "Nerve Support"
	desc = "The nanites act as a secondary nervous system, reducing the amount of time the host is stunned."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/nervous/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 0.5

/datum/nanite_program/nervous/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 2

/datum/nanite_program/adrenaline
	name = "Adrenaline Burst"
	desc = "The nanites cause a burst of adrenaline when triggered, allowing the user to push their body past its normal limits."
	can_trigger = TRUE
	trigger_cost = 20
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/toxic, /datum/nanite_program/nerve_decay)

/datum/nanite_program/adrenaline/on_trigger()
	to_chat(host_mob, span_notice("You feel a sudden surge of energy!"))
	host_mob.SetAllImmobility(0)
	host_mob.adjustStaminaLoss(-75)
	host_mob.set_resting(FALSE)

/datum/nanite_program/hardening
	name = "Dermal Hardening"
	desc = "The nanites form a mesh under the host's skin, protecting them from melee and bullet impacts."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/skin_decay)
	var/datum/armor/nanite_armor = /datum/armor/hardening_armor

/datum/armor/hardening_armor
	melee = 30
	bullet = 30

//TODO on_hit effect that turns skin grey for a moment

/datum/nanite_program/hardening/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.physio_armor.add_other_armor(nanite_armor)


/datum/nanite_program/hardening/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.physio_armor.subtract_other_armor(nanite_armor)

/datum/nanite_program/refractive
	name = "Dermal Refractive Surface"
	desc = "The nanites form a membrane above the host's skin, reducing the effect of laser and energy impacts."
	use_rate = 0.50
	rogue_types = list(/datum/nanite_program/skin_decay)
	var/datum/armor/nanite_armor = /datum/armor/refractive_armor

/datum/armor/refractive_armor
	laser = 30
	energy = 30

/datum/nanite_program/refractive/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.physio_armor.add_other_armor(nanite_armor)

/datum/nanite_program/refractive/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.physio_armor.subtract_other_armor(nanite_armor)

/datum/nanite_program/coagulating
	name = "Rapid Coagulation"
	desc = "The nanites induce rapid coagulation when the host is wounded, dramatically reducing bleeding rate."
	use_rate = 0.10
	rogue_types = list(/datum/nanite_program/suffocating)

/datum/nanite_program/coagulating/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 0.1

/datum/nanite_program/coagulating/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 10

/datum/nanite_program/conductive
	name = "Electric Conduction"
	desc = "The nanites act as a grounding rod for electric shocks, protecting the host. Shocks can still damage the nanites themselves."
	use_rate = 0.20
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/conductive/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/conductive/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/mindshield
	name = "Mental Barrier"
	desc = "The nanites form a protective membrane around the host's brain, shielding them from abnormal influences while they're active."
	use_rate = 0.40
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mindshield/enable_passive_effect()
	. = ..()
	if(!host_mob.mind.has_antag_datum(/datum/antagonist/rev, TRUE)) //won't work if on a rev, to avoid having implanted revs.
		ADD_TRAIT(host_mob, TRAIT_MINDSHIELD, "nanites")
		host_mob.sec_hud_set_implants()

/datum/nanite_program/mindshield/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_MINDSHIELD, "nanites")
	host_mob.sec_hud_set_implants()

/datum/nanite_program/haste
	name = "Amphetamine Injection"
	desc = "The nanites synthesize amphetamine when triggered, which temporarily increases the host's running speed."
	can_trigger = TRUE
	trigger_cost = 10
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/toxic, /datum/nanite_program/nerve_decay)

/datum/nanite_program/haste/on_trigger()
	to_chat(host_mob, span_notice("Your body feels lighter and your legs feel relaxed!"))
	host_mob.set_resting(FALSE)
	host_mob.reagents.add_reagent(/datum/reagent/medicine/amphetamine, 3)

/datum/nanite_program/armblade
	name = "Nanite Blade"
	desc = "The nanites form a sharp blade around the user's arm when activated."
	use_rate = 1
	activate_cooldown = 10 SECONDS
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
	inhand_icon_state = "nanite_blade"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
