#define VEST_STEALTH 1
#define VEST_COMBAT 2
#define GIZMO_SCAN 1
#define GIZMO_MARK 2
#define MIND_DEVICE_MESSAGE 1
#define MIND_DEVICE_CONTROL 2

//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "A vest outfitted with advanced stealth technology. It has two modes - combat and stealth."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor_type = /datum/armor/abductor_vest
	actions_types = list(/datum/action/item_action/hands_free/activate)
	allowed = list(
		/obj/item/abductor,
		/obj/item/melee/baton/abductor,
		/obj/item/melee/baton,
		/obj/item/melee/tonfa,
		/obj/item/gun/energy,
		/obj/item/restraints/handcuffs
		)
	slowdown = 0
	var/mode = VEST_STEALTH
	var/stealth_active = FALSE
	/// Cooldown in seconds
	var/combat_cooldown = 20
	var/datum/icon_snapshot/disguise

/datum/armor/abductor_combat
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	rad = 15
	bio = 50
	fire = 90
	acid = 90
	stamina = 30
	bleed = 40

/datum/armor/abductor_vest
	melee = 15
	bullet = 15
	laser = 15
	energy = 25
	bomb = 15
	rad = 50
	bio = 15
	fire = 70
	acid = 70
	stamina = 60
	bleed = 80

/obj/item/clothing/suit/armor/abductor/vest/proc/toggle_nodrop()
	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT))
		REMOVE_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	else
		ADD_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	if(ismob(loc))
		to_chat(loc, span_notice("Your vest is now [HAS_TRAIT_FROM(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT) ? "locked" : "unlocked"]."))

/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			set_armor(/datum/armor/abductor_combat)
			icon_state = "vest_combat"
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			set_armor(/datum/armor/abductor_vest)
			icon_state = "vest_stealth"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_suit()
	update_action_buttons()

/obj/item/clothing/suit/armor/abductor/vest/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_OCLOTHING) //we only give the mob the ability to activate the vest if he's actually wearing it.
		return TRUE

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = 1
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(M), M.dir)
		RegisterSignal(M, COMSIG_HUMAN_GET_VISIBLE_NAME, PROC_REF(return_disguise_name))
		M.name_override = disguise.name
		M.icon = disguise.icon
		M.icon_state = disguise.icon_state
		M.cut_overlays()
		M.add_overlay(disguise.overlays)
		M.update_inv_hands()

/obj/item/clothing/suit/armor/abductor/vest/proc/return_disguise_name(mob/living/carbon/human/source, list/identity)
	SIGNAL_HANDLER
	if(identity[VISIBLE_NAME_FORCED]) // name-forcing overrides disguise
		return
	identity[VISIBLE_NAME_FACE] = disguise.name
	identity[VISIBLE_NAME_ID] = ""

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = 0
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(M), M.dir)
		UnregisterSignal(M, COMSIG_HUMAN_GET_VISIBLE_NAME)
		M.name_override = null
		M.cut_overlays()
		M.regenerate_icons()

/obj/item/clothing/suit/armor/abductor/vest/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/IsReflect()
	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/ui_action_click()
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(loc))
		if(combat_cooldown < initial(combat_cooldown))
			to_chat(loc, span_warning("Combat injection is still recharging."))
			return
		var/mob/living/carbon/human/M = loc
		M.adjustStaminaLoss(-75)
		M.SetUnconscious(0)
		M.SetStun(0)
		M.SetKnockdown(0)
		M.SetImmobilized(0)
		M.SetParalyzed(0)
		combat_cooldown = 0
		START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/vest/process(delta_time)
	combat_cooldown += delta_time
	if(combat_cooldown >= initial(combat_cooldown))
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/machinery/abductor/console/C in GLOB.machines)
		if(C.vest == src)
			C.vest = null
			break
	. = ..()

/obj/item/abductor
	icon = 'icons/obj/abductor.dmi'
	lefthand_file = 'icons/mob/inhands/antag/abductor_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/abductor_righthand.dmi'

/obj/item/proc/AbductorCheck(mob/user)
	if(HAS_TRAIT(user.mind, TRAIT_ABDUCTOR_TRAINING))
		return TRUE
	to_chat(user, span_warning("You can't figure out how this works!"))
	return FALSE

/obj/item/abductor/proc/ScientistCheck(mob/user)
	if(!HAS_TRAIT(user.mind, TRAIT_ABDUCTOR_TRAINING))
		to_chat(user, span_warning("You can't figure out how this works!"))
		return FALSE
	if(!HAS_TRAIT(user.mind, TRAIT_ABDUCTOR_SCIENTIST_TRAINING))
		to_chat(user, span_warning("You're not trained to use this!"))
		return FALSE
	return TRUE

/obj/item/abductor/gizmo
	name = "science tool"
	desc = "A dual-mode tool for retrieving specimens and scanning appearances. Scanning can be done through cameras."
	icon_state = "gizmo_scan"
	item_state = "silencer"
	var/mode = GIZMO_SCAN
	var/mob/living/marked = null
	var/obj/machinery/abductor/console/console

/obj/item/abductor/gizmo/attack_self(mob/user)
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, span_warning("The device is not linked to console!"))
		return

	if(mode == GIZMO_SCAN)
		mode = GIZMO_MARK
		icon_state = "gizmo_mark"
	else
		mode = GIZMO_SCAN
		icon_state = "gizmo_scan"
	to_chat(user, span_notice("You switch the device to [mode == GIZMO_SCAN ? "SCAN" : "MARK"] MODE"))

/obj/item/abductor/gizmo/attack(mob/living/M, mob/user)
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, span_warning("The device is not linked to console!"))
		return

	switch(mode)
		if(GIZMO_SCAN)
			scan(M, user)
		if(GIZMO_MARK)
			mark(M, user)


/obj/item/abductor/gizmo/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	if(flag)
		return
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, span_warning("The device is not linked to console!"))
		return

	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/abductor/gizmo/proc/scan(atom/target, mob/living/user)
	if(ishuman(target))
		console.AddSnapshot(target)
		to_chat(user, span_notice("You scan [target] and add [target.p_them()] to the database."))

/obj/item/abductor/gizmo/proc/mark(atom/target, mob/living/user)
	if(marked == target)
		to_chat(user, span_warning("This specimen is already marked!"))
		return
	if(ishuman(target))
		if(isabductor(target))
			marked = target
			to_chat(user, span_notice("You mark [target] for future retrieval."))
		else
			prepare(target,user)
	else
		prepare(target,user)

/obj/item/abductor/gizmo/proc/prepare(atom/target, mob/living/user)
	if(get_dist(target,user) > 1)
		to_chat(user, span_warning("You need to be next to the specimen to prepare it for transport!"))
		return
	to_chat(user, span_notice("You begin preparing [target] for transport..."))
	if(do_after(user, 100, target = target))
		marked = target
		to_chat(user, span_notice("You finish preparing [target] for transport."))

/obj/item/abductor/gizmo/Destroy()
	console?.gizmo = null
	. = ..()


/obj/item/abductor/silencer
	name = "abductor silencer"
	desc = "A compact device used to shut down communications equipment."
	icon_state = "silencer"
	item_state = "gizmo"

/obj/item/abductor/silencer/ComponentInitialize()
	. = ..()
	//Activate the jammer
	//This jammer will not block cameras or AI shells
	var/datum/component/radio_jamming/added_component = AddComponent(/datum/component/radio_jamming, 5, RADIO_JAMMER_ABDUCTOR_LEVEL)
	added_component.enable()

/obj/item/abductor/mind_device
	name = "mental interface device"
	desc = "A dual-mode tool for directly communicating with sentient brains. It can be used to send a direct message to a target, \
			or to send a command to a test subject with a charged gland."
	icon_state = "mind_device_message"
	item_state = "silencer"
	var/mode = MIND_DEVICE_MESSAGE

/obj/item/abductor/mind_device/attack_self(mob/user)
	if(!ScientistCheck(user))
		return

	if(mode == MIND_DEVICE_MESSAGE)
		mode = MIND_DEVICE_CONTROL
		icon_state = "mind_device_control"
	else
		mode = MIND_DEVICE_MESSAGE
		icon_state = "mind_device_message"
	to_chat(user, span_notice("You switch the device to [mode==MIND_DEVICE_MESSAGE? "TRANSMISSION": "COMMAND"] MODE"))

/obj/item/abductor/mind_device/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	if(!ScientistCheck(user))
		return

	switch(mode)
		if(MIND_DEVICE_CONTROL)
			mind_control(target, user)
		if(MIND_DEVICE_MESSAGE)
			mind_message(target, user)

/obj/item/abductor/mind_device/proc/mind_control(atom/target, mob/living/user)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/organ/heart/gland/G = C.getorganslot("heart")
		if(!istype(G))
			to_chat(user, span_warning("Your target does not have an experimental gland!"))
			return
		if(!G.mind_control_uses)
			to_chat(user, span_warning("Your target's gland is spent!"))
			return
		if(G.active_mind_control)
			to_chat(user, span_warning("Your target is already under a mind-controlling influence!"))
			return

		var/command = stripped_input(user, "Enter the command for your target to follow.\
											Uses Left: [G.mind_control_uses], Duration: [DisplayTimeText(G.mind_control_duration)]","Enter command")
		if(!command)
			return
		if(QDELETED(user) || user.get_active_held_item() != src || loc != user)
			return
		if(QDELETED(G))
			return

		if(istype(C.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			to_chat(user, span_warning("Your target seems to have some sort of protective headgear on, blocking the message from being sent!"))
			return

		G.mind_control(command, user)
		to_chat(user, span_notice("You send the command to your target."))

/obj/item/abductor/mind_device/proc/mind_message(atom/target, mob/living/user)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(user, span_warning("Your target is dead!"))
			return
		var/message = stripped_input(user, "Write a message to send to your target's brain.","Enter message")
		if(!message)
			return
		if(CHAT_FILTER_CHECK(message))
			to_chat(user, span_warning("Your message contains forbidden words."))
			return
		message = user.treat_message_min(message)
		if(QDELETED(L) || L.stat == DEAD)
			return

		to_chat(L, "[span_italics("You hear a voice in your head saying:")] [span_abductor(message)]")
		to_chat(user, span_notice("You send the message to your target."))

		for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
			var/sender = FOLLOW_LINK(ghost, user)
			var/receiver = FOLLOW_LINK(ghost, L)
			to_chat(ghost, span_deadsay("[sender] [span_name("[user]")] [span_abductor("Abductor Mental Telepathy")] -> [receiver] [span_name("[L]")]: [span_boldmessage("[message]")]"))
		log_directed_talk(user, L, message, LOG_SAY, "abductor whisper")


/obj/item/firing_pin/abductor
	name = "alien firing pin"
	icon_state = "firing_pin_ayy"
	desc = "This firing pin is slimy and warm; you can swear you feel it constantly trying to mentally probe you."
	fail_message = span_abductor("Firing error, please contact Command.")

/obj/item/firing_pin/abductor/pin_auth(mob/living/user)
	. = isabductor(user)

/obj/item/gun/energy/alien
	name = "alien pistol"
	desc = "A complicated gun that fires bursts of high-intensity radiation, electromagnetic disruption bolts or freezing shots."
	ammo_type = list(/obj/item/ammo_casing/energy/declone, /obj/item/ammo_casing/energy/ion, /obj/item/ammo_casing/energy/temp)
	pin = /obj/item/firing_pin/abductor
	icon_state = "alienpistol"
	item_state = "alienpistol"
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/paper/guides/antag/abductor
	name = "Dissection Guide"
	icon_state = "alienpaper_words"
	show_written_words = FALSE
	default_raw_text = {"<b>Dissection for Dummies</b><br>

<br>
1.Acquire fresh specimen.<br>
2.Put the specimen on operating table.<br>
3.Apply surgical drapes, preparing for experimental dissection.<br>
4.Apply scalpel to specimen's torso.<br>
5.Clamp bleeders on specimen's torso with a hemostat.<br>
6.Retract skin of specimen's torso with a retractor.<br>
7.Apply scalpel again to specimen's torso.<br>
8.Search through the specimen's torso with your hands to remove any superfluous organs.<br>
9.Insert replacement gland (Retrieve one from gland storage).<br>
10.Consider dressing the specimen back to not disturb the habitat. <br>
11.Put the specimen in the experiment machinery.<br>
12.Choose one of the machine options. The target will be analyzed and teleported to the selected drop-off point.<br>
13.You will receive one supply credit, and the subject will be counted towards your quota.<br>
<br>
Congratulations! You are now trained for invasive xenobiology research!"}

/obj/item/paper/guides/antag/abductor/AltClick()
	return //otherwise it would fold into a paperplane.

#define BATON_STUN 0
#define BATON_SLEEP 1
#define BATON_CUFF 2
#define BATON_PROBE 3
#define BATON_MODES 4

/obj/item/melee/baton/abductor
	name = "advanced baton"
	desc = "A quad-mode baton used for incapacitation and restraining of specimens."

	icon = 'icons/obj/abductor.dmi'
	lefthand_file = 'icons/mob/inhands/antag/abductor_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/abductor_righthand.dmi'
	icon_state = "wonderprodStun"
	item_state = "wonderprod"
	worn_icon_state = "classic_baton"

	force = 7

	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BELT

	actions_types = list(/datum/action/item_action/toggle_mode)
	//The mob we are currently incapacitating.
	var/mob/current_target

	stun_time = 14 SECONDS

	preload_cell_type = /obj/item/stock_parts/cell/infinite //Any sufficiently advanced technology is indistinguishable from magic
	activate_sound = null
	can_remove_cell = FALSE

	var/mode = BATON_STUN

	var/sleep_time = 2 MINUTES
	var/time_to_cuff = 3 SECONDS

/obj/item/melee/baton/abductor/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/melee/baton/abductor/proc/toggle(mob/living/user=usr)
	if(!AbductorCheck(user))
		return
	mode = (mode+1)%BATON_MODES
	var/txt
	switch(mode)
		if(BATON_STUN)
			txt = "stunning"
		if(BATON_SLEEP)
			txt = "sleep inducement"
		if(BATON_CUFF)
			txt = "restraining"
		if(BATON_PROBE)
			txt = "probing"

	if(!turned_on)
		toggle_on(user)
	to_chat(usr, span_notice("You switch the baton to [txt] mode."))
	update_icon()

/obj/item/melee/baton/abductor/examine(mob/user)
	. = ..()
	if (!isabductor(user))
		return
	. += "The device emits active neuro-impulses capable of stunning up to a single target at a time."
	switch(mode)
		if(BATON_STUN)
			. += span_warning("The baton is in stun mode.")
		if(BATON_SLEEP)
			. += span_warning("The baton is in sleep inducement mode.")
		if(BATON_CUFF)
			. += span_warning("The baton is in restraining mode.")
		if(BATON_PROBE)
			. += span_warning("The baton is in probing mode.")

/obj/item/melee/baton/abductor/update_icon_state()
	. = ..()
	switch(mode)
		if(BATON_STUN)
			icon_state = "wonderprodStun"
			item_state = "wonderprodStun"
		if(BATON_SLEEP)
			icon_state = "wonderprodSleep"
			item_state = "wonderprodSleep"
		if(BATON_CUFF)
			icon_state = "wonderprodCuff"
			item_state = "wonderprodCuff"
		if(BATON_PROBE)
			icon_state = "wonderprodProbe"
			item_state = "wonderprodProbe"

/obj/item/melee/baton/abductor/attack(mob/target, mob/living/user)
	if(!AbductorCheck(user))
		return FALSE

	if(!deductcharge(cell_hit_cost))
		to_chat(user, "<span class='warning'>[src] [cell ? "is out of charge" : "does not have a power source installed"].</span>")
		return FALSE

	if(!turned_on)
		toggle_on(user)

	if(iscyborg(target))
		if(mode == BATON_STUN)
			..()
		return FALSE

	if(!isliving(target))
		return FALSE

	if(clumsy_check(user))
		return FALSE

	var/mob/living/L = target

	user.do_attack_animation(L)

	if(shields_blocked(L, user))
		return FALSE

	switch (mode)
		if(BATON_STUN)
			..()
		if(BATON_SLEEP)
			SleepAttack(L,user)
		if(BATON_CUFF)
			CuffAttack(L,user)
		if(BATON_PROBE)
			ProbeAttack(L,user)
	return

/obj/item/melee/baton/abductor/proc/StunAttack(mob/living/L)
	L.Paralyze(stun_time)

/obj/item/melee/baton/abductor/attack_self(mob/living/user)
	toggle(user)

/obj/item/melee/baton/abductor/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	turned_on = FALSE
	..()

/obj/item/melee/baton/abductor/proc/SleepAttack(mob/living/L,mob/living/user)
	playsound(src, stun_sound, 50, TRUE, -1)
	if(L.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		if(istype(L.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			to_chat(user, span_warning("The specimen's protective headgear is interfering with the sleep inducement!"))
			L.visible_message(span_danger("[user] tried to induced sleep in [L] with [src], but [L.p_their()] headgear protected [L.p_them()]!"), \
								span_userdanger("You feel a strange wave of heavy drowsiness wash over you, but your headgear deflects most of it!"))
			L.drowsyness += 2
			return
		L.visible_message(span_danger("[user] has induced sleep in [L] with [src]!"), \
							span_userdanger("You suddenly feel very drowsy!"))
		L.Sleeping(sleep_time)
		switch_target(L)
		log_combat(user, L, "put to sleep")
	else
		if(istype(L.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			to_chat(user, span_warning("The specimen's protective headgear is completely blocking our sleep inducement methods!"))
			L.visible_message(span_danger("[user] tried to induce sleep in [L] with [src], but [L.p_their()] headgear completely protected [L.p_them()]!"), \
								span_userdanger("Any sense of drowsiness is quickly diminished as your headgear deflects the effects!"))
			return
		L.drowsyness += 1
		to_chat(user, span_warning("Sleep inducement works fully only on stunned specimens! "))
		L.visible_message(span_danger("[user] tried to induce sleep in [L] with [src]!"), \
							span_userdanger("You suddenly feel drowsy!"))

/obj/item/melee/baton/abductor/proc/CuffAttack(mob/living/L,mob/living/user)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/C = L
	if(!C.handcuffed)
		if(C.canBeHandcuffed())
			playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
			C.visible_message(span_danger("[user] begins restraining [C] with [src]!"), \
									span_userdanger("[user] begins shaping an energy field around your hands!"))
			if(do_after(user, time_to_cuff, C) && C.canBeHandcuffed())
				if(!C.handcuffed)
					C.set_handcuffed(new /obj/item/restraints/handcuffs/energy/used(C))
					C.update_handcuffed()
					to_chat(user, span_notice("You restrain [C]."))
					log_combat(user, C, "handcuffed")
			else
				to_chat(user, span_warning("You fail to restrain [C]."))
		else
			to_chat(user, span_warning("[C] doesn't have two hands..."))

/obj/item/melee/baton/abductor/proc/ProbeAttack(mob/living/L,mob/living/user)
	L.visible_message(span_danger("[user] probes [L] with [src]!"), \
						span_userdanger("[user] probes you!"))

	var/species = span_warning("Unknown species")
	var/helptext = span_warning("Species unsuitable for experiments.")

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		species = span_notice("[H.dna.species.name]")
		if(L.mind && L.mind.has_antag_datum(/datum/antagonist/changeling))
			species = span_warning("Changeling lifeform")
		var/obj/item/organ/heart/gland/temp = locate() in H.internal_organs
		if(temp)
			helptext = span_warning("Experimental gland detected!")
		else
			if (L.getorganslot(ORGAN_SLOT_HEART))
				helptext = span_notice("Subject suitable for experiments.")
			else
				helptext = span_warning("Subject unsuitable for experiments.")

	to_chat(user, "[span_notice("Probing result:")][species]")
	to_chat(user, "[helptext]")

/// Switch a target, freeing our old target
/obj/item/melee/baton/abductor/proc/switch_target(mob/new_target)
	if (current_target == new_target)
		return
	if (current_target)
		//Free the target
		if (isliving(current_target))
			var/mob/living/L = current_target
			L.SetParalyzed(0)
			L.SetSleeping(0)
		//Unregister them
		unregister_target()
	current_target = new_target
	if (current_target)
		RegisterSignal(current_target, COMSIG_PARENT_QDELETING, PROC_REF(unregister_target))
		START_PROCESSING(SSprocessing, src)

/// Called when a target is deleted
/obj/item/melee/baton/abductor/proc/unregister_target()
	SIGNAL_HANDLER
	UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
	current_target = null
	STOP_PROCESSING(SSprocessing, src)

/obj/item/melee/baton/abductor/process(delta_time)
	if (!current_target)
		return PROCESS_KILL
	var/mob/living/L = current_target
	if (!istype(L))
		return
	//If our target is not paralysed or sleeping, they are already free
	if (!L.IsParalyzed() && !L.IsSleeping())
		unregister_target()

/obj/item/restraints/handcuffs/energy
	name = "hard-light energy field"
	desc = "A hard-light field restraining the hands."
	icon_state = "cuff" // Needs sprite
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	breakouttime = 45 SECONDS
	trashtype = /obj/item/restraints/handcuffs/energy/used
	flags_1 = NONE

/obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/used/dropped(mob/user)
	user.visible_message(span_danger("[user]'s [name] breaks in a discharge of energy!"), \
							span_userdanger("[user]'s [name] breaks in a discharge of energy!"))
	var/datum/effect_system/spark_spread/S = new
	S.set_up(4,0,user.loc)
	S.start()
	..()

/obj/item/radio/headset/abductor
	name = "alien headset"
	desc = "An advanced alien headset designed to monitor communications of human space stations. Why does it have a microphone? No one knows."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "abductor_headset"
	item_state = "abductor_headset"
	keyslot2 = new /obj/item/encryptionkey/heads/captain
	bang_protect = 1

/obj/item/radio/headset/abductor/Initialize(mapload)
	. = ..()
	make_syndie()

/obj/item/radio/headset/abductor/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		return // Stops humans from disassembling abductor headsets.
	return ..()

/obj/item/abductor_machine_beacon
	name = "machine beacon"
	desc = "A beacon designed to instantly tele-construct abductor machinery."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "beacon"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/spawned_machine

/obj/item/abductor_machine_beacon/attack_self(mob/user)
	..()
	user.visible_message(span_notice("[user] places down [src] and activates it."), span_notice("You place down [src] and activate it."))
	user.dropItemToGround(src)
	playsound(src, 'sound/machines/terminal_alert.ogg', 50)
	addtimer(CALLBACK(src, PROC_REF(try_spawn_machine)), 30)

/obj/item/abductor_machine_beacon/proc/try_spawn_machine()
	var/viable = FALSE
	if(isfloorturf(loc))
		var/turf/T = loc
		viable = TRUE
		for(var/obj/thing in T.contents)
			if(thing.density || ismachinery(thing) || isstructure(thing))
				viable = FALSE
	if(viable)
		playsound(src, 'sound/effects/phasein.ogg', 50, TRUE)
		var/new_machine = new spawned_machine(loc)
		visible_message(span_notice("[new_machine] warps on top of the beacon!"))
		qdel(src)
	else
		playsound(src, 'sound/machines/buzz-two.ogg', 50)

/obj/item/abductor_machine_beacon/chem_dispenser
	name = "beacon - Reagent Synthesizer"
	spawned_machine = /obj/machinery/chem_dispenser/abductor

/obj/item/scalpel/alien
	name = "alien scalpel"
	desc = "It's a gleaming sharp knife made out of silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.25

/obj/item/hemostat/alien
	name = "alien hemostat"
	desc = "You've never seen this before."
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.25

/obj/item/retractor/alien
	name = "alien retractor"
	desc = "You're not sure if you want the veil pulled back."
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.25

/obj/item/circular_saw/alien
	name = "alien saw"
	desc = "Do the aliens also lose this, and need to find an alien hatchet?"
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.25

/obj/item/surgicaldrill/alien
	name = "alien drill"
	desc = "Maybe alien surgeons have finally found a use for the drill."
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.25

/obj/item/cautery/alien
	name = "alien cautery"
	desc = "Why would bloodless aliens have a tool to stop bleeding? \
		Unless..."
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.25

/obj/item/clothing/head/helmet/abductor
	name = "agent headgear"
	desc = "Abduct with style - spiky style. Prevents digital tracking."
	icon_state = "alienhelmet"
	item_state = "alienhelmet"
	flash_protect = 1
	blockTracking = TRUE
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

// Operating Table / Beds / Lockers

/obj/structure/bed/abductor
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon = 'icons/obj/abductor.dmi'
	buildstacktype = /obj/item/stack/sheet/mineral/abductor
	icon_state = "bed"

/obj/structure/table_frame/abductor
	name = "alien table frame"
	desc = "A sturdy table frame made from alien alloy."
	icon_state = "alien_frame"
	framestack = /obj/item/stack/sheet/mineral/abductor
	framestackamount = 1

/obj/structure/table_frame/abductor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You start disassembling [src]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 30))
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			for(var/i in 1 to framestackamount)
				new framestack(get_turf(src))
			qdel(src)
			return
	if(istype(I, /obj/item/stack/sheet/mineral/abductor))
		var/obj/item/stack/sheet/P = I
		if(P.get_amount() < 1)
			to_chat(user, span_warning("You need one alien alloy sheet to do this!"))
			return
		to_chat(user, span_notice("You start adding [P] to [src]..."))
		if(do_after(user, 50, target = src))
			P.use(1)
			new /obj/structure/table/abductor(src.loc)
			qdel(src)
		return
	if(istype(I, /obj/item/stack/sheet/mineral/silver))
		var/obj/item/stack/sheet/P = I
		if(P.get_amount() < 1)
			to_chat(user, span_warning("You need one sheet of silver to do	this!"))
			return
		to_chat(user, span_notice("You start adding [P] to [src]..."))
		if(do_after(user, 50, target = src))
			P.use(1)
			new /obj/structure/table/optable/abductor(src.loc)
			qdel(src)

/obj/structure/table/abductor
	name = "alien table"
	desc = "Advanced flat surface technology at work!"
	icon = 'icons/obj/smooth_structures/tables/alien_table.dmi'
	icon_state = "alien_table-0"
	base_icon_state = "alien_table"
	buildstack = /obj/item/stack/sheet/mineral/abductor
	framestack = /obj/item/stack/sheet/mineral/abductor
	buildstackamount = 1
	framestackamount = 1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ABDUCTOR_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_ABDUCTOR_TABLES)
	frame = /obj/structure/table_frame/abductor

/obj/structure/table/optable/abductor
	name = "alien operating table"
	desc = "Used for alien medical procedures. The surface is covered in tiny spines."
	frame = /obj/structure/table_frame/abductor
	buildstack = /obj/item/stack/sheet/mineral/silver
	framestack = /obj/item/stack/sheet/mineral/abductor
	buildstackamount = 1
	framestackamount = 1
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"
	can_buckle = 1
	/// Amount to inject per second
	var/inject_am = 0.5

	var/static/list/injected_reagents = list(/datum/reagent/medicine/corazone)

/obj/structure/table/optable/abductor/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/optable/abductor/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(iscarbon(AM))
		START_PROCESSING(SSobj, src)
		to_chat(AM, span_danger("You feel a series of tiny pricks!"))

/obj/structure/table/optable/abductor/process(delta_time)
	. = PROCESS_KILL
	for(var/mob/living/carbon/C in get_turf(src))
		. = TRUE
		for(var/chemical in injected_reagents)
			if(C.reagents.get_reagent_amount(chemical) < inject_am * delta_time)
				C.reagents.add_reagent(chemical, inject_am * delta_time)

/obj/structure/table/optable/abductor/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Contains secrets of the universe."
	icon_state = "abductor"
	icon_door = "abductor"
	can_weld_shut = FALSE
	material_drop = /obj/item/stack/sheet/mineral/abductor
	door_anim_time = 0 // no animation

/obj/structure/door_assembly/door_assembly_abductor
	name = "alien airlock assembly"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	base_name = "alien airlock"
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/abductor
	material_type = /obj/item/stack/sheet/mineral/abductor
	noglass = TRUE

/obj/item/clothing/under/abductor
	desc = "The most advanced form of jumpsuit known to reality, looks uncomfortable."
	name = "alien jumpsuit"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "abductor"
	item_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	armor_type = /datum/armor/under_abductor
	can_adjust = FALSE

/datum/armor/under_abductor
	bomb = 10
	bio = 10

#undef VEST_STEALTH
#undef VEST_COMBAT
#undef GIZMO_SCAN
#undef GIZMO_MARK
#undef MIND_DEVICE_MESSAGE
#undef MIND_DEVICE_CONTROL
#undef BATON_STUN
#undef BATON_SLEEP
#undef BATON_CUFF
#undef BATON_PROBE
#undef BATON_MODES
