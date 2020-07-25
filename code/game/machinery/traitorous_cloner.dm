//Experimental cloner; clones a body regardless of the owner's status, letting a ghost control it instead

/obj/machinery/clonepod/experimental/traitorous
	name = "cloning pod"
	desc = "An ancient cloning pod. It seems to be an early prototype of the experimental cloners used in Nanotrasen Stations."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = null
	circuit = /obj/item/circuitboard/machine/clonepod/experimental/traitorous
	internal_radio = FALSE
	var/emmaged = FALSE

//Start growing a human clone in the pod!
/obj/machinery/clonepod/experimental/traitorous/growclone(clonename, ui, mutation_index, mindref, last_death, datum/species/mrace, list/features, factions, list/quirks, datum/bank_account/insurance)
	if(panel_open)
		return NONE
	if(mess || attempting)
		return NONE

	attempting = TRUE //One at a time!!
	countdown.start()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

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
		var/datum/antagonist/antag
		if(!antag)
			antag = new /datum/antagonist/custom

		var/datum/objective/O = new /datum/objective/custom
		O.team = team
		O.explanation_text = "Impersonate [clonename]. There can only be one."
		//O.owner = H.mind

		antag.name = "Defective Clone"
		antag.objectives |= O

		if(emmaged)
			var/expl_text = stripped_input(usr, "Enter additional objective", "Objective:", "Free objective.")
			if(expl_text)
				var/datum/objective/SecO = new /datum/objective/custom
				SecO.team = team
				SecO.explanation_text = expl_text
				//SecO.owner = H.mind
				antag.objectives |= SecO

		H.mind.add_antag_datum(antag, team)
		H.mind.announce_objectives()

	return CLONING_DELETE_RECORD | CLONING_SUCCESS //so that we don't spam clones with autoprocess unless we leave a body in the scanner

/obj/machinery/clonepod/experimental/traitorous/go_out()
	var/mob/living/mob_occupant = occupant
	if(!isnull(mob_occupant) && !isnull(mob_occupant.mind))
		mob_occupant.mind.announce_objectives()
	..()

/obj/machinery/clonepod/experimental/traitorous/proc/make_emmaged()
	emmaged = TRUE

/obj/machinery/clonepod/experimental/traitorous/proc/is_emmaged()
	return emmaged

//Prototype cloning console, much more rudimental and lacks modern functions such as saving records, autocloning, or safety checks.
/obj/machinery/computer/prototype_cloning/traitorous
	name = "cloning console"
	desc = "Used to operate an experimental cloner."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/prototype_cloning/traitorous
	var/is_emmaged = FALSE

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/prototype_cloning/GetAvailablePod(mind = null)
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/experimental/traitorous/pod = P
			if(pod.is_operational() && !(pod.occupant || pod.mess))
				return pod

/obj/machinery/computer/prototype_cloning/traitorous/emag_act(emag_user)
	var/obj/machinery/clonepod/experimental/traitorous/P = GetAvailablePod()
	if(!is_emmaged || !isnull(P) && !P.is_emmaged())
		to_chat(usr, "<span class='notice'>You rewire some circutery.</span>")
		is_emmaged = TRUE
		P.make_emmaged()
