/obj/item/living_heart
	name = "Living Heart"
	desc = "Link to the worlds beyond."
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
		to_chat(user,"<span class='warning'>No target could be found. Put the living heart on the rune and use the rune to recieve a target.</span>")
		return
	var/dist = get_dist(user.loc,target.loc)
	var/dir = get_dir(user.loc,target.loc)
	if(user.z != target.z)
		to_chat(user,"<span class='warning'>[target.real_name] is on another plane of existance!</span>")
	else
		switch(dist)
			if(0 to 15)
				to_chat(user,"<span class='warning'>[target.real_name] is near you. They are to the [dir2text(dir)] of you!</span>")
			if(16 to 31)
				to_chat(user,"<span class='warning'>[target.real_name] is somewhere in your vicinty. They are to the [dir2text(dir)] of you!</span>")
			else
				if (dir)
					to_chat(user,"<span class='warning'>[target.real_name] is far away from you. They are to the [dir2text(dir)] of you!</span>")
				else
					to_chat(user,"<span class='warning'>[target.real_name] is beyond our reach.</span>")

	if(target.stat == DEAD)
		to_chat(user,"<span class='warning'>[target.real_name] is dead. Bring them onto a transmutation rune!</span>")

/datum/action/innate/heretic_shatter
	name = "Shattering Offer"
	desc = "By breaking your blade you are noticed by the hill or rust and are granted an escape from a dire sitatuion. (Teleports you to a random safe z turf on your current z level but destroys your blade.)"
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
	to_chat(holder,"<span class='warning'> You feel a gust of energy flow through your body, Rusted Hills heard your call...")
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
	if(!cultie || !proximity_flag)
		return
	var/list/knowledge = cultie.get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/eldritch_knowledge_datum = knowledge[X]
		eldritch_knowledge_datum.on_eldritch_blade(target,user,proximity_flag,click_parameters)

/obj/item/melee/sickly_blade/rust
	name = "\improper Rusted Blade"
	desc = "This crescent blade is decrepit, wasting to dust. Yet still it bites, catching flesh with jagged, rotten teeth."
	icon_state = "rust_blade"
	item_state = "rust_blade"

/obj/item/melee/sickly_blade/ash
	name = "\improper Ashen Blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	item_state = "ash_blade"

/obj/item/melee/sickly_blade/flesh
	name = "\improper Flesh Blade"
	desc = "A crescent blade born from a fleshwarped creature. Keenly aware, it seeks to spread to others the excruitations it has endured from dread origins."
	icon_state = "flesh_blade"
	item_state = "flesh_blade"

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulse of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	///What trait do we want to add upon equipiing
	var/used_by_unitiated = FALSE
	var/trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/living/carbon/human/user, slot)
	. = ..()

	if(slot == SLOT_NECK && user.mind && istype(user))
		if (!used_by_unitiated)
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
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into improbable shapes."
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
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// slightly better than normal cult robes
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 35, "bio" = 20, "rad" = 0, "fire" = 20, "acid" = 20)

/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the close minded. Healing to those with knowledge of the beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldrich_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)

/obj/item/artifact
	name = "strange figurine"
	desc = "A stone statuette of some sort."
	var/inUse = FALSE
	var/deity
	var/godname = "C'Thulhu"
	var/activated = FALSE
	var/ashes = FALSE
	icon = 'icons/obj/wizard.dmi'	//temporary
	icon_state = "voodoo"

/obj/item/artifact/Initialize()
	..()
	deity = rand(1,15)
	switch (deity)
		if (1)	//force awake - sleep
			godname = "Lobon"
		if (2)	//eye heal
			godname = "Nath-Horthath"
		if (3)	//brain heal
			godname = "Oukranos"
		if (4)	//heal toxin
			godname = "Tamash"
		if (5)	//heal burn
			godname = "Karakal"
		if (6)	// heal brute
			godname = "D’endrrah"
		if (7)	// eye damage
			godname = "Azathoth"
		if (8)	//tongue damage
			godname = "Abhoth"
		if (9)	//brain damage - induce sleep
			godname = "Aiueb Gnshal"
		if (10)	//brute
			godname = "Ialdagorth"
		if (11)	//burn
			godname = "Tulzscha"
		if (12)	//paralyze legs
			godname = "C'thalpa"
		if (13)	//paralyze hands
			godname = "Mh'ithrha"
		if (14)	//emp - emag
			godname = "Shabbith-Ka"
		if (15)	// depacification - eldritch antag
			godname = "Yomagn'tho"

/obj/item/artifact/examine(mob/user)
	. = ..()
	if (!ashes)
		var/mob/living/carbon/C = user
		var/datum/antagonist/heretic_monster/disciple/dantag = C.mind.has_antag_datum(/datum/antagonist/heretic_monster/disciple)
		if((C.job in list("Curator")) || IS_HERETIC(C) || dantag)
			if (deity<=6)
				.+="You identify it as an avatar of [godname], one of the earth's weak gods."	//the weak gods of earth watch out for their creations, so they offer beneficial boons
			else
				.+="You identify it as an avatar of [godname], one of the forbidden gods."				//forbidden gods on the other side...
		if (IS_HERETIC(C) || dantag)
			if (!activated)
				.+="Use in hand to perform a ritual for [godname], granting this [src] magical powers."
			else
				var/desc = "The [name] will offer the boon of [godname], "
				switch (deity)
					if (1)
						desc += "fixing one's insides."
					if (2)
						desc += "bringing back one's vision."
					if (3)
						desc += "restoring one's sanity and mind."
					if (4)
						desc += "purging one's body of inpurities."
					if (5)
						desc += "healing one's burned flesh."
					if (6)
						desc += "bringing back one's vision."
					if (7)
						desc += "making one blind."
					if (8)
						desc += "halting one's speech."
					if (9)
						desc += "making one stupid."
					if (10)
						desc += "inflicting wounds."
					if (11)
						desc += "causing one's skin to burn."
					if (12)
						desc += "crippling one's legs."
					if (13)
						desc += "crippling one's hands."
					if (14)
						desc += "crippling one's hands."
					if (15)
						desc += "bringing madness into one's mind."
				.+=desc

			var/datum/antagonist/heretic/her = user.mind.has_antag_datum(/datum/antagonist/heretic)
			if (!ashes && !her.has_deity(deity))
				.+="Performing a ritual for [godname] will also grant you favor."

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
		if (1)
			target.adjustOrganLoss(ORGAN_SLOT_HEART,-5)
			target.adjustOrganLoss(ORGAN_SLOT_LIVER,-5)
			target.adjustOrganLoss(ORGAN_SLOT_STOMACH,-5)
			target.adjustOrganLoss(ORGAN_SLOT_LUNGS,-5)
			to_chat(target,"<span class='notice'>You feel younger!</span>")
		if (2)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,-10)
			to_chat(target,"<span class='notice'>Your vision feels sharper!</span>")
		if (3)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,-10)
			to_chat(target,"<span class='notice'>You can think more clearly!</span>")
		if (4)
			target.adjustToxLoss(-10)
			to_chat(target,"<span class='notice'>You feel refreshed!</span>")
		if (5)
			target.adjustFireLoss(-10)
			to_chat(target,"<span class='notice'>Your skin tickles!</span>")
		if (6)
			target.adjustBruteLoss(-10)
			to_chat(target,"<span class='notice'>Your bruises heal!</span>")
		if (7)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,10)
			to_chat(target,"<span class='warning'>Your eyes sting!</span>")
		if (8)
			target.adjustOrganLoss(ORGAN_SLOT_TONGUE,8)
			target.silent += 2 SECONDS
		if (9)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,8)
			to_chat(target,"<span class='warning'>Your feel confused!</span>")
		if (10)
			target.adjustBruteLoss(5)
			to_chat(target,"<span class='warning'>Your flesh hurts!</span>")
		if (11)
			target.adjustFireLoss(5)
			to_chat(target,"<span class='warning'>Your skin burns!</span>")
		if (12)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == LEG_RIGHT || organ.body_part == LEG_LEFT)
					organ.receive_damage(stamina = 5)
			to_chat(target,"<span class='warning'>Your legs tingle!</span>")
		if (13)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == ARM_RIGHT || organ.body_part == ARM_LEFT)
					organ.receive_damage(stamina = 5)
			to_chat(target,"<span class='warning'>Your arms tingle!</span>")
		if (14)
			target.emp_act(EMP_LIGHT)
			to_chat(target,"<span class='warning'>That was weird!</span>")
		if (15)
			if(HAS_TRAIT(target, TRAIT_PACIFISM))
				REMOVE_TRAIT(target, TRAIT_PACIFISM,TRAIT_GENERIC)	//remove any and all?
			to_chat(target,"<span class='warning'>Your feel an evil overcomes you!</span>")
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
		if (1)
			target.adjustOrganLoss(ORGAN_SLOT_HEART,-100)
			target.adjustOrganLoss(ORGAN_SLOT_LIVER,-100)
			target.adjustOrganLoss(ORGAN_SLOT_STOMACH,-100)
			target.adjustOrganLoss(ORGAN_SLOT_LUNGS,-100)
		if (2)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,-80)
		if (3)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,-50)
			target.SetSleeping(0)
		if (4)
			target.adjustToxLoss(-50)
		if (5)
			target.adjustFireLoss(-50)
		if (6)
			target.adjustBruteLoss(-50)
		if (7)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,40)
		if (8)
			target.adjustOrganLoss(ORGAN_SLOT_TONGUE,30)
			target.silent += 20 SECONDS
		if (9)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,15)
			target.SetSleeping(10 SECONDS)
		if (10)
			target.adjustBruteLoss(20)
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			if(!target.anchored)
				target.throw_at(throw_target, rand(4,8), 14, user)
		if (11)
			target.adjustFireLoss(20)
			target.IgniteMob()
		if (12)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == LEG_RIGHT || organ.body_part == LEG_LEFT)
					organ.receive_damage(stamina = 200)
		if (13)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == ARM_RIGHT || organ.body_part == ARM_LEFT)
					organ.receive_damage(stamina = 200)
		if (14)
			target.electrocute_act(12, safety=TRUE, stun = FALSE)
			target.emp_act(EMP_HEAVY)	//was gonna make it emag, but I figured this is just as good
		if (15)
			var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
			if (master)
				master.enslave(target)

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, target)
	smoke.start()

	return TRUE

/obj/item/clothing/neck/eldritch_amulet/crucifix
	name = "crucifix"
	desc = "In the eventuality that one of those you falesly accused is, in fact, a real witch, this will ward you against their curses."
	trait = TRAIT_WARDED
	resistance_flags = FIRE_PROOF | ACID_PROOF
	used_by_unitiated = TRUE

/obj/item/clothing/neck/eldritch_amulet/rosary
	name = "rosary beads"
	desc = "A wooden crucifix meant to ward of curses and hexes."
	trait = TRAIT_WARDED
	used_by_unitiated = TRUE
	resistance_flags = FLAMMABLE