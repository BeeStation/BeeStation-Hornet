/datum/plant_gene/trait/slip
	// Makes plant slippery, unless it has a grown-type trash. Then the trash gets slippery.
	// Applies other trait effects (teleporting, etc) to the target by on_slip.
	name = "Slippery Skin"
	desc = "This makes your plants slippery. Be careful of stepping on them!"
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	rate = 1.6
	examine_line = "<span class='info'>It has a very slippery skin.</span>"
	research_needed = 3

/* <Behavior table>
	 <A type>
		[on_squash] ...
		[on_aftersquash] ...

	 <B type>
		[on_slip] ...
		[on_attack] ...
		[on_throw_impact] ...

	 <C type>
		[on_attackby] ...
		[on_consume] ...
		[on_grow] ...
		[on_new_] Sets the plant with Slippery component

	 <misc>
	 	If the plant has squash trait, it squashes first.
 */

/datum/plant_gene/trait/slip/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G) && ispath(G.trash, /obj/item/grown))
		return
	var/obj/item/seeds/seed = G.seed
	var/stun_len = seed.potency * rate

	if(!istype(G, /obj/item/grown/bananapeel) && (!G.reagents || !G.reagents.has_reagent(/datum/reagent/lube)))
		stun_len /= 3

	G.AddComponent(/datum/component/slippery, min(stun_len,140), NONE, CALLBACK(src, .proc/handle_slip, G))

/datum/plant_gene/trait/slip/proc/handle_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/M)
	// squash must happen first. If it has no squash trait, It will do on_slip step by step.
	if(G.squash(M, "slip"))
		for(var/datum/plant_gene/trait/T in G.seed.genes)
			T.on_slip(G, M)
	if(G.squash_destruct_check())
		qdel(G)


// Squash -------------------------------------------------
/datum/plant_gene/trait/squash
	// Allows the plant to be squashed when thrown or slipped on, leaving a colored mess and trash type item behind.
	// Also splashes everything in target turf with reagents and applies other trait effects (teleporting, etc) to the target by on_squash.
	// For code, see grown.dm
	name = "Liquid Contents"
	desc = "This makes your plants very fragil from throwing."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	examine_line = "<span class='info'>It has a lot of liquid contents inside.</span>"
	research_needed = 2

/* <Behavior table>
	 itself does nothing. Its behaiour is coded in `grown.dm` as it said.
 */
