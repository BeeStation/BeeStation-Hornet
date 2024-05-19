// Sleeper, Medical Beam, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical
	mech_flags = EXOSUIT_MODULE_MEDICAL

/obj/item/mecha_parts/mecha_equipment/medical/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/can_attach(obj/vehicle/sealed/mecha/medical/M)
	if(..() && istype(M))
		return 1


/obj/item/mecha_parts/mecha_equipment/medical/attach(obj/vehicle/sealed/mecha/M)
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/process()
	if(!chassis)
		return PROCESS_KILL

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper
	name = "mounted sleeper"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents in the exosuit's reserves."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	energy_drain = 20
	range = MECHA_MELEE
	equip_cooldown = 20
	var/mob/living/carbon/patient = null
	var/inject_amount = 10
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Exit(atom/movable/O)
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/action(mob/source, mob/living/carbon/target, params)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(!patient_insertion_check(target))
		return
	to_chat(source, "[icon2html(src, source)]<span class='notice'>You start putting [target] into [src]...</span>")
	chassis.visible_message("<span class='warning'>[chassis] starts putting [target] into \the [src].</span>")
	if(do_after(source, equip_cooldown, target=target))
		if(!chassis || src != chassis.selected || !(get_dir(chassis, target)&chassis.dir))
			return
		if(!patient_insertion_check(target, source))
			return
		target.forceMove(src)
		patient = target
		START_PROCESSING(SSobj, src)
		update_equip_info()
		to_chat(source, "[icon2html(src, source)]<span class='notice'>[target] successfully loaded into [src]. Life support functions engaged.</span>")
		chassis.visible_message("<span class='warning'>[chassis] loads [target] into [src].</span>")
		log_message("[target] loaded. Life support functions engaged.", LOG_MECHA)
		return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/patient_insertion_check(mob/living/carbon/target, mob/user)
	if(target.buckled)
		to_chat(user, "[icon2html(src, user)]<span class='warning'>[target] will not fit into the sleeper because [target.p_theyre()] buckled to [target.buckled]!</span>")
		return
	if(target.has_buckled_mobs())
		to_chat(user, "[icon2html(src, user)]<span class='warning'>[target] will not fit into the sleeper because of the creatures attached to it!</span>")
		return
	if(patient)
		to_chat(user, "[icon2html(src, user)]<span class='warning'>The sleeper is already occupied!</span>")
		return
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/go_out()
	if(!patient)
		return
	patient.forceMove(get_turf(src))
	to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='notice'>[patient] ejected. Life support functions disabled.</span>")
	log_message("[patient] ejected. Life support functions disabled.", LOG_MECHA)
	STOP_PROCESSING(SSobj, src)
	patient = null
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/detach()
	if(patient)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='warning'>Unable to detach [src] - equipment occupied!</span>")
		return
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		if(patient)
			temp = "<br />\[Occupant: [patient] ([patient.stat > 1 ? "*DECEASED*" : "Health: [patient.health]%"])\]<br /><a href='?src=[REF(src)];view_stats=1'>View stats</a>|<a href='?src=[REF(src)];eject=1'>Eject</a>"
		return "[output] [temp]"
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Topic(href,href_list)
	. = ..()
	if(.)
		return
	if(!(usr in chassis.occupants))
		return
	if(href_list["eject"])
		go_out()
	if(href_list["view_stats"])
		usr << browse(get_patient_stats(),"window=msleeper")
		onclose(usr, "msleeper")
		return
	if(href_list["inject"])
		var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate() in chassis
		var/datum/reagent/R = locate(href_list["inject"]) in SG.reagents.reagent_list
		if(istype(R))
			inject_reagent(R, SG)
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_stats()
	if(!patient)
		return
	return {"<html>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<title>[patient] statistics</title>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				<style>
				h3 {margin-bottom:2px;font-size:14px;}
				#lossinfo, #reagents, #injectwith {padding-left:15px;}
				</style>
				</head>
				<body>
				<h3>Health statistics</h3>
				<div id="lossinfo">
				[get_patient_dam()]
				</div>
				<h3>Reagents in bloodstream</h3>
				<div id="reagents">
				[get_patient_reagents()]
				</div>
				<div id="injectwith">
				[get_available_reagents()]
				</div>
				</body>
				</html>"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_dam()
	var/t1
	switch(patient.stat)
		if(0)
			t1 = "Conscious"
		if(1)
			t1 = "Unconscious"
		if(2)
			t1 = "*dead*"
		else
			t1 = "Unknown"
	var/core_temp = ""
	if(ishuman(patient))
		var/mob/living/carbon/human/humi = patient
		core_temp = {"<font color="[humi.coretemperature > 300 ? "#3d5bc3" : "#c51e1e"]"><b>Body Temperature:</b> [humi.bodytemperature-T0C]&deg;C ([humi.bodytemperature*1.8-459.67]&deg;F)</font><br />"}
	return {"<font color="[patient.health > 50 ? "#3d5bc3" : "#c51e1e"]"><b>Health:</b> [patient.stat > 1 ? "[t1]" : "[patient.health]% ([t1])"]</font><br />
				[core_temp]
				<font color="[patient.bodytemperature > 300 ? "#3d5bc3" : "#c51e1e"]"><b>Body Temperature:</b> [patient.bodytemperature-T0C]&deg;C ([patient.bodytemperature*1.8-459.67]&deg;F)</font><br />
				<font color="[patient.getBruteLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Brute Damage:</b> [patient.getBruteLoss()]%</font><br />
				<font color="[patient.getOxyLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Respiratory Damage:</b> [patient.getOxyLoss()]%</font><br />
				<font color="[patient.getToxLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Toxin Content:</b> [patient.getToxLoss()]%</font><br />
				<font color="[patient.getFireLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Burn Severity:</b> [patient.getFireLoss()]%</font><br />
				<span class='danger'>[patient.getCloneLoss() ? "Subject appears to have cellular damage." : ""]</span><br />
				<span class='danger'>[patient.getOrganLoss(ORGAN_SLOT_BRAIN) ? "Significant brain damage detected." : ""]</span><br />
				<span class='danger'>[length(patient.get_traumas()) ? "Brain Traumas detected." : ""]</span><br />
				"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_reagents()
	if(patient.reagents)
		for(var/datum/reagent/R in patient.reagents.reagent_list)
			if(R.volume > 0)
				. += "[R]: [round(R.volume,0.01)]<br />"
	return . || "None"

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_available_reagents()
	var/output
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate(/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun) in chassis
	if(SG && SG.reagents && islist(SG.reagents.reagent_list))
		for(var/datum/reagent/R in SG.reagents.reagent_list)
			if(R.volume > 0)
				output += "<a href=\"?src=[REF(src)];inject=[REF(R)]\">Inject [R.name]</a><br />"
	return output


/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/inject_reagent(datum/reagent/R,obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG)
	if(!R || !patient || !SG || !(SG in chassis.equipment))
		return 0
	var/to_inject = min(R.volume, inject_amount)
	if(to_inject && patient.reagents.get_reagent_amount(R.type) + to_inject <= inject_amount*2)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='notice'>Injecting [patient] with [to_inject] units of [R.name].</span>")
		log_message("Injecting [patient] with [to_inject] units of [R.name].", LOG_MECHA)
		log_combat(chassis.occupants, patient, "injected", "[name] ([R] - [to_inject] units)")
		SG.reagents.trans_id_to(patient,R.type,to_inject)
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/update_equip_info()
	if(..())
		if(patient)
			send_byjax(chassis.occupants,"msleeper.browser","lossinfo",get_patient_dam())
			send_byjax(chassis.occupants,"msleeper.browser","reagents",get_patient_reagents())
			send_byjax(chassis.occupants,"msleeper.browser","injectwith",get_available_reagents())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/container_resist(mob/living/user)
	go_out()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/process()
	if(..())
		return
	if(!chassis.has_charge(energy_drain))
		log_message("Deactivated.", LOG_MECHA)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='warning'>[src] deactivated - no power.</span>")
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/M = patient
	if(!M)
		return
	if(M.health > 0)
		M.adjustOxyLoss(-1)
	M.AdjustStun(-80)
	M.AdjustKnockdown(-80)
	M.AdjustParalyzed(-80)
	M.AdjustImmobilized(-80)
	M.AdjustUnconscious(-80)
	if(M.reagents.get_reagent_amount(/datum/reagent/medicine/epinephrine) < 5)
		M.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
	chassis.use_power(energy_drain)
	update_equip_info()




///////////////////////////////// Syringe Gun ///////////////////////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "exosuit syringe gun"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "syringegun"
	var/list/syringes
	var/list/known_reagents
	var/list/processed_reagents
	var/max_syringes = 10
	var/max_volume = 75 //max reagent volume
	var/synth_speed = 5 //[num] reagent units per cycle
	energy_drain = 10
	var/mode = 0 //0 - fire syringe, 1 - analyze reagents.
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 10

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Initialize(mapload)
	. = ..()
	create_reagents(max_volume, NO_REACT)
	syringes = new
	known_reagents = list(/datum/reagent/medicine/epinephrine="Epinephrine",/datum/reagent/medicine/charcoal="Charcoal")
	processed_reagents = new

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/can_attach(obj/vehicle/sealed/mecha/medical/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href=\"?src=[REF(src)];toggle_mode=1\">[mode? "Analyze" : "Launch"]</a>\]<br />\[Syringes: [syringes.len]/[max_syringes] | Reagents: [reagents.total_volume]/[reagents.maximum_volume]\]<br /><a href='?src=[REF(src)];show_reagents=1'>Reagents list</a>"
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/action(mob/source, atom/movable/target, params)
	if(!action_checks(target))
		return
	if(istype(target, /obj/item/reagent_containers/syringe))
		return load_syringe(target)
	if(istype(target, /obj/item/storage))//Loads syringes from boxes
		for(var/obj/item/reagent_containers/syringe/S in target.contents)
			load_syringe(S, source)
		return
	if(mode)
		return analyze_reagents(target, source)
	if(!syringes.len)
		to_chat(source, "[icon2html(src, source)]<span class=\"alert\">No syringes loaded.</span>")
		return
	if(reagents.total_volume<=0)
		to_chat(source, "[icon2html(src, source)]<span class=\"alert\">No available reagents to load syringe with.</span>")
		return
	if(HAS_TRAIT(source, TRAIT_PACIFISM))
		to_chat(source, "<span class=\"alert\">The [src] is lethally chambered! You don't want to risk harming anyone...</span>")
		return
	var/turf/trg = get_turf(target)
	var/obj/item/reagent_containers/syringe/mechsyringe = syringes[1]
	mechsyringe.forceMove(get_turf(chassis))
	reagents.trans_to(mechsyringe, min(mechsyringe.volume, reagents.total_volume), transfered_by = source)
	syringes -= mechsyringe
	mechsyringe.icon = 'icons/obj/chemical.dmi'
	mechsyringe.icon_state = "syringeproj"
	playsound(chassis, 'sound/items/syringeproj.ogg', 50, 1)
	log_message("Launched [mechsyringe] from [src] by [source], targeting [target].", LOG_MECHA)
	spawn(0) //This code is trash and whoever wrote it should feel bad
		for(var/i=0, i<6, i++)
			if(!mechsyringe)
				break
			if(step_towards(mechsyringe,trg))
				var/list/mobs = new
				for(var/mob/living/carbon/M in mechsyringe.loc)
					mobs += M
				var/mob/living/carbon/M = safepick(mobs)
				if(M)
					var/R
					mechsyringe.visible_message("<span class=\"attack\"> [M] was hit by the syringe!</span>")
					if(M.can_inject(null, 1))
						if(mechsyringe.reagents)
							for(var/datum/reagent/A in mechsyringe.reagents.reagent_list)
								R += "[A.name] ([num2text(A.volume)]"
						mechsyringe.icon_state = initial(mechsyringe.icon_state)
						mechsyringe.icon = initial(mechsyringe.icon)
						mechsyringe.reagents.reaction(M, INJECT)
						mechsyringe.reagents.trans_to(M, mechsyringe.reagents.total_volume, transfered_by = source)
						M.take_bodypart_damage(2)
						log_combat(source, M, "shot", "syringegun")
					break
				else if(mechsyringe.loc == trg)
					mechsyringe.icon_state = initial(mechsyringe.icon_state)
					mechsyringe.icon = initial(mechsyringe.icon)
					mechsyringe.update_icon()
					break
			else
				mechsyringe.icon_state = initial(mechsyringe.icon_state)
				mechsyringe.icon = initial(mechsyringe.icon)
				mechsyringe.update_icon()
				break
			sleep(1)
	return ..()


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Topic(href,href_list)
	..()
	if (href_list["toggle_mode"])
		mode = !mode
		update_equip_info()
		return
	if (href_list["select_reagents"])
		processed_reagents.len = 0
		var/m = 0
		var/message
		for(var/i=1 to known_reagents.len)
			if(m>=synth_speed)
				break
			var/reagent = text2path(href_list["reagent_[i]"])
			if(reagent && (reagent in known_reagents))
				message = "[m ? ", " : null][known_reagents[reagent]]"
				processed_reagents += reagent
				m++
		if(processed_reagents.len)
			message += " added to production"
			START_PROCESSING(SSobj, src)
			to_chat(usr, message)
			to_chat(usr, "[icon2html(src, usr)]<span class='notice'>Reagent processing started.</span>")
			log_message("Reagent processing started.", LOG_MECHA)
		return
	if (href_list["show_reagents"])
		if(!(usr in chassis.occupants))
			return
		usr << browse(get_reagents_page(),"window=msyringegun")
	if (href_list["purge_reagent"])
		var/reagent = href_list["purge_reagent"]
		if(reagent)
			reagents.del_reagent(reagent)
		return
	if (href_list["purge_all"])
		reagents.clear_reagents()
		return
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_page()
	var/output = {"<html>
						<head>
						<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
						<title>Reagent Synthesizer</title>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						</script>
						<style>
						h3 {margin-bottom:2px;font-size:14px;}
						#reagents, #reagents_form {}
						form {width: 90%; margin:10px auto; border:1px dotted #999; padding:6px;}
						#submit {margin-top:5px;}
						</style>
						</head>
						<body>
						<h3>Current reagents:</h3>
						<div id="reagents">
						[get_current_reagents()]
						</div>
						<h3>Reagents production:</h3>
						<div id="reagents_form">
						[get_reagents_form()]
						</div>
						</body>
						</html>
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_form()
	var/r_list = get_reagents_list()
	var/inputs
	if(r_list)
		inputs += "<input type=\"hidden\" name=\"src\" value=\"[REF(src)]\">"
		inputs += "<input type=\"hidden\" name=\"select_reagents\" value=\"1\">"
		inputs += "<input id=\"submit\" type=\"submit\" value=\"Apply settings\">"
	var/output = {"<form action="byond://" method="get">
						[r_list || "No known reagents"]
						[inputs]
						</form>
						[r_list? "<span style=\"font-size:80%;\">Only the first [synth_speed] selected reagent\s will be added to production</span>" : null]
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_list()
	var/output
	for(var/i=1 to known_reagents.len)
		var/reagent_id = known_reagents[i]
		output += {"<input type="checkbox" value="[reagent_id]" name="reagent_[i]" [(reagent_id in processed_reagents)? "checked=\"1\"" : null]> [known_reagents[reagent_id]]<br />"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_current_reagents()
	var/output
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.volume > 0)
			output += "[R]: [round(R.volume,0.001)] - <a href=\"?src=[REF(src)];purge_reagent=[R]\">Purge Reagent</a><br />"
	if(output)
		output += "Total: [round(reagents.total_volume,0.001)]/[reagents.maximum_volume] - <a href=\"?src=[REF(src)];purge_all=1\">Purge All</a>"
	return output || "None"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/load_syringe(obj/item/reagent_containers/syringe/S, mob/user)
	if(syringes.len<max_syringes)
		if(!chassis.Adjacent(S))
			to_chat(user, "[icon2html(src, user)]<span class='warning'>Unable to load syringe!</span>")
			return FALSE
		S.reagents.trans_to(src, S.reagents.total_volume, transfered_by = user)
		S.forceMove(src)
		syringes += S
		to_chat(user, "[icon2html(src, user)]<span class='notice'>Syringe loaded.</span>")
		update_equip_info()
		return 1
	to_chat(user, "[icon2html(src, user)]<span class='warning'>[src]'s syringe chamber is full!</span>")
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/analyze_reagents(atom/A, mob/user)
	if(get_dist(src,A) >= 4)
		to_chat(user, "[icon2html(src, user)]<span class='notice'>The object is too far away!</span>")
		return FALSE
	if(!A.reagents || ismob(A))
		to_chat(user, "[icon2html(src, user)]<span class='warning'>No reagent info gained from [A].</span>")
		return FALSE
	to_chat(user, "[icon2html(src, user)]<span class='notice'>Analyzing reagents...</span>")
	for(var/datum/reagent/R in A.reagents.reagent_list)
		if(!(R.chem_flags & CHEMICAL_NOT_SYNTH) && add_known_reagent(R.type,R.name))
			to_chat(user, "[icon2html(src, user)]<span class='notice'>Reagent analyzed, identified as [R.name] and added to database.</span>")
			send_byjax(chassis.occupants,"msyringegun.browser","reagents_form",get_reagents_form())
	to_chat(user, "[icon2html(src, user)]<span class='notice'>Analysis complete.</span>")
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(!(r_id in known_reagents))
		known_reagents += r_id
		known_reagents[r_id] = r_name
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/update_equip_info()
	if(..())
		send_byjax(chassis.occupants,"msyringegun.browser","reagents",get_current_reagents())
		send_byjax(chassis.occupants,"msyringegun.browser","reagents_form",get_reagents_form())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/on_reagent_change(changetype)
	..()
	update_equip_info()
	return


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/process()
	if(..())
		return
	if(!processed_reagents.len || reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='alert'>Reagent processing stopped.</span>")
		log_message("Reagent processing stopped.", LOG_MECHA)
		STOP_PROCESSING(SSobj, src)
		return
	var/amount = synth_speed / processed_reagents.len
	for(var/reagent in processed_reagents)
		reagents.add_reagent(reagent,amount)
		chassis.use_power(energy_drain)

///////////////////////////////// Medical Beam ///////////////////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	name = "exosuit medical beamgun"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites."
	icon_state = "mecha_medigun"
	energy_drain = 10
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 0
	var/obj/item/gun/medbeam/mech/medigun
	custom_materials = list(/datum/material/iron = 15000, /datum/material/glass = 8000, /datum/material/plasma = 3000, /datum/material/gold = 8000, /datum/material/diamond = 2000)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Initialize(mapload)
	. = ..()
	medigun = new(src)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Destroy()
	qdel(medigun)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/process()
	if(..())
		return
	medigun.process()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/action(mob/source, atom/movable/target, params)
	medigun.process_fire(target, loc)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
