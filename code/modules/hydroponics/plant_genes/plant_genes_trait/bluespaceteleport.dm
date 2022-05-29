/datum/plant_gene/trait/teleport
	// Makes plant teleport people when squashed or slipped on.
	// Teleport radius is calculated as max(round(potency*rate), 1)
	name = "Bluespace Activity"
	desc = "This makes your plants allow teleporting your victim."
	plusdesc = "NOTICE: This needs Liquid Contents trait or Slippery skin trait."
	randomness_flags = BOTANY_RANDOM_COMMON
	rate = 0.1
	research_needed = 2

/datum/plant_gene/trait/teleport/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	if(isliving(target))
		var/teleport_radius = max(round(G.seed.potency / 10), 1)
		var/turf/T = get_turf(target)
		var/mob/living/carbon/C = target
		new /obj/effect/decal/cleanable/molten_object(T) //Leave a pile of goo behind for dramatic effect...
		do_teleport(target, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
		if(C.ckey == G.fingerprintslast)		//what's the point of logging someone attacking himself
			return
		log_combat(G.thrownby, C, "hit", G, "at [AREACOORD(T)] teleporting them to [AREACOORD(C)]")
		C.investigate_log("has been hit by a bluespace plant at [AREACOORD(T)] teleporting them to [AREACOORD(C)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)

/datum/plant_gene/trait/teleport/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/C)
	var/teleport_radius = max(round(G.seed.potency / 10), 1)
	var/turf/T = get_turf(C)
	to_chat(C, "<span class='warning'>You slip through spacetime!</span>")
	do_teleport(C, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
	if(C.ckey != G.fingerprintslast)			//what's the point of logging someone attacking himself
		C.investigate_log("has slipped on bluespace plant at [AREACOORD(T)] teleporting them to [AREACOORD(C)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
		log_combat(C, G, "slipped on", null, "teleporting them from [AREACOORD(T)] to [AREACOORD(C)]. Last fingerprint: [G.fingerprintslast].")
	if(prob(50))
		do_teleport(G, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
	else
		new /obj/effect/decal/cleanable/molten_object(T) //Leave a pile of goo behind for dramatic effect...
		qdel(G)
