/*
	Apply bee buff
*/
/obj/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = TRUE
	armor_flag = ENERGY
	martial_arts_no_deflect = TRUE

/obj/projectile/energy/floramut/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/datum/component/planter/plant_tray = target.GetComponent(/datum/component/planter)
	if(!plant_tray || !length(plant_tray.plants))
		return
	for(var/datum/component/plant/plant_comp as anything in plant_tray.plants)
		SEND_SIGNAL(plant_comp, COMSIG_PLANT_BEE_BUFF)

/*
	Removes all weeds
*/
/obj/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = TRUE
	armor_flag = ENERGY
	martial_arts_no_deflect = TRUE

/obj/projectile/energy/florayield/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/datum/component/planter/plant_tray = target.GetComponent(/datum/component/planter)
	plant_tray?.weed_level = 0

