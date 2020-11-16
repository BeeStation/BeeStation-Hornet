/obj/item/integrated_circuit/input
	var/can_be_asked_input = 0
	category_text = "Input"
	power_draw_per_use = 5

/obj/item/integrated_circuit/input/proc/ask_for_input(mob/user)
	return

/obj/item/integrated_circuit/input/button
	name = "button"
	desc = "This tiny button must do something, right?"
	icon_state = "button"
	complexity = 1
	can_be_asked_input = 1
	inputs = list()
	outputs = list()
	activators = list("on pressed" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/input/button/ask_for_input(mob/user) //Bit misleading name for this specific use.
	to_chat(user, "<span class='notice'>You press the button labeled '[displayed_name]'.</span>")
	activate_pin(1)

/obj/item/integrated_circuit/input/toggle_button
	name = "toggle button"
	desc = "It toggles on, off, on, off..."
	icon_state = "toggle_button"
	complexity = 1
	can_be_asked_input = 1
	inputs = list()
	outputs = list("on" = IC_PINTYPE_BOOLEAN)
	activators = list("on toggle" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/input/toggle_button/ask_for_input(mob/user) // Ditto.
	set_pin_data(IC_OUTPUT, 1, !get_pin_data(IC_OUTPUT, 1))
	push_data()
	activate_pin(1)
	to_chat(user, "<span class='notice'>You toggle the button labeled '[displayed_name]' [get_pin_data(IC_OUTPUT, 1) ? "on" : "off"].</span>")

/obj/item/integrated_circuit/input/numberpad
	name = "number pad"
	desc = "This small number pad allows someone to input a number into the system."
	icon_state = "numberpad"
	complexity = 2
	can_be_asked_input = 1
	inputs = list()
	outputs = list("number entered" = IC_PINTYPE_NUMBER)
	activators = list("on entered" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4

/obj/item/integrated_circuit/input/numberpad/ask_for_input(mob/user)
	var/new_input = input(user, "Enter a number, please.",displayed_name) as null|num
	if(isnum_safe(new_input) && user.IsAdvancedToolUser())
		set_pin_data(IC_OUTPUT, 1, new_input)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/textpad
	name = "text pad"
	desc = "This small text pad allows someone to input a string into the system."
	icon_state = "textpad"
	complexity = 2
	can_be_asked_input = 1
	inputs = list()
	outputs = list("string entered" = IC_PINTYPE_STRING)
	activators = list("on entered" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4

/obj/item/integrated_circuit/input/textpad/ask_for_input(mob/user)
	var/new_input = stripped_multiline_input(user, "Enter some words, please.",displayed_name)
	if(istext(new_input) && user.IsAdvancedToolUser())
		set_pin_data(IC_OUTPUT, 1, new_input)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/colorpad
	name = "color pad"
	desc = "This small color pad allows someone to input a hexadecimal color into the system."
	icon_state = "colorpad"
	complexity = 2
	can_be_asked_input = 1
	inputs = list()
	outputs = list("color entered" = IC_PINTYPE_STRING)
	activators = list("on entered" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4

/obj/item/integrated_circuit/input/colorpad/ask_for_input(mob/user)
	var/new_color = input(user, "Enter a color, please.", "Color", "#ffffff") as color|null
	if(new_color && user.IsAdvancedToolUser())
		set_pin_data(IC_OUTPUT, 1, new_color)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/med_scanner
	name = "integrated medical analyser"
	desc = "A very small version of the common medical analyser. This allows the machine to know how healthy someone is."
	icon_state = "medscan"
	complexity = 4
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"total health %" = IC_PINTYPE_NUMBER,
		"total missing health" = IC_PINTYPE_NUMBER
		)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 40

/obj/item/integrated_circuit/input/med_scanner/do_work()
	var/mob/living/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living)
	if(!istype(H)) //Invalid input
		return
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		var/total_health = round(H.health/H.getMaxHealth(), 0.01)*100
		var/missing_health = H.getMaxHealth() - H.health

		set_pin_data(IC_OUTPUT, 1, total_health)
		set_pin_data(IC_OUTPUT, 2, missing_health)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/adv_med_scanner
	name = "integrated adv. medical analyser"
	desc = "A very small version of the medbot's medical analyser. This allows the machine to know how healthy someone is. \
	This type is much more precise, allowing the machine to know much more about the target than a normal analyzer."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"total health %"		= IC_PINTYPE_NUMBER,
		"total missing health"	= IC_PINTYPE_NUMBER,
		"brute damage"			= IC_PINTYPE_NUMBER,
		"burn damage"			= IC_PINTYPE_NUMBER,
		"tox damage"			= IC_PINTYPE_NUMBER,
		"oxy damage"			= IC_PINTYPE_NUMBER,
		"clone damage"			= IC_PINTYPE_NUMBER
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/input/adv_med_scanner/do_work()
	var/mob/living/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living)
	if(!istype(H)) //Invalid input
		return
	if(H in view(get_turf(src))) // Like medbot's analyzer it can be used in range..
		var/total_health = round(H.health/H.getMaxHealth(), 0.01)*100
		var/missing_health = H.getMaxHealth() - H.health

		set_pin_data(IC_OUTPUT, 1, total_health)
		set_pin_data(IC_OUTPUT, 2, missing_health)
		set_pin_data(IC_OUTPUT, 3, H.getBruteLoss())
		set_pin_data(IC_OUTPUT, 4, H.getFireLoss())
		set_pin_data(IC_OUTPUT, 5, H.getToxLoss())
		set_pin_data(IC_OUTPUT, 6, H.getOxyLoss())
		set_pin_data(IC_OUTPUT, 7, H.getCloneLoss())

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/slime_scanner
	name = "slime scanner"
	desc = "A very small version of the xenobio analyser. This allows the machine to know every needed properties of slime. Output mutation list is non-associative."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"colour"				= IC_PINTYPE_STRING,
		"adult"					= IC_PINTYPE_BOOLEAN,
		"nutrition"				= IC_PINTYPE_NUMBER,
		"charge"				= IC_PINTYPE_NUMBER,
		"health"				= IC_PINTYPE_NUMBER,
		"possible mutation"		= IC_PINTYPE_LIST,
		"genetic destability"	= IC_PINTYPE_NUMBER,
		"slime core amount"		= IC_PINTYPE_NUMBER,
		"Growth progress"		= IC_PINTYPE_NUMBER,
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/input/slime_scanner/do_work()
	var/mob/living/simple_animal/slime/T = get_pin_data_as_type(IC_INPUT, 1, /mob/living/simple_animal/slime)
	if(!isslime(T)) //Invalid input
		return
	if(T in view(get_turf(src))) // Like medbot's analyzer it can be used in range..

		set_pin_data(IC_OUTPUT, 1, T.colour)
		set_pin_data(IC_OUTPUT, 2, T.is_adult)
		set_pin_data(IC_OUTPUT, 3, T.nutrition/T.get_max_nutrition())
		set_pin_data(IC_OUTPUT, 4, T.powerlevel)
		set_pin_data(IC_OUTPUT, 5, round(T.health/T.maxHealth,0.01)*100)
		set_pin_data(IC_OUTPUT, 6, uniqueList(T.slime_mutation))
		set_pin_data(IC_OUTPUT, 7, T.mutation_chance)
		set_pin_data(IC_OUTPUT, 8, T.cores)
		set_pin_data(IC_OUTPUT, 9, T.amount_grown/SLIME_EVOLUTION_THRESHOLD)


	push_data()
	activate_pin(2)



/obj/item/integrated_circuit/input/plant_scanner
	name = "integrated plant analyzer"
	desc = "A very small version of the plant analyser. This allows the machine to know all valuable parameters of plants in trays. \
			It can only scan plants, not seeds or fruits."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"plant type"		= IC_PINTYPE_STRING,
		"age"		= IC_PINTYPE_NUMBER,
		"potency"	= IC_PINTYPE_NUMBER,
		"yield"			= IC_PINTYPE_NUMBER,
		"Maturation speed"			= IC_PINTYPE_NUMBER,
		"Production speed"			= IC_PINTYPE_NUMBER,
		"Endurance"			= IC_PINTYPE_NUMBER,
		"Lifespan"			= IC_PINTYPE_NUMBER,
		"Weed Growth Rate"		= IC_PINTYPE_NUMBER,
		"Weed Vulnerability"	= IC_PINTYPE_NUMBER,
		"Weed level"			= IC_PINTYPE_NUMBER,
		"Pest level"			= IC_PINTYPE_NUMBER,
		"Toxicity level"			= IC_PINTYPE_NUMBER,
		"Water level"			= IC_PINTYPE_NUMBER,
		"Nutrition level"			= IC_PINTYPE_NUMBER,
		"harvest"			= IC_PINTYPE_NUMBER,
		"dead"			= IC_PINTYPE_NUMBER,
		"plant health"			= IC_PINTYPE_NUMBER,
		"self sustaining"		= IC_PINTYPE_NUMBER,
		"using irrigation" 		= IC_PINTYPE_NUMBER,
		"connected trays"		= IC_PINTYPE_LIST
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 10

/obj/item/integrated_circuit/input/plant_scanner/do_work()
	var/obj/machinery/hydroponics/H = get_pin_data_as_type(IC_INPUT, 1, /obj/machinery/hydroponics)
	if(!istype(H)) //Invalid input
		return
	for(var/i=1, i<=outputs.len, i++)
		set_pin_data(IC_OUTPUT, i, null)
	if(H in view(get_turf(src))) // Like medbot's analyzer it can be used in range..
		if(H.myseed)
			set_pin_data(IC_OUTPUT, 1, H.myseed.plantname)
			set_pin_data(IC_OUTPUT, 2, H.age)
			set_pin_data(IC_OUTPUT, 3, H.myseed.potency)
			set_pin_data(IC_OUTPUT, 4, H.myseed.yield)
			set_pin_data(IC_OUTPUT, 5, H.myseed.maturation)
			set_pin_data(IC_OUTPUT, 6, H.myseed.production)
			set_pin_data(IC_OUTPUT, 7, H.myseed.endurance)
			set_pin_data(IC_OUTPUT, 8, H.myseed.lifespan)
			set_pin_data(IC_OUTPUT, 9, H.myseed.weed_rate)
			set_pin_data(IC_OUTPUT, 10, H.myseed.weed_chance)
		set_pin_data(IC_OUTPUT, 11, H.weedlevel)
		set_pin_data(IC_OUTPUT, 12, H.pestlevel)
		set_pin_data(IC_OUTPUT, 13, H.toxic)
		set_pin_data(IC_OUTPUT, 14, H.waterlevel)
		set_pin_data(IC_OUTPUT, 15, H.nutrilevel)
		set_pin_data(IC_OUTPUT, 16, H.harvest)
		set_pin_data(IC_OUTPUT, 17, H.dead)
		set_pin_data(IC_OUTPUT, 18, H.plant_health)
		set_pin_data(IC_OUTPUT, 19, H.self_sustaining)
		set_pin_data(IC_OUTPUT, 20, H.using_irrigation)
		set_pin_data(IC_OUTPUT, 21, H.FindConnected())
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/gene_scanner
	name = "gene scanner"
	desc = "This circuit will scan the target plant for traits and reagent genes. Output is non-associative."
	extended_desc = "This allows the machine to scan plants in trays for reagent and trait genes. \
			It can only scan plants, not seeds or fruits."
	inputs = list(
		"target" = IC_PINTYPE_REF
	)
	outputs = list(
		"traits" = IC_PINTYPE_LIST,
		"reagents" = IC_PINTYPE_LIST
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	icon_state = "medscan_adv"
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/input/gene_scanner/do_work()
	var/list/gtraits = list()
	var/list/greagents = list()
	var/obj/machinery/hydroponics/H = get_pin_data_as_type(IC_INPUT, 1, /obj/machinery/hydroponics)
	if(!istype(H)) //Invalid input
		return
	for(var/i=1, i<=outputs.len, i++)
		set_pin_data(IC_OUTPUT, i, null)
	if(H in view(get_turf(src))) // Like medbot's analyzer it can be used in range..
		if(H.myseed)
			for(var/datum/plant_gene/reagent/G in H.myseed.genes)
				greagents.Add(G.get_name())

			for(var/datum/plant_gene/trait/G in H.myseed.genes)
				gtraits.Add(G.get_name())

	set_pin_data(IC_OUTPUT, 1, gtraits)
	set_pin_data(IC_OUTPUT, 2, greagents)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/input/examiner
	name = "examiner"
	desc = "It's a little machine vision system. It can return the name, description, distance, \
	relative coordinates, total amount of reagents, maximum amount of reagents, density, and opacity of the referenced object."
	icon_state = "video_camera"
	complexity = 6
	inputs = list(
		"target" = IC_PINTYPE_REF
		)
	outputs = list(
		"name"				 	= IC_PINTYPE_STRING,
		"description"			= IC_PINTYPE_STRING,
		"X"						= IC_PINTYPE_NUMBER,
		"Y"						= IC_PINTYPE_NUMBER,
		"distance"				= IC_PINTYPE_NUMBER,
		"max reagents"			= IC_PINTYPE_NUMBER,
		"amount of reagents"	= IC_PINTYPE_NUMBER,
		"density"				= IC_PINTYPE_BOOLEAN,
		"opacity"				= IC_PINTYPE_BOOLEAN,
		"occupied turf"			= IC_PINTYPE_REF
		)
	activators = list(
		"scan" = IC_PINTYPE_PULSE_IN,
		"on scanned" = IC_PINTYPE_PULSE_OUT,
		"not scanned" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/input/examiner/do_work()
	var/atom/H = get_pin_data_as_type(IC_INPUT, 1, /atom)
	var/turf/T = get_turf(src)

	if(!istype(H) || !(H in view(T)))
		activate_pin(3)
	else
		set_pin_data(IC_OUTPUT, 1, H.name)
		set_pin_data(IC_OUTPUT, 2, H.desc)

		if(istype(H, /mob/living))
			var/mob/living/M = H
			var/msg = M.examine()
			if(msg)
				set_pin_data(IC_OUTPUT, 2, msg)

		set_pin_data(IC_OUTPUT, 3, H.x-T.x)
		set_pin_data(IC_OUTPUT, 4, H.y-T.y)
		set_pin_data(IC_OUTPUT, 5, sqrt((H.x-T.x)*(H.x-T.x)+ (H.y-T.y)*(H.y-T.y)))
		var/mr = 0
		var/tr = 0
		if(H.reagents)
			mr = H.reagents.maximum_volume
			tr = H.reagents.total_volume
		set_pin_data(IC_OUTPUT, 6, mr)
		set_pin_data(IC_OUTPUT, 7, tr)
		set_pin_data(IC_OUTPUT, 8, H.CanPass(assembly ? assembly : src, get_turf(H)))
		set_pin_data(IC_OUTPUT, 9, H.opacity)
		set_pin_data(IC_OUTPUT, 10, get_turf(H))
		push_data()
		activate_pin(2)

/obj/item/integrated_circuit/input/turfpoint
	name = "Tile pointer"
	desc = "This circuit will get a tile ref with the provided absolute coordinates."
	extended_desc = "If the machine	cannot see the target, it will not be able to calculate the correct direction.\
	This circuit only works while inside an assembly."
	icon_state = "numberpad"
	complexity = 5
	inputs = list("X" = IC_PINTYPE_NUMBER,"Y" = IC_PINTYPE_NUMBER)
	outputs = list("tile" = IC_PINTYPE_REF)
	activators = list("calculate dir" = IC_PINTYPE_PULSE_IN, "on calculated" = IC_PINTYPE_PULSE_OUT,"not calculated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40

/obj/item/integrated_circuit/input/turfpoint/do_work()
	if(!assembly)
		activate_pin(3)
		return
	var/turf/T = get_turf(assembly)
	var/target_x = CLAMP(get_pin_data(IC_INPUT, 1), 0, world.maxx)
	var/target_y = CLAMP(get_pin_data(IC_INPUT, 2), 0, world.maxy)
	var/turf/A = locate(target_x, target_y, T.z)
	set_pin_data(IC_OUTPUT, 1, null)
	if(!A || !(A in view(T)))
		activate_pin(3)
		return
	else
		set_pin_data(IC_OUTPUT, 1, WEAKREF(A))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/turfscan
	name = "tile analyzer"
	desc = "This circuit can analyze the contents of the scanned turf, and can read letters on the turf."
	icon_state = "video_camera"
	complexity = 5
	inputs = list(
		"target" = IC_PINTYPE_REF
		)
	outputs = list(
		"located ref" 		= IC_PINTYPE_LIST,
		"Written letters" 	= IC_PINTYPE_STRING,
		"area"				= IC_PINTYPE_STRING
		)
	activators = list(
		"scan" = IC_PINTYPE_PULSE_IN,
		"on scanned" = IC_PINTYPE_PULSE_OUT,
		"not scanned" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40
	cooldown_per_use = 10

/obj/item/integrated_circuit/input/turfscan/do_work()
	var/turf/scanned_turf = get_pin_data_as_type(IC_INPUT, 1, /turf)
	var/turf/circuit_turf = get_turf(src)
	var/area_name = get_area_name(scanned_turf)
	if(!istype(scanned_turf)) //Invalid input
		activate_pin(3)
		return

	if(scanned_turf in view(circuit_turf)) // This is a camera. It can't examine things that it can't see.
		var/list/turf_contents = new()
		for(var/obj/U in scanned_turf)
			turf_contents += WEAKREF(U)
		for(var/mob/U in scanned_turf)
			turf_contents += WEAKREF(U)
		set_pin_data(IC_OUTPUT, 1, turf_contents)
		set_pin_data(IC_OUTPUT, 3, area_name)
		var/list/St = new()
		for(var/obj/effect/decal/cleanable/crayon/I in scanned_turf)
			St.Add(I.icon_state)
		if(St.len)
			set_pin_data(IC_OUTPUT, 2, jointext(St, ",", 1, 0))
		push_data()
		activate_pin(2)

/obj/item/integrated_circuit/input/turfpoint
	name = "tile pointer"
	desc = "This circuit will get tile ref with given absolute coorinates."
	extended_desc = "If the machine	cannot see the target, it will not be able to scan it.\
	This circuit will only work in an assembly."
	icon_state = "numberpad"
	complexity = 5
	inputs = list("X" = IC_PINTYPE_NUMBER,"Y" = IC_PINTYPE_NUMBER)
	outputs = list("tile" = IC_PINTYPE_REF)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT,"not scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40

/obj/item/integrated_circuit/input/turfpoint/do_work()
	if(!assembly)
		activate_pin(3)
		return
	var/turf/T = get_turf(assembly)
	var/target_x = CLAMP(get_pin_data(IC_INPUT, 1), 0, world.maxx)
	var/target_y = CLAMP(get_pin_data(IC_INPUT, 2), 0, world.maxy)
	var/turf/A = locate(target_x, target_y, T.z)
	set_pin_data(IC_OUTPUT, 1, null)
	if(!A || !(A in view(T)))
		activate_pin(3)
		return
	else
		set_pin_data(IC_OUTPUT, 1, WEAKREF(A))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/turfscan
	name = "tile analyzer"
	desc = "This machine vision system can analyze contents of desired tile.And can read letters on floor."
	icon_state = "video_camera"
	complexity = 5
	inputs = list(
		"target" = IC_PINTYPE_REF
		)
	outputs = list(
		"located ref" 		= IC_PINTYPE_LIST,
		"Written letters" 	= IC_PINTYPE_STRING
		)
	activators = list(
		"scan" = IC_PINTYPE_PULSE_IN,
		"on scanned" = IC_PINTYPE_PULSE_OUT,
		"not scanned" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40
	cooldown_per_use = 10

/obj/item/integrated_circuit/input/turfscan/do_work()
	var/atom/movable/H = get_pin_data_as_type(IC_INPUT, 1, /atom)
	var/turf/T = get_turf(src)
	var/turf/E = get_turf(H)
	if(!istype(H)) //Invalid input
		return

	if(H in view(T)) // This is a camera. It can't examine thngs,that it can't see.
		var/list/cont = new()
		if(E.contents.len)
			for(var/i = 1 to E.contents.len)
				var/atom/U = E.contents[i]
				cont += WEAKREF(U)
		set_pin_data(IC_OUTPUT, 1, cont)
		var/list/St = new()
		for(var/obj/effect/decal/cleanable/crayon/I in E.contents)
			St.Add(I.icon_state)
		if(St.len)
			set_pin_data(IC_OUTPUT, 2, jointext(St, ",", 1, 0))
		push_data()
		activate_pin(2)
	else
		activate_pin(3)

/obj/item/integrated_circuit/input/local_locator
	name = "local locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon. This type only locates something \
	that is holding the machine containing it."
	inputs = list()
	outputs = list("located ref"		= IC_PINTYPE_REF,
					"is ground"			= IC_PINTYPE_BOOLEAN,
					"is creature"		= IC_PINTYPE_BOOLEAN)
	activators = list("locate" = IC_PINTYPE_PULSE_IN,
		"on scanned" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 20

/obj/item/integrated_circuit/input/local_locator/do_work()
	var/datum/integrated_io/O = outputs[1]
	O.data = null
	if(assembly)
		O.data = WEAKREF(assembly.loc)
	set_pin_data(IC_OUTPUT, 2, isturf(assembly.loc))
	set_pin_data(IC_OUTPUT, 3, ismob(assembly.loc))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/adjacent_locator
	name = "adjacent locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon. This type only locates something \
	that is standing up to a meter away from the machine."
	extended_desc = "The first pin requires a ref to the kind of object that you want the locator to acquire. This means that it will \
	give refs to nearby objects that are similar. If more than one valid object is found nearby, it will choose one of them at \
	random."
	inputs = list("desired type ref" = IC_PINTYPE_REF)
	outputs = list("located ref" = IC_PINTYPE_REF)
	activators = list("locate" = IC_PINTYPE_PULSE_IN,"found" = IC_PINTYPE_PULSE_OUT,
		"not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30

/obj/item/integrated_circuit/input/adjacent_locator/do_work()
	var/datum/integrated_io/I = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = null

	if(!isweakref(I.data))
		return
	var/atom/A = I.data.resolve()
	if(!A)
		return
	var/desired_type = A.type

	var/list/nearby_things = range(1, get_turf(src))
	var/list/valid_things = list()
	for(var/atom/thing in nearby_things)
		if(thing.type != desired_type)
			continue
		valid_things.Add(thing)
	if(valid_things.len)
		O.data = WEAKREF(pick(valid_things))
		activate_pin(2)
	else
		activate_pin(3)
	O.push_data()

/obj/item/integrated_circuit/input/advanced_locator_list
	complexity = 6
	name = "list advanced locator"
	desc = "This is needed for certain devices that demand list of names for a target to act upon. This type locates something \
	that is standing in given radius of up to 8 meters. Output is non-associative. Input will only consider keys if associative."
	extended_desc = "The first pin requires a list of the kinds of objects that you want the locator to acquire. It will locate nearby objects by name and description, \
	and will then provide a list of all found objects which are similar. \
	The second pin is a radius."
	inputs = list("desired type ref" = IC_PINTYPE_LIST, "radius" = IC_PINTYPE_NUMBER)
	outputs = list("located ref" = IC_PINTYPE_LIST)
	activators = list("locate" = IC_PINTYPE_PULSE_IN,"found" = IC_PINTYPE_PULSE_OUT,"not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30
	var/radius = 1
	cooldown_per_use = 10

/obj/item/integrated_circuit/input/advanced_locator_list/on_data_written()
	var/rad = get_pin_data(IC_INPUT, 2)

	if(isnum_safe(rad))
		rad = CLAMP(rad, 0, 8)
		radius = rad

/obj/item/integrated_circuit/input/advanced_locator_list/do_work()
	var/datum/integrated_io/I = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = null
	var/list/input_list = list()
	input_list = I.data
	if(length(input_list))	//if there is no input don't do anything.
		var/turf/T = get_turf(src)
		var/list/nearby_things = view(radius,T)
		var/list/valid_things = list()
		for(var/item in input_list)
			if(!isnull(item) && !isnum_safe(item))
				if(istext(item))
					for(var/i in nearby_things)
						var/atom/thing = i
						if(ismob(thing) && !isliving(thing))
							continue
						if(findtext(addtext(thing.name," ",thing.desc), item, 1, 0) )
							valid_things.Add(WEAKREF(thing))
				else
					var/atom/A = item
					var/desired_type = A.type
					for(var/i in nearby_things)
						var/atom/thing = i
						if(thing.type != desired_type)
							continue
						if(ismob(thing) && !isliving(thing))
							continue
						valid_things.Add(WEAKREF(thing))
		if(valid_things.len)
			O.data = valid_things
			O.push_data()
			activate_pin(2)
		else
			O.push_data()
			activate_pin(3)
	else
		O.push_data()
		activate_pin(3)

/obj/item/integrated_circuit/input/advanced_locator
	complexity = 6
	name = "advanced locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon. This type locates something \
	that is standing in given radius of up to 8 meters"
	extended_desc = "The first pin requires a ref to the kind of object that you want the locator to acquire. This means that it will \
	give refs to nearby objects which are similar. If this pin is a string, the locator will search for an \
	item matching the desired text in its name and description. If more than one valid object is found nearby, it will choose one of them at \
	random. The second pin is a radius."
	inputs = list("desired type" = IC_PINTYPE_ANY, "radius" = IC_PINTYPE_NUMBER)
	outputs = list("located ref" = IC_PINTYPE_REF)
	activators = list("locate" = IC_PINTYPE_PULSE_IN,"found" = IC_PINTYPE_PULSE_OUT,"not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30
	var/radius = 1

/obj/item/integrated_circuit/input/advanced_locator/on_data_written()
	var/rad = get_pin_data(IC_INPUT, 2)
	if(isnum_safe(rad))
		rad = CLAMP(rad, 0, 8)
		radius = rad

/obj/item/integrated_circuit/input/advanced_locator/do_work()
	var/datum/integrated_io/I = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = null
	var/turf/T = get_turf(src)
	var/list/nearby_things =  view(radius,T)
	var/list/valid_things = list()
	if(isweakref(I.data))
		var/atom/A = I.data.resolve()
		var/desired_type = A.type
		if(desired_type)
			for(var/i in nearby_things)
				var/atom/thing = i
				if(ismob(thing) && !isliving(thing))
					continue
				if(thing.type == desired_type)
					valid_things.Add(thing)
	else if(istext(I.data))
		var/DT = I.data
		for(var/i in nearby_things)
			var/atom/thing = i
			if(ismob(thing) && !isliving(thing))
				continue
			if(findtext(addtext(thing.name," ",thing.desc), DT, 1, 0) )
				valid_things.Add(thing)
	if(valid_things.len)
		O.data = WEAKREF(pick(valid_things))
		O.push_data()
		activate_pin(2)
	else
		O.push_data()
		activate_pin(3)

/obj/item/integrated_circuit/input/signaler
	name = "integrated signaler"
	desc = "Signals from a signaler can be received with this, allowing for remote control. It can also send signals."
	extended_desc = "When a signal is received from another signaler, the 'on signal received' activator pin will be pulsed. \
	The two input pins are to configure the integrated signaler's settings. Note that the frequency should not have a decimal in it, \
	meaning the default frequency is expressed as 1457, not 145.7. To send a signal, pulse the 'send signal' activator pin."
	icon_state = "signal"
	complexity = 4
	inputs = list("frequency" = IC_PINTYPE_NUMBER,"code" = IC_PINTYPE_NUMBER)
	outputs = list()
	activators = list(
		"send signal" = IC_PINTYPE_PULSE_IN,
		"on signal sent" = IC_PINTYPE_PULSE_OUT,
		"on signal received" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_LONG_RANGE
	power_draw_idle = 5
	power_draw_per_use = 40
	cooldown_per_use = 5
	var/frequency = FREQ_SIGNALER
	var/code = DEFAULT_SIGNALER_CODE
	var/datum/radio_frequency/radio_connection
	var/hearing_range = 1

/obj/item/integrated_circuit/input/signaler/Initialize()
	. = ..()
	spawn(40)
		set_frequency(frequency)
		// Set the pins so when someone sees them, they won't show as null
		set_pin_data(IC_INPUT, 1, frequency)
		set_pin_data(IC_INPUT, 2, code)

/obj/item/integrated_circuit/input/signaler/Destroy()
	SSradio.remove_object(src,frequency)

	frequency = 0
	return ..()

/obj/item/integrated_circuit/input/signaler/on_data_written()
	var/new_freq = get_pin_data(IC_INPUT, 1)
	var/new_code = get_pin_data(IC_INPUT, 2)
	if(isnum_safe(new_freq) && new_freq > 0)
		set_frequency(new_freq)
	if(isnum_safe(new_code))
		code = new_code


/obj/item/integrated_circuit/input/signaler/do_work() // Sends a signal.
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list("code" = code))
	radio_connection.post_signal(src, signal)
	activate_pin(2)

/obj/item/integrated_circuit/input/signaler/proc/set_frequency(new_frequency)
	if(!frequency)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)

/obj/item/integrated_circuit/input/signaler/receive_signal(datum/signal/signal)
	var/new_code = get_pin_data(IC_INPUT, 2)
	var/code = 0

	if(isnum_safe(new_code))
		code = new_code
	if(!signal)
		return 0
	if(signal.data["code"] != code)
		return 0
	if(signal.source == src) // Don't trigger ourselves.
		return 0

	activate_pin(3)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)

/obj/item/integrated_circuit/input/ntnet_packet
	name = "NTNet networking circuit"
	desc = "Enables the sending and receiving of messages over NTNet via packet data protocol."
	extended_desc = "Data can be sent or received using the second pin on each side, \
	with additonal data reserved for the third pin. When a message is received, the second activation pin \
	will pulse whatever is connected to it. Pulsing the first activation pin will send a message. Messages \
	can be sent to multiple recepients. Addresses must be separated with a semicolon, like this: Address1;Address2;Etc."
	icon_state = "signal"
	complexity = 2
	cooldown_per_use = 1
	inputs = list(
		"target NTNet addresses"= IC_PINTYPE_STRING,
		"data to send"			= IC_PINTYPE_STRING,
		"secondary text"		= IC_PINTYPE_STRING,
		"passkey"				= IC_PINTYPE_STRING
		)
	outputs = list(
		"address received"			= IC_PINTYPE_STRING,
		"data received"				= IC_PINTYPE_STRING,
		"secondary text received"	= IC_PINTYPE_STRING,
		"passkey"					= IC_PINTYPE_STRING,
		"is_broadcast"				= IC_PINTYPE_BOOLEAN
		)
	activators = list("send data" = IC_PINTYPE_PULSE_IN, "on data received" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_LONG_RANGE
	power_draw_per_use = 50
	var/address

/obj/item/integrated_circuit/input/ntnet_packet/Initialize()
	. = ..()
	var/datum/component/ntnet_interface/net = LoadComponent(/datum/component/ntnet_interface)
	address = net.hardware_id
	net.differentiate_broadcast = FALSE
	desc += "<br>This circuit's NTNet hardware address is: [address]"

/obj/item/integrated_circuit/input/ntnet_packet/do_work()
	var/target_address = get_pin_data(IC_INPUT, 1)
	var/message = get_pin_data(IC_INPUT, 2)
	var/text = get_pin_data(IC_INPUT, 3)

	var/datum/netdata/data = new
	data.recipient_ids = splittext(target_address, ";")
	var/key = get_pin_data(IC_INPUT, 4) // hippie start -- adds passkey back in
	data.standard_format_data(message, text, key) // hippie end
	ntnet_send(data)

/obj/item/integrated_circuit/input/ntnet_receive(datum/netdata/data)
	set_pin_data(IC_OUTPUT, 1, data.sender_id)
	set_pin_data(IC_OUTPUT, 2, data.data["data"])
	set_pin_data(IC_OUTPUT, 3, data.data["data_secondary"])
	set_pin_data(IC_OUTPUT, 4, data.data["encrypted_passkey"])
	set_pin_data(IC_OUTPUT, 5, data.broadcast)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/ntnet_advanced
	name = "Low level NTNet transreceiver"
	desc = "Enables the sending and receiving of messages over NTNet via packet data protocol. Allows advanced control of message contents and signalling. Must use associative lists. Outputs associative list. Has a slower transmission rate than normal NTNet circuits, due to increased data processing complexity."
	extended_desc = "Data can be sent or received using the second pin on each side, \
	When a message is received, the second activation pin will pulse whatever is connected to it. \
	Pulsing the first activation pin will send a message. Messages can be sent to multiple recepients. \
	Addresses must be separated with a semicolon, like this: Address1;Address2;Etc."
	icon_state = "signal"
	complexity = 4
	cooldown_per_use = 10
	inputs = list(
		"target NTNet addresses"= IC_PINTYPE_STRING,
		"data"					= IC_PINTYPE_LIST,
		)
	outputs = list("received data" = IC_PINTYPE_LIST, "is_broadcast" = IC_PINTYPE_BOOLEAN)
	activators = list("send data" = IC_PINTYPE_PULSE_IN, "on data received" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_LONG_RANGE
	power_draw_per_use = 50
	var/address

/obj/item/integrated_circuit/input/ntnet_advanced/Initialize()
	. = ..()
	var/datum/component/ntnet_interface/net = LoadComponent(/datum/component/ntnet_interface)
	address = net.hardware_id
	net.differentiate_broadcast = FALSE
	desc += "<br>This circuit's NTNet hardware address is: [address]"

/obj/item/integrated_circuit/input/ntnet_advanced/do_work()
	var/target_address = get_pin_data(IC_INPUT, 1)
	var/list/message = get_pin_data(IC_INPUT, 2)
	if(!islist(message))
		message = list()
	var/datum/netdata/data = new
	data.recipient_ids = splittext(target_address, ";")
	data.data = message
	//data.passkey = assembly.access_card.access
	ntnet_send(data)

/obj/item/integrated_circuit/input/ntnet_advanced/ntnet_receive(datum/netdata/data)
	set_pin_data(IC_OUTPUT, 1, data.data)
	set_pin_data(IC_OUTPUT, 2, data.broadcast)
	push_data()
	activate_pin(2)

//This circuit gives information on where the machine is.
/obj/item/integrated_circuit/input/gps
	name = "global positioning system"
	desc = "This allows you to easily know the position of a machine containing this device."
	extended_desc = "The coordinates that the GPS outputs are absolute, not relative. The full coords output has the coords separated by commas and is in string format."
	icon_state = "gps"
	complexity = 4
	inputs = list()
	outputs = list("X"= IC_PINTYPE_NUMBER, "Y" = IC_PINTYPE_NUMBER, "Z" = IC_PINTYPE_NUMBER, "full coords" = IC_PINTYPE_STRING)
	activators = list("get coordinates" = IC_PINTYPE_PULSE_IN, "on get coordinates" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30

/obj/item/integrated_circuit/input/gps/do_work()
	var/turf/T = get_turf(src)

	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	set_pin_data(IC_OUTPUT, 4, null)
	if(!T)
		return

	set_pin_data(IC_OUTPUT, 1, T.x)
	set_pin_data(IC_OUTPUT, 2, T.y)
	set_pin_data(IC_OUTPUT, 3, T.z)
	set_pin_data(IC_OUTPUT, 4, "[T.x],[T.y],[T.z]")
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/microphone
	name = "microphone"
	desc = "Useful for spying on people, or for voice-activated machines."
	extended_desc = "This will automatically translate most languages it hears to Galactic Common. \
	The first activation pin is always pulsed when the circuit hears someone talk, while the second one \
	is only triggered if it hears someone speaking a language other than Galactic Common."
	icon_state = "recorder"
	complexity = 8
	inputs = list()
	flags_1 = CONDUCT_1 | HEAR_1
	outputs = list(
	"speaker" = IC_PINTYPE_STRING,
	"message" = IC_PINTYPE_STRING
	)
	activators = list("on message received" = IC_PINTYPE_PULSE_OUT, "on translation" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 5

/obj/item/integrated_circuit/input/microphone/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, message_mode)
	. = ..()
	var/translated = FALSE
	if(speaker && message)
		if(raw_message)
			if(message_langs != get_selected_language())
				translated = TRUE
		set_pin_data(IC_OUTPUT, 1, speaker.GetVoice())
		set_pin_data(IC_OUTPUT, 2, raw_message)

	push_data()
	activate_pin(1)
	if(translated)
		activate_pin(2)

/obj/item/integrated_circuit/input/sensor
	name = "sensor"
	desc = "Scans and obtains a reference for any objects or persons near you. All you need to do is shove the machine in their face."
	extended_desc = "If the 'ignore storage' pin is set to true, the sensor will disregard scanning various storage containers such as backpacks."
	icon_state = "recorder"
	complexity = 12
	inputs = list("ignore storage" = IC_PINTYPE_BOOLEAN)
	outputs = list("scanned" = IC_PINTYPE_REF)
	activators = list("on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 120

/obj/item/integrated_circuit/input/sensor/sense(atom/A, mob/user, prox)
	if(!prox || !A || (ismob(A) && !isliving(A)))
		return FALSE
	if(!check_then_do_work())
		return FALSE
	var/ignore_bags = get_pin_data(IC_INPUT, 1)
	if(ignore_bags)
		var/datum/component/storage/STR = A.GetComponent(/datum/component/storage)
		if(STR)
			return FALSE
	set_pin_data(IC_OUTPUT, 1, WEAKREF(A))
	push_data()
	to_chat(user, "<span class='notice'>You scan [A] with [assembly].</span>")
	activate_pin(1)
	return TRUE

/obj/item/integrated_circuit/input/sensor/ranged
	name = "ranged sensor"
	desc = "Scans and obtains a reference for any objects or persons in range. All you need to do is point the machine towards the target."
	extended_desc = "If the 'ignore storage' pin is set to true, the sensor will disregard scanning various storage containers such as backpacks."
	icon_state = "recorder"
	complexity = 36
	inputs = list("ignore storage" = IC_PINTYPE_BOOLEAN)
	outputs = list("scanned" = IC_PINTYPE_REF)
	activators = list("on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 120

/obj/item/integrated_circuit/input/sensor/ranged/sense(atom/A, mob/user)
	if(!user || !A || (ismob(A) && !isliving(A)))
		return FALSE
	if(user.client)
		if(!(A in view(user.client)))
			return FALSE
	else
		if(!(A in view(user)))
			return FALSE
	if(!check_then_do_work())
		return FALSE
	var/ignore_bags = get_pin_data(IC_INPUT, 1)
	if(ignore_bags)
		if(istype(A, /obj/item/storage))
			return FALSE
	set_pin_data(IC_OUTPUT, 1, WEAKREF(A))
	push_data()
	to_chat(user, "<span class='notice'>You scan [A] with [assembly].</span>")
	activate_pin(1)
	return TRUE

/obj/item/integrated_circuit/input/obj_scanner
	name = "scanner"
	desc = "Scans and obtains a reference for any objects you use on the assembly."
	extended_desc = "If the 'put down' pin is set to true, the assembly will take the scanned object from your hands to its location. \
	Useful for interaction with the grabber. The scanner only works using the help intent."
	icon_state = "recorder"
	complexity = 4
	inputs = list("put down" = IC_PINTYPE_BOOLEAN)
	outputs = list("scanned" = IC_PINTYPE_REF)
	activators = list("on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 20

/obj/item/integrated_circuit/input/obj_scanner/attackby_react(var/atom/A,var/mob/user,intent)
	if(intent!=INTENT_HELP)
		return FALSE
	if(!check_then_do_work())
		return FALSE
	var/pu = get_pin_data(IC_INPUT, 1)
	if(pu)
		user.transferItemToLoc(A,drop_location())
	set_pin_data(IC_OUTPUT, 1, WEAKREF(A))
	push_data()
	to_chat(user, "<span class='notice'>You let [assembly] scan [A].</span>")
	activate_pin(1)
	return TRUE

/obj/item/integrated_circuit/input/internalbm
	name = "internal battery monitor"
	desc = "This monitors the charge level of an internal battery."
	icon_state = "internalbm"
	extended_desc = "This circuit will give you the values of charge, max charge, and the current percentage of the internal battery on demand."
	w_class = WEIGHT_CLASS_TINY
	complexity = 1
	inputs = list()
	outputs = list(
		"cell charge" = IC_PINTYPE_NUMBER,
		"max charge" = IC_PINTYPE_NUMBER,
		"percentage" = IC_PINTYPE_NUMBER,
		"refference to assembly" = IC_PINTYPE_REF,
		"refference to cell" = IC_PINTYPE_REF
		)
	activators = list("read" = IC_PINTYPE_PULSE_IN, "on read" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 1

/obj/item/integrated_circuit/input/internalbm/do_work()
	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	set_pin_data(IC_OUTPUT, 4, null)
	set_pin_data(IC_OUTPUT, 5, null)
	if(assembly)
		set_pin_data(IC_OUTPUT, 4, WEAKREF(assembly))
		if(assembly.battery)
			set_pin_data(IC_OUTPUT, 1, assembly.battery.charge)
			set_pin_data(IC_OUTPUT, 2, assembly.battery.maxcharge)
			set_pin_data(IC_OUTPUT, 3, 100*assembly.battery.charge/assembly.battery.maxcharge)
			set_pin_data(IC_OUTPUT, 5, WEAKREF(assembly.battery))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/externalbm
	name = "external battery monitor"
	desc = "This can read the battery state of any device in view."
	icon_state = "externalbm"
	extended_desc = "This circuit will give you the charge, max charge, and the current percentage values of any device or battery in view."
	w_class = WEIGHT_CLASS_TINY
	complexity = 2
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"cell charge" = IC_PINTYPE_NUMBER,
		"max charge" = IC_PINTYPE_NUMBER,
		"percentage" = IC_PINTYPE_NUMBER
		)
	activators = list("read" = IC_PINTYPE_PULSE_IN, "on read" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 1

/obj/item/integrated_circuit/input/externalbm/do_work()

	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	if(AM)
		var/obj/item/stock_parts/cell/C = AM.get_cell()
		if(C)
			var/turf/A = get_turf(src)
			if(get_turf(AM) in view(A))
				set_pin_data(IC_OUTPUT, 1, C.charge)
				set_pin_data(IC_OUTPUT, 2, C.maxcharge)
				set_pin_data(IC_OUTPUT, 3, C.percent())
	push_data()
	activate_pin(2)
	return

/obj/item/integrated_circuit/input/ntnetsc
	name = "NTNet scanner"
	desc = "This can return the NTNet IDs of a component inside the given object, if there are any."
	icon_state = "signalsc"
	w_class = WEIGHT_CLASS_TINY
	complexity = 2
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"id" = IC_PINTYPE_STRING
		)
	activators = list("read" = IC_PINTYPE_PULSE_IN, "found" = IC_PINTYPE_PULSE_OUT,"not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 1

/obj/item/integrated_circuit/input/ntnetsc/do_work()
	var/atom/AM = get_pin_data_as_type(IC_INPUT, 1, /atom)
	var/datum/component/ntnet_interface/net

	if(AM)
		var/list/processing_list = list(AM)
		while(processing_list.len && !net)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			//Byond does not allow things to be in multiple contents, or double parent-child hierarchies, so only += is needed
			//This is also why we don't need to check against assembled as we go along
			processing_list += A.contents
			net = A.GetComponent(/datum/component/ntnet_interface)

	if(net)
		set_pin_data(IC_OUTPUT, 1, net.hardware_id)
		push_data()
		activate_pin(2)
	else
		set_pin_data(IC_OUTPUT, 1, null)
		push_data()
		activate_pin(3)

/obj/item/integrated_circuit/input/matscan
	name = "material scanner"
	desc = "This special module is designed to get information about material containers of different machinery, \
			like ORM, lathes, etc."
	icon_state = "video_camera"
	complexity = 6
	inputs = list(
		"target" = IC_PINTYPE_REF
		)
	outputs = list(
		"Iron"				 	= IC_PINTYPE_NUMBER,
		"Glass"					= IC_PINTYPE_NUMBER,
		"Silver"				= IC_PINTYPE_NUMBER,
		"Gold"					= IC_PINTYPE_NUMBER,
		"Diamond"				= IC_PINTYPE_NUMBER,
		"Solid Plasma"			= IC_PINTYPE_NUMBER,
		"Uranium"				= IC_PINTYPE_NUMBER,
		"Bananium"				= IC_PINTYPE_NUMBER,
		"Titanium"		= IC_PINTYPE_NUMBER,
		"Bluespace Mesh"		= IC_PINTYPE_NUMBER,
		"Biomass"				= IC_PINTYPE_NUMBER,
		)
	activators = list(
		"scan" = IC_PINTYPE_PULSE_IN,
		"on scanned" = IC_PINTYPE_PULSE_OUT,
		"not scanned" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40
	var/list/mtypes = list(/datum/material/iron, /datum/material/glass, /datum/material/silver, /datum/material/gold, /datum/material/diamond, /datum/material/plasma, /datum/material/uranium, /datum/material/bananium, /datum/material/titanium, /datum/material/bluespace, /datum/material/biomass)


/obj/item/integrated_circuit/input/matscan/do_work()
	var/atom/movable/H = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/turf/T = get_turf(src)
	var/datum/component/material_container/mt = H.GetComponent(/datum/component/material_container)
	if(!mt) //Invalid input
		return
	if(H in view(T)) // This is a camera. It can't examine thngs,that it can't see.
		for(var/I in 1 to mtypes.len)
			var/amount = mt.materials[mtypes[I]]
			if(amount)
				set_pin_data(IC_OUTPUT, I, amount)
			else
				set_pin_data(IC_OUTPUT, I, null)
		push_data()
		activate_pin(2)
	else
		activate_pin(3)

/obj/item/integrated_circuit/input/atmospheric_analyzer
	name = "atmospheric analyzer"
	desc = "A miniaturized analyzer which can scan anything that contains gases. Leave target as NULL to scan the air around the assembly."
	extended_desc = "The nth element of gas amounts is the number of moles of the \
					nth gas in gas list. \
					Pressure is in kPa, temperature is in Kelvin. \
					Due to programming limitations, scanning an object that does \
					not contain a gas will return the air around it instead."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"target" = IC_PINTYPE_REF
			)
	outputs = list(
			"gas list" = IC_PINTYPE_LIST,
			"gas amounts" = IC_PINTYPE_LIST,
			"total moles" = IC_PINTYPE_NUMBER,
			"pressure" = IC_PINTYPE_NUMBER,
			"temperature" = IC_PINTYPE_NUMBER,
			"volume" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"scan" = IC_PINTYPE_PULSE_IN,
			"on success" = IC_PINTYPE_PULSE_OUT,
			"on failure" = IC_PINTYPE_PULSE_OUT
			)
	power_draw_per_use = 5

/obj/item/integrated_circuit/input/atmospheric_analyzer/do_work()
	for(var/i=1 to 6)
		set_pin_data(IC_OUTPUT, i, null)
	var/atom/target = get_pin_data_as_type(IC_INPUT, 1, /atom)
	if(!target)
		target = get_turf(src)
	if( get_dist(get_turf(target),get_turf(src)) > 1 )
		activate_pin(3)
		return

	var/datum/gas_mixture/air_contents = target.return_air()
	if(!air_contents)
		activate_pin(3)
		return

	var/list/gases = air_contents.get_gases()
	var/list/gas_names = list()
	var/list/gas_amounts = list()
	for(var/id in gases)
		var/name = GLOB.meta_gas_info[id][META_GAS_NAME]
		var/amt = round(air_contents.get_moles(id), 0.001)
		gas_names.Add(name)
		gas_amounts.Add(amt)

	set_pin_data(IC_OUTPUT, 1, gas_names)
	set_pin_data(IC_OUTPUT, 2, gas_amounts)
	set_pin_data(IC_OUTPUT, 3, round(air_contents.total_moles(), 0.001))
	set_pin_data(IC_OUTPUT, 4, round(air_contents.return_pressure(), 0.001))
	set_pin_data(IC_OUTPUT, 5, round(air_contents.return_temperature(), 0.001))
	set_pin_data(IC_OUTPUT, 6, round(air_contents.return_volume(), 0.001))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/data_card_reader
	name = "data card reader"
	desc = "A circuit that can read from and write to data cards."
	extended_desc = "Setting the \"write mode\" boolean to true will cause any data cards that are used on the assembly to replace\
 their existing function and data strings with the given strings, if it is set to false then using a data card on the assembly will cause\
 the function and data strings stored on the card to be written to the output pins."
	icon_state = "card_reader"
	complexity = 4
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
		"function" = IC_PINTYPE_STRING,
		"data to store" = IC_PINTYPE_STRING,
		"write mode" = IC_PINTYPE_BOOLEAN
	)
	outputs = list(
		"function" = IC_PINTYPE_STRING,
		"stored data" = IC_PINTYPE_STRING
	)
	activators = list(
		"on write" = IC_PINTYPE_PULSE_OUT,
		"on read" = IC_PINTYPE_PULSE_OUT
	)

/obj/item/integrated_circuit/input/data_card_reader/attackby_react(obj/item/I, mob/living/user, intent)
	var/obj/item/card/data/card = I.GetCard()
	var/write_mode = get_pin_data(IC_INPUT, 3)
	if(card)
		if(write_mode == TRUE)
			card.function = get_pin_data(IC_INPUT, 1)
			card.data = get_pin_data(IC_INPUT, 2)
			push_data()
			activate_pin(1)
		else
			set_pin_data(IC_OUTPUT, 1, card.function)
			set_pin_data(IC_OUTPUT, 2, card.data)
			push_data()
			activate_pin(2)
	else
		return FALSE
	return TRUE

//Adding some color to cards aswell, because why not
/obj/item/card/data/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/integrated_electronics/detailer))
		var/obj/item/integrated_electronics/detailer/D = I
		detail_color = D.detail_color
		update_icon()
	return ..()


//Interceptor
//Intercepts a telecomms signal, aka a radio message (;halp getting griff)
//Inputs:
//On (Boolean): If on, the circuit intercepts radio signals. Otherwise it does not. This doesn't affect no pass!
//No pass (Boolean): Decides if the signal will be silently intercepted
//					(false) or also blocked from being sent on the radio (true)
//Outputs:
//Source: name of the mob
//Job: job of the mob
//content: the actual message
//spans: a list of spans, there's not much info about this but stuff like robots will have "robot" span
/obj/item/integrated_circuit/input/tcomm_interceptor
	name = "telecommunication interceptor"
	desc = "This circuit allows for telecomms signals \
	to be fetched prior to being broadcasted."
	extended_desc = "Similar \
	to the old NTSL system of realtime signal modification, \
	the circuit connects to telecomms and fetches data \
	for each signal, which can be sent normally or blocked, \
	for cases such as other circuits modifying certain data. \
	Beware, this cannot stop signals from unreachable areas, such \
	as space or zlevels other than station's one."
	complexity = 30
	cooldown_per_use = 0.1
	w_class = WEIGHT_CLASS_SMALL
	inputs = list(
		"intercept" = IC_PINTYPE_BOOLEAN,
		"no pass" = IC_PINTYPE_BOOLEAN
		)
	outputs = list(
		"source" = IC_PINTYPE_STRING,
		"job" = IC_PINTYPE_STRING,
		"content" = IC_PINTYPE_STRING,
		"spans" = IC_PINTYPE_LIST,
		"frequency" = IC_PINTYPE_NUMBER
		)
	activators = list(
		"on intercept" = IC_PINTYPE_PULSE_OUT
		)
	power_draw_idle = 0
	spawn_flags = IC_SPAWN_RESEARCH
	var/obj/machinery/telecomms/receiver/circuit/receiver
	var/list/freq_blacklist = list(FREQ_CENTCOM,FREQ_SYNDICATE,FREQ_CTF_RED,FREQ_CTF_BLUE)

/obj/item/integrated_circuit/input/tcomm_interceptor/Initialize()
	. = ..()
	receiver = new(src)
	receiver.holder = src

/obj/item/integrated_circuit/input/tcomm_interceptor/Destroy()
	qdel(receiver)
	GLOB.ic_jammers -= src
	..()

/obj/item/integrated_circuit/input/tcomm_interceptor/receive_signal(datum/signal/signal)
	if((signal.transmission_method == TRANSMISSION_SUBSPACE) && get_pin_data(IC_INPUT, 1))
		if(signal.frequency in freq_blacklist)
			return
		set_pin_data(IC_OUTPUT, 1, signal.data["name"])
		set_pin_data(IC_OUTPUT, 2, signal.data["job"])
		set_pin_data(IC_OUTPUT, 3, signal.data["message"])
		set_pin_data(IC_OUTPUT, 4, signal.data["spans"])
		set_pin_data(IC_OUTPUT, 5, signal.frequency)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/tcomm_interceptor/on_data_written()
	if(get_pin_data(IC_INPUT, 2))
		GLOB.ic_jammers |= src
		if(get_pin_data(IC_INPUT, 1))
			power_draw_idle = 200
		else
			power_draw_idle = 100
	else
		GLOB.ic_jammers -= src
		if(get_pin_data(IC_INPUT, 1))
			power_draw_idle = 100
		else
			power_draw_idle = 0

/obj/item/integrated_circuit/input/tcomm_interceptor/power_fail()
	set_pin_data(IC_INPUT, 1, 0)
	set_pin_data(IC_INPUT, 2, 0)

/obj/item/integrated_circuit/input/tcomm_interceptor/disconnect_all()
	set_pin_data(IC_INPUT, 1, 0)
	set_pin_data(IC_INPUT, 2, 0)
	..()


// -Inputlist- //
/obj/item/integrated_circuit/input/selection
	name = "selection circuit"
	desc = "This circuit lets you choose between different strings from a selection."
	extended_desc = "This circuit lets you choose between up to 4 different values from selection of up to 8 strings that you can set. Null values are ignored and the chosen value is put out in selected."
	icon_state = "addition"
	can_be_asked_input = 1
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
		"A" = IC_PINTYPE_STRING,
		"B" = IC_PINTYPE_STRING,
		"C" = IC_PINTYPE_STRING,
		"D" = IC_PINTYPE_STRING,
		"E" = IC_PINTYPE_STRING,
		"F" = IC_PINTYPE_STRING,
		"G" = IC_PINTYPE_STRING,
		"H" = IC_PINTYPE_STRING
	)
	activators = list(
		"on selected" = IC_PINTYPE_PULSE_OUT
	)
	outputs = list(
		"selected" = IC_PINTYPE_STRING
	)

/obj/item/integrated_circuit/input/selection/ask_for_input(mob/user)
	var/list/selection = list()
	for(var/k in 1 to inputs.len)
		var/I = get_pin_data(IC_INPUT, k)
		if(istext(I))
			selection.Add(I)
	var/selected = input(user,"Choose input.","Selection") in selection
	if(!selected)
		return
	set_pin_data(IC_OUTPUT, 1, selected)
	push_data()
	activate_pin(1)


// -storage examiner- // **works**
/obj/item/integrated_circuit/input/storage_examiner
	name = "storage examiner circuit"
	desc = "This circuit lets you scan a storage's content. (backpacks, toolboxes etc.)"
	extended_desc = "The items are put out as reference, which makes it possible to interact with them. Additionally also gives the amount of items."
	icon_state = "grabber"
	can_be_asked_input = 1
	complexity = 6
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
		"storage" = IC_PINTYPE_REF
	)
	activators = list(
		"examine" = IC_PINTYPE_PULSE_IN,
		"on examined" = IC_PINTYPE_PULSE_OUT
	)
	outputs = list(
		"item amount" = IC_PINTYPE_NUMBER,
		"item list" = IC_PINTYPE_LIST
	)
	power_draw_per_use = 85

/obj/item/integrated_circuit/input/storage_examiner/do_work()
	var/obj/item/storage = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(!istype(storage,/obj/item/storage))
		return

	set_pin_data(IC_OUTPUT, 1, storage.contents.len)

	var/list/regurgitated_contents = list()
	for(var/obj/o in storage.contents)
		regurgitated_contents.Add(WEAKREF(o))


	set_pin_data(IC_OUTPUT, 2, regurgitated_contents)
	push_data()
	activate_pin(2)
