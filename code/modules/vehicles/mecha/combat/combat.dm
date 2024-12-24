/obj/vehicle/sealed/mecha/combat
	force = 30
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	internal_damage_threshold = 50
	armor_type = /datum/armor/mecha_combat
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	destruction_knockdown_duration = 8 SECONDS
	exit_delay = 40


/datum/armor/mecha_combat
	melee = 30
	bullet = 30
	laser = 15
	energy = 20
	bomb = 20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/combat/restore_equipment()
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	return ..()

/obj/vehicle/sealed/mecha/combat/proc/max_ammo() //Max the ammo stored for Nuke Ops mechs, or anyone else that calls this
	for(var/obj/item/I in equipment)
		if(istype(I, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/))
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = I
			gun.projectiles_cache = gun.projectiles_cache_max
