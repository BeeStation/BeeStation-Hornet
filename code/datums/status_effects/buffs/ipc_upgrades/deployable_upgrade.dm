/datum/status_effect/ipc_upgrade/deployable
	id = "ipc deployable"
	name = "Generic Deployable Upgrade"
	slot = UPGRADE_UTILITY
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable/no_text
	abstract_type = /datum/status_effect/ipc_upgrade/deployable
	var/obj/item/to_deploy
	var/obj/item/to_deploy_typepath = /obj/item

/datum/status_effect/ipc_upgrade/deployable/on_apply()
	. = ..()
	to_deploy = new to_deploy_typepath()
	to_deploy.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(to_deploy, TRAIT_NODROP, UPGRADE_TRAIT)

/datum/status_effect/ipc_upgrade/deployable/on_remove()
	. = ..()
	QDEL_NULL(to_deploy)

/datum/status_effect/ipc_upgrade/deployable/activate(atom/target)
	if(!owner.dropItemToGround(owner.get_active_held_item(), FALSE))
		to_chat(owner, span_notice("Something is preventing the upgrade from deploying!"))
		return FALSE
	if(!..())
		return FALSE
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	owner.visible_message(span_warning("[owner] extends \a [to_deploy] from an internal compartment!"), span_notice("You extend \a [to_deploy] from an internal compartment."))
	owner.put_in_hand(to_deploy, owner.active_hand_index)

/datum/status_effect/ipc_upgrade/deployable/deactivate()
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	owner.visible_message(span_warning("[owner] retracts \a [to_deploy] into an internal compartment!"), span_notice("You retract \a [to_deploy] into an internal compartment."))
	to_deploy.moveToNullspace()
	. = ..()

/datum/status_effect/ipc_upgrade/deployable/medbeam
	id = "ipc deployable medbeam"
	name = "Integrated Revival Beam"
	active_power_requirement = 40
	slot = UPGRADE_UTILITY
	action_icon = "medbeam"
	to_deploy_typepath = /obj/item/gun/medbeam/weak
	item_type = /obj/item/ipc_upgrade/medbeam

/datum/status_effect/ipc_upgrade/deployable/medbeam/should_process()
	var/obj/item/gun/medbeam/weak/medgun = to_deploy
	return ..() && medgun.active

/obj/item/blood_drive
	name = "blood drive"
	desc = "An experimental piece of weaponry, this sword extracts blood and uses it to repair a robotic user. Sadly, it does not work on the dead."
	icon_state = "blood_drive"
	inhand_icon_state = "blood_drive"
	worn_icon_state = "blood_drive"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ISWEAPON
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	block_power = 10
	canblock = TRUE

	block_flags = BLOCKING_ACTIVE | BLOCKING_PROJECTILE
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_DEEP_WOUND
	max_integrity = 200
	resistance_flags = FIRE_PROOF

/obj/item/blood_drive/Initialize(mapload)
	. = ..()
	create_reagents(50)

/obj/item/blood_drive/attack(mob/living/target_mob, mob/living/user, params)
	if(..())
		return TRUE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(iscarbon(target_mob) && target_mob.stat != DEAD)
		var/mob/living/carbon/carbon_mob = target_mob
		carbon_mob.transfer_blood_to(src, force / 2, TRUE)

	user.adjustBruteLoss(floor(-src.reagents.total_volume))
	user.adjustFireLoss(floor(-src.reagents.total_volume * 0.25)) //less effective at healing burn
	reagents.clear_reagents()

/datum/status_effect/ipc_upgrade/deployable/blood_drive
	id = "ipc deployable blood drive"
	name = "Integrated Blood Drive"
	active_power_requirement = 5
	slot = UPGRADE_UTILITY
	action_icon = "blood_drive"
	to_deploy_typepath = /obj/item/blood_drive
	item_type = /obj/item/ipc_upgrade/blood_drive
