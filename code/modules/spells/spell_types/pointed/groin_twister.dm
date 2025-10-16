/datum/action/spell/pointed/groin_twister //https://www.youtube.com/results?search_query=twist+his+dick
	name = "Groin twister"
	desc = "Incapacitate MALES for a while, leave them crippled until they get a surgery. \
		Can't be used on dionae or plasmamen."
	background_icon_state = "bg_mime"
	icon_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "finger_guns0"
	check_flags = AB_CHECK_CONSCIOUS
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "BOL'Z TUISTAZ!"
	invocation_type = INVOCATION_SHOUT

/datum/action/spell/pointed/groin_twister/is_valid_spell(mob/user, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if (target == user)
		return FALSE
	if(!ishuman(target))
		return FALSE

/datum/action/spell/pointed/groin_twister/on_cast(mob/living/user, atom/target)
	. = ..()
	if(target.gender != MALE)
		to_chat(target, ("<span class='notice'>This is a good day to be female.</span>"))
		to_chat(user, ("<span class='warning'>There is nothing to twist there!</span>"))
	else
		to_chat(target, ("<span class='warning'>Your groin gets twisted!</span>"))
		to_chat(user, ("<span class='warning'>You twist [target]'s groin!</span>"))
		twist_groin(user,target)
	return

/datum/action/spell/pointed/groin_twister/proc/twist_groin(mob/living/caster, mob/living/cast_on)
	add_traits(list(TRAIT_WHISPER_ONLY,TRAIT_CRYING, TRAIT_TWISTED_GROIN,TRAIT_IMMOBILIZED))
	var/obj/item/bodypart/LL = cast_on.get_bodypart(BODY_ZONE_L_LEG)
	if(LL)
		LL.receive_damage(30)
	var/obj/item/bodypart/RL = cast_on.get_bodypart(BODY_ZONE_R_LEG)
	if(RL)
		RL.receive_damage(30)
