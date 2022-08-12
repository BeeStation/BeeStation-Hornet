/proc/generate_reward_value(amount)
	var/amount_left = amount * rand(0.8, 1.4)
	var/split = rand(1, 3)
	var/amount_per_item = amount_left/split

	. = list()

	for(var/i in 1 to split)
		//Pick an item close to the wanted amount
		var/selected_item = SSorbits.get_reward_item(amount_per_item)
		. += selected_item

/datum/controller/subsystem/processing/orbits/proc/generate_reward_loot()
	rewards = list()
	//Allows you to create an energy gun
	rewards[/obj/item/focusing_crystal] = 3500
	rewards[/obj/item/focusing_crystal/split] = 5000
	rewards[/obj/item/focusing_crystal/refractive] = 4000
	rewards[/obj/item/focusing_crystal/robust] = 4000
	rewards[/obj/item/focusing_crystal/speed] = 4000
	rewards[/obj/item/focusing_crystal/xray] = 7000
	rewards[/obj/item/focusing_crystal/unstable] = 5000
	rewards[/obj/item/focusing_crystal/supermatter] = 5000
	//Elite weapons
	rewards[/obj/item/gun/energy/beam_rifle] = 14000
	rewards[/obj/item/gun/energy/xray] = 11000
	//Alien Weapons
	rewards[/obj/item/gun/energy/vortex] = 12000
	//Utility
	rewards[/obj/item/storage/box/hardsuit_tracking_upgrades] = 8000
