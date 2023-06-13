/datum/config_entry/string/policy_postclonetext
	config_entry_value = "<span class='boldannounce'>You have forgotten all the knowledge you gained while being a ghost aswell as the five minutes leading up to your death!</span>"

/datum/config_entry/string/policy_polymorph
	config_entry_value = "<span class='boldannounce'>Even if you take the form of an antagonistic being, you have the same mind as before your transformation. Your loyalties and interests remain the same. Unless you were turned into a shade, or were previously an antagonist, this is not a pass to go antagonize the station.</span>"

/datum/config_entry/string/non_antag_mind
	config_entry_value = "<span class='boldannounce'>You're playing a character that is known as an antagonist, but your mind IS NOT antagonist. Please avoid antagonism.</span>"

/// announces the policy as long as their mind is not antag
/proc/announce_non_antag_mind_policy(mob/living/target_user)
	var/datum/mind/mind = target_user.mind
	if(!mind.has_antag_datum(/datum/antagonist, TRUE))
		var/non_antag_mind_msg = CONFIG_GET(string/non_antag_mind)
		if(non_antag_mind_msg)
			to_chat(target_user, non_antag_mind_msg)
