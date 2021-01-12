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
		to_chat(user,"<span class='warning'>No target could be found. Put the living heart on a transmutation rune and activate the rune to recieve a target.</span>")
		return
	var/dist = get_dist(get_turf(user),get_turf(target))
	var/dir = get_dir(get_turf(user),get_turf(target))
	if(user.z != target.z)
		to_chat(user,"<span class='warning'>[target.real_name] is on another plane of existence!</span>")
	else
		switch(dist)
			if(0 to 15)
				to_chat(user,"<span class='warning'>[target.real_name] is near you. They are to the [dir2text(dir)] of you!</span>")
			if(16 to 31)
				to_chat(user,"<span class='warning'>[target.real_name] is somewhere in your vicinity. They are to the [dir2text(dir)] of you!</span>")
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
	if(IS_HERETIC(holder) || IS_HERETIC_CULTIST(holder))
		return TRUE
	else
		return FALSE

/datum/action/innate/heretic_shatter/Activate()
	var/turf/safe_turf = find_safe_turf(zlevels = sword.z, extended_safety_checks = TRUE)
	do_teleport(holder,safe_turf,forceMove = TRUE)
	to_chat(holder,"<span class='warning'>You feel a gust of energy flow through your body... the Rusted Hills heard your call...</span>")
	qdel(sword)


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
	force = 17
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	var/datum/action/innate/heretic_shatter/linked_action

/obj/item/melee/sickly_blade/Initialize()
	. = ..()
	linked_action = new(src)

/obj/item/melee/sickly_blade/attack(mob/living/M, mob/living/user)
	if(!(IS_HERETIC(user) || IS_HERETIC_CULTIST(user)))
		to_chat(user,"<span class='danger'>You feel a pulse of alien intellect lash out at your mind!</span>")
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

/obj/item/melee/sickly_blade/proc/get_cultist_user(mob/user)
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if (!cultie)
		var/datum/antagonist/heretic_monster/disciple/sucker = user.mind.has_antag_datum(/datum/antagonist/heretic_monster/disciple)
		if (sucker)
			return sucker.master
	return cultie

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/antagonist/heretic/cultie = get_cultist_user(user)
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

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulsing of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	///What trait do we want to add upon equipiing
	var/trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/living/carbon/human/user, slot)
	. = ..()

	if(slot == SLOT_NECK && user.mind && istype(user))
		if (!IS_HERETIC(user))
			return
		var/datum/antagonist/heretic_monster/disciple/D = user.mind.has_antag_datum(/datum/antagonist/heretic_monster/disciple)
		if (D && !D.can_use_magic())
			return
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

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flash_protect = 1

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	item_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book, /obj/item/living_heart)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	armor = list(MELEE = 50, BULLET = 50, LASER = 50,ENERGY = 50, BOMB = 35, BIO = 20, RAD = 0, FIRE = 20, ACID = 20)

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
	if(slot != ITEM_SLOT_MASK)
		return
	if(ishuman(user) && user.mind && slot == ITEM_SLOT_MASK)
		local_user = user
		START_PROCESSING(SSobj,src)

		if(IS_HERETIC(user) || IS_HERETIC_CULTIST(user))
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

	if((IS_HERETIC(local_user) || IS_HERETIC_CULTIST(local_user)) && HAS_TRAIT(src,TRAIT_NODROP))
		REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

	for(var/mob/living/carbon/human/human_in_range in spiral_range(9,local_user))
		if(IS_HERETIC(human_in_range) || IS_HERETIC_CULTIST(human_in_range))
			continue

		SEND_SIGNAL(human_in_range,COMSIG_VOID_MASK_ACT,rand(-1,-10))

		if(prob(60))
			human_in_range.hallucination += 5

		if(prob(40))
			human_in_range.Jitter(5)

		if(prob(30))
			human_in_range.emote(pick("giggle","laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(prob(25))
			human_in_range.Dizzy(5)

/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	item_flags = EXAMINE_SKIP
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	icon_state = "void_cloak"
	item_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book, /obj/item/living_heart)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	// slightly worse than normal cult robes
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/cultrobes/void/ToggleHood()
	if(!iscarbon(loc))
		return
	var/mob/living/carbon/carbon_user = loc
	if(IS_HERETIC(carbon_user) || IS_HERETIC_CULTIST(carbon_user))
		. = ..()
		//We need to account for the hood shenanigans, and that way we can make sure items always fit, even if one of the slots is used by the fucking hood.
		if(suittoggled)
			to_chat(carbon_user,"<span class='notice'>The light shifts around you making the cloak invisible!</span>")
		else
			to_chat(carbon_user,"<span class='notice'>The kaleidoscope of colours collapses around you, as the cloak shifts to visibility!</span>")
		item_flags = suittoggled ? EXAMINE_SKIP : ~EXAMINE_SKIP
	else
		to_chat(carbon_user,"<span class='danger'>You can't force the hood onto your head!</span>")

/obj/item/melee/rune_knife
	name = "Carving Knife"
	desc = "Cold Steel, pure, perfect, this knife can carve the floor in many ways, but only few can evoke the dangers that lurk beneath reality."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "rune_carver"
	flags_1 = CONDUCT_1
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	throwforce = 20
	embedding = list(embed_chance=75, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=5, rip_time=15)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	///turfs that you cannot draw carvings on
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava))
	///A check to see if you are in process of drawing a rune
	var/drawing = FALSE
	///A list of current runes
	var/list/current_runes = list()
	///Max amount of runes
	var/max_rune_amt = 3
	///Linked action
	var/datum/action/innate/rune_shatter/linked_action

/obj/item/melee/rune_knife/examine(mob/user)
	. = ..()
	. += "This item can carve 'Alert carving' - nearly invisible rune that when stepped on gives you a prompt about where someone stood on it and who it was, doesn't get destroyed by being stepped on."
	. += "This item can carve 'Grasping carving' - when stepped on it causes heavy damage to the legs and stuns for 5 seconds."
	. += "This item can carve 'Mad carving' - when stepped on it causes dizzyness, jiterryness, temporary blindness, confusion , stuttering and slurring."

/obj/item/melee/rune_knife/Initialize()
	. = ..()
	linked_action = new(src)

/obj/item/melee/rune_knife/Destroy()
	. = ..()
	QDEL_NULL(linked_action)

/obj/item/melee/rune_knife/pickup(mob/user)
	. = ..()
	linked_action.Grant(user, src)

/obj/item/melee/rune_knife/dropped(mob/user, silent)
	. = ..()
	linked_action.Remove(user, src)

/obj/item/melee/rune_knife/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!is_type_in_typecache(target,blacklisted_turfs) && !drawing && proximity_flag)
		carve_rune(target,user,proximity_flag,click_parameters)

///Action of carving runes, gives you the ability to click on floor and choose a rune of your need.
/obj/item/melee/rune_knife/proc/carve_rune(atom/target, mob/user, proximity_flag, click_parameters)
	var/obj/structure/trap/eldritch/elder = locate() in range(1,target)
	if(elder)
		to_chat(user,"<span class='notice'>You can't draw runes that close to each other!</span>")
		return

	for(var/_rune_ref in current_runes)
		var/datum/weakref/rune_ref = _rune_ref
		if(!rune_ref.resolve())
			current_runes -= rune_ref

	if(current_runes.len >= max_rune_amt)
		to_chat(user,"<span class='notice'>The blade cannot support more runes!</span>")
		return

	var/list/pick_list = list()
	for(var/E in subtypesof(/obj/structure/trap/eldritch))
		var/obj/structure/trap/eldritch/eldritch = E
		pick_list[initial(eldritch.name)] = eldritch

	drawing = TRUE

	var/type = pick_list[input(user,"Choose the rune","Rune") as null|anything in pick_list ]
	if(!type)
		drawing = FALSE
		return


	to_chat(user,"<span class='notice'>You start drawing the rune...</span>")
	if(!do_after(user,5 SECONDS,target = target))
		drawing = FALSE
		return

	drawing = FALSE
	var/obj/structure/trap/eldritch/eldritch = new type(target)
	eldritch.set_owner(user)
	current_runes += WEAKREF(eldritch)

/datum/action/innate/rune_shatter
	name = "Rune break"
	desc = "Destroys all runes that were drawn by this blade."
	background_icon_state = "bg_ecult"
	button_icon_state = "rune_break"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	///Reference to the rune knife it is inside of
	var/obj/item/melee/rune_knife/sword

/datum/action/innate/rune_shatter/Grant(mob/user, obj/object)
	sword = object
	return ..()

/datum/action/innate/rune_shatter/Activate()
	for(var/_rune_ref in sword.current_runes)
		var/datum/weakref/rune_ref = _rune_ref
		qdel(rune_ref.resolve())
	sword.current_runes.Cut()

/obj/item/eldritch_potion
	name = "Brew of Day and Night"
	desc = "You should never see this"
	icon = 'icons/obj/eldritch.dmi'
	///Typepath to the status effect this is supposed to hold
	var/status_effect

/obj/item/eldritch_potion/attack_self(mob/user)
	. = ..()
	to_chat(user,"<span class='notice'>You drink the potion and with the viscous liquid, the glass dematerializes.</span>")
	effect(user)
	qdel(src)

///The effect of the potion if it has any special one, in general try not to override this and utilize the status_effect var to make custom effects.
/obj/item/eldritch_potion/proc/effect(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbie = user
	carbie.apply_status_effect(status_effect)

/obj/item/eldritch_potion/crucible_soul
	name = "Brew of Crucible Soul"
	desc = "Allows you to phase through walls for 15 seconds, after the time runs out, you get teleported to your original location."
	icon_state = "crucible_soul"
	status_effect = /datum/status_effect/crucible_soul

/obj/item/eldritch_potion/duskndawn
	name = "Brew of Dusk and Dawn"
	desc = "Allows you to see clearly through walls and objects for 60 seconds."
	icon_state = "clarity"
	status_effect = /datum/status_effect/duskndawn

/obj/item/eldritch_potion/wounded
	name = "Brew of Wounded Soldier"
	desc = "For the next 60 seconds each wound will heal you, minor wounds heal 1 of it's damage type per second, moderate heal 3 and critical heal 6. You also become immune to damage slowdon."
	icon_state = "marshal"
	status_effect = /datum/status_effect/marshal

/obj/item/clothing/neck/crucifix
	name = "crucifix"
	desc = "In the eventuality that one of those you falesly accused is, in fact, a real witch, this will ward you against their curses."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "crucifix"
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/crucifix/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_NECK && istype(user))
		ADD_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)
		user.update_sight()

/obj/item/clothing/neck/crucifix/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)
	user.update_sight()

/obj/item/clothing/neck/crucifix/rosary
	name = "rosary beads"
	desc = "A wooden crucifix meant to ward of curses and hexes."
	resistance_flags = FLAMMABLE
	icon_state = "rosary"

#define GOD_YOUTH 1
#define GOD_SIGHT 2
#define GOD_MIND 3
#define GOD_CLEANSE 4
#define GOD_MEND 5
#define GOD_CAUTERIZE 6
#define GOD_BLIND 7
#define GOD_MUTE 8
#define GOD_STUPID 9
#define GOD_HURT 10
#define GOD_BURN 11
#define GOD_PARALIZE 12
#define GOD_DISABLE 13
#define GOD_EMP 14
#define GOD_MADNESS 15
#define GODS_MAX 15

/obj/item/artifact
	name = "strange figurine"
	desc = "A stone statuette of some sort."
	var/inUse = FALSE
	var/deity
	var/godname = "C'Thulhu"
	var/activated = FALSE
	var/ashes = FALSE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "figure"

/obj/item/artifact/Initialize()
	..()
	deity = rand(1,GODS_MAX)
	switch (deity)
		if (GOD_YOUTH)
			godname = "Lobon"
		if (GOD_SIGHT)
			godname = "Nath-Horthath"
		if (GOD_MIND)
			godname = "Oukranos"
		if (GOD_CLEANSE)
			godname = "Tamash"
		if (GOD_MEND)
			godname = "Karakal"
		if (GOD_CAUTERIZE)
			godname = "D’endrrah"
		if (GOD_BLIND)
			godname = "Azathoth"
		if (GOD_MUTE)
			godname = "Abhoth"
		if (GOD_STUPID)
			godname = "Aiueb Gnshal"
		if (GOD_HURT)
			godname = "Ialdagorth"
		if (GOD_BURN)
			godname = "Tulzscha"
		if (GOD_PARALIZE)
			godname = "C'thalpa"
		if (GOD_DISABLE)
			godname = "Mh'ithrha"
		if (GOD_EMP)
			godname = "Shabbith-Ka"
		if (GOD_MADNESS)
			godname = "Yomagn'tho"

/obj/item/artifact/examine(mob/user)
	. = ..()
	if (!ashes)
		var/mob/living/carbon/C = user
		var/datum/antagonist/heretic_monster/disciple/dantag = C.mind.has_antag_datum(/datum/antagonist/heretic_monster/disciple)
		if((C.job in list("Curator")) || IS_HERETIC(C) || dantag)
			if (deity <= 6)
				. += "You identify it as an avatar of [godname], one of the earth's weak gods."	//the weak gods of earth watch out for their creations, so they offer beneficial boons
			else
				. += "You identify it as an avatar of [godname], one of the forbidden gods."				//forbidden gods on the other side...
		if (IS_HERETIC(C) || dantag)
			if (!activated)
				. += "Use in hand to perform a ritual for [godname], granting this [src] magical powers."
			else
				var/boon = "The [name] will offer the boon of [godname], "
				switch (deity)
					if (GOD_YOUTH)
						boon += "fixing one's organs."
					if (GOD_SIGHT)
						boon += "bringing back one's vision."
					if (GOD_MIND)
						boon += "restoring one's sanity and mind."
					if (GOD_CLEANSE)
						boon += "purging one's body of inpurities."
					if (GOD_MEND)
						boon += "healing one's burned flesh."
					if (GOD_CAUTERIZE)
						boon += "bringing back one's vision."
					if (GOD_BLIND)
						boon += "making one blind."
					if (GOD_MUTE)
						boon += "halting one's speech."
					if (GOD_STUPID)
						boon += "making one stupid."
					if (GOD_HURT)
						boon += "inflicting wounds."
					if (GOD_BURN)
						boon += "causing one's skin to burn."
					if (GOD_PARALIZE)
						boon += "crippling one's legs."
					if (GOD_DISABLE)
						boon += "crippling one's hands."
					if (GOD_EMP)
						boon += "crippling one's hands."
					if (GOD_MADNESS)
						boon += "bringing madness into one's mind."
				. += boon

			var/datum/antagonist/heretic/her = user.mind.has_antag_datum(/datum/antagonist/heretic)
			if (!ashes && !her.has_deity(deity))
				. += "Performing a ritual for [godname] will also grant you favor."

/obj/item/artifact/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(proximity_flag)
		if (HAS_TRAIT(target,TRAIT_WARDED))
			user.visible_message("<span class='notice'>You hex [target] with the blessing of [godname]!</span>","<span class='danger'>[user] performs a strange ritual with the [src]!</span>")
			to_chat(user,"<span class='warning'>[target] is warded against your cruse!</span>")
			to_chat(target,"<span class='warning'>Your crucifix protects you against [user]'s curse!</span>")
		else if (infuse_blessing(user,target))
			user.visible_message("<span class='notice'>You hex [target] with the blessing of [godname]!</span>","<span class='danger'>[user] performs a strange ritual with the [src]!</span>")
		if (ashes)
			qdel(src)

/obj/item/artifact/attack_self(mob/user)
	. = ..()
	if (!inUse)
		inUse = TRUE
		if (!activated && IS_HERETIC(user))
			var/datum/antagonist/heretic/her = user.mind.has_antag_datum(/datum/antagonist/heretic)
			to_chat(user,"<span class='notice'>You start a praying towards [godname]!</span>")
			if (do_after(user,5 SECONDS))
				var/result = "The prayer is complete"
				if (!activated)
					result += ". You activated the [src] with the blessing of [godname]"
				if (!her.has_deity(deity))
					result += " and you gained the favor of [godname]"
					her.gain_favor(1)
				to_chat(user,"<span class='notice'>[result].</span>")
				activated = TRUE
				her.gain_deity(deity)
				return TRUE
		else if (infuse_blessing(user,user))
			user.visible_message("<span class='notice'>You strike yourself with the blessing of [godname]!</span>","<span class='danger'>[user] performs a strange ritual with the [src]!</span>")
		inUse = FALSE
	if (ashes)
		qdel(src)

/obj/item/artifact/proc/infuse_blessing(mob/living/user,mob/living/carbon/human/target)
	if (!activated)
		return FALSE
	switch (deity)
		if (GOD_YOUTH)
			target.adjustOrganLoss(ORGAN_SLOT_HEART,-5)
			target.adjustOrganLoss(ORGAN_SLOT_LIVER,-5)
			target.adjustOrganLoss(ORGAN_SLOT_STOMACH,-5)
			target.adjustOrganLoss(ORGAN_SLOT_LUNGS,-5)
			to_chat(target,"<span class='notice'>You feel younger!</span>")
		if (GOD_SIGHT)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,-10)
			to_chat(target,"<span class='notice'>Your vision feels sharper!</span>")
		if (GOD_MIND)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,-10)
			to_chat(target,"<span class='notice'>You can think more clearly!</span>")
		if (GOD_CLEANSE)
			target.adjustToxLoss(-10)
			to_chat(target,"<span class='notice'>You feel refreshed!</span>")
		if (GOD_MEND)
			target.adjustFireLoss(-10)
			to_chat(target,"<span class='notice'>Your skin tickles!</span>")
		if (GOD_CAUTERIZE)
			target.adjustBruteLoss(-10)
			to_chat(target,"<span class='notice'>Your bruises heal!</span>")
		if (GOD_BLIND)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,10)
			to_chat(target,"<span class='warning'>Your eyes sting!</span>")
		if (GOD_MUTE)
			target.adjustOrganLoss(ORGAN_SLOT_TONGUE,8)
			target.silent += 3 SECONDS
		if (GOD_STUPID)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,8)
			to_chat(target,"<span class='warning'>Your feel confused!</span>")
		if (GOD_HURT)
			target.adjustBruteLoss(5)
			to_chat(target,"<span class='warning'>Your flesh hurts!</span>")
		if (GOD_BURN)
			target.adjustFireLoss(5)
			to_chat(target,"<span class='warning'>Your skin burns!</span>")
		if (GOD_PARALIZE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == LEG_RIGHT || organ.body_part == LEG_LEFT)
					organ.receive_damage(stamina = 5)
			to_chat(target,"<span class='warning'>Your legs tingle!</span>")
		if (GOD_DISABLE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == ARM_RIGHT || organ.body_part == ARM_LEFT)
					organ.receive_damage(stamina = 5)
			to_chat(target,"<span class='warning'>Your arms tingle!</span>")
		if (GOD_EMP)
			target.emp_act(EMP_LIGHT)
			to_chat(target,"<span class='warning'>That was weird!</span>")
		if (GOD_MADNESS)
			if(HAS_TRAIT(target, TRAIT_PACIFISM))
				REMOVE_TRAIT(target, TRAIT_PACIFISM,TRAIT_GENERIC)	//remove any and all?
			to_chat(target,"<span class='warning'>Your feel that evil overcomes you!</span>")
	return TRUE

/obj/item/artifact/proc/to_ashes(mob/living/usr)
	var/god = deity
	var/name = godname
	to_chat(usr,"<span class='notice'>You crush the [src] into your burning hand. The resulting goofer dust can be used to inflict a stronger effect on the target.</span>")

	qdel(src)

	var/obj/item/artifact/ashes/new_item = new(usr.loc)
	new_item.deity = god
	new_item.godname = name

/obj/item/artifact/ashes
	name = "goofer dust"
	desc = "Ritualistic dust used to curse mortals."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	activated = TRUE
	ashes = TRUE

/obj/item/artifact/ashes/to_ashes(mob/living/usr)
	return

/obj/item/artifact/ashes/infuse_blessing(mob/living/user,mob/living/carbon/human/target)
	switch (deity)
		if (GOD_YOUTH)
			target.adjustOrganLoss(ORGAN_SLOT_HEART,-100)
			target.adjustOrganLoss(ORGAN_SLOT_LIVER,-100)
			target.adjustOrganLoss(ORGAN_SLOT_STOMACH,-100)
			target.adjustOrganLoss(ORGAN_SLOT_LUNGS,-100)
		if (GOD_SIGHT)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,-80)
		if (GOD_MIND)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,-50)
			target.SetSleeping(0)
		if (GOD_CLEANSE)
			target.adjustToxLoss(-50)
		if (GOD_MEND)
			target.adjustFireLoss(-50)
		if (GOD_CAUTERIZE)
			target.adjustBruteLoss(-50)
		if (GOD_BLIND)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,40)
		if (GOD_MUTE)
			target.adjustOrganLoss(ORGAN_SLOT_TONGUE,50)
			target.silent += 10 SECONDS
		if (GOD_STUPID)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,15)
			target.SetSleeping(10 SECONDS)
		if (GOD_HURT)
			target.adjustBruteLoss(20)
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			if(!target.anchored)
				target.throw_at(throw_target, rand(4,8), 14, user)
		if (GOD_BURN)
			target.adjustFireLoss(20)
			target.IgniteMob()
		if (GOD_PARALIZE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == LEG_RIGHT || organ.body_part == LEG_LEFT)
					organ.receive_damage(stamina = 200)
		if (GOD_DISABLE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == ARM_RIGHT || organ.body_part == ARM_LEFT)
					organ.receive_damage(stamina = 200)
		if (GOD_EMP)
			target.electrocute_act(12, safety=TRUE, stun = FALSE)
			target.emp_act(EMP_HEAVY)	//was gonna make it emag, but I figured this is just as good
		if (GOD_MADNESS)
			var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
			if (master)
				master.enslave(target)

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, target)
	smoke.start()

	return TRUE

#undef GOD_YOUTH
#undef GOD_SIGHT
#undef GOD_MIND
#undef GOD_CLEANSE
#undef GOD_MEND
#undef GOD_CAUTERIZE
#undef GOD_BLIND
#undef GOD_MUTE
#undef GOD_STUPID
#undef GOD_HURT
#undef GOD_BURN
#undef GOD_PARALIZE
#undef GOD_DISABLE
#undef GOD_EMP
#undef GOD_MADNESS
#undef GODS_MAX