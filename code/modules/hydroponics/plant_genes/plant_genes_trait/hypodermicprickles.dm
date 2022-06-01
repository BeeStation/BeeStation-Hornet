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
			var/turf/T = get_turf(L)
			if(slip)
				L.investigate_log("has slipped on plant at [AREACOORD(T)] injecting him with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_combat(L, G, "slipped on the", null, "injecting him with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].")
			else
				log_combat(G.thrownby, L, "hit", G, "at [AREACOORD(T)] injecting them with [G.reagents.log_list()]")
				L.investigate_log("[L] has been prickled by a plant at [AREACOORD(T)] injecting them with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)

/datum/plant_gene/trait/stinging/proc/prick(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L)
	if(!L.reagents && !L.can_inject(null, 0))
		return FALSE

	var/injecting_amount = CLAMP(G.seed.potency*0.2, 1, 5) // Minimum of 1, max of 5
	var/fraction = min(injecting_amount/G.reagents.total_volume, 1)
	G.reagents.reaction(L, INJECT, fraction)
	G.reagents.trans_to(L, injecting_amount)
	to_chat(L, "<span class='danger'>You are pricked by [G]!</span>")
	return TRUE
