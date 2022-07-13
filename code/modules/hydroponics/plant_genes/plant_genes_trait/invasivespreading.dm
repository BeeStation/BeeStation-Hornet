///Invasive spreading lets the plant jump to other trays, the spreadinhg plant won't replace plants of the same type.
/datum/plant_gene/trait/invasive
	name = "Invasive Spreading"
	desc = "This makes your plant spreading to nearby trays or dirts."
	var/chance = 100
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	research_needed = 1

/* <Behavior table>
	 <A type>
		[on_squash] ...
		[on_aftersquash] ...

	 <B type>
		[on_slip] ...
		[on_attack] ...
		[on_throw_impact] ...

	 <C type>
		[on_attackby] ...
		[on_consume] ...
		[on_grow] whenever a plant cycles, 15% chance to spread to nearby tray.
		[on_new_plant] ...
		[on_new_seed] ...
		[on_removal] ...
 */

/datum/plant_gene/trait/invasive/Initialize(mapload)
	desc += "[chance]% chance to spread."
	. = ..()

/datum/plant_gene/trait/invasive/on_grow(obj/machinery/hydroponics/H)
	for(var/step_dir in GLOB.alldirs)
		var/obj/machinery/hydroponics/HY = locate() in get_step(H, step_dir)
		if(HY && prob(chance))
			world.log << "checked"
			if(HY.myseed) // check if there is something in the tray.
				var/obj/item/seeds/S = HY.myseed
				if(S.plantname == S.plantname && S.research_identifier == S.research_identifier && HY.dead != 0)
					continue //It should not destroy its owm kind.
				qdel(S)
				HY.myseed = null
			var/obj/item/seeds/S_from = H.myseed
			HY.myseed = S_from.Copy()
			HY.plant_seed(HY.myseed, TRUE)
			HY.visible_message("<span class='warning'>The [H.myseed.plantname] spreads!</span>")
