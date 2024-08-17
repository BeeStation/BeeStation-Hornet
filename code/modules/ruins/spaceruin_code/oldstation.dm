///////////	Oldstation items

/obj/item/paper/fluff/ruins/oldstation
	name = "Cryo Awakening Alert"
	default_raw_text = "<B>**WARNING**</B><BR><BR>Catastrophic damage sustained to station. Powernet exhausted to reawaken crew.<BR><BR>Immediate Objectives<br><br>1: Activate emergency power generator<br>2: Lift station lockdown on the bridge<br><br>Please locate the 'Damage Report' on the bridge for a detailed situation report."

/obj/item/paper/fluff/ruins/oldstation/damagereport
	name = "Damage Report"
	default_raw_text = "<b>*Damage Report*</b><br><br><b>Alpha Station</b> - Destroyed<br><br><b>Beta Station</b> - Catastrophic Damage. Medical, destroyed. Atmospherics, partially destroyed. Engine Core, destroyed.<br><br><b>Charlie Station</b> - Intact. Loss of oxygen to eastern side of main corridor.<br><br><b>Delta Station</b> - Intact. <b>WARNING</b>: Unknown force occupying Delta Station. Intent unknown. Species unknown. Numbers unknown.<br><br>Recommendation - Reestablish station powernet via solar array. Reestablish station atmospherics system to restore air."

/obj/item/paper/fluff/ruins/oldstation/protosuit
	name = "B01-MOD modular suit Report"
	default_raw_text = "<b>*Prototype MODsuit*</b><br><br>This is a prototype powered exoskeleton, a design not seen in hundreds of years, \
		the first post-void war era modular suit to ever be safely utilized by an operator. \
		This ancient clunker is still functional, though it's missing several modern-day luxuries from \
		updated Nakamura Engineering designs. Primarily, the suit's myoelectric suit layer is entirely non-existant, \
		and the servos do very little to help distribute the weight evenly across the wearer's body, \
		making it slow and bulky to move in. Additionally, the armor plating never finished production aside from the shoulders, \
		forearms, and helmet; making it useless against direct attacks. The internal heads-up display is rendered entirely in \
		monochromatic cyan, leaving the user unable to see long distances. However, the way the helmet retracts is pretty cool."

/obj/item/paper/fluff/ruins/oldstation/protohealth
	name = "Health Analyser Report"
	default_raw_text = "<b>*Health Analyser*</b><br><br>The portable Health Analyser is essentially a handheld variant of a health analyser. Years of research have concluded with this device which is \
	capable of diagnosing even the most critical, obscure or technical injuries any humanoid entity is suffering in an easy to understand format that even a non-trained health professional \
	can understand.<br><br>The health analyser is expected to go into full production as standard issue medical kit."

/obj/item/paper/fluff/ruins/oldstation/protogun
	name = "K14 Energy Gun Report"
	default_raw_text = "<b>*K14-Multiphase Energy Gun*</b><br><br>The K14 Prototype Energy Gun is the first Energy Rifle that has been successfully been able to not only hold a larger ammo charge \
	than other gun models, but is capable of swapping between different energy projectile types on command with no incidents.<br><br>The weapon still suffers several drawbacks, its alternative, \
	non laser fire mode, can only fire one round before exhausting the energy cell, the weapon also remains prohibitively expensive, nonetheless NT Market Research fully believe this weapon \
	will form the backbone of our Energy weapon catalogue.<br><br>The K14 is expected to undergo revision to fix the ammo issues, the K15 is expected to replace the 'stun' setting with a \
	'disable' setting in an attempt to bypass the ammo issues."

/obj/item/paper/fluff/ruins/oldstation/protosing
	name = "Singularity Generator"
	default_raw_text = "<b>*Singularity Generator*</b><br><br>Modern power generation typically comes in two forms, a Fusion Generator or a Fission Generator. Fusion provides the best space to power \
	ratio, and is typically seen on military or high security ships and stations, however Fission reactors require the usage of expensive, and rare, materials in its construction.. Fission generators are massive and bulky, and require a large reserve of uranium to power, however they are extremely cheap to operate and oft need little maintenance once \
	operational.<br><br>The Singularity aims to alter this, a functional Singularity is essentially a controlled Black Hole, a Black Hole that generates far more power than Fusion or Fission \
	generators can ever hope to produce. "

/obj/item/paper/fluff/ruins/oldstation/protoinv
	name = "Laboratory Inventory"
	default_raw_text = "<b>*Inventory*</b><br><br>(1) Prototype Hardsuit<br><br>(1)Health Analyser<br><br>(1)Prototype Energy Gun<br><br>(1)Singularity Generation Disk<br><br><b>DO NOT REMOVE WITHOUT \
	THE CAPTAIN AND RESEARCH DIRECTOR'S AUTHORISATION</b>"

/obj/item/paper/fluff/ruins/oldstation/report
	name = "Crew Reawakening Report"
	default_raw_text = "Artificial Program's report to surviving crewmembers.<br><br>Crew were placed into cryostasis on March 10th, 2445.<br><br>Crew were awoken from cryostasis around June, 2557.<br><br> \
	<b>SIGNIFICANT EVENTS OF NOTE</b><br>1: The primary radiation detectors were taken offline after 112 years due to power failure, secondary radiation detectors showed no residual \
	radiation on station. Deduction, primarily detector was malfunctioning and was producing a radiation signal when there was none.<br><br>2: A data burst from a nearby Nanotrasen Space \
	Station was received, this data burst contained research data that has been uploaded to our RnD labs.<br><br>3: Unknown invasion force has occupied Delta station."

/obj/item/paper/fluff/ruins/oldstation/generator_manual
	name = "S.U.P.E.R.P.A.C.M.A.N.-type portable generator manual"
	default_raw_text = "You can barely make out a faded sentence... <br><br> Wrench down the generator on top of a wire node connected to either a SMES input terminal or the power grid."

/obj/machinery/mod_installer
	name = "modular outerwear device installator"
	desc = "An ancient machine that mounts a MOD unit onto the occupant."
	icon = 'icons/obj/machines/mod_installer.dmi'
	icon_state = "mod_installer"
	base_icon_state = "mod_installer"
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	//obj_flags = NO_BUILD // Becomes undense when the door is open
	idle_power_usage = 50
	active_power_usage = 300

	var/busy = FALSE
	var/busy_icon_state

	var/obj/item/mod/control/mod_unit = /obj/item/mod/control/pre_equipped/prototype

	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/mod_installer/Initialize(mapload)
	. = ..()
	occupant_typecache = typecacheof(/mob/living/carbon/human)
	if(ispath(mod_unit))
		mod_unit = new mod_unit()

/obj/machinery/mod_installer/Destroy()
	QDEL_NULL(mod_unit)
	return ..()

/obj/machinery/mod_installer/proc/set_busy(status, working_icon)
	busy = status
	busy_icon_state = working_icon
	update_appearance()

/obj/machinery/mod_installer/proc/play_install_sound()
	playsound(src, 'sound/items/rped.ogg', 30, FALSE)

/obj/machinery/mod_installer/update_icon_state()
	icon_state = busy ? busy_icon_state : "[base_icon_state][state_open ? "_open" : null]"
	return ..()

/obj/machinery/mod_installer/update_overlays()
	var/list/overlays = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return overlays
	overlays += (busy || !mod_unit) ? "red" : "green"
	return overlays

/obj/machinery/mod_installer/proc/start_process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!occupant || !mod_unit || busy)
		return
	set_busy(TRUE, "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_active"), 2.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(play_install_sound)), 2.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_falling"), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_process)), 7.5 SECONDS)

/obj/machinery/mod_installer/proc/complete_process()
	set_busy(FALSE)
	var/mob/living/carbon/human/human_occupant = occupant
	if(!istype(human_occupant))
		return
	if(!human_occupant.dropItemToGround(human_occupant.back))
		return
	if(!human_occupant.equip_to_slot_if_possible(mod_unit, mod_unit.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	human_occupant.update_action_buttons(TRUE)
	playsound(src, 'sound/machines/ping.ogg', 30, FALSE)
	if(!human_occupant.dropItemToGround(human_occupant.wear_suit) || !human_occupant.dropItemToGround(human_occupant.head))
		finish_completion()
		return
	mod_unit.quick_activation()
	finish_completion()

/obj/machinery/mod_installer/proc/finish_completion()
	mod_unit = null
	open_machine()

/obj/machinery/mod_installer/open_machine()
	if(state_open)
		return FALSE
	..()
	return TRUE

/obj/machinery/mod_installer/close_machine(mob/living/carbon/user)
	if(!state_open)
		return FALSE
	..()
	addtimer(CALLBACK(src, PROC_REF(start_process)), 1 SECONDS)
	return TRUE

/obj/machinery/mod_installer/relaymove(mob/living/user, direction)
	var/message
	if(busy)
		message = "it won't budge!"
	else if(user.stat != CONSCIOUS)
		message = "you don't have the energy!"
	if(!isnull(message))
		if (COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
			balloon_alert(user, message)
		return
	open_machine()

/obj/machinery/mod_installer/interact(mob/user)
	if(state_open)
		close_machine(null, user)
		return
	else if(busy)
		balloon_alert(user, "it's locked!")
		return
	open_machine()
