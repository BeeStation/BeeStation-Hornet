

/atom/movable/screen/swarmer
	icon = 'icons/mob/swarmer.dmi'

/atom/movable/screen/swarmer/FabricateTrap
	icon_state = "ui_trap"
	name = "Create trap (Costs 5 Resources)"
	desc = "Creates a trap that will nonlethally shock any non-swarmer that attempts to cross it. (Costs 5 resources)"

/atom/movable/screen/swarmer/FabricateTrap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateTrap()

/atom/movable/screen/swarmer/Barricade
	icon_state = "ui_barricade"
	name = "Create barricade (Costs 5 Resources)"
	desc = "Creates a destructible barricade that will stop any non swarmer from passing it. Also allows disabler beams to pass through. (Costs 5 resources)"

/atom/movable/screen/swarmer/Barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateBarricade()

/atom/movable/screen/swarmer/Replicate
	icon_state = "ui_replicate"
	name = "Replicate (Costs 50 Resources)"
	desc = "Creates another of our kind."

/atom/movable/screen/swarmer/Replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateSwarmer()

/atom/movable/screen/swarmer/RepairSelf
	icon_state = "ui_self_repair"
	name = "Repair self"
	desc = "Repairs damage to our body."

/atom/movable/screen/swarmer/RepairSelf/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.RepairSelf()

/atom/movable/screen/swarmer/ToggleLight
	icon_state = "ui_light"
	name = "Toggle light"
	desc = "Toggles our inbuilt light on or off."

/atom/movable/screen/swarmer/ToggleLight/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ToggleLight()

/atom/movable/screen/swarmer/ContactSwarmers
	icon_state = "ui_contact_swarmers"
	name = "Contact swarmers"
	desc = "Sends a message to all other swarmers, should they exist."

/atom/movable/screen/swarmer/ContactSwarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ContactSwarmers()

/datum/hud/swarmer/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/swarmer/FabricateTrap()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/Barricade()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/Replicate()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/RepairSelf()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/ToggleLight()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/ContactSwarmers()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using
