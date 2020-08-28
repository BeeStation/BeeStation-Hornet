#define SAFETY_COOLDOWN 100

/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine used to recycle small items inefficiently. There are lights on the side."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	density = TRUE
	circuit = /obj/item/circuitboard/machine/recycler
	idle_power_usage = 50
	active_power_usage = 200
	var/safety_mode = FALSE // Temporarily stops machine if it detects a mob
	var/icon_name = "grinder-o"
	var/bloody = FALSE
	var/emagged_by = null // Used for logging
	var/eat_dir = WEST
	var/amount_produced = 50
	var/crush_damage = 1000
	var/eat_victim_items = TRUE
	var/item_recycle_sound = 'sound/items/welder.ogg'

/obj/machinery/recycler/Initialize(mapload)
	var/list/allowed_materials = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/copper,
		/datum/material/silver,
		/datum/material/plasma,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plastic,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace
	)
	AddComponent(/datum/component/material_container, allowed_materials, INFINITY, MATCONTAINER_NO_INSERT|BREAKDOWN_FLAGS_RECYCLER)
	AddComponent(/datum/component/butchering/recycler, 1, amount_produced,amount_produced/5)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/recycler/LateInitialize()
	. = ..()
	update_appearance(UPDATE_ICON)
	req_one_access = get_all_accesses() + get_all_centcom_access()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/recycler/RefreshParts()
	var/amt_made = 0
	var/mat_mod = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		mat_mod = 2 * B.rating
	mat_mod *= 50000
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		amt_made = 12.5 * M.rating //% of materials salvaged
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = mat_mod
	amount_produced = min(50, amt_made) + 50
	var/datum/component/butchering/butchering = GetComponent(/datum/component/butchering/recycler)
	butchering.effectiveness = amount_produced
	butchering.bonus_modifier = amount_produced/5

/obj/machinery/recycler/examine(mob/user)
	. = ..()
	. += span_notice("Reclaiming <b>[amount_produced]%</b> of materials salvaged.")
	. += "The power light is [(machine_stat & NOPOWER) ? "off" : "on"].\n"+\
	"The safety-mode light is [safety_mode ? "on" : "off"].\n"+\
	"The safety-sensors status light is [obj_flags & EMAGGED ? "off" : "on"]."


/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return

	if(default_pry_open(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/recycler/on_emag(mob/user)
	..()
	if(safety_mode)
		safety_mode = FALSE
		update_appearance()
	playsound(src, "sparks", 75, 1, -1)
	to_chat(user, span_notice("You use the cryptographic sequencer on [src]."))
	if(user)
		emagged_by = key_name(user) // key_name is collected here instead of when it's logged so that it gets their current mob name, not whatever future mob they may have

/obj/machinery/recycler/update_icon_state()
	var/is_powered = !(machine_stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = FALSE
	icon_state = icon_name + "[is_powered]" + "[(bloody ? "bld" : "")]" // add the blood tag at the end
	return ..()

/obj/machinery/recycler/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(border_dir == eat_dir)
		return TRUE

/obj/machinery/recycler/proc/on_entered(datum/source, atom/movable/enterer, old_loc)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(eat), enterer)

/obj/machinery/recycler/proc/eat(atom/movable/morsel, sound=TRUE)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(safety_mode)
		return
	if(iseffect(morsel))
		return
	if(!isturf(morsel.loc))
		return
	if(morsel.resistance_flags & INDESTRUCTIBLE)
		return

	var/list/to_eat
	if(istype(morsel, /obj/item))
		to_eat = morsel.GetAllContents()
	else
		to_eat = list(morsel)

	var/items_recycled = 0

	for(var/i in to_eat)
		var/atom/movable/AM = i
		var/obj/item/bodypart/head/as_head = AM
		var/obj/item/mmi/as_mmi = AM
		var/brain_holder = istype(AM, /obj/item/organ/brain) || (istype(as_head) && as_head.brain) || (istype(as_mmi) && as_mmi.brain) || isbrain(AM) || istype(AM, /obj/item/dullahan_relay)
		if(brain_holder)
			emergency_stop(AM)
		else if(isliving(AM))
			if(obj_flags & EMAGGED)
				crush_living(AM)
			else
				emergency_stop(AM)
		else if(istype(AM, /obj/item) && !istype(AM, /obj/item/stack))
			recycle_item(AM)
			items_recycled++
		else
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.forceMove(loc)

	if(items_recycled && sound)
		playsound(src, item_recycle_sound, 50, 1)

/obj/machinery/recycler/proc/recycle_item(obj/item/I)
	if(I.resistance_flags & INDESTRUCTIBLE) //indestructible item check
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		I.forceMove(loc)
		return
	I.forceMove(loc)
	var/obj/item/grown/log/L = I
	if(istype(L))
		var/seed_modifier = 0
		if(L.seed)
			seed_modifier = round(L.seed.potency / 25)
		new L.plank_type(src.loc, 1 + seed_modifier)
		qdel(L)
	else
		var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
		var/material_amount = materials.get_item_material_amount(I, BREAKDOWN_FLAGS_RECYCLER)
		if(!material_amount)
			return
		materials.insert_item(I, material_amount, multiplier = (amount_produced / 100), breakdown_flags=BREAKDOWN_FLAGS_RECYCLER)
		qdel(I)
		materials.retrieve_all()


/obj/machinery/recycler/proc/emergency_stop(mob/living/L)
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
	safety_mode = TRUE
	update_appearance()
	L.forceMove(loc)
	addtimer(CALLBACK(src, PROC_REF(reboot)), SAFETY_COOLDOWN)

/obj/machinery/recycler/proc/reboot()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
	safety_mode = FALSE
	update_appearance()

/obj/machinery/recycler/proc/crush_living(mob/living/L)

	L.forceMove(loc)

	if(issilicon(L))
		playsound(src, 'sound/items/welder.ogg', 50, 1)
	else
		playsound(src, 'sound/effects/splat.ogg', 50, 1)

	if(iscarbon(L))
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!", forced="recycler grinding")
		add_mob_blood(L)

	if(!bloody && !issilicon(L))
		bloody = TRUE
		update_icon()

	// Remove and recycle the equipped items
	if(eat_victim_items)
		for(var/obj/item/I in L.get_equipped_items(TRUE))
			if(L.dropItemToGround(I))
				eat(I, sound=FALSE)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Unconscious(100)
	L.adjustBruteLoss(crush_damage)
	L.log_message("has been crushed by a recycler that was emagged by [(emagged_by || "nobody")]", LOG_ATTACK, color="red")

/obj/machinery/recycler/deathtrap
	name = "dangerous old crusher"
	obj_flags = CAN_BE_HIT | EMAGGED
	crush_damage = 120
	flags_1 = NODECONSTRUCT_1

/obj/item/paper/guides/recycler
	name = "paper - 'garbage duty instructions'"
	default_raw_text = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"

#undef SAFETY_COOLDOWN
