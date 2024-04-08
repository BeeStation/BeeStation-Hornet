/obj/effect/loot_jobscale/armoury
	jobs = list(
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
		JOB_NAME_HEADOFSECURITY
	)

/obj/effect/loot_jobscale/armoury/energy_gun
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "energy"
	loot = list(/obj/item/gun/energy/e_gun)
	fan_out_items = TRUE
	minimum = 2
	linear_scaling_rate = 0.4

/obj/effect/loot_jobscale/armoury/laser_gun
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "laser"
	loot = list(/obj/item/gun/energy/laser)
	fan_out_items = TRUE
	minimum = 2
	linear_scaling_rate = 0.4

/obj/effect/loot_jobscale/armoury/riot_shotgun
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "riotshotgun"
	loot = list(/obj/item/gun/ballistic/shotgun/riot)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.3

/obj/effect/loot_jobscale/armoury/wt550
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "wt550"
	loot = list(/obj/item/gun/ballistic/automatic/wt550)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.3

/obj/effect/loot_jobscale/armoury/disabler
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "disabler"
	loot = list(/obj/item/gun/energy/disabler)
	fan_out_items = TRUE
	minimum = 2
	linear_scaling_rate = 0.6

/obj/effect/loot_jobscale/armoury/dragnet
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "dragnet"
	loot = list(/obj/item/gun/energy/e_gun/dragnet)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.2

/obj/effect/loot_jobscale/armoury/bulletproof_vest
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "bulletproof"
	loot = list(/obj/item/clothing/suit/armor/bulletproof)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.5

/obj/effect/loot_jobscale/armoury/bulletproof_helmet
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "helmetalt"
	loot = list(/obj/item/clothing/head/helmet/alt)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.5

/obj/effect/loot_jobscale/armoury/riot_suit
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "riot"
	loot = list(/obj/item/clothing/suit/armor/riot)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.4

/obj/effect/loot_jobscale/armoury/riot_helmet
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "riot"
	loot = list(/obj/item/clothing/head/helmet/riot)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.4

/obj/effect/loot_jobscale/armoury/riot_shield
	icon = 'icons/obj/shields.dmi'
	icon_state = "riot"
	loot = list(/obj/item/shield/riot)
	fan_out_items = TRUE
	minimum = 1
	linear_scaling_rate = 0.4
