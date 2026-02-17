/*
	This component is responsible for handling individual instances of embedded objects. The embeddable element is what allows an item to be embeddable and stores its embedding stats,
	and when it impacts and meets the requirements to stick into something, it instantiates an embedded component. Once the item falls out, the component is destroyed, while the
	element survives to embed another day.

		- Carbon embedding has all the classical embedding behavior, and tracks more events and signals. The main behaviors and hooks to look for are:
			-- Every process tick, there is a chance to randomly proc pain, controlled by pain_chance. There may also be a chance for the object to fall out randomly, per fall_chance
			-- Every time the mob moves, there is a chance to proc jostling pain, controlled by jostle_chance (and only 50% as likely if the mob is walking or crawling)
			-- Various signals hooking into carbon topic() and the embed removal surgery in order to handle removals.


	In addition, there are 2 cases of embedding: embedding, and sticking

		- Embedding involves harmful and dangerous embeds, whether they cause brute damage, stamina damage, or a mix. This is the default behavior for embeddings, for when something is "pointy"

		- Sticking occurs when an item should not cause any harm while embedding (imagine throwing a sticky ball of tape at someone, rather than a shuriken). An item is considered "sticky"
			when it has 0 random pain chance and 0 jostling chance. It's a bit arbitrary, but fairly straightforward.

		Stickables differ from embeds in the following ways:
			-- Text descriptors use phrasing like "X is stuck to Y" rather than "X is embedded in Y"
			-- There is no slicing sound on impact
			-- All damage checks and bloodloss are skipped

*/


/datum/component/embedded
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/obj/item/bodypart/limb
	var/obj/item/weapon

	// all of this stuff is explained in _DEFINES/combat.dm
	var/embed_chance // not like we really need it once we're already stuck in but hey
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

	var/harmful

/datum/component/embedded/Initialize(obj/item/I,
			datum/thrownthing/throwingdatum,
			obj/item/bodypart/part,
			embed_chance = EMBED_CHANCE,
			fall_chance = EMBEDDED_ITEM_FALLOUT,
			pain_chance = EMBEDDED_PAIN_CHANCE,
			pain_mult = EMBEDDED_PAIN_MULTIPLIER,
			max_damage_mult = EMBEDDED_MAX_DAMAGE_MULTIPLIER,
			remove_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
			rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
			ignore_throwspeed_threshold = FALSE,
			jostle_chance = EMBEDDED_JOSTLE_CHANCE,
			jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
			pain_stam_pct = EMBEDDED_PAIN_STAM_PCT,
			armour_block = EMBEDDED_ARMOUR_BLOCK)

	if(!iscarbon(parent) || !isitem(I))
		return COMPONENT_INCOMPATIBLE

	if(part)
		limb = part
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
	src.weapon = I

	if(!weapon.isEmbedHarmless())
		harmful = TRUE

	weapon.embedded(parent, part)
	START_PROCESSING(SSdcs, src)
	var/mob/living/carbon/victim = parent

	limb._embed_object(weapon) // on the inside... on the inside...
	weapon.forceMove(victim)
	RegisterSignals(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(weaponDeleted))
	victim.visible_message(span_danger("[weapon] [harmful ? "embeds" : "sticks"] itself [harmful ? "in" : "to"] [victim]'s [limb.name]!"), span_userdanger("[weapon] [harmful ? "embeds" : "sticks"] itself [harmful ? "in" : "to"] your [limb.name]!"))

	if(harmful)
		victim.throw_alert(ALERT_EMBEDDED_OBJECT, /atom/movable/screen/alert/embeddedobject)
		playsound(victim,'sound/weapons/bladeslice.ogg', 40)
		weapon.add_mob_blood(victim)//it embedded itself in you, of course it's bloody!
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)

/datum/component/embedded/Destroy()
	var/mob/living/carbon/victim = parent
	if(victim && !victim.has_embedded_objects())
		victim.clear_alert(ALERT_EMBEDDED_OBJECT)
		SEND_SIGNAL(victim, COMSIG_CLEAR_MOOD_EVENT, "embedded")
	if(weapon)
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	weapon = null
	limb = null
	return ..()

/datum/component/embedded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(jostleCheck))
	RegisterSignal(parent, COMSIG_CARBON_EMBED_RIP, PROC_REF(ripOut))
	RegisterSignal(parent, COMSIG_CARBON_EMBED_REMOVAL, PROC_REF(safeRemove))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(checkRemoval))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(tryPullOutOther))

/datum/component/embedded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_EMBED_RIP, COMSIG_CARBON_EMBED_REMOVAL, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND))

/datum/component/embedded/process(delta_time)
	var/mob/living/carbon/victim = parent

	if(!victim || !limb) // in case the victim and/or their limbs exploded (say, due to a sticky bomb)
		weapon.forceMove(get_turf(weapon))
		qdel(src)
		return

	if(victim.stat == DEAD)
		return

	var/damage = weapon.w_class * pain_mult
	var/max_damage = weapon.w_class * max_damage_mult + weapon.throwforce
	var/pain_chance_current = DT_PROB_RATE(pain_chance / 100, delta_time) * 100
	if(pain_stam_pct && HAS_TRAIT_FROM(victim, TRAIT_INCAPACITATED, STAMINA)) //if it's a less-lethal embed, give them a break if they're already stamcritted
		pain_chance_current *= 0.2
		damage *= 0.5
	else if(victim.body_position == LYING_DOWN)
		pain_chance_current *= 0.2

	if(harmful && prob(pain_chance_current))
		var/damage_left = max_damage - limb.get_damage()
		var/damage_wanted = (1-pain_stam_pct) * damage
		var/damage_to_deal = clamp(damage_wanted, 0, damage_left)
		var/damage_as_stam = damage_wanted - damage_to_deal
		if(!damage_to_deal)
			to_chat(victim, span_userdanger("[weapon] embedded in your [limb.name] stings a little!"))
		else
			limb.receive_damage(brute=damage_to_deal, stamina=(pain_stam_pct * damage) + damage_as_stam)
			to_chat(victim, span_userdanger("[weapon] embedded in your [limb.name] hurts!"))

	var/fallchance_current =  DT_PROB_RATE(fall_chance / 100, delta_time) * 100
	if(prob(fallchance_current))
		fallOut()

////////////////////////////////////////
////////////BEHAVIOR PROCS//////////////
////////////////////////////////////////

/// Called every time a carbon with a harmful embed moves, rolling a chance for the item to cause pain. The chance is halved if the carbon is crawling or walking.
/datum/component/embedded/proc/jostleCheck()
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	var/chance = jostle_chance
	if(victim.m_intent == MOVE_INTENT_WALK || victim.body_position == LYING_DOWN)
		chance *= 0.5

	if(harmful && prob(chance))
		var/damage = weapon.w_class * jostle_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		to_chat(victim, span_userdanger("[weapon] embedded in your [limb.name] jostles and stings!"))


/// Called when then item randomly falls out of a carbon. This handles the damage and descriptors, then calls safe_remove()
/datum/component/embedded/proc/fallOut()
	var/mob/living/carbon/victim = parent

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)

	victim.visible_message(span_danger("[weapon] falls [harmful ? "out" : "off"] of [victim.name]'s [limb.name]!"), span_userdanger("[weapon] falls [harmful ? "out" : "off"] of your [limb.name]!"))
	safeRemove()

/// Called when a carbon with an object embedded/stuck to them inspects themselves and clicks the appropriate link to begin ripping the item out. This handles the ripping attempt, descriptors, and dealing damage, then calls safe_remove()
/datum/component/embedded/proc/ripOut(datum/source, obj/item/I, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	if(I != weapon || src.limb != limb)
		return

	var/mob/living/carbon/victim = parent
	var/time_taken = rip_time * weapon.w_class
	INVOKE_ASYNC(src, PROC_REF(complete_rip_out), victim, I, limb, time_taken)

/// everything async that ripOut used to do
/datum/component/embedded/proc/complete_rip_out(mob/living/carbon/victim, obj/item/I, obj/item/bodypart/limb, time_taken)
	victim.visible_message(span_warning("[victim] attempts to remove [weapon] from [victim.p_their()] [limb.name]."),span_notice("You attempt to remove [weapon] from your [limb.name]... (It will take [DisplayTimeText(time_taken)].)"))

	if(!do_after(victim, time_taken, target = victim))
		return
	if(!weapon || !limb || weapon.loc != victim || !(weapon in limb.embedded_objects))
		qdel(src)
		return

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage) //It hurts to rip it out, get surgery you dingus.
		victim.emote("scream")

	victim.visible_message(span_notice("[victim] successfully rips [weapon] [harmful ? "out" : "off"] of [victim.p_their()] [limb.name]!"), span_notice("You successfully remove [weapon] from your [limb.name]."))
	safeRemove(victim)

/// This proc handles the final step and actual removal of an embedded/stuck item from a carbon, whether or not it was actually removed safely.
/// Pass TRUE for to_hands if we want it to go to the victim's hands when they pull it out
/datum/component/embedded/proc/safeRemove(mob/to_hands)
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	limb._unembed_object(weapon)
	UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING)) // have to do it here otherwise we trigger weaponDeleted()

	if(!weapon.unembedded()) // if it hasn't deleted itself due to drop del
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
		//If a mob was passed in and it can hold items, put it in the mob's hand.
		if(istype(to_hands) && to_hands.can_hold_items())
			INVOKE_ASYNC(to_hands, TYPE_PROC_REF(/mob, put_in_hands), weapon)
		else
			INVOKE_ASYNC(weapon, TYPE_PROC_REF(/atom/movable, forceMove), get_turf(victim))
		if(istype(weapon, /obj/item/shrapnel))
			weapon.disableEmbedding()

	qdel(src)

/datum/component/embedded/proc/tryPullOutOther(mob/living/carbon/victim, mob/user)
	SIGNAL_HANDLER

	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	if(ishuman(victim)) // check to see if the limb is actually exposed
		var/mob/living/carbon/human/victim_human = victim
		if(!victim_human.try_inject(user, limb.body_zone, INJECT_CHECK_IGNORE_SPECIES | INJECT_TRY_SHOW_ERROR_MESSAGE))
			return TRUE

	if(weapon.w_class <= WEIGHT_CLASS_SMALL)
		to_chat(user, span_warning("[weapon] embedding in \the [limb.name] of [parent] is too small to pull out with your bare hands!"))
		return

	INVOKE_ASYNC(src, PROC_REF(pluckOut), user, 1, 2, "pulling out")
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/embedded/proc/checkRemoval(mob/living/carbon/victim, obj/item/I, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(victim) || user.is_zone_selected(limb.body_zone) || user.combat_mode)
		return

	var/damage_multiplier = 1
	var/remove_verb = "removing"

	switch(I.tool_behaviour)
		if(TOOL_HEMOSTAT)
			damage_multiplier = 0
			remove_verb = "carefully removing"
		if(TOOL_WIRECUTTER)
			if(weapon.w_class >= WEIGHT_CLASS_NORMAL)
				to_chat(user, span_warning("[weapon] is too large to extract with wirecutters!"))
				return
			damage_multiplier = 0.5
		if(TOOL_SCREWDRIVER)
			if(weapon.w_class >= WEIGHT_CLASS_SMALL)
				to_chat(user, span_warning("[weapon] is too large to dislodge with a screwdriver!"))
				return
			damage_multiplier = 0.8
			remove_verb = "dislodging"
		else
			return

	if(ishuman(victim)) // check to see if the limb is actually exposed
		var/mob/living/carbon/human/victim_human = victim
		if(!victim_human.try_inject(user, limb.body_zone, INJECT_CHECK_IGNORE_SPECIES | INJECT_TRY_SHOW_ERROR_MESSAGE))
			return TRUE

	INVOKE_ASYNC(src, PROC_REF(pluckOut), user, damage_multiplier, max(damage_multiplier, 0.2), remove_verb)
	return COMPONENT_NO_AFTERATTACK

/// The actual action for pulling out an embedded object with any tools that work
/datum/component/embedded/proc/pluckOut(mob/user, damage_multiplier, time_multiplier, remove_verb)
	var/mob/living/carbon/victim = parent

	var/self_pluck = (user == victim)

	if(self_pluck)
		user.visible_message(span_danger("[user] begins [remove_verb] [weapon] from [user.p_their()] [limb.name]"), span_notice("You start [remove_verb] [weapon] from your [limb.name]..."),\
			vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=victim)
	else
		user.visible_message(span_danger("[user] begins [remove_verb] [weapon] from [victim]'s [limb.name]"),span_notice("You start [remove_verb] [weapon] from [victim]'s [limb.name]..."), \
			vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] begins [remove_verb] [weapon] from your [limb.name]..."))

	//Pluck time
	var/pluck_time = 4 SECONDS * weapon.w_class * time_multiplier
	if(!do_after(user, pluck_time, target = victim))
		if(self_pluck)
			to_chat(user, span_danger("You fail to remove [weapon] from your [limb.name]."))
		else
			to_chat(user, span_danger("You fail to remove [weapon] from [victim]'s [limb.name]."))
			to_chat(victim, span_danger("[user] fails to remove [weapon] from your [limb.name]."))
		return

	//Removed successfully
	if(self_pluck)
		to_chat(user, span_notice("You successfully remove [weapon] from your [limb.name]."))
	else
		to_chat(user, span_notice("You successfully remove [weapon] from [victim]'s [limb.name]."))
		to_chat(victim, span_notice("[user] remove [weapon] from your [limb.name]."))

	//Apply damage
	if(harmful && damage_multiplier)
		var/damage = weapon.w_class * remove_pain_mult * damage_multiplier
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		victim.emote("scream")

	//Remove it
	safeRemove(user)

/// Something deleted or moved our weapon while it was embedded, how rude!
/datum/component/embedded/proc/weaponDeleted()
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	limb._unembed_object(weapon)

	if(victim)
		to_chat(victim, span_userdanger("\The [weapon] that was embedded in your [limb.name] disappears!"))
	qdel(src)
