/datum/plant_gene/trait/stinging
	name = "Hypodermic Prickles"
	desc = "This makes your plant injecting its contents into a person when they're thrown to them."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	trait_id = "chemmix"
	research_needed = 1
	var/selfdesctruct = FALSE

/* <Behavior table>
	 <A type>
		[on_squash] ...
		[on_aftersquash] ...

	 <B type>
		[on_slip] activate the effect.
		[on_attack] activate the effect.
		[on_throw_impact] activate the effect.

	 <C type>
		[on_attackby] ...
		[on_consume] ...
		[on_grow] ...
		[on_new_plant] ...
		[on_new_seed] ...
		[on_removal] ...
 */

/datum/plant_gene/trait/stinging/on_slip(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	return activate_effect(G, target, p_method)
	// return value determines if the plant should be destroyed

/datum/plant_gene/trait/stinging/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	return activate_effect(G, target, p_method)

/datum/plant_gene/trait/stinging/on_attack(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	return activate_effect(G, target, p_method)

/datum/plant_gene/trait/stinging/proc/activate_effect(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	. = FALSE
	if(!isliving(target))
		return FALSE
	var/turf/T = get_turf(target)
	var/mob/living/L = target
	if(prick(G, L, p_method))
		ADD_TRAIT(L, TRAIT_BOTANY_IMMUNE_INJECT, TRAIT_GENERIC)
		addtimer(CALLBACK(src, /datum/plant_gene/trait/stinging.proc/handle_mob_trait, L), BTNY_CFG_TRAIT_INJECT_IMMUME_TIME)
		//immume for inject for 30s

		if(L.ckey != G.fingerprintslast)
			if(p_method & PLANT_ACTIVATED_SLIP)
				L.investigate_log("been slipped on plant([G]) at [AREACOORD(T)], being injected him with [G.reagents.log_list()]. Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [key_name(L)] has slipped on a plant([G]) at [AREACOORD(T)], being injected with [G.reagents.log_list()]. Last pickup ckey: [G.fingerprintslast].")
				log_combat(L, G, "slipped on the", G, ", being injected with [G.reagents.log_list()]. Last pickup ckey: [G.fingerprintslast]. #botany.")
			else if(p_method & PLANT_ACTIVATED_ATTACK)
				L.investigate_log("been attacked by a plant at [AREACOORD(T)], being injected them with [G.reagents.log_list()]. Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [key_name(L)] has been attacked by a plant([G]) at [AREACOORD(T)], being injected with [G.reagents.log_list()]. Last pickup ckey: [G.fingerprintslast].")
			else if(p_method & PLANT_ACTIVATED_THROW)
				var/mob/thrown_by = G.thrownby?.resolve()
				L.investigate_log("been prickled by a plant at [AREACOORD(T)], being injected with [G.reagents.log_list()] from being hit by a THROWN plant. Thrower: [(thrown_by || "(unknown error)")]. Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [(thrown_by || "(unknown error)")] has thrown to [key_name(L)] by a plant([G]) at [AREACOORD(T)], injecting them with [G.reagents.log_list()]. Last pickup ckey: [G.fingerprintslast].")
			else
				L.investigate_log("been prickled by a plant at [AREACOORD(T)], being injected with [G.reagents.log_list()], but the attack method is unknown. Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [key_name(L)] has been prickled by a plant([G]) at [AREACOORD(T)], being injected with [G.reagents.log_list()], but the attack method is unknown. Last pickup ckey: [G.fingerprintslast].")
				CRASH("Plant trait is activated by unknown method. Method: [p_method]")


	if(selfdesctruct)
		selfdesctruct = FALSE //This datum exists to every plant. You need to turn off.
		return TRUE


/datum/plant_gene/trait/stinging/proc/prick(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L, p_method)
	if(reagent_check(G, L))
		return FALSE
	if(!L.reagents && !L.can_inject(null, 0))
		return FALSE
	if(HAS_TRAIT(L, TRAIT_BOTANY_IMMUNE_INJECT))
		return FALSE

	var/potentpower = max(round(G.seed.potency/10),1)
	if(!(p_method & PLANT_ACTIVATED_SQUASH)) // if not squash trait, not effective.
		potentpower = round(potentpower/2)
	var/avaiable_chem_size = 8
	for(var/datum/reagent/R in G.reagents.reagent_list)
		var/amt = R.volume > R.metabolization_rate*potentpower ? R.metabolization_rate*potentpower : R.volume
		if(R.metabolization_rate >= 5)
			amt = R.volume < 5 ? R.volume : 5
		G.reagents.reaction(L, INJECT)
		G.reagents.trans_id_to(L, R, amt)
		if(!avaiable_chem_size)
			break

	to_chat(L, "<span class='danger'>You are pricked by [G]!</span>")
	reagent_check(G, L)
	return TRUE

/datum/plant_gene/trait/stinging/proc/handle_mob_trait(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_BOTANY_IMMUNE_INJECT, TRAIT_GENERIC)

/datum/plant_gene/trait/stinging/proc/reagent_check(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L)
	if(!G.reagents || !G.reagents.total_volume)
		L.visible_message("<span class='notice'>[G] has been dusted.</span>","<span class='italics'>You hear dusting.</span>")
		selfdesctruct = TRUE
		return TRUE
	return FALSE

// ------------------------------------------------------------
// Seprated chemicals
/datum/plant_gene/trait/noreact
	name = "Separated Chemicals"
	desc = "Chemicals don't mix until it's used."
	plusdesc = "Note: not compatible with Hypodermic Prickles."
	trait_id = "chemmix"
	plant_gene_flags = NONE
	research_needed = -1

/* <Behavior table>
	 <A type>
		[on_squash] ...
		[on_aftersquash] after squash, remove the reagent flags.

	 <B type>
		[on_slip] ...
		[on_attack] ...
		[on_throw_impact] ...

	 <C type>
		[on_attackby] ...
		[on_consume] ...
		[on_grow] ...
		[on_new_plant] makes the reagent flags NO_REACT
		[on_new_seed] ...
		[on_removal] ...
 */

/datum/plant_gene/trait/noreact/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	ENABLE_BITFIELD(G.reagents.flags, NO_REACT)

/datum/plant_gene/trait/noreact/on_aftersquash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	DISABLE_BITFIELD(G.reagents.flags, NO_REACT)
	G.reagents.handle_reactions()
