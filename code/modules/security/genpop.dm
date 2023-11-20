//From NSV13
//Credit to oraclestation for the idea! This just a recode...
// Recode CanAllowThrough() and machine_stat

#define MAX_TIMER 10 HOURS //Permabrig.
#define PRESET_SHORT 5 MINUTES
#define PRESET_MEDIUM 10 MINUTES
#define PRESET_LONG 15 MINUTES

/obj/machinery/turnstile
	name = "turnstile"
	desc = "A mechanical door that permits one-way access to the brig."
	icon = 'icons/obj/machines/turnstile.dmi' //ADD ICON
	icon_state = "turnstile_map" //ADD ICON
	power_channel = AREA_USAGE_ENVIRON
	density = TRUE
	pass_flags_self = PASSTRANSPARENT | PASSGRILLE | PASSSTRUCTURE
	obj_integrity = 250
	max_integrity = 250
	integrity_failure = 74
	//Robust! It'll be tough to break...
	armor = list("melee" = 50, "bullet" = 20, "laser" = 0, "energy" = 80, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50, "stamina" = 0)
	anchored = TRUE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	//Seccies and brig phys may always pass, either way.
	req_one_access = list(ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_PRISONER)
	//Cooldown so we don't shock a million times a second
	COOLDOWN_DECLARE(shock_cooldown)
	circuit = /obj/item/circuitboard/machine/turnstile

/obj/item/circuitboard/machine/turnstile
	name = "Turnstile circuitboard"
	desc = "The circuit board for a turnstile machine."
	build_path = /obj/machinery/turnstile

//Executive officer's line variant. For rule of cool.
/*/obj/machinery/turnstile/xo
	name = "\improper XO line turnstile"
	req_one_access = list(ACCESS_BRIG, ACCESS_HEADS)
*/

/obj/structure/closet/secure_closet/genpop
	name = "Prisoner locker"
	desc = "A locker to store a prisoner's valuables, that they can collect at a later date."
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	locked = FALSE
	var/registered_name = null

/obj/structure/closet/secure_closet/genpop/Initialize(mapload)
	. = ..()

/obj/structure/closet/secure_closet/genpop/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/I = null
	if(istype(W, /obj/item/card/id))
		I = W
	else
		I = W.GetID()
	if(istype(I))
		if(broken)
			to_chat(user, "<span class='danger'>It appears to be broken.</span>")
			return
		if(!I || !I.registered_name)
			return
		//Sec officers can always open the lockers. Bypass the ID setting behaviour.
		//Buuut, if they're holding a prisoner ID, that takes priority.
		if(allowed(user) && !istype(I, /obj/item/card/id/prisoner))
			locked = !locked
			update_icon()
			return TRUE
		//Handle setting a new ID.
		if(!registered_name)
			if(istype(I, /obj/item/card/id/prisoner)) //Don't claim the locker for a sec officer mind you...
				var/obj/item/card/id/prisoner/P = I
				if(P.assigned_locker)
					to_chat(user, "<span class='notice'>This ID card is already registered to a locker.</span>")
					return FALSE
				P.assigned_locker = src
				registered_name = I.registered_name
				desc = "Assigned to: [I.registered_name]."
				say("Locker sealed. Assignee: [I.registered_name]")

				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
				locked = TRUE
				update_icon()
			else
				to_chat(user, "<span class='danger'>Invalid ID. Only prisoners / officers may use these lockers.</span>")
			return FALSE
		//It's an ID, and is the correct registered name.
		if(istype(I) && (registered_name == I.registered_name))
			var/obj/item/card/id/prisoner/ID = I
			//Not a prisoner ID.
			if(!istype(ID))
				return FALSE
			if(ID.served_time < ID.sentence)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 80) //find another sound
				say("DANGER: PRISONER HAS NOT COMPLETED SENTENCE. AWAIT SENTENCE COMPLETION. COMPLIANCE IS IN YOUR BEST INTEREST.")
				return FALSE
			visible_message("<span class='warning'>[user] slots [I] into [src]'s ID slot, freeing its contents!</span>")
			registered_name = null
			desc = initial(desc)
			locked = FALSE
			update_icon()
			qdel(I)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			return
		else
			to_chat(user, "<span class='danger'>Access Denied.</span>")
	else
		return ..()


/obj/machinery/turnstile/Initialize(mapload)
	. = ..()
	icon_state = "turnstile"
	//Attach a signal handler to the turf below for when someone passes through.
	//Signal automatically gets unattached and reattached when we're moved.
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/turnstile/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(istype(arrived, /mob))
		flick("operate", src)
		playsound(src,'sound/items/ratchet.ogg',50,0,3)

///Handle movables (especially mobs) bumping into us.
/obj/machinery/turnstile/Bumped(atom/movable/movable)
	. = ..()
	if(!istype(movable, /mob)) //just let non-mobs bump
		return
	if(machine_stat & BROKEN) //try to shock mobs if we're broken
		try_shock(movable)
		return
	//pretend to be an airlock if a mob bumps us
	//(which means they tried to move through but didn't have access)
	flick("deny", src)
	playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)

///Shock attacker if we're broken
/obj/machinery/turnstile/attackby(obj/item/item, mob/user, params)
	if(default_deconstruction_screwdriver(user, "turnstile", "turnstile", item))
		update_appearance()//add proper panel icons
		return
	if(default_deconstruction_crowbar(item))
		return
	. = ..()
	if(machine_stat & BROKEN)
		try_shock(user)

//Shock attack if something is thrown at it if we're broken
/obj/machinery/turnstile/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && BROKEN)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				playsound(src, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
				tesla_zap(src, 3, 8000, TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE | TESLA_MOB_STUN | TESLA_ALLOW_DUPLICATES) // Around 20 damage for humans
	return ..()

/obj/machinery/turnstile/welder_act(mob/living/user, obj/item/I)
	//Shamelessly copied airlock code
	. = TRUE //Never attack it with a welding tool
	if(!I.tool_start_check(user, amount=0))
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>The turnstile doesn't need repairing.</span>")
		return
	user.visible_message("[user] is welding the turnstile.", \
				"<span class='notice'>You begin repairing the turnstile...</span>", \
				"<span class='italics'>You hear welding.</span>")
	if(I.use_tool(src, user, 40, volume=50))
		obj_integrity = max_integrity
		set_machine_stat(machine_stat & ~BROKEN)
		user.visible_message("[user.name] has repaired [src].", \
							"<span class='notice'>You finish repairing the turnstile.</span>")
		update_icon()
		return

/obj/machinery/turnstile/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(. == TRUE)
		return TRUE //Allow certain things declared with pass_flags_self through wihout side effects
	if(machine_stat & BROKEN)
		return FALSE
	if(get_dir(loc, target) == dir) //Always let people through in one direction. Not used at the moment.
		return TRUE
	var/allowed = allowed(mover)
	//Everyone with access can drag you out. Prisoners can't drag each other out.
	if(!allowed && mover.pulledby)
		var/mob/living/carbon/human/H = mover.pulledby
		if(istype(H.wear_id, /obj/item/card/id/prisoner) || istype(H.get_active_held_item(), /obj/item/card/id/prisoner))
			return FALSE
		else
			allowed = allowed(mover.pulledby)
	if(allowed)
		return TRUE
	return FALSE

///Shock user if we can
/obj/machinery/turnstile/proc/try_shock(mob/user)
	if(machine_stat & NOPOWER)		// unpowered, no shock
		return FALSE
	if(!COOLDOWN_FINISHED(src, shock_cooldown)) //Don't shock in very short succession to avoid stuff getting out of hand.
		return FALSE
	COOLDOWN_START(src, shock_cooldown, 0.5 SECONDS)
	do_sparks(5, TRUE, src)
	if(electrocute_mob(user, power_source = get_area(src), source = src, dist_check = TRUE))
		return TRUE
	else
		return FALSE

//Officer interface.
/obj/machinery/genpop_interface
	name = "Prisoner Management Interface"
	icon = 'icons/obj/machines/genpop_display.dmi'
	icon_state = "frame"
	desc = "An all-in-one interface for officers to manage prisoners!"
	req_access = list(ACCESS_SECURITY)
	density = FALSE
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1
	circuit = /obj/item/circuitboard/machine/genpop_interface
	var/time_to_screwdrive = 20
	var/next_print = 0
	var/desired_sentence = 60 //What sentence do you want to give them?
	var/desired_crime //What is their crime?
	var/desired_name //What is their name?
	var/desired_description //Description of their crime
	var/obj/item/radio/Radio //needed to send messages to sec radio
	var/static/list/crimes = list() //The list of crimes the officer user will either be filtering or searching in.
	var/search_text //Text for the search bar

	var/static/list/minor = list(
		list(name="Assault", tooltip="To use physical force against someone without the apparent intent to kill them.", colour="yellow",icon="hand-rock",sentence="5"),
		list(name="Pickpocketting", tooltip="To steal items from another's person..", colour="yellow",icon="mask",sentence="5"),
		list(name="Minor Vandalism", tooltip="To damage, destroy, or permanently deface non-critical furniture, vendors, or personal property.", colour="yellow",icon="house-damage",sentence="5"),
		list(name="Vigilantism", tooltip="To perform the responsibilities and duties of the security department without approval or due cause to act.", colour="yellow",icon="user-secret",sentence="5"),
		list(name="Illegal Distribution", tooltip="The possession of dangerous or illegal drugs/equipment in a quantity greater than that which is reasonable for personal consumption.", colour="yellow",icon="joint",sentence="5"),
		list(name="Disturbing the Peace", tooltip="	To knowingly organize a movement which disrupts the normal operations of a department.", colour="yellow",icon="fist-raised",sentence="5"),
		list(name="Negligence", tooltip="To be negligent in one's duty to an extent that it may cause harm, illness, or other negative effect, to another.", colour="yellow",icon="low-vision",sentence="5"),
		list(name="Trespass", tooltip="To be in an area which a person has either not purposefully been admitted to, does not have access, or has been asked to leave by someone who has access to that area.", colour="yellow",icon="walking",sentence="5"),
		list(name="Breaking and Entering", tooltip="To trespass into an area using a method of forcible entry.", colour="yellow",icon="door-open",sentence="5"),
		list(name="Discriminatory Language", tooltip="To use language which demeans, generalizes, or otherwise de-personafies the individual at which it is targeted.", colour="yellow",icon="comment-slash",sentence="5"),
		list(name="Fine Evasion", tooltip="To purposefully avoid or refuse to pay a legal fine.", colour="yellow",icon="dollar-sign",sentence="5"),
		list(name="Religious Activity outside of the chapel", tooltip="To convert, proselytize, hold rituals or otherwise attempt to act in the name of a religion or deity outside of the chapel.", colour="yellow",icon="cross",sentence="5"),
	)
	var/static/list/misdemeanours = list(
		list(name="Aggravated Assault", tooltip="To take physical action against a person with intent to grievously harm, but not to kill.", colour="orange",icon="user-injured",sentence="10"),
		list(name="Theft", tooltip="To steal equipment or items from a workplace, or items of extraordinary value from one's person.", colour="orange",icon="mask",sentence="10"),
		list(name="Major Vandalism", tooltip="To destroy or damage non-critical furniture, vendors, or personal property in a manor that can not be repaired.", colour="orange",icon="house-damage",sentence="10"),
		list(name="Conspiracy", tooltip="To knowingly work with another person in the interest of committing an illegal action.", colour="orange",icon="user-friends",sentence="10"),
		list(name="Hostile Agent", tooltip="To knowingly act as a recruiter, representative, messenger, ally, benefactor, or other associate of a hostile organization as defined within Code 405(EOTC).", colour="orange",icon="user-ninja",sentence="10"),
		list(name="Contrabang Equipment Possession", tooltip="To possess equipment not approved for use or production aboard Nanotrasen stations. This includes equipment produced by The Syndicate, Wizard Federation, or any other hostile organization as defined within Code 405(EOTC).", colour="orange",icon="briefcase",sentence="10"),
		list(name="Rioting", tooltip="To act as a member in a group which collectively commits acts of major vandalism, sabotage, grand sabotage, or other felony crimes.", colour="orange",icon="fist-raised",sentence="10"),
		list(name="High Negligence", tooltip="To be negligent in one's duty to an extent that it may cause harm to multiple individuals, a department, or in a manor which directly leads to a serious injury of another person which requires emergency medical treatment.", colour="orange",icon="blind",sentence="10"),
		list(name="Trespass, Inherently Dangerous Areas", tooltip="Trespassing in an area which may lead to the injury of self, or others.", colour="orange",icon="door-closed",sentence="10"),
		list(name="Breaking and Entering, Inherently Dangerous Areas", tooltip="To trespass into an area which may lead to the injury of self or others using forcible entry.", colour="orange",icon="door-open",sentence="10"),
		list(name="Insubordination", tooltip="To knowingly disobey a lawful order from a superior.", colour="orange",icon="hand-middle-finger",sentence="10"),
		list(name="Fraud", tooltip="To misrepresent ones intention in the interest of gaining property or money from another individual.", colour="orange",icon="comment-dollar",sentence="10"),
		list(name="Genetic Mutilation", tooltip="To purposefully modify an individual's genetic code without consent, or with intent to harm.", colour="orange",icon="dna",sentence="10"),
	)
	var/static/list/major = list(
		list(name="Murder", tooltip="To purposefully kill someone.", colour="bad",icon="skull",sentence="15"),
		list(name="Larceny", tooltip="To steal rare, expensive (Items of greater than 1000 credit value), or restricted equipment from secure areas or one's person.", colour="bad",icon="mask",sentence="15"),
		list(name="Sabotage", tooltip="To destroy station assets or resources critical to normal or emergency station procedures, or cause sections of the station to become uninhabitable.", colour="bad",icon="bomb",sentence="15"),
		list(name="High Conspiracy", tooltip="To knowingly work with another person in the interest of committing a major or greater crime.", colour="bad",icon="users",sentence="15"),
		list(name="Hostile Activity", tooltip="	To knowingly commit an act which is in direct opposition to the interests of Nanotrasen, Or to directly assist a known enemy of the corporation.", colour="bad",icon="thumbs-down",sentence="15"),
		list(name="Possession, Illegal Inherently Dangerous Equipment", tooltip="To possess restricted or illegal equipment which has a primary purpose of causing harm to others, or large amounts of destruction..", colour="bad",icon="exclamation-triangle",sentence="15"),
		list(name="Inciting a Riot", tooltip="To perform actions in the interest of causing large amounts of unrest up to and including rioting.", colour="bad",icon="fist-raised",sentence="15"),
		list(name="Manslaughter", tooltip="To unintentionally kill someone through negligent, but not malicious, actions.", colour="bad",icon="book-dead",sentence="15"),
		list(name="Trespass, High Security Areas", tooltip="Trespassing in any of the following without appropriate permission or access: Command areas, Personal offices, Weapons storage, weapon production, explosive storage, explosive production, or other high security areas.", colour="bad",icon="running",sentence="15"),
		list(name="Breaking and Entering, High Security Areas", tooltip="To commit trespassing into a secure area as defined in Code 309(Trespass, High Security Areas) using forcible entry.", colour="bad",icon="door-open",sentence="15"),
		list(name="Dereliction", tooltip="To willfully abandon an obligation that is critical to the station's continued operation.", colour="bad",icon="walking",sentence="15"),
		list(name="Corporate Fraud", tooltip="To misrepresent one's intention in the interest of gaining property or money from Nanotrasen, or to gain or give property or money from Nanotrasen without proper authorization.", colour="bad",icon="hand-holding-usd",sentence="15"),
		list(name="Identity Theft", tooltip="To assume the identity of another individual.", colour="bad",icon="theater-masks",sentence="15"),
	)
	var/static/list/capital = list(
		list(name="Prime Murder", tooltip="To commit the act of murder, with clear intent to kill, and clear intent or to have materially take steps to prevent the revival of the victim", colour="grey",icon="skull-crossbones",sentence="[MAX_TIMER / 600]"),
		list(name="Grand Larceny", tooltip="To steal inherently dangerous items from their storage, one's person, or other such methods acquire through illicit means.", colour="grey",icon="mask",sentence="[MAX_TIMER / 600]"),
		list(name="Grand Sabotage", tooltip="To destroy or modify station assets or equipment without which the station may collapse or otherwise become uninhabitable.", colour="grey",icon="bomb",sentence="[MAX_TIMER / 600]"),
		list(name="Espionage", tooltip="To knowingly betray critical information to enemies of the station.", colour="grey",icon="user-secret",sentence="[MAX_TIMER / 600]"),
		list(name="Enemy of the Corporation", tooltip="To be a member of any of the following organizations: Hostile boarding parties, Wizards, Changeling Hiveminds, cults.", colour="grey",icon="user-alt-slash",sentence="[MAX_TIMER / 600]"),
		list(name="Possession, Corporate Secrets", tooltip="To possess secret documentation or high density tamper-resistant data storage devices (Blackboxes) from any organization without authorization by Nanotrasen.", colour="grey",icon="file-invoice",sentence="[MAX_TIMER / 600]"),
		list(name="Subversion of the Chain of Command", tooltip="Disrupting the chain of command via either murder of a commanding officer or illegaly declaring oneself to be a commanding officer.", colour="grey",icon="link",sentence="[MAX_TIMER / 600]"),
		list(name="Biological Terror", tooltip="To knowingly release, cause, or otherwise cause the station to become affected by a disease, plant, or other biological form which may spread uncontained and or cause serious physical harm.", colour="grey",icon="biohazard",sentence="[MAX_TIMER / 600]"),
	)

/obj/item/circuitboard/machine/genpop_interface
	name = "Prisoner Management Interface (circuit)"
	build_path = /obj/machinery/genpop_interface

/obj/machinery/genpop_interface/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, "<span class='notice'>You start to disconnect the monitor...</span>")
		if(I.use_tool(src, user, time_to_screwdrive, volume=50))
			deconstruct(TRUE, user) //drops one station bounced radio out of thin air, not ideal but no easily implemented solution thus far.
	return TRUE

/obj/machinery/genpop_interface/Initialize(mapload)
	. = ..()
	update_icon()

	Radio = new/obj/item/radio(src)
	Radio.listening = 0
	Radio.set_frequency(FREQ_SECURITY)

/obj/machinery/genpop_interface/update_icon()
	if(machine_stat & (NOPOWER))
		icon_state = "frame"
		return

	if(machine_stat & (BROKEN))
		set_picture("ai_bsod")
		return
	set_picture("genpop")

/obj/machinery/genpop_interface/attackby(obj/item/C, mob/user)
	if(!istype(C, /obj/item/card/id))
		. = ..()
	else
		var/obj/item/card/id/I = C
		playsound(src, 'sound/machines/ping.ogg', 20)
		desired_name = I.registered_name

/obj/machinery/genpop_interface/proc/set_picture(state)
	if(maptext)
		maptext = ""
	cut_overlays()
	add_overlay(mutable_appearance(icon, state))

/obj/machinery/genpop_interface/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/genpop_interface/ui_interact(mob/user, datum/tgui/ui)
	search_text = null
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GenPop")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/genpop_interface/ui_data(mob/user)
	var/list/data = list()
	data["allPrisoners"] = list()
	data["desired_name"] = desired_name
	data["desired_crime"] = desired_crime
	data["sentence"] = desired_sentence
	data["canPrint"] = world.time >= next_print
	data["allCrimes"] = crimes
	data["search_text"] = search_text
	var/list/L = data["allPrisoners"]
	for(var/obj/item/card/id/prisoner/ID in GLOB.prisoner_ids)
		var/list/id_info = list()
		id_info["name"] = ID.registered_name
		id_info["id"] = "\ref[ID]"
		id_info["served_time"] = ID.served_time
		id_info["sentence"] = ID.sentence
		id_info["crime"] = ID.crime
		data["allPrisoners"][++L.len] = id_info
	return data

/obj/machinery/genpop_interface/proc/print_id(mob/user)

	if(world.time < next_print)
		to_chat(user, "<span class='warning'>[src]'s ID printer is on cooldown.</span>")
		return FALSE
	investigate_log("[key_name(user)] created a prisoner ID with sentence: [desired_sentence / 60] for [desired_sentence / 60] min", INVESTIGATE_RECORDS)
	user.log_message("[key_name(user)] created a prisoner ID with sentence: [desired_sentence / 60] for [desired_sentence / 60] min", LOG_ATTACK)

	if(desired_crime)
		var/datum/data/record/R = find_record("name", desired_name, GLOB.data_core.general)
		if(R)
			R.fields["criminal"] = "Incarcerated"
			var/crime = GLOB.data_core.createCrimeEntry(desired_crime, null, user.real_name, station_time_timestamp())
			GLOB.data_core.addCrime(R.fields["id"], crime)
			investigate_log("New Crime: <strong>[desired_crime]</strong> | Added to [R.fields["name"]] by [key_name(user)]", INVESTIGATE_RECORDS)
			say("Criminal record for [R.fields["name"]] successfully updated.")
			playsound(loc, 'sound/machines/ping.ogg', 50, 1)

	var/obj/item/card/id/id = new /obj/item/card/id/prisoner(get_turf(src), desired_sentence, desired_crime, desired_name)
	Radio.talk_into(src, "Prisoner [id.registered_name] has been incarcerated for [desired_sentence / 60 ] minutes.")
	var/obj/item/paper/paperwork = new /obj/item/paper(get_turf(src))
	paperwork.add_raw_text("<h1 id='record-of-incarceration'>Record Of Incarceration:</h1> <hr> <h2 id='name'>Name: </h2> <p>[desired_name]</p> <h2 id='crime'>Crime: </h2> <p>[desired_crime]</p> <h2 id='sentence-min'>Sentence (Min)</h2> <p>[desired_sentence/60]</p> <h2 id='description'>Description </h2> <p>[desired_description]</p> <p>WhiteRapids Military Council, disciplinary authority</p>")
	paperwork.update_appearance()
	desired_sentence = 60
	desired_crime = null
	desired_name = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	next_print = world.time + 20 SECONDS




/obj/machinery/genpop_interface/ui_act(action, params)
	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("time")
			var/value = text2num(params["adjust"])
			if(value && isnum(value))
				desired_sentence += value
				desired_sentence = clamp(desired_sentence,0,MAX_TIMER)
		if("crime")
			crimes = stripped_input(usr, "Input prisoner's crimes...", "Crimes", desired_crime)
			desired_description = stripped_input(usr, "Describe infraction...", "Description")
			if(crimes == null | !Adjacent(usr))
				return FALSE
			desired_crime = crimes
		if("prisoner_name")
			var/prisoner_name = stripped_input(usr, "Input prisoner's name...", "Crimes", desired_name)
			if(prisoner_name == null | !Adjacent(usr))
				return FALSE
			desired_name = prisoner_name
		if("print")
			print_id(usr)

		if("search_text") //unused, not working
			search_text = params["text"]

		if("preset")
			var/preset = params["preset"]
			var/preset_time = 0
			switch(preset)
				if("short")
					preset_time = PRESET_SHORT
					crimes = minor
				if("medium")
					preset_time = PRESET_MEDIUM
					crimes = misdemeanours
				if("long")
					preset_time = PRESET_LONG
					crimes = major
				if("perma")
					preset_time = MAX_TIMER
					crimes = capital

			desired_sentence = preset_time
			desired_sentence /= 10
		if("presetCrime")
			var/preset_crime = params["crime"]
			var/preset_time = text2num(params["preset"])
			var/preset_description = params["tooltip"]
			desired_crime = preset_crime
			desired_sentence = preset_time MINUTES
			desired_sentence /= 10
			desired_description = preset_description
		if("modifier")
			var/modifier = params["modifier"]
			switch(modifier)
				if("resisted")
					desired_sentence *= 1.20
				if("attempted")
					if(desired_sentence <= 300)
						alert("Attempted minor crimes must be met with fines!", "Ok")
						return
					if(desired_sentence >=3600)
						desired_sentence -= 2700 //back to major crime (900)
					else
						desired_sentence -= 300
					desired_crime = "Attempted [desired_crime]"
				if("elevated")
					if(desired_sentence >= 900)
						desired_sentence = 36000
					else
						desired_sentence += 300
					desired_crime = "[desired_crime] (Repeat offender)"
		if("adjust_time")
			var/obj/item/card/id/prisoner/id = locate(params["id"])
			var/value = text2num(params["adjust"])
			if(!istype(id) || id.access == ACCESS_PRISONER) //check for prisonner access too
				return
			if(value && isnum(value))
				id.sentence += value
				id.sentence = clamp(id.sentence,0,MAX_TIMER)
		if("release")
			var/obj/item/card/id/prisoner/id = locate(params["id"])
			if(!istype(id))
				return
			if(alert("Are you sure you want to release [id.registered_name]", "Prisoner Release", "Yes", "No") != "Yes")
				return
			Radio.talk_into(src, "Prisoner [id.registered_name] has been discharged.")
			investigate_log("[key_name(usr)] has early-released [id] ([id.loc])", INVESTIGATE_RECORDS)
			usr.log_message("[key_name(usr)] has early-released [id] ([id.loc])", LOG_ATTACK)
			id.served_time = id.sentence
		if("escaped")
			var/obj/item/card/id/prisoner/id = locate(params["id"])
			if(!istype(id))
				return
			if(alert("Do you want to reset the sentence of [id.registered_name]?", "Confirmation", "Yes", "No") != "Yes")
				return
			Radio.talk_into(src, "Prisoner [id.registered_name] has had their serving time reset.")
			investigate_log("[key_name(usr)] has reset the timer of [id] ([id.loc])", INVESTIGATE_RECORDS)
			usr.log_message("[key_name(usr)] has reset the timer of [id] ([id.loc])", LOG_ATTACK)
			id.served_time = 0

GLOBAL_LIST_EMPTY(prisoner_ids)

/obj/item/card/id/prisoner //renamed existing prisonner id to id/gulag
	icon_state = "orange"
	item_state = "orange-id"
	assignment = "convict"
	var/served_time = 0 //Seconds.
	var/sentence = 0 //'ard time innit.
	var/crime = null //What you in for mate?
	var/atom/assigned_locker = null //Where's our stuff then guv?

/obj/item/card/id/prisoner/Initialize(mapload, _sentence, _crime, _name)
	. = ..()
	LAZYADD(GLOB.prisoner_ids, src)
	if(_crime)
		crime = _crime
	if(_sentence)
		sentence = _sentence
		if(!_name)
			registered_name = "Prisoner WR-ROSETTA#[rand(0, 10000)]"
		else
			registered_name = _name
		update_label(registered_name, "Convict")
		START_PROCESSING(SSobj, src)

/obj/item/card/id/prisoner/Destroy()
	GLOB.prisoner_ids -= src
	. = ..()

/obj/item/card/id/prisoner/examine(mob/user)
	. = ..()
	if(sentence)
		. += "<span class='notice'>You have served [served_time / 60] / [sentence  / 60] minutes.</span>"
	if(crime)
		. += "<span class='warning'>It appears its holder was convicted of: <b>[crime]</b></span>"

/obj/item/card/id/prisoner/process()
	served_time ++ //Maybe 2?
	if(served_time >= sentence) //FREEDOM!
		assignment = "Ex-Convict"
		access = list(ACCESS_PRISONER)
		update_label(registered_name, assignment)
		playsound(loc, 'sound/machines/ping.ogg', 50, 1)

		var/datum/data/record/R = find_record("name", registered_name, GLOB.data_core.general)
		if(R)
			R.fields["criminal"] = "Discharged"

		if(isliving(loc))
			to_chat(loc, "<span class='boldnotice'>You have served your sentence! You may now exit prison through the turnstiles and collect your belongings.</span>")
		return PROCESS_KILL



#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG

#undef MAX_TIMER
