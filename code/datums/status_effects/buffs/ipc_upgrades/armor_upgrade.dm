/datum/status_effect/ipc_upgrade/armor
	id = "ipc armor"
	name = "Generic Armor"
	var/armor

/datum/status_effect/ipc_upgrade/armor/on_apply()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.physio_armor = human_owner.physiology.physio_armor.add_other_armor(armor)

/datum/status_effect/ipc_upgrade/armor/on_remove()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.physio_armor = human_owner.physiology.physio_armor.subtract_other_armor(armor)

/datum/status_effect/ipc_upgrade/armor/las_armor
	id = "ipc las armor"
	name = "Ablative Plating"
	upgrade_overlays = list("armor" = UNIFORM_LAYER)
	slot = UPGRADE_EXTERNAL
	armor = /datum/armor/refractive_armor
	item_type = /obj/item/ipc_upgrade/las_armor

/datum/status_effect/ipc_upgrade/armor/ken_armor
	id = "ipc ken armor"
	name = "Reactive Plating"
	upgrade_overlays = list("armor" = UNIFORM_LAYER)
	slot = UPGRADE_EXTERNAL
	armor = /datum/armor/hardening_armor
	item_type = /obj/item/ipc_upgrade/ken_armor
