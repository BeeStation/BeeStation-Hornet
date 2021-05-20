/obj/item/organ/wings
	name = "Pair of wings"
	desc = "A pair of wings. They look skinny and useless"
	icon_state = "angelwings"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_WINGS
	var/flight_level = WINGS_COSMETIC
	var/basewings = "wings" //right now, this just determines whether the wings are normal wings or moth wings
	var/wing_type = "Angel"
	var/canopen = TRUE
	var/wingsound = null
	var/datum/action/innate/flight/fly

/obj/item/organ/wings/Initialize()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		Refresh(H)

/obj/item/organ/wings/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		Refresh(H)

/obj/item/organ/wings/proc/Refresh(mob/living/carbon/human/H)
	if(!(basewings in H.dna.species.mutant_bodyparts))
		H.dna.species.mutant_bodyparts |= basewings
		H.dna.features[basewings] = wing_type
		H.update_body()
	if(flight_level >= WINGS_FLYING)
		fly = new
		fly.Grant(H)

/obj/item/organ/wings/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= basewings
		wing_type = H.dna.features[basewings]
		H.update_body()
	if(flight_level >= WINGS_FLYING)
		fly.Remove(H)
		QDEL_NULL(fly)
		if(H.movement_type & FLYING)
			H.dna.species.toggle_flight(H)

/obj/item/organ/wings/proc/toggleopen(mob/living/carbon/human/H) //opening and closing wings are purely cosmetic
	if(!canopen)
		return FALSE
	if(wingsound)
		playsound(H, wingsound, 100, 7)
	if(basewings == "wings")
		if("wings" in H.dna.species.mutant_bodyparts)
			H.dna.species.mutant_bodyparts -= "wings"
			H.dna.species.mutant_bodyparts |= "wingsopen"
		else if("wingsopen" in H.dna.species.mutant_bodyparts)
			H.dna.species.mutant_bodyparts -= "wingsopen"
			H.dna.species.mutant_bodyparts |= "wings"
		else //it appears we don't actually have wing icons. apply them!!
			Refresh(H)
		H.update_body()
		return TRUE
	return FALSE

/obj/item/organ/wings/cybernetic
	name = "cybernetic wingpack"
	desc = "A compact pair of mechanical wings, which use the atmosphere to create thrust."
	icon_state = "wingpack"
	flight_level = WINGS_FLYING
	wing_type = "Robot"
	wingsound = 'sound/items/change_jaws.ogg'
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/wings/cybernetic/emp_act(severity)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/datum/species/S = H.dna.species
		var/outofcontrol = ((rand(1, 10)) * severity)
		to_chat(H, "<span_class = 'userdanger'>You lose control of your [src]!</span>")
		while(outofcontrol)
			if(S.CanFly(H))
				if(H.movement_type & FLYING)
					var/throw_dir = pick(GLOB.alldirs)
					var/atom/throw_target = get_edge_target_turf(H, throw_dir)
					H.throw_at(throw_target, 5, 4)
					if(prob(10))
						S.toggle_flight(H)
				else
					S.toggle_flight(H)
					if(prob(50))
						stoplag(5)
						S.toggle_flight(H)
			else
				H.Togglewings()
			outofcontrol --
			stoplag(5)

/obj/item/organ/wings/cybernetic/ayy
	name = "advanced cybernetic wingpack"
	desc = "A compact pair of mechanical wings. They are equipped with miniaturized void engines, and can fly in any atmosphere, or lack thereof."
	flight_level = WINGS_MAGIC

/obj/item/organ/wings/moth
	name = "pair of moth wings"
	desc = "A pair of moth wings."
	icon_state = "mothwings"
	flight_level = WINGS_FLIGHTLESS
	basewings = "moth_wings"
	wing_type = "plain"
	canopen = FALSE

/obj/item/organ/wings/moth/robust
	desc = "A pair of moth wings. They look robust enough to fly in an atmosphere"
	flight_level = WINGS_FLYING

/obj/item/organ/wings/moth/on_life()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(flight_level >= WINGS_FLIGHTLESS && H.bodytemperature >= 800 && H.fire_stacks > 0)
			flight_level = WINGS_COSMETIC
			to_chat(H, "<span class='danger'>Your precious wings burn to a crisp!</span>")
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "burnt_wings", /datum/mood_event/burnt_wings)
			H.dna.features["moth_wings"] = "Burnt Off"
			wing_type = "Burnt Off"
			H.dna.species.handle_mutant_bodyparts(H)

/obj/item/organ/wings/angel
	name = "pair of feathered wings"
	desc = "A pair of feathered wings. They seem robust enough for flight"
	flight_level = WINGS_FLYING

/obj/item/organ/wings/dragon
	name = "pair of dragon wings"
	desc = "A pair of dragon wings. They seem robust enough for flight"
	icon_state = "dragonwings"
	flight_level = WINGS_FLYING
	wing_type = "Dragon"

/obj/item/organ/wings/dragon/fake
	desc = "A pair of fake dragon wings. They're useless"
	flight_level = WINGS_COSMETIC

/obj/item/organ/wings/bee
	name = "pair of bee wings"
	desc = "A pair of bee wings. They seem tiny and undergrown"
	icon_state = "beewings"
	flight_level = WINGS_COSMETIC
	actions_types = list(/datum/action/item_action/organ_action/use/bee_dash)
	wing_type = "Bee"

/datum/action/item_action/organ_action/use/bee_dash
	var/jumpdistance = 3
	var/jumpspeed = 1
	var/recharging_rate = 100
	var/recharging_time = 0

/datum/action/item_action/organ_action/use/bee_dash/Trigger()
	var/mob/living/carbon/L = owner

	if(L.stat != CONSCIOUS || L.buckling || L.restrained()) // Has to be concious and unbuckled
		return
	if(recharging_time > world.time)
		to_chat(L, "<span class='warning'>The wings aren't ready to dash yet!</span>")
		return
	var/datum/gas_mixture/environment = L.loc.return_air()
	if(environment && !(environment.return_pressure() > 30))
		to_chat(L, "<span class='warning'>The atmosphere is too thin for you to dash!</span>")
		return

	var/turf/target = get_edge_target_turf(L, L.dir) //represents the user's direction
	var/hoppingtable = FALSE // Triggers the trip
	var/jumpdistancemoved = jumpdistance // temp jumpdistance
	var/turf/checkjump = get_turf(L)

	for(var/i in 1 to jumpdistance) //This is how hiero club find the tiles in front of it, tell me/fix it if there's a better way
		var/turf/T = get_step(checkjump, L.dir)
		if(T.density || !T.ClickCross(invertDir(L.dir), border_only = 1))
			break
		if(locate(/obj/structure/table) in T) // If there's a table, trip
			hoppingtable = TRUE
			jumpdistancemoved = i
			break
		if(!T.ClickCross(L.dir)) // Check for things other than tables that would block flight at the T turf
			break
		checkjump = get_step(checkjump, L.dir)

	var/datum/callback/crashcallback
	if(hoppingtable)
		crashcallback = CALLBACK(src, .proc/crash_into_table, get_step(checkjump, L.dir))
	if(L.throw_at(target, jumpdistancemoved, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = crashcallback, force = MOVE_FORCE_WEAK))
		playsound(L, 'sound/creatures/bee.ogg', 50, 1, 1)
		L.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(L, "<span class='warning'>Something prevents you from dashing forward!</span>")

/datum/action/item_action/organ_action/use/bee_dash/proc/crash_into_table(turf/tableturf)
	if(owner.loc == tableturf)
		var/mob/living/carbon/L = owner
		L.take_bodypart_damage(10,check_armor = TRUE)
		L.Paralyze(40)
		L.visible_message("<span class='danger'>[L] crashes into a table, falling over!</span>",\
			"<span class='userdanger'>You violently crash into a table!</span>")
		playsound(src,'sound/weapons/punch1.ogg',50,1)

/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/S = H.dna.species
	if(S.CanFly(H))
		S.toggle_flight(H)
		if(!(H.movement_type & FLYING))
			to_chat(H, "<span class='notice'>You settle gently back onto the ground...</span>")
		else
			to_chat(H, "<span class='notice'>You beat your wings and begin to hover gently above the ground...</span>")
			H.set_resting(FALSE, TRUE)
