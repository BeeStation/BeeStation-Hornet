/// Global assoc list. [ckey] = [spellbook entry type]
GLOBAL_LIST_EMPTY(wizard_spellbook_purchases_by_key)

/datum/antagonist/wizard
	name = "Space Wizard"
	roundend_category = "wizards/witches"
	antagpanel_category = "Wizard"
	banning_key = ROLE_WIZARD
	required_living_playtime = 8
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	ui_name = "AntagInfoWizard"
	leave_behaviour = ANTAGONIST_LEAVE_KEEP
	var/strip = TRUE //strip before equipping
	var/allow_rename = TRUE
	var/hud_version = "wizard"
	var/datum/team/wizard/wiz_team //Only created if wizard summons apprentices
	var/move_to_lair = TRUE
	var/outfit_type = /datum/outfit/wizard
	var/wiz_age = WIZARD_AGE_MIN /* Wizards by nature cannot be too young. */
	show_to_ghosts = TRUE

/datum/antagonist/wizard/on_gain()
	equip_wizard()
	if(give_objectives)
		create_objectives()
	if(move_to_lair)
		send_to_lair()
	. = ..()
	if(allow_rename)
		rename_wizard()
	owner.remove_all_quirks()

/datum/antagonist/wizard/get_antag_name() // wizards are not in the same team
	return "Space Wizard [owner.name]"

/datum/antagonist/wizard/create_team(datum/team/wizard/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	wiz_team = new_team

/datum/antagonist/wizard/get_team()
	return wiz_team

/datum/team/wizard
	name = "wizard team"
	var/datum/antagonist/wizard/master_wizard

/datum/antagonist/wizard/proc/create_wiz_team()
	var/static/count = 0
	wiz_team = new(owner)
	wiz_team.name = "Wizard team No.[++count]" // it will be only displayed to admins
	wiz_team.master_wizard = src
	update_wiz_icons_added(owner.current)

/datum/antagonist/wizard/proc/send_to_lair()
	if(!owner || !owner.current)
		return
	if(!GLOB.wizardstart.len)
		SSjob.SendToLateJoin(owner.current)
		to_chat(owner, "HOT INSERTION, GO GO GO")
	owner.current.forceMove(pick(GLOB.wizardstart))

/datum/team/wizard/get_team_name() // team name is based on the master wizard's current form
	var/mind_name = master_wizard.owner.name
	var/mob_name = master_wizard.owner?.current.real_name
	if(mind_name == mob_name)
		return "Spece Wizard [mind_name]"
	return "Space Wizard [mind_name] in [mob_name]" // tells which one is the real master

/datum/antagonist/wizard/proc/create_objectives()
	if(!give_objectives)
		return
	switch(rand(1,100))
		if(1 to 30)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
			log_objective(owner, kill_objective.explanation_text)

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective
				log_objective(owner, escape_objective.explanation_text)

		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective
			log_objective(owner, steal_objective.explanation_text)

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective
				log_objective(owner, escape_objective.explanation_text)

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
			log_objective(owner, kill_objective.explanation_text)

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective
			log_objective(owner, steal_objective.explanation_text)

			if (!(locate(/datum/objective/survive) in objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = owner
				objectives += survive_objective
				log_objective(owner, survive_objective.explanation_text)

		else
			if (!(locate(/datum/objective/hijack) in objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = owner
				objectives += hijack_objective
				log_objective(owner, hijack_objective.explanation_text)

/datum/antagonist/wizard/on_removal()
	// Currently removes all spells regardless of innate or not. Could be improved.
	for(var/datum/action/spell/spell in owner.current.actions)
		if(spell.owner == owner)
			qdel(spell)
			owner.current.actions -= spell
	return ..()

/datum/antagonist/wizard/proc/equip_wizard()
	if(!owner)
		return
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(strip)
		H.delete_equipment()
	//Wizards are human by default. Use the mirror if you want something else.
	H.set_species(/datum/species/human)
	if(H.age < wiz_age)
		H.age = wiz_age
	H.equipOutfit(outfit_type)
	var/datum/action/spell/new_spell = new /datum/action/spell/teleport/area_teleport/wizard(owner)
	new_spell.Grant(owner.current)

/datum/antagonist/wizard/greet()
	to_chat(owner, span_boldannounce("You are the Space Wizard!"))
	to_chat(owner, "<B>The Space Wizards Federation has given you the following tasks:</B>")
	owner.announce_objectives()
	to_chat(owner, "You will find a list of available spells in your spell book. Choose your magic arsenal carefully.")
	to_chat(owner, "The spellbook is bound to you, and others cannot use it.")
	to_chat(owner, "In your pockets you will find a teleport scroll. Use it as needed.")
	to_chat(owner,"<B>Remember:</B> Do not forget to prepare your spells.")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Space Wizard",
		"Prepare your spells and cause havok upon the accursed station.")

/datum/antagonist/wizard/farewell()
	to_chat(owner, span_userdanger("You have been brainwashed! You are no longer a wizard!"))

/datum/antagonist/wizard/proc/rename_wizard()
	set waitfor = FALSE

	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/mob/living/wiz_mob = owner.current
	var/newname = sanitize_name(reject_bad_text(stripped_input(wiz_mob, "You are the [name]. Would you like to change your name to something else?", "Name change", randomname, MAX_NAME_LEN)))

	if (!newname)
		newname = randomname

	wiz_mob.fully_replace_character_name(wiz_mob.real_name, newname)

/datum/antagonist/wizard/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_wiz_icons_added(M, wiz_team ? TRUE : FALSE) //Don't bother showing the icon if you're solo wizard
	M.faction |= FACTION_WIZARD

/datum/antagonist/wizard/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_wiz_icons_removed(M)
	M.faction -= FACTION_WIZARD


/datum/antagonist/wizard/get_admin_commands()
	. = ..()
	.["Send to Lair"] = CALLBACK(src,PROC_REF(admin_send_to_lair))

/datum/antagonist/wizard/proc/admin_send_to_lair(mob/admin)
	owner.current.forceMove(pick(GLOB.wizardstart))

/datum/antagonist/wizard/apprentice
	name = "Wizard Apprentice"
	hud_version = "apprentice"
	var/datum/mind/master
	var/school = APPRENTICE_DESTRUCTION
	outfit_type = /datum/outfit/wizard/apprentice
	wiz_age = APPRENTICE_AGE_MIN

/datum/antagonist/wizard/apprentice/greet()
	to_chat(owner, "<B>You are [master.current.real_name]'s apprentice! You are bound by magic contract to follow [master.p_their()] orders and help [master.p_them()] in accomplishing [master.p_their()] goals.")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/equip_wizard()
	. = ..()
	if(!owner)
		return
	if(!ishuman(owner.current))
		return
	var/list/spells_to_grant = list()
	var/list/items_to_grant = list()
	switch(school)
		if(APPRENTICE_DESTRUCTION)
			spells_to_grant = list(
				/datum/action/spell/teleport/area_teleport/wizard/apprentice,
				/datum/action/spell/aoe/magic_missile,
				/datum/action/spell/pointed/projectile/fireball,
			)
			to_chat(owner, ("<span class='bold'>Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned powerful, \
				destructive spells. You are able to cast magic missile and fireball.</span>"))

		if(APPRENTICE_BLUESPACE)
			spells_to_grant = list(
				/datum/action/spell/teleport/area_teleport/wizard,
				/datum/action/spell/jaunt/ethereal_jaunt,
			)
			items_to_grant = list(
				/obj/item/gun/magic/wand/teleport,
			)
			to_chat(owner, ("<span class='bold'>Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned reality-bending \
				mobility spells. You are able to cast teleport and ethereal jaunt, and have a wand of teleportation.</span>"))

		if(APPRENTICE_HEALING)
			spells_to_grant = list(
				/datum/action/spell/teleport/area_teleport/wizard/apprentice,
				/datum/action/spell/charge,
				/datum/action/spell/forcewall,
			)
			items_to_grant = list(
				/obj/item/gun/magic/wand/healing,
			)
			to_chat(owner, ("<span class='bold'>Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned life-saving \
				survival spells. You are able to cast charge and forcewall, and have a wand of healing.</span>"))

		if(APPRENTICE_ROBELESS)
			spells_to_grant = list(
				/datum/action/spell/teleport/area_teleport/wizard/apprentice,
				/datum/action/spell/aoe/knock,
				/datum/action/spell/pointed/mind_transfer,
			)
			to_chat(owner, ("<span class='bold'>Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned stealthy, \
				robeless spells. You are able to cast knock and mindswap.</span>"))
		if(APPRENTICE_WILDMAGIC)
			var/static/list/spell_entry
			if(!spell_entry)
				spell_entry = list()
				for(var/datum/spellbook_entry/each_entry as() in subtypesof(/datum/spellbook_entry) - typesof(/datum/spellbook_entry/item) - typesof(/datum/spellbook_entry/summon))
					spell_entry += new each_entry

			var/spells_left = 2
			while(spells_left)
				var/failsafe = FALSE
				var/datum/spellbook_entry/chosen_spell = pick(spell_entry)
				if(chosen_spell.no_random)
					continue
				for(var/spell in owner.current.actions)
					if(chosen_spell == spell) // You don't learn the same spell
						failsafe = TRUE
						break
					if(is_type_in_typecache(spell, chosen_spell.no_coexistance_typecache)) // You don't learn a spell that isn't compatible with another
						failsafe = TRUE
						break
				if(failsafe)
					continue
				var/new_spell = chosen_spell.spell_type
				spells_to_grant += new_spell
				spells_left--
			to_chat(owner, span_bold("Your service has not gone unrewarded, however. Studying under [master.current.real_name], you have learned special spells that aren't available to standard apprentices."))

	for(var/spell_type in spells_to_grant)
		var/datum/action/spell/new_spell = new spell_type(owner)
		new_spell.Grant(owner.current)

	for(var/item_type in items_to_grant)
		var/obj/item/new_item = new item_type(owner.current)
		owner.current.put_in_hands(new_item)

/datum/antagonist/wizard/apprentice/create_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = owner
	new_objective.set_target(master)
	new_objective.explanation_text = "Protect [master.current.real_name], the wizard."
	objectives += new_objective
	log_objective(owner, new_objective.explanation_text)

//Random event wizard
/datum/antagonist/wizard/apprentice/imposter
	name = "Wizard Imposter"
	allow_rename = FALSE
	move_to_lair = FALSE
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/wizard/apprentice/imposter/greet()
	to_chat(owner, "<B>You are an imposter! Trick and confuse the crew to misdirect malice from your handsome original!</B>")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/imposter/equip_wizard()
	var/mob/living/carbon/human/master_mob = master.current
	var/mob/living/carbon/human/H = owner.current
	if(!istype(master_mob) || !istype(H))
		return
	if(master_mob.ears)
		H.equip_to_slot_or_del(new master_mob.ears.type, ITEM_SLOT_EARS)
	if(master_mob.w_uniform)
		H.equip_to_slot_or_del(new master_mob.w_uniform.type, ITEM_SLOT_ICLOTHING)
	if(master_mob.shoes)
		H.equip_to_slot_or_del(new master_mob.shoes.type, ITEM_SLOT_FEET)
	if(master_mob.wear_suit)
		H.equip_to_slot_or_del(new master_mob.wear_suit.type, ITEM_SLOT_OCLOTHING)
	if(master_mob.head)
		H.equip_to_slot_or_del(new master_mob.head.type, ITEM_SLOT_HEAD)
	if(master_mob.back)
		H.equip_to_slot_or_del(new master_mob.back.type, ITEM_SLOT_BACK)

	//Operation: Fuck off and scare people
	var/datum/action/spell/jaunt/ethereal_jaunt/jaunt = new(owner)
	jaunt.Grant(H)
	var/datum/action/spell/teleport/area_teleport/wizard/teleport = new(owner)
	teleport.Grant(H)
	var/datum/action/spell/teleport/radius_turf/blink/blink = new(owner)
	blink.Grant(H)

/datum/antagonist/wizard/proc/update_wiz_icons_added(mob/living/wiz,join = TRUE)
	var/datum/atom_hud/antag/wizhud = GLOB.huds[ANTAG_HUD_WIZ]
	wizhud.join_hud(wiz)
	set_antag_hud(wiz, hud_version)

/datum/antagonist/wizard/proc/update_wiz_icons_removed(mob/living/wiz)
	var/datum/atom_hud/antag/wizhud = GLOB.huds[ANTAG_HUD_WIZ]
	wizhud.leave_hud(wiz)
	set_antag_hud(wiz, null)


/datum/antagonist/wizard/academy
	name = "Academy Teacher"
	outfit_type = /datum/outfit/wizard
	move_to_lair = FALSE
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/wizard/academy/equip_wizard()
	. = ..()
	if(!isliving(owner.current))
		return
	var/mob/living/living_current = owner.current

	var/datum/action/spell/jaunt/ethereal_jaunt/jaunt = new(owner)
	jaunt.Grant(living_current)
	var/datum/action/spell/aoe/magic_missile/missile = new(owner)
	missile.Grant(living_current)
	var/datum/action/spell/pointed/projectile/fireball/fireball = new(owner)
	fireball.Grant(living_current)

	var/obj/item/implant/exile/exiled = new /obj/item/implant/exile(living_current)
	exiled.implant(living_current)

/datum/antagonist/wizard/academy/create_objectives()
	var/datum/objective/new_objective = new("Protect Wizard Academy from the intruders")
	new_objective.owner = owner
	objectives += new_objective
	log_objective(owner, new_objective.explanation_text)

//Solo wizard report
/datum/antagonist/wizard/roundend_report()
	var/list/parts = list()

	parts += printplayer(owner)

	var/count = 1
	var/wizardwin = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Objective #[count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			parts += "<B>Objective #[count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
			wizardwin = 0
		count++

	if(wizardwin)
		parts += span_greentext("The wizard was successful!")
	else
		parts += span_redtext("The wizard has failed!")

	var/list/purchases = list()
	for(var/list/log as anything in GLOB.wizard_spellbook_purchases_by_key[owner.key])
		var/datum/spellbook_entry/bought = log[LOG_SPELL_TYPE]
		var/amount = log[LOG_SPELL_AMOUNT]

		purchases += "[amount > 1 ? "[amount]x ":""][initial(bought.name)]"

	if(length(purchases))
		parts += ("<span class='bold'>[owner.name] used the following spells:</span>")
		parts += purchases.Join(", ")
	else
		parts += ("<span class='bold'>[owner.name] didn't buy any spells!</span>")

	return parts.Join("<br>")

//Wizard with apprentices report
/datum/team/wizard/roundend_report()
	var/list/parts = list()

	parts += span_header("Wizards/witches of [master_wizard.owner.name] team were:")
	parts += master_wizard.roundend_report()
	parts += " "
	parts += span_header("[master_wizard.owner.name] apprentices were:")
	parts += printplayerlist(members - master_wizard.owner)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
