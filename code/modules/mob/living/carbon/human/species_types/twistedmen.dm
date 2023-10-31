// Icewalkers made for Spooktober 2023

/datum/species/twistedmen

	name = "\improper Twisted man"
	plural_form = "Twisted men"
	id = SPECIES_TWISTED
	sexes = 0
	species_traits = list(NOBLOOD,NOHUSK,NOREAGENTS,NO_UNDERWEAR,NOEYESPRITES,REVIVESBYHEALING)
	inherent_traits = list(TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_LIMBATTACHMENT,TRAIT_NOMETABOLISM,TRAIT_NOGUNS, TRAIT_SNOWSTORMIMMUNE)
	inherent_biotypes = list(MOB_UNDEAD,MOB_HUMANOID)
	no_equip = list(ITEM_SLOT_HEAD, //All of them
					ITEM_SLOT_MASK,
					ITEM_SLOT_EYES,
					ITEM_SLOT_EARS,
					ITEM_SLOT_NECK,
					ITEM_SLOT_OCLOTHING,
					ITEM_SLOT_ICLOTHING,
					ITEM_SLOT_ID,
					ITEM_SLOT_BACK,
					ITEM_SLOT_BELT,
					ITEM_SLOT_HANDS,
					ITEM_SLOT_LPOCKET,
					ITEM_SLOT_RPOCKET,
					ITEM_SLOT_GLOVES,
					ITEM_SLOT_FEET,
					ITEM_SLOT_ICLOTHING,
					ITEM_SLOT_SUITSTORE)
	damage_overlay_type = "" //normal sprite already shows wounds, likely to remain empty
	changesource_flags = MIRROR_BADMIN //The species is not balanced for normal rounds, considering leaving this empty
	species_language_holder = /datum/language_holder/twistedmen

	species_chest = /obj/item/bodypart/head/twisted
	species_head = /obj/item/bodypart/chest/twisted
	species_l_arm = /obj/item/bodypart/l_arm/twisted
	species_r_arm = /obj/item/bodypart/r_arm/twisted
	species_l_leg = /obj/item/bodypart/l_leg/twisted
	species_r_leg = /obj/item/bodypart/r_leg/twisted
	var/datum/action/innate/dispenser/dispenser

	mutanteyes = /obj/item/organ/eyes/twisted

/mob/living/carbon/human/species/twistedmen
	race = /datum/species/twistedmen
	faction = list("twisted")
	pass_flags = PASSBLOB //so they can pass through splinter walls

/mob/living/carbon/human/species/twistedmen/Initialize(mob/living/carbon/C)
	..()
	deathsound = pick('sound/voice/twisted/twisteddeath_1.ogg',
					'sound/voice/twisted/twisteddeath_2.ogg',
					'sound/voice/twisted/twisteddeath_3.ogg')

/mob/living/carbon/human/species/twistedmen/Login()
	..()
	mind.add_antag_datum(/datum/antagonist/twistedmen)



/datum/species/twistedmen/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		dispenser = new
		dispenser.Grant(C)
	C.fully_replace_character_name(null, pick("Yoka", "Drak", "Loso", "Arta", "Weyh", "Ines", "Toth", "Fara", "Amar", "Eske", "Reth", "Dedo", "Btoh", "Nikt", "Neth",
		"Kanas", "Garis", "Uloft", "Tarat", "Khari", "Thnor", "Rekka", "Ragga", "Rfikk", "Harfr", "Andid", "Ethra", "Dedol", "Totum",
		"Ntrath", "Keriam"))

/datum/species/twistedmen/get_scream_sound(mob/living/carbon/user)
	return pick(
		'sound/voice/twisted/twistedscream_1.ogg',
		'sound/voice/twisted/twistedscream_2.ogg',
		'sound/voice/twisted/twistedscream_3.ogg',
		'sound/voice/twisted/twistedscream_4.ogg',
	)

/datum/species/twistedmen/get_laugh_sound(mob/living/carbon/user)
	return pick(
		'sound/voice/twisted/twistedlaugh_1.ogg',
		'sound/voice/twisted/twistedlaugh_2.ogg',
		'sound/voice/twisted/twistedlaugh_3.ogg',
		'sound/voice/twisted/twistedlaugh_4.ogg',
	)

/datum/species/twistedmen/get_species_description()
	return "A twisted husk of flesh and metal, haunting the wastes of Iceland in search of sacrifices to offer to the Unshaped."

/datum/species/twistedmen/get_species_lore()
	return list("Shapeless shadows roaming the wastes of Iceland, these ominous creatures bear strange ressemblances to humans and are highly aggressive. They seem to be in a state of constant agony, their defiled bodies made of a twisted metal and flesh, a trickle of blood pouring out of what seems to be wounds. They band together in settlements and organize hunting parties to find victims to brutally sacrifice in honor of their terrible god.")

/datum/species/twistedmen/spec_revival(mob/living/carbon/human/H)
	H.notify_ghost_cloning("Your mangled body has been repaired!")
	H.grab_ghost()
	INVOKE_ASYNC(src, PROC_REF(declare_revival), H)
	H.update_body()

/datum/species/twistedmen/proc/declare_revival(mob/living/carbon/human/H)
	H.set_resting(TRUE, TRUE)
	H.say("...")
	sleep(4 SECONDS)
	if(H.stat == DEAD)
		return
	H.emote("laugh")
	H.set_resting(FALSE, TRUE)

/datum/species/twistedmen/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	. = ..()
	target.pass_flags |= PASSBLOB

/mob/living/carbon/human/species/twistedmen/stop_pulling()
	if(!istype(pulling, /mob/living/carbon/human/species/twistedmen))
		pulling.pass_flags &= ~PASSBLOB
	. = ..()

/obj/item/bodypart/l_arm/twisted/attach_limb(mob/living/carbon/C, special, is_creating)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate_welder), C), 2) //Just enough time for the open hand to be valid. Yes this is hacky af

/obj/item/bodypart/l_arm/twisted/proc/activate_welder(mob/living/carbon/C)
	var/hand =  C.get_empty_held_index_for_side("l")
	if(hand)
		welder = new/obj/item/weldingtool/infinite
		if(!C.put_in_hand(welder, hand, TRUE))
			qdel(welder)

/obj/item/organ/eyes/twisted
	name = "twisted eyes"
	desc = "Shields the twisted from the bright lights their arc-welders emit."
	flash_protect = 2
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/datum/action/innate/dispenser
	name = "Flesh craft"
	desc = "Craft tools using chunks of your body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "transmute"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'//NEEDS ICON
	background_icon_state = "bg_cult"
	COOLDOWN_DECLARE(dispense_cooldown)

/datum/action/innate/dispenser/Activate()
	if(!COOLDOWN_FINISHED(src,dispense_cooldown))
		return
	var/list/dispense_list = list(
		"Zipties" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "cuff_blood"),//NEEDS ICON (?)
		"Bola" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "bola"),//NEEDS ICON (?)
		"Shield" = image(icon = 'icons/obj/shields.dmi', icon_state = "twisted"),)//NEEDS ICON (?)
	var/choice = show_radial_menu(owner, owner, dispense_list, radius = 42)
	switch(choice)
		if("Zipties")
			choice = new /obj/item/restraints/handcuffs/cable/zipties/blood/twisted
		if("Bola")
			choice = new /obj/item/restraints/legcuffs/bola/watcher/twisted
		if("Shield")
			choice = new /obj/item/shield/riot/twisted
	if(!choice)
		return
	if(!owner.put_in_active_hand(choice))
		to_chat(owner, "<span class='warning'>Your hand is full!</span>")//NEEDS LOCALIZATION
		qdel(choice)
		return
	to_chat(owner, "<span class='warning'>You fabricate [choice]!</span>")//NEEDS LOCALIZATION
	COOLDOWN_START(src,dispense_cooldown,10 SECONDS)

/obj/item/restraints/handcuffs/cable/zipties/blood/twisted
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/blood/twisted_used

/obj/item/restraints/handcuffs/cable/zipties/blood/twisted/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(crumble), src)

/obj/item/restraints/handcuffs/cable/zipties/blood/twisted/proc/crumble()
	visible_message("<span class='warning'>the [src] crumbles away!</span>")
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	qdel(src)

/obj/item/restraints/handcuffs/cable/zipties/blood/twisted/apply_cuffs(mob/living/carbon/target, mob/user, var/dispense = 0)
	. = ..()
	target.adjustFireLoss(-25)
	target.adjustBruteLoss(-25)
	target.adjustOxyLoss(25)

/obj/item/restraints/handcuffs/cable/zipties/blood/twisted_used/Initialize()
	visible_message("<span class='warning'>the restraints crumbles away!</span>")
	qdel(src) //hacky, but we don't actually want these to stick around after use.

/obj/item/restraints/legcuffs/bola/watcher/twisted
	name = "twisted bola"
	desc = "A Bola made from inside of one of the twisted"
	icon_state = "bola_watcher"
	item_state = "bola_watcher"
	knockdown = 2 SECONDS
	breakouttime = 4 SECONDS //The bola crumbles in this same time period anyway

/obj/item/restraints/legcuffs/bola/watcher/twisted/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(crumble_timed), src)

/obj/item/restraints/legcuffs/bola/watcher/twisted/proc/crumble_timed()
	addtimer(CALLBACK(src, PROC_REF(crumble)), breakouttime + 1 SECONDS) //Flight will not last more than a second anyway

/obj/item/restraints/legcuffs/bola/watcher/twisted/ensnare(mob/living/carbon/C)
	..()
	addtimer(CALLBACK(src, PROC_REF(crumble)), breakouttime)

/obj/item/restraints/legcuffs/bola/watcher/twisted/proc/crumble()
	visible_message("<span class='warning'>the [src] crumbles away!</span>")
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	qdel(src)

/obj/item/shield/riot/twisted
	name = "twisted shield"
	desc = "an amalgamation of metal and flesh mashed with one another to serve as a shield. Reflects light at the right angle, blood drips from it."
	icon_state = "twisted"
	item_state = "twisted"
	lefthand_file = 'icons/mob/inhands/halloween/twistedl.dmi'
	righthand_file = 'icons/mob/inhands/halloween/twistedr.dmi'
	transparent = FALSE
	max_integrity =  65 //Can block up to 7 laser attacks and a moderate amount of melee.
	block_power = 0

/obj/item/shield/riot/twisted/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(crumble), src)

/obj/item/shield/riot/twisted/shatter(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	var/obj/item/bodypart/BP
	if(owner.get_active_hand() == BODY_ZONE_PRECISE_L_HAND)
		BP = owner.get_bodypart(BODY_ZONE_L_ARM)
	else
		BP = owner.get_bodypart(BODY_ZONE_R_ARM)
	BP.dismember()
	crumble()

/obj/item/shield/riot/twisted/proc/crumble()
	visible_message("<span class='warning'>the [src] crumbles away!</span>")
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	qdel(src)

