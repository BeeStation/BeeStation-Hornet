/datum/mutation/geladikinesis
	name = "Geladikinesis"
	desc = "Allows the user to concentrate moisture and sub-zero forces into snow."
	quality = POSITIVE
	instability = 10
	difficulty = 10
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/snow

/obj/effect/proc_holder/spell/targeted/conjure_item/snow
	name = "Create Snow"
	desc = "Concentrates cryokinetic forces to create snow, useful for snow-like construction."
	item_type = /obj/item/stack/sheet/snow

	charge_max = 50
	delete_old = FALSE
	action_icon_state = "snow"

/datum/mutation/wax_saliva
	name = "Waxy Saliva"
	desc = "Allows the user to secrete wax."
	quality = POSITIVE
	instability = 10
	difficulty = 10
	synchronizer_coeff = 1
	locked = TRUE
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/wax

/obj/effect/proc_holder/spell/targeted/conjure_item/wax
	name = "Secrete Wax"
	desc = "Concentrate to spit out some wax, useful for bee-themed construction."
	item_type = /obj/item/stack/sheet/wax
	charge_max = 50
	delete_old = FALSE
	action_icon_state = "honey"

/datum/mutation/cryokinesis
	name = "Cryokinesis"
	desc = "Draws negative energy from the sub-zero void to freeze surrounding temperatures at subject's will."
	quality = POSITIVE //upsides and downsides
	instability = 20
	difficulty = 12
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/aimed/cryo

/obj/effect/proc_holder/spell/aimed/cryo
	name = "Cryobeam"
	desc = "This power fires a frozen bolt at a target."
	charge_max = 150
	cooldown_min = 150
	clothes_req = FALSE
	range = 3
	projectile_type = /obj/projectile/temp/cryo
	base_icon_state = "icebeam"
	action_icon_state = "icebeam"
	active_msg = "You focus your cryokinesis!"
	deactive_msg = "You relax."
	active = FALSE

