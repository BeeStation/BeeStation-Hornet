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
	var/impact_pain_mult
	var/remove_pain_mult
	var/rip_time
	var/ignore_throwspeed_threshold
	var/jostle_chance
	var/jostle_pain_mult
	var/pain_stam_pct

	var/harmful

/datum/component/embedded/Initialize(obj/item/I,
			datum/thrownthing/throwingdatum,
			obj/item/bodypart/part,
			embed_chance = EMBED_CHANCE,
			fall_chance = EMBEDDED_ITEM_FALLOUT,
			pain_chance = EMBEDDED_PAIN_CHANCE,
			pain_mult = EMBEDDED_PAIN_MULTIPLIER,
			remove_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
			impact_pain_mult = EMBEDDED_IMPACT_PAIN_MULTIPLIER,
			rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
			ignore_throwspeed_threshold = FALSE,
			jostle_chance = EMBEDDED_JOSTLE_CHANCE,
			jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
			pain_stam_pct = EMBEDDED_PAIN_STAM_PCT)

	if(!iscarbon(parent) || !isitem(I))
		return COMPONENT_INCOMPATIBLE

	if(part)
		limb = part
	src.embed_chance = embed_chance
	src.fall_chance = fall_chance
	src.pain_chance = pain_chance
	src.pain_mult = pain_mult
	src.remove_pain_mult = remove_pain_mult
	src.rip_time = rip_time
	src.impact_pain_mult = impact_pain_mult
	src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
	src.jostle_chance = jostle_chance
	src.jostle_pain_mult = jostle_pain_mult
	src.pain_stam_pct = pain_stam_pct
	src.weapon = I

	if(!weapon.isEmbedHarmless())
		harmful = TRUE

	weapon.embedded(parent)
	START_PROCESSING(SSdcs, src)
	var/mob/living/carbon/victim = parent

	limb.embedded_objects |= weapon // on the inside... on the inside...
	weapon.forceMove(victim)
	RegisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), .proc/weaponDeleted)
	victim.visible_message("<span class='danger'>[weapon] [harmful ? "embeds" : "sticks"] itself [harmful ? "in" : "to"] [victim]'s [limb.name]!</span>", "<span class='userdanger'>[weapon] [harmful ? "embeds" : "sticks"] itself [harmful ? "in" : "to"] your [limb.name]!</span>")

	if(harmful)
		victim.throw_alert("embeddedobject", /atom/movable/screen/alert/embeddedobject)
		playsound(victim,'sound/weapons/bladeslice.ogg', 40)
		weapon.add_mob_blood(victim)//it embedded itself in you, of course it's bloody!
		var/damage = weapon.w_class * impact_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)

/datum/component/embedded/Destroy()
	var/mob/living/carbon/victim = parent
	if(victim && !victim.has_embedded_objects())
		victim.clear_alert("embeddedobject")
		SEND_SIGNAL(victim, COMSIG_CLEAR_MOOD_EVENT, "embedded")
	if(weapon)
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	weapon = null
	limb = null
	return ..()

/datum/component/embedded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/jostleCheck)
	RegisterSignal(parent, COMSIG_CARBON_EMBED_RIP, .proc/ripOut)
	RegisterSignal(parent, COMSIG_CARBON_EMBED_REMOVAL, .proc/safeRemove)

/datum/component/embedded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_EMBED_RIP, COMSIG_CARBON_EMBED_REMOVAL))

/datum/component/embedded/process()
	var/mob/living/carbon/victim = parent

	if(!victim || !limb) // in case the victim and/or their limbs exploded (say, due to a sticky bomb)
		weapon.forceMove(get_turf(weapon))
		qdel(src)
		return

	if(victim.stat == DEAD)
		return

	var/damage = weapon.w_class * pain_mult
	var/chance = pain_chance
	if(pain_stam_pct && victim.stam_paralyzed) //if it's a less-lethal embed, give them a break if they're already stamcritted
		chance *= 0.2
		damage *= 0.5

	if(harmful && prob(chance))
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [limb.name] hurts!</span>")

	if(prob(fall_chance))
		fallOut()

////////////////////////////////////////
////////////BEHAVIOR PROCS//////////////
////////////////////////////////////////

/// Called every time a carbon with a harmful embed moves, rolling a chance for the item to cause pain. The chance is halved if the carbon is crawling or walking.
/datum/component/embedded/proc/jostleCheck()
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	var/chance = jostle_chance
	if(victim.m_intent == MOVE_INTENT_WALK || victim.lying)
		chance *= 0.5

	if(prob(chance))
		var/damage = weapon.w_class * jostle_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [limb.name] jostles and stings!</span>")


/// Called when then item randomly falls out of a carbon. This handles the damage and descriptors, then calls safe_remove()
/datum/component/embedded/proc/fallOut()
	var/mob/living/carbon/victim = parent

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)

	victim.visible_message("<span class='danger'>[weapon] falls [harmful ? "out" : "off"] of [victim.name]'s [limb.name]!</span>", "<span class='userdanger'>[weapon] falls [harmful ? "out" : "off"] of your [limb.name]!</span>")
	safeRemove()

/// Called when a carbon with an object embedded/stuck to them inspects themselves and clicks the appropriate link to begin ripping the item out. This handles the ripping attempt, descriptors, and dealing damage, then calls safe_remove()
/datum/component/embedded/proc/ripOut(datum/source, obj/item/I, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	if(I != weapon || src.limb != limb)
		return

	var/mob/living/carbon/victim = parent
	var/time_taken = rip_time * weapon.w_class
	INVOKE_ASYNC(src, .proc/complete_rip_out, victim, I, limb, time_taken)

/// everything async that ripOut used to do
/datum/component/embedded/proc/complete_rip_out(mob/living/carbon/victim, obj/item/I, obj/item/bodypart/limb, time_taken)
	victim.visible_message("<span class='warning'>[victim] attempts to remove [weapon] from [victim.p_their()] [limb.name].</span>","<span class='notice'>You attempt to remove [weapon] from your [limb.name]... (It will take [DisplayTimeText(time_taken)].)</span>")

	if(!do_after(victim, time_taken, target = victim))
		return
	if(!weapon || !limb || weapon.loc != victim || !(weapon in limb.embedded_objects))
		qdel(src)
		return

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage) //It hurts to rip it out, get surgery you dingus.
		victim.emote("scream")

	victim.visible_message("<span class='notice'>[victim] successfully rips [weapon] [harmful ? "out" : "off"] of [victim.p_their()] [limb.name]!</span>", "<span class='notice'>You successfully remove [weapon] from your [limb.name].</span>")
	safeRemove(TRUE)

/// This proc handles the final step and actual removal of an embedded/stuck item from a carbon, whether or not it was actually removed safely.
/// Pass TRUE for to_hands if we want it to go to the victim's hands when they pull it out
/datum/component/embedded/proc/safeRemove(to_hands)
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	limb.embedded_objects -= weapon
	UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING)) // have to do it here otherwise we trigger weaponDeleted()

	if(!weapon.unembedded()) // if it hasn't deleted itself due to drop del
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
		if(to_hands)
			INVOKE_ASYNC(to_hands, /mob.proc/put_in_hands, weapon)
		else
			weapon.forceMove(get_turf(victim))

	qdel(src)

/// Something deleted or moved our weapon while it was embedded, how rude!
/datum/component/embedded/proc/weaponDeleted()
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	limb.embedded_objects -= weapon

	if(victim)
		to_chat(victim, "<span class='userdanger'>\The [weapon] that was embedded in your [limb.name] disappears!</span>")
	qdel(src)
