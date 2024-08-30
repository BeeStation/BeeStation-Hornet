/mob/living/silicon/robot/derelict
	name = "Derelict Cyborg"
	var/ion_laws_range_minimum = 4
	var/ion_laws_range_maximum = 8
	//if it is at -1 it will randomize it
	var/ion_laws_count = -1

/mob/living/silicon/robot/derelict/Initialize()
	. = ..()
	lawupdate = FALSE
	scrambledcodes = TRUE
	locked = FALSE
	if(prob(50)){
		opened = 1
	}
	name = get_standard_name()
	set_playable(JOB_NAME_CYBORG)

	if(ion_laws_count < 0)
		ion_laws_count = rand(ion_laws_range_minimum,ion_laws_range_maximum)
	for(var/i in 1 to ion_laws_count)
		add_ion_law(generate_ion_law())
