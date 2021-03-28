
/datum/uplink_item/suits/hardsuit/nanotrasen
	name = "Emergency Response Hardsuit"
	desc = "An incredibly strong Nanotrasen brand hardsuit issued to Emergency Response Personnel. \
		It is fitted with an advanced tracking system and environmental protection."
	item = /obj/item/clothing/suit/space/hardsuit/ert
	cost = 8
	syndicate_station_mode = SYNDIE_MODE_ONLY
	exclude_modes = list(/datum/game_mode/nuclear)

/datum/uplink_item/suits/hardsuit/nanotrasen/shielded
	name = "Shielded Emergency Response Hardsuit"
	desc=  "An upgraded version of the emergency response suit, with an integrated shielding system capable \
		of deflecting 3 hazards before recharging."
	cost = 30
	item = /obj/item/clothing/suit/space/hardsuit/shielded/syndie/nanotrasen
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)
	exclude_modes = list()

/datum/uplink_item/device_tools/encryptionkey/centcom
	name = "Nanotrasen Encryption Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to all station department channels \
			as well as talk on an encrypted Nanotrasen channel with other agents that have the same key."
	item = /obj/item/encryptionkey/headset_cent/hear_all
	cost = 2
	surplus = 75
	exclude_modes = list(/datum/game_mode/incursion) //To prevent traitors from immediately outing the hunters to security.
	restricted = TRUE
	syndicate_station_mode = SYNDIE_MODE_ONLY

/datum/uplink_item/dangerous/recharging_belt
	name = "Recharging Belt"
	desc = "A wired belt that inductively saps power from nearby APCs and uses it to charge its contents. \
		Can recharge energy based weapons and energy magasines."
	item = /obj/item/storage/belt/recharging_belt
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)
	cost = 18
	syndicate_station_mode = SYNDIE_MODE_ONLY

/datum/uplink_item/dangerous/tesla_revolver
	name = "Tesla Revolver"
	desc = "A powerful revolver that uses an internal nuclear fission reactor to generate a massive potential difference \
		before discharging a ball of energy in whatever direction the gun is facing. Recharges automatically."
	item = /obj/item/gun/energy/tesla_revolver/self_recharge
	cost = 6
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/dangerous/laser_carbine
	name = "Laser Carbine"
	desc = "A high-energy, fully automatic, magasine loaded carbine which fires energy based rounds."
	item = /obj/item/gun/ballistic/automatic/laser/laser_carbine
	cost = 12
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/dangerous/tactical_energy
	name = "Tactical Energy Gun"
	desc = "A fully automatic, fast firing energy gun which fires heavy lasers using an internal power cell."
	item = /obj/item/gun/energy/e_gun/tactical
	cost = 14
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/dangerous/pulse_pistol
	name = "M1911-P"
	desc = "A modified M1911 which fires destructive pulse rounds. Has a relatively small power cell, so needs constant recharging."
	item = /obj/item/gun/energy/pulse/pistol/m1911/finite
	cost = 16
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/dangerous/energy_gun
	name = "Energy Gun"
	desc = "A standard issue energy gun given out to common Nanotrasen security forces."
	item = /obj/item/gun/energy/e_gun
	cost = 6
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/dangerous/shotgun
	name = "Combat Shotgun"
	desc = "A self-loading combat shotgun used by Nanotrasen pointmen."
	item = /obj/item/gun/ballistic/shotgun/automatic/combat
	cost = 9
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/dangerous/maeteba
	name = "Mateba Revolver"
	desc = "A powerful revolver used by Nanotrasen officers."
	item = /obj/item/gun/ballistic/revolver/mateba
	cost = 8
	syndicate_station_mode = SYNDIE_MODE_ONLY

/datum/uplink_item/ammo/energyclip
	name = "Energy Clip"
	desc = "A 20 round rechargable battery compatible with the Nanotrasen laser carbine."
	item = /obj/item/ammo_box/magazine/recharge/laser
	cost = 2
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/ammo/energyclip_pulse
	name = "Pulse Energy Clip"
	desc = "A 16 round rechargable particle pulser which fires destructive pulse lasers. Compatible with the laser carbine"
	item = /obj/item/ammo_box/magazine/recharge/laser/pulse
	cost = 4
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/ammo/energyclip_highcap
	name = "High Capacity Energy Clip"
	desc = "A 38 round rechargable battery compatible with the laser carbine."
	item = /obj/item/ammo_box/magazine/recharge/laser/high_cap
	cost = 3
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/ammo/shotgun
	name = "Lethal Shotgun Rounds"
	desc = "A small box containing 7 lethal shotgun shells."
	item = /obj/item/storage/box/lethalshot
	cost = 2
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/ammo/shotgun_pulse
	name = "Pulse Shotgun Rounds"
	desc = "A small box containing 7 heavy pulse shotgun shells."
	item = /obj/item/storage/box/pulseshot
	cost = 4
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/ammo/shotgun_laser
	name = "Laser Shotgun Rounds"
	desc = "A small box containing 7 laser shotgun shells."
	item = /obj/item/storage/box/lasershot
	cost = 4
	syndicate_station_mode = SYNDIE_MODE_ONLY
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)
