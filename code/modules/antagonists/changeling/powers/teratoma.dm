/datum/action/changeling/teratoma
	name = "Birth Teratoma"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem"
	helptext = "The tumor will not be loyal to us or our cause. Costs two changeling absorptions"
	button_icon_state = "spread_infestation"
	chemical_cost = 1
	dna_cost = 2
	req_absorbs = 0 //if I forget to change it back to 3 yell at me

//Makes a single egg, which hatches into a reskinned monkey with an objective to cause chaos after some time.
/datum/action/changeling/teratoma/sting_action(mob/user)
	..()
	if(create_teratoma(user))
		var/mob/living/U = user
		playsound(user.loc, 'sound/effects/blobattack.ogg', 50, 1)
		U.spawn_gibs()
		user.visible_message("<span class='danger'>Something horrible bursts out of [user]'s chest!</span>", \
								"<span class='danger'>Living teratoma bursts out of your chest!</span>", \
								"<span class='hear'>You hear flesh tearing!</span>", COMBAT_MESSAGE_RANGE)
		return
	return TRUE		//so it doesn't consume chemicals

/datum/action/changeling/teratoma/proc/create_teratoma(mob/user)
	var/turf/A = get_turf(user)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as a living teratoma?", ROLE_TERATOMA, null, ROLE_TERATOMA, 5 SECONDS) //players must answer rapidly
	if(!LAZYLEN(candidates)) //if we got at least one candidate, they're teratoma now
		to_chat(usr, "<span class='warning'>You fail at creating a tumor. Perhaps you should try again later?</span>")
		return FALSE
	var/mob/living/carbon/monkey/tumor/T = new /mob/living/carbon/monkey/tumor(A)
	var/mob/dead/observer/C = pick(candidates)
	T.key = C.key
	var/datum/antagonist/teratoma/D = new
	T.mind.add_antag_datum(D)
	to_chat(T, "<span='notice'>You burst out from [user]'s chest!</span>")
	SEND_SOUND(T, sound('sound/effects/blobattack.ogg'))
	return TRUE
