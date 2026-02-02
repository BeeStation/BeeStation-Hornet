/datum/action/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs and vital internal organs, as well as removing shrapnel and restoring blood volume. Costs 10 chemicals."
	helptext = "Will alert nearby crew if any external limbs are regenerated. Can be used while unconscious."
	button_icon_state = "regenerate"
	chemical_cost = 10
	dna_cost = 1
	check_flags = AB_CHECK_DEAD

/datum/action/changeling/regenerate/sting_action(mob/living/user)
	if(!iscarbon(user))
		to_chat(user, span_notice("You have nothing to regenerate in this state!"))
		return FALSE

	..()
	to_chat(user, span_notice("You feel an itching, both inside and outside as your tissues knit and reknit."))
	var/mob/living/carbon/carbon_user = user
	if(length(carbon_user.get_missing_limbs()))
		playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
		carbon_user.visible_message(
			span_warning("[user]'s missing limbs reform, making a loud, grotesque sound!"),
			span_userdanger("Your limbs regrow, making a loud, crunchy sound and giving you great pain!"),
			span_hear("You hear organic matter ripping and tearing!"),
		)

		carbon_user.emote("scream")

	carbon_user.fully_heal(HEAL_BODY)

	// Make sure the brain's nonvital
	// Shouldn't be necessary but you can never be certain with lingcode
	var/obj/item/organ/brain/replacement_brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	replacement_brain.organ_flags &= ~ORGAN_VITAL
	replacement_brain.decoy_override = TRUE

	return TRUE

/datum/action/changeling/limbsnake
	name = "Chimera"
	desc = "We turn our limbs into an autonomous snake. The poison of this creatures can paralyze attackers. Costs 15 chemicals."
	helptext = "We reform one of our limbs as an autonomous snake-like creature. This grotesque display may ward off attackers, and the creature will inject them with incapacitating poison."
	button_icon_state = "limbsnake"
	chemical_cost = 15
	dna_cost = 2
	req_human = TRUE
	check_flags = NONE
	ignores_fakedeath = TRUE

/datum/action/changeling/limbsnake/sting_action(mob/living/user)
	..()
	var/mob/living/carbon/C = user
	var/list/parts = list()
	for(var/Zim in C.bodyparts)
		var/obj/item/bodypart/BP = Zim
		if(BP.body_part != HEAD && BP.body_part != CHEST && IS_ORGANIC_LIMB(BP))
			if(!(BP.bodypart_flags & BODYPART_UNREMOVABLE))
				parts += BP
	if(!LAZYLEN(parts))
		to_chat(user, span_notice("We don't have any limbs to detach."))
		return
	//limb related actions
	var/obj/item/bodypart/BP = pick(parts)
	for(var/obj/item/bodypart/Gir in parts)
		if(Gir.body_part == ARM_RIGHT || Gir.body_part == ARM_LEFT)	//arms first, so they can mitigate the damage with the Armblade ability too, and it's not entirely reliant on regenerate
			BP = Gir
	//text message
	C.visible_message(span_warning("[user]'s [BP] detaches itself and takes the form of a snake!"),
			span_userdanger("Our [BP] forms into a horrifying snake and heads towards our attackers!"))
	BP.dismember()
	BP.Destroy()
	//Deploy limbsnake
	var/mob/living/snek = new /mob/living/simple_animal/hostile/poison/limbsnake(get_turf(user))
	//assign faction
	snek.faction |= "[REF(C)]"
	return TRUE

/mob/living/simple_animal/hostile/poison/limbsnake
	name = "limb snake"
	desc = "This is no snake at all! It looks like someone's limb grew fangs out of it's fingers and it's out to bite anyone!"
	icon_state = "snake"
	icon_living = "snake"
	del_on_death = TRUE
	speak_emote = list("gargles")
	health = 50
	maxHealth = 50
	melee_damage = 3
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "steps on"
	response_harm_simple = "step on"
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	chat_color = "#26F55A"
	mobchatspan = "chaplain"
	faction = list(FACTION_HOSTILE,FACTION_CREATURE)
	poison_per_bite = 4
	poison_type = /datum/reagent/toxin/staminatoxin
	discovery_points = 1000

/mob/living/simple_animal/hostile/poison/limbsnake/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
