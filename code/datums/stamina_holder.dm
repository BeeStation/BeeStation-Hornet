/datum/stamina_container
	///Daddy?
	var/mob/living/parent
	///The maximum amount of stamina this container has
	var/maximum = 0
	///How much stamina we have right now
	var/current = 0
	///The amount of stamina gained per second
	var/regen_rate = 10
	///The difference between current and maximum stamina
	var/loss = 0
	var/loss_as_percent = 0
	///Regeneration is held off until this world.time
	var/regen_blocked_until = 0

	VAR_PRIVATE/default_max
	VAR_PRIVATE/default_regen

	var/list/maximum_modifiers
	var/list/regen_modifiers
	var/list/regen_multipliers

/datum/stamina_container/New(parent, maximum = STAMINA_MAX, regen_rate = STAMINA_REGEN)
	src.parent = parent
	src.maximum = maximum
	src.default_max = maximum
	src.regen_rate = regen_rate
	src.default_regen = regen_rate
	src.current = maximum

/datum/stamina_container/Destroy()
	parent?.stamina = null
	parent = null
	STOP_PROCESSING(SSstamina, src)
	return ..()

/datum/stamina_container/process(delta_time)
	if(delta_time && world.time >= regen_blocked_until)
		current = min(current + (regen_rate*delta_time), maximum)
	loss = maximum - current
	loss_as_percent = maximum ? loss / maximum * 100 : 0

	if(datum_flags & DF_ISPROCESSING)
		if(delta_time && current == maximum)
			STOP_PROCESSING(SSstamina, src)
	else if(!(current == maximum))
		START_PROCESSING(SSstamina, src)

	parent.on_stamina_update()

///Hold off stamina regeneration for some period of time.
/datum/stamina_container/proc/block_regen(time)
	regen_blocked_until = max(regen_blocked_until, world.time + time)

///Adjust stamina by an amount. Returns the actual change in stamina.
/datum/stamina_container/proc/adjust(amt as num, forced)
	if(!amt)
		return 0
	if(amt < 0 && HAS_TRAIT_FROM(parent, TRAIT_INCAPACITATED, STAMINA))
		return 0
	if(SEND_SIGNAL(parent, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, STAMINA, -amt, forced) & COMPONENT_IGNORE_CHANGE)
		return 0
	///Our parent might want to fuck with these numbers
	var/modify = parent.pre_stamina_change(amt, forced)
	var/old_current = current
	current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	process()
	. = current - old_current
	if(. < 0)
		parent.on_stamina_loss()

/datum/stamina_container/proc/add_regen_modifier(source, amount)
	LAZYSET(regen_modifiers, source, amount)
	update_stamina_regen()

/datum/stamina_container/proc/remove_regen_modifier(source)
	LAZYREMOVE(regen_modifiers, source)
	update_stamina_regen()

/datum/stamina_container/proc/add_regen_multiplier(source, multiplier)
	if(LAZYACCESS(regen_multipliers, source) == multiplier)
		return
	LAZYSET(regen_multipliers, source, multiplier)
	update_stamina_regen()

/datum/stamina_container/proc/remove_regen_multiplier(source)
	if(isnull(LAZYACCESS(regen_multipliers, source)))
		return
	LAZYREMOVE(regen_multipliers, source)
	update_stamina_regen()

/datum/stamina_container/proc/update_stamina_regen()
	PRIVATE_PROC(TRUE)

	var/new_regen_rate = default_regen
	for(var/source, value in regen_modifiers)
		new_regen_rate += value
	for(var/source, value in regen_multipliers)
		new_regen_rate *= value

	regen_rate = max(new_regen_rate, 2)

/datum/stamina_container/proc/add_max_modifier(source, amount)
	LAZYSET(maximum_modifiers, source, amount)
	update_maximum()

/datum/stamina_container/proc/remove_max_modifier(source)
	LAZYREMOVE(maximum_modifiers, source)
	update_maximum()

/datum/stamina_container/proc/update_maximum()
	PRIVATE_PROC(TRUE)

	var/new_max_stamina = default_max
	for(var/source, value in maximum_modifiers)
		new_max_stamina += value

	maximum = max(new_max_stamina, 50)
	current = min(current, maximum)
	process()
