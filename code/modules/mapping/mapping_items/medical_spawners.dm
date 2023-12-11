/obj/effect/loot_jobscale/medical
	jobs = list(
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_MEDICALDOCTOR,
		JOB_NAME_PARAMEDIC,
	)

/obj/effect/loot_jobscale/medical/medkits
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid-mystery"
	loot = list(/obj/item/storage/firstaid/brute, /obj/item/storage/firstaid/fire, /obj/item/storage/firstaid/toxin, /obj/item/storage/firstaid/o2)
	fan_out_items = TRUE
	linear_scaling_rate = 0.5
	minimum = 1
	maximum = 3

/obj/effect/loot_jobscale/medical/brute_kit
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid-brute"
	loot = list(/obj/item/storage/firstaid/brute)
	fan_out_items = TRUE
	minimum = 1
	maximum = 3
	linear_scaling_rate = 0.5

/obj/effect/loot_jobscale/medical/burn_kit
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid-burn"
	loot = list(/obj/item/storage/firstaid/fire)
	fan_out_items = TRUE
	minimum = 1
	maximum = 3
	linear_scaling_rate = 0.5

/obj/effect/loot_jobscale/medical/tox_kit
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid-toxin"
	loot = list(/obj/item/storage/firstaid/toxin)
	fan_out_items = TRUE
	minimum = 1
	maximum = 3
	linear_scaling_rate = 0.5

/obj/effect/loot_jobscale/medical/oxy_kit
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid-o2"
	loot = list(/obj/item/storage/firstaid/o2)
	fan_out_items = TRUE
	minimum = 1
	maximum = 3
	linear_scaling_rate = 0.5

/obj/effect/loot_jobscale/medical/first_aid_kit
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
	loot = list(/obj/item/storage/firstaid/regular)
	fan_out_items = TRUE
	minimum = 1
	maximum = 3
	linear_scaling_rate = 0.5
