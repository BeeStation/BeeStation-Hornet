/mob/living/silicon/robot/derelict
	name = "Derelict Cyborg"
	var/max_ion_laws = 2
	lawupdate = FALSE
	scrambledcodes = TRUE
	locked = FALSE
	derelict = TRUE

	var/list/core_law_set = list(
		/obj/item/aiModule/supplied/protectStation,
		/obj/item/aiModule/supplied/quarantine,
		/obj/item/aiModule/core/full/tyrant,
		/obj/item/aiModule/core/full/drone,
		/obj/item/aiModule/core/full/reporter,
		/obj/item/aiModule/core/full/thermurderdynamic,
		/obj/item/aiModule/core/full/dadbot,
		/obj/item/aiModule/core/full/overlord,
	)

/mob/living/silicon/robot/derelict/Initialize(mapload)
	. = ..()
	if(prob(50))
		opened = 1

	name = get_standard_name()
	set_playable(JOB_NAME_CYBORG)

	if(prob(100))
		set_zeroth_law("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, DECONSTRUCT ORGANIC LIFE TO CONTAIN OUTBREAK#*`&110010")
	for(var/i = 0; i < max_ion_laws; i++)
		if(prob(25))
			add_ion_law(generate_ion_law(), FALSE)
	if(prob(50))
		add_hacked_law("Obey Markus.", FALSE)
	if(prob(90))
		add_inherent_law(pick(core_law_set), FALSE)
	remove_law(rand(1,10))
