datum/virus
	var/name = "Virus"
	var/resistance = 10
	var/obj/machinery/computer/console

datum/virus/proc/can_install(mob/user, obj/machinery/computer/source)	//check if proper console
	if (!istype(source))
		return FALSE
	return TRUE

datum/virus/proc/install(mob/user, obj/machinery/computer/source)	//inject in console
	if (!source.infection)
		source.infection = src
		console = source
		message_admins("[ADMIN_LOOKUPFLW(usr)] infected [console] with [name] at [ADMIN_VERBOSEJMP(T)].")
		log_game("[key_name(usr)] infected [console] with [name] at [AREACOORD(T)].")
		return TRUE
	return FALSE

datum/virus/proc/on_interact(mob/user)	//on user interact with computer/console
	return

datum/virus/proc/on_process()	//prevents computer from processing
	return TRUE

datum/virus/proc/on_charge()	//prevents computer from gaining power
	return TRUE

datum/virus/proc/on_request_login(obj/machinery/computer/source,obj/item/card/id/suckers_id)	//on sucker put ID into the console
		//save ID
		//output saved ID if suckers ID is null
	return	suckers_id
	
datum/virus/proc/Destroy()	//they removed the infection
	console.infection = null
	qdel(src)

//	---	CRAFTABLE	---

/*	<3	KILLER	<3	*
 *	prevents console from opeating
/*	-------------	*/
datum/virus/killer
	name = "K1LL3R"	
	resistance = 5
	
datum/virus/killer/on_process()	
	return FALSE
	
datum/virus/killer/on_charge()	
	return FALSE

/*	<3	TIDER	<3	*
 *	Scrambles the name and ID of the user
/*	-------------	*/
datum/virus/tider
	var/name = "T1-D3R"	
	var/obj/item/card/id/cached_id
	resistance = 10

datum/virus/tider/install()	
	. = ..()
	cached_id = new ()
	cached_id.registered_name = "Assistant McAssistantson"
	cached_id.assignment = "Assistant"
	return .
	
datum/virus/tider/on_request_login(obj/machinery/computer/source,obj/item/card/id/suckers_id)	//on sucker put ID into the console
	if (!suckers_id)
		return
	cached_id.access_txt = suckers_id.access_txt
	cached_id.access = suckers_id.access
	return	cached_id


//	---	SYNDICATE SELECTION	---

/*	<3	LOGGER	<3	*
 *	Copies the last inserted ID
/*	-------------	*/
datum/virus/logger
	var/name = "Keylogger"	
	var/obj/item/card/id/cached_id
	resistance = 14

datum/virus/logger/on_request_login(obj/machinery/computer/source,obj/item/card/id/suckers_id)	//on sucker put ID into the console
	if (!suckers_id)
		return cached_id
	if (!cached_id)
		cached_id = new ()
	cached_id.registered_name = registered_name.access
	cached_id.assignment = suckers_id.assignment
	cached_id.access_txt = suckers_id.access_txt
	cached_id.access = suckers_id.access
	return cached_id


//	---	CRAFTABLE	---

/*	<3	GREMLIN	<3	*
 *	bomb explodes the console when used, small explosion
/*	-------------	*/
datum/virus/cuban
	name = "Trojan Pete"	
	resistance = 12
	
datum/virus/cuban/on_interact(mob/user)	//on user interact with computer/console
		to_chat(user, "<span class='warning'>The [console] displays a message: Bye, sucker!"</span>")
	addtimer(CALLBACK(attached_action, /datum/virus/cuban.proc/detonate_machine), 20) 
	Destroy()
	
datum/virus/cuban/proc/detonate_machine()
	if(console && !QDELETED(console))
		var/turf/T = get_turf(console)
		explosion(get_turf(console), 0, 1, 2, 0)