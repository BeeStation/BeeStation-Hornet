/obj/item/ipc_upgrade
	icon = 'icons/obj/ipc_upgrade.dmi'

	var/datum/status_effect/ipc_upgrade/upgrade
	var/slot

/obj/item/ipc_upgrade/Initialize(mapload)
	. = ..()
	var/datum/status_effect/ipc_upgrade/upgrade_type = upgrade
	slot = upgrade_type.slot

/obj/item/ipc_upgrade/proc/insert(mob/living/carbon/owner)
	if(get_ipc_upgrade_by_slot(owner.status_effects, slot))
		return FALSE
	owner.apply_status_effect(upgrade)
	return TRUE

/obj/item/ipc_upgrade/repair_nexus
	name = "repair nexus"
	desc = "A core upgrade that repairs robotic parts at the cost of energy."
	upgrade = /datum/status_effect/ipc_upgrade/repair_nexus
	icon_state = "repair_nexus"

/obj/item/ipc_upgrade/emp_shield
	name = "disposable EMP shielding"
	desc = "A core upgrade that redirects EMP attacks. It will only survive a few attacks, however."
	upgrade = /datum/status_effect/ipc_upgrade/emp_shield
	icon_state = "emp_shield"

/obj/item/ipc_upgrade/supply_pack
	name = "supply pack"
	desc = "A utility upgrade that installs a very large storage unit on the back of the user. Uniquely, this can store extra large items."
	upgrade = /datum/status_effect/ipc_upgrade/supply_pack
	icon_state = "supply_pack"

/obj/item/ipc_upgrade/part_fab
	name = "part fabricator"
	desc = "A utility upgrade that can fabricate stock parts at will."
	upgrade = /datum/status_effect/ipc_upgrade/part_fab
	icon_state = "part_fab"

/obj/item/ipc_upgrade/blood_drive
	name = "integrated blood drive"
	desc = "An illegal utility upgrade that, when attacking another person, will extract blood and use it to repair the user."
	upgrade = /datum/status_effect/ipc_upgrade/deployable/blood_drive
	icon_state = "blood_drive"

/obj/item/ipc_upgrade/medbeam
	name = "integrated revival beam"
	desc = "A utility upgrade that allows the user to generate a beam that heals critical injuries. It cannot heal smaller ones, though."
	upgrade = /datum/status_effect/ipc_upgrade/deployable/medbeam
	icon_state = "medbeam"

/obj/item/ipc_upgrade/overclocked_servos
	name = "overclocked servos"
	desc = "A utility upgrade that increase the efficiency of movement servos in the user."
	upgrade = /datum/status_effect/ipc_upgrade/overclocked_servos
	icon_state = "overclocked_servos"

/obj/item/ipc_upgrade/tool_speedifier
	name = "tool adaptor"
	desc = "A utility upgrade that allows the user to interface with tools more effectively, increasing their speed."
	upgrade = /datum/status_effect/ipc_upgrade/tool_speedifier
	icon_state = "tool_speedifier"

/obj/item/ipc_upgrade/leap_legs
	name = "leap legs"
	desc = "A utility upgrade that installs powerful hydraulics that allow to user to launch themselves violently."
	upgrade = /datum/status_effect/ipc_upgrade/leap_legs
	icon_state = "leap_legs"

/obj/item/ipc_upgrade/ipc_generator
	name = "isotope decay generator"
	desc = "A core upgrade that installs a small RTG in the user, allowing them to generate trace amounts of power."
	upgrade = /datum/status_effect/ipc_upgrade/ipc_generator
	icon_state = "ipc_generator"

/obj/item/ipc_upgrade/fuel_generator
	name = "plasmatic generator"
	desc = "A core upgrade that installs a small plasma generator in the user, allowing them to generate a decent amount of power. Insert plasma material in the designated port on the user to fuel the generator."
	upgrade = /datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator
	icon_state = "fuel_generator"

/obj/item/ipc_upgrade/vacuum_shielding
	name = "vacuum shielding"
	desc = "An external upgrade that seals joints, protecting them from a vacuum."
	upgrade = /datum/status_effect/ipc_upgrade/trait/vacuum_shielding
	icon_state = "vacuum_shielding"

/obj/item/ipc_upgrade/rad_shielding
	name = "radiation shielding"
	desc = "An external upgrade that includes lead plating to reduce incoming radiation emissions."
	upgrade = /datum/status_effect/ipc_upgrade/trait/rad_shielding
	icon_state = "rad_shielding"

/obj/item/ipc_upgrade/las_armor
	name = "ablative plating"
	desc = "An external upgrade that includes temperature resistant plating, reducing energy weapons and heat based damages."
	upgrade = /datum/status_effect/ipc_upgrade/armor/las_armor
	icon_state = "las_armor"

/obj/item/ipc_upgrade/ken_armor
	name = "reactive plating"
	desc = "An external upgrade that includes hardened plating, reducing ballistic weapons and kinetic based damages."
	upgrade = /datum/status_effect/ipc_upgrade/armor/ken_armor
	icon_state = "ken_armor"

/obj/item/ipc_upgrade/cooling_system
	name = "cooling system"
	desc = "An external upgrade that includes advanced cooling devices, reducing overall temperature. Does not protect against heat caused by lack of coolant."
	upgrade = /datum/status_effect/ipc_upgrade/cooling_system
	icon_state = "cooling_system"

/obj/item/ipc_upgrade/ex_cannon
	name = "mounted EX-19 cannon"
	desc = "An illegal utility upgrade that installs a shoulder mounted cannon. This model requires a charge-up period before firing."
	upgrade = /datum/status_effect/ipc_upgrade/gun/charged/ex_cannon
	icon_state = "ex_cannon"
