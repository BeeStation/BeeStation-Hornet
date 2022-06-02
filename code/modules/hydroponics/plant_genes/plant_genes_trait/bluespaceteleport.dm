/datum/plant_gene/trait/teleport
	// Makes plant teleport people when squashed or slipped on.
	// Teleport radius is calculated as max(round(potency*rate), 1)
	name = "Bluespace Activity"
	desc = "This makes your plants allow teleporting your victim."
	plusdesc = "NOTICE: This needs Liquid Contents trait or Slippery skin trait."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	rate = 0.1
	research_needed = 2

/datum/plant_gene/trait/teleport/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	var/turf/T = get_turf(target)
	before_process(G, target, T)

/datum/plant_gene/trait/teleport/on_slip(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	var/turf/T = get_turf(C)
	before_process(G, target, T, TRUE)

/datum/plant_gene/trait/teleport/proc/before_process(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L, turf/T, slip=FALSE)
	if(plant_teleport(G, L, T, slip))
		if(L.ckey != G.fingerprintslast) //what's the point of logging someone attacking himself
			ADD_TRAIT(L, TRAIT_BOTANY_IMMUNE_TELE, PLANT_TRAIT) //self attack doesn't give you immune
			addtimer(CALLBACK(src, /datum/plant_gene/trait/teleport.proc/handle_mob_trait, L), BTNY_CFG_TRAIT_TELE_IMMUME_TIME)
			if(slip)
				L.investigate_log("has slipped on bluespace plant at [AREACOORD(T)] teleporting them to [AREACOORD(L)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_combat(L, G, "slipped on", null, "teleporting them from [AREACOORD(T)] to [AREACOORD(L)]. Last fingerprint: [G.fingerprintslast].")
			else
				L.investigate_log("has been hit by a bluespace plant at [AREACOORD(T)] teleporting them to [AREACOORD(L)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_combat(G.thrownby, L, "hit", G, "at [AREACOORD(T)] teleporting them to [AREACOORD(L)]")
		if(slip)
			to_chat(L, "<span class='warning'>You slip through spacetime!</span>")
		else
			to_chat(L, "<span class='warning'>You are squashed through spacetime!</span>")

/datum/plant_gene/trait/teleport/proc/plant_teleport(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L, turf/T, slip=FALSE)
	if(HAS_TRAIT(L, TRAIT_BOTANY_IMMUNE_TELE))
		to_chat(L, "<span class='warning'>Spacetime pushes you back!</span>")
		return FALSE
	if(!isliving(target))
		return FALSE

	var/teleport_radius = max(round(G.seed.potency / 10), 1)
	if(slip)
		if(prob(50))
			new /obj/effect/decal/cleanable/molten_object(T) //Leave a pile of goo behind for dramatic effect...
			qdel(G)
			return TRUE
		else
			return FALSE
	do_teleport(target, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/effect/decal/cleanable/molten_object(T)
	return TRUE

/datum/plant_gene/trait/teleport/proc/handle_mob_trait(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_BOTANY_IMMUNE_TELE, PLANT_TRAIT)
