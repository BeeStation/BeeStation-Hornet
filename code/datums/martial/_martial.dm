/datum/martial_art
	var/name = "Martial Art"
	var/id = "" //ID, used by mind/has_martialart
	var/streak = ""
	var/max_streak_length = 6
	var/current_target
	var/datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts
	var/smashes_tables = FALSE //If the martial art smashes tables when performing table slams and head smashes
	var/datum/weakref/holder //owner of the martial art
	var/display_combos = FALSE //shows combo meter if true
	var/combo_timer = 6 SECONDS // period of time after which the combo streak is reset.
	var/timerid
	/// If set to true this style allows you to punch people despite being a pacifist (for instance Boxing, which does no damage)
	var/pacifist_style = FALSE
	var/bypass_blocking = TRUE //Is this martial art specifically allowed to bypass shields and blades?

	/// Weakref to button to access martial guide
	var/datum/weakref/info_button_ref

	//Moves that are specific to each martial art, and passed into the martial art action button
	var/Move1 = null
	var/Move2 = null
	var/Move3 = null
	var/Move4 = null
	var/Move5 = null
	var/AdditionText = null

/datum/martial_art/proc/help_act(mob/living/A, mob/living/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/disarm_act(mob/living/A, mob/living/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/harm_act(mob/living/A, mob/living/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/grab_act(mob/living/A, mob/living/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/can_use(mob/living/L)
	return TRUE

/datum/martial_art/proc/add_to_streak(element, mob/living/D)
	if(D != current_target)
		reset_streak(D)
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak, 1 + length(streak[1]))
	if (display_combos)
		var/mob/living/holder_living = holder.resolve()
		timerid = addtimer(CALLBACK(src, PROC_REF(reset_streak), null, FALSE), combo_timer, TIMER_UNIQUE | TIMER_STOPPABLE)
		holder_living?.hud_used?.combo_display.update_icon_state(streak, combo_timer - 2 SECONDS)

/datum/martial_art/proc/reset_streak(mob/living/new_target, update_icon = TRUE)
	if(timerid)
		deltimer(timerid)
	current_target = new_target
	streak = ""
	if(update_icon)
		var/mob/living/holder_living = holder?.resolve()
		holder_living?.hud_used?.combo_display.update_icon_state(streak)

/datum/martial_art/proc/teach(mob/living/holder_living, make_temporary=FALSE)
	if(!istype(holder_living) || !holder_living.mind)
		return FALSE
	if(holder_living.mind.martial_art)
		if(make_temporary)
			if(!holder_living.mind.martial_art.allow_temp_override)
				return FALSE
			store(holder_living.mind.martial_art, holder_living)
		else
			holder_living.mind.martial_art.on_remove(holder_living)
	else if(make_temporary)
		base = holder_living.mind.default_martial_art
	holder_living.mind.martial_art = src
	holder = WEAKREF(holder_living)
	//Skip info button stuff if we dont have moves
	if(!display_combos)
		return TRUE
	var/datum/action/martial_info/info_button = make_info_button()
	if(info_button)
		to_chat(holder, span_boldnotice("For more info, read the martial panel. \
			You can always come back to it using the button in the top left."))
		info_button?.trigger()
	return TRUE

/datum/martial_art/proc/make_info_button()
	var/datum/action/martial_info/info_button = new(src)
	var/mob/living/carbon/holder_living = holder.resolve()
	info_button.Grant(holder_living)
	info_button_ref = WEAKREF(info_button)
	return info_button

/datum/martial_art/proc/store(datum/martial_art/old, mob/living/holder_living)
	old.on_remove(holder_living)
	if (old.base) //Checks if old is temporary, if so it will not be stored.
		base = old.base
	else //Otherwise, old is stored.
		base = old

/datum/martial_art/proc/remove(mob/living/holder_living)
	if(!istype(holder_living) || !holder_living.mind || holder_living.mind.martial_art != src)
		return
	on_remove(holder_living)
	if(base)
		base.teach(holder_living)
	else
		var/datum/martial_art/default = holder_living.mind.default_martial_art
		default.teach(holder_living)
	holder = null

/datum/martial_art/proc/on_remove(mob/living/holder_living)
	if(info_button_ref)
		var/datum/action/martial_info/info_button = info_button_ref.resolve()
		info_button.Remove(holder_living)
		QDEL_NULL(info_button_ref)

///Gets called when a projectile hits the owner. Returning anything other than BULLET_ACT_HIT will stop the projectile from hitting the mob.
/datum/martial_art/proc/on_projectile_hit(mob/living/A, obj/projectile/P, def_zone)
	return BULLET_ACT_HIT

//button to review martial arts
/datum/action/martial_info
	name = "Open Martial Art Guide:"
	button_icon_state = "round_end"

/*
/datum/action/martial_info/New(master)
	. = ..()
	var/datum/martial_art/martial_art = owner.mind.martial_art
	name = "Open [martial_art.name] Guide:"
*/

/datum/action/martial_info/on_activate(mob/user, atom/target)
	ui_interact(owner)

/datum/action/martial_info/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(!owner.mind || !owner.mind.martial_art)
		return FALSE
	return TRUE

/datum/action/martial_info/ui_state()
	return GLOB.always_state

/datum/action/martial_info/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MartialInfo", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/action/martial_info/ui_data(mob/user)
	var/list/data = list()
	var/datum/martial_art/martial_art = owner.mind.martial_art
	data["name"] = martial_art.name
	data["Move1"] = martial_art.Move1
	data["Move2"] = martial_art.Move2
	data["Move3"] = martial_art.Move3
	data["Move4"] = martial_art.Move4
	data["Move5"] = martial_art.Move5
	data["AdditionText"] = martial_art.AdditionText
	return data
