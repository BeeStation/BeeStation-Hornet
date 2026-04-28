
/obj/item/research_disk_pinpointer
	name = "research disk locator"
	desc = "A small handheld device that detects nearby research disks. Despite its extremely high sensitivity, the returned signal from research disks is so weak that it only has a short range."
	icon = 'icons/obj/device.dmi'
	icon_state = "researchlocator"
	var/next_use_time = 0
	var/range = 30

/obj/item/research_disk_pinpointer/attack_self(mob/user)
	if(world.time < next_use_time)
		to_chat(user, span_notice("Internal capacitors recharging..."))
		return
	to_chat(user, span_notice("You pulse for nearby research disks."))
	pulse_effect(get_turf(src), 6)
	next_use_time = world.time + 10 SECONDS
	for(var/obj/item/disk/tech_disk/research/research_disk in SSorbits.research_disks)
		var/dist = get_dist(user, research_disk)
		if(dist <= range && isturf(research_disk.loc) && research_disk.get_virtual_z_level() == get_virtual_z_level())
			var/direction = get_dir(user, research_disk)
			dir = direction
			say("Weak signal detected [dir2text(direction)] of current location, [dist] meters away.")
			return
