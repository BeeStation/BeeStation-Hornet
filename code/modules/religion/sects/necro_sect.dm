/datum/religion_sect/necro_sect
	name = "Necromancy"
	desc = "A sect dedicated to the revival and summoning of the dead. Sacrificing living animals grants you favor."
	quote = "An undead army is a must have!"
	tgui_icon = "skull"
	alignment = ALIGNMENT_EVIL
	max_favor = 10000
	desired_items = list(
		/obj/item/organ/)
	rites_list = list(
		/datum/religion_rites/raise_dead,
		/datum/religion_rites/living_sacrifice,
		/datum/religion_rites/raise_undead,
		/datum/religion_rites/create_lesser_lich)
	altar_icon_state = "convertaltar-green"

//Necro bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/necro_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/necro_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/organ))
		return
	adjust_favor(10, L)
	to_chat(L, span_notice("You offer [N] to [GLOB.deity], pleasing them and gaining 10 favor in the process."))
	qdel(N)
	return TRUE


/// Necro Rites

/datum/religion_rites/create_lesser_lich
	name = "Create Lesser Lich"
	desc = "Gives the bound creature a spell granting them the ability to create a lesser phylactery, causing them to become a skeleton and revive on death twice if the phylactery still exists on-station. Be warned, becoming a lesser lich will prevent revivial by any other means."
	ritual_length = 60 SECONDS //This one's pretty powerful so it'll still be long
	ritual_invocations = list("From the depths of the soul pool ...",
	"... come forth into this being ...",
	"... grant this servant power ...",
	"... grant them temporary immortality ...")
	invoke_msg = "... Grant them the power to become one with necromancy!!"
	favor_cost = 2250
/// the creature chosen for the rite
	var/mob/living/lich_to_be
/// the the typepath of the spell to gran
	var/datum/action/spell/lichspell = /datum/action/spell/lesserlichdom

/datum/religion_rites/create_lesser_lich/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(length(movable_reltool.buckled_mobs))
		for(var/creature in movable_reltool.buckled_mobs)
			lich_to_be = creature
		if(HAS_TRAIT(lich_to_be, TRAIT_NO_SOUL))
			to_chat(user,span_warning("[lich_to_be] has no soul, as such this rite would not help them. To empower another, they must be buckled to [movable_reltool]."))
			lich_to_be = null
			return FALSE
		for(var/datum/action/spell/knownspell in lich_to_be.actions)
			if(knownspell.type == lichspell)
				to_chat(user,span_warning("You've already empowered [lich_to_be], get them to use the spell granted to them! To empower another, they must be buckled to [movable_reltool]."))
				lich_to_be = null
				return FALSE
		to_chat(user,span_warning("You're going to empower the [lich_to_be] who is buckled on [movable_reltool]."))
		return ..()
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		lich_to_be = user
		if(HAS_TRAIT(lich_to_be, TRAIT_NO_SOUL))
			to_chat(user,span_warning("You have no soul, as such this rite would not help you. To empower another, they must be buckled to [movable_reltool]."))
			lich_to_be = null
			return FALSE
		for(var/datum/action/spell/knownspell in lich_to_be.actions)
			if(knownspell.type == lichspell)
				to_chat(user,span_warning("You've already empowered yourself, use the spell granted to you! To empower another, they must be buckled to [movable_reltool]."))
				lich_to_be = null
				return FALSE
		to_chat(user,span_warning("You're empowering yourself!"))
		return ..()


/datum/religion_rites/create_lesser_lich/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		lich_to_be = user
	else
		for(var/mob/living/carbon/human/buckled in movable_reltool.buckled_mobs)
			lich_to_be = buckled
			break
	if(!lich_to_be)
		return FALSE
	lichspell = new /datum/action/spell/lesserlichdom
	lichspell.Grant(lich_to_be)
	lich_to_be.visible_message(span_notice("[lich_to_be] has been empowered by the soul pool!"))
	lich_to_be = null
	return ..()

/datum/religion_rites/raise_undead
	name = "Raise Undead"
	desc = "Creates an undead creature if a soul is willing to take it."
	ritual_length = 50 SECONDS
	ritual_invocations = list("Come forth from the pool of souls ...",
	"... enter our realm ...",
	"... become one with our world ...",
	"... rise ...",
	"... RISE! ...")
	invoke_msg = "... RISE!!!"
	favor_cost = 1250

/datum/religion_rites/raise_undead/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/cult/blood/long(altar_turf)
	new /obj/effect/temp_visual/dir_setting/curse/long(altar_turf)
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		question = "Do you wish to be resurrected as a Holy Summoned Undead?",
		check_jobban = ROLE_HOLY_SUMMONED,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_HOLYUNDEAD,
		jump_target = religious_tool,
		role_name_text = "holy summoned undead",
		alert_pic = /mob/living/carbon/human/species/skeleton,
	)
	if(!candidate)
		to_chat(user, span_warning("The soul pool is empty..."))
		new /obj/effect/gibspawner/human/bodypartless(altar_turf)
		user.visible_message(span_warning("The soul pool was not strong enough to bring forth the undead."))
		GLOB.religious_sect?.adjust_favor(favor_cost, user) //refund if nobody takes the role
		return NOT_ENOUGH_PLAYERS
	var/datum/mind/Mind = new /datum/mind(candidate.key)
	var/undead_species = pick(/mob/living/carbon/human/species/zombie, /mob/living/carbon/human/species/skeleton)
	var/mob/living/carbon/human/species/undead = new undead_species(altar_turf)
	undead.real_name = "Holy Undead ([rand(1,999)])"
	Mind.active = 1
	Mind.transfer_to(undead)
	undead.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(undead), ITEM_SLOT_BACK)
	undead.equip_to_slot_or_del(new /obj/item/clothing/under/costume/skeleton(undead), ITEM_SLOT_ICLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/chaplain_hoodie(undead), ITEM_SLOT_OCLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(undead), ITEM_SLOT_FEET)
	var/datum/action/spell/smoke = new /datum/action/spell/smoke
	smoke.Grant(undead)
	if(GLOB.religion)
		var/obj/item/storage/book/bible/booze/B = new
		undead.mind?.holy_role = HOLY_ROLE_PRIEST
		B.deity_name = GLOB.deity
		B.name = GLOB.bible_name
		B.icon_state = GLOB.bible_icon_state
		B.item_state = GLOB.bible_item_state
		to_chat(undead, "There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain.")
		undead.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)
		GLOB.religious_sect?.on_conversion(undead)
	if(is_special_character(user))
		to_chat(undead, span_userdanger("You are grateful to have been summoned into this word by [user]. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost."))
	else
		to_chat(undead, span_bignotice("You are grateful to have been summoned into this world. You are now a member of this station's crew, Try not to cause any trouble."))
	playsound(altar_turf, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg',), 50, TRUE)
	return ..()

/datum/religion_rites/raise_dead
	name = "Raise Dead"
	desc = "Revives a buckled dead creature or person."
	ritual_length = 40 SECONDS
	ritual_invocations = list("Rejoin our world ...",
	"... come forth from the beyond ...",
	"... fresh life awaits you ...",
	"... return to us ...",
	"... by the power granted by the gods ...",
	"... you shall rise again ...")
	invoke_msg = "Welcome back to the mortal plain."
	favor_cost = 1500

///the target
	var/mob/living/carbon/human/raise_target

/datum/religion_rites/raise_dead/perform_rite(mob/living/user, atom/religious_tool)
	if(!religious_tool || !ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/mob/living/carbon/r_target in movable_reltool.buckled_mobs)
		if(!iscarbon(r_target))
			to_chat(user, span_warning("Only carbon lifeforms can be properly resurrected!"))
			return FALSE
		if(r_target.stat != DEAD)
			to_chat(user, span_warning("You can only resurrect dead bodies, this one is still alive!"))
			return FALSE
		if(!r_target.mind)
			to_chat(user, span_warning("This creature has no connected soul..."))
			return FALSE
		raise_target = r_target
		raise_target.notify_ghost_cloning("Your soul is being summoned back to your body by mystical power!", source = src)
		return ..()

/datum/religion_rites/raise_dead/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(raise_target in religious_tool.buckled_mobs))
		to_chat(user, span_warning("The body is no longer on the altar!"))
		raise_target = null
		return FALSE
	if(!raise_target.mind)
		to_chat(user, span_warning("This creature's soul has left the pool..."))
		raise_target = null
		return FALSE
	if(raise_target.stat != DEAD)
		to_chat(user, span_warning("The target has to stay dead for the rite to work! If they came back without your spiritual guidence... Who knows what could happen!?"))
		raise_target = null
		return FALSE
	raise_target.grab_ghost() // Shove them back in their body.
	raise_target.revive(HEAL_ALL)
	playsound(altar_turf, 'sound/magic/staff_healing.ogg', 50, TRUE)
	raise_target = null
	return ..()

/datum/religion_rites/living_sacrifice
	name = "Living Sacrifice"
	desc = "Sacrifice a non-sentient living buckled creature for favor."
	ritual_length = 25 SECONDS
	ritual_invocations = list("To offer this being unto the gods ...",
	"... to feed them with its soul ...",
	"... so that they may consume all within their path ...",
	"... release their binding on this mortal plane ...",
	"... I offer you this living being ...")
	invoke_msg = "... may it join the horde of undead, and become one with the souls of the damned. "

//the living creature chosen for the sacrifice of the rite
	var/mob/living/chosen_sacrifice
/datum/religion_rites/living_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!religious_tool || !ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/creature in movable_reltool.buckled_mobs)
		chosen_sacrifice = creature
		if(chosen_sacrifice.stat == DEAD)
			to_chat(user, span_warning("You can only sacrifice living creatures, this one is dead!"))
			chosen_sacrifice = null
			return FALSE
		if(chosen_sacrifice.mind)
			to_chat(user, span_warning("This sacrifice is sentient! [GLOB.deity] will not accept this offering."))
			chosen_sacrifice = null
			return FALSE
		if(chosen_sacrifice.flags_1 & HOLOGRAM_1)
			to_chat(user, span_warning("You cannot sacrifice this. It is not made of flesh!"))
			chosen_sacrifice = null
			return FALSE
		var/mob/living/carbon/C = creature
		if(!isnull(C))
			cuff(C)
		return ..()

/datum/religion_rites/living_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right creature is still buckled
		to_chat(user, span_warning("The right sacrifice is no longer on the altar!"))
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat == DEAD)
		to_chat(user, span_warning("The sacrifice is no longer alive, it needs to be alive until the end of the rite!"))
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 200 + round(chosen_sacrifice.health * 2)
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	new /obj/effect/temp_visual/cult/blood/out(altar_turf)
	to_chat(user, span_notice("[GLOB.deity] absorbs [chosen_sacrifice], leaving blood and gore in its place. [GLOB.deity] rewards you with [favor_gained] favor."))
	chosen_sacrifice.gib(TRUE, FALSE, TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/bamf.ogg', 50, TRUE)
	chosen_sacrifice = null
	return ..()

/datum/religion_rites/living_sacrifice/proc/cuff(mob/living/carbon/C)
	if(C.handcuffed)
		return
	C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult(C)
	C.update_handcuffed()
	playsound(C, 'sound/magic/smoke.ogg', 50, 1)
	C.visible_message(span_warning("Darkness forms around [C]'s wrists as shadowy bindings appear on them!"))
