/**
 * #Chemical Reaction
 *
 * Datum that makes the magic between reagents happen.
 *
 * Chemical reactions is a class that is instantiated and stored in a global list 'chemical_reactions_list'
 */
/datum/chemical_reaction
	var/name = null
	var/id = null
	///Results of the chemical reactions
	var/list/results = list()
	///Required chemicals that are USED in the reaction
	var/list/required_reagents = list()
	///Required chemicals that must be present in the container but are not USED.
	var/list/required_catalysts = list()
	var/list/hints = list()

	/// If required_container will check for the exact type, or will also accept subtypes
	var/required_container_accepts_subtypes = FALSE
	/// If required_container_accepts_subtypes is FALSE, the exact type of what container this reaction can take place in. Otherwise, what type including subtypes are acceptable.
	var/atom/required_container
	var/required_other = FALSE

	///Determines if a chemical reaction can occur inside a mob
	var/mob_react = TRUE
	///The message shown to nearby people upon mixing, if applicable
	var/mix_message = "The solution begins to bubble."
	///The sound played upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg'

	/// Set to TRUE if you want the recipe to only react when it's BELOW the required temp.
	var/is_cold_recipe = FALSE
	///Required temperature for the reaction to begin, for fermimechanics it defines the lower area of bell curve for determining heat based rate reactions, aka the minimum
	var/required_temp = 0
	/// Upper end for above (i.e. the end of the curve section defined by temp_exponent_factor)
	var/optimal_temp = 500
	/// Temperature at which reaction explodes - If any reaction is this hot, it explodes!
	var/overheat_temp = 900
	/// How sharp the temperature exponential curve is (to the power of value)
	var/temp_exponent_factor = 2
	/// How much the temperature changes per unit of chem used. without REACTION_HEAT_ARBITARY flag the rate of change depends on the holder heat capacity else results are more accurate
	var/thermic_constant = 0
	/// Optimal/max rate possible if all conditions are perfect
	var/rate_up_lim = 30
	/// bitflags for clear conversions; see code/__DEFINES/reagents.dm
	var/reaction_flags = REACTION_INSTANT
	///Tagging vars
	///A bitflag var for tagging reagents for the reagent loopup functon
	var/reaction_tags = NONE

///REACTION PROCS

/**
 * Checks if this reaction can occur.
 */
/datum/chemical_reaction/proc/pre_reaction_other_checks(datum/reagents/holder)
	return TRUE

/**
 * Shit that happens on reaction
 * Only procs at the START of a reaction
 * use reaction_step() for each step of a reaction
 * or reaction_finish() when the reaction stops
 * If reaction_flags & REACTION_INSTANT then this is the only proc that is called.
 *
 * Proc where the additional magic happens.
 * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * created_volume - volume created when this is mixed. look at 'var/list/results'.
 */
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

/**
 * Stuff that occurs in the middle of a reaction
 * Only procs DURING a reaction
 * If reaction_flags & REACTION_INSTANT then this isn't called
 * returning END_REACTION will END the reaction
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * reaction - the equilibrium reaction holder that is reaction is processed within - use this to edit delta_t
 * * step_reaction_vol - volume created per step
 *
 * Outputs:
 * * returning END_REACTION will end the associated reaction - flagging it for deletion and preventing any reaction in that timestep from happening. Make sure to set the vars in the holder to one that can't start it from starting up again.
 */
/datum/chemical_reaction/proc/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, step_reaction_vol)
	return

/**
 * Stuff that should happen at the end of the reaction.
 *
 * Proc where the additional magic happens.
 * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * react_volume - volume created across the whole reaction
 */
/datum/chemical_reaction/proc/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	return

/**
 * Occurs when a reation is overheated (i.e. past its overheat_temp)
 * Will be called every tick in the reaction that it is overheated
 * If you want this to be a once only proc (i.e. the reaction is stopped after) set equilibrium.to_delete = TRUE
 * The above is useful if you're writing an explosion
 * By default the parent proc will reduce the final yield slightly. If you don't want that don't add ..()
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * equilibrium - the equilibrium datum that contains the equilibrium reaction properties and methods
 * * step_volume_added - how much product (across all products) was added for this single step
 */
/datum/chemical_reaction/proc/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(!results[reagent.type])
			continue
		reagent.volume *= 0.98 //Slowly lower yield per tick
	holder.update_total()

/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = FACTION_CHEMICAL_SUMMON, random = TRUE)
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "A [reaction_name] reaction has occurred in [ADMIN_VERBOSEJMP(T)]"
		message += " (<A HREF='BYOND://?_src_=vars;Vars=[REF(A)]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom)))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/spawned_mob
			if(random)
				spawned_mob = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				spawned_mob = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			spawned_mob.faction |= mob_faction
			if(prob(50))
				for(var/j in 1 to rand(1, 3))
					step(spawned_mob, pick(NORTH,SOUTH,EAST,WEST))

///Simulates a vortex that moves nearby movable atoms towards or away from the turf T. Range also determines the strength of the effect. High values cause nearby objects to be thrown.
/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(X.anchored)
			continue
		if(iseffect(X) || iscameramob(X) || isdead(X))
			continue
		var/distance = get_dist(X, T)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
			if(setting_type)
				var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
				X.throw_at(throw_target, moving_power, 1)
			else
				X.throw_at(T, moving_power, 1)
		else
			if(setting_type)
				if(step_away(X, T) && moving_power > 1) //Can happen twice at most. So this is fine.
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_away), X, T), 2)
			else
				if(step_towards(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_towards), X, T), 2)
