/datum/plant_gene/trait/cell_charge
	// Cell recharging trait. Charges all mob's power cells to (potency*rate)% mark when eaten.
	// Generates sparks on squash.
	// Small (potency*rate*5) chance to shock squish or slip target for (potency*rate*5) damage.
	// Also affects plant batteries see capatative cell production datum
	name = "Electrical Activity"
	rate = 0.2

/datum/plant_gene/trait/cell_charge/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/C)
	var/power = round(G.seed.potency*rate)
	if(prob(power))
		C.electrocute_act(power, G, 1, 1)
		var/turf/T = get_turf(C)
		if(C.ckey != G.fingerprintslast)
			C.investigate_log("[C] has slipped on an electric plant at [AREACOORD(T)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
			log_combat(C, G, "slipped on and got electrocuted by", null, "with the power of 10. Last fingerprint: [G.fingerprintslast]")

/datum/plant_gene/trait/cell_charge/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/power = G.seed.potency*rate
		if(prob(power))
			C.electrocute_act(round(power), G, 1, 1)
			if(C.ckey != G.fingerprintslast)
				log_combat(G.thrownby, C, "hit and electrocuted", G, "at [AREACOORD(G)] with power of [power]")
				C.investigate_log("[C] has been hit by an electric plant at [AREACOORD(G)] with power of [power]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)

/datum/plant_gene/trait/cell_charge/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target)
	if(!G.reagents.total_volume)
		var/batteries_recharged = 0
		for(var/obj/item/stock_parts/cell/C in target.GetAllContents())
			var/newcharge = min(G.seed.potency*0.01*C.maxcharge, C.maxcharge)
			if(C.charge < newcharge)
				C.charge = newcharge
				if(isobj(C.loc))
					var/obj/O = C.loc
					O.update_icon() //update power meters and such
				C.update_icon()
				batteries_recharged = 1
		if(batteries_recharged)
			to_chat(target, "<span class='notice'>Your batteries are recharged!</span>")
