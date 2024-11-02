/datum/nanite_program
	var/name = "Generic Nanite Program"
	var/desc = "Warn a coder if you can read this."

	var/datum/component/nanites/nanites
	var/mob/living/host_mob

	///Amount of nanites used while active
	var/use_rate = 0
	///If there can be more than one copy in the same nanites
	var/unique = TRUE
	///If the nanites have a trigger function (used for the programming UI)
	var/can_trigger = FALSE
	///Amount of nanites required to trigger
	var/trigger_cost = 0
	///Deciseconds required between each trigger activation
	var/trigger_cooldown = 50
	/// Maximum duration that this program can be active for before turning off
	/// If set to null, there will be no maximum duration
	var/maximum_duration = null

	///World time required for the next trigger activation
	var/next_trigger = 0
	/// Time that the nanite program will be automatically disabled
	var/disable_time = null

	var/program_flags = NONE
	var/passive_enabled = FALSE //If the nanites have an on/off-style effect, it's tracked by this var

	var/list/rogue_types = list(/datum/nanite_program/glitch) //What this can turn into if it glitches.
	//As a rule of thumb, these should be:
	//A: simpler
	//B: negative
	//C: affecting the same parts of the body, roughly
	//B is mostly a consequence of A: it's always going to be simpler to cause damage than to repair it, so a software bug will not randomly make the flesh eating
	//nanites learn how to repair cells.
	//Given enough glitch-swapping you'll end up with stuff like necrotic or toxic nanites, which are very simple as they just try to eat what's in front of them
	//or just lie around polluting the blood


	//The following vars are customizable
	var/activated = TRUE 			//If FALSE, the program won't process, disables passive effects, can't trigger and doesn't consume nanites

	/// When deactivated, the program will wait X deciseconds before self-reactivating. Also works if the program begins deactivated.
	/// If the nanites are a trigger nanite, then it will trigger instead of activating.
	var/timer_restart = 0
	var/timer_shutdown = 0 			//When activated, the program will wait X deciseconds before self-deactivating. Also works if the program begins activated.
	var/timer_trigger_delay = 0				//[Trigger only] While active, the program will delay trigger signals by X deciseconds.

	//Indicates the next world.time tick where these timers will act
	/// When should the program re-activate itself automatically.
	var/timer_restart_next = 0
	var/timer_shutdown_next = 0
	var/timer_trigger_delay_next = 0

	//Signal codes, these handle remote input to the nanites. If set to 0 they'll ignore signals.
	var/activation_code 	= 0 	//Code that activates the program [1-9999]
	var/deactivation_code 	= 0 	//Code that deactivates the program [1-9999]
	var/kill_code 			= 0		//Code that permanently removes the program [1-9999]
	var/trigger_code 		= 0 	//Code that triggers the program (if available) [1-9999]

	//Extra settings
	///Don't ever override this or I will come to your house and stand menacingly behind a bush
	var/list/extra_settings = list()

	//Rules
	//Rules that automatically manage if the program's active without requiring separate sensor programs
	var/list/datum/nanite_rule/rules = list()

	//Logic
	//a list of logic types a nanite program's rules follow
	var/static/list/logic = list(
		"AND" = NL_AND,
		"OR" = NL_OR,
		"NOR" = NL_NOR,
		"NAND" = NL_NAND,
	)

/datum/nanite_program/New()
	. = ..()
	register_extra_settings()
	// Anything with a maximum duration must be an active ability
	if (maximum_duration)
		can_trigger = TRUE

/datum/nanite_program/Destroy()
	extra_settings = null
	if(host_mob)
		if(activated)
			deactivate()
		if(passive_enabled)
			disable_passive_effect()
		on_mob_remove()
	if(nanites)
		nanites.programs -= src
	for(var/datum/nanite_rule/rule as anything in rules)
		rule.remove()
	rules.Cut()
	return ..()

/datum/nanite_program/proc/copy()
	var/datum/nanite_program/new_program = new type()
	copy_programming(new_program, TRUE)

	return new_program

/datum/nanite_program/proc/copy_programming(datum/nanite_program/target, copy_activated = TRUE)
	if(copy_activated)
		target.activated = activated
	target.timer_restart = timer_restart
	target.timer_shutdown = timer_shutdown
	target.timer_trigger_delay = timer_trigger_delay
	target.activation_code = activation_code
	target.deactivation_code = deactivation_code
	target.kill_code = kill_code
	target.trigger_code = trigger_code

	target.rules = list()
	for(var/R in rules)
		var/datum/nanite_rule/rule = R
		rule.copy_to(target)

	if(istype(target,src))
		copy_extra_settings_to(target)

///Register extra settings by overriding this.
///extra_settings[name] = new typepath() for each extra setting
/datum/nanite_program/proc/register_extra_settings()
	var/list/logictypes = list()
	for(var/name in logic)
		logictypes += name
	extra_settings[NES_RULE_LOGIC] = new /datum/nanite_extra_setting/type("AND", logictypes)
	return

///You can override this if you need to have special behavior after setting certain settings.
/datum/nanite_program/proc/set_extra_setting(setting, value)
	var/datum/nanite_extra_setting/ES = extra_settings[setting]
	if(istype(ES, /datum/nanite_extra_setting/text))
		if(CHAT_FILTER_CHECK(value))
			to_chat(usr, span_warning("Your message contains forbidden words."))
			var/logmsg = "attempted to set a forbidden nanite cloud [src] field \"[setting]\" with contents: \"[value]\". The message was filtered and blocked."
			log_admin_private("[key_name(usr)] [logmsg]")
			message_admins("[ADMIN_LOOKUPFLW(usr)] [logmsg]")
			return ES.set_value("")
	log_game("[key_name(usr)] set the nanite cloud [src] field \"[setting]\" to: \"[value]\"")
	return ES.set_value(value)

///You probably shouldn't be overriding this one, but I'm not a cop.
/datum/nanite_program/proc/get_extra_setting_value(setting)
	var/datum/nanite_extra_setting/ES = extra_settings[setting]
	return ES.get_value()

///Used for getting information about the extra settings to the frontend
/datum/nanite_program/proc/get_extra_settings_frontend()
	var/list/out = list()
	for(var/name in extra_settings)
		var/datum/nanite_extra_setting/ES = extra_settings[name]
		out += ES.get_frontend_list(name)
	return out

///Copy of the list instead of direct reference for obvious reasons
/datum/nanite_program/proc/copy_extra_settings_to(datum/nanite_program/target)
	var/list/copy_list = list()
	for(var/ns_name in extra_settings)
		var/datum/nanite_extra_setting/extra_setting = extra_settings[ns_name]
		copy_list[ns_name] = extra_setting.get_copy()
	target.extra_settings = copy_list

/datum/nanite_program/proc/on_add(datum/component/nanites/_nanites)
	nanites = _nanites
	if(nanites.host_mob)
		on_mob_add()

/datum/nanite_program/proc/on_mob_add()
	host_mob = nanites.host_mob
	// Triggered nanite programs can only be triggered and not activated/de-activated
	if (can_trigger)
		return
	if(activated) //apply activation effects depending on initial status; starts the restart and shutdown timers
		activate()
	else
		deactivate()

/datum/nanite_program/proc/on_mob_remove()
	return

/datum/nanite_program/proc/toggle()
	// Triggered nanite programs can only be triggered and not activated/de-activated
	if (can_trigger)
		return
	if(!activated)
		activate()
	else
		deactivate()

/datum/nanite_program/proc/activate()
	activated = TRUE
	if(timer_shutdown)
		timer_shutdown_next = world.time + timer_shutdown
	if (!isnull(maximum_duration))
		disable_time = world.time + maximum_duration

/datum/nanite_program/proc/deactivate()
	if(passive_enabled)
		disable_passive_effect()
	activated = FALSE
	if(timer_restart)
		timer_restart_next = world.time + timer_restart
	if (!isnull(disable_time))
		disable_time = null

/// Processes every second
/datum/nanite_program/proc/on_process()
	SHOULD_CALL_PARENT(TRUE)
	if(!can_trigger && !activated)
		if(timer_restart_next && world.time > timer_restart_next)
			activate()
			timer_restart_next = 0
		return

	if (can_trigger && !activated)
		if(timer_restart_next && world.time > timer_restart_next)
			trigger()
			timer_restart_next = 0
		return

	if(!can_trigger && timer_shutdown_next && world.time > timer_shutdown_next)
		deactivate()
		timer_shutdown_next = 0
		return

	// Disable time forces deactivation
	if (!isnull(disable_time) && world.time > disable_time)
		deactivate()
		return

	if(can_trigger && timer_trigger_delay_next && world.time > timer_trigger_delay_next)
		trigger(delayed = TRUE)
		timer_trigger_delay_next = 0
		return

	if(check_conditions() && consume_nanites(use_rate))
		if(!passive_enabled)
			enable_passive_effect()
		active_effect()
	else
		if(passive_enabled)
			disable_passive_effect()

//If false, disables active and passive effects, but doesn't consume nanites
//Can be used to avoid consuming nanites for nothing
/datum/nanite_program/proc/check_conditions()
	// Nanites automatically disabled when time passes the disable timer
	if (!isnull(disable_time) && world.time > disable_time)
		return FALSE
	var/rule_amt = length(rules)
	if(rule_amt)
		var/datum/nanite_extra_setting/logictype = extra_settings[NES_RULE_LOGIC]
		if(logictype)
			switch(logictype.get_value())
				if(NL_AND)
					for(var/R in 1 to min(rule_amt, 5))
						var/datum/nanite_rule/rule = rules[R]
						if(!rule.check_rule())
							return FALSE
				if(NL_OR)
					for(var/R in 1 to min(rule_amt, 5))
						var/datum/nanite_rule/rule = rules[R]
						if(rule.check_rule())
							return TRUE
					return FALSE
				if(NL_NOR)
					for(var/R in 1 to min(rule_amt, 5))
						var/datum/nanite_rule/rule = rules[R]
						if(rule.check_rule())
							return FALSE
				if(NL_NAND)
					for(var/R in 1 to min(rule_amt, 5))
						var/datum/nanite_rule/rule = rules[R]
						if(!rule.check_rule())
							return TRUE
					return FALSE
		else
			for(var/R in 1 to min(rule_amt, 5))
				var/datum/nanite_rule/rule = rules[R]
				if(!rule.check_rule())
					return FALSE
	return TRUE

//Constantly procs as long as the program is active
/datum/nanite_program/proc/active_effect()
	return

//Procs once when the program activates
/datum/nanite_program/proc/enable_passive_effect()
	passive_enabled = TRUE

//Procs once when the program deactivates
/datum/nanite_program/proc/disable_passive_effect()
	passive_enabled = FALSE

//Checks conditions then fires the nanite trigger effect
/datum/nanite_program/proc/trigger(delayed = FALSE, comm_message)
	if(!can_trigger || world.time < next_trigger)
		// If we fail to trigger, then requeue to trigger again
		if (!timer_restart_next && timer_restart)
			timer_restart_next = world.time + timer_restart
		return
	if(timer_trigger_delay && !delayed)
		timer_trigger_delay_next = world.time + timer_trigger_delay
		return
	// If we don't have a maximum duration, queue up the trigger restart
	if (!maximum_duration && timer_restart)
		timer_restart_next = world.time + timer_restart
	if(!check_conditions())
		return
	if(!consume_nanites(trigger_cost))
		return
	next_trigger = world.time + trigger_cooldown + maximum_duration
	on_trigger(comm_message)

//Nanite trigger effect, requires can_trigger to be used
/datum/nanite_program/proc/on_trigger(comm_message)
	if (maximum_duration)
		activate()

/datum/nanite_program/proc/consume_nanites(amount, force = FALSE)
	return nanites.consume_nanites(amount, force)

/datum/nanite_program/proc/on_emp(severity)
	if(program_flags & NANITE_EMP_IMMUNE)
		return
	if(prob(80 / severity))
		software_error()

/datum/nanite_program/proc/on_shock(shock_damage)
	if(!(program_flags & NANITE_SHOCK_IMMUNE))
		if(prob(10))
			software_error()
		else if(prob(33))
			qdel(src)

/datum/nanite_program/proc/on_minor_shock()
	if(!(program_flags & NANITE_SHOCK_IMMUNE))
		if(prob(10))
			software_error()

/datum/nanite_program/proc/on_death()
	return

/datum/nanite_program/proc/software_error(type)
	if(!type)
		type = rand(1,4)
	switch(type)
		if(1)
			qdel(src) //kill switch
			return
		if(2) //deprogram codes
			activation_code = 0
			deactivation_code = 0
			kill_code = 0
			trigger_code = 0
		if(3)
			if(can_trigger)
				trigger()
			else
				toggle()
		if(4) //Program is scrambled and does something different
			var/rogue_type = pick(rogue_types)
			var/datum/nanite_program/rogue = new rogue_type
			nanites.add_program(null, rogue, src)
			qdel(src)

/datum/nanite_program/proc/receive_nanite_signal(code, source)
	if(activation_code && code == activation_code && !activated && !can_trigger)
		activate()
		host_mob.investigate_log("'s [name] nanite program was activated by [source] with code [code]. Cloud No.[nanites.cloud_id]", INVESTIGATE_NANITES)
	else if(deactivation_code && code == deactivation_code && activated && !can_trigger)
		deactivate()
		host_mob.investigate_log("'s [name] nanite program was deactivated by [source] with code [code]. Cloud No.[nanites.cloud_id]", INVESTIGATE_NANITES)
	if(can_trigger && trigger_code && code == trigger_code)
		trigger()
		host_mob.investigate_log("'s [name] nanite program was triggered by [source] with code [code]. Cloud No.[nanites.cloud_id]", INVESTIGATE_NANITES)
	if(kill_code && code == kill_code)
		host_mob.investigate_log("'s [name] nanite program was deleted by [source] with code [code]. Cloud No.[nanites.cloud_id]", INVESTIGATE_NANITES)
		qdel(src)
