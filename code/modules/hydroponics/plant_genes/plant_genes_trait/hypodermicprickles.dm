/datum/plant_gene/trait/stinging
	name = "Hypodermic Prickles"
	desc = "This makes your plant injecting its contents into a person when they're thrown to them."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	trait_id = "chemmix"
	research_needed = 1

/datum/plant_gene/trait/stinging/on_slip(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	before_process(G, target, TRUE)

/datum/plant_gene/trait/stinging/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	before_process(G, target)

/datum/plant_gene/trait/stinging/on_attack(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	before_process(G, target)

/datum/plant_gene/trait/stinging/proc/before_process(obj/item/reagent_containers/food/snacks/grown/G, atom/target, slip=FALSE)
	if(!isliving(target) || !G.reagents || !G.reagents.total_volume)
		return
	var/mob/living/L = target
	if(prick(G, L))
		if(L.ckey != G.fingerprintslast)			//what's the point of logging someone attacking himself
			ADD_TRAIT(L, TRAIT_BOTANY_IMMUNE_INJECT, PLANT_TRAIT)
			addtimer(CALLBACK(src, /datum/plant_gene/trait/stinging.proc/handle_mob_trait, L), BTNY_CFG_TRAIT_INJECT_IMMUME_TIME)
			//immume for inject for 30s
			var/turf/T = get_turf(L)
			if(slip)
				L.investigate_log("has slipped on plant at [AREACOORD(T)] injecting him with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_combat(L, G, "slipped on the", null, "injecting him with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].")
			else
				L.investigate_log("[L] has been prickled by a plant at [AREACOORD(T)] injecting them with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_combat(G.thrownby, L, "hit", G, "at [AREACOORD(T)] injecting them with [G.reagents.log_list()]")

/datum/plant_gene/trait/stinging/proc/prick(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L)
	if(!L.reagents)
		visible_message(L, "<span class='notice'>[G] has been dusted.</span>","<span class='italics'>You hear dusting.</span>")
		qdel(G)
		return FALSE
	if(!L.can_inject(null, 0))
		return FALSE
	if(HAS_TRAIT(L, TRAIT_BOTANY_IMMUNE_INJECT))
		return FALSE
	var/potentpower = max(round(G.seed.potency/10),1)
	for(var/datum/reagent/R in G.reagents.reagent_list)
		var/amt = R.volume > R.metabolization_rate*potentpower ? R.metabolization_rate*potentpower R.volume
		if(R.metabolization_rate > 100)
			amt = R.volume < 5 ? R.volume : 5
		G.reagents.reaction(L, INJECT)
		G.reagents.trans_id_to(L, R, amt)

	to_chat(L, "<span class='danger'>You are pricked by [G]!</span>")
	return TRUE

/datum/plant_gene/trait/stinging/proc/handle_mob_trait(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_BOTANY_IMMUNE_INJECT, PLANT_TRAIT)



// Seprated chemicals
/datum/plant_gene/trait/noreact
	name = "Separated Chemicals"
	desc = "Chemicals don't mix until it's used."
	plusdesc = "Note: not compatible with Hypodermic Prickles."
	trait_id = "chemmix"
	plant_gene_flags = NONE
	research_needed = -1

/datum/plant_gene/trait/noreact/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	ENABLE_BITFIELD(G.reagents.flags, NO_REACT)

/datum/plant_gene/trait/noreact/on_squashreact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	DISABLE_BITFIELD(G.reagents.flags, NO_REACT)
	G.reagents.handle_reactions()
