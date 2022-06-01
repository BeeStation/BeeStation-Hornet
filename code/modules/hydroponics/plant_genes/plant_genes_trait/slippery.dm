/datum/plant_gene/trait/slip
	// Makes plant slippery, unless it has a grown-type trash. Then the trash gets slippery.
	// Applies other trait effects (teleporting, etc) to the target by on_slip.
	name = "Slippery Skin"
	desc = "This makes your plants slippery. Be careful of stepping on them!"
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	rate = 1.6
	examine_line = "<span class='info'>It has a very slippery skin.</span>"
	research_needed = 3

/datum/plant_gene/trait/slip/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	if(istype(G) && ispath(G.trash, /obj/item/grown))
		return
	var/obj/item/seeds/seed = G.seed
	var/stun_len = seed.potency * rate

	if(!istype(G, /obj/item/grown/bananapeel) && (!G.reagents || !G.reagents.has_reagent(/datum/reagent/lube)))
		stun_len /= 3

	G.AddComponent(/datum/component/slippery, min(stun_len,140), NONE, CALLBACK(src, .proc/handle_slip, G))

/datum/plant_gene/trait/slip/proc/handle_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/M)
	for(var/datum/plant_gene/trait/T in G.seed.genes)
		T.on_slip(G, M)
