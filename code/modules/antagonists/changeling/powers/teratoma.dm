#define MAX_TERATOMA 2

/datum/action/changeling/teratoma
	name = "Birth Teratoma"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem"
	helptext = "The tumor will not be loyal to us or our cause. Costs two changeling absorptions"
	button_icon_state = "spread_infestation"
	chemical_cost = 60
	dna_cost = 2
	req_human = TRUE

//Reskinned monkey - teratoma, will burst out of the host, with the objective to cause chaos.
/datum/action/changeling/teratoma/sting_action(mob/user)
	..()
	if(create_teratoma(user))
		var/mob/living/U = user
		playsound(user.loc, 'sound/effects/blobattack.ogg', 50, 1)
		U.spawn_gibs()
		user.visible_message("<span class='danger'>Something horrible bursts out of [user]'s chest!</span>", \
								"<span class='danger'>Living teratoma bursts out of your chest!</span>", \
								"<span class='hear'>You hear flesh tearing!</span>", COMBAT_MESSAGE_RANGE)
	return FALSE		//create_teratoma() handles the chemicals anyway so there is no reason to take them again

/datum/action/changeling/teratoma/proc/create_teratoma(mob/living/carbon/human/user)
	if (!istype(user))
		return FALSE
	if (!user.dna)
		to_chat(user, "<span class='warning'>Our current form has insufficient genetic material to create a Teratoma.</span>")
		return FALSE
	var/terratoma_count = 0
	for (var/mob/living/carbon/monkey/tumor/teratoma in GLOB.mob_living_list)
		if (teratoma.creator_key != user.key || teratoma.stat == DEAD)
			continue
		terratoma_count ++
	if (terratoma_count >= MAX_TERATOMA)
		to_chat(user, "<span class='warning'>You don't have enough energy to birth a teratoma...</span>")
		return FALSE
	var/datum/antagonist/changeling/c = user.mind.has_antag_datum(/datum/antagonist/changeling)
	c.chem_charges -= chemical_cost				//I'm taking your chemicals hostage!
	var/turf/A = get_turf(user)
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as a living teratoma?", ROLE_TERATOMA, null, 7.5 SECONDS) //players must answer rapidly
	if(!LAZYLEN(candidates)) //if we got at least one candidate, they're teratoma now
		to_chat(usr, "<span class='warning'>You fail at creating a tumor. Perhaps you should try again later?</span>")
		c.chem_charges += chemical_cost				//If it fails we want to refund the chemicals
		return FALSE
	// Rerun preconditions after sleeping
	if (!user.dna)
		to_chat(user, "<span class='warning'>Our current form has insufficient genetic material to create a Teratoma.</span>")
		return FALSE
	if (!user.key)
		return FALSE
	terratoma_count = 0
	for (var/mob/living/carbon/monkey/tumor/teratoma in GLOB.mob_living_list)
		if (teratoma.creator_key != user.key || teratoma.stat == DEAD)
			continue
		terratoma_count ++
	if (terratoma_count >= MAX_TERATOMA)
		to_chat(user, "<span class='warning'>You don't have enough energy to birth a teratoma...</span>")
		return FALSE
	var/mob/living/carbon/monkey/tumor/T = new /mob/living/carbon/monkey/tumor(A)
	// Copies the DNA, so that you can find who caused it while causing some chaos
	T.dna.copy_dna(user.dna)
	T.creator_key = user.key
	var/mob/dead/observer/C = pick(candidates)
	T.key = C.key
	var/datum/antagonist/teratoma/D = new
	T.mind.add_antag_datum(D)
	to_chat(T, "<span class='notice'>You burst out from [user]'s chest!</span>")
	SEND_SOUND(T, sound('sound/effects/blobattack.ogg'))
	return TRUE

#undef MAX_TERATOMA
