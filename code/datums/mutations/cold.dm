/datum/mutation/geladikinesis
	name = "Geladikinesis"
	desc = "Allows the user to concentrate moisture and sub-zero forces into snow."
	quality = POSITIVE
	instability = 10
	difficulty = 10
	energy_coeff = 1
	power_path = /datum/action/spell/conjure_item/snow

/datum/action/spell/conjure_item/snow
	name = "Create Snow"
	desc = "Concentrates cryokinetic forces to create snow, useful for snow-like construction."
	button_icon_state = "snow"

	cooldown_time = 5 SECONDS
	spell_requirements = NONE
	mindbound = FALSE
	item_type = /obj/item/stack/sheet/snow
	delete_old = FALSE

/datum/mutation/wax_saliva
	name = "Waxy Saliva"
	desc = "Allows the user to secrete wax."
	quality = POSITIVE
	instability = 10
	difficulty = 10
	energy_coeff = 1
	locked = TRUE
	power_path = /datum/action/spell/conjure_item/wax

/datum/action/spell/conjure_item/wax
	name = "Secrete Wax"
	desc = "Concentrate to spit out some wax, useful for bee-themed construction."
	item_type = /obj/item/stack/sheet/wax
	cooldown_time = 5 SECONDS
	delete_old = FALSE
	spell_requirements = NONE
	button_icon_state = "honey"
	mindbound = FALSE

/datum/mutation/cryokinesis
	name = "Cryokinesis"
	desc = "Draws negative energy from the sub-zero void to freeze surrounding temperatures at subject's will."
	quality = POSITIVE //upsides and downsides
	instability = 20
	difficulty = 12
	energy_coeff = 1
	power_coeff = 1
	power_path = /datum/action/spell/pointed/projectile/cryo

/datum/action/spell/pointed/projectile/cryo
	name = "Cryobeam"
	desc = "This power fires a frozen bolt at a target."
	button_icon_state = "icebeam0"
	cooldown_time = 15 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	mindbound = FALSE
	base_icon_state = "icebeam"
	active_msg = "You focus your cryokinesis!"
	deactive_msg = "You relax."
	projectile_type = /obj/projectile/temp/cryo
