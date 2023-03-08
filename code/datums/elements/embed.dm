/*
	The presence of this element allows an item (or a projectile carrying an item) to embed itself in a carbon when it is thrown into a target (whether by hand, gun, or explosive wave) with either
	at least 4 throwspeed (EMBED_THROWSPEED_THRESHOLD) or ignore_throwspeed_threshold set to TRUE. Items meant to be used as shrapnel for projectiles should have ignore_throwspeed_threshold set to true.

	Whether we're dealing with a direct /obj/item (throwing a knife at someone) or an /obj/projectile with a shrapnel_type, how we handle things plays out the same, with one extra step separating them.
	Items simply make their COMSIG_MOVABLE_IMPACT_ZONE check, while projectiles check on COMSIG_PROJECTILE_SELF_ON_HIT.
	Upon a projectile hitting a valid target, it spawns whatever type of payload it has defined, then has that try to embed itself in the target on its own.

	Otherwise non-embeddable or stickable items can be made embeddable/stickable through wizard events/sticky tape/admin memes.
*/

/datum/element/embed
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/initialized = FALSE /// whether we can skip assigning all the vars (since these are bespoke elements, we don't have to reset the vars every time we attach to something, we already know what we are!)

	// all of this stuff is explained in _DEFINES/combat.dm
	var/embed_chance
	var/fall_chance
	var/pain_chance
	var/pain_mult
	var/max_damage_mult
	var/remove_pain_mult
	var/rip_time
	var/ignore_throwspeed_threshold
	var/jostle_chance
	var/jostle_pain_mult
	var/pain_stam_pct
	var/armour_block
	var/payload_type

/datum/element/embed/Attach(datum/target, embed_chance, fall_chance, pain_chance, pain_mult, max_damage_mult, remove_pain_mult, rip_time, ignore_throwspeed_threshold, jostle_chance, jostle_pain_mult, pain_stam_pct, armour_block, projectile_payload=/obj/item/shard)
	. = ..()

	if(!isitem(target) && !isprojectile(target))
		return ELEMENT_INCOMPATIBLE

	if(isitem(target))
		RegisterSignal(target, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(checkEmbed))
		RegisterSignal(target, COMSIG_ELEMENT_ATTACH, PROC_REF(severancePackage))
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(examined))
		RegisterSignal(target, COMSIG_EMBED_TRY_FORCE, PROC_REF(tryForceEmbed))
		RegisterSignal(target, COMSIG_ITEM_DISABLE_EMBED, PROC_REF(detachFromWeapon))
		if(!initialized)
			src.embed_chance = embed_chance
			src.fall_chance = fall_chance
			src.pain_chance = pain_chance
			src.pain_mult = pain_mult
			src.max_damage_mult = max_damage_mult
			src.remove_pain_mult = remove_pain_mult
			src.rip_time = rip_time
			src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
			src.jostle_chance = jostle_chance
			src.jostle_pain_mult = jostle_pain_mult
			src.pain_stam_pct = pain_stam_pct
			src.armour_block = armour_block
			initialized = TRUE
	else
		payload_type = projectile_payload
		RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(checkEmbedProjectile))


/datum/element/embed/Detach(obj/target)
	. = ..()
	if(isitem(target))
		UnregisterSignal(target, list(COMSIG_MOVABLE_IMPACT_ZONE, COMSIG_ELEMENT_ATTACH, COMSIG_MOVABLE_IMPACT, COMSIG_PARENT_EXAMINE, COMSIG_EMBED_TRY_FORCE, COMSIG_ITEM_DISABLE_EMBED))
	else
		UnregisterSignal(target, list(COMSIG_PROJECTILE_SELF_ON_HIT))


/// Checking to see if we're gonna embed into a human
/datum/element/embed/proc/checkEmbed(obj/item/weapon, mob/living/carbon/victim, hit_zone, datum/thrownthing/throwingdatum, forced=FALSE)
	SIGNAL_HANDLER

	if(!istype(victim) || HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		return

	var/flying_speed = throwingdatum ? throwingdatum.speed : weapon.throw_speed

	if(!forced && (flying_speed < EMBED_THROWSPEED_THRESHOLD && !ignore_throwspeed_threshold)) // check if it's a forced embed, and if not, if it's going fast enough to proc embedding
		return

	var/actual_chance = embed_chance

	if(throwingdatum?.speed > weapon.throw_speed)
		actual_chance += (throwingdatum.speed - weapon.throw_speed) * EMBEDDED_CHANCE_SPEED_BONUS

	var/target_armour = 0

	if(!weapon.isEmbedHarmless()) // all the armor in the world won't save you from a kick me sign
		target_armour = victim.run_armor_check(hit_zone, armour_penetration = weapon.armour_penetration, silent = TRUE)

		//Target has enough armour to block the embed.
		if(target_armour >= armour_block)
			victim.visible_message("<span class='danger'>[weapon] bounces off [victim]'s armor!</span>", "<span class='notice'>[weapon] bounces off your armor!</span>", vision_distance = COMBAT_MESSAGE_RANGE)
			return

	var/percentage_unblocked = 1 - (target_armour / armour_block)

	if(!prob(actual_chance * percentage_unblocked))
		return

	var/obj/item/bodypart/limb = victim.get_bodypart(hit_zone) || pick(victim.bodyparts)
	victim.AddComponent(/datum/component/embedded,\
		weapon,\
		throwingdatum,\
		part = limb,\
		embed_chance = embed_chance,\
		fall_chance = fall_chance,\
		pain_chance = pain_chance,\
		pain_mult = pain_mult,\
		remove_pain_mult = remove_pain_mult,\
		rip_time = rip_time,\
		ignore_throwspeed_threshold = ignore_throwspeed_threshold,\
		jostle_chance = jostle_chance,\
		jostle_pain_mult = jostle_pain_mult,\
		pain_stam_pct = pain_stam_pct)

	return TRUE

///A different embed element has been attached, so we'll detach and let them handle things
/datum/element/embed/proc/severancePackage(obj/item/weapon, datum/element/E)
	SIGNAL_HANDLER

	if(istype(E, /datum/element/embed))
		Detach(weapon)

///If we don't want to be embeddable anymore (deactivating an e-dagger for instance)
/datum/element/embed/proc/detachFromWeapon(obj/weapon)
	SIGNAL_HANDLER

	Detach(weapon)

///Someone inspected our embeddable item
/datum/element/embed/proc/examined(obj/item/I, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(I.isEmbedHarmless())
		examine_list += "[I] feels sticky, and could probably get stuck to someone if thrown properly!"
	else
		examine_list += "[I] has a fine point, and could probably embed in someone if thrown properly!"

/**
  * checkEmbedProjectile() is what we get when a projectile with a defined shrapnel_type impacts a target.
  *
  * If we hit a valid target, we create the shrapnel_type object and immediately call tryEmbed() on it, targeting what we impacted. That will lead
  *	it to call tryForceEmbed() on its own embed element (it's out of our hands here, our projectile is done), where it will run through all the checks it needs to.
  */
/datum/element/embed/proc/checkEmbedProjectile(obj/item/projectile/P, atom/movable/firer, atom/hit, angle, hit_zone)
	SIGNAL_HANDLER

	if(!iscarbon(hit))
		Detach(P)
		return // we don't care

	var/obj/item/payload = new payload_type(get_turf(hit))
	var/mob/living/carbon/C = hit
	var/obj/item/bodypart/limb = C.get_bodypart(hit_zone)
	if(!limb)
		limb = C.get_bodypart()

	if(!payload.tryEmbed(limb))
		payload.failedEmbed()
	Detach(P)

/**
  * tryForceEmbed() is called here when we fire COMSIG_EMBED_TRY_FORCE from [/obj/item/proc/tryEmbed]. Mostly, this means we're a piece of shrapnel from a projectile that just impacted something, and we're trying to embed in it.
  *
  * The reason for this extra mucking about is avoiding having to do an extra hitby(), and annoying the target by impacting them once with the projectile, then again with the shrapnel, and possibly
  * AGAIN if we actually embed. This way, we save on at least one message.
  *
  * Arguments:
  * * I- the item we're trying to insert into the target
  * * target- what we're trying to shish-kabob, either a bodypart or a carbon
  * * hit_zone- if our target is a carbon, try to hit them in this zone, if we don't have one, pick a random one. If our target is a bodypart, we already know where we're hitting.
  * * forced- if we want this to succeed 100%
  */
/datum/element/embed/proc/tryForceEmbed(obj/item/I, atom/target, hit_zone, forced=FALSE)
	SIGNAL_HANDLER

	var/obj/item/bodypart/limb
	var/mob/living/carbon/C

	if(!forced && !prob(embed_chance))
		return

	if(iscarbon(target))
		C = target
		if(!hit_zone)
			limb = pick(C.bodyparts)
			hit_zone = limb.body_zone
	else if(isbodypart(target))
		limb = target
		C = limb.owner

	return checkEmbed(I, C, hit_zone, forced=TRUE)
