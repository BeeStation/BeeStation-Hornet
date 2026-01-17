/obj/machinery/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray"
	density = TRUE
	pixel_z = 8
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	circuit = /obj/item/circuitboard/machine/hydroponics
	idle_power_usage = 5000
	use_power = NO_POWER_USE
	var/waterlevel = 100	//The amount of water in the tray (max 100)
	var/maxwater = 100		//The maximum amount of water in the tray
	var/nutrilevel = 10		//The amount of nutrient in the tray (max 10)
	var/maxnutri = 10		//The maximum nutrient of water in the tray
	var/pestlevel = 0		//The amount of pests in the tray (max 10)
	var/weedlevel = 0		//The amount of weeds in the tray (max 10)
	var/yieldmod = 1		//Nutriment's effect on yield
	var/mutmod = 1			//Nutriment's effect on mutations
	var/toxic = 0			//Toxicity in the tray?
	var/age = 0				//Current age
	var/dead = 0			//Is it dead?
	var/plant_health		//Its health
	var/lastproduce = 0		//Last time it was harvested
	var/lastcycle = 0		//Used for timing of cycles.
	var/cycledelay = 30 SECONDS //Time between each growth cycle
	var/harvest = 0			//Ready to harvest?
	var/obj/item/seeds/myseed = null	//The currently planted seed
	var/rating = 1
	var/unwrenchable = 1
	var/recent_bee_visit = FALSE //Have we been visited by a bee recently, so bees dont overpollinate one plant
	var/using_irrigation = FALSE //If the tray is connected to other trays via irrigation hoses
	var/self_sufficiency_req = 20 //Required total dose to make a self-sufficient hydro tray. 1:1 with earthsblood.
	var/self_sufficiency_progress = 0
	var/self_sustaining = FALSE //If the tray generates nutrients and water on its own


/obj/machinery/hydroponics/constructable
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray3"

/obj/machinery/hydroponics/constructable/RefreshParts()
	var/tmp_capacity = 0
	for (var/obj/item/stock_parts/matter_bin/M in component_parts)
		tmp_capacity += M.rating
	for (var/obj/item/stock_parts/manipulator/M in component_parts)
		rating = M.rating
	maxwater = tmp_capacity * 50 // Up to 300
	maxnutri = tmp_capacity * 5 // Up to 30

/obj/machinery/hydroponics/constructable/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Tray efficiency at <b>[rating*100]%</b>.")


/obj/machinery/hydroponics/Destroy()
	if(myseed)
		qdel(myseed)
		myseed = null
	return ..()

/obj/machinery/hydroponics/constructable/attackby(obj/item/I, mob/living/user, params)
	if (!user.combat_mode)
		// handle opening the panel
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
			return

		// handle deconstructing the machine, if permissible
		if(I.tool_behaviour == TOOL_CROWBAR && using_irrigation)
			to_chat(user, span_warning("Disconnect the hoses first!"))
			return
		else if(default_deconstruction_crowbar(I))
			return

	return ..()

/obj/machinery/hydroponics/proc/FindConnected()
	var/list/connected = list()
	var/list/processing_atoms = list(src)

	while(processing_atoms.len)
		var/atom/a = processing_atoms[1]
		for(var/step_dir in GLOB.cardinals)
			var/obj/machinery/hydroponics/h = locate() in get_step(a, step_dir)
			// Soil plots aren't dense
			if(h && h.using_irrigation && h.density && !(h in connected) && !(h in processing_atoms))
				processing_atoms += h

		processing_atoms -= a
		connected += a

	return connected


/obj/machinery/hydroponics/bullet_act(obj/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(!myseed)
		return ..()
	if(istype(Proj , /obj/projectile/energy/floramut))
		mutate()
	else if(istype(Proj , /obj/projectile/energy/florayield))
		return myseed.bullet_act(Proj)
	else
		return ..()

/obj/machinery/hydroponics/power_change()
	. = ..()
	if(machine_stat & NOPOWER && self_sustaining)
		self_sustaining = FALSE

/obj/machinery/hydroponics/process(delta_time)
	var/needs_update = 0 // Checks if the icon needs updating so we don't redraw empty trays every time

	if(myseed && (myseed.loc != src))
		myseed.forceMove(src)

	if(!powered() && self_sustaining)
		visible_message("<span class='warning'>[name]'s auto-grow functionality shuts off!</span>")
		update_use_power(NO_POWER_USE)
		self_sustaining = FALSE
		update_appearance()

	if(self_sustaining)
		adjustNutri(0.5 * delta_time)
		adjustWater(rand(1,2) * delta_time * 0.5)
		adjustWeeds(-1 * delta_time)
		adjustPests(-1 * delta_time)
		adjustToxic(-1 * delta_time)

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(myseed && !dead)
			// Advance age
			age++
			if(age < myseed.maturation)
				lastproduce = age

			needs_update = 1


//Nutrients//////////////////////////////////////////////////////////////
			// Nutrients deplete slowly
			if(prob(50))
				adjustNutri(-0.1 / rating)

			// Lack of nutrients hurts non-weeds
			if(nutrilevel <= 0 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				adjustHealth(-rand(1,3))

//Photosynthesis/////////////////////////////////////////////////////////
			// Lack of light hurts non-mushrooms
			if(isturf(loc))
				var/turf/currentTurf = loc
				var/lightAmt = currentTurf.get_lumcount()
				if(myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
					if(lightAmt < 0.2)
						adjustHealth(-1 / rating)
				else // Non-mushroom
					if(lightAmt < 0.4)
						adjustHealth(-2 / rating)

//Water//////////////////////////////////////////////////////////////////
			// Drink random amount of water
			adjustWater(-rand(0.1,0.6) / rating)

			// If the plant is dry, it loses health pretty fast, unless mushroom
			if(waterlevel <= 10 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
				adjustHealth(-rand(0,1) / rating)
				if(waterlevel <= 0)
					adjustHealth(-rand(0,2) / rating)

			// Sufficient water level and nutrient level = plant healthy but also spawns weeds
			else if(waterlevel > 10 && nutrilevel > 0)
				adjustHealth(rand(1,2) / rating)
				if(myseed && prob(myseed.weed_chance))
					adjustWeeds(myseed.weed_rate)
				else if(prob(1))  //1 percent chance the weed population will increase
					adjustWeeds(1 / rating)

//Toxins/////////////////////////////////////////////////////////////////

			// Too much toxins cause harm, but when the plant drinks the contaiminated water, the toxins disappear slowly
			if(toxic >= 40 && toxic < 80)
				adjustHealth(-1 / rating)
				adjustToxic(-rand(1,10) / rating)
			else if(toxic >= 80) // I don't think it ever gets here tbh unless above is commented out
				adjustHealth(-3)
				adjustToxic(-rand(1,10) / rating)

//Pests & Weeds//////////////////////////////////////////////////////////

			if(pestlevel >= 8)
				if(!myseed.get_gene(/datum/plant_gene/trait/plant_type/carnivory))
					adjustHealth(-2 / rating)

				else
					adjustHealth(2 / rating)
					adjustPests(-1 / rating)

			else if(pestlevel >= 4)
				if(!myseed.get_gene(/datum/plant_gene/trait/plant_type/carnivory))
					adjustHealth(-1 / rating)

				else
					adjustHealth(1 / rating)
					if(prob(50))
						adjustPests(-1 / rating)

			else if(pestlevel < 4 && myseed.get_gene(/datum/plant_gene/trait/plant_type/carnivory))
				adjustHealth(-2 / rating)
				if(prob(5))
					adjustPests(-1 / rating)

			// If it's a weed, it doesn't stunt the growth
			if(weedlevel >= 5 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				adjustHealth(-1 / rating)

//Health & Age///////////////////////////////////////////////////////////

			// Plant dies if plant_health <= 0
			if(plant_health <= 0)
				plantdies()
				adjustWeeds(1 / rating) // Weeds flourish

			// If the plant is too old, lose health fast
			if(age > myseed.lifespan)
				adjustHealth(-rand(1,5) / rating)

			// Harvest code
			if(age > myseed.production && (age - lastproduce) > myseed.production && (!harvest && !dead))
				nutrimentMutation()
				if(myseed && myseed.yield != -1) // Unharvestable shouldn't be harvested
					harvest = 1
				else
					lastproduce = age
			if(prob(1) || (myseed.get_gene(/datum/plant_gene/trait/plant_type/carnivory) && prob(5)))  // 1% chance for pests on most plants, 5% on carnivorous plants since they attract bugs.
				adjustPests(1 / rating)
		else
			if(waterlevel > 10 && nutrilevel > 0 && prob(10))  // If there's no plant, the percentage chance is 10%
				adjustWeeds(1 / rating)

		// Weeeeeeeeeeeeeeedddssss
		if(weedlevel >= 10 && prob(50)) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
			if(myseed)
				if(!myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy) && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism)) // If a normal plant
					weedinvasion()
			else
				weedinvasion() // Weed invasion into empty tray
			needs_update = 1
		if (needs_update)
			update_icon()

		if(myseed && prob(5 * (11-myseed.production)))
			for(var/g in myseed.genes)
				if(istype(g, /datum/plant_gene/trait))
					var/datum/plant_gene/trait/selectedtrait = g
					selectedtrait.on_grow(src)
	return

/obj/machinery/hydroponics/proc/nutrimentMutation()
	if (mutmod == 0)
		return
	if (mutmod == 1)
		if(prob(80))		//80%
			mutate()
		else if(prob(75))	//15%
			hardmutate()
		return
	if (mutmod == 2)
		if(prob(50))		//50%
			mutate()
		else if(prob(50))	//25%
			hardmutate()
		else if(prob(50))	//12.5%
			mutatespecie()
		return
	return

/obj/machinery/hydroponics/update_icon()
	//Refreshes the icon and sets the luminosity
	cut_overlays()

	if(self_sustaining)
		if(istype(src, /obj/machinery/hydroponics/soil))
			add_atom_colour(rgb(255, 175, 0), FIXED_COLOUR_PRIORITY)
		else
			add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "gaia_blessing"))
		set_light(3)

	update_icon_hoses()

	if(myseed)
		update_icon_plant()
		update_icon_lights()

	if(!self_sustaining)
		if(myseed && myseed.get_gene(/datum/plant_gene/trait/glow))
			var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
			set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
		else
			set_light(0)
	update_name()
	return

/obj/machinery/hydroponics/proc/update_icon_hoses()
	var/n = 0
	for(var/Dir in GLOB.cardinals)
		var/obj/machinery/hydroponics/t = locate() in get_step(src,Dir)
		if(t && t.using_irrigation && using_irrigation)
			n += Dir

	icon_state = "hoses-[n]"

/obj/machinery/hydroponics/proc/update_icon_plant()
	var/mutable_appearance/plant_overlay = mutable_appearance(myseed.growing_icon, layer = OBJ_LAYER + 0.01)
	if(dead)
		plant_overlay.icon_state = myseed.icon_dead
	else if(harvest)
		if(!myseed.icon_harvest)
			plant_overlay.icon_state = "[myseed.icon_grow][myseed.growthstages]"
		else
			plant_overlay.icon_state = myseed.icon_harvest
	else
		var/t_growthstate = clamp(round((age / myseed.maturation) * myseed.growthstages), 1, myseed.growthstages)
		plant_overlay.icon_state = "[myseed.icon_grow][t_growthstate]"
	add_overlay(plant_overlay)

/obj/machinery/hydroponics/proc/update_icon_lights()
	if(waterlevel <= 10)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_lowwater3"))
	if(nutrilevel <= 2)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_lownutri3"))
	if(plant_health <= (myseed.endurance / 2))
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_lowhealth3"))
	if(weedlevel >= 5 || pestlevel >= 5 || toxic >= 40)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_alert3"))
	if(harvest)
		add_overlay(mutable_appearance('icons/obj/hydroponics/equipment.dmi', "over_harvest3"))


/obj/machinery/hydroponics/examine(user)
	. = ..()
	if(myseed)
		. += span_info("It has [span_name("[myseed.plantname]")] planted.")
		if (dead)
			. += span_warning("It's dead!")
		else if (harvest)
			. += span_info("It's ready to harvest.")
		else if (plant_health <= (myseed.endurance / 2))
			. += span_warning("It looks unhealthy.")
	else
		. += span_info("It's empty.")

	if(!self_sustaining)
		. += "[span_info("Water: [waterlevel]/[maxwater].")]\n"+\
		span_info("Nutrient: [round(nutrilevel)]/[maxnutri].")
		if(self_sufficiency_progress > 0)
			var/percent_progress = round(self_sufficiency_progress * 100 / self_sufficiency_req)
			. += span_info("Treatment for self-sustenance are [percent_progress]% complete.")
	else
		. += span_info("It doesn't require any water or nutrients.")

	if(weedlevel >= 5)
		to_chat(user, span_warning("It's filled with weeds!"))
	if(pestlevel >= 5)
		to_chat(user, span_warning("It's filled with tiny worms!"))
	to_chat(user, "" )


/obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	dead = 0
	var/oldPlantName
	if(myseed) // In case there's nothing in the tray beforehand
		oldPlantName = myseed.plantname
		qdel(myseed)
		myseed = null
	else
		oldPlantName = "empty tray"
	switch(rand(1,18))		// randomly pick predominative weed
		if(16 to 18)
			myseed = new /obj/item/seeds/reishi(src)
		if(14 to 15)
			myseed = new /obj/item/seeds/nettle(src)
		if(12 to 13)
			myseed = new /obj/item/seeds/flower/harebell(src)
		if(10 to 11)
			myseed = new /obj/item/seeds/amanita(src)
		if(8 to 9)
			myseed = new /obj/item/seeds/chanter(src)
		if(6 to 7)
			myseed = new /obj/item/seeds/tower(src)
		if(4 to 5)
			myseed = new /obj/item/seeds/plump(src)
		else
			myseed = new /obj/item/seeds/starthistle(src)
	age = 1
	lastproduce = 1
	plant_health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0 // Reset
	pestlevel = 0 // Reset
	update_icon()
	visible_message(span_warning("The [oldPlantName] is overtaken by some [myseed.plantname]!"))


/obj/machinery/hydroponics/proc/mutate(lifemut = 2, endmut = 5, productmut = 1, yieldmut = 2, potmut = 25, wrmut = 2, wcmut = 5, traitmut = 0) // Mutates the current seed
	if(!myseed)
		return
	myseed.mutate(lifemut, endmut, productmut, yieldmut, potmut, wrmut, wcmut, traitmut)

/obj/machinery/hydroponics/proc/hardmutate()
	mutate(4, 10, 2, 4, 50, 4, 10, 3)

/obj/machinery/hydroponics/proc/glowmutate()
	if(!myseed)
		return
	myseed.add_random_glow()


/obj/machinery/hydroponics/proc/mutatespecie() // Mutagent produced a new plant!
	if(!myseed || dead)
		return

	var/oldPlantName = myseed.plantname
	if(myseed.mutatelist.len > 0)
		var/mutantseed = pick(myseed.mutatelist)
		qdel(myseed)
		myseed = null
		myseed = new mutantseed
	else
		return

	hardmutate()
	age = 0
	plant_health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0 // Reset

	var/message = span_warning("[oldPlantName] suddenly mutates into [myseed.plantname]!")
	addtimer(CALLBACK(src, PROC_REF(after_mutation), message), 0.5 SECONDS)


/obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if( weedlevel > 5 )
		if(myseed)
			qdel(myseed)
			myseed = null
		var/newWeed = pick(/obj/item/seeds/liberty, /obj/item/seeds/angel, /obj/item/seeds/nettle/death, /obj/item/seeds/kudzu)
		myseed = new newWeed
		dead = 0
		hardmutate()
		age = 0
		plant_health = myseed.endurance
		lastcycle = world.time
		harvest = 0
		weedlevel = 0 // Reset

		var/message = span_warning("The mutated weeds in [src] spawn some [myseed.plantname]!")
		addtimer(CALLBACK(src, PROC_REF(after_mutation), message), 0.5 SECONDS)
	else
		to_chat(usr, span_warning("The few weeds in [src] seem to react, but only for a moment..."))


//Called after plant mutation, update the appearance of the tray content and send a visible_message()
/obj/machinery/hydroponics/proc/after_mutation(message)
	update_icon()
	visible_message(message)

/obj/machinery/hydroponics/proc/plantdies() // OH NOES!!!!! I put this all in one function to make things easier
	plant_health = 0
	harvest = 0
	pestlevel = 0 // Pests die
	lastproduce = 0
	if(!dead)
		update_icon()
		dead = 1



/obj/machinery/hydroponics/proc/mutatepest(mob/user)
	if(pestlevel > 5)
		message_admins("[ADMIN_LOOKUPFLW(user)] caused spiderling pests to spawn in a hydro tray")
		log_game("[key_name(user)] caused spiderling pests to spawn in a hydro tray")
		visible_message(span_warning("The pests seem to behave oddly..."))
		spawn_atom_to_turf(/obj/structure/spider/spiderling/hunter, src, 3, FALSE)
	else
		to_chat(user, span_warning("The pests seem to behave oddly, but quickly settle down..."))

/obj/machinery/hydroponics/proc/applyChemicals(datum/reagents/S, mob/user)
	if(myseed)
		myseed.on_chem_reaction(S) //In case seeds have some special interactions with special chems, currently only used by vines

	// Requires 5 mutagen to possibly change species.// Poor man's mutagen.
	if(S.has_reagent(/datum/reagent/toxin/mutagen, 5) || S.has_reagent(/datum/reagent/uranium/radium, 10) || S.has_reagent(/datum/reagent/uranium, 10))
		switch(rand(100))
			if(91 to 100)
				adjustHealth(-10)
				to_chat(user, span_warning("The plant shrivels and burns."))
			if(81 to 90)
				mutatespecie()
			if(66 to 80)
				hardmutate()
			if(41 to 65)
				mutate()
			if(21 to 41)
				to_chat(user, span_notice("The plants don't seem to react..."))
			if(11 to 20)
				mutateweed()
			if(1 to 10)
				mutatepest(user)
			else
				to_chat(user, span_notice("Nothing happens..."))

	// 2 or 1 units is enough to change the yield and other stats.// Can change the yield and other stats, but requires more than mutagen
	else if(S.has_reagent(/datum/reagent/toxin/mutagen, 2) || S.has_reagent(/datum/reagent/uranium/radium, 5) || S.has_reagent(/datum/reagent/uranium, 5))
		hardmutate()
	else if(S.has_reagent(/datum/reagent/toxin/mutagen, 1) || S.has_reagent(/datum/reagent/uranium/radium, 2) || S.has_reagent(/datum/reagent/uranium, 2))
		mutate()

	//Bioluminescence only mutation
	if(S.has_reagent(/datum/reagent/colorful_reagent, 1))
		glowmutate()

	// After handling the mutating, we now handle the damage from adding crude radioactives...
	if(S.has_reagent(/datum/reagent/uranium, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/uranium) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/uranium) * 2))
	if(S.has_reagent(/datum/reagent/uranium/radium, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/uranium/radium) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/uranium/radium) * 3)) // Radium is harsher (OOC: also easier to produce)

	// Nutriments
	if(S.has_reagent(/datum/reagent/plantnutriment/eznutriment, 1))
		yieldmod = 1
		mutmod = 1
		cycledelay = 200
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/eznutriment) * 1))

	if(S.has_reagent(/datum/reagent/plantnutriment/left4zednutriment, 1))
		yieldmod = 0
		mutmod = 2
		cycledelay = 200
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/left4zednutriment) * 1))

	if(S.has_reagent(/datum/reagent/plantnutriment/robustharvestnutriment, 1))
		yieldmod = 1.3
		mutmod = 0
		cycledelay = 200
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/robustharvestnutriment) *1 ))

	if(S.has_reagent(/datum/reagent/plantnutriment/slimenutriment, 1))
		yieldmod = 0.8
		mutmod = 1
		cycledelay = 150
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/slimenutriment) *1))


	// Ambrosia Gaia produces earthsblood.
	if(S.has_reagent(/datum/reagent/medicine/earthsblood))
		self_sufficiency_progress += S.get_reagent_amount(/datum/reagent/medicine/earthsblood)
		if(self_sufficiency_progress >= self_sufficiency_req)
			become_self_sufficient()
		else if(!self_sustaining)
			to_chat(user, span_notice("[src] warms as it might on a spring day under a genuine Sun."))

	// Antitoxin binds shit pretty well. So the tox goes significantly down
	if(S.has_reagent(/datum/reagent/medicine/charcoal, 1))
		adjustToxic(-round(S.get_reagent_amount(/datum/reagent/medicine/charcoal) * 2))

	if(S.has_reagent(/datum/reagent/toxin, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin) * 2))

	// Milk is good for humans, but bad for plants. The sugars canot be used by plants, and the milk fat fucks up growth. Not shrooms though. I can't deal with this now...
	if(S.has_reagent(/datum/reagent/consumable/milk, 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/milk) * 0.1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/milk) * 0.9))

	// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
	if(S.has_reagent(/datum/reagent/consumable/ethanol/beer, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.05))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.25))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.7))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent(/datum/reagent/fluorine, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/fluorine) * 2))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/fluorine) * 2.5))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/fluorine) * 0.5))
		adjustWeeds(-rand(1,4))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent(/datum/reagent/chlorine, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/chlorine) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/chlorine) * 1.5))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/chlorine) * 0.5))
		adjustWeeds(-rand(1,3))

	// White Phosphorous + water -> phosphoric acid. That's not a good thing really.
	// Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
	if(S.has_reagent(/datum/reagent/phosphorus, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.75))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.1))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.5))
		adjustWeeds(-rand(1,2))

	// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
	if(S.has_reagent(/datum/reagent/consumable/sugar, 1))
		adjustWeeds(rand(1,2))
		adjustPests(rand(1,2))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/sugar) * 0.1))

	// It is water!
	if(S.has_reagent(/datum/reagent/water, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/water) * 1))

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits~
	if(S.has_reagent(/datum/reagent/water/holywater, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/water/holywater) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/water/holywater) * 0.1))

	// A variety of nutrients are dissolved in club soda, without sugar.
	// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
	if(S.has_reagent(/datum/reagent/consumable/sodawater, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 0.1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 0.1))

	// Man, you guys are stupid
	if(S.has_reagent(/datum/reagent/toxin/acid, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/acid) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/acid) * 1.5))
		adjustWeeds(-rand(1,2))

	// SERIOUSLY
	if(S.has_reagent(/datum/reagent/toxin/acid/fluacid, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/acid/fluacid) * 2))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/acid/fluacid) * 3))
		adjustWeeds(-rand(1,4))

	// Plant-B-Gone is just as bad
	if(S.has_reagent(/datum/reagent/toxin/plantbgone, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone) * 5))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone) * 6))
		adjustWeeds(-rand(4,8))

	// why, just why
	if(S.has_reagent(/datum/reagent/napalm, 1))
		if(!(myseed.resistance_flags & FIRE_PROOF))
			adjustHealth(-round(S.get_reagent_amount(/datum/reagent/napalm) * 6))
			adjustToxic(round(S.get_reagent_amount(/datum/reagent/napalm) * 7))
		adjustWeeds(-rand(5,9)) //At least give them a small reward if they bother.

	//Weed Spray
	if(S.has_reagent(/datum/reagent/toxin/plantbgone/weedkiller, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone/weedkiller) * 0.5))
		//old toxicity was 4, each spray is default 10 (minimal of 5) so 5 and 2.5 are the new ammounts
		adjustWeeds(-rand(1,2))

	//Pest Spray
	if(S.has_reagent(/datum/reagent/toxin/pestkiller, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/pestkiller) * 0.5))
		adjustPests(-rand(1,2))

	// Healing
	if(S.has_reagent(/datum/reagent/medicine/cryoxadone, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/medicine/cryoxadone) * 3))
		adjustToxic(-round(S.get_reagent_amount(/datum/reagent/medicine/cryoxadone) * 3))

	// Ammonia is bad ass.
	if(S.has_reagent(/datum/reagent/ammonia, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/ammonia) * 0.5))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/ammonia) * 1))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount(/datum/reagent/ammonia) * 0.01))

	// Saltpetre is used for gardening IRL, to simplify highly, it speeds up growth and strengthens plants
	if(S.has_reagent(/datum/reagent/saltpetre, 1))
		var/salt = S.get_reagent_amount(/datum/reagent/saltpetre)
		adjustHealth(round(salt * 0.25))
		if (myseed)
			myseed.adjust_production(-round(salt/100)-prob(salt%100))
			myseed.adjust_potency(round(salt*0.5))
	// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
	if(S.has_reagent(/datum/reagent/ash, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/ash) * 0.25))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/ash) * 0.5))
		adjustWeeds(-1)

	// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant.
	if(S.has_reagent(/datum/reagent/diethylamine, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 2))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 0.02))
		adjustPests(-rand(1,2))

	// Compost, effectively
	if(S.has_reagent(/datum/reagent/consumable/nutriment, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/consumable/nutriment) * 0.5))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/consumable/nutriment) * 1))

	// FEED ME
	if(S.has_reagent(/datum/reagent/blood, 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/blood) * 1))
		adjustPests(rand(2,4))

	// FEED ME SEYMOUR
	if(S.has_reagent(/datum/reagent/medicine/strange_reagent, 1))
		spawnplant()

	// The best stuff there is. For testing/debugging.
	if(S.has_reagent(/datum/reagent/medicine/adminordrazine, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustPests(-rand(1,5))
		adjustWeeds(-rand(1,5))

	if(S.has_reagent(/datum/reagent/medicine/adminordrazine, 5))
		switch(rand(100))
			if(66  to 100)
				mutatespecie()
			if(33	to 65)
				mutateweed()
			if(1   to 32)
				mutatepest(user)
			else
				to_chat(user, span_warning("Nothing happens..."))

/obj/machinery/hydroponics/attackby(obj/item/O, mob/user, params)
	//Called when mob user "attacks" it with object O
	if(IS_EDIBLE(O) || istype(O, /obj/item/reagent_containers)) // Syringe stuff (and other reagent containers now too)
		var/obj/item/reagent_containers/reagent_source = O

		if(!reagent_source.reagents.total_volume)
			to_chat(user, span_notice("[reagent_source] is empty."))
			return 1

		var/list/trays = list(src)//makes the list just this in cases of syringes and compost etc
		var/target = myseed ? myseed.plantname : src
		var/visi_msg = ""
		var/irrigate = 0	//How am I supposed to irrigate pill contents?
		var/transfer_amount

		if(IS_EDIBLE(reagent_source) || istype(reagent_source, /obj/item/reagent_containers/pill))
			visi_msg="[user] composts [reagent_source], spreading it through [target]"
			transfer_amount = reagent_source.reagents.total_volume
			SEND_SIGNAL(reagent_source, COMSIG_ITEM_ON_COMPOSTED, user)
		else
			transfer_amount = reagent_source.amount_per_transfer_from_this
			if(istype(reagent_source, /obj/item/reagent_containers/syringe/))
				var/obj/item/reagent_containers/syringe/syr = reagent_source
				visi_msg="[user] injects [target] with [syr]"
			else if(istype(reagent_source, /obj/item/reagent_containers/spray/))
				visi_msg="[user] sprays [target] with [reagent_source]"
				playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
				irrigate = 1
			else if(transfer_amount) // Droppers, cans, beakers, what have you.
				visi_msg="[user] uses [reagent_source] on [target]"
				irrigate = 1
			// Beakers, bottles, buckets, etc.
			if(reagent_source.is_drainable())
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

		if(irrigate && transfer_amount > 30 && reagent_source.reagents.total_volume >= 30 && using_irrigation)
			trays = FindConnected()
			if (trays.len > 1)
				visi_msg += ", setting off the irrigation system"

		if(visi_msg)
			visible_message(span_notice("[visi_msg]."))

		var/split = round(transfer_amount/trays.len)

		for(var/obj/machinery/hydroponics/H in trays)
		//cause I don't want to feel like im juggling 15 tamagotchis and I can get to my real work of ripping flooring apart in hopes of validating my life choices of becoming a space-gardener

			var/datum/reagents/S = new /datum/reagents() //This is a strange way, but I don't know of a better one so I can't fix it at the moment...
			S.my_atom = H

			reagent_source.reagents.trans_to(S,split, transfered_by = user)
			if(IS_EDIBLE(reagent_source) || istype(reagent_source, /obj/item/reagent_containers/pill))
				qdel(reagent_source)

			H.applyChemicals(S, user)

			S.clear_reagents()
			qdel(S)
			H.update_icon()
		if(reagent_source) // If the source wasn't composted and destroyed
			reagent_source.update_icon()
		return 1

	else if(O.tool_behaviour == TOOL_SEED && !istype(O, /obj/item/seeds/sample))
		if(!myseed)
			if(istype(O, /obj/item/seeds/kudzu))
				investigate_log("had Kudzu planted in it by [key_name(user)] at [AREACOORD(src)]","kudzu")
			if(!user.transferItemToLoc(O, src))
				return
			if(!istype(O, /obj/item/seeds)) //If the given item is supposed to be a seed, but isn't a subtype of /obj/item/seed
				O = O.fake_seed // use the item's fake_seed variable instead.
			to_chat(user, span_notice("You plant [O]."))
			dead = 0
			myseed = O
			age = 1
			lastproduce = 1
			plant_health = myseed.endurance
			lastcycle = world.time
			update_icon()
		else
			to_chat(user, span_warning("[src] already has seeds in it!"))

	else if(istype(O, /obj/item/plant_analyzer))
		var/list/message = list()
		if(myseed)
			message += "*** <B>[myseed.plantname]</B> ***"
			message += "- Plant Age: [span_notice("[age]")]"
			var/list/text_string = myseed.get_analyzer_text()
			if(text_string)
				message += text_string
		else
			message += "<B>No plant found.</B>"
		message += "- Weed level: [span_notice("[weedlevel] / 10")]"
		message += "- Pest level: [span_notice("[pestlevel] / 10")]"
		message += "- Toxicity level: [span_notice("[toxic] / 100")]"
		message += "- Water level: [span_notice("[waterlevel] / [maxwater]")]"
		message += "- Nutrition level: [span_notice("[nutrilevel] / [maxnutri]")]"
		to_chat(user, examine_block(jointext(message, "\n")))

	else if(istype(O, /obj/item/cultivator))
		if(weedlevel > 0)
			user.visible_message("[user] uproots the weeds.", span_notice("You remove the weeds from [src]."))
			weedlevel = 0
			update_icon()
		else
			to_chat(user, span_warning("This plot is completely devoid of weeds! It doesn't need uprooting."))

	else if(istype(O, /obj/item/storage/bag/plants))
		harvest_plant(user)
		for(var/obj/item/food/grown/G in locate(user.x,user.y,user.z))
			O.atom_storage?.attempt_insert(G, user, TRUE)

	else if(default_unfasten_wrench(user, O))
		return

	else if((O.tool_behaviour == TOOL_WIRECUTTER) && unwrenchable)
		if (!anchored)
			to_chat(user, span_warning("Anchor the tray first!"))
			return
		using_irrigation = !using_irrigation
		O.play_tool_sound(src)
		user.visible_message(span_notice("[user] [using_irrigation ? "" : "dis"]connects [src]'s irrigation hoses."), \
		span_notice("You [using_irrigation ? "" : "dis"]connect [src]'s irrigation hoses."))
		for(var/obj/machinery/hydroponics/h in range(1,src))
			h.update_icon()

	else if(istype(O, /obj/item/shovel/spade))
		if(!myseed && !weedlevel)
			to_chat(user, span_warning("[src] doesn't have any plants or weeds!"))
			return
		user.visible_message(span_notice("[user] starts digging out [src]'s plants..."),
			span_notice("You start digging out [src]'s plants..."))
		if(O.use_tool(src, user, 50, volume=50) || (!myseed && !weedlevel))
			user.visible_message(span_notice("[user] digs out the plants in [src]!"), span_notice("You dig out all of [src]'s plants!"))
			if(myseed) //Could be that they're just using it as a de-weeder
				age = 0
				plant_health = 0
				lastproduce = 0
				if(harvest)
					harvest = FALSE //To make sure they can't just put in another seed and insta-harvest it
				qdel(myseed)
				myseed = null
			weedlevel = 0 //Has a side effect of cleaning up those nasty weeds
			update_icon()

	else
		return ..()

/obj/machinery/hydroponics/attackby_secondary(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/reagent_containers/syringe))
		to_chat(user, "<span class='warning'>You can't get any extract out of this plant.</span>")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

/obj/machinery/hydroponics/can_be_unfasten_wrench(mob/user, silent)
	if (!unwrenchable)  // case also covered by NODECONSTRUCT checks in default_unfasten_wrench
		return CANT_UNFASTEN

	if (using_irrigation)
		if (!silent)
			to_chat(user, span_warning("Disconnect the hoses first!"))
		return FAILED_UNFASTEN

	return ..()

/obj/machinery/hydroponics/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(issilicon(user)) //How does AI know what plant is?
		return
	harvest_plant(user)

/obj/machinery/hydroponics/attack_robot(mob/living/user) // robots have little manipulator bits
	if(Adjacent(user))
		return harvest_plant(user)

/obj/machinery/hydroponics/proc/harvest_plant(mob/user)
	if(harvest)
		return myseed.harvest(user)

	else if(dead)
		dead = 0
		to_chat(user, span_notice("You remove the dead plant from [src]."))
		qdel(myseed)
		myseed = null
		update_icon()
	else
		if(user)
			examine(user)

/obj/machinery/hydroponics/proc/update_tray(mob/user)
	harvest = 0
	lastproduce = age
	if(istype(myseed, /obj/item/seeds/dionapod))
		to_chat(user, span_notice("You harvest from the [myseed.plantname]."))
	else if(myseed.getYield() <= 0)
		to_chat(user, span_warning("You fail to harvest anything useful!"))
	else
		to_chat(user, span_notice("You harvest [myseed.getYield()] items from the [myseed.plantname]."))
	if(!myseed.get_gene(/datum/plant_gene/trait/repeated_harvest))
		qdel(myseed)
		myseed = null
		dead = 0
		age = 0
		lastproduce = 0
	update_icon()

/// Tray Setters - The following procs adjust the tray or plants variables, and make sure that the stat doesn't go out of bounds.///
/obj/machinery/hydroponics/proc/adjustNutri(adjustamt)
	nutrilevel = clamp(nutrilevel + adjustamt, 0, maxnutri)

/obj/machinery/hydroponics/proc/adjustWater(adjustamt)
	waterlevel = clamp(waterlevel + adjustamt, 0, maxwater)

	if(adjustamt>0)
		adjustToxic(-round(adjustamt/4))//Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.

/obj/machinery/hydroponics/proc/adjustHealth(adjustamt)
	if(myseed && !dead)
		plant_health = clamp(plant_health + adjustamt, 0, myseed.endurance)

/obj/machinery/hydroponics/proc/adjustToxic(adjustamt)
	toxic = clamp(toxic + adjustamt, 0, 100)

/obj/machinery/hydroponics/proc/adjustPests(adjustamt)
	pestlevel = clamp(pestlevel + adjustamt, 0, 10)

/obj/machinery/hydroponics/proc/adjustWeeds(adjustamt)
	weedlevel = clamp(weedlevel + adjustamt, 0, 10)

/obj/machinery/hydroponics/proc/spawnplant() // why would you put strange reagent in a hydro tray you monster I bet you also feed them blood
	var/list/livingplants = list(/mob/living/simple_animal/hostile/tree, /mob/living/simple_animal/hostile/killertomato)
	var/chosen = pick(livingplants)
	var/mob/living/simple_animal/hostile/C = new chosen(get_turf(src))
	C.faction = list(FACTION_PLANTS)

/obj/machinery/hydroponics/proc/become_self_sufficient() // Ambrosia Gaia effect
	visible_message(span_boldnotice("[src] begins to glow with a beautiful light!"))
	self_sustaining = TRUE
	update_icon()

/obj/machinery/hydroponics/update_name()
	if(renamedByPlayer)
		return
	if(myseed)
		name = "[initial(name)] ([myseed.plantname])"
	else
		name = initial(name)
	return ..()

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/hydroponics/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	desc = "A patch of dirt."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "soil"
	circuit = null
	density = FALSE
	use_power = NO_POWER_USE
	flags_1 = NODECONSTRUCT_1
	unwrenchable = FALSE

/obj/machinery/hydroponics/soil/update_icon_hoses()
	return // Has no hoses

/obj/machinery/hydroponics/soil/update_icon_lights()
	return // Has no lights

/obj/machinery/hydroponics/soil/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_SHOVEL && !istype(O, /obj/item/shovel/spade)) //Doesn't include spades because of uprooting plants
		to_chat(user, span_notice("You clear up [src]!"))
		qdel(src)
	else
		return ..()
