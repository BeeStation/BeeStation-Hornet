/datum/species/ipc
	name = "IPC"
	id = SPECIES_IPC
	bodyflag = FLAG_IPC
	say_mod = "states"
	sexes = FALSE
	species_traits = list(NOTRANSSTING,NOEYESPRITES,NO_DNA_COPY,ROBOTIC_LIMBS,NOZOMBIE,MUTCOLORS,REVIVESBYHEALING,NOHUSK,NOMOUTH)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_NOBREATH,TRAIT_RADIMMUNE,TRAIT_LIMBATTACHMENT,TRAIT_NOCRITDAMAGE,TRAIT_EASYDISMEMBER,TRAIT_POWERHUNGRY,TRAIT_XENO_IMMUNE, TRAIT_TOXIMMUNE)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	mutant_brain = /obj/item/organ/brain/positron
	mutanteyes = /obj/item/organ/eyes/robotic
	mutanttongue = /obj/item/organ/tongue/robot
	mutantliver = /obj/item/organ/liver/cybernetic/upgraded/ipc
	mutantstomach = /obj/item/organ/stomach/battery/ipc
	mutantears = /obj/item/organ/ears/robot
	mutant_heart = /obj/item/organ/heart/cybernetic/ipc
	mutant_organs = list(/obj/item/organ/cyberimp/arm/power_cord)
	mutant_bodyparts = list("ipc_screen", "ipc_antenna", "ipc_chassis")
	default_features = list("mcolor" = "#7D7D7D", "ipc_screen" = "Static", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)")
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/iron{amount = 10}
	exotic_blood = /datum/reagent/oil
	damage_overlay_type = "synth"
	limbs_id = "synth"
	mutant_bodyparts = list("ipc_screen", "ipc_antenna", "ipc_chassis")
	default_features = list("ipc_screen" = "BSOD", "ipc_antenna" = "None")
	burnmod = 2
	heatmod = 1.5
	brutemod = 1
	clonemod = 0
	staminamod = 0.8
	siemens_coeff = 1.5
	blood_color = "#000000"
	reagent_tag = PROCESS_SYNTHETIC
	species_gibs = GIB_TYPE_ROBOTIC
	attack_sound = 'sound/items/trayhit1.ogg'
	allow_numbers_in_name = TRUE
	deathsound = "sound/voice/borg_deathsound.ogg"
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	species_language_holder = /datum/language_holder/synthetic
	special_step_sounds = list('sound/effects/servostep.ogg')

	var/saved_screen //for saving the screen when they die
	var/datum/action/innate/change_screen/change_screen

/datum/species/ipc/random_name(unique)
	var/ipc_name = "[pick(GLOB.posibrain_names)]-[rand(100, 999)]"
	return ipc_name

/datum/species/ipc/on_species_gain(mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/appendix/A = C.getorganslot("appendix") //See below.
	if(A)
		A.Remove(C)
		QDEL_NULL(A)
	var/obj/item/organ/lungs/L = C.getorganslot("lungs") //Hacky and bad. Will be rewritten entirely in KapuCarbons anyway.
	if(L)
		L.Remove(C)
		QDEL_NULL(L)
	if(ishuman(C) && !change_screen)
		change_screen = new
		change_screen.Grant(C)
	for(var/obj/item/bodypart/O in C.bodyparts)
		O.render_like_organic = TRUE // Makes limbs render like organic limbs instead of augmented limbs, check bodyparts.dm
		var/chassis = C.dna.features["ipc_chassis"]
		var/datum/sprite_accessory/ipc_chassis/chassis_of_choice = GLOB.ipc_chassis_list[chassis]
		C.dna.species.limbs_id = chassis_of_choice.limbs_id
		if(chassis_of_choice.color_src == MUTCOLORS && !(MUTCOLORS in C.dna.species.species_traits)) // If it's a colorable(Greyscale) chassis, we use MUTCOLORS.
			C.dna.species.species_traits += MUTCOLORS
		else if(MUTCOLORS in C.dna.species.species_traits)
			C.dna.species.species_traits -= MUTCOLORS
		O.light_brute_msg = "scratched"
		O.medium_brute_msg = "dented"
		O.heavy_brute_msg = "sheared"

		O.light_burn_msg = "burned"
		O.medium_burn_msg = "scorched"
		O.heavy_burn_msg = "seared"

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.physiology.bleed_mod *= 0.1

/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(change_screen)
		change_screen.Remove(C)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.physiology.bleed_mod *= 10

/datum/species/ipc/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT //beep

/datum/species/ipc/spec_death(gibbed, mob/living/carbon/C)
	saved_screen = C.dna.features["ipc_screen"]
	C.dna.features["ipc_screen"] = "BSOD"
	C.update_body()
	addtimer(CALLBACK(src, .proc/post_death, C), 5 SECONDS)

/datum/species/ipc/proc/post_death(mob/living/carbon/C)
	if(C.stat < DEAD)
		return
	C.dna.features["ipc_screen"] = null //Turns off screen on death
	C.update_body()

/datum/action/innate/change_screen
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/change_screen/Activate()
	var/screen_choice = input(usr, "Which screen do you want to use?", "Screen Change") as null | anything in GLOB.ipc_screens_list
	var/color_choice = input(usr, "Which color do you want your screen to be?", "Color Change") as null | color
	if(!screen_choice)
		return
	if(!color_choice)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.dna.features["ipc_screen"] = screen_choice
	H.eye_color = sanitize_hexcolor(color_choice)
	H.update_body()

/obj/item/apc_powercord
	name = "power cord"
	desc = "An internal power cord hooked up to a battery. Useful if you run on electricity. Not so much otherwise."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if((!istype(target, /obj/machinery/power/apc) && !isethereal(target)) || !ishuman(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/stomach/battery/battery = H.getorganslot(ORGAN_SLOT_STOMACH)
	if(!battery)
		to_chat(H, "<span class='warning'>You try to siphon energy from \the [target], but your power cell is gone!</span>")
		return

	if(istype(H) && H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
		to_chat(user, "<span class='warning'>You are already fully charged!</span>")
		return

	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.cell && A.cell.charge > A.cell.maxcharge/4)
			powerdraw_loop(A, H, TRUE)
			return
		else
			to_chat(user, "<span class='warning'>There is not enough charge to draw from that APC.</span>")
			return

	if(isethereal(target))
		var/mob/living/carbon/human/target_ethereal = target
		var/obj/item/organ/stomach/battery/target_battery = target_ethereal.getorganslot(ORGAN_SLOT_STOMACH)
		if(target_ethereal.nutrition > 0 && target_battery)
			powerdraw_loop(target_battery, H, FALSE)
			return
		else
			to_chat(user, "<span class='warning'>There is not enough charge to draw from that being!</span>")
			return
/obj/item/apc_powercord/proc/powerdraw_loop(atom/target, mob/living/carbon/human/H, apc_target)
	H.visible_message("<span class='notice'>[H] inserts a power connector into [target].</span>", "<span class='notice'>You begin to draw power from the [target].</span>")
	var/obj/item/organ/stomach/battery/battery = H.getorganslot(ORGAN_SLOT_STOMACH)
	if(apc_target)
		var/obj/machinery/power/apc/A = target
		if(!istype(A))
			return
		while(do_after(H, 10, target = A))
			if(!battery)
				to_chat(H, "<span class='warning'>You need a battery to recharge!</span>")
				break
			if(loc != H)
				to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
				break
			if(A.cell.charge <= A.cell.maxcharge/4)
				to_chat(H, "<span class='warning'>The [A] doesn't have enough charge to spare.</span>")
				break
			A.charging = 1
			if(A.cell.charge > A.cell.maxcharge/4 + 250)
				battery.adjust_charge(250)
				A.cell.charge -= 250
				to_chat(H, "<span class='notice'>You siphon off some of the stored charge for your own use.</span>")
			else
				battery.adjust_charge(A.cell.charge - A.cell.maxcharge/4)
				A.cell.charge = A.cell.maxcharge/4
				to_chat(H, "<span class='notice'>You siphon off as much as the [A] can spare.</span>")
				break
			if(battery.charge >= battery.max_charge)
				to_chat(H, "<span class='notice'>You are now fully charged.</span>")
				break
	else
		var/obj/item/organ/stomach/battery/A = target
		if(!istype(A))
			return
		var/charge_amt
		while(do_after(H, 10, target = A.owner))
			if(!battery)
				to_chat(H, "<span class='warning'>You need a battery to recharge!</span>")
				break
			if(loc != H)
				to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
				break
			if(A.charge == 0)
				to_chat(H, "<span class='warning'>[A] is completely drained!</span>")
				break
			charge_amt = A.charge <= 50 ? A.charge : 50
			A.adjust_charge(-1 * charge_amt)
			battery.adjust_charge(charge_amt)
			if(battery.charge >= battery.max_charge)
				to_chat(H, "<span class='notice'>You are now fully charged.</span>")
				break

	H.visible_message("<span class='notice'>[H] unplugs from the [target].</span>", "<span class='notice'>You unplug from the [target].</span>")
	return

/datum/species/ipc/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.health <= UNCONSCIOUS && H.stat != DEAD) // So they die eventually instead of being stuck in crit limbo.
		H.adjustFireLoss(6) // After bodypart_robotic resistance this is ~2/second
		if(prob(5))
			to_chat(H, "<span class='warning'>Alert: Internal temperature regulation systems offline; thermal damage sustained. Shutdown imminent.</span>")
			H.visible_message("[H]'s cooling system fans stutter and stall. There is a faint, yet rapid beeping coming from inside their chassis.")

/datum/species/ipc/spec_revival(mob/living/carbon/human/H)
	H.notify_ghost_cloning("You have been repaired!")
	H.grab_ghost()
	H.dna.features["ipc_screen"] = "BSOD"
	H.update_body()
	H.say("Reactivating [pick("core systems", "central subroutines", "key functions")]...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Reinitializing [pick("personality matrix", "behavior logic", "morality subsystems")]...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Finalizing setup...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Unit [H.real_name] is fully functional. Have a nice day.")
	H.dna.features["ipc_screen"] = saved_screen
	H.update_body()
	return

/datum/species/ipc/get_harm_descriptors()
	return list("bleed" = "leaking", "brute" = "denting", "burn" = "burns")
