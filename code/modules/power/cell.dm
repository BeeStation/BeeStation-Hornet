#define ETHEREAL_CELL_DRAIN_TIME (3.5 SECONDS)
#define ETHEREAL_CELL_POWER_DRAIN (0.75 * STANDARD_CELL_CHARGE)
/// The factor by which we multiply drain to get how much we gain
#define ETHEREAL_CELL_POWER_GAIN_FACTOR 0.08

/obj/item/stock_parts/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	inhand_icon_state = "cell"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	/// note %age converted to actual charge in New
	var/charge = 0
	/// Maximum charge possible in Aur
	var/maxcharge = STANDARD_CELL_CHARGE
	custom_materials = list(/datum/material/iron=700, /datum/material/glass=50)
	grind_results = list(/datum/reagent/lithium = 15, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	/// If the cell has been booby-trapped by injecting it with plasma. Chance on use() to explode.
	var/rigged = FALSE
	/// If the power cell was damaged by an explosion, chance for it to become corrupted and function the same as rigged.
	var/corrupted = FALSE
	///how much power is given every tick in a recharger
	var/chargerate
	/// How many recharge cycles untill 100%? Default is 20. Calculation goes - (maxcharge / chargerate_divide)
	var/chargerate_divide = 20
	///does it self recharge, over time, or not?
	var/self_recharge = FALSE
	///stores the chargerate to restore when hit with EMP, for slime cores
	var/emp_timer = 0
	var/ratingdesc = TRUE
	/// If it's a grown that acts as a battery, add a wire overlay to it.
	var/grown_battery = FALSE

/obj/item/stock_parts/cell/get_cell()
	return src

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stock_parts/cell)

/obj/item/stock_parts/cell/Initialize(mapload, override_maxcharge)
	. = ..()
	START_PROCESSING(SSobj, src)
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	charge = maxcharge
	if(ratingdesc)
		desc += " This one can store up to <span class='cfc_orange'>[display_power(maxcharge)]</span>."
	chargerate = (maxcharge / chargerate_divide)
	update_appearance()

/obj/item/stock_parts/cell/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/stock_parts/cell/calculate_price()
	// Base cell price is 10. Price will increase related to max charge
	// T2 cell is 100 cr for instance
	custom_price = maxcharge / 1000

/obj/item/stock_parts/cell/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, self_recharge))
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/stock_parts/cell/process(delta_time)
	if(emp_timer > world.time)
		return
	if(self_recharge)
		give(chargerate * 0.125 * delta_time)
	else
		return PROCESS_KILL

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += mutable_appearance('icons/obj/power.dmi', "grown_wires")
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		. += "cell-o2"
	else
		. += "cell-o1"

/obj/item/stock_parts/cell/proc/percent() // return % charge of cell
	return maxcharge ? 100 * charge / maxcharge : 0 //Division by 0 protection

// use power from a cell
/obj/item/stock_parts/cell/use(amount, force)
	if(rigged && amount > 0)
		plasma_ignition(4)
		return 0
	if(!force && charge < amount)
		return 0
	charge = max(charge - amount, 0)
	if(!istype(loc, /obj/machinery/power/apc))
		SSblackbox.record_feedback("tally", "cell_used", 1, type)
	return 1

// recharge the cell
/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		plasma_ignition(4)
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	return power_used

/**
 * Changes the charge of the cell.
 * Args:
 * - amount: The energy to give to the cell (can be negative).
 * Returns: The energy that was given to the cell (can be negative).
 */
/obj/item/stock_parts/cell/proc/change(amount)
	var/energy_used = clamp(amount, -charge, maxcharge - charge)
	charge += energy_used
	if(rigged && energy_used)
		explode()
	return energy_used

/**
 * Returns the amount of charge used on the cell.
 */
/obj/item/stock_parts/cell/proc/used_charge()
	return maxcharge - charge

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()
	if(rigged)
		. += span_danger("This power cell seems to be faulty!")
	else
		. += "The charge meter reads [round(src.percent() )]%."

/obj/item/stock_parts/cell/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS

/obj/item/stock_parts/cell/on_reagent_change(changetype)
	rigged = (corrupted || reagents.has_reagent(/datum/reagent/toxin/plasma, 5)) //has_reagent returns the reagent datum
	return ..()


/obj/item/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = FALSE
		corrupt()
		return

	message_admins("[ADMIN_LOOKUPFLW(usr)] has triggered a rigged/corrupted power cell explosion at [AREACOORD(T)].")
	log_game("[key_name(usr)] has triggered a rigged/corrupted power cell explosion at [AREACOORD(T)].")

	//explosion(T, 0, 1, 2, 2)
	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (prob(10))
		rigged = TRUE //broken batterys are dangerous
		corrupted = TRUE

/obj/item/stock_parts/cell/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0
	if(self_recharge)
		emp_timer = world.time + 30 SECONDS


/obj/item/stock_parts/cell/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		switch(severity)
			if(2)
				if(prob(50))
					corrupt()
			if(3)
				if(prob(25))
					corrupt()

/obj/item/stock_parts/cell/attack_self(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/stomach/electrical/ethereal/maybe_stomach = human_user.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!istype(maybe_stomach))
		return
	if(maybe_stomach.drain_time > world.time)
		return

	ethereal_drain(human_user, maybe_stomach)

/obj/item/stock_parts/cell/proc/ethereal_drain(mob/living/carbon/human/user, obj/item/organ/stomach/electrical/ethereal/used_stomach)
	if(charge <= 0)
		balloon_alert(user, "out of charge!")
		return

	var/obj/item/stock_parts/cell/stomach_cell = used_stomach.cell
	used_stomach.drain_time = world.time + ETHEREAL_CELL_DRAIN_TIME
	to_chat(user, span_notice("You begin clumsily channeling power from [src] into your body."))

	while(do_after(user, ETHEREAL_CELL_DRAIN_TIME, target = src))
		if(isnull(used_stomach) || (used_stomach != user.get_organ_slot(ORGAN_SLOT_STOMACH)))
			balloon_alert(user, "stomach removed!?")
			return

		var/our_charge = charge
		var/scaled_stomach_used_charge = stomach_cell.used_charge() / ETHEREAL_CELL_POWER_GAIN_FACTOR
		var/potential_charge = min(our_charge, scaled_stomach_used_charge)
		var/to_drain = min(ETHEREAL_CELL_POWER_DRAIN, potential_charge)
		var/energy_drained = use(to_drain, force = TRUE)
		used_stomach.adjust_charge(energy_drained * ETHEREAL_CELL_POWER_GAIN_FACTOR)
		update_appearance(UPDATE_OVERLAYS)

		if(stomach_cell.used_charge() <= 0)
			balloon_alert(user, "your charge is full!")
			return
		if(charge <= 0)
			balloon_alert(user, "out of charge!")
			return

/obj/item/stock_parts/cell/blob_act(obj/structure/blob/B)
	SSexplosions.high_mov_atom += src

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return clamp(20 + round(charge/25000), 20, 195) + rand(-5,5)
	else
		return 0

/obj/item/stock_parts/cell/get_part_rating()
	return rating * maxcharge

/obj/item/stock_parts/cell/attackby_storage_insert(datum/component/storage, atom/storage_holder, mob/user)
	var/obj/item/mod/control/mod = storage_holder
	return !(istype(mod) && mod.open)

/* Cell variants*/
/obj/item/stock_parts/cell/empty/Initialize(mapload)
	. = ..()
	charge = 0

/obj/item/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargeable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = 5 KILOWATT
	custom_materials = list(/datum/material/glass=40)

/obj/item/stock_parts/cell/crap/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_appearance()

/obj/item/stock_parts/cell/upgraded
	name = "upgraded power cell"
	desc = "A power cell with a slightly higher capacity than normal!"
	maxcharge = 25 KILOWATT
	custom_materials = list(/datum/material/glass=50)

/obj/item/stock_parts/cell/upgraded/plus
	name = "upgraded power cell+"
	desc = "A power cell with an even higher capacity than the base model!"
	maxcharge = 50 KILOWATT

/obj/item/stock_parts/cell/ninja
	name = "black power cell"
	icon_state = "bscell"
	maxcharge = 100 KILOWATT
	custom_materials = list(/datum/material/glass=60)
	chargerate = 2000

/obj/item/stock_parts/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = 100 KILOWATT
	custom_materials = list(/datum/material/glass=60)
	rating = 1

/obj/item/stock_parts/cell/high/plus
	name = "high-capacity power cell+"
	desc = "Where did these come from?"
	icon_state = "h+cell"
	maxcharge = 150 KILOWATT

/obj/item/stock_parts/cell/high/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_appearance()

/obj/item/stock_parts/cell/super
	name = "super-capacity power cell"
	icon_state = "scell"
	maxcharge = 200 KILOWATT
	custom_materials = list(/datum/material/glass=300)
	rating = 2

/obj/item/stock_parts/cell/super/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_appearance()

/obj/item/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	icon_state = "hpcell"
	maxcharge = 300 KILOWATT
	custom_materials = list(/datum/material/glass=400)
	rating = 3

/obj/item/stock_parts/cell/hyper/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_appearance()

/obj/item/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable transdimensional power cell."
	icon_state = "bscell"
	maxcharge = 400 KILOWATT
	custom_materials = list(/datum/material/glass=600)
	rating = 4

/obj/item/stock_parts/cell/bluespace/empty/Initialize(mapload)
	. = ..()
	charge = 0
	update_appearance()

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	maxcharge = INFINITY
	custom_materials = list(/datum/material/glass=1000)
	rating = 100
	chargerate_divide = 1

/obj/item/stock_parts/cell/infinite/use(used, force = FALSE)
	return TRUE

/obj/item/stock_parts/cell/infinite/abductor
	name = "void core"
	desc = "An alien power cell that produces energy seemingly out of nowhere."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cell"
	maxcharge = 500 KILOWATT
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/abductor/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

/obj/item/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch based power cell."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"
	charge = 10
	maxcharge = 3 KILOWATT
	custom_materials = null
	grown_battery = TRUE //it has the overlays for wires

/obj/item/stock_parts/cell/high/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	custom_materials = null
	rating = 5 //self-recharge makes these desirable
	self_recharge = TRUE // Infused slime cores self-recharge, over time
	chargerate_divide = 100
	maxcharge = 20 KILOWATT

/obj/item/stock_parts/cell/emergency_light
	name = "miniature power cell"
	desc = "A tiny power cell with a very low power capacity. Used in light fixtures to power them in the event of an outage."
	maxcharge = 1.2 KILOWATT //Emergency lights use 5 watts per second, meaning 4 minutes of emergency power from a cell
	custom_materials = list(/datum/material/glass = 20)
	w_class = WEIGHT_CLASS_TINY

/obj/item/stock_parts/cell/emergency_light/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(!A.lightswitch || !A.light_power)
		charge = 0 //For naturally depowered areas, we start with no power

/obj/item/stock_parts/cell/ethereal
	name = "ahelp it"
	desc = "you shouldn't see this"
	maxcharge = ETHEREAL_CHARGE_DANGEROUS
	charge = ETHEREAL_CHARGE_FULL
	icon_state = null
	custom_materials = null
	grind_results = null

/obj/item/stock_parts/cell/ethereal/examine(mob/user)
	. = ..()
	CRASH("[src.type] got examined by [user]")

#undef ETHEREAL_CELL_DRAIN_TIME
#undef ETHEREAL_CELL_POWER_DRAIN
#undef ETHEREAL_CELL_POWER_GAIN_FACTOR
