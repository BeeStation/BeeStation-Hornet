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

/datum/plant_gene/trait/teleport/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	activate_effect(G, target, p_method)

/datum/plant_gene/trait/teleport/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/target, p_method)
	activate_effect(G, target, p_method)
	return TRUE
	// return value determines if the plant should be destroyed.
	// bluespace teleport crops must be destroyed once it's activated.

/datum/plant_gene/trait/teleport/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/target, p_method)
	activate_effect(G, target, p_method)
	return TRUE

/datum/plant_gene/trait/teleport/proc/activate_effect(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	if(!isliving(target))
		return FALSE
	var/turf/T = get_turf(target)
	var/mob/living/L = target
	if(plant_teleport(G, L, T))
		ADD_TRAIT(L, TRAIT_BOTANY_IMMUNE_TELE, TRAIT_GENERIC) //self attack doesn't give you immune
		addtimer(CALLBACK(src, .proc/handle_mob_trait, L), BTNY_CFG_TRAIT_TELE_IMMUME_TIME)
		to_chat(L, "<span class='warning'>You slip through spacetime!</span>")

		if(L?.ckey != G.fingerprintslast)
			if(p_method & PLANT_ACTIVATED_SLIP)
				L.investigate_log("has been teleported to [AREACOORD(L)] from [AREACOORD(T)] by stepping on a SLIPPERY bluespace plant([G]). Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [key_name(L)] has been teleported to [AREACOORD(L)] from [AREACOORD(T)] by stepping on a SLIPPERY bluespace plant([G]). Last pickup ckey: [G.fingerprintslast].")
			else if(p_method & PLANT_ACTIVATED_ATTACK)
				L.investigate_log("been teleported to [AREACOORD(L)] from [AREACOORD(T)] from being ATTACKED BY a bluespace plant([G]). Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [key_name(L)] has been teleported to [AREACOORD(L)] from [AREACOORD(T)] from being ATTACKED BY a bluespace plant([G]). Last pickup ckey: [G.fingerprintslast].")
			else if(p_method & PLANT_ACTIVATED_THROW)
				var/mob/thrown_by = G.thrownby?.resolve()
				L.investigate_log("has been teleported to [AREACOORD(L)] from [AREACOORD(T)] from being hit by a THROWN bluespace plant([G]). Thrower: [(thrown_by || "(unknown)")]. Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [(thrown_by || "(unknown)")] has thrown a bluespace plant([G]) to [key_name(L)], causing teleporting them to [AREACOORD(L)] from [AREACOORD(T)]. Last pickup ckey: [G.fingerprintslast].")
			else
				L.investigate_log("been teleported to [AREACOORD(L)] from [AREACOORD(T)] due to a bluespace plant([G]), but the attack method is unknown. Last pickup ckey: [G.fingerprintslast].", INVESTIGATE_BOTANY)
				log_game("#botany. [key_name(L)] has been teleported to [AREACOORD(L)] from [AREACOORD(T)] due to a bluespace plant([G]), but the attack method is unknown. Last pickup ckey: [G.fingerprintslast].")
				CRASH("Plant trait is activated by unknown method. Method: [p_method]")


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
