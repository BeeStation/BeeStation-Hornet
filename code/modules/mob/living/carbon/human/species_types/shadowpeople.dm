#define HEART_RESPAWN_THRESHOLD 40
#define HEART_SPECIAL_SHADOWIFY 2

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "\improper Shadow"
	plural_form = "Shadowpeople"
	id = SPECIES_SHADOWPERSON
	sexes = 0
	meat = /obj/item/food/meat/slab/human/mutant/shadow
	species_traits = list(NOBLOOD,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NOBREATH)
	inherent_factions = list("faithless")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	mutanteyes = /obj/item/organ/eyes/night_vision
	species_language_holder = /datum/language_holder/shadowpeople

	species_chest = /obj/item/bodypart/chest/shadow
	species_head = /obj/item/bodypart/head/shadow
	species_l_arm = /obj/item/bodypart/l_arm/shadow
	species_r_arm = /obj/item/bodypart/r_arm/shadow
	species_l_leg = /obj/item/bodypart/l_leg/shadow
	species_r_leg = /obj/item/bodypart/r_leg/shadow


/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()

		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
			H.take_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
		else if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
			H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)

/datum/species/shadow/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/shadow/get_species_description()
	return "Victims of a long extinct space alien. Their flesh is a sickly \
		seethrough filament, their tangled insides in clear view. Their form \
		is a mockery of life, leaving them mostly unable to work with others under \
		normal circumstances."

/datum/species/shadow/get_species_lore()
	return list(
		"Long ago, the Spinward Sector used to be inhabited by terrifying aliens aptly named \"Shadowlings\" \
		after their control over darkness, and tendancy to kidnap victims into the dark maintenance shafts. \
		Around 2558, the long campaign Nanotrasen waged against the space terrors ended with the full extinction of the Shadowlings.",

		"Victims of their kidnappings would become brainless thralls, and via surgery they could be freed from the Shadowling's control. \
		Those more unlucky would have their entire body transformed by the Shadowlings to better serve in kidnappings. \
		Unlike the brain tumors of lesser control, these greater thralls could not be reverted.",

		"With Shadowlings long gone, their will is their own again. But their bodies have not reverted, burning in exposure to light. \
		Nanotrasen has assured the victims that they are searching for a cure. No further information has been given, even years later. \
		Most shadowpeople now assume Nanotrasen has long since shelfed the project.",
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

/datum/species/shadow/nightmare
	name = "Nightmare"
	id = "nightmare"
	burnmod = 1.5
	no_equip = list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_NOBREATH,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOHUNGER)
	mutanteyes = /obj/item/organ/eyes/night_vision/nightmare
	mutant_organs = list(/obj/item/organ/heart/nightmare)
	mutant_brain = /obj/item/organ/brain/nightmare
	nojumpsuit = 1

	var/info_text = "You are a <span class='danger'>Nightmare</span>. The ability <span class='warning'>shadow walk</span> allows unlimited, unrestricted movement in the dark while activated. \
					Your <span class='warning'>light eater</span> will destroy any light producing objects you attack, as well as destroy any lights a living creature may be holding. You will automatically dodge gunfire and melee attacks when on a dark tile. If killed, you will eventually revive if left in darkness."

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")

	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))

/datum/species/shadow/nightmare/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message("<span class='danger'>[H] dances in the shadows, evading [P]!</span>")
			playsound(T, "bullet_miss", 75, 1)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE

//Organs

/obj/item/organ/brain/nightmare
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."
	icon_state = "brain-x-d"
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/shadowwalk

/obj/item/organ/brain/nightmare/Insert(mob/living/carbon/M, special = 0, pref_load = FALSE)
	..()
	if(M.dna.species.id != "nightmare")
		M.set_species(/datum/species/shadow/nightmare)
		visible_message("<span class='warning'>[M] thrashes as [src] takes root in [M.p_their()] body!</span>")
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/SW = new
	M.AddSpell(SW)
	shadowwalk = SW


/obj/item/organ/brain/nightmare/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	if(shadowwalk)
		M.RemoveSpell(shadowwalk)
	..()


/obj/item/organ/heart/nightmare
	name = "heart of darkness"
	desc = "An alien organ that twists and writhes when exposed to light."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	color = "#1C1C1C"
	var/respawn_progress = 0
	var/obj/item/light_eater/blade
	decay_factor = 0


/obj/item/organ/heart/nightmare/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
						 "<span class='danger'>[src] feels unnaturally cold in your hands. You raise [src] your mouth and devour it!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)


	user.visible_message("<span class='warning'>Blood erupts from [user]'s arm as it reforms into a weapon!</span>", \
						 "<span class='userdanger'>Icy blood pumps through your veins as your arm reforms itself!</span>")
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/nightmare/Insert(mob/living/carbon/M, special = 0, pref_load = FALSE)
	..()
	if(special != HEART_SPECIAL_SHADOWIFY)
		blade = new/obj/item/light_eater
		M.put_in_hands(blade)

/obj/item/organ/heart/nightmare/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	respawn_progress = 0
	if(blade && special != HEART_SPECIAL_SHADOWIFY)
		M.visible_message("<span class='warning'>\The [blade] disintegrates!</span>")
		QDEL_NULL(blade)
	..()

/obj/item/organ/heart/nightmare/Stop()
	return 0

/obj/item/organ/heart/nightmare/update_icon()
	return //always beating visually

/obj/item/organ/heart/nightmare/on_death()
	if(!owner)
		return
	var/turf/T = get_turf(owner)
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			respawn_progress++
			playsound(owner,'sound/effects/singlebeat.ogg',40,1)
	if(respawn_progress >= HEART_RESPAWN_THRESHOLD)
		owner.revive(full_heal = TRUE)
		if(!(owner.dna.species.id == "shadow" || owner.dna.species.id == "nightmare"))
			var/mob/living/carbon/old_owner = owner
			Remove(owner, HEART_SPECIAL_SHADOWIFY)
			old_owner.set_species(/datum/species/shadow)
			Insert(old_owner, HEART_SPECIAL_SHADOWIFY)
			to_chat(owner, "<span class='userdanger'>You feel the shadows invade your skin, leaping into the center of your chest! You're alive!</span>")
			SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
		owner.visible_message("<span class='warning'>[owner] staggers to [owner.p_their()] feet!</span>")
		playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, 1)
		respawn_progress = 0

//Weapon

/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	force = 25
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL | ISWEAPON
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP

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
		ExtinguishMob()
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)
	if(pulling)
		pulling.lighteater_act(light_eater)

/obj/effect/decal/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message("<span class='danger'>[src] is disintegrated by [light_eater]!</span>")
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
		visible_message("<span class='danger'>[src] is disintegrated by [light_eater]!</span>")
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
		visible_message("<span class='danger'>The headlamp of [src] is disintegrated by [light_eater]!</span>")
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
		visible_message("<span class='danger'>The light bulb of [src] is disintegrated by [light_eater]!</span>")
	break_tile()
	playsound(src, 'sound/items/welder.ogg', 50, 1)

/obj/item/weldingtool/cyborg/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!isOn())
		return
	if(light_eater)
		loc.visible_message("<span class='danger'>The the integrated welding tool is snuffed out by [light_eater]!</span>")
		disable()
	..()

#undef HEART_SPECIAL_SHADOWIFY
#undef HEART_RESPAWN_THRESHOLD
