/datum/antagonist/clownloose
	name = "Loose Clown"
	roundend_category = "Prisoner"
	banning_key = ROLE_CLOWNLOOSE
	show_in_antagpanel = TRUE
	antagpanel_category = "Loose Clown"
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE

/datum/antagonist/clownloose/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_clownloose_icons_added(M)

/datum/antagonist/clownloose/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_clownloose_icons_removed(M)

/datum/objective/clowncaphat
	name = "Keep the Centcom hat."
	explanation_text = "Have the stolen  centcom hat on you by the end of the shift. HONK!"


/datum/objective/clowncaphat/check_completion()
	return ..() || owner?.current?.check_contents_for(/obj/item/clothing/head/hats/centhat/stolen)

/datum/antagonist/clownloose/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/clownloose/proc/forge_objectives()
	var/datum/objective/escape/escape = new()
	escape.owner = owner
	objectives += escape
	var/datum/objective/clowncaphat/objective2 = new()
	objective2.owner = owner
	objectives += objective2

/datum/antagonist/clownloose/greet()
	to_chat(owner, "<span class='big bold'>You are the Loose Clown!</span>")
	to_chat(owner, "<span class='boldannounce'>You were a clown imprisoned in CentCom, but managed to slip an officer and escaped on a drop pod to another station before getting caught!\
								 You are wanted for stealing the a captain hat from a high ranked Centcom official, and security in this new station you dropped on will try to catch you.\
								 Escape in the shuttle or an escape pod without getting caught while having the hat. Do not kill anyone. You have more than enough gear to prank everyone and escape being a free clown.</span>")
	owner.announce_objectives()

/datum/antagonist/clownloose/proc/update_clownloose_icons_added(var/mob/living/carbon/human/clownloose)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_CLOWNLOOSE]
	prihud.join_hud(clownloose)
	set_antag_hud(clownloose, "loose clown")

/datum/antagonist/clownloose/proc/update_clownloose_icons_removed(var/mob/living/carbon/human/clownloose)
	var/datum/atom_hud/antag/prihud = GLOB.huds[ANTAG_HUD_CLOWNLOOSE]
	prihud.leave_hud(clownloose)
	set_antag_hud(clownloose, null)
