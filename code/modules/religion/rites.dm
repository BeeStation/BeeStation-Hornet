/datum/religion_rites
	/// name of the religious rite
	var/name = "religious rite"
	/// Description of the religious rite
	var/desc = "immm gonna rooon"
	/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
	/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
	/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0
	/// does the altar auto-delete the rite
	var/auto_delete = TRUE

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()

/datum/religion_rites/proc/can_afford(mob/living/user)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	return TRUE

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE
	var/turf/T = get_turf(religious_tool)
	if(!T.is_holy())
		to_chat(user, "<span class='warning'>The altar can only function in a holy area!</span>")
		return FALSE
	if(!GLOB.religious_sect.altar_anchored)
		to_chat(user, "<span class='warning'>The altar must be secured to the floor if you wish to perform the rite!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(!GLOB.religious_sect.altar_anchored)
			to_chat(user, "<span class='warning'>The altar must be secured to the floor if you wish to perform the rite!</span>")
			return FALSE
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!length(ritual_invocations)) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations)))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations))) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(!GLOB.religious_sect.altar_anchored)
		to_chat(user, "<span class='warning'>The altar must be secured to the floor if you wish to perform the rite!</span>")
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	SHOULD_CALL_PARENT(TRUE)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/**** Technophile Sect ****/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 25 SECONDS
	ritual_invocations = list("By the inner workings of our god ...",
						"... We call upon you, in the face of adversity ...",
						"... to complete us, removing that which is undesirable ...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 1800

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to convert the one buckled on [movable_reltool].</span>")
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		if(isandroid(user))
			to_chat(user,"<span class='warning'>You've already converted yourself. To convert others, they must be buckled to [movable_reltool].</span>")
			return FALSE
		to_chat(user,"<span class='warning'>You're going to convert yourself with this ritual.</span>")
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/android)
	rite_target.visible_message("<span class='notice'>[rite_target] has been converted by the rite of [name]!</span>")
	return TRUE


/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a random blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "Let your will power our forges.",
							"... Help us in our great conquest!")
	invoke_msg = "The end of flesh is near!"
	favor_cost = 800

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
					/obj/item/organ/cyberimp/arm/surgery,
					/obj/item/organ/cyberimp/eyes/hud/diagnostic,
					/obj/item/organ/cyberimp/eyes/hud/medical,
					/obj/item/organ/cyberimp/mouth/breathing_tube,
					/obj/item/organ/cyberimp/chest/thrusters,
					/obj/item/organ/cyberimp/chest/nutriment,
					/obj/item/organ/cyberimp/arm/toolset,
					/obj/item/organ/wings/cybernetic,
					/obj/item/organ/eyes/robotic/glow)
	new blessing(altar_turf)
	return TRUE


/datum/religion_rites/machine_implantation
	name = "Machine Implantation"
	desc = "Apply a provided upgrade to your body. Place a cybernetic item on the altar, then buckle someone to implant them, otherwise it will implant you."
	ritual_length = 20 SECONDS
	ritual_invocations = list("Lend us your power ...",
						"... We call upon you, grant us this upgrade ...",
						"... Complete us, joining man and machine ...")
	invoke_msg = "... Let the mechanical parts, Merge!!"
	favor_cost = 1000
	var/obj/item/organ/chosen_implant

/datum/religion_rites/machine_implantation/perform_rite(mob/living/user, atom/religious_tool)
	chosen_implant = locate() in get_turf(religious_tool)
	if(!chosen_implant)
		to_chat(user, "<span class='warning'>This rite requires cybernetics for implantation.</span>")
		return FALSE
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(length(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to merge the implant with the one buckled on [movable_reltool].</span>")
	else if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	to_chat(user,"<span class='warning'>You're going to merge the implant into yourself with this ritual.</span>")
	return ..()

/datum/religion_rites/machine_implantation/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!length(movable_reltool.buckled_mobs))
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		chosen_implant = null
		return FALSE
	chosen_implant.Insert(rite_target)
	rite_target.visible_message("<span class='notice'>[chosen_implant] has been merged into [rite_target] by the rite of [name]!</span>")
	chosen_implant = null
	return TRUE


/**** Ever-Burning Candle sect ****/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Protection"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand time and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 1000
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user,"<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE

/datum/religion_rites/burning_sacrifice
	name = "Burning Offering"
	desc = "Sacrifice a buckled burning corpse for favor, the more burn damage the corpse has the more favor you will receive."
	ritual_length = 15 SECONDS
	ritual_invocations = list("Burning body ...",
	"... cleansed by the flame ...",
	"... we were all created from fire ...",
	"... and to it ...")
	invoke_msg = "... WE RETURN! "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user,"<span class='warning'>Only carbon lifeforms can be properly burned for the sacrifice!</span>")
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user,"<span class='warning'>You can only sacrifice dead bodies, this one is still alive!</span>")
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user,"<span class='warning'>This corpse needs to be on fire to be sacrificed!</span>")
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user,"<span class='warning'>The right sacrifice is no longer on the altar!</span>")
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user,"<span class='warning'>The sacrifice is no longer on fire, it needs to burn until the end of the rite!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user,"<span class='warning'>The sacrifice has to stay dead for the rite to work!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect.adjust_favor(favor_gained, user)
	to_chat(user, "<span class='notice'>[GLOB.deity] absorbs the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor.")
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE

/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "Burn bright, little candles, for you will only extinguish along with the universe."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
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
	var/lichspell = /obj/effect/proc_holder/spell/targeted/lesserlichdom

/datum/religion_rites/create_lesser_lich/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(length(movable_reltool.buckled_mobs))
		for(var/creature in movable_reltool.buckled_mobs)
			lich_to_be = creature
		if(!lich_to_be.mind.hasSoul)
			to_chat(user,"<span class='warning'>[lich_to_be] has no soul, as such this rite would not help them. To empower another, they must be buckled to [movable_reltool].</span>")
			lich_to_be = null
			return FALSE
		for(var/obj/effect/proc_holder/spell/knownspell in lich_to_be.mob_spell_list)
			if(knownspell.type == lichspell)
				to_chat(user,"<span class='warning'>You've already empowered [lich_to_be], get them to use the spell granted to them! To empower another, they must be buckled to [movable_reltool].</span>")
				lich_to_be = null
				return FALSE
		to_chat(user,"<span class='warning'>You're going to empower the [lich_to_be] who is buckled on [movable_reltool].</span>")
		return ..()
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		lich_to_be = user
		if(!lich_to_be.mind.hasSoul)
			to_chat(user,"<span class='warning'>You have no soul, as such this rite would not help you. To empower another, they must be buckled to [movable_reltool].</span>")
			lich_to_be = null
			return FALSE
		for(var/obj/effect/proc_holder/spell/knownspell in lich_to_be.mob_spell_list)
			if(knownspell.type == lichspell)
				to_chat(user,"<span class='warning'>You've already empowered yourself, use the spell granted to you! To empower another, they must be buckled to [movable_reltool].</span>")
				lich_to_be = null
				return FALSE
		to_chat(user,"<span class='warning'>You're empowering yourself!</span>")
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
	lich_to_be.AddSpell(new lichspell(null))
	lich_to_be.visible_message("<span class='notice'>[lich_to_be] has been empowered by the soul pool!</span>")
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
	var/list/candidates = pollGhostCandidates("Do you wish to be resurrected as a Holy Summoned Undead?", ROLE_HOLY_SUMMONED, null, 10 SECONDS, POLL_IGNORE_HOLYUNDEAD)
	if(!length(candidates))
		to_chat(user, "<span class='warning'>The soul pool is empty...")
		new /obj/effect/gibspawner/human/bodypartless(altar_turf)
		user.visible_message("<span class='warning'>The soul pool was not strong enough to bring forth the undead.")
		GLOB.religious_sect?.adjust_favor(favor_cost, user) //refund if nobody takes the role
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/datum/mind/Mind = new /datum/mind(selected.key)
	var/undead_species = pick(/mob/living/carbon/human/species/zombie, /mob/living/carbon/human/species/skeleton)
	var/mob/living/carbon/human/species/undead = new undead_species(altar_turf)
	undead.real_name = "Holy Undead ([rand(1,999)])"
	Mind.active = 1
	Mind.transfer_to(undead)
	undead.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(undead), ITEM_SLOT_BACK)
	undead.equip_to_slot_or_del(new /obj/item/clothing/under/costume/skeleton(undead), ITEM_SLOT_ICLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/chaplain_hoodie(undead), ITEM_SLOT_OCLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(undead), ITEM_SLOT_FEET)
	undead.AddSpell(new /obj/effect/proc_holder/spell/targeted/smoke(null))
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
		to_chat(undead, "<span class='userdanger'>You are grateful to have been summoned into this word by [user]. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
	else
		to_chat(undead, "<span class='big notice'>You are grateful to have been summoned into this world. You are now a member of this station's crew, Try not to cause any trouble.</span>")
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
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/mob/living/carbon/r_target in movable_reltool.buckled_mobs)
		if(!iscarbon(r_target))
			to_chat(user, "<span class='warning'>Only carbon lifeforms can be properly resurrected!</span>")
			return FALSE
		if(r_target.stat != DEAD)
			to_chat(user, "<span class='warning'>You can only resurrect dead bodies, this one is still alive!</span>")
			return FALSE
		if(!r_target.mind)
			to_chat(user, "<span class='warning'>This creature has no connected soul...")
			return FALSE
		raise_target = r_target
		raise_target.notify_ghost_cloning("Your soul is being summoned back to your body by mystical power!", source = src)
		return ..()

/datum/religion_rites/raise_dead/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(raise_target in religious_tool.buckled_mobs))
		to_chat(user, "<span class='warning'>The body is no longer on the altar!</span>")
		raise_target = null
		return FALSE
	if(!raise_target.mind)
		to_chat(user, "<span class='warning'>This creature's soul has left the pool...")
		raise_target = null
		return FALSE
	if(raise_target.stat != DEAD)
		to_chat(user, "<span class='warning'>The target has to stay dead for the rite to work! If they came back without your spiritual guidence... Who knows what could happen!?</span>")
		raise_target = null
		return FALSE
	raise_target.grab_ghost() // Shove them back in their body.
	raise_target.revive(full_heal = 1, admin_revive = 1)
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
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/creature in movable_reltool.buckled_mobs)
		chosen_sacrifice = creature
		if(chosen_sacrifice.stat == DEAD)
			to_chat(user, "<span class='warning'>You can only sacrifice living creatures, this one is dead!</span>")
			chosen_sacrifice = null
			return FALSE
		if(chosen_sacrifice.mind)
			to_chat(user, "<span class='warning'>This sacrifice is sentient! [GLOB.deity] will not accept this offering.</span>")
			chosen_sacrifice = null
			return FALSE
		var/mob/living/carbon/C = creature
		if(!isnull(C))
			cuff(C)
		return ..()

/datum/religion_rites/living_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right creature is still buckled
		to_chat(user, "<span class='warning'>The right sacrifice is no longer on the altar!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat == DEAD)
		to_chat(user, "<span class='warning'>The sacrifice is no longer alive, it needs to be alive until the end of the rite!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 200 + round(chosen_sacrifice.health * 2)
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	new /obj/effect/temp_visual/cult/blood/out(altar_turf)
	to_chat(user, "<span class='notice'>[GLOB.deity] absorbs [chosen_sacrifice], leaving blood and gore in its place. [GLOB.deity] rewards you with [favor_gained] favor.</span>")
	chosen_sacrifice.gib(TRUE, FALSE, TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/bamf.ogg', 50, TRUE)
	chosen_sacrifice = null
	return ..()

/datum/religion_rites/living_sacrifice/proc/cuff(var/mob/living/carbon/C)
	if(C.handcuffed)
		return
	C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult(C)
	C.update_handcuffed()
	playsound(C, 'sound/magic/smoke.ogg', 50, 1)
	C.visible_message("<span class='warning'>Darkness forms around [C]'s wrists as shadowy bindings appear on them!</span>")

/**** Carp rites ****/

/datum/religion_rites/summon_carp
	name = "Summon Carp"
	desc = "Creates a Sentient Space Carp, if a soul is willing to take it. If not, the favor is refunded."
	ritual_length = 50 SECONDS
	ritual_invocations = list("Grant us a new follower ...",
	"... let them enter our realm ...",
	"... become one with our world ...",
	"... to swim in our space ...",
	"... and help our cause ...")
	invoke_msg = "... We summon thee, Holy Carp!"
	favor_cost = 500

/datum/religion_rites/summon_carp/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/bluespace_fissure/long(altar_turf)
	user.visible_message("<span class'notice'>A tear in reality appears above the altar!</span>")
	var/list/candidates = pollGhostCandidates("Do you wish to be summoned as a Holy Carp?", ROLE_HOLY_SUMMONED, null, 10 SECONDS, POLL_IGNORE_HOLYCARP)
	if(!length(candidates))
		new /obj/effect/gibspawner/generic(altar_turf)
		user.visible_message("<span class='warning'>The carp pool was not strong enough to bring forth a space carp.")
		GLOB.religious_sect?.adjust_favor(400, user)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/datum/mind/M = new /datum/mind(selected.key)
	var/carp_species = pick(/mob/living/simple_animal/hostile/carp/megacarp, /mob/living/simple_animal/hostile/carp)
	var/mob/living/simple_animal/hostile/carp = new carp_species(altar_turf)
	carp.name = "Holy Space-Carp ([rand(1,999)])"
	carp.key = selected.key
	carp.sentience_act()
	carp.maxHealth += 100
	carp.health += 100
	M.transfer_to(carp)
	if(GLOB.religion)
		carp.mind?.holy_role = HOLY_ROLE_PRIEST
		to_chat(carp, "There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain.")
		GLOB.religious_sect?.on_conversion(carp)
	if(is_special_character(user))
		to_chat(carp, "<span class='userdanger'>You are grateful to have been summoned into this word by [user]. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
	else
		to_chat(carp, "<span class='big notice'>You are grateful to have been summoned into this world. You are now a member of this station's crew, Try not to cause any trouble.</span>")
	playsound(altar_turf, 'sound/effects/slosh.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/summon_carpsuit
	name = "Summon Carp-Suit"
	desc = "Summons a Space-Carp Suit"
	ritual_length = 30 SECONDS
	ritual_invocations = list("We shall become one ...",
	"... we shall blend in ...",
	"... we shall join in the ways of the carp ...",
	"... grant us new clothing ...")
	invoke_msg = "So we can swim."
	favor_cost = 300
	var/obj/item/clothing/suit/chosen_clothing

/datum/religion_rites/summon_carpsuit/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/T = get_turf(religious_tool)
	var/list/L = T.contents
	if(!locate(/obj/item/clothing/suit) in L)
		to_chat(user, "<span class='warning'>There is no suit clothing on the altar!</span>")
		return FALSE
	for(var/obj/item/clothing/suit/apparel in L)
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/summon_carpsuit/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		user.visible_message("<span class'notice'>The [chosen_clothing] transforms!</span>")
		chosen_clothing.obj_destruction()
		chosen_clothing = null
		new /obj/item/clothing/suit/space/hardsuit/carp/old(get_turf(religious_tool))
		playsound(get_turf(religious_tool), 'sound/effects/slosh.ogg', 50, TRUE)
		return ..()
	chosen_clothing = null
	to_chat(user, "<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE

/datum/religion_rites/flood_area
	name = "Flood Area"
	desc = "Flood the area with water vapor, great for learning to swim!"
	ritual_length = 25 SECONDS
	ritual_invocations = list("We must swim ...",
	"... but to do so, we need water ...",
	"... grant us a great flood ...",
	"... soak us in your glory ...",
	"... we shall swim forever ...")
	invoke_msg = "... in our own personal ocean."
	favor_cost = 200

/datum/religion_rites/flood_area/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/open/T = get_turf(religious_tool)
	if(istype(T))
		T.atmos_spawn_air("water_vapor=5000;TEMP=255")
	return ..()

/**** Plant rites ****/

/datum/religion_rites/summon_animals
	name = "Create Life"
	desc = "Creates a few animals, this can range from butterflys to giant frogs! Please be careful."
	ritual_length = 30 SECONDS
	ritual_invocations = list("Great Mother ...",
	"... bring us new life ...",
	"... to join with our nature ...",
	"... and live amongst us ...")
	invoke_msg = "... We summon thee, Animals from the Byond!" //might adjust to beyond due to ooc/ic/meta
	favor_cost = 500

/datum/religion_rites/summon_animals/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/bluespace_fissure/long(altar_turf)
	user.visible_message("<span class'notice'>A tear in reality appears above the altar!</span>")
	return ..()

/datum/religion_rites/summon_animals/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	var/turf/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 8)
		var/mob/living/simple_animal/S = create_random_mob(altar_turf, FRIENDLY_SPAWN)
		S.faction |= "neutral"
	playsound(altar_turf, 'sound/ambience/servicebell.ogg', 25, TRUE)
	if(prob(0.1))
		playsound(altar_turf, 'sound/effects/bamf.ogg', 100, TRUE)
		altar_turf.visible_message("<span class='boldwarning'>A large form seems to be forcing its way into your reality via the portal [user] opened! RUN!!!</span>")
		new /mob/living/simple_animal/hostile/jungle/leaper(altar_turf)
	return ..()

/datum/religion_rites/create_sandstone
	name = "Create Sandstone"
	desc = "Create Sandstone for soil production to help create a plant garden."
	ritual_length = 35 SECONDS
	ritual_invocations = list("Bring to us ...",
	"... the stone we need ...",
	"... so we can toil away ...")
	invoke_msg = "and spread many seeds."
	favor_cost = 800

/datum/religion_rites/create_sandstone/invoke_effect(mob/living/user, atom/religious_tool)
	new /obj/item/stack/sheet/mineral/sandstone/fifty(get_turf(religious_tool))
	playsound(get_turf(religious_tool), 'sound/effects/pop_expl.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/grass_generator
	name = "Blessing of Nature"
	desc = "Summon a moveable object that slowly generates grass and fairy-grass around itself while healing any Pod-People or Holy people nearby."
	ritual_length = 60 SECONDS
	ritual_invocations = list("Let the plantlife grow ...",
	"... let it grow across the land ...",
	"... far and wide it shall spread ...",
	"... show us true nature ...",
	"... and we shall worship it all ...")
	invoke_msg = "... in our own personal haven."
	favor_cost = 1000

/datum/religion_rites/grass_generator/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/open/T = get_turf(religious_tool)
	if(istype(T))
		new /obj/structure/destructible/religion/nature_pylon(T)
	return ..()

/datum/religion_rites/create_podperson
	name = "Nature Conversion"
	desc = "Convert a human-esque individual into a being of nature. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list("By the power of nature ...",
						"... We call upon you, in this time of need ...",
						"... to merge us with all that is natural ...")
	invoke_msg = "... May the grass be greener on the other side, show us what it means to be one with nature!!"
	favor_cost = 300

/datum/religion_rites/create_podperson/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to convert the one buckled on [movable_reltool].</span>")
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		if(ispodperson(user))
			to_chat(user,"<span class='warning'>You've already converted yourself. To convert others, they must be buckled to [movable_reltool].</span>")
			return FALSE
		to_chat(user,"<span class='warning'>You're going to convert yourself with this ritual.</span>")
	return ..()

/datum/religion_rites/create_podperson/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/pod)
	rite_target.visible_message("<span class='notice'>[rite_target] has been converted by the rite of [name]!</span>")
	return TRUE
