/datum/species/vampire
	name = "\improper Vampire"
	id = SPECIES_VAMPIRE
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH,TRAIT_DRINKSBLOOD)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	mutant_bodyparts = list("tail_human" = "None", "ears" = "None", "wings" = "None", "body_size" = "Normal")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	exotic_bloodtype = "U"
	use_skintones = TRUE
	mutantheart = /obj/item/organ/heart/vampire
	mutanttongue = /obj/item/organ/tongue/vampire
	mutantstomach = null
	mutantlungs = null
	examine_limb_id = SPECIES_HUMAN
	skinned_type = /obj/item/stack/sheet/animalhide/human
	var/info_text = "You are a <span class='danger'>Vampire</span>. You will slowly but constantly lose blood if outside of a coffin. If inside a coffin, you will slowly heal. You may gain more blood by grabbing a live victim and using your drain ability."
	var/datum/action/spell/shapeshift/bat/batform //attached to the datum itself to avoid cloning memes, and other duplicates

/datum/species/vampire/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/vampire/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")
	C.skin_tone = "albino"
	C.update_body(0)
	if(isnull(batform))
		batform = new
		batform.Grant(C)

/datum/species/vampire/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(!isnull(batform))
		batform.Remove(C)
		QDEL_NULL(batform)

/datum/species/vampire/spec_life(mob/living/carbon/human/C, delta_time, times_fired)
	. = ..()
	if(istype(C.loc, /obj/structure/closet/crate/coffin))
		C.heal_overall_damage(2 * delta_time, 2 * delta_time, 0, BODYTYPE_ORGANIC)
		C.adjustToxLoss(-2 * delta_time)
		C.adjustOxyLoss(-2 * delta_time)
		C.adjustCloneLoss(-2 * delta_time)
		return
	C.blood_volume -= 0.125 * delta_time
	if(C.blood_volume <= BLOOD_VOLUME_SURVIVE)
		to_chat(C, span_danger("You ran out of blood!"))
		C.investigate_log("has been dusted by a lack of blood (vampire).", INVESTIGATE_DEATHS)
		C.dust()
	var/area/A = get_area(C)
	if(istype(A, /area/chapel))
		to_chat(C, span_danger("You don't belong here!"))
		C.adjustFireLoss(10 * delta_time)
		C.adjust_fire_stacks(3 * delta_time)
		C.IgniteMob()

/datum/species/vampire/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/nullrod/whip))
		return 1 //Whips deal 2x damage to vampires. Vampire killer.
	return 0

/datum/species/vampire/get_species_description()
	return "A classy Vampire! They descend upon Space Station Thirteen Every year to spook the crew! \"Bleeg!!\""

/datum/species/vampire/get_species_lore()
	return list(
		"Vampires are unholy beings blessed and cursed with The Thirst. \
		The Thirst requires them to feast on blood to stay alive, and in return it gives them many bonuses."
	)

/datum/species/vampire/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bed",
			SPECIES_PERK_NAME = "Coffin Brooding",
			SPECIES_PERK_DESC = "Vampires can delay The Thirst and heal by resting in a coffin. So THAT'S why they do that!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "cross",
			SPECIES_PERK_NAME = "Against God and Nature",
			SPECIES_PERK_DESC = "Almost all higher powers are disgusted by the existence of \
				Vampires, and entering the Chapel is essentially suicide. Do not do it!",
		),
	)

	return to_add

// Vampire blood is special, so it needs to be handled with its own entry.
/datum/species/vampire/create_pref_blood_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "The Thirst",
		SPECIES_PERK_DESC = "In place of eating, Vampires suffer from The Thirst. \
			Thirst of what? Blood! Their tongue allows them to grab people and drink \
			their blood, and they will die if they run out. As a note, it doesn't \
			matter whose blood you drink, it will all be converted into your blood \
			type when consumed.",
	))

	return to_add

// There isn't a "Minor Undead" biotype, so we have to explain it in an override (see: dullahans)
/datum/species/vampire/create_pref_biotypes_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "skull",
		SPECIES_PERK_NAME = "Minor Undead",
		SPECIES_PERK_DESC = "[name] are minor undead. \
			Minor undead enjoy some of the perks of being dead, like \
			not needing to breathe or eat, but do not get many of the \
			environmental immunities involved with being fully undead.",
	))

	return to_add

/obj/item/organ/tongue/vampire
	name = "vampire tongue"
	actions_types = list(/datum/action/item_action/organ_action/vampire)
	color = "#1C1C1C"
	var/drain_cooldown = 0

#define VAMP_DRAIN_AMOUNT 50

/datum/action/item_action/organ_action/vampire
	name = "Drain Victim"
	desc = "Leech blood from any carbon victim you are passively grabbing."

/datum/action/item_action/organ_action/vampire/on_activate(mob/user, atom/target)
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		var/obj/item/organ/tongue/vampire/V = target
		if(V.drain_cooldown >= world.time)
			to_chat(H, span_notice("You just drained blood, wait a few seconds."))
			return
		if(H.pulling && iscarbon(H.pulling))
			var/mob/living/carbon/victim = H.pulling
			if(H.blood_volume >= BLOOD_VOLUME_MAXIMUM)
				to_chat(H, span_notice("You're already full!"))
				return
			if(victim.stat == DEAD)
				to_chat(H, span_notice("You need a living victim!"))
				return
			if(!victim.blood_volume || (victim.dna && (HAS_TRAIT(victim, TRAIT_NOBLOOD) || victim.dna.species.exotic_blood)))
				to_chat(H, span_notice("[victim] doesn't have blood!"))
				return
			V.drain_cooldown = world.time + 30
			if(victim.can_block_magic(FALSE, TRUE, FALSE))
				to_chat(victim, span_warning("[H] tries to bite you, but stops before touching you!"))
				to_chat(H, span_warning("[victim] is blessed! You stop just in time to avoid catching fire."))
				return
			if(victim?.reagents?.has_reagent(/datum/reagent/consumable/garlic))
				to_chat(victim, span_warning("[H] tries to bite you, but recoils in disgust!"))
				to_chat(H, span_warning("[victim] reeks of garlic! you can't bring yourself to drain such tainted blood."))
				return
			if(!do_after(H, 3 SECONDS, target = victim, hidden = TRUE))
				return
			var/blood_volume_difference = BLOOD_VOLUME_MAXIMUM - H.blood_volume //How much capacity we have left to absorb blood
			var/drained_blood = min(victim.blood_volume, VAMP_DRAIN_AMOUNT, blood_volume_difference)
			to_chat(victim, span_danger("[H] is draining your blood!"))
			to_chat(H, span_notice("You drain some blood!"))
			playsound(H, 'sound/items/drink.ogg', 30, 1, -2)
			victim.blood_volume = clamp(victim.blood_volume - drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			H.blood_volume = clamp(H.blood_volume + drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			if(!victim.blood_volume)
				to_chat(H, span_warning("You finish off [victim]'s blood supply!"))

#undef VAMP_DRAIN_AMOUNT

/obj/item/organ/heart/vampire
	name = "vampire heart"
	actions_types = list(/datum/action/item_action/organ_action/vampire_heart)
	color = "#1C1C1C"

/datum/action/item_action/organ_action/vampire_heart
	name = "Check Blood Level"
	desc = "Check how much blood you have remaining."

/datum/action/item_action/organ_action/vampire_heart/on_activate(mob/user, atom/target)
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		to_chat(H, span_notice("Current blood level: [H.blood_volume]/[BLOOD_VOLUME_MAXIMUM]."))

/datum/action/spell/shapeshift/bat
	name = "Bat Form"
	desc = "Take on the shape of a space bat."
	invocation = "Squeak!"
	cooldown_time = 5 SECONDS
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	possible_shapes = list(
		/mob/living/simple_animal/hostile/retaliate/bat/vampire
	)
