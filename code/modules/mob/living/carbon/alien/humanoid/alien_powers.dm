/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/
/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/


/datum/action/alien
	name = "Alien Power"
	background_icon_state = "bg_alien"
	button_icon = 'icons/hud/actions/actions_xeno.dmi'
	button_icon_state = null
	check_flags = AB_CHECK_CONSCIOUS
	/// How much plasma this action uses.
	var/plasma_cost = 0

/datum/action/alien/is_available()
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.getPlasma() < plasma_cost)
		return FALSE

	return TRUE

/datum/action/alien/pre_activate(mob/user, atom/target)
	// Parent calls Activate(), so if parent returns TRUE,
	// it means the activation happened successfuly by this point
	. = ..()
	if(!.)
		return FALSE
	// Xeno actions like "evolve" may result in our action (or our alien) being deleted
	// In that case, we can just exit now as a "success"
	if(QDELETED(src) || QDELETED(owner))
		return TRUE

	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.adjustPlasma(-plasma_cost)
	// It'd be really annoying if click-to-fire actions stayed active,
	// even if our plasma amount went under the required amount.
	if(requires_target && carbon_owner.getPlasma() < plasma_cost)
		unset_click_ability(owner, refund_cooldown = FALSE)

	return TRUE

/datum/action/alien/update_stat_status(list/stat)
	stat[STAT_STATUS] = GENERATE_STAT_TEXT("PLASMA - [plasma_cost]")

/datum/action/alien/make_structure
	/// The type of structure the action makes on use
	var/obj/structure/made_structure_type

/datum/action/alien/make_structure/is_available()
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(owner.loc) || isspaceturf(owner.loc))
		return FALSE

	return TRUE

/datum/action/alien/make_structure/pre_activate(mob/user, atom/target)
	if(!check_for_duplicate())
		return FALSE

	if(!check_for_vents())
		return FALSE

	return ..()

/datum/action/alien/make_structure/on_activate(mob/user, atom/target)
	new made_structure_type(owner.loc)
	return TRUE

/// Checks if there's a duplicate structure in the owner's turf
/datum/action/alien/make_structure/proc/check_for_duplicate()
	var/obj/structure/existing_thing = locate(made_structure_type) in owner.loc
	if(existing_thing)
		to_chat(owner, ("<span class='warning'>There is already \a [existing_thing] here!</span>"))
		return FALSE

	return TRUE

/// Checks if there's an atmos machine (vent) in the owner's turf
/datum/action/alien/make_structure/proc/check_for_vents()
	var/obj/machinery/atmospherics/components/unary/atmos_thing = locate() in owner.loc
	if(atmos_thing)
		var/are_you_sure = tgui_alert(owner, "Laying eggs and shaping resin here would block access to [atmos_thing]. Do you want to continue?", "Blocking Atmospheric Component", list("Yes", "No"))
		if(are_you_sure != "Yes")
			return FALSE
		if(QDELETED(src) || QDELETED(owner) || !check_for_duplicate())
			return FALSE

	return TRUE

/datum/action/alien/make_structure/plant_weeds
	name = "Plant Weeds"
	desc = "Plants some alien weeds."
	button_icon_state = "alien_plant"
	plasma_cost = 50
	made_structure_type = /obj/structure/alien/weeds/node

/datum/action/alien/make_structure/plant_weeds/on_activate(mob/user, atom/target)
	owner.visible_message(("<span class='alienalert'>[owner] plants some alien weeds!</span>"))
	return ..()

/datum/action/alien/whisper
	name = "Whisper"
	desc = "Whisper to someone."
	button_icon_state = "alien_whisper"
	plasma_cost = 10

/datum/action/alien/whisper/on_activate(mob/user, atom/target)
	var/list/possible_recipients = list()
	for(var/mob/living/recipient in oview(owner))
		possible_recipients += recipient

	if(!length(possible_recipients))
		to_chat(owner, ("<span class='noticealien'>There's no one around to whisper to.</span>"))
		return FALSE

	var/mob/living/chosen_recipient = tgui_input_list(owner, "Select whisper recipient", "Whisper", sort_names(possible_recipients))
	if(!chosen_recipient)
		return FALSE

	var/to_whisper = tgui_input_text(owner, title = "Alien Whisper")
	if(QDELETED(chosen_recipient) || QDELETED(src) || QDELETED(owner) || !is_available() || !to_whisper)
		return FALSE
	if(chosen_recipient.can_block_magic())
		to_chat(owner, ("<span class='warning'>As you reach into [chosen_recipient]'s mind, you are stopped by a mental blockage. It seems you've been foiled.</span>"))
		return FALSE

	log_directed_talk(owner, chosen_recipient, to_whisper, LOG_SAY, tag = "alien whisper")
	to_chat(chosen_recipient, "[("<span class='noticealien'>You hear a strange, alien voice in your head...</span>")][to_whisper]")
	to_chat(owner, ("<span class='noticealien'>You said: \"[to_whisper]\" to [chosen_recipient]</span>"))
	for(var/mob/dead_mob as anything in GLOB.dead_mob_list)
		if(!isobserver(dead_mob))
			continue
		var/follow_link_user = FOLLOW_LINK(dead_mob, owner)
		var/follow_link_whispee = FOLLOW_LINK(dead_mob, chosen_recipient)
		to_chat(dead_mob, "[follow_link_user] [("<span class='name'>[owner]</span>")] [("<span class='alienalert'>Alien Whisper --> </span>")] [follow_link_whispee] [("<span class='name'>[chosen_recipient]</span>")] [("<span class='noticealien'>[to_whisper]</span>")]")

	return TRUE

/datum/action/alien/transfer
	name = "Transfer Plasma"
	desc = "Transfer Plasma to another alien."
	plasma_cost = 0
	button_icon_state = "alien_transfer"

/datum/action/alien/transfer/on_activate(mob/user, atom/target)
	var/mob/living/carbon/carbon_owner = owner
	var/list/mob/living/carbon/aliens_around = list()
	for(var/mob/living/carbon/alien in view(owner))
		if(alien.getPlasma() == -1 || alien == owner)
			continue
		aliens_around += alien

	if(!length(aliens_around))
		to_chat(owner, ("<span class='noticealien'>There are no other aliens around.</span>"))
		return FALSE

	var/mob/living/carbon/donation_target = tgui_input_list(owner, "Target to transfer to", "Plasma Donation", sort_names(aliens_around))
	if(!donation_target)
		return FALSE

	var/amount = tgui_input_number(owner, "Amount", "Transfer Plasma to [donation_target]", max_value = carbon_owner.getPlasma())
	if(QDELETED(donation_target) || QDELETED(src) || QDELETED(owner) || !is_available() || isnull(amount) || amount <= 0)
		return FALSE

	if(get_dist(owner, donation_target) > 1)
		to_chat(owner, ("<span class='noticealien'>You need to be closer!</span>"))
		return FALSE

	donation_target.adjustPlasma(amount)
	carbon_owner.adjustPlasma(-amount)

	to_chat(donation_target, ("<span class='noticealien'>[owner] has transferred [amount] plasma to you.</span>"))
	to_chat(owner, ("<span class='noticealien'>You transfer [amount] plasma to [donation_target].</span>"))
	return TRUE

/datum/action/alien/acid
	requires_target = TRUE
	unset_after_click = FALSE

/datum/action/alien/acid/corrosion
	name = "Corrosive Acid"
	desc = "Drench an object in acid, destroying it over time."
	button_icon_state = "alien_acid"
	plasma_cost = 50

/datum/action/alien/acid/corrosion/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, ("<span class='noticealien'>You prepare to vomit acid. <b>Click a target to acid it!</b></span>"))
	on_who.update_icons()

/datum/action/alien/acid/corrosion/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, ("<span class='noticealien'>You empty your corrosive acid glands.</span>"))
	on_who.update_icons()

/datum/action/alien/acid/corrosion/pre_activate(mob/user, atom/target)
	if(get_dist(owner, target) > 1)
		return FALSE

	return ..()

/datum/action/alien/acid/corrosion/on_activate(mob/user, atom/target)
	if(iscarbon(target))
		//This is blocked by virtually any clothing which is destroyed if possible, but will still do 60 damage without any.
		target.acid_act(50, 50)

	else if(!target.acid_act(200, 1000))
		to_chat(owner, ("<span class='noticealien'>You cannot dissolve this object.</span>"))
		return FALSE

	owner.visible_message(
		("<span class='alienalert'>[owner] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>"),
		("<span class='noticealien'>You vomit globs of acid over [target]. It begins to sizzle and melt.</span>"),
	)
	return TRUE

/datum/action/alien/acid/neurotoxin
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	button_icon_state = "alien_neurotoxin_0"
	plasma_cost = 50

/datum/action/alien/acid/neurotoxin/is_available()
	var/mob/living/carbon/as_carbon = owner
	if(istype(as_carbon) && as_carbon.is_mouth_covered(ITEM_SLOT_MASK))
		return FALSE
	return ..() && isturf(owner.loc)

/datum/action/alien/acid/neurotoxin/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, ("<span class='notice'>You prepare your neurotoxin gland. <B>Left-click to fire at a target!</B></span>"))

	button_icon_state = "alien_neurotoxin_1"
	update_buttons()
	on_who.update_icons()

/datum/action/alien/acid/neurotoxin/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, ("<span class='notice'>You empty your neurotoxin gland.</span>"))

	button_icon_state = "alien_neurotoxin_0"
	update_buttons()
	on_who.update_icons()

/datum/action/alien/acid/neurotoxin/InterceptClickOn(mob/living/clicker, params, atom/target)
	. = ..()
	if(!.)
		unset_click_ability(clicker, refund_cooldown = FALSE)
		return FALSE

	// We do this in InterceptClickOn() instead of Activate()
	// because we use the click parameters for aiming the projectile
	// (or something like that)
	var/turf/user_turf = clicker.loc
	var/turf/target_turf = get_step(clicker, target.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(target_turf))
		return FALSE

	var/modifiers = params2list(params)
	clicker.visible_message(
		("<span class='danger'>[clicker] spits neurotoxin!</span>"),
		("<span class='alienalert'>You spit neurotoxin.</span>"),
	)
	var/obj/projectile/bullet/neurotoxin/neurotoxin = new /obj/projectile/bullet/neurotoxin(clicker.loc)
	neurotoxin.preparePixelProjectile(target, clicker, modifiers)
	neurotoxin.firer = clicker
	neurotoxin.fire()
	clicker.newtonian_move(get_dir(target_turf, user_turf))
	return TRUE

// Has to return TRUE, otherwise is skipped.
/datum/action/alien/acid/neurotoxin/on_activate(mob/user, atom/target)
	return TRUE

/datum/action/alien/make_structure/resin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin."
	button_icon_state = "alien_resin"
	plasma_cost = 55
	/// A list of all structures we can make.
	var/static/list/structures = list(
		"resin wall" = /obj/structure/alien/resin/wall,
		"resin membrane" = /obj/structure/alien/resin/membrane,
		"resin nest" = /obj/structure/bed/nest,
	)

// Snowflake to check for multiple types of alien resin structures
/datum/action/alien/make_structure/resin/check_for_duplicate()
	for(var/blocker_name in structures)
		var/obj/structure/blocker_type = structures[blocker_name]
		if(locate(blocker_type) in owner.loc)
			to_chat(owner, ("<span class='warning'>There is already a resin structure there!</span>"))
			return FALSE

	return TRUE

/datum/action/alien/make_structure/resin/on_activate(mob/user, atom/target)
	var/choice = tgui_input_list(owner, "Select a shape to build", "Resin building", structures)
	if(isnull(choice) || QDELETED(src) || QDELETED(owner) || !check_for_duplicate() || !is_available())
		return FALSE

	var/obj/structure/choice_path = structures[choice]
	if(!ispath(choice_path))
		return FALSE

	owner.visible_message(
		("<span class='notice'>[owner] vomits up a thick purple substance and begins to shape it.</span>"),
		("<span class='notice'>You shape a [choice] out of resin.</span>"),
	)

	new choice_path(owner.loc)
	return TRUE

/datum/action/alien/sneak
	name = "Sneak"
	desc = "Blend into the shadows to stalk your prey."
	button_icon_state = "alien_sneak"
	/// The alpha we go to when sneaking.
	var/sneak_alpha = 75

/datum/action/alien/sneak/Remove(mob/living/remove_from)
	if(HAS_TRAIT(remove_from, TRAIT_ALIEN_SNEAK))
		remove_from.alpha = initial(remove_from.alpha)
		REMOVE_TRAIT(remove_from, TRAIT_ALIEN_SNEAK, name)

	return ..()

/datum/action/alien/sneak/on_activate(mob/user, atom/target)
	if(HAS_TRAIT(owner, TRAIT_ALIEN_SNEAK))
		// It's safest to go to the initial alpha of the mob.
		// Otherwise we get permanent invisbility exploits.
		owner.alpha = initial(owner.alpha)
		to_chat(owner, span_noticealien("You reveal yourself!"))
		REMOVE_TRAIT(owner, TRAIT_ALIEN_SNEAK, name)

	else
		owner.alpha = sneak_alpha
		to_chat(owner, span_noticealien("You blend into the shadows..."))
		ADD_TRAIT(owner, TRAIT_ALIEN_SNEAK, name)

	return TRUE

/// Gets the plasma level of this carbon's plasma vessel, or -1 if they don't have one
/mob/living/carbon/proc/getPlasma()
	var/obj/item/organ/alien/plasmavessel/vessel = get_organ_by_type(/obj/item/organ/alien/plasmavessel)
	if(!vessel)
		return -1
	return vessel.stored_plasma

/// Adjusts the plasma level of the carbon's plasma vessel if they have one
/mob/living/carbon/proc/adjustPlasma(amount)
	var/obj/item/organ/alien/plasmavessel/vessel = get_organ_by_type(/obj/item/organ/alien/plasmavessel)
	if(!vessel)
		return FALSE
	vessel.stored_plasma = max(vessel.stored_plasma + amount,0)
	vessel.stored_plasma = min(vessel.stored_plasma, vessel.max_plasma) //upper limit of max_plasma, lower limit of 0
	for(var/datum/action/alien/ability in actions)
		ability.update_buttons()
	return TRUE

/mob/living/carbon/alien/adjustPlasma(amount)
	. = ..()
	updatePlasmaDisplay()

//For alien evolution/promotion/queen finder procs. Checks for an active alien of that type
/proc/get_alien_type(alienpath)
	for(var/mob/living/carbon/alien/humanoid/A in GLOB.alive_mob_list)
		if(!istype(A, alienpath))
			continue
		if(!A.key || A.stat == DEAD) //Only living aliens with a ckey are valid.
			continue
		return A
	return FALSE
