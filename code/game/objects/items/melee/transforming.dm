/obj/item/melee/transforming
	sharpness = SHARP_DISMEMBER
	bleed_force = 0
	var/active = FALSE
	var/force_on = 30 //force when active
	var/faction_bonus_force = 0 //Bonus force dealt against certain factions
	var/throwforce_on = 20
	var/bleed_force_on = BLEED_CUT
	var/icon_state_on = "axe1"
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	var/list/attack_verb_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	var/list/attack_verb_off = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	w_class = WEIGHT_CLASS_SMALL
	var/bonus_active = FALSE //If the faction damage bonus is active
	var/list/nemesis_factions //Any mob with a faction that exists in this list will take bonus damage/effects
	var/w_class_on = WEIGHT_CLASS_BULKY
	var/clumsy_check = TRUE

/obj/item/melee/transforming/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	if(active)
		return ..()
	return 0


/obj/item/melee/transforming/Initialize(mapload)
	. = ..()
	if(active)
		if(attack_verb_on.len)
			attack_verb_continuous = attack_verb_on
	else
		if(attack_verb_off.len)
			attack_verb_continuous = attack_verb_off
		if(embedding)
			updateEmbedding()
	if(sharpness)
		AddComponent(/datum/component/butchering, 50, 100, 0, hitsound)

/obj/item/melee/transforming/attack_self(mob/living/carbon/user)
	if(transform_weapon(user))
		clumsy_transform_effect(user)

/obj/item/melee/transforming/attack(mob/living/target, mob/living/carbon/human/user)
	var/nemesis_faction = FALSE
	if(LAZYLEN(nemesis_factions))
		for(var/F in target.faction)
			if(F in nemesis_factions)
				nemesis_faction = TRUE
				force += faction_bonus_force
				nemesis_effects(user, target)
				break
	. = ..()
	if(nemesis_faction)
		force -= faction_bonus_force

/obj/item/melee/transforming/proc/transform_weapon(mob/living/user, supress_message_text)
	active = !active
	if(active)
		force = force_on
		throwforce = throwforce_on
		hitsound = hitsound_on
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb_continuous = attack_verb_on
		icon_state = icon_state_on
		w_class = w_class_on
		bleed_force = bleed_force_on
		if(embedding)
			updateEmbedding()
	else
		force = initial(force)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_off.len)
			attack_verb_continuous = attack_verb_off
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		bleed_force = initial(bleed_force)
		if(embedding)
			disableEmbedding()
	transform_messages(user, supress_message_text)
	add_fingerprint(user)
	return TRUE

/obj/item/melee/transforming/proc/nemesis_effects(mob/living/user, mob/living/target)
	return

/obj/item/melee/transforming/proc/transform_messages(mob/living/user, supress_message_text)
	playsound(user, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
	if(!supress_message_text)
		balloon_alert(user, "[src] [active ? "is now active" : "can now be concealed"].")

/obj/item/melee/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("You accidentally cut yourself with [src], like a doofus!"))
		user.take_bodypart_damage(5,5)
