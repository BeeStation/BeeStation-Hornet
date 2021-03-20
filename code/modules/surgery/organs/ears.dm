/obj/item/organ/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Your ears begin to resonate with an internal ring sometimes.</span>"
	now_failing = "<span class='warning'>You are unable to hear at all!</span>"
	now_fixed = "<span class='info'>Noise slowly begins filling your ears once more.</span>"
	low_threshold_cleared = "<span class='info'>The ringing in your ears has died down.</span>"

	// `deaf` measures "ticks" of deafness. While > 0, the person is unable
	// to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	//Resistance against loud noises
	var/bang_protect = 0
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/ears/on_life()
	if(!iscarbon(owner))
		return
	..()
	var/mob/living/carbon/C = owner
	if((damage < maxHealth) && (organ_flags & ORGAN_FAILING))	//ear damage can be repaired from the failing condition
		organ_flags &= ~ORGAN_FAILING
	// genetic deafness prevents the body from using the ears, even if healthy
	if(HAS_TRAIT(C, TRAIT_DEAF))
		deaf = max(deaf, 1)
	else if(!(organ_flags & ORGAN_FAILING)) // if this organ is failing, do not clear deaf stacks.
		deaf = max(deaf - 1, 0)
		if(prob(damage / 20) && (damage > low_threshold))
			adjustEarDamage(0, 4)
			SEND_SOUND(C, sound('sound/weapons/flash_ring.ogg'))
			to_chat(C, "<span class='warning'>The ringing in your ears grows louder, blocking out any external noises for a moment.</span>")
	else if((organ_flags & ORGAN_FAILING) && (deaf == 0))
		deaf = 1	//stop being not deaf you deaf idiot

/obj/item/organ/ears/proc/restoreEars()
	deaf = 0
	damage = 0
	organ_flags &= ~ORGAN_FAILING

	var/mob/living/carbon/C = owner

	if(iscarbon(owner) && HAS_TRAIT(C, TRAIT_DEAF))
		deaf = 1

/obj/item/organ/ears/proc/adjustEarDamage(ddmg, ddeaf)
	damage = max(damage + (ddmg*damage_multiplier), 0)
	deaf = max(deaf + (ddeaf*damage_multiplier), 0)

/obj/item/organ/ears/proc/minimumDeafTicks(value)
	deaf = max(deaf, value)

/obj/item/organ/ears/invincible
	damage_multiplier = 0


/mob/proc/restoreEars()

/mob/living/carbon/restoreEars()
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.restoreEars()

/mob/proc/adjustEarDamage()

/mob/living/carbon/adjustEarDamage(ddmg, ddeaf)
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.adjustEarDamage(ddmg, ddeaf)

/mob/proc/minimumDeafTicks()

/mob/living/carbon/minimumDeafTicks(value)
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.minimumDeafTicks(value)


/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "kitty"
	bang_protect = -2
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/active = FALSE
	var/datum/proximity_monitor/advanced/felinid_tracking/tracking_field
	var/next_use_time
	var/last_host_loc

/obj/item/organ/ears/cat/Destroy()
	disable_listening(owner)
	. = ..()

/obj/item/organ/ears/cat/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		color = H.hair_color
		H.dna.species.mutant_bodyparts |= "ears"
		H.dna.features["ears"] = "Cat"
		H.update_body()

/obj/item/organ/ears/cat/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		color = H.hair_color
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()
	disable_listening(H)

/obj/item/organ/ears/cat/ui_action_click(mob/user, actiontype)
	if(next_use_time > world.time)
		to_chat(user, "<span class='warning'>You can't do that yet!</span>")
		return
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!active)
		enable_listening(H)
	else
		disable_listening(H)

/obj/item/organ/ears/cat/proc/enable_listening(mob/living/carbon/human/H)
	if(active)
		return
	active = TRUE
	H.add_movespeed_modifier(MOVESPEED_ID_STALKING, update=TRUE, priority=100, multiplicative_slowdown=1.25)
	tracking_field = make_field(/datum/proximity_monitor/advanced/felinid_tracking, list("current_range" = 5, "host" = H, "parent" = H, "ears" = src))
	bang_protect = -5	//Ears are listening out, god forbit you hear any loud noises.
	H.visible_message("<span class='notice'>[H] freezes and looks alert, [H.p_their()] ears perking up!</span>")
	next_use_time = world.time + 10 SECONDS
	START_PROCESSING(SSprocessing, src)

/obj/item/organ/ears/cat/proc/disable_listening(mob/living/carbon/human/H)
	if(!active)
		return
	active = FALSE
	H.remove_movespeed_modifier(MOVESPEED_ID_STALKING)
	bang_protect = -2
	qdel(tracking_field)
	H.visible_message("<span class='notice'>[H]'s relaxes!</span>")
	next_use_time = world.time + 10 SECONDS
	STOP_PROCESSING(SSprocessing, src)

/obj/item/organ/ears/cat/Remove(mob/living/carbon/M, special)
	if(active)
		ui_action_click(M)
	. = ..()

/obj/item/organ/ears/cat/process()
	if(tracking_field && (!last_host_loc || last_host_loc != get_turf(owner)))
		tracking_field.HandleMove()
		last_host_loc = get_turf(owner)

/datum/proximity_monitor/advanced/felinid_tracking
	name = "Felinid tracking field"
	setup_field_turfs = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	var/list/tracked_turf = list()
	var/mob/parent
	var/obj/item/organ/ears/cat/ears

/datum/proximity_monitor/advanced/felinid_tracking/Destroy()
	. = ..()
	for(var/tracked_atom in tracked_turf)
		untrack_turf(tracked_atom)

/datum/proximity_monitor/advanced/felinid_tracking/update_new_turfs()
	var/list/before_turfs = field_turfs.Copy()
	. = ..()
	var/list/removed_turfs = before_turfs - field_turfs
	for(var/turf/T as() in removed_turfs)
		untrack_turf(T)

/datum/proximity_monitor/advanced/felinid_tracking/setup_field_turf(turf/T)
	track_turf(T)
	. = ..()

/datum/proximity_monitor/advanced/felinid_tracking/proc/untrack_turf(turf/T)
	UnregisterSignal(T, COMSIG_TURF_PLAY_SOUND)
	tracked_turf -= T

/datum/proximity_monitor/advanced/felinid_tracking/proc/track_turf(turf/T)
	RegisterSignal(T, COMSIG_TURF_PLAY_SOUND, .proc/OnHeard, TRUE)
	tracked_turf += T

/datum/proximity_monitor/advanced/felinid_tracking/proc/OnHeard(turf/turf_source, atom/movable/source, list/listeners, volume, maxdistance)
	//Check parent
	if(!parent.client)
		ears.disable_listening(parent)
		return
	//Check ears
	if(!istype(ears))
		qdel(src)
		return
	//Check hearing
	if(!parent.can_hear())
		return
	//Check type
	if(!istype(parent) || !turf_source)
		return
	//Check volume
	if(volume <= 0)
		return
	//Check range
	if(get_dist(get_turf(parent), turf_source) >= maxdistance - 1)
		return
	//Check that we were a listener
	if(!(parent in listeners))
		return
	//Check pressure
	var/pressure_factor = 1
	var/turf/T = get_turf(parent)
	var/datum/gas_mixture/hearer_env = T.return_air()
	var/datum/gas_mixture/source_env = turf_source.return_air()

	if(hearer_env && source_env)
		var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
		if(pressure < ONE_ATMOSPHERE)
			pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
	else //space
		pressure_factor = 0
	if(pressure_factor < 0.6)
		return
	//Do effect
	var/x_change = turf_source.x - T.x
	var/y_change = turf_source.y - T.y
	var/image/I = new('icons/effects/alert.dmi', loc = T, layer = ABOVE_LIGHTING_LAYER)
	I.plane = ABOVE_LIGHTING_PLANE
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	//Do that you can see it through the darkness.
	I.pixel_x = x_change * world.icon_size
	I.pixel_y = y_change * world.icon_size
	parent.client.images += I
	//Animation
	sleep(4.3)
	parent.client.images -= I
	qdel(I)

/obj/item/organ/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."
	var/datum/component/waddle

/obj/item/organ/ears/penguin/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(istype(H))
		to_chat(H, "<span class='notice'>You suddenly feel like you've lost your balance.</span>")
		waddle = H.AddComponent(/datum/component/waddling)

/obj/item/organ/ears/penguin/Remove(mob/living/carbon/human/H,  special = 0)
	. = ..()
	if(istype(H))
		to_chat(H, "<span class='notice'>Your sense of balance comes back to you.</span>")
		QDEL_NULL(waddle)

/obj/item/organ/ears/bronze
	name = "tin ears"
	desc = "The robust ears of a bronze golem. "
	damage_multiplier = 0.1 //STRONK
	bang_protect = 1 //Fear me weaklings.

/obj/item/organ/ears/robot
	name = "auditory sensors"
	icon_state = "robotic_ears"
	desc = "A pair of microphones intended to be installed in an IPC head, that grant the ability to hear."
	zone = "head"
	slot = "ears"
	gender = PLURAL
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/ears/robot/emp_act(severity)
	switch(severity)
		if(1)
			owner.Jitter(30)
			owner.Dizzy(30)
			owner.Knockdown(200)
			deaf = 30
			to_chat(owner, "<span class='warning'>Your robotic ears are ringing, uselessly.</span>")
		if(2)
			owner.Jitter(15)
			owner.Dizzy(15)
			owner.Knockdown(100)
			to_chat(owner, "<span class='warning'>Your robotic ears buzz.</span>")
