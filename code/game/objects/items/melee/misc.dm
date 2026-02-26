/obj/item/melee
	item_flags = NEEDS_PERMIT | ISWEAPON

/obj/item/melee/proc/check_martial_counter(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(target.check_block())
		target.visible_message(span_danger("[target.name] blocks [src] and twists [user]'s arm behind [user.p_their()] back!"),
					span_userdanger("You block the attack!"))
		user.Stun(40)
		return TRUE


/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	inhand_icon_state = "chain"
	worn_icon_state = "whip"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/weapons/chainhit.ogg'
	custom_materials = list(/datum/material/iron = 1000)

/obj/item/melee/chainofcommand/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/melee/synthetic_arm_blade
	name = "synthetic arm blade"
	desc = "A grotesque blade that on closer inspection seems made of synthetic flesh, it still feels like it would hurt very badly as a weapon."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	force = 20
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT

/obj/item/melee/synthetic_arm_blade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 60, 80) //very imprecise

/obj/item/melee/sabre
	name = "officer's sabre"
	desc = "An elegant weapon, its monomolecular edge is capable of cutting through flesh and bone with ease."
	icon_state = "sabre"
	inhand_icon_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 15
	canblock = TRUE

	block_power = 50
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 75
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = 1000)


/obj/item/melee/sabre/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 30, 95, 5) //fast and effective, but as a sword, it might damage the results.

/obj/item/melee/sabre/on_exit_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/sabre/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to cut off all [user.p_their()] limbs with [src]! it looks like [user.p_theyre()] trying to commit suicide!"))
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
	if(!QDELETED(affecting) && !(affecting.bodypart_flags & BODYPART_UNREMOVABLE) && affecting.owner == user && !QDELETED(user))
		playsound(user, hitsound, 25, 1)
		affecting.dismember(BRUTE)
		user.adjustBruteLoss(20)

/obj/item/melee/sabre/proc/manual_suicide(mob/living/user, originally_nodropped)
	if(!QDELETED(user))
		user.adjustBruteLoss(200)
		user.death(FALSE)
	REMOVE_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)

/obj/item/melee/sabre/carbon_fiber
	name = "carbon fiber sabre"
	desc = "A sabre made of a sleek carbon fiber polymer with a reinforced blade."
	icon_state = "sabre_fiber"
	inhand_icon_state = "sabre_fiber"
	force = 15
	armour_penetration = 25
	sharpness = SHARP //No dismembering for security sabre without direct intent

/obj/item/melee/sabre/mime
	name = "Bread Blade"
	desc = "An elegant weapon, it has an inscription on it that says:  \"La Gluten Gutter\"."
	force = 25
	icon_state = "rapier"
	inhand_icon_state = "rapier"
	lefthand_file = null
	righthand_file = null
	block_power = 75
	armor_type = /datum/armor/sabre_mime

/datum/armor/sabre_mime
	fire = 100
	acid = 100

/obj/item/melee/sabre/mime/on_exit_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/mime/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/mime/sabre = container.real_location?.resolve()
	if(istype(sabre))
		playsound(sabre, 'sound/items/sheath.ogg', 25, TRUE)

// Supermatter Sword
/obj/item/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "supermatter_sword"
	inhand_icon_state = "supermatter_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	force_string = "INFINITE"
	item_flags = NEEDS_PERMIT|NO_BLOOD_ON_ITEM
	var/obj/machinery/power/supermatter_crystal/shard
	var/balanced = 1
	canblock = TRUE

	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE

/obj/item/melee/supermatter_sword/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	qdel(hitby)
	owner.visible_message(span_danger("[hitby] evaporates in midair!"))
	return TRUE

/obj/item/melee/supermatter_sword/Initialize(mapload)
	. = ..()
	shard = new /obj/machinery/power/supermatter_crystal(src)
	qdel(shard.countdown)
	shard.countdown = null
	START_PROCESSING(SSobj, src)
	visible_message(span_warning("[src] appears, balanced ever so perfectly on its hilt. This isn't ominous at all."))

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
	visible_message(span_danger("The blast wave smacks into [src] and rapidly flashes to ash."),\
	span_italics("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything()

/obj/item/melee/supermatter_sword/acid_act()
	visible_message(span_danger("The acid smacks into [src] and rapidly flashes to ash."),\
	span_italics("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything()

/obj/item/melee/supermatter_sword/bullet_act(obj/projectile/P)
	visible_message(span_danger("[P] smacks into [src] and rapidly flashes to ash."),\
	span_italics("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything(P)
	return BULLET_ACT_HIT

/obj/item/melee/supermatter_sword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] touches [src]'s blade. It looks like [user.p_theyre()] tired of waiting for the radiation to kill [user.p_them()]!"))
	user.dropItemToGround(src, TRUE)
	shard.Bumped(user)

/obj/item/melee/supermatter_sword/proc/consume_everything(target)
	if(isnull(target))
		shard.Bump(target)
	else if(!isturf(target))
		shard.Bumped(target)
	else
		consume_turf(target)

/obj/item/melee/supermatter_sword/proc/consume_turf(turf/turf)
	var/oldtype = turf.type
	var/turf/new_turf = turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	if(new_turf.type == oldtype)
		return

	playsound(turf, 'sound/effects/supermatter.ogg', 50, TRUE)
	turf.visible_message(
		span_danger("[turf] smacks into [src] and rapidly flashes to ash."),
		span_hear("You hear a loud crack as you are washed with a wave of heat."),
	)
	shard.Bump(turf)
	CALCULATE_ADJACENT_TURFS(turf, MAKE_ACTIVE)

/obj/item/melee/supermatter_sword/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/curator_whip
	name = "curator's whip"
	desc = "Somewhat eccentric and outdated, it still stings like hell to be hit by."
	icon_state = "whip"
	inhand_icon_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	worn_icon_state = "whip"
	slot_flags = ITEM_SLOT_BELT
	force = 0.001 //"Some attack noises shit"
	reach = 3
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/melee/curator_whip/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!ishuman(target))
		return

	switch(user.get_combat_bodyzone(target))
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
			target.visible_message(span_danger("[I] is yanked out of [target]'s hands by [src]!"),span_userdanger("[user] grabs [I] out of your hands with [src]!"))
			to_chat(user, span_notice("You yank [I] towards yourself."))
			log_combat(user, target, "disarmed", src)
			if(!user.get_inactive_held_item())
				user.throw_mode_on(THROW_MODE_TOGGLE)
				user.swap_hand()
				I.throw_at(user, 10, 2)

/obj/item/melee/curator_whip/proc/whip_trip(mob/living/user, mob/living/target) //this is bad and ugly but not as bad and ugly as the original code
	if(get_dist(user, target) < 2)
		to_chat(user, span_warning("[target] is too close to trip with the whip!"))
		return
	target.Knockdown(3 SECONDS)
	log_combat(user, target, "tripped", src)
	target.visible_message(span_danger("[user] knocks [target] off [target.p_their()] feet!"), span_userdanger("[user] yanks your legs out from under you!"))

/obj/item/melee/curator_whip/proc/whip_lash(mob/living/user, mob/living/target)
	if(target.getarmor(type = MELEE, penetration = armour_penetration) < 16)
		target.emote("scream")
		target.visible_message(span_danger("[user] whips [target]!"), span_userdanger("[user] whips you! It stings!"))

/obj/item/melee/roastingstick
	name = "advanced roasting stick"
	desc = "A telescopic roasting stick with a miniature shield generator designed to ensure entry into various high-tech shielded cooking ovens and firepits."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "roastingstick_0"
	inhand_icon_state = null
	worn_icon_state = "tele_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 0
	attack_verb_continuous = list("hits", "pokes")
	attack_verb_simple = list("hit", "poke")
	/// The sausage attatched to our stick.
	var/obj/item/food/sausage/held_sausage
	/// Static list of things our roasting stick can interact with.
	var/static/list/ovens
	/// The beam that links to the oven we use
	var/datum/beam/beam

/obj/item/melee/roastingstick/Initialize(mapload)
	. = ..()
	if(!ovens)
		ovens = typecacheof(list(
			/obj/anomaly,
			/obj/machinery/power/supermatter_crystal,
			/obj/structure/bonfire,
		))
	AddComponent( \
		/datum/component/transforming, \
		hitsound_on = hitsound, \
		clumsy_check = FALSE, \
		inhand_icon_change = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_PRE_TRANSFORM, PROC_REF(attempt_transform))
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_PRE_TRANSFORM].
 *
 * If there is a sausage attached, returns COMPONENT_BLOCK_TRANSFORM.
 */
/obj/item/melee/roastingstick/proc/attempt_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(held_sausage)
		to_chat(user, span_warning("You can't retract [src] while [held_sausage] is attached!"))
		return COMPONENT_BLOCK_TRANSFORM

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback on stick extension.
 */
/obj/item/melee/roastingstick/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	icon_state = active ? "roastingstick_1" : "roastingstick_0"
	inhand_icon_state = active ? "nullrod" : null
	if(user)
		balloon_alert(user, "[active ? "extended" : "collapsed"] [src]")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/roastingstick/attackby(atom/target, mob/user)
	..()
	if (istype(target, /obj/item/food/meat) || istype(target, /obj/item/food/sausage))
		var/obj/item/food/target_sausage = target
		if ( !( target_sausage.foodtypes & RAW ) &&  !( target_sausage.foodtypes & FRIED ) ) // ONLY COOKED MEATS, NO RAW, NO FRIED.
			if (!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
				to_chat(user, span_warning("You must extend [src] to attach anything to it!"))
				return
			if (held_sausage)
				to_chat(user, span_warning("[held_sausage] is already attached to [src]!"))
				return
			if (user.transferItemToLoc(target, src))
				held_sausage = target
			else
				to_chat(user, span_warning("[target] doesn't seem to want to get on [src]!"))
		else
			to_chat(user, span_warning("[target] can't be roasted using [src]! Pre-cook the meat!"))
	else
		to_chat(user, span_warning("[target] can't be roasted using [src]!"))
	update_appearance()

/obj/item/melee/roastingstick/attack_hand(mob/user, list/modifiers)
	..()
	if (held_sausage)
		user.put_in_hands(held_sausage)

/obj/item/melee/roastingstick/update_overlays()
	. = ..()
	if(held_sausage)
		. += mutable_appearance(icon, "roastingstick_sausage")

/obj/item/melee/roastingstick/Exited(atom/movable/gone, direction)
	. = ..()
	if (gone == held_sausage)
		held_sausage = null
		update_appearance()

/obj/item/melee/roastingstick/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if (!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return
	if (!is_type_in_typecache(target, ovens))
		return
	if (istype(target, /obj/anomaly) && get_dist(user, target) < 10)
		to_chat(user, span_notice("You send [held_sausage] towards [target]."))
		playsound(src, 'sound/items/rped.ogg', 50, TRUE)
		beam = user.Beam(target, icon_state = "rped_upgrade", time = 10 SECONDS)
	else if (user.Adjacent(target))
		to_chat(user, span_notice("You extend [src] towards [target]."))
		playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, TRUE)
	else
		return
	finish_roasting(user, target)

/obj/item/melee/roastingstick/proc/finish_roasting(user, atom/target)
	if(do_after(user, 100, target = user))
		to_chat(user, span_notice("You finish roasting [held_sausage]."))
		playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
		held_sausage.add_atom_colour(rgb(103, 63, 24), FIXED_COLOUR_PRIORITY)
		held_sausage.name = "[target.name]-roasted [held_sausage.name]"
		held_sausage.desc = "[held_sausage.desc] It has been cooked to perfection on \a [target]."
		update_appearance()
	else
		QDEL_NULL(beam)
		playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
		to_chat(user, span_notice("You put [src] away."))

/obj/item/melee/knockback_stick
	name = "Knockback Stick"
	desc = "An portable anti-gravity generator which knocks people back upon contact."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "telebaton_on"
	inhand_icon_state = "nullrod"
	worn_icon_state = "tele_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("repells")
	attack_verb_simple = list("repell")
	var/cooldown = 0
	var/knockbackpower = 6

/obj/item/melee/knockback_stick/attack(mob/living/target, mob/living/user)
	add_fingerprint(user)

	if(cooldown <= world.time)
		playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
		log_combat(user, target, "knockedbacked", src)
		target.visible_message(span_danger("[user] has knocked back [target] with [src]!"), \
			span_userdanger("[user] has knocked you back [target] with [src]!"))

		var/throw_dir = get_dir(user,target)
		var/turf/throw_at = get_ranged_target_turf(target, throw_dir, knockbackpower)
		target.throw_at(throw_at, throw_range, 3)

		cooldown = world.time + 15

//Former Wooden Baton
/obj/item/melee/tonfa
	name = "Police Tonfa"
	desc = "A traditional police baton for gaining the submission of an uncooperative target without the use of lethal-force. \
		As with all traditional weapons, the target will find themselves bruised, but alive. It has proven to be effective in preventing \
		repeat offenses and has brought employment to lawyers for decades."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "beater"
	inhand_icon_state = "beater"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 12
	throwforce = 7
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_LARGE
	hitsound = 'sound/effects/woodhit.ogg'
	custom_price = 100
	/// Damage dealt while on help intent
	var/non_harm_force = 3
	/// Stamina damage dealt
	var/stamina_force = 25

// #11200 Review - TEMP: Hacky code to deal with force string for this item.
/obj/item/melee/tonfa/openTip(location, control, params, mob/living/user)
	if (user != null && !user.combat_mode)
		force = non_harm_force
	else
		force = initial(force)
	return ..()

/obj/item/melee/tonfa/attack(mob/living/target, mob/living/user)
	var/target_zone = user.get_combat_bodyzone(target)
	var/armour_level = target.getarmor(target_zone, STAMINA, penetration = armour_penetration - 15)

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, span_danger("You hit yourself over the head."))
		user.adjustStaminaLoss(stamina_force)

		// Deal full damage
		force = initial(force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(!isliving(target))
		return ..()
	if(iscyborg(target))
		if (!user.combat_mode)
			playsound(get_turf(src), hitsound, 75, 1, -1)
			user.do_attack_animation(target) // The attacker cuddles the Cyborg, awww. No damage here.
			return
	if (!user.combat_mode)
		force = non_harm_force
	else
		force = initial(force)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
			return
		if(check_martial_counter(H, user))
			log_combat(user, target, "attempted to attack", src, "(blocked by martial arts)")
			return

		target.visible_message("[user] strikes [target] in the [parse_zone(target_zone)].", "You strike [target] in the [parse_zone(target_zone)].")
		log_combat(user, target, "attacked", src)

		// If the target has a lot of stamina loss, knock them down
		if ((user.is_zone_selected(BODY_ZONE_L_LEG) || user.is_zone_selected(BODY_ZONE_R_LEG)) && target.getStaminaLoss() > 22)
			var/effectiveness = CLAMP01((target.getStaminaLoss() - 22) / 50)
			log_combat(user, target, "knocked-down", src, "(additional effect)")
			// Move the target back upon knockdown, to give them some time to recover
			var/shove_dir = get_dir(user.loc, target.loc)
			var/turf/target_shove_turf = get_step(target.loc, shove_dir)
			var/mob/living/carbon/human/target_collateral_human = locate(/mob/living/carbon) in target_shove_turf.contents
			if (target_collateral_human && target_shove_turf != get_turf(user))
				target.Knockdown(max(0.5 SECONDS, effectiveness * 4 SECONDS * (100-armour_level)/100))
				target_collateral_human.Knockdown(0.5 SECONDS)
			else
				target.Knockdown(effectiveness * 4 SECONDS * (100-armour_level)/100)
			target.Move(target_shove_turf, shove_dir)
		if (user.is_zone_selected(BODY_ZONE_L_LEG) || user.is_zone_selected(BODY_ZONE_R_LEG) || user.is_zone_selected(BODY_ZONE_L_ARM) || user.is_zone_selected(BODY_ZONE_R_ARM))
			// 4-5 hits on an unarmoured target
			target.apply_damage(stamina_force*0.6, STAMINA, target_zone, armour_level)
		else
			// 4-5 hits on an unarmoured target
			target.apply_damage(stamina_force, STAMINA, target_zone, armour_level)

	return ..()

/obj/item/stake
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'icons/vampires/stakes.dmi'
	icon_state = "wood"
	inhand_icon_state = "wood"
	lefthand_file = 'icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'icons/vampires/bs_rightinhand.dmi'
	slot_flags = ITEM_SLOT_POCKETS
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("staked", "stabbed", "tore into")
	attack_verb_simple = list("staked", "stabbed", "tore into")
	sharpness = SHARP
	force = 6
	throwforce = 10
	max_integrity = 30
	embedding = list(
		"embed_chance" = 100,
		"fall_chance" = 0,
		"rip_time" = 5 SECONDS, // this is actually 10 seconds because it gets multiplied by the w_class
	)

	///Time it takes to embed the stake into someone's chest.
	var/staketime = 12 SECONDS

/obj/item/stake/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(.)
		return

	// Cannot target yourself, must be in combat mode and targeting the chest
	if(target == user)
		return
	if(!user.combat_mode)
		return
	if(check_zone(user.get_combat_bodyzone()) != BODY_ZONE_CHEST)
		return

	if(HAS_TRAIT(target, TRAIT_BEINGSTAKED))
		to_chat(user, span_notice("[target] is already having a stake driven into [target.p_their()] chest!"))
		return

	// lol, cry about it
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		to_chat(user, span_notice("[target]'s chest is too thick! [src] won't go in!"))
		return

	// Cannot have something in your chest
	var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return
	for(var/obj/item/embedded_object in chest.embedded_objects)
		to_chat(user, span_boldannounce("[target]'s chest already has [embedded_object] inside of it!"))
		return

	playsound(target, 'sound/magic/Demon_consume.ogg', 50, 1)
	to_chat(target, span_userdanger("[user] is driving a stake into your chest!"))
	to_chat(user, span_notice("You put all your weight into embedding [src] into [target]'s chest..."))

	ADD_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
	if(!do_after(user, staketime, target))
		REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
		return

	REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)

	// Actually embed the stake and apply damage
	if(!tryEmbed(target.get_bodypart(BODY_ZONE_CHEST), TRUE, TRUE))
		return

	target.apply_damage(force * 5, BRUTE, BODY_ZONE_CHEST)

	playsound(target, 'sound/effects/splat.ogg', 40, 1)
	user.visible_message(
		span_danger("[user] drives the [src] into [target]'s chest!"),
		span_danger("You drive the [src] into [target]'s chest!"),
	)

	if(IS_VAMPIRE(target))
		to_chat(target, span_userdanger("You have been staked! Your powers are useless while it's in your chest!"))
		target.balloon_alert(target, "you have been staked!")

///Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/obj/item/stake/proc/can_be_staked(mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	if(!CHECK_BITFIELD(target.mobility_flags, MOBILITY_MOVE))
		return TRUE
	return FALSE

/// Created by welding and acid-treating a simple stake.
/obj/item/stake/hardened
	name = "hardened stake"
	desc = "A wooden stake carved to a sharp point and hardened by fire."
	icon_state = "hardened"
	force = 8
	throwforce = 12
	armour_penetration = 10
	staketime = 8 SECONDS

/obj/item/stake/hardened/silver
	name = "silver stake"
	desc = "Polished and sharp at the end. For when some mofo is always trying to iceskate uphill."
	icon_state = "silver"
	inhand_icon_state = "silver"
	siemens_coefficient = 1
	force = 9
	armour_penetration = 25
	staketime = 6 SECONDS
