/datum/plant_gene/trait/teleport
	// Makes plant teleport people when squashed or slipped on.
	// Teleport radius is calculated as max(round(potency*rate), 1)
	name = "Bluespace Activity"
	desc = "This makes your plants allow teleporting your victim."
	plusdesc = "NOTICE: This needs Liquid Contents trait or Slippery skin trait."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	rate = 0.1
	research_needed = 2

/* <Behavior table>
	 <A type>
		[on_squash] activate the effect
		[on_aftersquash] ...

	 <B type>
		[on_slip] activate the effect
		[on_attack] ... (works through squash)
		[on_throw_impact] ... (works through squash)

	 <C type>
		[on_attackby] ...
		[on_consume] activate the effect
		[on_grow] ...
		[on_new_plant] ...
		[on_new_seed] ...
		[on_removal] ...
 */

/datum/plant_gene/trait/teleport/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target, var/p_method="attack")
	activate_effect(G, target, p_method)

/datum/plant_gene/trait/teleport/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/target)
	activate_effect(G, target, "slip")
	return TRUE

/datum/plant_gene/trait/teleport/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/target)
	activate_effect(G, target, "consume")
	return TRUE

/datum/plant_gene/trait/teleport/proc/activate_effect(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method="attack")
	var/turf/T = get_turf(target)
	if(!isliving(target))
		return FALSE
	var/mob/living/L = target
	if(plant_teleport(G, L, T))
		ADD_TRAIT(L, TRAIT_BOTANY_IMMUNE_TELE, TRAIT_GENERIC) //self attack doesn't give you immune
		addtimer(CALLBACK(src, /datum/plant_gene/trait/teleport.proc/handle_mob_trait, L), BTNY_CFG_TRAIT_TELE_IMMUME_TIME)

		switch(p_method)
			if("slip")
				if(L.ckey != G.fingerprintslast)
					L.investigate_log("has slipped on bluespace plant at [AREACOORD(T)] teleporting them to [AREACOORD(L)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
					log_combat(L, G, "slipped on", null, "teleporting them from [AREACOORD(T)] to [AREACOORD(L)]. Last fingerprint: [G.fingerprintslast].")
				to_chat(L, "<span class='warning'>You slip through spacetime!</span>")
			else
				if(L.ckey != G.fingerprintslast)
					L.investigate_log("has been hit by a bluespace plant at [AREACOORD(T)] teleporting them to [AREACOORD(L)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
					log_combat(G.thrownby, L, "hit", G, "at [AREACOORD(T)] teleporting them to [AREACOORD(L)]")
				to_chat(L, "<span class='warning'>You are squashed through spacetime!</span>")


/datum/plant_gene/trait/teleport/proc/plant_teleport(obj/item/reagent_containers/food/snacks/grown/G, mob/living/L, turf/T)
	if(L.ckey != G.fingerprintslast) // self use for anytime
		if(HAS_TRAIT(L, TRAIT_BOTANY_IMMUNE_TELE))
			to_chat(L, "<span class='warning'>Spacetime pushes you back!</span>")
			return FALSE


	var/obj/item/seeds/S = G.seed
	var/teleport_radius = max(round(S.potency / 10), 1)
	do_teleport(L, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/effect/decal/cleanable/molten_object(T)
	return TRUE

/datum/plant_gene/trait/teleport/proc/handle_mob_trait(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_BOTANY_IMMUNE_TELE, TRAIT_GENERIC)
