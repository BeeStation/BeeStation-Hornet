/datum/status_effect/ipc_upgrade/trait
	id = "ipc trait"
	name = "Generic Trait Upgrade"
	var/trait

/datum/status_effect/ipc_upgrade/trait/on_apply()
	. = ..()
	ADD_TRAIT(owner, trait, UPGRADE_TRAIT)

/datum/status_effect/ipc_upgrade/trait/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, trait, UPGRADE_TRAIT)

/datum/status_effect/ipc_upgrade/trait/vacuum_shielding
	id = "ipc vacuum shield"
	name = "Vacuum Shielding"
	slot = UPGRADE_EXTERNAL
	trait = TRAIT_RESISTLOWPRESSURE
	item_type = /obj/item/ipc_upgrade/vacuum_shielding

/datum/status_effect/ipc_upgrade/trait/rad_shielding
	id = "ipc rad shield"
	name = "Radiation Shielding"
	slot = UPGRADE_EXTERNAL
	trait = TRAIT_RADIMMUNE
	item_type = /obj/item/ipc_upgrade/rad_shielding
