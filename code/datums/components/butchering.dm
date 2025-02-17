/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed = 8 SECONDS
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness = 100
	/// Percentage increase to bonus item chance
	var/bonus_modifier = 0
	/// Sound played when butchering
	var/butcher_sound = 'sound/weapons/slice.ogg'
	/// Whether or not this component can be used to butcher currently. Used to temporarily disable butchering
	var/butchering_enabled = TRUE
	/// Whether or not this component is compatible with blunt tools.
	var/can_be_blunt = FALSE

/datum/component/butchering/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled, _can_be_blunt)
	if(_speed)
		speed = _speed
	if(_effectiveness)
		effectiveness = _effectiveness
	if(_bonus_modifier)
		bonus_modifier = _bonus_modifier
	if(_butcher_sound)
		butcher_sound = _butcher_sound
	if(disabled)
		butchering_enabled = FALSE
	if(_can_be_blunt)
		can_be_blunt = _can_be_blunt
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(onItemAttack))

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	if(!user.combat_mode)
		return
	if(M.stat == DEAD && (M.butcher_results || M.guaranteed_butcher_results)) //can we butcher it?
		if(butchering_enabled && (can_be_blunt || source.is_sharp()))
			INVOKE_ASYNC(src, PROC_REF(startButcher), source, M, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(M) && source.force && source.is_sharp())
		var/mob/living/carbon/human/H = M
		var/neckslice_conditions = (H.health <= H.crit_threshold || user.grab_state >= GRAB_NECK || H.IsSleeping())
		if(neckslice_conditions && user.pulling == H && user.is_zone_selected(BODY_ZONE_HEAD) && user.grab_state >= GRAB_AGGRESSIVE) // Only sleeping, neck grabbed, or crit, can be sliced.
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, span_warning("You don't want to harm other living beings!"))
				return COMPONENT_CANCEL_ATTACK_CHAIN

			if(H.has_status_effect(/datum/status_effect/neck_slice))
				user.show_message(span_danger("[H]'s neck has already been already cut, you can't make the bleeding any worse!"), 1, span_danger("Their neck has already been already cut, you can't make the bleeding any worse!"))
				return

			INVOKE_ASYNC(src, PROC_REF(startNeckSlice), source, H, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/M, mob/living/user)
	to_chat(user, span_notice("You begin to butcher [M]..."))
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_after(user, speed, M) && M.Adjacent(source))
		Butcher(user, M)

/datum/component/butchering/proc/startNeckSlice(obj/item/source, mob/living/carbon/human/H, mob/living/user)
	if(DOING_INTERACTION_WITH_TARGET(user, H))
		to_chat(user, span_warning("You're already interacting with [H]!"))
		return

	user.visible_message(span_danger("[user] is slitting [H]'s throat!"), \
					span_danger("You start slicing [H]'s throat!"), \
					span_hear("You hear a cutting noise!"))
	H.show_message(span_userdanger("Your throat is being slit by [user]!"), 1, \
					span_userdanger("Something is cutting into your neck!"), NONE)
	log_combat(user, H, "attempted throat slitting", source)

	playsound(H.loc, butcher_sound, 50, TRUE, -1)
	var/item_force = source.force
	if(!item_force) //Division by 0 protection
		item_force = 1
	if(do_after(user, clamp(500 / item_force, 30, 100), H) && H.Adjacent(source))
		if(H.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message(span_danger("[H]'s neck has already been already cut, you can't make the bleeding any worse!"), 1, span_danger("Their neck has already been already cut, you can't make the bleeding any worse!"))
			return

		H.visible_message(span_danger("[user] slits [H]'s throat!"), \
					span_userdanger("[user] slits your throat..."))
		H.apply_damage(item_force, BRUTE, BODY_ZONE_HEAD)
		H.add_bleeding(BLEED_CRITICAL)
		H.apply_status_effect(/datum/status_effect/neck_slice)

/datum/component/butchering/proc/Butcher(mob/living/butcher, mob/living/meat)
	var/turf/T = meat.drop_location()
	var/final_effectiveness = effectiveness - meat.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance
	for(var/V in meat.butcher_results)
		var/obj/bones = V
		var/amount = meat.butcher_results[bones]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, span_warning("You fail to harvest some of the [initial(bones.name)] from [meat]."))
			else if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, span_info("You harvest some extra [initial(bones.name)] from [meat]!"))
				for(var/i in 1 to 2)
					new bones (T)
			else
				new bones (T)
		meat.butcher_results.Remove(bones) //in case you want to, say, have it drop its results on gib
	for(var/V in meat.guaranteed_butcher_results)
		var/obj/sinew = V
		var/amount = meat.guaranteed_butcher_results[sinew]
		for(var/i in 1 to amount)
			new sinew (T)
		meat.guaranteed_butcher_results.Remove(sinew)
	if(butcher)
		butcher.visible_message(span_notice("[butcher] butchers [meat]."), \
								span_notice("You butcher [meat]."))
	ButcherEffects(meat)
	meat.harvest(butcher)
	meat.log_message("has been butchered by [key_name(butcher)]", LOG_ATTACK)
	meat.investigate_log("was gibbed via butchering", INVESTIGATE_DEATHS)
	meat.gib(FALSE, FALSE, TRUE)

/datum/component/butchering/proc/ButcherEffects(mob/living/meat) //extra effects called on butchering, override this via subtypes
	return

///Special snowflake component only used for the recycler.
/datum/component/butchering/recycler

/datum/component/butchering/recycler/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled, _can_be_blunt)
	if(!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/butchering/recycler/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return
	var/mob/living/victim = arrived
	var/obj/machinery/recycler/eater = parent
	if(eater.safety_mode || (eater.machine_stat & (BROKEN|NOPOWER))) //I'm so sorry.
		return
	if(victim.stat == DEAD && (victim.butcher_results || victim.guaranteed_butcher_results))
		Butcher(parent, victim)
