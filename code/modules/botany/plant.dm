/*
	The plant component is basically a central hub for plant features to send signals from
	The majority of implementation should happen in the plant feature datums
*/
//TODO: add some botany achievments after / during TM - Racc

/datum/component/plant
	///The object acting as our plant
	var/obj/item/plant_item
	///Species ID, used for stuff like book keeping
	var/species_id
	///Our plant features
	var/list/plant_features = list(/datum/plant_feature/body, /datum/plant_feature/fruit, /datum/plant_feature/roots)
	///Do we skip the growing phase
	var/skip_growth
	///How much we reward we give when scanned, discovery points. Nothing really changes this, but it's here for the future in case certain traits or features buff it
	var/discovery_reward = 500
	///used to stop weird interactions with spades
	var/spading = FALSE
	///Have we inherited a name?
	var/name_override
	var/desc_override

//Appearance
	///Used to toggle if we want to use body feature's appearances. You can toggle this off if you want to make something with an existing appearance a plant
	var/use_body_appearance = TRUE
	///Do we exist over the water? See _plant_body.dm for more details, this is overridden by our body - QUICK ACCESS
	var/draw_below_water
	///Do we use the mouse offset when planting - QUICK ACCESS
	var/use_mouse_offset = FALSE

/datum/component/plant/Initialize(obj/item/_plant_item, list/_plant_features, _species_id, _skip_growth)
	. = ..()
	plant_item = _plant_item
	skip_growth = _skip_growth
	plant_item.flags_1 |= IS_ONTOP_1
	//Setup signals for spade behaviour
	RegisterSignal(plant_item, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(catch_attackby))
	//Species ID setup
	if(!_species_id)
		compile_species_id()
	else
		species_id = _species_id
	//Plant features
	if(length(_plant_features))
		populate_features(_plant_features)
	//Discoverable
	plant_item.AddComponent(/datum/component/discoverable/plant, discovery_reward)
	//Genes
	populate_gene_cache()

/datum/component/plant/Destroy(force, silent)
	SEND_SIGNAL(src, COMSIG_PLANT_UPROOTED,  null, null, plant_item.loc)
	for(var/feature as anything in plant_features)
		qdel(feature)
	return ..()

///Item interactions for plants that aren't covered by the individual plant_features
/datum/component/plant/proc/catch_attackby(datum/source, obj/item, mob/living/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

//Spade interaction, allows us to dig up plants
	if((proximity_flag || get_dist(user, plant_item) <= 1) && !spading && istype(item, /obj/item/shovel/spade))
		INVOKE_ASYNC(src, PROC_REF(async_catch_attackby), item, user)

/datum/component/plant/proc/async_catch_attackby(obj/item, mob/living/user)
	playsound(plant_item, 'sound/effects/shovel_dig.ogg', 60)
	spading = TRUE
	if(length(item.contents))
		spading = FALSE
		return
	if(do_after(user, 2.5 SECONDS, plant_item) && !length(item.contents)) //Check contents twice cuz time frame changes
		//Remove the plant from it's old home
		var/atom/movable/AM = plant_item.loc
		if(istype(AM))
			AM.vis_contents -= plant_item
		//Move to new home
		SEND_SIGNAL(src, COMSIG_PLANT_UPROOTED, user, item, plant_item.loc)
		plant_item.forceMove(item)
		item.vis_contents += plant_item
		RegisterSignal(item, COMSIG_ITEM_PRE_ATTACK, PROC_REF(catch_spade_attack))
		RegisterSignal(plant_item, COMSIG_MOVABLE_MOVED, PROC_REF(catch_moved))
		spading = FALSE
		return TRUE
	else
		spading = FALSE

//Follow up for spade interaction
/datum/component/plant/proc/catch_spade_attack(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER

	if(target == plant_item)
		return
	//Is this even a planter?
	var/datum/component/planter/tray_component = target.GetComponent(/datum/component/planter)
	if(!tray_component)
		to_chat(user, "<span class='warning'>You can't plant [plant_item] here!</span>")
		return
	if(!SEND_SIGNAL(src, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE, tray_component.substrate))
		to_chat(user, "<span class='warning'>You can't plant [plant_item] in this substrate!</span>")
		return
	if(!SEND_SIGNAL(src, COMSIG_PLANT_POLL_TRAY_SIZE, target))
		to_chat(user, "<span class='warning'>There's no room to plant [plant_item] here!</span>")
		return
	INVOKE_ASYNC(src, PROC_REF(catch_spade_attack_async), source, target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/plant/proc/catch_spade_attack_async(obj/spade, obj/target, mob/user)
	playsound(plant_item, 'sound/effects/shovel_dig.ogg', 60)
	if(!do_after(user, 2.5 SECONDS, target))
		return
	UnregisterSignal(spade, COMSIG_ITEM_PRE_ATTACK)
	if(!(locate(plant_item) in spade))
		return
	SEND_SIGNAL(src, COMSIG_PLANT_PLANTED, target)
	plant_item.forceMove(target)
	target.vis_contents += plant_item
	spade.vis_contents -= plant_item

/datum/component/plant/proc/catch_moved(datum/source, atom/movable/old_loc, dir)
	SIGNAL_HANDLER

	UnregisterSignal(old_loc, COMSIG_ITEM_PRE_ATTACK)
	UnregisterSignal(plant_item, COMSIG_MOVABLE_MOVED)
	old_loc.vis_contents -= plant_item

/datum/component/plant/proc/populate_features(list/_features)
	plant_features = _features?.Copy() || plant_features
	for(var/datum/plant_feature/feature as anything in plant_features)
		plant_features -= feature
		if(ispath(feature))
			plant_features += new feature(src)
		else
			plant_features += feature.copy(src)

///This generates a unqiue species ID for us. Call this when a plant is modified or created or whatever
/datum/component/plant/proc/compile_species_id()
	species_id = build_plant_species_id(plant_features)
	SSbotany.plant_species |= species_id
	populate_gene_cache()

/datum/component/plant/proc/populate_gene_cache()
	if(SSbotany.gene_cache[species_id])
		return
	var/list/plant_genes = list()
	for(var/datum/plant_feature/gene as anything in plant_features)
		if(QDELETED(gene))
			continue
		plant_genes += gene?.copy()
	SSbotany.gene_cache[species_id] = plant_genes
