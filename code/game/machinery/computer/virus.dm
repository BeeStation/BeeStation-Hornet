datum/malware
	var/name = "Virus"
	var/resistance = 10
	var/obj/machinery/computer/console

datum/malware/proc/can_install(mob/user, obj/machinery/computer/source)	//check if proper console
	if (!istype(source))
		return FALSE
	return TRUE

datum/malware/proc/install(mob/user, obj/machinery/computer/source)	//inject in console
	if (source.infection && source.infection.resistance<0)
		source.infection.Destroy()
	if (!source.infection)
		source.infection = src
		console = source
		message_admins("[ADMIN_LOOKUPFLW(usr)] infected [console] with [name] at [ADMIN_VERBOSEJMP(T)].")
		log_game("[key_name(usr)] infected [console] with [name] at [AREACOORD(T)].")
		return TRUE
	return FALSE

datum/malware/proc/on_interact(mob/user)	//on user interact with computer/console
	return

datum/malware/proc/on_process()	//prevents computer from processing
	return TRUE

datum/malware/proc/on_request_login(obj/machinery/computer/source,obj/item/card/id/suckers_id)	//on sucker put ID into the console
		//save ID
		//output saved ID if suckers ID is null
	return	suckers_id
	
datum/malware/proc/Destroy()	//they removed the infection
	console.infection = null
	qdel(src)

//	---	CRAFTABLE	---

//	<3	HONKER	<3	/
//	machine honks randomly
//	-------------	/
datum/malware/clown
	name = "H0NK3R"	
	resistance = -1	//removed by absolutely anything
	
datum/malware/clown/on_process()	
	if (prob(2))
		playsound(console, 'sound/items/bikehorn.ogg', 25, FALSE)
	return TRUE
	
//	<3	KILLER	<3	/
//	prevents console from being operated by humans
//	-------------	/
datum/malware/killer
	name = "D0M3-N@T.r1x"	
	resistance = 5
	
datum/malware/killer/can_install(mob/user, obj/machinery/computer/source)	
	. = ..()
	if (.)
		console.stat |= VIRUSED
	return .
	
datum/malware/killer/Destroy()	
	if (console.stat & VIRUSED)
		console.stat ~= VIRUSED
	 ..()
	 
datum/malware/killer/strong
	name = "D0M3-N@T_2.r1x"	
	resistance = 100

//	<3	TIDER	<3	/
//	Scrambles the name and ID of the user
//	-------------	/
datum/malware/tider
	var/name = "T1-D3R"	
	var/obj/item/card/id/cached_id
	resistance = 5
requires ID

datum/malware/tider/install()	
	. = ..()
	cached_id = new ()
	cached_id.registered_name = "Assistant McAssistantson"
	cached_id.assignment = "Assistant"
	return .
	
datum/malware/tider/on_request_login(obj/machinery/computer/source,obj/item/card/id/suckers_id)	
	if (!suckers_id)
		return
	cached_id.access_txt = suckers_id.access_txt
	cached_id.access = suckers_id.access
	return cached_id

//	<3	CUBAN	<3	/
//	bomb explodes the console when used, small explosion
//	-------------	/
datum/malware/cuban
	name = "Trojan Pete"	
	resistance = 12
	
datum/malware/cuban/on_interact(mob/user)	//on user interact with computer/console
		to_chat(user, "<span class='warning'>The [console] displays a message: Bye, sucker!"</span>")
	addtimer(CALLBACK(attached_action, /datum/malware/cuban.proc/detonate_machine), 20) 
	Destroy()
	
datum/malware/cuban/proc/detonate_machine()
	if(console && !QDELETED(console))
		var/turf/T = get_turf(console)
		explosion(get_turf(console), 0, 1, 2, 0)


//	---	SYNDICATE SELECTION	---

//	<3	LOGGER	<3	/
//	Copies the last inserted ID
//	-------------	/
datum/malware/logger
	var/name = "Keylogger"	
	var/obj/item/card/id/cached_id
	resistance = 16
requires ID

datum/malware/logger/on_request_login(obj/machinery/computer/source,obj/item/card/id/suckers_id)	
	if (!suckers_id)
		return cached_id
	if (!cached_id)
		cached_id = new ()
	cached_id.registered_name = registered_name.access
	cached_id.assignment = suckers_id.assignment
	cached_id.access_txt = suckers_id.access_txt
	cached_id.access = suckers_id.access
	return suckers_id
		
//	<3	MOBSPAWNER	<3	/
//	Injects cloning/research/engineering/botany/teleporter, outputs hostile mobs... AI/nukeops only
//	-------------	/
datum/malware/gate
	name = "G4T3"	
	resistance = 9001
	var/next_mob_time = 0