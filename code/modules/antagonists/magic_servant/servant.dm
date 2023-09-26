/datum/antagonist/magic_servant
	name = "Magic Servant"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	banning_key = ROLE_WIZARD

/datum/antagonist/magic_servant/proc/setup_master(mob/M)
	var/datum/objective/O = new("Serve [M.real_name].")
	O.owner = owner
	objectives |= O
