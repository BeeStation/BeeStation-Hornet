/obj/item/melee
	item_flags = NEEDS_PERMIT | ISWEAPON

/obj/item/melee/proc/check_martial_counter(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(target.check_block())
		target.visible_message("<span class='danger'>[target.name] blocks [src] and twists [user]'s arm behind [user.p_their()] back!</span>",
					"<span class='userdanger'>You block the attack!</span>")
		user.Stun(40)
		return TRUE


/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/chainhit.ogg'
	materials = list(/datum/material/iron = 1000)

/obj/item/melee/chainofcommand/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/melee/synthetic_arm_blade
	name = "synthetic arm blade"
	desc = "A grotesque blade that on closer inspection seems made of synthetic flesh, it still feels like it would hurt very badly as a weapon."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	force = 20
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	sharpness = IS_SHARP

/obj/item/melee/synthetic_arm_blade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 60, 80) //very imprecise

/obj/item/melee/sabre
	name = "officer's sabre"
	desc = "An elegant weapon, its monomolecular edge is capable of cutting through flesh and bone with ease."
	icon_state = "sabre"
	item_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 15
	block_level = 1
	block_upgrade_walk = 1
	block_power = 50
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 75
	sharpness = IS_SHARP
	attack_verb = list("slashed", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(/datum/material/iron = 1000)


/obj/item/melee/sabre/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 30, 95, 5) //fast and effective, but as a sword, it might damage the results.

/obj/item/melee/sabre/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/melee/sabre/on_exit_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/sabre/B = S.real_location()
	if(istype(B))
		playsound(B, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/sabre/B = S.real_location()
	if(istype(B))
		playsound(B, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/sabre/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is trying to cut off all [user.p_their()] limbs with [src]! it looks like [user.p_theyre()] trying to commit suicide!</span>")
	var/i = 0
	ADD_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)
	if(iscarbon(user))
		var/mob/living/carbon/Cuser = user
		var/obj/item/bodypart/holding_bodypart = Cuser.get_holding_bodypart_of_item(src)
		var/list/limbs_to_dismember
		var/list/arms = list()
		var/list/legs = list()
		var/obj/item/bodypart/bodypart

		for(bodypart in Cuser.bodyparts)
			if(bodypart == holding_bodypart)
				continue
			if(bodypart.body_part & ARMS)
				arms += bodypart
			else if (bodypart.body_part & LEGS)
				legs += bodypart

		limbs_to_dismember = arms + legs
		if(holding_bodypart)
			limbs_to_dismember += holding_bodypart

		var/speedbase = abs((4 SECONDS) / limbs_to_dismember.len)
		for(bodypart in limbs_to_dismember)
			i++
			addtimer(CALLBACK(src, PROC_REF(suicide_dismember), user, bodypart), speedbase * i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), (5 SECONDS) * i)
	return MANUAL_SUICIDE

/obj/item/melee/sabre/proc/suicide_dismember(mob/living/user, obj/item/bodypart/affecting)
	if(!QDELETED(affecting) && affecting.dismemberable && affecting.owner == user && !QDELETED(user))
		playsound(user, hitsound, 25, 1)
		affecting.dismember(BRUTE)
		user.adjustBruteLoss(20)

/obj/item/melee/sabre/proc/manual_suicide(mob/living/user, originally_nodropped)
	if(!QDELETED(user))
		user.adjustBruteLoss(200)
		user.death(FALSE)
	REMOVE_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)

/obj/item/melee/sabre/mime
	name = "Bread Blade"
	desc = "An elegant weapon, it has an inscription on it that says:  \"La Gluten Gutter\"."
	force = 18
	icon_state = "rapier"
	item_state = "rapier"
	lefthand_file = null
	righthand_file = null
	block_power = 60
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)

/obj/item/melee/sabre/mime/on_exit_storage(datum/component/storage/concrete/R)
	var/obj/item/storage/belt/sabre/mime/M = R.real_location()
	if(istype(M))
		playsound(M, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/component/storage/concrete/R)
	var/obj/item/storage/belt/sabre/mime/M = R.real_location()
	if(istype(M))
		playsound(M, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/classic_baton
	name = "classic baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL

	var/cooldown_check = 0 // Used interally, you don't want to modify

	var/cooldown = 20 // Default wait time until can stun again.
	var/stun_time_silicon = (5 SECONDS) // If enabled, how long do we stun silicons.
	var/stamina_damage = 55 // Do we deal stamina damage.
	var/affect_silicon = FALSE // Does it stun silicons.
	var/on_sound // "On" sound, played when switching between able to stun or not.
	var/on_stun_sound = "sound/effects/woodhit.ogg" // Default path to sound for when we stun.
	var/stun_animation = FALSE // Do we animate the "hit" when stunning.
	var/on = TRUE // Are we on or off

	var/on_icon_state // What is our sprite when turned on
	var/off_icon_state // What is our sprite when turned off
	var/on_item_state // What is our in-hand sprite when turned on
	var/force_on // Damage when on - not stunning
	var/force_off // Damage when off - not stunning
	var/weight_class_on // What is the new size class when turned on

// Description for trying to stun when still on cooldown.
/obj/item/melee/classic_baton/proc/get_wait_description()
	return

// Description for when turning their baton "on"
/obj/item/melee/classic_baton/proc/get_on_description()
	. = list()

	.["local_on"] = "<span class ='warning'>You extend the baton.</span>"
	.["local_off"] = "<span class ='notice'>You collapse the baton.</span>"

	return .

// Default message for stunning mob.
/obj/item/melee/classic_baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visibletrip"] =  "<span class ='danger'>[user] has knocked [target]'s legs out from under them with [src]!</span>"
	.["localtrip"] = "<span class ='danger'>[user] has knocked your legs out from under you [src]!</span>"
	.["visibledisarm"] =  "<span class ='danger'>[user] has disarmed [target] with [src]!</span>"
	.["localdisarm"] = "<span class ='danger'>[user] whacks your arm with [src], causing a coursing pain!</span>"
	.["visiblestun"] =  "<span class ='danger'>[user] beat [target] with [src]!</span>"
	.["localstun"] = "<span class ='danger'>[user] has beat you with [src]!</span>"

	return .

// Default message for stunning a silicon.
/obj/item/melee/classic_baton/proc/get_silicon_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = "<span class='danger'>[user] pulses [target]'s sensors with the baton!</span>"
	.["local"] = "<span class='danger'>You pulse [target]'s sensors with the baton!</span>"

	return .

// Are we applying any special effects when we stun to carbon
/obj/item/melee/classic_baton/proc/additional_effects_carbon(mob/living/target, mob/living/user)
	return

// Are we applying any special effects when we stun to silicon
/obj/item/melee/classic_baton/proc/additional_effects_silicon(mob/living/target, mob/living/user)
	return

//Police Baton
/obj/item/melee/classic_baton/police
	name = "police baton"

/obj/item/melee/classic_baton/police/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()
	var/def_check = target.getarmor(type = MELEE)

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='danger'>You hit yourself over the head.</span>")
		user.adjustStaminaLoss(stamina_damage)

		additional_effects_carbon(user) // user is the target here
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		// We don't stun if we're on harm.
		if (user.a_intent != INTENT_HARM)
			if (affect_silicon)
				var/list/desc = get_silicon_stun_description(target, user)

				target.flash_act(affect_silicon = TRUE)
				target.Paralyze(stun_time_silicon)
				additional_effects_silicon(target, user)

				user.visible_message(desc["visible"], desc["local"])
				playsound(get_turf(src), on_stun_sound, 100, TRUE, -1)

				if (stun_animation)
					user.do_attack_animation(target)
			else
				..()
		else
			..()
		return
	if(!isliving(target))
		return
	if (user.a_intent == INTENT_HARM)
		if(!..())
			return
		if(!iscyborg(target))
			return
	else
		if(cooldown_check <= world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					return

			var/list/desc = get_stun_description(target, user)

			if (stun_animation)
				user.do_attack_animation(target)
			playsound(get_turf(src), on_stun_sound, 75, 1, -1)
			additional_effects_carbon(target, user)
			if((user.zone_selected == BODY_ZONE_HEAD) || (user.zone_selected == BODY_ZONE_CHEST))
				target.apply_damage(stamina_damage, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblestun"], desc["localstun"])
			if((user.zone_selected == BODY_ZONE_R_LEG) || (user.zone_selected == BODY_ZONE_L_LEG))
				target.Knockdown(30)
				log_combat(user, target, "tripped", src)
				target.visible_message(desc["visibletrip"], desc["localtrip"])
			if(user.zone_selected == BODY_ZONE_L_ARM)
				target.apply_damage(50, STAMINA, BODY_ZONE_L_ARM, def_check)
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
			if(user.zone_selected == BODY_ZONE_R_ARM)
				target.apply_damage(50, STAMINA, BODY_ZONE_R_ARM, def_check)
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])

			add_fingerprint(user)

			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = WEAKREF(user)
			cooldown_check = world.time + cooldown
		else
			var/wait_desc = get_wait_description()
			if (wait_desc)
				to_chat(user, wait_desc)

/obj/item/melee/classic_baton/police/deputy
	name = "deputy baton"
	force = 12
	cooldown = 10
	stamina_damage = 20

//Telescopic Baton
/obj/item/melee/classic_baton/police/telescopic
	name = "telescopic baton"
	desc = "A compact and harmless personal defense weapon. Sturdy enough to knock the feet out from under attackers and robust enough to disarm with a quick strike to the hand"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "telebaton_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	stamina_damage = 0
	item_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 0
	on = FALSE
	on_sound = 'sound/weapons/batonextend.ogg'

	on_icon_state = "telebaton_1"
	off_icon_state = "telebaton_0"
	on_item_state = "nullrod"
	force_on = 0
	force_off = 0
	weight_class_on = WEIGHT_CLASS_BULKY

/obj/item/melee/classic_baton/telescopic/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(on)
		return ..()
	return 0

/obj/item/melee/classic_baton/telescopic/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)

	user.visible_message("<span class='suicide'>[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear [user.p_their()] mind.</span>")
	if(!on)
		src.attack_self(user)
	else
		playsound(src, on_sound, 50, 1)
		add_fingerprint(user)
	sleep(3)
	if (!QDELETED(H))
		if(!QDELETED(B))
			H.internal_organs -= B
			qdel(B)
		new /obj/effect/gibspawner/generic(H.drop_location(), H)
		return (BRUTELOSS)

/obj/item/melee/classic_baton/police/telescopic/attack_self(mob/user)
	on = !on
	var/list/desc = get_on_description()

	if(on)
		to_chat(user, desc["local_on"])
		icon_state = on_icon_state
		item_state = on_item_state
		w_class = weight_class_on
		force = force_on
		attack_verb = list("smacked", "struck", "cracked", "beaten")
	else
		to_chat(user, desc["local_off"])
		icon_state = off_icon_state
		item_state = null //no sprite for concealment even when in hand
		slot_flags = ITEM_SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = force_off
		attack_verb = list("hit", "poked")

	playsound(src.loc, on_sound, 50, 1)
	add_fingerprint(user)

//Contractor Baton
/obj/item/melee/classic_baton/retractible_stun
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "contractor_baton_0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	item_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 5
	on = FALSE
	var/knockdown_time_carbon = (1.5 SECONDS) // Knockdown length for carbons.
	var/stamina_damage_non_target = 55
	var/stamina_damage_target = 85
	var/target_confusion = 4 SECONDS

	stamina_damage = 85
	affect_silicon = TRUE
	on_sound = 'sound/weapons/contractorbatonextend.ogg'
	on_stun_sound = 'sound/effects/contractorbatonhit.ogg'
	stun_animation = TRUE

	on_icon_state = "contractor_baton_1"
	off_icon_state = "contractor_baton_0"
	on_item_state = "contractor_baton"
	force_on = 10
	force_off = 5
	weight_class_on = WEIGHT_CLASS_NORMAL

/obj/item/melee/classic_baton/retractible_stun/get_wait_description()
	return "<span class='danger'>The baton is still charging!</span>"

/obj/item/melee/classic_baton/retractible_stun/additional_effects_carbon(mob/living/target, mob/living/user)
	target.Jitter(2 SECONDS)
	target.stuttering += 2 SECONDS

/obj/item/melee/classic_baton/retractible_stun/attack_self(mob/user)
	on = !on
	var/list/desc = get_on_description()

	if(on)
		to_chat(user, desc["local_on"])
		icon_state = on_icon_state
		item_state = on_item_state
		w_class = weight_class_on
		force = force_on
		attack_verb = list("smacked", "struck", "cracked", "beaten")
	else
		to_chat(user, desc["local_off"])
		icon_state = off_icon_state
		item_state = null //no sprite for concealment even when in hand
		slot_flags = ITEM_SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = force_off
		attack_verb = list("hit", "poked")

	playsound(src.loc, on_sound, 50, TRUE)
	add_fingerprint(user)

/obj/item/melee/classic_baton/retractible_stun/proc/is_target(mob/living/target, mob/living/user)
	return TRUE

/obj/item/melee/classic_baton/retractible_stun/proc/check_disabled(mob/living/target, mob/living/user)
	return FALSE

/obj/item/melee/classic_baton/retractible_stun/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()

	if(check_disabled(target, user))
		return ..()

	var/is_target = is_target(target, user)

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='danger'>You hit yourself over the head.</span>")

		user.Paralyze(knockdown_time_carbon * force)
		user.adjustStaminaLoss(stamina_damage)

		additional_effects_carbon(user) // user is the target here
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		// We don't stun if we're on harm.
		if (user.a_intent != INTENT_HARM)
			if (affect_silicon)
				var/list/desc = get_silicon_stun_description(target, user)

				target.flash_act(affect_silicon = TRUE)
				target.Paralyze(stun_time_silicon)
				additional_effects_silicon(target, user)

				user.visible_message(desc["visible"], desc["local"])
				playsound(get_turf(src), on_stun_sound, 100, TRUE, -1)

				if (stun_animation)
					user.do_attack_animation(target)
			else
				..()
		else
			..()
		return
	if(!isliving(target))
		return
	if (user.a_intent == INTENT_HARM)
		if(!..())
			return
		if(!iscyborg(target))
			return
	else
		if(cooldown_check <= world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					return

			var/list/desc = get_stun_description(target, user)

			if (stun_animation)
				user.do_attack_animation(target)

			playsound(get_turf(src), on_stun_sound, 75, TRUE, -1)
			if(is_target)
				target.Knockdown(knockdown_time_carbon)
				target.drop_all_held_items()
				target.adjustStaminaLoss(stamina_damage)
				if(target_confusion > 0 && target.confused < 6 SECONDS)
					target.confused = min(target.confused + target_confusion, 6 SECONDS)
			else
				target.Knockdown(knockdown_time_carbon)
				target.adjustStaminaLoss(stamina_damage_non_target)
			additional_effects_carbon(target, user)

			log_combat(user, target, "stunned", src)
			add_fingerprint(user)

			target.visible_message(desc["visible"], desc["local"])

			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = user
			cooldown_check = world.time + cooldown
		else
			var/wait_desc = get_wait_description()
			if (wait_desc)
				to_chat(user, wait_desc)

/obj/item/melee/classic_baton/retractible_stun/contractor_baton
	name = "contractor baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electric shocks that can resonate with a specific target's brain frequency causing significant stunning effects."
	var/datum/antagonist/traitor/owner_data = null

/obj/item/melee/classic_baton/retractible_stun/contractor_baton/check_disabled(mob/living/target, mob/living/user)
	return !owner_data || owner_data?.owner?.current != user

/obj/item/melee/classic_baton/retractible_stun/contractor_baton/is_target(mob/living/target, mob/living/user)
	return owner_data.contractor_hub?.current_contract?.contract?.target == target.mind

/obj/item/melee/classic_baton/retractible_stun/contractor_baton/pickup(mob/user)
	..()
	if(!owner_data)
		var/datum/antagonist/traitor/traitor_data = user.mind.has_antag_datum(/datum/antagonist/traitor)
		if(traitor_data)
			owner_data = traitor_data
			to_chat(user, "<span class='notice'>[src] scans your genetic data as you pick it up, creating an uplink with the syndicate database. Attacking your current target will stun them, however the baton is weak against non-targets.</span>")

/obj/item/melee/classic_baton/retractible_stun/bounty
	name = "bounty hunter baton"
	desc = "A compact, specialised retractible stun baton assigned to bounty hunters."
	knockdown_time_carbon = (2 SECONDS)
	stamina_damage_non_target = 60
	stamina_damage_target = 60
	stamina_damage = 60
	target_confusion = 0

// Supermatter Sword
/obj/item/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "supermatter_sword"
	item_state = "supermatter_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	var/obj/machinery/power/supermatter_crystal/shard
	var/balanced = 1
	block_level = 1
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	force_string = "INFINITE"

/obj/item/melee/supermatter_sword/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	qdel(hitby)
	owner.visible_message("<span class='danger'>[hitby] evaporates in midair!</span>")
	return TRUE

/obj/item/melee/supermatter_sword/Initialize(mapload)
	. = ..()
	shard = new /obj/machinery/power/supermatter_crystal(src)
	qdel(shard.countdown)
	shard.countdown = null
	START_PROCESSING(SSobj, src)
	visible_message("<span class='warning'>[src] appears, balanced ever so perfectly on its hilt. This isn't ominous at all.</span>")

/obj/item/melee/supermatter_sword/process()
	if(balanced || throwing || ismob(src.loc) || isnull(src.loc))
		return
	if(!isturf(src.loc))
		var/atom/target = src.loc
		forceMove(target.loc)
		consume_everything(target)
	else
		var/turf/T = get_turf(src)
		if(!isspaceturf(T))
			consume_turf(T)

/obj/item/melee/supermatter_sword/afterattack(target, mob/user, proximity_flag)
	. = ..()
	if(user && target == user)
		user.dropItemToGround(src)
	if(proximity_flag)
		consume_everything(target)

/obj/item/melee/supermatter_sword/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(ismob(hit_atom))
		var/mob/M = hit_atom
		if(src.loc == M)
			M.dropItemToGround(src)
	consume_everything(hit_atom)

/obj/item/melee/supermatter_sword/pickup(user)
	..()
	balanced = 0

/obj/item/melee/supermatter_sword/ex_act(severity, target)
	visible_message("<span class='danger'>The blast wave smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/melee/supermatter_sword/acid_act()
	visible_message("<span class='danger'>The acid smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/melee/supermatter_sword/bullet_act(obj/projectile/P)
	visible_message("<span class='danger'>[P] smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything(P)
	return BULLET_ACT_HIT

/obj/item/melee/supermatter_sword/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] touches [src]'s blade. It looks like [user.p_theyre()] tired of waiting for the radiation to kill [user.p_them()]!</span>")
	user.dropItemToGround(src, TRUE)
	shard.Bumped(user)

/obj/item/melee/supermatter_sword/proc/consume_everything(target)
	if(isnull(target))
		shard.Consume()
	else if(!isturf(target))
		shard.Bumped(target)
	else
		consume_turf(target)

/obj/item/melee/supermatter_sword/proc/consume_turf(turf/T)
	var/oldtype = T.type
	var/turf/newT = T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	if(newT.type == oldtype)
		return
	playsound(T, 'sound/effects/supermatter.ogg', 50, 1)
	T.visible_message("<span class='danger'>[T] smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	shard.Consume()
	CALCULATE_ADJACENT_TURFS(T)

/obj/item/melee/supermatter_sword/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/curator_whip
	name = "curator's whip"
	desc = "Somewhat eccentric and outdated, it still stings like hell to be hit by."
	icon_state = "whip"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 0.001 //"Some attack noises shit"
	reach = 3
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/melee/curator_whip/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!ishuman(target))
		return

	switch(user.zone_selected)
		if(BODY_ZONE_L_ARM)
			whip_disarm(user, target, "left")
		if(BODY_ZONE_R_ARM)
			whip_disarm(user, target, "right")
		if(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
			whip_trip(user, target)
		else
			whip_lash(user, target)

/obj/item/melee/curator_whip/proc/whip_disarm(mob/living/carbon/user, mob/living/target, side)
	var/obj/item/I = target.get_held_items_for_side(side)
	if(I)
		if(target.dropItemToGround(I))
			target.visible_message("<span class='danger'>[I] is yanked out of [target]'s hands by [src]!</span>","<span class='userdanger'>[user] grabs [I] out of your hands with [src]!</span>")
			to_chat(user, "<span class='notice'>You yank [I] towards yourself.</span>")
			log_combat(user, target, "disarmed", src)
			if(!user.get_inactive_held_item())
				user.throw_mode_on(THROW_MODE_TOGGLE)
				user.swap_hand()
				I.throw_at(user, 10, 2)

/obj/item/melee/curator_whip/proc/whip_trip(mob/living/user, mob/living/target) //this is bad and ugly but not as bad and ugly as the original code
	if(get_dist(user, target) < 2)
		to_chat(user, "<span class='warning'>[target] is too close to trip with the whip!</span>")
		return
	target.Knockdown(3 SECONDS)
	log_combat(user, target, "tripped", src)
	target.visible_message("<span class='danger'>[user] knocks [target] off [target.p_their()] feet!</span>", "<span class='userdanger'>[user] yanks your legs out from under you!</span>")

/obj/item/melee/curator_whip/proc/whip_lash(mob/living/user, mob/living/target)
	if(target.getarmor(type = MELEE) < 16)
		target.emote("scream")
		target.visible_message("<span class='danger'>[user] whips [target]!</span>", "<span class='userdanger'>[user] whips you! It stings!</span>")

/obj/item/melee/roastingstick
	name = "advanced roasting stick"
	desc = "A telescopic roasting stick with a miniature shield generator designed to ensure entry into various high-tech shielded cooking ovens and firepits."
	icon_state = "roastingstick_0"
	item_state = "null"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 0
	attack_verb = list("hit", "poked")
	var/obj/item/reagent_containers/food/snacks/sausage/held_sausage
	var/static/list/ovens
	var/on = FALSE
	var/datum/beam/beam

/obj/item/melee/roastingstick/Initialize(mapload)
	. = ..()
	if(!ovens)
		ovens = typecacheof(list(/obj/anomaly, /obj/machinery/power/supermatter_crystal, /obj/structure/bonfire))

/obj/item/melee/roastingstick/attack_self(mob/user)
	on = !on
	if(on)
		extend(user)
	else
		if (held_sausage)
			to_chat(user, "<span class='warning'>You can't retract [src] while [held_sausage] is attached!</span>")
			return
		retract(user)

	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)

/obj/item/melee/roastingstick/attackby(atom/target, mob/user)
	..()
	if (istype(target, /obj/item/reagent_containers/food/snacks/sausage))
		if (!on)
			to_chat(user, "<span class='warning'>You must extend [src] to attach anything to it!</span>")
			return
		if (held_sausage)
			to_chat(user, "<span class='warning'>[held_sausage] is already attached to [src]!</span>")
			return
		if (user.transferItemToLoc(target, src))
			held_sausage = target
		else
			to_chat(user, "<span class='warning'>[target] doesn't seem to want to get on [src]!</span>")
	update_icon()

/obj/item/melee/roastingstick/attack_hand(mob/user)
	..()
	if (held_sausage)
		user.put_in_hands(held_sausage)
		held_sausage = null
	update_icon()

/obj/item/melee/roastingstick/update_icon()
	. = ..()
	cut_overlays()
	if (held_sausage)
		var/mutable_appearance/sausage = mutable_appearance(icon, "roastingstick_sausage")
		add_overlay(sausage)

/obj/item/melee/roastingstick/proc/extend(user)
	to_chat(user, "<span class='warning'>You extend [src].</span>")
	icon_state = "roastingstick_1"
	item_state = "nullrod"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/melee/roastingstick/proc/retract(user)
	to_chat(user, "<span class='notice'>You collapse [src].</span>")
	icon_state = "roastingstick_0"
	item_state = null
	w_class = WEIGHT_CLASS_SMALL

/obj/item/melee/roastingstick/handle_atom_del(atom/target)
	if (target == held_sausage)
		held_sausage = null
		update_icon()

/obj/item/melee/roastingstick/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!on)
		return
	if(is_type_in_typecache(target, ovens))
		if(held_sausage && held_sausage.roasted)
			to_chat("Your [held_sausage] has already been cooked.")
			return
		if(istype(target, /obj/anomaly) && get_dist(user, target) < 10)
			to_chat(user, "You send [held_sausage] towards [target].")
			playsound(src, 'sound/items/rped.ogg', 50, 1)
			beam = user.Beam(target,icon_state="rped_upgrade", time = 10 SECONDS)
		else if (user.Adjacent(target))
			to_chat(user, "You extend [src] towards [target].")
			playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
		else
			return
		if(do_after(user, 100, target = user))
			finish_roasting(user, target)
		else
			QDEL_NULL(beam)
			playsound(src, 'sound/weapons/batonextend.ogg', 50, 1)

/obj/item/melee/roastingstick/proc/finish_roasting(user, atom/target)
	to_chat(user, "You finish roasting [held_sausage]")
	playsound(src,'sound/items/welder2.ogg',50,1)
	held_sausage.add_atom_colour(rgb(103,63,24), FIXED_COLOUR_PRIORITY)
	held_sausage.name = "[target.name]-roasted [held_sausage.name]"
	held_sausage.desc = "[held_sausage.desc] It has been cooked to perfection on \a [target]."
	update_icon()

/obj/item/melee/knockback_stick
	name = "Knockback Stick"
	desc = "An portable anti-gravity generator which knocks people back upon contact."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "telebaton_1"
	item_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("repelled")
	var/cooldown = 0
	var/knockbackpower = 6

/obj/item/melee/knockback_stick/attack(mob/living/target, mob/living/user)
	add_fingerprint(user)

	if(cooldown <= world.time)
		playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
		log_combat(user, target, "knockedbacked", src)
		target.visible_message("<span class ='danger'>[user] has knocked back [target] with [src]!</span>", \
			"<span class ='userdanger'>[user] has knocked you back [target] with [src]!</span>")

		var/throw_dir = get_dir(user,target)
		var/turf/throw_at = get_ranged_target_turf(target, throw_dir, knockbackpower)
		target.throw_at(throw_at, throw_range, 3)

		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user

		cooldown = world.time + 15
