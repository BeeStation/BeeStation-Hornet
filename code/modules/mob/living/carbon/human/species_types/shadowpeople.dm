/// How many life ticks are required for the nightmare's heart to revive the nightmare.
#define HEART_RESPAWN_THRESHOLD (80 SECONDS)
/// A special flag value used to make a nightmare heart not grant a light eater. Appears to be unused.
#define HEART_SPECIAL_SHADOWIFY 2

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Shadow"
	plural_form = "Shadowpeople"
	id = SPECIES_SHADOW
	sexes = FALSE
	meat = /obj/item/food/meat/slab/human/mutant/shadow
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_NOFLASH
	)
	inherent_factions = list(FACTION_FAITHLESS)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC

	mutantbrain = /obj/item/organ/brain/shadow
	mutanteyes = /obj/item/organ/eyes/night_vision/shadow
	mutantheart = null
	mutantlungs = null

	species_language_holder = /datum/language_holder/shadowpeople

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow,
	)

/datum/species/shadow/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/shadow/get_species_description()
	return "Victims of a long extinct space alien. Their flesh is a sickly \
		see-through filament, their tangled insides in clear view. Their form \
		is a mockery of life, leaving them mostly unable to work with others under \
		normal circumstances."

/datum/species/shadow/get_species_lore()
	return list(
		"Long ago, the Spinward Sector used to be inhabited by terrifying aliens aptly named \"Shadowlings\" \
		after their control over darkness, and tendency to kidnap victims into the dark maintenance shafts. \
		Around 2558, the long campaign Nanotrasen waged against the space terrors ended with the full extinction of the Shadowlings.",

		"Victims of their kidnappings would become brainless thralls, and via surgery they could be freed from the Shadowling's control. \
		Those more unlucky would have their entire body transformed by the Shadowlings to better serve in kidnappings. \
		Unlike the brain tumors of lesser control, these greater thralls could not be reverted.",

		"With Shadowlings long gone, their will is their own again. But their bodies have not reverted, burning in exposure to light. \
		Nanotrasen has assured the victims that they are searching for a cure. No further information has been given, even years later. \
		Most shadowpeople now assume Nanotrasen has long since shelved the project.",
	)

/datum/species/shadow/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Shadowborn",
			SPECIES_PERK_DESC = "Their skin blooms in the darkness. All kinds of damage, \
				no matter how extreme, will heal over time as long as there is no light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Nightvision",
			SPECIES_PERK_DESC = "Their eyes are adapted to the night, and can see in the dark with no problems.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Lightburn",
			SPECIES_PERK_DESC = "Their flesh withers in the light. Any exposure to light is \
				incredibly painful for the shadowperson, charring their skin.",
		),
	)

	return to_add


/// the key to some of their powers
/obj/item/organ/brain/shadow
	name = "shadowling tumor"
	desc = "Something that was once a brain, before being remolded by a shadowling. It has adapted to the dark, irreversibly."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'

/obj/item/organ/brain/shadow/on_life(delta_time, times_fired)
	. = ..()
	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return
	var/light_amount = owner_turf.get_lumcount()

	if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
		owner.take_overall_damage(brute = 0.5 * delta_time, burn = 0.5 * delta_time, required_bodytype = BODYTYPE_ORGANIC)
	else if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
		owner.heal_overall_damage(brute = 0.5 * delta_time, burn = 0.5 * delta_time, required_bodytype = BODYTYPE_ORGANIC)

/obj/item/organ/eyes/night_vision/shadow
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	flash_protect = -1

/datum/species/shadow/nightmare
	name = "Nightmare"
	id = SPECIES_NIGHTMARE
	examine_limb_id = SPECIES_SHADOW
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE
	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NOBLOOD,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_JUMPSUIT,
		TRAIT_NOT_TRANSMORPHIC,
		TRAIT_NOFLASH
	)

	mutantheart = /obj/item/organ/heart/nightmare
	mutantbrain = /obj/item/organ/brain/shadow/nightmare
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow/nightmare,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow/nightmare,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow,
	)

	var/info_text = "You are a " + span_danger("Nightmare") + ". The ability " + span_warning("shadow walk") + " allows unlimited, unrestricted movement in the dark while activated. \
					Your " + span_warning("light eater") + " will destroy any light producing objects you attack, as well as destroy any lights a living creature may be holding. You will automatically dodge gunfire and melee attacks when on a dark tile. If killed, you will eventually revive if left in darkness."

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	to_chat(C, "[info_text]")

	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))
	C.set_safe_hunger_level()

/datum/species/shadow/nightmare/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message(span_danger("[H] dances in the shadows, evading [P]!"))
			playsound(T, "bullet_miss", 75, 1)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE

//Organs

/obj/item/organ/brain/shadow/nightmare
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "brain-x-d"
	///Our associated shadow jaunt spell, for all nightmares
	var/datum/action/spell/jaunt/shadow_walk/our_jaunt

/obj/item/organ/brain/shadow/nightmare/on_mob_insert(mob/living/carbon/brain_owner)
	. = ..()

	if(brain_owner.dna.species.id != SPECIES_NIGHTMARE)
		brain_owner.set_species(/datum/species/shadow/nightmare)
		visible_message(span_warning("[brain_owner] thrashes as [src] takes root in [brain_owner.p_their()] body!"))

	our_jaunt = new(brain_owner)
	our_jaunt.Grant(brain_owner)

/obj/item/organ/brain/shadow/nightmare/on_mob_remove(mob/living/carbon/brain_owner)
	. = ..()
	QDEL_NULL(our_jaunt)

/obj/item/organ/heart/nightmare
	name = "heart of darkness"
	desc = "An alien organ that twists and writhes when exposed to light."
	visual = TRUE
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "demon_heart-on"

	color = "#1C1C1C"
	decay_factor = 0
	var/respawn_progress = 0
	var/obj/item/light_eater/blade

/obj/item/organ/heart/nightmare/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(
		span_warning("[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"),
		span_danger("[src] feels unnaturally cold in your hands. You raise [src] to your mouth and devour it!")
	)
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)

	user.visible_message(
		span_warning("Blood erupts from [user]'s arm as it reforms into a weapon!"),
		span_userdanger("Icy blood pumps through your veins as your arm reforms itself!")
	)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/nightmare/on_mob_insert(mob/living/carbon/heart_owner, special, movement_flags)
	. = ..()
	if(special != HEART_SPECIAL_SHADOWIFY)
		blade = new/obj/item/light_eater
		heart_owner.put_in_hands(blade)

/obj/item/organ/heart/nightmare/on_mob_remove(mob/living/carbon/heart_owner, special, movement_flags)
	. = ..()
	respawn_progress = 0
	if(blade && special != HEART_SPECIAL_SHADOWIFY)
		heart_owner.visible_message(span_warning("\The [blade] disintegrates!"))
		QDEL_NULL(blade)

/obj/item/organ/heart/nightmare/Stop()
	return FALSE

/obj/item/organ/heart/nightmare/update_icon()
	return //always beating visually

/obj/item/organ/heart/nightmare/on_death(delta_time, times_fired)
	if(!owner)
		return
	var/turf/T = get_turf(owner)
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			respawn_progress += delta_time SECONDS
			playsound(owner,'sound/effects/singlebeat.ogg',40,1)

	if(respawn_progress < HEART_RESPAWN_THRESHOLD)
		return

	owner.revive(HEAL_ALL & ~HEAL_REFRESH_ORGANS)
	if(!(owner.dna.species.id == SPECIES_SHADOW || owner.dna.species.id == SPECIES_NIGHTMARE))
		var/mob/living/carbon/old_owner = owner
		Remove(owner, HEART_SPECIAL_SHADOWIFY)
		old_owner.set_species(/datum/species/shadow)
		Insert(old_owner, HEART_SPECIAL_SHADOWIFY)
		to_chat(owner, span_userdanger("You feel the shadows invade your skin, leaping into the center of your chest! You're alive!"))
		SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
	owner.visible_message(span_warning("[owner] staggers to [owner.p_their()] feet!"))
	playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
	respawn_progress = 0

//Weapon

/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	force = 25

	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL | ISWEAPON
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_DISMEMBER_EASY
	bleed_force = BLEED_DEEP_WOUND
	//Fuck you, *crowbars your evil thing
	tool_behaviour = TOOL_CROWBAR

/obj/item/light_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	ADD_TRAIT(src, TRAIT_DOOR_PRYER, INNATE_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)

/obj/item/light_eater/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	AM.lighteater_act(src)

/atom/movable/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	for(var/datum/component/overlay_lighting/light_source in affected_dynamic_lights)
		if(light_source.parent != src)
			var/atom/A = light_source.parent
			A.lighteater_act(light_eater, src)

/mob/living/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(on_fire)
		extinguish_mob()
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)
	if(pulling)
		pulling.lighteater_act(light_eater)

/obj/effect/decal/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message(span_danger("[src] is disintegrated by [light_eater]!"))
	qdel(src)
	playsound(src, 'sound/items/welder.ogg', 50, 1)

/mob/living/carbon/human/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(isethereal(src))
		emp_act(EMP_LIGHT)

/mob/living/silicon/robot/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(lamp_enabled)
		smash_headlamp()

/obj/structure/bonfire/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(burning)
		extinguish()
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)
	..()

/obj/structure/glowshroom/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if (light_power > 0)
		acid_act()

/obj/item/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message(span_danger("[src] is disintegrated by [light_eater]!"))
	burn()
	playsound(src, 'sound/items/welder.ogg', 50, 1)

/obj/item/modular_computer/tablet/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(light_range && light_power > 0 && light_on)
		// Only the queen of Beetania can save our IDs from this infernal nightmare
		var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
		var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
		card_slot2?.try_eject()
		card_slot?.try_eject()
	..()

/obj/item/clothing/head/helmet/space/hardsuit/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!light_range || !light_power || !light_on || light_broken)
		return ..()
	if(light_eater)
		visible_message(span_danger("The headlamp of [src] is disintegrated by [light_eater]!"))
	light_broken = TRUE
	var/mob/user = ismob(parent) ? parent : null
	attack_self(user)
	playsound(src, 'sound/items/welder.ogg', 50, 1)
	..()

/obj/item/clothing/head/helmet/space/plasmaman/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!lamp_functional)
		return
	if(helmet_on)
		smash_headlamp()
	..()

/turf/open/floor/light/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	. = ..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message(span_danger("The light bulb of [src] is disintegrated by [light_eater]!"))
	break_tile()
	playsound(src, 'sound/items/welder.ogg', 50, 1)

/obj/item/weldingtool/cyborg/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!isOn())
		return
	if(light_eater)
		loc.visible_message(span_danger("The integrated welding tool is snuffed out by [light_eater]!"))
		disable()
	..()

#undef HEART_SPECIAL_SHADOWIFY


// Shadow sect section
#define SHADOW_CONVERSION_TRESHOLD 60 // Used for people changing into shadowpeople because of hearts

/datum/species/shadow/blessed // Shadow person subsiecies with interacts with shadow sect
	id = "shadow_blessed"
	mutantbrain = /obj/item/organ/brain/shadow/blessed
	var/sect_rituals_completed = 0 // only important if shadow sect is at play, this is a way to check what level of rituals it completed. Used by shadow hearts

/obj/item/organ/brain/shadow/blessed/on_life(delta_time, times_fired)
	. = ..()
	var/datum/species/shadow/blessed/sect_species = owner.dna.species

	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return
	var/light_amount = owner_turf.get_lumcount()

	if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
		owner.take_overall_damage(0.5 * delta_time, 0.5 * delta_time, 0, BODYTYPE_ORGANIC)
		if(owner.has_movespeed_modifier(/datum/movespeed_modifier/shadow_sect))
			owner.remove_movespeed_modifier(/datum/movespeed_modifier/shadow_sect)
	else if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
		if(sect_species.sect_rituals_completed >= 1 && owner.nutrition <= NUTRITION_LEVEL_WELL_FED)
			owner.nutrition += 2 * delta_time
		owner.heal_overall_damage((0.5 * delta_time), (0.5 * delta_time), 0, BODYTYPE_ORGANIC)
		if(sect_species.sect_rituals_completed >= 2)
			if(sect_species.sect_rituals_completed == 3)
				owner.add_movespeed_modifier(/datum/movespeed_modifier/shadow_sect)

/datum/species/shadow/blessed/check_roundstart_eligible()
	return FALSE

/datum/species/shadow/blessed/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if (istype(GLOB.religious_sect, /datum/religion_sect/shadow_sect))
		change_hearts_ritual(C)

/datum/species/shadow/proc/change_hearts_ritual(mob/living/carbon/C) // This is supposed to be called only for shadow sect
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!isnightmare(C))
		if(sect.grand_ritual_level == 1)
			mutantheart = new/obj/item/organ/heart/shadow_ritual/first
			mutantheart.Insert(C, 0, FALSE)
		if(sect.grand_ritual_level == 2)
			mutantheart = new/obj/item/organ/heart/shadow_ritual/second
			mutantheart.Insert(C, 0, FALSE)
		if(sect.grand_ritual_level == 3)
			mutantheart = new/obj/item/organ/heart/shadow_ritual/third
			mutantheart.Insert(C, 0, FALSE)

/datum/species/shadow/blessed/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		if(prob(20) && sect_rituals_completed >= 2)
			var/light_amount = T.get_lumcount()
			if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
				H.visible_message(span_danger("[H] dances in the shadows, evading [P]!"))
				playsound(T, "bullet_miss", 75, 1)
				return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/movespeed_modifier/shadow_sect
	multiplicative_slowdown = -0.15


/obj/item/organ/heart/shadow_ritual // This parent should never appear itself
	visual = TRUE
	decay_factor = 0
	var/shadow_conversion = 0 // Determines progress of transforming owner into shadow person
	var/sect_rituals_completed_granted = 0 // What level of sect_rituals_completed the heart grants
	var/datum/action/innate/shadow_comms/comms/C = new // For granting shadow comms

/obj/item/organ/heart/shadow_ritual/first
	name = "shadowed heart"
	desc = "An object resembling a heart, completely shrouded by a thick layer of darkness."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "shadow_heart_1"
	sect_rituals_completed_granted = 1

/obj/item/organ/heart/shadow_ritual/second
	name = "faded heart"
	desc = "A hard to distinguish heart-like organ covered by a shifting darkness."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "shadow_heart_2"
	sect_rituals_completed_granted = 2

/obj/item/organ/heart/shadow_ritual/third
	name = "pulsing darkness"
	desc = "An indistinguishable object cloaked in an undispellable darkness. The only thing that can be made out is the darkness pulsing."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "shadow_heart_3"
	var/respawn_progress = 0
	sect_rituals_completed_granted = 3


/obj/item/organ/heart/shadow_ritual/Stop()
	return FALSE

/obj/item/organ/heart/shadow_ritual/update_icon()
	return

/obj/item/organ/heart/shadow_ritual/on_mob_insert(mob/living/carbon/heart_owner)
	. = ..()
	if(isblessedshadow(heart_owner))
		var/mob/living/carbon/human/O = heart_owner
		var/datum/species/shadow/blessed/S = O.dna.species
		S.sect_rituals_completed = sect_rituals_completed_granted
		C.Grant(heart_owner)
	else
		shadow_conversion = 0
		to_chat(heart_owner, span_userdanger("You feel a chill spreading throughout your body..."))


/obj/item/organ/heart/shadow_ritual/on_mob_remove(mob/living/carbon/heart_owner)
	. = ..()
	if(isblessedshadow(heart_owner))
		var/mob/living/carbon/human/O = heart_owner
		var/datum/species/shadow/blessed/S = O.dna.species
		S.sect_rituals_completed = 0
		heart_owner.alpha = 255
		C.Remove(heart_owner)
		if(heart_owner.has_movespeed_modifier(/datum/movespeed_modifier/shadow_sect))
			heart_owner.remove_movespeed_modifier(/datum/movespeed_modifier/shadow_sect)
	if(shadow_conversion != 0)
		to_chat(heart_owner, span_bigboldinfo("You feel warmth returning to you once more."))
		shadow_conversion = 0

/obj/item/organ/heart/shadow_ritual/third/on_mob_remove(mob/living/carbon/heart_owner)
	..()
	respawn_progress = 0

/obj/item/organ/heart/shadow_ritual/on_life(delta_time, times_fired)
	..()
	if(!isshadow(owner))
		shadow_conversion += 1
		if(shadow_conversion > SHADOW_CONVERSION_TRESHOLD)
			shadow_conversion = 0
			to_chat(owner, span_userdanger("You feel the shadows invade your skin, leaping from the center of your chest!"))
			var/mob/living/carbon/old_owner = owner
			old_owner.set_species(/datum/species/shadow/blessed)
		else
			var/random_mesage = rand(0,90)
			if(random_mesage == 0)
				to_chat(owner, span_warning("Dark spots appear all over your skin."))
			if(random_mesage == 1)
				to_chat(owner, span_warning("Bright lights seem really unpleasant."))
			if(random_mesage == 2)
				to_chat(owner, span_warning("The chill isn't going away."))
			if(random_mesage == 4)
				to_chat(owner, span_warning("You feel like you should rest in a dark place."))
	else if(!isblessedshadow(owner) && !isnightmare(owner))
		to_chat(owner, span_userdanger("You feel closer to shadows surrounding you."))
		var/mob/living/carbon/old_owner = owner
		old_owner.set_species(/datum/species/shadow/blessed)


/obj/item/organ/heart/shadow_ritual/third/on_death(delta_time)
	if(!owner)
		return
	var/turf/T = get_turf(owner)
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			respawn_progress += 0.75 * delta_time SECONDS
			playsound(owner,'sound/effects/singlebeat.ogg',40,1)
	if(respawn_progress >= HEART_RESPAWN_THRESHOLD)
		owner.revive(HEAL_ALL)
		if(!isshadow(owner))
			var/mob/living/carbon/old_owner = owner
			old_owner.set_species(/datum/species/shadow/blessed)
			to_chat(owner, span_userdanger("You feel the shadows invade your skin, leaping from the center of your chest! You're alive!"))
			SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
		owner.visible_message(span_warning("[owner] staggers to [owner.p_their()] feet!"))
		playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, 1)
		respawn_progress = 0


#undef HEART_RESPAWN_THRESHOLD


// Shadow comms, copied from cult

/datum/action/innate/shadow_comms
	button_icon = 'icons/hud/actions/action_generic.dmi'
	background_icon_state = "bg_default"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/innate/shadow_comms/is_available()
	if(!isblessedshadow(owner))
		return FALSE
	var/mob/living/carbon/human/O = owner
	var/datum/species/shadow/blessed/S = O.dna.species
	if(S.sect_rituals_completed == 0)
		return FALSE
	return ..()

/datum/action/innate/shadow_comms/comms
	name = "Whisper"
	desc = "Talk to other shadowpeople using shadows."
	button_icon_state = "commune"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/shadow_comms/comms/on_activate()
	var/input = tgui_input_text(usr, "Please choose a message to tell to the shadows.", "Voice of Shadows", "")
	if(!input || !is_available())
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, span_warning("You cannot send a message that contains a word prohibited in IC chat!"))
		return
	shadow_commune(usr, input)

/datum/action/innate/shadow_comms/comms/proc/shadow_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	var/title = "Shadow"
	var/span = "average"
	if(user.mind && user.mind.holy_role > 1)
		span = "big bold"
		title = "Darkest shadow"
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	message = user.treat_message_min(message)
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(isblessedshadow(M))
			var/mob/living/carbon/human/O = M
			var/datum/species/shadow/blessed/S = O.dna.species
			if(S.sect_rituals_completed != 0)
				to_chat(M, my_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = M == user)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]", type = MESSAGE_TYPE_RADIO)

	user.log_talk(message, LOG_SAY, tag="shadow sect")


#undef SHADOW_CONVERSION_TRESHOLD
