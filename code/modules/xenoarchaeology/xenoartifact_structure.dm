/*
	Pretty much a duplicate of the regular item.
	Look at the item for comment documentation, most of the comments here are just artifacts from the copy paste
	Use this file to house the weird off-shoot artifacts. 
*/

/obj/structure/xenoartifact
	name = "xenoartifact"
	icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	icon_state = "map_editor"
	density = TRUE
	
	var/charge = 0 //How much input the artifact is getting from activator traits
	var/charge_req //This isn't a requirement anymore. This just affects how effective the charge is

	var/material //Associated traits & colour
	var/list/traits = list()
	var/datum/xenoartifact_trait/touch_desc
	var/special_desc = "The Xenoartifact is made from a" //used for special examine circumstance, science goggles
	var/process_type
	var/code //Used for signaler trait
	var/frequency
	var/datum/radio_frequency/radio_connection
	var/min_desc //Just a holder for examine special_desc from minor traits

	var/max_range = 1 //How far his little arms can reach
	var/list/true_target = list()
	var/usedwhen //holder for worldtime
	var/cooldown = 8 SECONDS //Time between uses
	var/cooldownmod = 0 //Extra time traits can add to the cooldown
	COOLDOWN_DECLARE(xenoa_cooldown)

	var/list/icon_slots[4] //Associated with random sprite stuff.
	var/mutable_appearance/icon_overlay 

	var/malfunction_chance //Everytime the artifact is used this increases. When this is successfully proc'd the artifact gains a malfunction and this is lowered. 
	var/malfunction_mod = 1 //How much the chance can change in a sinlge itteration

	var/obj/structure/xenoartifact/little_man_inside_me //this is a temporary solution. Deleting the base artifact also deletes this one's traits too?

	var/logging = TRUE //Noisy artifact can be turned off.

/obj/structure/xenoartifact/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/xenoartifact_pricing)
	AddComponent(/datum/component/discoverable, XENOA_DP, TRUE) //Same values as original artifacts, exploration.

/obj/structure/xenoartifact/Initialize(mapload, var/obj/structure/xenoartifact/X)
	. = ..()
	if(!X)
		qdel(src)
		return
	var/datum/component/xenoartifact_pricing/p = X.GetComponent(/datum/component/xenoartifact_pricing)
	var/datum/component/xenoartifact_pricing/pd = GetComponent(/datum/component/xenoartifact_pricing)
	pd.price = p.price
	p = null
	pd = null
	name = X.name
	material = X.material
	charge_req = X.charge_req*1.5
	special_desc = X.special_desc
	touch_desc = X.touch_desc
	alpha = X.alpha
	traits = X.traits
	little_man_inside_me = X
	little_man_inside_me.forceMove(src)

	for(var/datum/xenoartifact_trait/t as() in traits)
		if(!istype(t, /datum/xenoartifact_trait/minor/dense))
			t.on_init(src)

	var/holdthisplease = rand(1, 3)
	icon_state = "SB[holdthisplease]"//Base
	generate_icon(icon, "SBL[holdthisplease]", material)
	if(prob(70) || icon_slots[1])//Top
		if(!(icon_slots[1])) //Some traits can set this too, it will be set to a code that looks like 9XX
			icon_slots[1] = rand(1, 3)
		generate_icon(icon, "ST[icon_slots[1]]")
		generate_icon(icon, "STL[icon_slots[1]]", material)
		
		if(prob(70) || icon_slots[2])//Bottom
			if(!(icon_slots[2]))
				icon_slots[2] = rand(1, 3)
			generate_icon(icon, "SBTM[icon_slots[2]]")
			generate_icon(icon, "SBTML[icon_slots[2]]", material)

	if(prob(50)  || icon_slots[3])//Left
		if(!(icon_slots[3]))
			icon_slots[3] = rand(1, 2)
		generate_icon(icon, "SL[icon_slots[3]]")
		generate_icon(icon, "SLL[icon_slots[3]]", material)

	if(prob(50) || icon_slots[4])//Right
		if(!(icon_slots[4]))
			icon_slots[4] = rand(1, 2)
		generate_icon(icon, "SR[icon_slots[4]]")
		generate_icon(icon, "SRL[icon_slots[4]]", material)

/obj/structure/xenoartifact/examine(mob/living/carbon/user)
	. = ..()
	if(istype(user.glasses, /obj/item/clothing/glasses/science))
		to_chat(user, "<span class='notice'>[special_desc]</span>")

/obj/structure/xenoartifact/attack_hand(mob/user)
	. = ..()
	if(process_type == IS_LIT) //Snuff out candle
		to_chat(user, "<span class='notice'>You snuff out [name]</span>")
		process_type = null
		return
	if(user.a_intent == INTENT_GRAB)
		touch_desc?.on_touch(src, user)
		return
	SEND_SIGNAL(src, XENOA_INTERACT, null, user, user)

/obj/structure/xenoartifact/attackby(obj/item/I, mob/living/user, params)
	for(var/datum/xenoartifact_trait/t as() in traits)
		t.on_item(src, user, I)
	if(!(COOLDOWN_FINISHED(src, xenoa_cooldown))||user?.a_intent == INTENT_GRAB||istype(I, /obj/item/xenoartifact_label)||istype(I, /obj/item/xenoartifact_labeler))
		return
	..()

/*
	check_charge() is essentially what runs all the minor, major, and malf trait activations. 
	This process also culls any irrelivent targets in reference to max_range and calculates the true charge.
	True charge is simply, almost, the average of the charge and charge_req. This allows for a unique varience of 
	output from artifacts, generally producing some funny results too.
	
*/
/obj/structure/xenoartifact/proc/check_charge(mob/user, charge_mod)
	if(logging)
		log_game("[user] attempted to activate [src] at [world.time]. Located at [x] [y] [z].")
	if(prob(malfunction_chance)) //See if we pick up an malfunction
		var/datum/xenoartifact_trait/t = pick(subtypesof(/datum/xenoartifact_trait/malfunction))
		traits+=new t
		malfunction_chance=malfunction_chance*0.2
	else    
		malfunction_chance+=malfunction_mod

	for(var/atom/M in true_target) //Cull
		if(get_dist(get_turf(src), get_turf(M)) > max_range)   
			true_target -= M
	if(true_target.len < 1) //Don't bother if there aren't any targets
		return

	charge+=charge_mod
	if(COOLDOWN_FINISHED(src, xenoa_cooldown))//Execution of traits here
		for(var/datum/xenoartifact_trait/t as() in traits)//Minor traits aren't apart of the target loop
			if(!istype(t, /datum/xenoartifact_trait/major))
				t.activate(src, user, user)
		charge = (charge+charge_req)/1.9 //Not quite an average. Generally produces slightly higher results.     
		for(var/atom/M in true_target)
			create_beam(M)
			for(var/datum/xenoartifact_trait/major/t as() in traits) //Major
				if(logging)
					log_game("[src] activated trait [t]. Located at [x] [y] [z]")
				t.activate(src, M, user)
			if(!(get_trait(/datum/xenoartifact_trait/minor/aura))) //Quick fix for bug that selects multiple targets for noraisin
				break
		COOLDOWN_START(src, xenoa_cooldown, cooldown+cooldownmod)
	charge = 0
	true_target = list()

/obj/structure/xenoartifact/proc/get_proximity(range) //Gets a singular bam beano
	for(var/mob/living/M in oview(range, get_turf(src)))
		. = process_target(M)
	if(isliving(loc))
		. = loc
	return

/obj/structure/xenoartifact/proc/get_trait(typepath) //Returns the desired trait and it's values if it's in the artifact's
	return (locate(typepath) in traits)

/obj/structure/xenoartifact/proc/generate_icon(var/icn, var/icnst = "", colour) //Add extra icon overlays
	icon_overlay = mutable_appearance(icn, icnst)
	icon_overlay.layer = FLOAT_LAYER //Not doing this fucks the object icons when you're holding it
	icon_overlay.appearance_flags = RESET_ALPHA// Not doing this fucks the alpha?
	icon_overlay.alpha = alpha//
	if(colour)
		icon_overlay.color = colour
	add_overlay(icon_overlay)

/obj/structure/xenoartifact/proc/process_target(atom/target)
	. = target
	if(isliving(target?.loc))
		. = target?.loc
	//Have to type convert to access pulling
	var/mob/living/M = istype(target, /mob/living) ? target : null
	if(M && M?.pulling)
		. = M?.pulling
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/on_target_del, target)
	return

/obj/structure/xenoartifact/proc/on_target_del(atom/target)
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	true_target -= target
	target = null

/obj/structure/xenoartifact/proc/create_beam(atom/target) //Helps show how the artifact is working. Hint stuff.
	if(!target.loc)
		return
	var/datum/beam/xenoa_beam/B = new(src.loc, target, time=1.5 SECONDS, beam_icon='icons/obj/xenoarchaeology/xenoartifact.dmi', beam_icon_state="xenoa_beam", btype=/obj/effect/ebeam/xenoa_ebeam)
	B.set_color(material)
	INVOKE_ASYNC(B, /datum/beam/xenoa_beam.proc/Start)

/obj/structure/xenoartifact/proc/default_activate(chr, mob/user, atom/target) //used for some stranger cases. structure specific cases that don't fall under the default templates. See battery activator.
	if(!(COOLDOWN_FINISHED(src, xenoa_cooldown)))
		return FALSE
	charge = chr
	true_target += process_target(target)
	check_charge(user)
	return TRUE

/obj/structure/xenoartifact/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)

/obj/structure/xenoartifact/proc/send_signal(var/datum/signal/signal)
	if(!radio_connection||!signal)
		return
	radio_connection.post_signal(src, signal)

/obj/structure/xenoartifact/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return
	SEND_SIGNAL(src, XENOA_SIGNAL, null, get_proximity(max_range), get_proximity(max_range))

/obj/structure/xenoartifact/process(delta_time) //I can't be bothered getting the actual charge value for the traits at the moment, so these are fine for now.
	switch(process_type)
		if(IS_LIT)
			true_target = list(get_proximity(min(max_range, 5)))
			if(get_proximity(min(max_range, 5)))
				visible_message("<span class='danger'>The [name] flicks out.</span>")
				default_activate(25, null, null)
				process_type = null
				return PROCESS_KILL
		if(IS_TICK)
			visible_message("<span class='notice'>The [name] ticks.</span>")
			true_target = list(get_proximity(min(max_range, 5)))
			default_activate(25, null, null)
			if(prob(13))
				process_type = null
				return PROCESS_KILL
		else    
			return PROCESS_KILL

/obj/structure/xenoartifact/Destroy()
	qdel(little_man_inside_me)
	for(var/datum/xenoartifact_trait/t as() in traits)
		t.on_del(src)
		qdel(t)
	SSradio.remove_object(src, frequency)
	qdel(radio_connection)
	qdel(traits)
	qdel(touch_desc)
	for(var/atom/movable/C in contents)
		var/atom/movable/AM = C
		AM.forceMove(get_turf(loc))
	..()
