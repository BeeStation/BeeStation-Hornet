///Invasive spreading lets the plant jump to other trays, the spreadinhg plant won't replace plants of the same type.
/datum/plant_gene/trait/invasive
	name = "Invasive Spreading"

/datum/plant_gene/trait/invasive/on_grow(obj/machinery/hydroponics/H)
	for(var/step_dir in GLOB.alldirs)
		var/obj/machinery/hydroponics/HY = locate() in get_step(H, step_dir)
		if(HY && prob(15))
			if(HY.myseed) // check if there is something in the tray.
				if(HY.myseed.gettype() == H.myseed.gettype() && HY.dead != 0)
					continue //It should not destroy its owm kind.
				qdel(HY.myseed)
				HY.myseed = null
			HY.myseed = H.myseed.Copy()
			HY.age = 0
			HY.dead = 0
			HY.plant_health = HY.myseed.endurance
			HY.lastcycle = world.time
			HY.harvest = 0
			HY.weedlevel = 0 // Reset
			HY.pestlevel = 0 // Reset
			HY.update_icon()
			HY.visible_message("<span class='warning'>The [H.myseed.plantname] spreads!</span>")
