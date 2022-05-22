/datum/plant_gene/trait/stinging
	name = "Hypodermic Prickles"

/datum/plant_gene/trait/stinging/on_slip(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	if(!isliving(target) || !G.reagents || !G.reagents.total_volume)
		return
	var/mob/living/L = target
	if(prick(G, L))
		if(L.ckey != G.fingerprintslast)
			var/turf/T = get_turf(L)
			L.investigate_log("has slipped on plant at [AREACOORD(T)] injecting him with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
			log_combat(L, G, "slipped on the", null, "injecting him with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].")

/datum/plant_gene/trait/stinging/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	if(!isliving(target) || !G.reagents || !G.reagents.total_volume)
		return
	var/mob/living/L = target
	if(prick(G, L))
		if(L.ckey != G.fingerprintslast)			//what's the point of logging someone attacking himself
			var/turf/T = get_turf(L)
			log_combat(G.thrownby, L, "hit", G, "at [AREACOORD(T)] injecting them with [G.reagents.log_list()]")
			L.investigate_log("[L] has been prickled by a plant at [AREACOORD(T)] injecting them with [G.reagents.log_list()]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)

/datum/plant_gene/trait/stinging/proc/prick(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L)
	if(!L.reagents && !L.can_inject(null, 0))
		return FALSE

	var/injecting_amount = max(1, G.seed.potency*0.2) // Minimum of 1, max of 20
	var/fraction = min(injecting_amount/G.reagents.total_volume, 1)
	G.reagents.reaction(L, INJECT, fraction)
	G.reagents.trans_to(L, injecting_amount)
	to_chat(L, "<span class='danger'>You are pricked by [G]!</span>")
	return TRUE
