/datum/plant_gene/trait/smoke
	name = "Gaseous Decomposition"

/datum/plant_gene/trait/smoke/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	var/datum/effect_system/smoke_spread/chem/S = new
	var/splat_location = get_turf(target)
	var/smoke_amount = round(sqrt(G.seed.potency * 0.1), 1)
	var/turf/T = get_turf(G)
	S.attach(splat_location)
	S.set_up(G.reagents, smoke_amount, splat_location, 0)
	S.start()
	log_admin_private("[G.fingerprintslast] has caused a plant to create smoke containing [G.reagents.log_list()] at [AREACOORD(T)]")
	message_admins("[G.fingerprintslast] has caused a plant to create smoke containing [G.reagents.log_list()] at [ADMIN_VERBOSEJMP(T)]")
	G.investigate_log(" has created a smoke containing [G.reagents.log_list()] at [AREACOORD(T)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
	G.reagents.clear_reagents()
