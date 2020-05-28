//Experimental cloner; clones a body regardless of the owner's status, letting a ghost control it instead

/obj/machinery/clonepod/traitorous
	name = "experimental cloning pod traitorous"
	desc = "An ancient cloning pod. It seems to be an early prototype of the experimental cloners used in Nanotrasen Stations."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = null
	circuit = /obj/item/circuitboard/machine/clonepod/traitorous
	internal_radio = FALSE
	var/emmaged = FALSE

//Start growing a human clone in the pod!
/obj/machinery/clonepod/traitorous/growclone(clonename, ui, mutation_index, mindref, last_death, datum/species/mrace, list/features, factions, list/quirks, datum/bank_account/insurance)
	if(panel_open)
		return NONE
	if(mess || attempting)
		return NONE

	attempting = TRUE //One at a time!!
	countdown.start()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

	/*var/expl_text stripped_input(admin, "(Firstidk?)Custom objective:", "ObjectiveSecond", explanation_text)
	var/datum/objective/custom/O
		name = "custom"
		explanation_text = expl_text

	*/

	H.hardset_dna(ui, mutation_index, H.real_name, null, mrace, features)

	if(efficiency > 2)
		var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations)
		H.dna.remove_mutation_group(unclean_mutations)
	if(efficiency > 5 && prob(20))
		H.easy_randmut(POSITIVE)
	if(efficiency < 3 && prob(50))
		var/mob/M = H.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
		if(ismob(M))
			H = M

	H.silent = 20 //Prevents an extreme edge case where clones could speak if they said something at exactly the right moment.
	occupant = H

	if(!clonename)	//to prevent null names
		clonename = "clone ([rand(1,999)])"
	H.real_name = clonename

	icon_state = "pod_1"
	//Get the clone body ready
	maim_clone(H)
	ADD_TRAIT(H, TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_STABLELIVER, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_MUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOBREATH, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	H.Unconscious(80)

	var/list/candidates = pollCandidatesForMob("Do you want to play as [clonename]'s defective clone?", null, null, null, 100, H, POLL_IGNORE_DEFECTIVECLONE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		H.key = C.key

	if(grab_ghost_when == CLONER_FRESH_CLONE)
		H.grab_ghost()
		to_chat(H, "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>")

	if(grab_ghost_when == CLONER_MATURE_CLONE)
		H.ghostize(TRUE)	//Only does anything if they were still in their old body and not already a ghost
		to_chat(H.get_ghost(TRUE), "<span class='notice'>Your body is beginning to regenerate in a cloning pod. You will become conscious when it is complete.</span>")

	if(H)
		H.faction |= factions

		H.set_cloned_appearance()

		H.set_suicide(FALSE)
	attempting = FALSE


	if(!GLOB.admin_objective_list)
		generate_admin_objective_list()

	if(!isnull(H.mind)) // If we don't have mind, don't set any objectives to it, or it will break the cloner with an infinite loop of exceptions.
		var/datum/objective/O = new /datum/objective/custom
		O.team = src
		O.explanation_text = "Impersonate [clonename]."
		O.owner = H

		var/datum/antagonist/team_antag
		if(!team_antag)
			team_antag = new /datum/antagonist/custom
		team_antag.name = "Defective Clone"
		H.mind.add_antag_datum(team_antag, src)
		team_antag.objectives |= O

		if(emmaged)
			var/expl_text = stripped_input(usr, "Enter additional objective", "Objective:", "Free objective.")
			if(expl_text)
				var/datum/objective/SecO = new /datum/objective/custom
				SecO.team = src
				SecO.explanation_text = expl_text
				SecO.owner = H
				team_antag.objectives |= SecO

		H.mind.announce_objectives()

	return CLONING_DELETE_RECORD | CLONING_SUCCESS //so that we don't spam clones with autoprocess unless we leave a body in the scanner

/obj/machinery/clonepod/traitorous/go_out()
	var/mob/living/mob_occupant = occupant
	mob_occupant.mind.announce_objectives()
	..()

/obj/machinery/clonepod/traitorous/proc/make_emmaged()
	emmaged = TRUE

/obj/machinery/clonepod/traitorous/proc/is_emmaged()
	return emmaged

//Prototype cloning console, much more rudimental and lacks modern functions such as saving records, autocloning, or safety checks.
/obj/machinery/computer/prototype_cloning_traitorous
	name = "prototype cloning console traitorous"
	desc = "Used to operate an experimental cloner."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/prototype_cloning_traitorous
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/list/pods //Linked experimental cloning pods
	var/temp = "Inactive"
	var/scantemp = "Ready to Scan"
	var/loading = FALSE // Nice loading text
	var/is_emmaged = FALSE

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/prototype_cloning_traitorous/Initialize()
	. = ..()
	updatemodules(TRUE)

/obj/machinery/computer/prototype_cloning_traitorous/Destroy()
	if(pods)
		for(var/P in pods)
			DetachCloner(P)
		pods = null
	return ..()

/obj/machinery/computer/prototype_cloning_traitorous/proc/GetAvailablePod(mind = null)
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/traitorous/pod = P
			if(pod.is_operational() && !(pod.occupant || pod.mess))
				return pod

/obj/machinery/computer/prototype_cloning_traitorous/proc/updatemodules(findfirstcloner)
	scanner = findscanner()
	if(findfirstcloner && !LAZYLEN(pods))
		findcloner()

/obj/machinery/computer/prototype_cloning_traitorous/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(var/direction in GLOB.cardinals)
		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, direction))
		// If found and operational, return the scanner
		if (!isnull(scannerf) && scannerf.is_operational())
			return scannerf

	// If no scanner was found, it will return null
	return null

/obj/machinery/computer/prototype_cloning_traitorous/proc/findcloner()
	var/obj/machinery/clonepod/traitorous/podf = null
	for(var/direction in GLOB.cardinals)
		podf = locate(/obj/machinery/clonepod/traitorous, get_step(src, direction))
		if (!isnull(podf) && podf.is_operational())
			AttachCloner(podf)

/obj/machinery/computer/prototype_cloning_traitorous/proc/AttachCloner(obj/machinery/clonepod/traitorous/pod)
	if(!pod.connected)
		pod.connected = src
		LAZYADD(pods, pod)

/obj/machinery/computer/prototype_cloning_traitorous/proc/DetachCloner(obj/machinery/clonepod/traitorous/pod)
	pod.connected = null
	LAZYREMOVE(pods, pod)

/obj/machinery/computer/prototype_cloning_traitorous/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/P = W

		if(istype(P.buffer, /obj/machinery/clonepod/traitorous))
			if(get_area(P.buffer) != get_area(src))
				to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
				P.buffer = null
				return
			to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
			var/obj/machinery/clonepod/traitorous/pod = P.buffer
			if(pod.connected)
				pod.connected.DetachCloner(pod)
			AttachCloner(pod)
		else
			P.buffer = src
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(P.buffer)] [P.buffer.name] in buffer %-</font color>")
		return
	else
		return ..()

/obj/machinery/computer/prototype_cloning_traitorous/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/prototype_cloning_traitorous/interact(mob/user)
	user.set_machine(src)
	add_fingerprint(user)

	if(..())
		return

	updatemodules(TRUE)

	var/dat = ""
	dat += "<a href='byond://?src=[REF(src)];refresh=1'>Refresh</a>"

	dat += "<h3>Cloning Pod Status</h3>"
	dat += "<div class='statusDisplay'>[temp]&nbsp;</div>"

	if (isnull(src.scanner) || !LAZYLEN(pods))
		dat += "<h3>Modules</h3>"
		//dat += "<a href='byond://?src=[REF(src)];relmodules=1'>Reload Modules</a>"
		if (isnull(src.scanner))
			dat += "<font class='bad'>ERROR: No Scanner detected!</font><br>"
		if (!LAZYLEN(pods))
			dat += "<font class='bad'>ERROR: No Pod detected</font><br>"

	// Scan-n-Clone
	if (!isnull(src.scanner))
		var/mob/living/scanner_occupant = get_mob_or_brainmob(scanner.occupant)

		dat += "<h3>Cloning</h3>"

		dat += "<div class='statusDisplay'>"
		if(!scanner_occupant)
			dat += "Scanner Unoccupied"
		else if(loading)
			dat += "[scanner_occupant] => Scanning..."
		else
			scantemp = "Ready to Clone"
			dat += "[scanner_occupant] => [scantemp]"
		dat += "</div>"

		if(scanner_occupant)
			dat += "<a href='byond://?src=[REF(src)];clone=1'>Clone</a>"
			dat += "<br><a href='byond://?src=[REF(src)];lock=1'>[src.scanner.locked ? "Unlock Scanner" : "Lock Scanner"]</a>"
		else
			dat += "<span class='linkOff'>Clone</span>"

	var/datum/browser/popup = new(user, "cloning", "Prototype Cloning System Control")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/prototype_cloning_traitorous/Topic(href, href_list)
	if(..())
		return

	if(loading)
		return

	else if ((href_list["clone"]) && !isnull(scanner) && scanner.is_operational())
		scantemp = ""

		loading = TRUE
		updateUsrDialog()
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		say("Initiating scan...")

		spawn(20)
			clone_occupant(scanner.occupant)
			loading = FALSE
			updateUsrDialog()
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

		//No locking an open scanner.
	else if ((href_list["lock"]) && !isnull(scanner) && scanner.is_operational())
		if ((!scanner.locked) && (scanner.occupant))
			scanner.locked = TRUE
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else
			scanner.locked = FALSE
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

	else if (href_list["refresh"])
		updateUsrDialog()
		playsound(src, "terminal_type", 25, 0)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/prototype_cloning_traitorous/proc/clone_occupant(occupant)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	if(ishuman(mob_occupant))
		var/mob/living/carbon/C = mob_occupant
		dna = C.has_dna()
	if(isbrain(mob_occupant))
		var/mob/living/brain/B = mob_occupant
		dna = B.stored_dna

	if(!istype(dna))
		scantemp = "<font class='bad'>Unable to locate valid genetic data.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if((HAS_TRAIT(mob_occupant, TRAIT_HUSK)) && (src.scanner.scan_level < 2))
		scantemp = "<font class='bad'>Subject's body is too damaged to scan properly.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return
	if(HAS_TRAIT(mob_occupant, TRAIT_BADDNA))
		scantemp = "<font class='bad'>Subject's DNA is damaged beyond any hope of recovery.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return

	var/clone_species
	if(dna.species)
		clone_species = dna.species
	else
		var/datum/species/rando_race = pick(GLOB.roundstart_races)
		clone_species = rando_race.type

	var/obj/machinery/clonepod/pod = GetAvailablePod()
	//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
	if(!LAZYLEN(pods))
		temp = "<font class='bad'>No Clonepods detected.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(!pod)
		temp = "<font class='bad'>No Clonepods available.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(pod.occupant)
		temp = "<font class='bad'>Cloning cycle already in progress.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else
		pod.growclone(mob_occupant.real_name, dna.uni_identity, dna.mutation_index, null, null, clone_species, dna.features, mob_occupant.faction)
		temp = "[mob_occupant.real_name] => <font class='good'>Cloning data sent to pod.</font>"
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

/obj/machinery/computer/prototype_cloning_traitorous/emag_act(emag_user)
	var/obj/machinery/clonepod/traitorous/P = GetAvailablePod()
	if(!is_emmaged || !P.is_emmaged())
		to_chat(usr, "<span class='notice'>You rewire some circutery.</span>")
		is_emmaged = TRUE
		P.make_emmaged()
