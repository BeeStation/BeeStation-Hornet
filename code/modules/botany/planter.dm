#define WEED_RATE 0.3
#define WEED_THRESHOLD 100

/datum/component/planter
	///How many available slots do we have for plants
	var/plant_slots = PLANT_BODY_SLOT_SIZE_LARGEST
	///What kind of substrate do we have?
	var/datum/plant_subtrate/substrate
	///Do we allow our substrate to be changed?
	var/allow_substrate_change = TRUE
	///How much do we visually offset the plant when planting it
	var/visual_upset = 16
	///How much we offset entering plant's layer - used to make pots work
	var/layer_upset = 0
	///Do we gain weeds over time?
	var/gain_weeds = TRUE
	///Weed buildup
	var/weed_level = 0
	///Have we been visited by a bee recently?
	var/recent_bee_visit = FALSE
	///List of plants stored in us
	var/list/plants = list()

/datum/component/planter/Initialize(_visual_upset, _layer_upset, _gain_weeds)
	. = ..()
	visual_upset = _visual_upset || visual_upset
	layer_upset = _layer_upset || layer_upset
	gain_weeds = _gain_weeds
	RegisterSignal(parent, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(catch_attack))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(catch_examine))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(catch_entered))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(catch_exited))
	if(!gain_weeds)
		return
	START_PROCESSING(SSobj, src)

/datum/component/planter/process(delta_time)
	var/obj/obj_parent = parent
//Weed tick
	if(!substrate)
		return
	weed_level += WEED_RATE * delta_time
//Tick reagents
	SEND_SIGNAL(obj_parent.reagents, COMSIG_PLANTER_TICK_REAGENTS,  src, delta_time)
//Weed overtake
	if(weed_level < WEED_THRESHOLD)
		return
	weed_level = 0
	var/obj/item/plant_seeds/preset/weed = pick_weight(SSbotany.weeds)
	weed = new weed(get_turf(parent))
	if(!weed.plant(parent, logic = TRUE))
		qdel(weed)
		return
	obj_parent.visible_message(span_warning("The [parent] is overtaken by some [weed.name_override]!"))

/datum/component/planter/proc/catch_attack(datum/source, obj/item/I, mob/living/attacker, params)
	SIGNAL_HANDLER

//Removing weeeds
	if(istype(I, /obj/item/cultivator))
		if(weed_level <= 0)
			attacker.visible_message("[attacker] digs around in [parent].", span_warning("[parent] is devoid of weeds!"))
			return
		attacker.visible_message("[attacker] uproots the weeds.", span_notice("You remove the weeds from [parent]."))
		weed_level = 0
		playsound(parent, 'sound/effects/shovel_dig.ogg', 60)
		return
//Remove substrate
	if(istype(I, /obj/item/shovel/spade) && !length(plants) && allow_substrate_change)
		INVOKE_ASYNC(src, PROC_REF(async_spade_action), attacker)
		return
	else if(length(plants))
		to_chat(attacker, span_warning("You can't clear [parent]'s substrate whil it still contains plants!"))
//Let people fill trays with reagents by hand
	var/obj/obj_parent = parent
	if(!IS_EDIBLE(I) && !istype(I, /obj/item/reagent_containers) || obj_parent.reagents?.flags & REFILLABLE)
		return
	var/obj/item/reagent_containers/reagent_source = I
	if(!reagent_source.reagents.total_volume) //It aint got no gas in it
		to_chat(attacker, span_warning("[reagent_source] is empty!"))
		return
	//Transfer reagents
	reagent_source.reagents.trans_to(parent, reagent_source.amount_per_transfer_from_this, transfered_by = attacker)
	to_chat(attacker, span_notice("You add [reagent_source.amount_per_transfer_from_this]u from [reagent_source] to [parent]!"))

/datum/component/planter/proc/async_spade_action(mob/user)
	playsound(parent, 'sound/effects/shovel_dig.ogg', 60)
	if(!do_after(user, 2.3 SECONDS, parent))
		return
	set_substrate(null)

/datum/component/planter/proc/catch_examine(datum/source, mob/looker, list/examine_text)
	SIGNAL_HANDLER

	if(substrate)
		examine_text += ("<span class='notice'>[parent] is filled with [substrate.name].\n[substrate.tooltip]</span>")
	else
		examine_text += ("<span class='warning'>[parent] does not contain any substrate!</span>")

/datum/component/planter/proc/catch_entered(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	var/plant_comp = entering.GetComponent(/datum/component/plant)
	if(!plant_comp)
		return
//Visuals
	entering.layer += layer_upset
	//Add visuals, move the plant upwards to make it look like it's inside us
	entering.pixel_y += visual_upset
//Records
	plants |= plant_comp
	RegisterSignal(entering, COMSIG_QDELETING, PROC_REF(catch_qdel))

/datum/component/planter/proc/catch_exited(datum/source, atom/movable/exiting)
	SIGNAL_HANDLER

	var/plant_comp = exiting.GetComponent(/datum/component/plant)
	if(!plant_comp)
		return
	exiting.layer -= layer_upset
	exiting.pixel_y -= visual_upset
	plants -= plant_comp
	UnregisterSignal(exiting, COMSIG_QDELETING)

/datum/component/planter/proc/set_substrate(_substrate)
	if(!allow_substrate_change)
		return
	SEND_SIGNAL(src, COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP, substrate)
	if(substrate)
		QDEL_NULL(substrate)
	if(_substrate)
		substrate = new _substrate()
	SEND_SIGNAL(src, COMSIG_PLANTER_UPDATE_SUBSTRATE, substrate)
	return substrate

/datum/component/planter/proc/catch_qdel(datum/source)
	SIGNAL_HANDLER

	plants -= source

#undef WEED_RATE
#undef WEED_THRESHOLD
