//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 30
	alert_type = /atom/movable/screen/alert/status_effect/shadow_mend

/atom/movable/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message(span_notice("Violet light wraps around [owner]'s body!"), span_notice("Violet light wraps around your body!"))
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message(span_warning("The violet light around [owner] glows black!"), span_warning("The tendrils around you cinch tightly and reap their toll..."))
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(/datum/status_effect/void_price)


/datum/status_effect/void_price
	id = "void_price"
	duration = 300
	tick_interval = 30
	alert_type = /atom/movable/screen/alert/status_effect/void_price

/atom/movable/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick()
	SEND_SOUND(owner, sound('sound/magic/summon_karp.ogg', volume = 25))
	owner.adjustBruteLoss(3)

/datum/status_effect/cyborg_power_regen
	id = "power_regen"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/power_regen
	var/power_to_give = 0 //how much power is gained each tick

/datum/status_effect/cyborg_power_regen/on_creation(mob/living/new_owner, new_power_per_tick)
	. = ..()
	if(. && isnum_safe(new_power_per_tick))
		power_to_give = new_power_per_tick

/atom/movable/screen/alert/status_effect/power_regen
	name = "Power Regeneration"
	desc = "You are quickly regenerating power!"
	icon_state = "power_regen"

/datum/status_effect/cyborg_power_regen/tick()
	var/mob/living/silicon/robot/cyborg = owner
	if(!istype(cyborg) || !cyborg.cell)
		qdel(src)
		return
	playsound(cyborg, 'sound/effects/light_flicker.ogg', 50, 1)
	cyborg.cell.give(power_to_give)

/datum/status_effect/his_grace
	id = "his_grace"
	duration = -1
	tick_interval = 4
	alert_type = /atom/movable/screen/alert/status_effect/his_grace
	var/bloodlust = 0

/atom/movable/screen/alert/status_effect/his_grace
	name = "His Grace"
	desc = "His Grace hungers, and you must feed Him."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/atom/movable/screen/alert/status_effect/his_grace/MouseEntered(location,control,params)
	desc = initial(desc)
	var/datum/status_effect/his_grace/HG = attached_effect
	desc += "<br><font size=3><b>Current Bloodthirst: [HG.bloodlust]</b></font>\
	<br>Becomes undroppable at <b>[HIS_GRACE_FAMISHED]</b>\
	<br>Will consume you at <b>[HIS_GRACE_CONSUME_OWNER]</b>"
	..()

/datum/status_effect/his_grace/on_apply()
	owner.log_message("gained His Grace's stun immunity", LOG_ATTACK)
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")
	return ..()

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	for(var/obj/item/his_grace/HG in owner.held_items)
		if(HG.bloodthirst > bloodlust)
			bloodlust = HG.bloodthirst
		if(HG.awakened)
			graces++
	if(!graces)
		owner.apply_status_effect(/datum/status_effect/his_wrath)
		qdel(src)
		return
	var/grace_heal = bloodlust * 0.05
	owner.adjustBruteLoss(-grace_heal)
	owner.adjustFireLoss(-grace_heal)
	owner.adjustToxLoss(-grace_heal, TRUE, TRUE)
	owner.adjustOxyLoss(-(grace_heal * 2))
	owner.adjustCloneLoss(-grace_heal)

/datum/status_effect/his_grace/on_remove()
	owner.log_message("lost His Grace's stun immunity", LOG_ATTACK)
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.stun_absorption -= "hisgrace"


/datum/status_effect/wish_granters_gift //Fully revives after ten seconds.
	id = "wish_granters_gift"
	duration = 50
	alert_type = /atom/movable/screen/alert/status_effect/wish_granters_gift

/datum/status_effect/wish_granters_gift/on_apply()
	to_chat(owner, span_notice("Death is not your end! The Wish Granter's energy suffuses you, and you begin to rise..."))
	return ..()

/datum/status_effect/wish_granters_gift/on_remove()
	owner.revive(full_heal = TRUE, admin_revive = TRUE)
	owner.visible_message(span_warning("[owner] appears to wake from the dead, having healed all wounds!"), span_notice("You have regenerated."))

/atom/movable/screen/alert/status_effect/wish_granters_gift
	name = "Wish Granter's Immortality"
	desc = "You are being resurrected!"
	icon_state = "wish_granter"

/datum/status_effect/cult_master
	id = "The Cult Master"
	duration = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/alive = TRUE

/datum/status_effect/cult_master/proc/deathrattle()
	if(!QDELETED(GLOB.cult_narsie))
		return //if Nar'Sie is alive, don't even worry about it
	var/area/A = get_area(owner)
	for(var/datum/mind/B in SSticker.mode.cult)
		if(isliving(B.current))
			var/mob/living/M = B.current
			SEND_SOUND(M, sound('sound/hallucinations/veryfar_noise.ogg'))
			to_chat(M, span_cultlarge("The Cult's Master, [owner], has fallen in \the [A]!"))

/datum/status_effect/cult_master/tick()
	if(owner.stat != DEAD && !alive)
		alive = TRUE
		return
	if(owner.stat == DEAD && alive)
		alive = FALSE
		deathrattle()

/datum/status_effect/cult_master/on_remove()
	deathrattle()
	. = ..()

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blooddrunk
	var/last_health = 0
	var/last_bruteloss = 0
	var/last_fireloss = 0
	var/last_toxloss = 0
	var/last_oxyloss = 0
	var/last_cloneloss = 0
	var/last_staminaloss = 0

/atom/movable/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "blooddrunk")
		owner.maxHealth *= 10
		owner.bruteloss *= 10
		owner.fireloss *= 10
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/BP = X
				BP.max_damage *= 10
				BP.brute_dam *= 10
				BP.burn_dam *= 10
		owner.toxloss *= 10
		owner.oxyloss *= 10
		owner.cloneloss *= 10
		owner.staminaloss *= 10
		owner.updatehealth()
		last_health = owner.health
		last_bruteloss = owner.getBruteLoss()
		last_fireloss = owner.getFireLoss()
		last_toxloss = owner.getToxLoss()
		last_oxyloss = owner.getOxyLoss()
		last_cloneloss = owner.getCloneLoss()
		last_staminaloss = owner.getStaminaLoss()
		owner.log_message("gained blood-drunk stun immunity", LOG_ATTACK)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1, use_reverb = FALSE)

/datum/status_effect/blooddrunk/tick() //multiply the effect of healing by 10
	if(owner.health > last_health)
		var/needs_health_update = FALSE
		var/new_bruteloss = owner.getBruteLoss()
		if(new_bruteloss < last_bruteloss)
			var/heal_amount = (new_bruteloss - last_bruteloss) * 10
			owner.adjustBruteLoss(heal_amount, updating_health = FALSE)
			new_bruteloss = owner.getBruteLoss()
			needs_health_update = TRUE
		last_bruteloss = new_bruteloss

		var/new_fireloss = owner.getFireLoss()
		if(new_fireloss < last_fireloss)
			var/heal_amount = (new_fireloss - last_fireloss) * 10
			owner.adjustFireLoss(heal_amount, updating_health = FALSE)
			new_fireloss = owner.getFireLoss()
			needs_health_update = TRUE
		last_fireloss = new_fireloss

		var/new_toxloss = owner.getToxLoss()
		if(new_toxloss < last_toxloss)
			var/heal_amount = (new_toxloss - last_toxloss) * 10
			owner.adjustToxLoss(heal_amount, updating_health = FALSE)
			new_toxloss = owner.getToxLoss()
			needs_health_update = TRUE
		last_toxloss = new_toxloss

		var/new_oxyloss = owner.getOxyLoss()
		if(new_oxyloss < last_oxyloss)
			var/heal_amount = (new_oxyloss - last_oxyloss) * 10
			owner.adjustOxyLoss(heal_amount, updating_health = FALSE)
			new_oxyloss = owner.getOxyLoss()
			needs_health_update = TRUE
		last_oxyloss = new_oxyloss

		var/new_cloneloss = owner.getCloneLoss()
		if(new_cloneloss < last_cloneloss)
			var/heal_amount = (new_cloneloss - last_cloneloss) * 10
			owner.adjustCloneLoss(heal_amount, updating_health = FALSE)
			new_cloneloss = owner.getCloneLoss()
			needs_health_update = TRUE
		last_cloneloss = new_cloneloss

		var/new_staminaloss = owner.getStaminaLoss()
		if(new_staminaloss < last_staminaloss)
			var/heal_amount = (new_staminaloss - last_staminaloss) * 10
			owner.adjustStaminaLoss(heal_amount, updating_health = FALSE)
			new_staminaloss = owner.getStaminaLoss()
			needs_health_update = TRUE
		last_staminaloss = new_staminaloss

		if(needs_health_update)
			owner.updatehealth()
			owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1)
	last_health = owner.health

/datum/status_effect/blooddrunk/on_remove()
	tick()
	owner.maxHealth *= 0.1
	owner.bruteloss *= 0.1
	owner.fireloss *= 0.1
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		for(var/X in C.bodyparts)
			var/obj/item/bodypart/BP = X
			BP.brute_dam *= 0.1
			BP.burn_dam *= 0.1
			BP.max_damage /= 10
	owner.toxloss *= 0.1
	owner.oxyloss *= 0.1
	owner.cloneloss *= 0.1
	owner.staminaloss *= 0.1
	owner.updatehealth()
	owner.log_message("lost blood-drunk stun immunity", LOG_ATTACK)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "blooddrunk");
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

/datum/status_effect/sword_spin
	id = "Bastard Sword Spin"
	duration = 50
	tick_interval = 8
	alert_type = null


/datum/status_effect/sword_spin/on_apply()
	owner.visible_message(span_danger("[owner] begins swinging the sword with inhuman strength!"))
	var/oldcolor = owner.color
	owner.color = "#ff0000"
	owner.add_stun_absorption("bloody bastard sword", duration, 2, "doesn't even flinch as the sword's power courses through them!", "You shrug off the stun!", " glowing with a blazing red aura!")
	owner.spin(duration,1)
	animate(owner, color = oldcolor, time = duration, easing = EASE_IN)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, update_atom_colour)), duration)
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, 0)
	return ..()


/datum/status_effect/sword_spin/tick()
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, 0)
	var/obj/item/slashy
	slashy = owner.get_active_held_item()
	for(var/mob/living/M in ohearers(1,owner))
		slashy.attack(M, owner)

/datum/status_effect/sword_spin/on_remove()
	owner.visible_message(span_warning("[owner]'s inhuman strength dissipates and the sword's runes grow cold!"))

//Used by changelings to rapidly heal
//Being on fire will suppress this healing
/datum/status_effect/fleshmend
	id = "fleshmend"
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend
	//Actual healing lasts for 30 seconds
	duration = 32 SECONDS
	var/ticks_passed = 0

/datum/status_effect/fleshmend/tick()
	ticks_passed ++
	if(owner.on_fire)
		linked_alert.icon_state = "fleshmend_fire"
		return
	else
		linked_alert.icon_state = "fleshmend"
	if(ticks_passed < 2)
		return
	else if(ticks_passed == 2)
		to_chat(owner, span_changeling("We begin to repair our tissue damage..."))
	//Heals 2 brute per second, for a total of 60
	owner.adjustBruteLoss(-2, FALSE, TRUE)
	//Heals 1 fireloss per second, for a total of 30
	owner.adjustFireLoss(-1, FALSE, TRUE)
	//Heals 5 oxyloss per second for a total of 150
	owner.adjustOxyLoss(-5, FALSE, TRUE)
	//Heals 0.5 cloneloss per second for a total of 15
	owner.adjustCloneLoss(-0.5, TRUE, TRUE)

/atom/movable/screen/alert/status_effect/fleshmend
	name = "Fleshmend"
	desc = "Our wounds are rapidly healing. <i>This effect is prevented if we are on fire.</i>"
	icon_state = "fleshmend"

/datum/status_effect/changeling
	var/datum/antagonist/changeling/ling
	var/chem_per_tick = 1

/datum/status_effect/changeling/on_apply()
	ling = is_changeling(owner)
	if(!ling)
		return FALSE
	return TRUE

/datum/status_effect/changeling/tick()
	if(ling.chem_charges < chem_per_tick)
		qdel(src)
		return FALSE
	ling.chem_charges -= chem_per_tick
	return TRUE

//Changeling invisibility
/datum/status_effect/changeling/camouflage
	id = "changelingcamo"
	alert_type = /atom/movable/screen/alert/status_effect/changeling_camouflage
	tick_interval = 5

/datum/status_effect/changeling/camouflage/tick()
	if(!..())
		return
	if(owner.on_fire)
		large_increase()
		return
	owner.alpha = max(owner.alpha - 20, 0)

/datum/status_effect/changeling/camouflage/on_apply()
	if(!..())
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(slight_increase))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(large_increase))
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(large_increase))
	RegisterSignal(owner, COMSIG_ATOM_BUMPED, PROC_REF(slight_increase))
	return TRUE

/datum/status_effect/changeling/camouflage/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_APPLY_DAMAGE, COMSIG_ATOM_BUMPED))
	owner.alpha = 255

/datum/status_effect/changeling/camouflage/proc/slight_increase()
	owner.alpha = min(owner.alpha + 15, 255)

/datum/status_effect/changeling/camouflage/proc/large_increase()
	owner.alpha = min(owner.alpha + 50, 255)

/atom/movable/screen/alert/status_effect/changeling_camouflage
	name = "Camouflage"
	desc = "We have adapted our skin to refract light around us."
	icon_state = "changeling_camo"

//Changeling mindshield
/datum/status_effect/changeling/mindshield
	id = "changelingmindshield"
	alert_type = /atom/movable/screen/alert/status_effect/changeling_mindshield
	tick_interval = 5 SECONDS
	chem_per_tick = 1

/datum/status_effect/changeling/mindshield/tick()
	if(..() && owner.on_fire)
		qdel(src)

/datum/status_effect/changeling/mindshield/on_apply()
	if(!..())
		return FALSE
	ADD_TRAIT(owner, TRAIT_FAKE_MINDSHIELD, CHANGELING_TRAIT)
	owner.sec_hud_set_implants()
	return TRUE

/datum/status_effect/changeling/mindshield/on_remove()
	REMOVE_TRAIT(owner, TRAIT_FAKE_MINDSHIELD, CHANGELING_TRAIT)
	owner.sec_hud_set_implants()

/atom/movable/screen/alert/status_effect/changeling_mindshield
	name = "Fake Mindshield"
	desc = "We are emitting a signal, causing us to appear as mindshielded to security HUDs."
	icon_state = "changeling_mindshield"

//Hippocratic Oath: Applied when the Rod of Asclepius is activated.
/datum/status_effect/hippocratic_oath
	id = "Hippocratic Oath"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 25
	examine_text = span_notice("They seem to have an aura of healing and helpfulness about them.")
	alert_type = null
	var/hand
	var/deathTick = 0

/datum/status_effect/hippocratic_oath/on_apply()
	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	return ..()

/datum/status_effect/hippocratic_oath/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(owner)

/datum/status_effect/hippocratic_oath/tick()
	if(owner.stat == DEAD)
		if(deathTick < 4)
			deathTick += 1
		else
			owner.visible_message("[owner]'s soul is absorbed into the rod, relieving the previous snake of its duty.")
			var/mob/living/simple_animal/hostile/retaliate/poison/snake/healSnake = new(owner.loc)
			var/list/chems = list(/datum/reagent/medicine/bicaridine, /datum/reagent/medicine/salbutamol, /datum/reagent/medicine/kelotane, /datum/reagent/medicine/antitoxin)
			healSnake.poison_type = pick(chems)
			healSnake.name = "Asclepius's Snake"
			healSnake.real_name = "Asclepius's Snake"
			healSnake.desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Unlike the average snake, its bites contain chemicals with minor healing properties."
			new /obj/effect/decal/cleanable/ash(owner.loc)
			new /obj/item/rod_of_asclepius(owner.loc)
			owner.investigate_log("has been consumed by the Rod of Asclepius.", INVESTIGATE_DEATHS)
			qdel(owner)
	else
		if(iscarbon(owner))
			var/mob/living/carbon/itemUser = owner
			var/obj/item/heldItem = itemUser.get_item_for_held_index(hand)
			if(heldItem == null || heldItem.type != /obj/item/rod_of_asclepius) //Checks to make sure the rod is still in their hand
				var/obj/item/rod_of_asclepius/newRod = new(itemUser.loc)
				newRod.activated()
				if(!itemUser.has_hand_for_held_index(hand))
					//If user does not have the corresponding hand anymore, give them one and return the rod to their hand
					if(((hand % 2) == 0))
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_R_ARM, FALSE, FALSE)
						L.attach_limb(itemUser)
						itemUser.put_in_hand(newRod, hand, forced = TRUE)
					else
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_L_ARM, FALSE, FALSE)
						L.attach_limb(itemUser)
						itemUser.put_in_hand(newRod, hand, forced = TRUE)
					to_chat(itemUser, span_notice("Your arm suddenly grows back with the Rod of Asclepius still attached!"))
				else
					//Otherwise get rid of whatever else is in their hand and return the rod to said hand
					itemUser.put_in_hand(newRod, hand, forced = TRUE)
					to_chat(itemUser, span_notice("The Rod of Asclepius suddenly grows back out of your arm!"))
			//Because a servant of medicines stops at nothing to help others, lets keep them on their toes and give them an additional boost.
			if(itemUser.health < itemUser.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(itemUser), "#375637")
			itemUser.adjustBruteLoss(-1.5)
			itemUser.adjustFireLoss(-1.5)
			itemUser.adjustToxLoss(-1.5, forced = TRUE) //Because Slime People are people too
			itemUser.adjustOxyLoss(-1.5)
			itemUser.adjustStaminaLoss(-1.5)
			itemUser.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1.5)
			itemUser.adjustCloneLoss(-0.5) //Becasue apparently clone damage is the bastion of all health
		//Heal all those around you, unbiased
		for(var/mob/living/L in hearers(7, owner))
			if(L.health < L.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(L), "#375637")
			if(iscarbon(L))
				L.adjustBruteLoss(-3.5)
				L.adjustFireLoss(-3.5)
				L.adjustToxLoss(-3.5, FALSE, TRUE) //Because Slime People are people too
				L.adjustOxyLoss(-3.5)
				L.adjustStaminaLoss(-3.5)
				L.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3.5)
				L.adjustCloneLoss(-1) //Becasue apparently clone damage is the bastion of all health
			else if(issilicon(L))
				L.adjustBruteLoss(-3.5)
				L.adjustFireLoss(-3.5)
			else if(isanimal(L))
				var/mob/living/simple_animal/SM = L
				SM.adjustHealth(-3.5, forced = TRUE)

/atom/movable/screen/alert/status_effect/regenerative_core
	name = "Blessing of the Necropolis"
	desc = "The power of the necropolis flows through you. You could get used to this..."
	icon_state = "regenerative_core"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 300
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/regenerative_core
	var/power = 1
	var/duration_mod = 1
	var/alreadyinfected = FALSE

/datum/status_effect/regenerative_core/on_apply()
	if(!HAS_TRAIT(owner, TRAIT_NECROPOLIS_INFECTED))
		to_chat(owner, span_userdanger("Tendrils of vile corruption knit your flesh together and strengthen your sinew. You resist the temptation of giving in to the corruption."))
	else
		alreadyinfected = TRUE
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "legion_core_trait")
	ADD_TRAIT(owner, TRAIT_NECROPOLIS_INFECTED, "legion_core_trait")
	if(is_mining_level(owner.z))
		power = 5
		duration_mod = 2
	owner.adjustBruteLoss(-20 * power)
	owner.adjustFireLoss(-20 * power)
	owner.cure_nearsighted()
	owner.ExtinguishMob()
	owner.fire_stacks = 0
	owner.set_blindness(0)
	owner.set_blurriness(0)
	owner.restore_blood()
	owner.bodytemperature = owner.get_body_temp_normal()
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/humi = owner
		humi.coretemperature = humi.get_body_temp_normal()
	owner.restoreEars()
	duration = rand(150, 450) * duration_mod
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "legion_core_trait")
	REMOVE_TRAIT(owner, TRAIT_NECROPOLIS_INFECTED, "legion_core_trait")
	if(!alreadyinfected)
		to_chat(owner, span_userdanger("You feel empty as the vile tendrils slink out of your flesh and leave you, a fragile human once more."))

/datum/status_effect/good_music
	id = "Good Music"
	alert_type = null
	duration = 6 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/good_music/tick()
	owner.dizziness = max(0, owner.dizziness - 2)
	owner.jitteriness = max(0, owner.jitteriness - 2)
	owner.confused = max(0, owner.confused - 1)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "goodmusic", /datum/mood_event/goodmusic)

/datum/status_effect/antimagic
	id = "antimagic"
	duration = 10 SECONDS
	examine_text = span_notice("They seem to be covered in a dull, grey aura.")

/datum/status_effect/antimagic/on_apply()
	owner.visible_message(span_notice("[owner] is coated with a dull aura!"))
	owner.AddComponent(/datum/component/anti_magic, \
		_source = MAGIC_TRAIT, \
		antimagic_flags = MAGIC_RESISTANCE, \
	)
	//glowing wings overlay
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, 0)
	return ..()

/datum/status_effect/antimagic/on_remove()
	for (var/datum/component/anti_magic/anti_magic in owner.GetComponents(/datum/component/anti_magic))
		if (anti_magic.source == MAGIC_TRAIT)
			qdel(anti_magic)
	owner.visible_message(span_warning("[owner]'s dull aura fades away..."))

/datum/status_effect/planthealing
	id = "Photosynthesis"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 25
	alert_type = /atom/movable/screen/alert/status_effect/planthealing
	examine_text = span_notice("Their leaves seem to be flourishing in the light!")

/atom/movable/screen/alert/status_effect/planthealing
	name = "Photosynthesis"
	desc = "Your wounds seem to be healing from the light."
	icon_state = "blooming"

/datum/status_effect/planthealing/on_apply()
	ADD_TRAIT(owner, TRAIT_PLANTHEALING, "Light Source")
	return ..()

/datum/status_effect/planthealing/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PLANTHEALING, "Light Source")

/datum/status_effect/planthealing/tick()
	owner.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC) //one unit of brute and burn healing should be good with the amount of times this is ran. Much slower than spec_life

/datum/status_effect/crucible_soul
	id = "Blessing of Crucible Soul"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	examine_text = span_notice("They don't seem to be all here.")
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul
	var/turf/location

/datum/status_effect/crucible_soul/on_apply()
	to_chat(owner,span_notice("You phase through reality, nothing is out of bounds!"))
	owner.alpha = 180
	owner.pass_flags |= PASSCLOSEDTURF | PASSTRANSPARENT | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB
	location = get_turf(owner)
	return TRUE

/datum/status_effect/crucible_soul/on_remove()
	to_chat(owner,span_notice("You regain your physicality, returning you to your original location..."))
	owner.alpha = initial(owner.alpha)
	owner.pass_flags &= ~(PASSCLOSEDTURF | PASSTRANSPARENT | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB)
	owner.forceMove(location)
	location = null

/datum/status_effect/duskndawn
	id = "Blessing of Dusk and Dawn"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	alert_type =/atom/movable/screen/alert/status_effect/duskndawn

/datum/status_effect/duskndawn/on_apply()
	ADD_TRAIT(owner,TRAIT_XRAY_VISION,type)
	owner.update_sight()
	return TRUE

/datum/status_effect/duskndawn/on_remove()
	REMOVE_TRAIT(owner,TRAIT_XRAY_VISION,type)
	owner.update_sight()

/atom/movable/screen/alert/status_effect/crucible_soul
	name = "Blessing of Crucible Soul"
	desc = "You phased through reality. You are halfway to your final destination..."
	icon_state = "crucible"

/atom/movable/screen/alert/status_effect/duskndawn
	name = "Blessing of Dusk and Dawn"
	desc = "Many things hide beyond the horizon. With Owl's help I managed to slip past Sun's guard and Moon's watch."
	icon_state = "duskndawn"
