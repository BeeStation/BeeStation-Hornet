/***************** MECHA ACTIONS *****************/

/obj/vehicle/sealed/mecha/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/mecha))
		var/datum/action/vehicle/sealed/mecha/mecha_action = .
		mecha_action.set_chassis(src)


/datum/action/vehicle/sealed/mecha
	icon_icon = 'icons/hud/actions/actions_mecha.dmi'
	var/obj/vehicle/sealed/mecha/chassis

/datum/action/vehicle/sealed/mecha/Destroy()
	chassis = null
	return ..()

///Sets the chassis var of our mecha action to the referenced mecha. Used during actions generation in
///generate_action_type() chain.
/datum/action/vehicle/sealed/mecha/proc/set_chassis(passed_chassis)
	chassis = passed_chassis

/datum/action/vehicle/sealed/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/vehicle/sealed/mecha/mech_eject/on_activate(mob/user, atom/target)
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.container_resist(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal
	name = "Toggle Cabin Airtight"
	button_icon_state = "mech_cabin_open"
	desc = "Airtight cabin preserves internal air and can be pressurized with a mounted air tank."

/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.set_cabin_seal(owner, !chassis.cabin_sealed)

/datum/action/vehicle/sealed/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.toggle_lights(user = owner)

/datum/action/vehicle/sealed/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/mecha/mech_view_stats/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.ui_interact(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties
	name = "Toggle Equipment Safeties"
	button_icon_state = "mech_safeties_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties/set_chassis(passed_chassis)
	. = ..()
	RegisterSignal(chassis, COMSIG_MECH_SAFETIES_TOGGLE, PROC_REF(update_action_icon))

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties/on_activate()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.set_safety(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties/proc/update_action_icon()
	SIGNAL_HANDLER
	button_icon_state = "mech_safeties_[chassis.weapons_safety ? "on" : "off"]"
	update_buttons()

/datum/action/vehicle/sealed/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	button_icon_state = "strafe"

/datum/action/vehicle/sealed/mecha/strafe/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.toggle_strafe()

/obj/vehicle/sealed/mecha/AltClick(mob/living/user)
	if(!(user in occupants) || !user.canUseTopic(src))
		return
	if(!(user in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)))
		to_chat(user, "<span class='warning'>You're in the wrong seat to control movement.</span>")
		return
	toggle_strafe()

/obj/vehicle/sealed/mecha/proc/toggle_strafe()
	if(!(mecha_flags & CANSTRAFE))
		to_chat(occupants, "[icon2html(src, occupants)][span_notice("This mecha does not support strafing.")]")
		return
	strafe = !strafe

	to_chat(occupants, "[icon2html(src, occupants)][span_notice("Toggled strafing mode [strafe?"on":"off"].")]")
	log_message("Toggled strafing mode [strafe?"on":"off"].", LOG_MECHA)

	for(var/occupant in occupants)
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/strafe)
		action?.update_buttons()

//////////////////////////////////////// Specific Ability Actions  ///////////////////////////////////////////////
//Need to be granted by the mech type, Not default abilities.

/datum/action/vehicle/sealed/mecha/mech_defense_mode
	name = "Toggle an energy shield that blocks all attacks from the faced direction at a heavy power cost."
	button_icon_state = "mech_defense_mode_off"

/datum/action/vehicle/sealed/mecha/mech_defense_mode/on_activate(mob/user, atom/target)
	SEND_SIGNAL(chassis, COMSIG_MECHA_ACTION_TRIGGER, owner, args) //Signal sent to the mech, to be handed to the shield. See durand.dm for more details

/datum/action/vehicle/sealed/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/vehicle/sealed/mecha/mech_smoke/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_SMOKE) && chassis.smoke_charges>0)
		chassis.smoke_system.start()
		chassis.smoke_charges--
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_SMOKE, chassis.smoke_cooldown)

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/on_activate(mob/user, atom/target)

	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.log_message("Toggled zoom mode.", LOG_MECHA)
		chassis.balloon_alert(owner, "Zoom mode has been [chassis.zoom_mode ? "enabled" : "disabled"].")
		if(chassis.zoom_mode)
			owner.client.view_size.setTo(4.5)
			SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg',volume=50))
		else
			owner.client.view_size.resetToDefault() //Let's not let this stack shall we?
		update_buttons()

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/new_damtype
	switch(chassis.damtype)
		if(TOX)
			new_damtype = BRUTE
			chassis.balloon_alert(owner, "your punches will now deal brute damage")
		if(BRUTE)
			new_damtype = BURN
			chassis.balloon_alert(owner, "your punches will now deal burn damage")
		if(BURN)
			new_damtype = TOX
			chassis.balloon_alert(owner,"your punches will now deal toxin damage")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(chassis, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	update_buttons()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = chassis.phasing ? "" : "phasing"
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.balloon_alert(owner, "[chassis.phasing ? "Enabled" : "Disabled"] phasing")
	update_buttons()

///swap seats, for two person mecha
/datum/action/vehicle/sealed/mecha/swap_seat
	name = "Switch Seats"
	button_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/swap_seat/on_activate(mob/user, atom/target, trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(chassis.occupants.len == chassis.max_occupants)
		chassis.balloon_alert(owner, "other seat occupied!")
		return
	var/list/drivers = chassis.return_drivers()
	chassis.balloon_alert(owner, "moving to other seat...")
	chassis.is_currently_ejecting = TRUE
	if(!do_after(owner, chassis.has_gravity() ? chassis.exit_delay : 0 , target = chassis))
		chassis.balloon_alert(owner, "interrupted!")
		chassis.is_currently_ejecting = FALSE
		return
	chassis.is_currently_ejecting = FALSE
	if(owner in drivers)
		chassis.balloon_alert(owner, "controlling gunner seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
	else
		chassis.balloon_alert(owner, "controlling pilot seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	chassis.update_icon_state()

/datum/action/vehicle/sealed/mecha/mech_overclock
	name = "Toggle overclocking"
	button_icon_state = "mech_overload_off"

/datum/action/vehicle/sealed/mecha/mech_overclock/Trigger(trigger_flags, forced_state = null)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.toggle_overclock(forced_state)
	chassis.balloon_alert(owner, chassis.overclock_mode ? "started overclocking" : "stopped overclocking")
	button_icon_state = "mech_overload_[chassis.overclock_mode ? "on" : "off"]"
	update_buttons()
