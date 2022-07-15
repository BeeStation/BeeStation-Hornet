/datum/plant_gene/trait/cell_charge
	// Cell recharging trait. Charges all mob's power cells to (potency*rate)% mark when eaten.
	// Generates sparks on squash.
	// Small (potency*rate*5) chance to shock squish or slip target for (potency*rate*5) damage.
	// Also affects plant batteries see capatative cell production datum
	name = "Electrical Activity"
	desc = "This makes your plants electrifying. It will boost the battery power if it can be made as a power cell."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	rate = 0.2
	research_needed = 1

/* <Behavior table>
	 <A type>
		[on_squash] activate the effect
		[on_aftersquash] ...

	 <B type>
		[on_slip] activate the effect
		[on_attack] ... (works through squash)
		[on_throw_impact] ... (works through squash)

	 <C type>
		[on_attackby] ...
		[on_consume] activate the effect (another one)
		[on_grow] ...
		[on_new_plant] ...
		[on_new_seed] ...
		[on_removal] ...
 */

/datum/plant_gene/trait/cell_charge/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	activate_effect(G, target, p_method)

/datum/plant_gene/trait/cell_charge/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/C, p_method)
	activate_effect(G, C, p_method)

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
			return TRUE
	return FALSE

/datum/plant_gene/trait/cell_charge/proc/activate_effect(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method="attack")
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/power = G.seed.potency*rate
		if(prob(power))
			C.electrocute_act(round(power), G, 1, 1)
			if(C?.ckey != G.fingerprintslast)
				else if(p_method & PLANT_ACTIVATED_SLIP)
					C.investigate_log("has been slipped, and electrocuted by an electric plant at [AREACOORD(G)] with power of [power]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
					log_game("[key_name(C)] has been slipped, and electrocute by an electric plant at [AREACOORD(G)] with power of [power]. Last fingerprint: [G.fingerprintslast]. #botany.")
				else if(p_method & PLANT_ACTIVATED_ATTACK)
					C.investigate_log("has been attacked, and electrocuted by an electric plant at [AREACOORD(G)] with power of [power]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
					log_game("[key_name(C)] has been attacked and electrocute by an electric plant at [AREACOORD(G)] with power of [power]. Last fingerprint: [G.fingerprintslast]. #botany.")
				else if(p_method & PLANT_ACTIVATED_THROW)
					var/mob/thrown_by = G.thrownby?.resolve()
					C.investigate_log("has been hit by a thrown electric plant at [AREACOORD(G)] with power of [power]. Thrower: [(thrown_by || "(unknown)")]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
					log_combat((thrown_by || "(unknown)"), C, "hit and electrocuted", G, "at [AREACOORD(G)] with power of [power]. #botany.")


	/**

	var/power = round(G.seed.potency*rate)
	if(prob(power))
		C.electrocute_act(power, G, 1, 1)
		var/turf/T = get_turf(C)
		if(C.ckey != G.fingerprintslast)
			C.investigate_log("[C] has slipped on an electric plant at [AREACOORD(T)]. Last fingerprint: [G.fingerprintslast].", INVESTIGATE_BOTANY)
			log_combat(C, G, "slipped on and got electrocuted by", null, "with the power of 10. Last fingerprint: [G.fingerprintslast]")

 */

