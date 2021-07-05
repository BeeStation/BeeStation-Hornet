/obj/item/living_heart
	name = "Living Heart"
	desc = "A link to the worlds beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "living_heart"
	w_class = WEIGHT_CLASS_SMALL
	///Target
	var/mob/living/carbon/human/target

/obj/item/living_heart/attack_self(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	if(!target)
		to_chat(user,"<span class='warning'>No target could be found. Put the living heart on the rune and use the rune to receive a target.</span>")
		return
	var/dist = get_dist(user.loc,target.loc)
	var/dir = get_dir(user.loc,target.loc)
	if(user.get_virtual_z_level() != target.get_virtual_z_level())
		to_chat(user,"<span class='warning'>[target.real_name] is on another plane of existance!</span>")
	else
		switch(dist)
			if(0 to 15)
				to_chat(user,"<span class='warning'>[target.real_name] is near you. They are to the [dir2text(dir)] of you!</span>")
			if(16 to 31)
				to_chat(user,"<span class='warning'>[target.real_name] is somewhere in your vicinty. They are to the [dir2text(dir)] of you!</span>")
			else
				to_chat(user,"<span class='warning'>[target.real_name] is far away from you. They are to the [dir2text(dir)] of you!</span>")

	if(target.stat == DEAD)
		to_chat(user,"<span class='warning'>[target.real_name] is dead. Bring them to a transmutation rune!</span>")

/datum/action/innate/heretic_shatter
	name = "Shattering Offer"
	desc = "By breaking your blade, you will be granted salvation from a dire situation. (Teleports you to a random safe turf on your current z level, but destroys your blade.)"
	background_icon_state = "bg_ecult"
	button_icon_state = "shatter"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN
	var/mob/living/carbon/human/holder
	var/obj/item/melee/sickly_blade/sword

/datum/action/innate/heretic_shatter/Grant(mob/user, obj/object)
	sword = object
	holder = user
	//i know what im doing
	return ..()

/datum/action/innate/heretic_shatter/IsAvailable()
	if(IS_HERETIC(holder) || IS_HERETIC_MONSTER(holder))
		return TRUE
	else
		return FALSE

/datum/action/innate/heretic_shatter/Activate()
	var/turf/safe_turf = find_safe_turf(zlevels = sword.z, extended_safety_checks = TRUE)
	do_teleport(holder,safe_turf,forceMove = TRUE)
	to_chat(holder,"<span class='warning'>You feel a gust of energy flow through your body... the Rusted Hills heard your call...</span>")
	qdel(sword)

/datum/action/innate/heretic_conceal
	name = "Robes"
	desc = "Makes you appear as unknown and changes your voice."
	background_icon_state = "bg_ecult"
	button_icon_state = "shatter"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN
	var/mob/living/carbon/human/holder
	var/obj/item/melee/sickly_blade/sword
	var/heretic_conceal_activated = FALSE

/datum/action/innate/heretic_conceal/Grant(mob/user, obj/object)
	sword = object
	holder = user
	return ..()

/datum/action/innate/heretic_conceal/IsAvailable()
	if(IS_HERETIC(holder) || IS_HERETIC_MONSTER(holder))
		return TRUE
	else
		return FALSE

/datum/action/innate/heretic_conceal/Activate()
	heretic_conceal_activated = !heretic_conceal_activated
	if(heretic_conceal_activated == TRUE)
		holder.name = "Apostle"
		holder.job = "Unknown"
	else
		.=..()

/obj/item/melee/sickly_blade
	name = "Sickly blade"
	desc = "A sickly green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_blade"
	item_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_NORMAL
	force = 24
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	var/datum/action/innate/heretic_shatter/linked_action

/obj/item/melee/sickly_blade/Initialize()
	. = ..()
	linked_action = new(src)

/obj/item/melee/sickly_blade/attack(mob/living/M, mob/living/user)
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user,"<span class='danger'>You feel a pulse of some alien intellect lash out at your mind!</span>")
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return FALSE
	return ..()

/obj/item/melee/sickly_blade/pickup(mob/user)
	. = ..()
	linked_action.Grant(user, src)

/obj/item/melee/sickly_blade/dropped(mob/user, silent)
	. = ..()
	linked_action.Remove(user, src)

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return
	var/list/knowledge = cultie.get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/eldritch_knowledge_datum = knowledge[X]
		if(proximity_flag)
			eldritch_knowledge_datum.on_eldritch_blade(target,user,proximity_flag,click_parameters)
		else
			eldritch_knowledge_datum.on_ranged_attack_eldritch_blade(target,user,click_parameters)

/obj/item/melee/sickly_blade/rust
	name = "\improper Rusted Blade"
	desc = "This crescent blade is decrepit, wasting to rust. Yet still it bites, ripping flesh and bone with jagged, rotten teeth."
	icon_state = "rust_blade"
	item_state = "rust_blade"

/obj/item/melee/sickly_blade/ash
	name = "\improper Ashen Blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	item_state = "ash_blade"

/obj/item/melee/sickly_blade/flesh
	name = "\improper Flesh Blade"
	desc = "A crescent blade born from a fleshwarped creature. Keenly aware, it seeks to spread to others the suffering it has endured from its dreadful origins."
	icon_state = "flesh_blade"
	item_state = "flesh_blade"

/obj/item/melee/spear_of_destiny
	name = "Spear Of Destiny"
	desc = "A relic weapon, a symbol of power. You can see a single nail held to the tip of it by what seems to be pure energy..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "longinus"
	item_state = "longinus"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	force = 25
	block_level = 1
	block_upgrade_walk = 1
	throwforce = 30
	attack_verb = list("tears", "lacerates", "rips", "dices", "rends", "pierces", "cleanses")
	throw_speed = 5

/obj/item/melee/spear_of_destiny/attack(mob/living/M, mob/living/user)
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user,"<span class='danger'>You feel a pulse of some alien intellect lash out at your mind!</span>")
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return FALSE
	return ..()

/obj/item/melee/spear_of_destiny/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !isturf(hit_atom))
		return
	emplode(hit_atom)

/obj/item/melee/spear_of_destiny/proc/emplode(turf/C) //Explodes if you throw it at someone
	var/turf/T = get_turf(C)
	playsound(src, 'sound/magic/lightningbolt.ogg', 50, TRUE)
	qdel(src)
	explosion(T, 0, 0, 2, 0, TRUE, FALSE, 1, FALSE, FALSE)

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulsing of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	///What trait do we want to add upon equipiing
	var/trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && user.mind && slot == ITEM_SLOT_NECK)   //Heretics are one of the few solo antags that don't give anything in return for killing them, a small trinket like an amulet that won't always be there is nothing much
		ADD_TRAIT(user, trait, CLOTHING_TRAIT)
		user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, trait, CLOTHING_TRAIT)
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "Piercing Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into impossible shapes."
	trait = TRAIT_XRAY_VISION

/obj/item/clothing/neck/eldritch_amulet/dampening
	name = "Dampening Eldritch Medallion"
	desc = "A strange medallion. Trying to touch it repels your finger like if two magnets of the same sides were brought together. It's impossibly hard to break and just gazing at it makes you uncomfortable."

/obj/item/clothing/neck/eldritch_amulet/dampening/equipped(mob/living/carbon/human/H, slot) // not gonna make a trait for a specific armor amount
	. = ..()
	if(H.mind && slot == ITEM_SLOT_NECK)
		H.physiology.brute_mod *= 0.90
		H.physiology.burn_mod *= 0.90

/obj/item/clothing/neck/eldritch_amulet/dampening/dropped(mob/living/carbon/human/H)
	. = ..()
	H.physiology.brute_mod = initial(H.physiology.brute_mod)
	H.physiology.burn_mod = initial(H.physiology.burn_mod)

/obj/item/clothing/neck/eldritch_amulet/ward
	name = "Holy Ward"
	desc = "This silver-encrusted ward designed by the old Church of Earth was used to prevent witches from using magic during burnings at the stake. This relic has been recreated by Nanotrasen in heresy fighting efforts."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "petcollar"
	item_color = "petcollar"
	trait = TRAIT_ELDRITCH_WARD

////// HOODS AND ROBES//////
/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	clothing_flags = THICKMATERIAL
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	flash_protect = 1
	bang_protect = 1

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	item_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	clothing_flags = THICKMATERIAL
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	// slightly better than normal cult robes. Hi KazooBard here, added a lot of bomb resist so the crew doesn't result to suicide bombing and causing mass collateral.
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 100, "bio" = 20, "rad" = 0, "fire" = 20, "acid" = 20, "stamina" = 50)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	name = "The candlewick"

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	name = "The Diadem of Blood"
	icon = 'icons/obj/clothing/flesh.dmi'
	icon_state = "worn_hooded"

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	name = "The Martyr's Crown of Thorns"
	icon = 'icons/obj/clothing/rust.dmi'
	icon_state = "hood"

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash
	name = "Cleanser's Robes"
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 100, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 50, "stamina" = 50) //DONT BOMB THE F*CKING HERETIC. boom syrignes work okay I guess but they are going to be tough-ish against bombs
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	var/mob/living/carbon/human/local_wearer


/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING && ishuman(user) && user.mind)
		local_wearer = user
		START_PROCESSING(SSobj,src)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/dropped(mob/M)
	local_wearer = null
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/process()
	if(!local_wearer)
		return PROCESS_KILL

	for(var/mob/living/carbon/human/human_in_range in viewers(10,local_wearer))
		if(IS_HERETIC(human_in_range) || IS_HERETIC_MONSTER(human_in_range) && !HAS_TRAIT(human_in_range, TRAIT_WARDED))
			continue

		SEND_SIGNAL(human_in_range,COMSIG_HUMAN_VOID_MASK_ACT,rand(-1,-10))

		if(prob(30))
			human_in_range.fire_stacks += 1

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh
	name = "Witch's Gown"
	armor = list("melee" = 60, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 100, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50, "stamina" = 50)
	icon = 'icons/obj/clothing/flesh.dmi'
	icon_state = "inhand_robes"
	item_state = "worn"
	w_class = WEIGHT_CLASS_BULKY
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust
	name = "Martyr's Rags"
	armor = list("melee" = 60, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 100, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50, "stamina" = 50)
	var/mob/living/carbon/human/local_wearer_rust
	icon = 'icons/obj/clothing/rust.dmi'
	icon_state = "icon_robe"
	item_state = "worn"
	w_class = WEIGHT_CLASS_BULKY
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust


/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING && ishuman(user) && user.mind)
		local_wearer_rust = user
		START_PROCESSING(SSobj,src)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/dropped(mob/M)
	local_wearer_rust = null
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/process(list/targets, mob/user = usr)
	if(!local_wearer_rust)
		return PROCESS_KILL
	else
		for(var/turf/T in targets)
			var/chance = 100 - (max(get_dist(T,local_wearer_rust),1)-1)*100/(2)
			if(!prob(chance))
				continue
			else
				T.rust_heretic_act()

/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the closed minded, yet refreshing to those with knowledge of the beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldrich_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)

/obj/item/clothing/mask/void_mask
	name = "Mask Of Madness"
	desc = "Mask created from the suffering of existance, you can look down it's eyes, and notice something gazing back at you."
	icon_state = "mad_mask"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	///Who is wearing this
	var/mob/living/carbon/human/local_user

/obj/item/clothing/mask/void_mask/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_MASK && ishuman(user) && user.mind)
		local_user = user
		START_PROCESSING(SSobj,src)

		if(IS_HERETIC(user) || IS_HERETIC_MONSTER(user))
			return
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/clothing/mask/void_mask/dropped(mob/M)
	local_user = null
	STOP_PROCESSING(SSobj,src)
	REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	return ..()

/obj/item/clothing/mask/void_mask/process()
	if(!local_user)
		return PROCESS_KILL

	if((IS_HERETIC(local_user) || IS_HERETIC_MONSTER(local_user)) && HAS_TRAIT(src,TRAIT_NODROP))
		REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

	for(var/mob/living/carbon/human/human_in_range in viewers(9,local_user))
		if(IS_HERETIC(human_in_range) || IS_HERETIC_MONSTER(human_in_range))
			continue

		SEND_SIGNAL(human_in_range,COMSIG_HUMAN_VOID_MASK_ACT,rand(-1,-10))

		if(prob(60))
			human_in_range.hallucination += 5

		if(prob(40))
			human_in_range.Jitter(5)

		if(prob(30))
			human_in_range.emote(pick("giggle","laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(prob(25))
			human_in_range.Dizzy(5)

/obj/item/clothing/neck/crucifix
	name = "crucifix"
	desc = "In the eventuality that one of those you falesly accused is, in fact, a real witch, this will ward you against their curses."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/obj/objects.dmi'
	icon_state = "crucifix"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/crucifix/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_NECK && istype(user))
		ADD_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/clothing/neck/crucifix/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/clothing/neck/crucifix/rosary
	name = "rosary beads"
	desc = "A wooden crucifix meant to ward off curses and hexes."
	resistance_flags = FLAMMABLE
	icon_state = "rosary"
