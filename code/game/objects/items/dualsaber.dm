/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/dualsaber
	icon = 'icons/obj/transforming_energy.dmi'
	icon_state = "dualsaber0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	hitsound = "swing_hit"
	armour_penetration = 35
	var/saber_color = "green"
	light_color = "#00ff00"//green
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_level = 2
	block_upgrade_walk = 1
	block_power = 70
	block_sound = 'sound/weapons/egloves.ogg'
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_power = 1
	light_on = FALSE
	var/twohand_force = 34
	var/hacked = FALSE
	var/list/possible_colors = list("red", "blue", "green", "purple")

/obj/item/dualsaber/Initialize(mapload)
	if(LAZYLEN(possible_colors))
		saber_color = pick(possible_colors)
		switch(saber_color)
			if("red")
				set_light_color(LIGHT_COLOR_RED)
			if("green")
				set_light_color(LIGHT_COLOR_GREEN)
			if("blue")
				set_light_color(LIGHT_COLOR_CYAN)
			if("purple")
				set_light_color(LIGHT_COLOR_LAVENDER)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))

/obj/item/dualsaber/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/dualsaber/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=force, force_wielded=twohand_force, block_power_unwielded=70, block_power_wielded=75, \
					wieldsound='sound/weapons/saberon.ogg', unwieldsound='sound/weapons/saberoff.ogg', icon_wielded="dualsaber[saber_color]1")

/// Triggered on wield of two handed item
/// Specific hulk checks due to reflection chance for balance issues and switches hitsounds.
/obj/item/dualsaber/proc/on_wield(obj/item/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	if(user && user.has_dna())
		if(user.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>You lack the grace to wield this!</span>")
			return COMPONENT_TWOHANDED_BLOCK_WIELD
	sharpness = IS_SHARP
	w_class = w_class_on
	hitsound = 'sound/weapons/blade1.ogg'
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)

/// Triggered on unwield of two handed item
/// switch hitsounds
/obj/item/dualsaber/proc/on_unwield(obj/item/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	sharpness = initial(sharpness)
	w_class = initial(w_class)
	hitsound = "swing_hit"
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE)

/obj/item/dualsaber/update_icon()
	icon_state = "dualsaber0"
	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	..()

/obj/item/dualsaber/suicide_act(mob/living/carbon/user)
	if(ISWIELDED(src))
		user.visible_message("<span class='suicide'>[user] begins spinning way too fast! It looks like [user.p_theyre()] trying to commit suicide!</span>")

		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)//stole from chainsaw code
		var/obj/item/organ/brain/B = user.getorganslot(ORGAN_SLOT_BRAIN)
		B.organ_flags &= ~ORGAN_VITAL	//this cant possibly be a good idea
		var/randdir
		for(var/i in 1 to 24)//like a headless chicken!
			if(user.is_holding(src))
				randdir = pick(GLOB.alldirs)
				user.Move(get_step(user, randdir),randdir)
				user.emote("spin")
				if (i == 3 && myhead)
					myhead.drop_limb()
				sleep(3)
			else
				user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
				return OXYLOSS

	else
		user.visible_message("<span class='suicide'>[user] begins beating [user.p_them()]self to death with \the [src]'s handle! It probably would've been cooler if [user.p_they()] turned it on first!</span>")
	return BRUTELOSS

/obj/item/dualsaber/attack(mob/target, mob/living/carbon/user)
	var/wielded = ISWIELDED(src)
	if(user.has_dna())
		if(user.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>You grip the blade too hard and accidentally drop it!</span>")
			if(wielded)
				user.dropItemToGround(src, force=TRUE)
				return
	..()
	if(wielded && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
		impale(user)
		return
	if(wielded && prob(50))
		INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

/obj/item/dualsaber/proc/jedi_spin(mob/living/user) //rip complex code, but this fucked up blocking
	user.emote("flip")

/obj/item/dualsaber/proc/impale(mob/living/user)
	to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on [src].</span>")
	if(ISWIELDED(src))
		user.take_bodypart_damage(20,25,check_armor = TRUE)
	else
		user.adjustStaminaLoss(25)

/obj/item/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(ISWIELDED(src))
		return ..()
	return 0

/obj/item/dualsaber/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(ISWIELDED(src))
		to_chat(user, "<span class='warning'>You can't pick up such dangerous item with your meaty hands without losing fingers, better not to!</span>")
		return 1

/obj/item/dualsaber/process()
	if(ISWIELDED(src))
		if(hacked)
			light_color = pick(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER)
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/dualsaber/IsReflect()
	if(ISWIELDED(src))
		return 1

/obj/item/dualsaber/ignition_effect(atom/A, mob/user)
	// same as /obj/item/melee/transforming/energy, mostly
	if(!ISWIELDED(src))
		return ""
	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [user.p_their()] nose"
	. = "<span class='warning'>[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), TRUE, -1)
	add_fingerprint(user)
	// Light your candles while spinning around the room
	INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

/obj/item/dualsaber/green
	possible_colors = list("green")

/obj/item/dualsaber/red
	possible_colors = list("red")

/obj/item/dualsaber/blue
	possible_colors = list("blue")

/obj/item/dualsaber/purple
	possible_colors = list("purple")

/obj/item/dualsaber/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			to_chat(user, "<span class='warning'>2XRNBW_ENGAGE</span>")
			saber_color = "rainbow"
			AddComponent(/datum/component/two_handed, icon_wielded="dualsaber[saber_color]1")
			update_icon()
		else
			to_chat(user, "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()
