/obj/item/dnainjector
	name = "\improper DNA injector"
	desc = "A cheap single use autoinjector that injects the user with DNA."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "dnainjector"
	base_icon_state = "dnainjector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	var/damage_coeff  = 1
	var/list/fields
	var/list/add_mutations = list()
	var/list/remove_mutations = list()

	var/used = FALSE

/obj/item/dnainjector/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !HAS_TRAIT(M, TRAIT_RADIMMUNE) && !HAS_TRAIT(M, TRAIT_BADDNA))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/HM in remove_mutations)
			M.dna.remove_mutation(HM)
			log_msg += "(mutation removal: [english_list(remove_mutations)])"
		for(var/HM in add_mutations)
			if(HM == /datum/mutation/race)
				message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(M)] with the [name] [span_danger("(MONKEY)")]")
				log_msg += " (MONKEY)"
			if(M.dna.mutation_in_sequence(HM))
				M.dna.activate_mutation(HM)
			else
				M.dna.add_mutation(HM, MUT_EXTRA)
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
			if(fields["UI"])	//UI+UE
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	return FALSE

/obj/item/dnainjector/attack(mob/living/target, mob/living/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	if(used)
		to_chat(user, span_warning("This injector is used up!"))
		return
	if(!target.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return
	log_combat(user, target, "attempted to inject", src)

	if(target != user)
		target.visible_message(span_danger("[user] is trying to inject [target] with [src]!"), \
			span_userdanger("[user] is trying to inject you with [src]!"))
		if(!do_after(user, 3 SECONDS, target) || used)
			return
		target.visible_message(span_danger("[user] injects [target] with the syringe with [src]!"), span_userdanger("[user] injects you with the syringe with [src]!"))

	else
		to_chat(user, span_notice("You inject yourself with [src]."))

	log_combat(user, target, "injected", src)

	if(!inject(target, user))	//Now we actually do the heavy lifting.
		to_chat(user, span_notice("It appears that [target] does not have compatible DNA."))

	used = TRUE
	icon_state = "[base_icon_state]0"
	desc += " This one is spent, you better recycle it!"


/obj/item/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	remove_mutations = list(/datum/mutation/hulk)

/obj/item/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations = list(/datum/mutation/hulk)

/obj/item/dnainjector/xraymut
	name = "\improper DNA injector (X-ray)"
	desc = "Finally you can see what the Captain does."
	add_mutations = list(/datum/mutation/thermal/x_ray)

/obj/item/dnainjector/antixray
	name = "\improper DNA injector (Anti-X-ray)"
	desc = "It will make you see harder."
	remove_mutations = list(/datum/mutation/thermal/x_ray)

/////////////////////////////////////
/obj/item/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	remove_mutations = list(/datum/mutation/nearsight)

/obj/item/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	add_mutations = list(/datum/mutation/nearsight)

/obj/item/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	add_mutations = list(/datum/mutation/epilepsy)

/obj/item/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	remove_mutations = list(/datum/mutation/epilepsy)
////////////////////////////////////
/obj/item/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	remove_mutations = list(/datum/mutation/cough)

/obj/item/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	add_mutations = list(/datum/mutation/cough)

/obj/item/dnainjector/antidwarf
	name = "\improper DNA injector (Anti-Dwarfism)"
	desc = "Helps you grow big and strong."
	remove_mutations = list(/datum/mutation/dwarfism)

/obj/item/dnainjector/dwarf
	name = "\improper DNA injector (Dwarfism)"
	desc = "It's a small world after all."
	add_mutations = list(/datum/mutation/dwarfism)

/obj/item/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."
	add_mutations = list(/datum/mutation/clumsy)

/obj/item/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumsy)"
	desc = "Apply this for Security Clown."
	remove_mutations = list(/datum/mutation/clumsy)

/obj/item/dnainjector/cluwnemut
	name = "\improper DNA injector (Cluwneify)"
	desc = "This is your last chance to turn back."
	add_mutations = list(/datum/mutation/cluwne)

/obj/item/dnainjector/anticluwne
	name = "\improper DNA injector (Anti-Cluwne)"
	desc = "This is going to hurt."
	remove_mutations = list(/datum/mutation/cluwne)

/obj/item/dnainjector/cursedcluwnemut
	name = "\improper DNA injector (Cluwneify)"
	desc = "This is your last chance to turn back."
	add_mutations = list(/datum/mutation/cluwne/cursed)

/obj/item/dnainjector/anticursedcluwne
	name = "\improper DNA injector (Anti-Cluwne)"
	desc = "This isn't going to work."
	remove_mutations = list(/datum/mutation/cluwne/cursed)

/obj/item/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure Tourette's."
	remove_mutations = list(/datum/mutation/tourettes)

/obj/item/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case of Tourette's."
	add_mutations = list(/datum/mutation/tourettes)

/obj/item/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr."
	add_mutations = list(/datum/mutation/nervousness)

/obj/item/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	remove_mutations = list(/datum/mutation/nervousness)

/obj/item/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."
	remove_mutations = list(/datum/mutation/space_adaptation)

/obj/item/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."
	add_mutations = list(/datum/mutation/space_adaptation)

/obj/item/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	add_mutations = list(/datum/mutation/blind)

/obj/item/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "IT'S A MIRACLE!!!"
	remove_mutations = list(/datum/mutation/blind)

/obj/item/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	remove_mutations = list(/datum/mutation/telekinesis)

/obj/item/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"
	add_mutations = list(/datum/mutation/telekinesis)

/obj/item/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	add_mutations = list(/datum/mutation/deaf)

/obj/item/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	remove_mutations = list(/datum/mutation/deaf)

/obj/item/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations = list(/datum/mutation/race)

/obj/item/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	remove_mutations = list(/datum/mutation/race)

/obj/item/dnainjector/antichameleon
	name = "\improper DNA injector (Anti-Chameleon)"
	remove_mutations = list(/datum/mutation/chameleon)

/obj/item/dnainjector/chameleonmut
	name = "\improper DNA injector (Chameleon)"
	add_mutations = list(/datum/mutation/chameleon)

/obj/item/dnainjector/antiwacky
	name = "\improper DNA injector (Anti-Wacky)"
	remove_mutations = list(/datum/mutation/wacky)

/obj/item/dnainjector/wackymut
	name = "\improper DNA injector (Wacky)"
	add_mutations = list(/datum/mutation/wacky)

/obj/item/dnainjector/antimute
	name = "\improper DNA injector (Anti-Mute)"
	remove_mutations = list(/datum/mutation/mute)

/obj/item/dnainjector/mutemut
	name = "\improper DNA injector (Mute)"
	add_mutations = list(/datum/mutation/mute)

/obj/item/dnainjector/antismile
	name = "\improper DNA injector (Anti-Smile)"
	remove_mutations = list(/datum/mutation/smile)

/obj/item/dnainjector/smilemut
	name = "\improper DNA injector (Smile)"
	add_mutations = list(/datum/mutation/smile)

/obj/item/dnainjector/unintelligiblemut
	name = "\improper DNA injector (Unintelligible)"
	add_mutations = list(/datum/mutation/unintelligible)

/obj/item/dnainjector/antiunintelligible
	name = "\improper DNA injector (Anti-Unintelligible)"
	remove_mutations = list(/datum/mutation/unintelligible)

/obj/item/dnainjector/swedishmut
	name = "\improper DNA injector (Swedish)"
	add_mutations = list(/datum/mutation/unintelligible)

/obj/item/dnainjector/antiswedish
	name = "\improper DNA injector (Anti-Swedish)"
	remove_mutations = list(/datum/mutation/unintelligible)

/obj/item/dnainjector/chavmut
	name = "\improper DNA injector (Chav)"
	add_mutations = list(/datum/mutation/chav)

/obj/item/dnainjector/antichav
	name = "\improper DNA injector (Anti-Chav)"
	remove_mutations = list(/datum/mutation/chav)

/obj/item/dnainjector/elvismut
	name = "\improper DNA injector (Elvis)"
	add_mutations = list(/datum/mutation/elvis)

/obj/item/dnainjector/antielvis
	name = "\improper DNA injector (Anti-Elvis)"
	remove_mutations = list(/datum/mutation/elvis)

/obj/item/dnainjector/lasereyesmut
	name = "\improper DNA injector (Laser Eyes)"
	add_mutations = list(/datum/mutation/laser_eyes)

/obj/item/dnainjector/antilasereyes
	name = "\improper DNA injector (Anti-Laser Eyes)"
	remove_mutations = list(/datum/mutation/laser_eyes)

/obj/item/dnainjector/void
	name = "\improper DNA injector (Void)"
	add_mutations = list(/datum/mutation/firebreath)

/obj/item/dnainjector/antivoid
	name = "\improper DNA injector (Anti-Void)"
	remove_mutations = list(/datum/mutation/firebreath)

/obj/item/dnainjector/antenna
	name = "\improper DNA injector (Antenna)"
	add_mutations = list(/datum/mutation/antenna)

/obj/item/dnainjector/antiantenna
	name = "\improper DNA injector (Anti-Antenna)"
	remove_mutations = list(/datum/mutation/antenna)

/obj/item/dnainjector/paranoia
	name = "\improper DNA injector (Paranoia)"
	add_mutations = list(/datum/mutation/paranoia)

/obj/item/dnainjector/antiparanoia
	name = "\improper DNA injector (Anti-Paranoia)"
	remove_mutations = list(/datum/mutation/paranoia)

/obj/item/dnainjector/radioactive
	name = "\improper DNA injector (Radioactive)"
	add_mutations = list(/datum/mutation/radioactive)

/obj/item/dnainjector/antiradioactive
	name = "\improper DNA injector (Anti-Radioactive)"
	remove_mutations = list(/datum/mutation/radioactive)

/obj/item/dnainjector/olfaction
	name = "\improper DNA injector (Olfaction)"
	add_mutations = list(/datum/mutation/olfaction)

/obj/item/dnainjector/antiolfaction
	name = "\improper DNA injector (Anti-Olfaction)"
	remove_mutations = list(/datum/mutation/olfaction)

/obj/item/dnainjector/insulated
	name = "\improper DNA injector (Insulated)"
	add_mutations = list(/datum/mutation/insulated)

/obj/item/dnainjector/antiinsulated
	name = "\improper DNA injector (Anti-Insulated)"
	remove_mutations = list(/datum/mutation/insulated)

/obj/item/dnainjector/shock
	name = "\improper DNA injector (Shock Touch)"
	add_mutations = list(/datum/mutation/shock)

/obj/item/dnainjector/antishock
	name = "\improper DNA injector (Anti-Shock Touch)"
	remove_mutations = list(/datum/mutation/shock)

/obj/item/dnainjector/spatialinstability
	name = "\improper DNA injector (Spatial Instability)"
	add_mutations = list(/datum/mutation/badblink)

/obj/item/dnainjector/antispatialinstability
	name = "\improper DNA injector (Anti-Spatial Instability)"
	remove_mutations = list(/datum/mutation/badblink)

/obj/item/dnainjector/acidflesh
	name = "\improper DNA injector (Acid Flesh)"
	add_mutations = list(/datum/mutation/acidflesh)

/obj/item/dnainjector/antiacidflesh
	name = "\improper DNA injector (Acid Flesh)"
	remove_mutations = list(/datum/mutation/acidflesh)

/obj/item/dnainjector/gigantism
	name = "\improper DNA injector (Gigantism)"
	add_mutations = list(/datum/mutation/gigantism)

/obj/item/dnainjector/antigigantism
	name = "\improper DNA injector (Anti-Gigantism)"
	remove_mutations = list(/datum/mutation/gigantism)

/obj/item/dnainjector/spastic
	name = "\improper DNA injector (Spastic)"
	add_mutations = list(/datum/mutation/spastic)

/obj/item/dnainjector/antispastic
	name = "\improper DNA injector (Anti-Spastic)"
	remove_mutations = list(/datum/mutation/spastic)

/obj/item/dnainjector/twoleftfeet
	name = "\improper DNA injector (Two Left Feet)"
	add_mutations = list(/datum/mutation/extrastun)

/obj/item/dnainjector/antitwoleftfeet
	name = "\improper DNA injector (Anti-Two Left Feet)"
	remove_mutations = list(/datum/mutation/extrastun)

/obj/item/dnainjector/geladikinesis
	name = "\improper DNA injector (Geladikinesis)"
	add_mutations = list(/datum/mutation/geladikinesis)

/obj/item/dnainjector/antigeladikinesis
	name = "\improper DNA injector (Anti-Geladikinesis)"
	remove_mutations = list(/datum/mutation/geladikinesis)

/obj/item/dnainjector/cryokinesis
	name = "\improper DNA injector (Cryokinesis)"
	add_mutations = list(/datum/mutation/cryokinesis)

/obj/item/dnainjector/anticryokinesis
	name = "\improper DNA injector (Anti-Cryokinesis)"
	remove_mutations = list(/datum/mutation/cryokinesis)

/obj/item/dnainjector/thermal
	name = "\improper DNA injector (Thermal Vision)"
	add_mutations = list(/datum/mutation/thermal)

/obj/item/dnainjector/antithermal
	name = "\improper DNA injector (Anti-Thermal Vision)"
	remove_mutations = list(/datum/mutation/thermal)

/obj/item/dnainjector/glow
	name = "\improper DNA injector (Glowy)"
	add_mutations = list(/datum/mutation/glow)

/obj/item/dnainjector/removeglow
	name = "\improper DNA injector (Anti-Glowy)"
	remove_mutations = list(/datum/mutation/glow)

/obj/item/dnainjector/antiglow
	name = "\improper DNA injector (Antiglowy)"
	add_mutations = list(/datum/mutation/glow/anti)

/obj/item/dnainjector/removeantiglow
	name = "\improper DNA injector (Anti-Antiglowy)"
	remove_mutations = list(/datum/mutation/glow/anti)

/obj/item/dnainjector/strongwings
	name = "\improper DNA injector (Strong Wings)"
	add_mutations = list(/datum/mutation/strongwings)

/obj/item/dnainjector/antistrongwings
	name = "\improper DNA injector (Anti-Strong Wings)"
	remove_mutations = list(/datum/mutation/strongwings)

/obj/item/dnainjector/catclaws
	name = "\improper DNA injector (Cat Claws)"
	add_mutations = list(/datum/mutation/catclaws)

/obj/item/dnainjector/anticatclaws
	name = "\improper DNA injector (Anti-Cat Claws)"
	remove_mutations = list(/datum/mutation/catclaws)

/obj/item/dnainjector/overload
	name = "\improper DNA injector (Overload)"
	add_mutations = list(/datum/mutation/overload)

/obj/item/dnainjector/antioverload
	name = "\improper DNA injector (Anti-Overload)"
	remove_mutations = list(/datum/mutation/overload)

/obj/item/dnainjector/acidooze
	name = "\improper DNA injector (Acid Ooze)"
	add_mutations = list(/datum/mutation/acidooze)

/obj/item/dnainjector/antiacidooze
	name = "\improper DNA injector (Pepto-Bismol)"
	remove_mutations = list(/datum/mutation/acidooze)

/obj/item/dnainjector/medievalmut
	name = "\improper DNA injector (Medieval)"
	add_mutations = list(/datum/mutation/medieval)

/obj/item/dnainjector/antimedieval
	name = "\improper DNA injector (Anti-Medieval)"
	remove_mutations = list(/datum/mutation/medieval)

/obj/item/dnainjector/spores
	name = "\improper DNA injector (Agaricale Pores)"
	add_mutations = list(/datum/mutation/spores)

/obj/item/dnainjector/antispores
	name = "\improper DNA injector (Anti-Agaricale Pores)"
	remove_mutations = list(/datum/mutation/spores)

// note: this is not functional. mutation is not added to temporary_mutation list - it becomes permanent.
/obj/item/dnainjector/timed
	var/duration = 600

/obj/item/dnainjector/timed/inject(mob/living/carbon/M, mob/user)
	if(M.stat == DEAD)	//prevents dead people from having their DNA changed
		to_chat(user, span_notice("You can't modify [M]'s DNA while [M.p_theyre()] dead."))
		return FALSE

	if(M.has_dna() && !(HAS_TRAIT(M, TRAIT_BADDNA)))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		var/endtime = world.time+duration
		for(var/mutation in remove_mutations)
			if(mutation == /datum/mutation/race)
				if(ishuman(M))
					continue
				M = M.dna.remove_mutation(mutation)
			else
				M.dna.remove_mutation(mutation)
		for(var/mutation in add_mutations)
			if(M.dna.get_mutation(mutation))
				continue //Skip permanent mutations we already have.
			if(mutation == /datum/mutation/race && ishuman(M))
				message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(M)] with the [name] [span_danger("(MONKEY)")]")
				log_msg += " (MONKEY)"
				M = M.dna.add_mutation(mutation, MUT_OTHER, endtime)
			else
				M.dna.add_mutation(mutation, MUT_OTHER, endtime)
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				if(!M.dna.previous["name"])
					M.dna.previous["name"] = M.real_name
				if(!M.dna.previous["UE"])
					M.dna.previous["UE"] = M.dna.unique_enzymes
				if(!M.dna.previous["blood_type"])
					M.dna.previous["blood_type"] = M.dna.blood_type
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
				M.dna.temporary_mutations[UE_CHANGED] = endtime
			if(fields["UI"])	//UI+UE
				if(!M.dna.previous["UI"])
					M.dna.previous["UI"] = M.dna.uni_identity
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
				M.dna.temporary_mutations[UI_CHANGED] = endtime
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	else
		return FALSE

/obj/item/dnainjector/timed/hulk
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations = list(/datum/mutation/hulk)

/obj/item/dnainjector/timed/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations = list(/datum/mutation/race)

/obj/item/dnainjector/activator
	name = "\improper DNA activator"
	desc = "Activates the current mutation on injection, if the subject has it."
	var/doitanyway = FALSE
	var/research = FALSE //Set to true to get expended and filled injectors for chromosomes
	var/filled = FALSE

/obj/item/dnainjector/activator/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !HAS_TRAIT(M, TRAIT_RADIMMUNE) && !HAS_TRAIT(M, TRAIT_BADDNA))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/mutation in add_mutations)
			var/datum/mutation/HM = mutation
			if(istype(HM, /datum/mutation))
				mutation = HM.type
			if(!M.dna.activate_mutation(HM))
				if(!doitanyway)
					log_msg += "(FAILED)"
				else
					M.dna.add_mutation(HM, MUT_EXTRA)
			else if(research && M.client)
				filled = TRUE
			log_msg += "([mutation])"
		if(filled)
			name = "filled [name]"
		else
			name = "expended [name]"
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	return FALSE
