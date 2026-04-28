/datum/action/spell/forcewall
	name = "Forcewall"
	desc = "Create a magical barrier that only you can pass through."
	button_icon_state = "shield"

	sound = 'sound/magic/forcewall.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 1.25 SECONDS

	invocation = "TARCOL MINTI ZHERI"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	/// The typepath to the wall we create on cast.
	var/wall_type = /obj/effect/forcefield/wizard

/datum/action/spell/forcewall/on_cast(mob/user, atom/target)
	. = ..()
	new wall_type(get_turf(owner), owner)

	if(owner.dir == SOUTH || owner.dir == NORTH)
		new wall_type(get_step(owner, EAST), owner, antimagic_flags)
		new wall_type(get_step(owner, WEST), owner, antimagic_flags)

	else
		new wall_type(get_step(owner, NORTH), owner, antimagic_flags)
		new wall_type(get_step(owner, SOUTH), owner, antimagic_flags)

/datum/action/spell/forcewall/cult
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire."
	background_icon_state = "bg_demon"
	button_icon = 'icons/hud/actions/actions_cult.dmi'
	button_icon_state = "cultforcewall"

	cooldown_time = 40 SECONDS
	invocation_type = INVOCATION_NONE

	wall_type = /obj/effect/forcefield/cult

/datum/action/spell/forcewall/mime
	name = "Invisible Blockade"
	desc = "Form an invisible three tile wide blockade."
	background_icon_state = "bg_mime"
	button_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "invisible_blockade"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	sound = null

	school = SCHOOL_MIME
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 0 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE

	invocation = ""
	invocation_type = INVOCATION_EMOTE
	invocation_self_message = ("<span class='notice'>You form a blockade in front of yourself.</span>")
	spell_max_level = 1

	wall_type = /obj/effect/forcefield/mime/advanced

/datum/action/spell/forcewall/mime/pre_cast(mob/user, atom/target)
	. = ..()
	invocation = ("<span class='notice'><b>[user]</b> looks as if a blockade is in front of [user.p_them()].</span>")
