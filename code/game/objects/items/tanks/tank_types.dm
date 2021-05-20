/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Plasma
 *		Emergency Oxygen
 */

/*
 * Oxygen
 */
/obj/item/tank/internals/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen, this one is blue."
	icon_state = "oxygen"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 10
	dog_fashion = /datum/dog_fashion/back


/obj/item/tank/internals/oxygen/populate_gas()
	air_contents.set_moles(/datum/gas/oxygen, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"
	dog_fashion = null

/obj/item/tank/internals/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"
	dog_fashion = null

/obj/item/tank/internals/oxygen/empty/populate_gas()
	return

/*
 * Anesthetic
 */
/obj/item/tank/internals/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	item_state = "an_tank"
	force = 10

/obj/item/tank/internals/anesthetic/populate_gas()
	air_contents.set_moles(/datum/gas/oxygen, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	air_contents.set_moles(/datum/gas/nitrous_oxide, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/*
 * Air
 */
/obj/item/tank/internals/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "air"
	item_state = "air"
	force = 10
	dog_fashion = /datum/dog_fashion/back

/obj/item/tank/internals/air/populate_gas()
	air_contents.set_moles(/datum/gas/oxygen, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	air_contents.set_moles(/datum/gas/nitrogen, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/*
 * Plasma
 */
/obj/item/tank/internals/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags_1 = CONDUCT_1
	slot_flags = null	//they have no straps!
	force = 8


/obj/item/tank/internals/plasma/populate_gas()
	air_contents.set_moles(/datum/gas/plasma, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasma/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/flamethrower))
		var/obj/item/flamethrower/F = W
		if ((!F.status)||(F.ptank))
			return
		if(!user.transferItemToLoc(src, F))
			return
		src.master = F
		F.ptank = src
		F.update_icon()
	else
		return ..()

/obj/item/tank/internals/plasma/full/populate_gas()
	air_contents.set_moles(/datum/gas/plasma, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasma/empty/populate_gas()
	return

/*
 * Plasmaman Plasma Tank
 */

/obj/item/tank/internals/plasmaman
	name = "extended-capacity plasma internals tank"
	desc = "A tank of plasma gas designed specifically for use as internals, particularly for plasma-based lifeforms. If you're not a Plasmaman, you probably shouldn't use this."
	icon_state = "plasmaman_tank"
	item_state = "plasmaman_tank"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/plasmaman/populate_gas()
	air_contents.set_moles(/datum/gas/plasma, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasmaman/full/populate_gas()
	air_contents.set_moles(/datum/gas/plasma, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasmaman/empty/populate_gas()
	return


/obj/item/tank/internals/plasmaman/belt
	name = "plasma internals belt tank"
	icon_state = "plasmaman_tank_belt"
	item_state = "plasmaman_tank_belt"
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 6
	w_class = WEIGHT_CLASS_SMALL //thanks i forgot this

/obj/item/tank/internals/plasmaman/belt/full/populate_gas()
	air_contents.set_moles(/datum/gas/plasma, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasmaman/belt/empty/populate_gas()
	return



/*
 * Emergency Oxygen
 */
/obj/item/tank/internals/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 4
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	volume = 1 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


/obj/item/tank/internals/emergency_oxygen/populate_gas()
	air_contents.set_moles(/datum/gas/oxygen, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/emergency_oxygen/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 2 // should last a bit over 30 minutes if full

/obj/item/tank/internals/emergency_oxygen/engi/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	volume = 8

/obj/item/tank/internals/emergency_oxygen/double/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/magic_oxygen
	name = "magic oxygen tank"
	icon_state = "emergency_double"
	volume = 100000000

/obj/item/tank/internals/emergency_oxygen/double/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/clown
	name = "emergency prank tank"
	desc = "Used for pranking in emergencies! Has a smidge of a mystery ingredient for 200% FUN!"
	icon_state = "clown"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 4
	distribute_pressure = 24
	volume = 1

/obj/item/tank/internals/emergency_oxygen/clown/populate_gas()
	air_contents.set_moles(/datum/gas/oxygen, (9.99*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))
	air_contents.set_moles(/datum/gas/nitrous_oxide, (0.01*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))