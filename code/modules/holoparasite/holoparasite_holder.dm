/**
 * A holoparasite holder used by a mind.
 * Handles shared effects between all holoparasites shared by one summoner.
 */
/datum/holoparasite_holder
	/// The mind that owns this holoparasite holder.
	var/datum/mind/owner
	/// The holoparasites contained by this holder.
	var/list/mob/living/simple_animal/hostile/holoparasite/holoparasites = list()
	/// The timer ID for the delayed death timer.
	var/delayed_death_timer_id
	/// TRUE if the owner will dust and such whenever they die, FALSE otherwise.
	var/death_two_electric_boogaloo = TRUE
	/// The antag team containing all the holoparasites in this holder.
	var/datum/team/holoparasites/team
	/// The current antag HUD for the owner.
	var/datum/atom_hud/antag/current_antag_hud
	/// The current antag HUD icon state for the owner.
	var/current_antag_hud_icon_state
	/// If the owner is in the process of dying (or is dead).
	var/dying = FALSE
	/// If the summoner has 'locked' their holoparasites, preventing them from manifesting.
	var/locked = FALSE
	/// An abstract object contained within the summoner, to host the team monitor component used for scout holoparasites.
	var/obj/effect/abstract/scout_monitor_holder/monitor_holder
	/// A weak reference to the team monitor component contained within the monitor holder, used for the host to track certain holoparasites on their HUD.
	var/datum/component/team_monitor/team_monitor

/datum/holoparasite_holder/New(datum/mind/_owner)
	if(!istype(_owner))
		CRASH("Attempted to create a holoparasite holder without a valid mind!")
	if(_owner.holoparasite_holder)
		CRASH("Attempted to create a second holoparasite holder for the mind of [key_name(_owner)]!")
	owner = _owner
	register_mind_signals()
	if(owner.current)
		register_body_signals(owner.current)
		var/datum/component/team_monitor/team_monitor = get_monitor(owner.current)
		team_monitor.show_hud(owner.current)
	if(owner.antag_hud)
		current_antag_hud = owner.antag_hud
	if(owner.antag_hud_icon_state)
		current_antag_hud_icon_state = owner.antag_hud_icon_state

/datum/holoparasite_holder/Destroy()
	unregister_mind_signals()
	unregister_body_signals(owner.current)
	stop_delayed_death()
	if(!QDELETED(team_monitor))
		team_monitor.hide_hud(owner.current)
		team_monitor.ClearFromParent()
		QDEL_NULL(team_monitor)
	if(!QDELETED(monitor_holder))
		QDEL_NULL(monitor_holder)
	return ..()

/datum/holoparasite_holder/proc/register_mind_signals()
	RegisterSignal(owner, COMSIG_MIND_TRANSFER_TO, PROC_REF(on_mind_transfer))
	RegisterSignal(owner, COMSIG_MIND_JOIN_ANTAG_HUD, PROC_REF(on_join_antag_hud))
	RegisterSignal(owner, COMSIG_MIND_LEAVE_ANTAG_HUD, PROC_REF(on_leave_antag_hud))

/datum/holoparasite_holder/proc/register_body_signals(mob/living/body)
	RegisterSignal(body, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(body, COMSIG_LIVING_DEATH, PROC_REF(on_body_death))
	RegisterSignal(body, COMSIG_LIVING_REVIVE, PROC_REF(on_body_revive))
	RegisterSignal(body, COMSIG_LIVING_ENTER_STASIS, PROC_REF(on_enter_stasis))
	RegisterSignal(body, COMSIG_LIVING_EXIT_STASIS, PROC_REF(on_exit_stasis))

/datum/holoparasite_holder/proc/unregister_mind_signals()
	UnregisterSignal(owner, list(COMSIG_MIND_TRANSFER_TO, COMSIG_MIND_JOIN_ANTAG_HUD, COMSIG_MIND_LEAVE_ANTAG_HUD))

/datum/holoparasite_holder/proc/unregister_body_signals(mob/living/body)
	UnregisterSignal(body, list(COMSIG_MOB_LOGIN, COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_LIVING_ENTER_STASIS, COMSIG_LIVING_EXIT_STASIS))

/**
 * Returns the holoparasite team for this summoner.
 */
/datum/holoparasite_holder/proc/get_holoparasite_team()
	if(!team)
		team = new(holder = src)
	return team

/**
 * Adds a new holoparasite to the holder.
 *
 * Arguments
 * * new_holopara: The holoparasite to add.
 */
/datum/holoparasite_holder/proc/add_holoparasite(mob/living/simple_animal/hostile/holoparasite/new_holopara)
	if(!istype(new_holopara))
		CRASH("Attempted to add a non-holoparasite ([new_holopara]) to the holoparasite holder of [key_name(owner)]!")
	if(new_holopara in holoparasites)
		return
	if(new_holopara.parent_holder)
		CRASH("Attempted to add a holoparasite ([key_name(new_holopara)]) with an existing holder ([key_name(new_holopara.parent_holder.owner)]) to the holder of [key_name(owner)]")
	holoparasites += new_holopara
	new_holopara.parent_holder = src
	if(current_antag_hud)
		current_antag_hud.join_hud(new_holopara)
	if(current_antag_hud_icon_state)
		set_antag_hud(new_holopara, current_antag_hud_icon_state)
	var/datum/component/team_monitor/team_monitor = get_monitor(owner.current)
	if(team_monitor)
		team_monitor.get_matching_beacons()

/**
 * Removes a holoparasite from the holder.
 *
 * Arguments
 * * holopara_to_remove: The holoparasite to remove.
 */
/datum/holoparasite_holder/proc/remove_holoparasite(mob/living/simple_animal/hostile/holoparasite/holopara_to_remove)
	if(!istype(holopara_to_remove))
		CRASH("Attempted to remove a non-holoparasite ([holopara_to_remove]) from the holoparasite holder of [key_name(owner)]!")
	if(holopara_to_remove.parent_holder != src)
		CRASH("Attempted to remove the wrong holder [key_name(owner)] from a holoparasite ([key_name(holopara_to_remove)])!")
	holoparasites -= holopara_to_remove
	holopara_to_remove.parent_holder = null
	if(current_antag_hud)
		current_antag_hud.leave_hud(holopara_to_remove)
	if(holopara_to_remove.mind.antag_hud_icon_state == current_antag_hud_icon_state)
		set_antag_hud(holopara_to_remove, null)

/**
 * Returns TRUE if the holoparasite holder is active (there are actual holoparasites in the holder), FALSE otherwise.
 */
/datum/holoparasite_holder/proc/is_active()
	return length(holoparasites)

/**
 * Transfers all the managed holoparasites into the summoner's new body.
 *
 * Arguments
 * * new_body: The new body to transfer the holoparasites to.
 */
/datum/holoparasite_holder/proc/transfer_holoparasites_to_body(mob/living/new_body)
	if(new_body.stat == DEAD && !HAS_TRAIT(new_body, TRAIT_NODEATH))
		return
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
		holopara.forceMove(new_body)
		holopara.register_body_signals(new_body)
		holopara.faction = new_body.faction.Copy()
		if(holopara.stat == DEAD)
			holopara.revive()
		to_chat(holopara, span_notice("You manifest into existence, as your master's soul appears in a new body!"))

/**
 * Handles the mind transferring bodies, unregistering our signals from the old body, and registering them with the new one.
 *
 * Arguments
 * * source: The mind that is transferring bodies.
 * * old_body: The body that the mind is transferring from.
 * * new_body: The body that the mind is transferring to.
 */
/datum/holoparasite_holder/proc/on_mind_transfer(datum/mind/source, mob/living/old_body, mob/living/new_body)
	SIGNAL_HANDLER
	remove_all_tracking_huds()
	if(old_body)
		unregister_body_signals(old_body)
		old_body.update_holoparasite_verbs()
		var/datum/component/team_monitor/team_monitor = get_monitor(old_body, create = FALSE)
		team_monitor?.hide_hud(old_body)
		toggle_monitor_hud(FALSE, old_body)
	stop_delayed_death()
	dying = FALSE
	SSblackbox.record_feedback("tally", "holoparasite_body_transfer", 1, "[QDELETED(old_body) ? "destroyed" : (old_body.stat != DEAD ? "alive" : "dead")] -> [(new_body && new_body.stat != DEAD) ? "alive" : "dead"]")
	if(new_body)
		if(new_body.stat == DEAD)
			start_delayed_death(new_body)
		var/datum/component/team_monitor/team_monitor = get_monitor(new_body)
		register_body_signals(new_body)
		transfer_holoparasites_to_body(new_body)
		new_body.update_holoparasite_verbs()
		team_monitor.show_hud(new_body)
		team_monitor.get_matching_beacons()
		handle_slime_cheese(old_body, new_body)
		toggle_monitor_hud(TRUE, new_body)

/**
 * Handles slimepeople transferring their mind to a new body on death.
 * This, in short, punishes them for their cheese, and renders their new body highly vulnerable for quite a bit,
 * while still allowing them to escape straight-up round-removal.
 *
 * Arguments
 * * old_body: The slimeperson's old body.
 * * new_body: The slimeperson's new body.
 */
/datum/holoparasite_holder/proc/handle_slime_cheese(mob/living/carbon/human/old_body, mob/living/carbon/human/new_body)
	if(!isslimeperson(old_body) || !isslimeperson(new_body) || (old_body.stat != DEAD && !HAS_TRAIT(old_body, TRAIT_CRITICAL_CONDITION)))
		return
	var/datum/species/oozeling/slime/old_slime = old_body.dna.species
	var/datum/species/oozeling/slime/new_slime = new_body.dna.species
	if(!(old_body in new_slime.bodies) || !(new_body in old_slime.bodies))
		return
	stop_delayed_death()
	// Nope, you still don't get to keep that body.
	playsound(old_body, 'sound/effects/curseattack.ogg', vol = 75, vary = TRUE, frequency = 0.5)
	old_body.dust(drop_items = TRUE)
	// Anyways, you don't escape such a death unpunished...
	if(HAS_TRAIT(new_body, TRAIT_NOCLONELOSS))
		new_body.adjustToxLoss(rand(40, 55), updating_health = FALSE, forced = TRUE)
	else
		new_body.adjustCloneLoss(rand(40, 55), updating_health = FALSE)
	var/obj/item/organ/brain/brain = new_body.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!istype(brain) || brain.decoy_override)
		var/obj/item/organ/heart = new_body.get_organ_slot(ORGAN_SLOT_HEART)
		if(!heart)
			// damn you, heartless bastard!!
			for(var/obj/item/organ/organ in new_body.internal_organs)
				organ.apply_organ_damage(rand(20, 40), organ.maxHealth - 1)
		else
			heart.apply_organ_damage(rand(20, 40), heart.maxHealth - 1)
	else
		brain.apply_organ_damage(rand(20, 40), HOLOPARA_MAX_BRAIN_DAMAGE)
	// straight to stamcrit with you!!
	new_body.take_overall_damage(stamina = rand(new_body.maxHealth * 1.1, new_body.maxHealth * 1.5), updating_health = TRUE)
	if(new_body.confused < 120)
		new_body.confused = 120
	to_chat(owner, span_userdanger("The process of moving your mind and its manifestations to a new body greatly strains both your mind and body!"))

/**
 * Handles the mind joining an antag HUD, adding their antag HUD to all of their holoparasites.
 */
/datum/holoparasite_holder/proc/on_join_antag_hud()
	SIGNAL_HANDLER
	if(!owner.antag_hud?.self_visible)
		return
	current_antag_hud = owner.antag_hud
	current_antag_hud_icon_state = owner.antag_hud_icon_state
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
		current_antag_hud.join_hud(holopara)
		set_antag_hud(holopara, current_antag_hud_icon_state)

/**
 * Handles the mind leaving an antag HUD, removing their antag HUD from all of their holoparasites.
 */
/datum/holoparasite_holder/proc/on_leave_antag_hud(datum/mind/_source, datum/atom_hud/antag/hud)
	SIGNAL_HANDLER
	if(hud != current_antag_hud)
		return
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
		hud.leave_hud(holopara)
		set_antag_hud(holopara, null)
	current_antag_hud = null
	current_antag_hud_icon_state = null

/**
 * Handles the owner logging in, so we can tell them about the holopara telepathy saymode.
 */
/datum/holoparasite_holder/proc/on_login(mob/living/source)
	SIGNAL_HANDLER
	var/holopara_amt = length(holoparasites)
	if(!holopara_amt)
		return
	to_chat(source, span_bigholoparasite("You can use :[MODE_KEY_HOLOPARASITE] or .[MODE_KEY_HOLOPARASITE] to privately communicate with your holoparasite[holopara_amt > 1 ? "s" : ""]!"))

/**
 * Handles the owner's body dying, which usually results in them being dusted
 * (unless they are in stasis, in which case their death will be delayed until they exit stasis, or they have the NODEATH trait, in which case they will not die at all)
 *
 * Arguments
 * * source: The owner's body.
 * * gibbed: TRUE if the owner's body was gibbed, FALSE otherwise.
 * * already_dead: TRUE if the owner's body was already dead, FALSE otherwise.
 */
/datum/holoparasite_holder/proc/on_body_death(mob/living/source, gibbed, already_dead)
	SIGNAL_HANDLER
	if(!death_two_electric_boogaloo || !is_active() || HAS_TRAIT(source, TRAIT_NODEATH))
		return
	if(IS_IN_STASIS(source))
		// Your disintegration is delayed... for now.
		for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
			if(holopara.stat == DEAD)
				continue
			holopara.death()
	else
		death_of_the_author(source, already_dead)

/datum/holoparasite_holder/proc/get_monitor(mob/living/body, create = TRUE)
	body = body || owner.current
	if(!istype(body))
		return
	if(QDELETED(monitor_holder))
		if(!create)
			return
		if(team_monitor)
			team_monitor.hide_hud(body)
			QDEL_NULL(team_monitor)
		monitor_holder = new(body)
		. = team_monitor = monitor_holder.AddComponent(/datum/component/team_monitor, REF(src))
	else
		monitor_holder.forceMove(body)
		. = team_monitor = monitor_holder.LoadComponent(/datum/component/team_monitor, REF(src))

/datum/holoparasite_holder/proc/remove_all_tracking_huds()
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
		holopara.tracking_beacon.toggle_visibility(FALSE)
		holopara.tracking_beacon.remove_from_huds()
	toggle_monitor_hud(FALSE)

/datum/holoparasite_holder/proc/toggle_monitor_hud(new_status, mob/living/body)
	body = body || owner.current
	if(!istype(body) || QDELING(body))
		return
	var/datum/component/team_monitor/team_monitor = get_monitor(body, FALSE)
	team_monitor?.toggle_hud(new_status, body)

/datum/holoparasite_holder/proc/reset_monitor_hud(mob/living/body)
	body = body || owner.current
	if(!istype(body) || QDELING(body))
		return
	var/datum/component/team_monitor/team_monitor = get_monitor(body)
	team_monitor.toggle_hud(FALSE, body)
	team_monitor.get_matching_beacons()
	team_monitor.toggle_hud(TRUE, body)

/**
 * Handles the owner's body being revived, which will prevent a delayed death from occuring.
 */
/datum/holoparasite_holder/proc/on_body_revive(mob/living/body)
	SIGNAL_HANDLER
	stop_delayed_death()
	dying = FALSE
	var/datum/component/team_monitor/team_monitor = get_monitor(body)
	team_monitor.show_hud(body)
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
		holopara.revive()

/**
 * Handles stopping delayed death whenever the owner enters stasis.
 */
/datum/holoparasite_holder/proc/on_enter_stasis()
	SIGNAL_HANDLER
	stop_delayed_death()

/**
 * Handles starting delayed death whenever the owner exits stasis.
 *
 * Arguments
 * * source: The owner's body.
 */
/datum/holoparasite_holder/proc/on_exit_stasis(mob/living/source)
	SIGNAL_HANDLER
	start_delayed_death(source)

/**
 * Start the countdown until the owner has a delayed death (for now, this is only used if they die while in stasis)
 *
 * Arguments
 * * body: The body to start the delayed death for.
 */
/datum/holoparasite_holder/proc/start_delayed_death(mob/living/body)
	if(!is_active())
		return
	stop_delayed_death()
	if(!death_two_electric_boogaloo)
		return
	if(body.stat != DEAD || HAS_TRAIT(body, TRAIT_NODEATH))
		return
	delayed_death_timer_id = addtimer(CALLBACK(src, PROC_REF(delayed_death), body), HOLOPARA_DELAYED_DEATH_TIME, TIMER_UNIQUE|TIMER_STOPPABLE)

/**
 * Stop the timer for the delayed death, used if they are revived or re-enter stasis before the timer runs out.
 */
/datum/holoparasite_holder/proc/stop_delayed_death()
	if(!delayed_death_timer_id)
		return
	deltimer(delayed_death_timer_id)
	delayed_death_timer_id = null

/**
 * Handle delayed death.
 * This is just a separate proc for blackbox reasons.
 *
 * Arguments:
 * * body: The body to disintegrate.
 */
/datum/holoparasite_holder/proc/delayed_death(mob/living/body)
	SSblackbox.record_feedback("amount", "holoparasite_delayed_death", 1)
	death_of_the_author(body, already_dead = TRUE)

/**
 * Handles dusting the owner whenever they die with holoparasites.
 * Now with extra traumatizing death messages!
 *
 * Arguments:
 * * body: The body to disintegrate.
 * * already_dead: TRUE if the body was already dead, FALSE otherwise.
 */
/datum/holoparasite_holder/proc/death_of_the_author(mob/living/body, already_dead = FALSE)
	if(!is_active() || dying || !death_two_electric_boogaloo)
		return
	dying = TRUE
	remove_all_tracking_huds()
	if(!QDELETED(team_monitor))
		team_monitor.hide_hud(body)
		team_monitor.ClearFromParent()
		QDEL_NULL(team_monitor)
	if(!QDELETED(monitor_holder))
		QDEL_NULL(monitor_holder)
	to_chat(body, span_userdanger("As your life fades away, you feel your body begin to crumple into dust, no longer able to sustain the manifestation[length(holoparasites) > 1 ? "s" : ""] of [english_holoparasite_list()]!"))
	if(!already_dead)
		if(ishuman(body))
			var/mob/living/carbon/human/human_body = body
			var/scream_sound = human_body?.dna?.species?.get_scream_sound(human_body)
			if(scream_sound)
				playsound(human_body, scream_sound, vol = 100, vary = TRUE, frequency = 0.5)
		body.visible_message(span_danger("[span_name("[body]")] lets out a pained, agonizing wail, [body.p_their()] expression consumed with fear, as [body.p_their()] body rapidly crumbles to dust!"), blind_message = "<i>You hear a pained, agonizing wail...</i>")
		var/traumatized = 0
		for(var/mob/living/viewer in viewers(world.view, body))
			if(viewer == body || (viewer in holoparasites) || viewer.is_blind())
				continue
			SEND_SIGNAL(viewer, COMSIG_ADD_MOOD_EVENT, "saw_holopara_death", /datum/mood_event/saw_holopara_death, body.real_name || body.name)
			traumatized++
		SSblackbox.record_feedback("tally", "holoparasite_traumatized_count", 1, traumatized)
	playsound(body, 'sound/effects/curseattack.ogg', vol = 75, vary = TRUE, frequency = 0.5)
	body.dust(drop_items = TRUE)
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
		if(holopara.stat == DEAD)
			continue
		if(holopara.is_manifested())
			playsound(holopara, 'sound/effects/curseattack.ogg', vol = 50, vary = TRUE, frequency = 0.5)
		holopara.death()
	stop_delayed_death()

/**
 * Returns an english list of all the holoparasite's names.
 *
 * Arguments
 * * colored: TRUE if the holoparasite names should be colored, FALSE if not.
 */
/datum/holoparasite_holder/proc/english_holoparasite_list(colored = TRUE)
	var/list/names = list()
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites)
		names += colored ? holopara.color_name : holopara.real_name
	return english_list(names)
