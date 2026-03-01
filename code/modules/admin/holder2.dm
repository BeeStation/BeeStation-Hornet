GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

/datum/admins
	var/datum/admin_rank/rank

	var/target
	var/name = "nobody's admin datum (no rank)" //Makes for better runtimes
	var/client/owner	= null
	var/fakekey			= null

	var/datum/marked_datum

	var/spamcooldown = 0

	///Randomly generated signature used for security records authorization name.
	var/admin_signature

	var/href_token

	var/deadmined

	var/ooc_confirmation_enabled = TRUE

	//Admin help manager
	var/datum/help_ui/admin/admin_interface

	var/datum/filter_editor/filteriffic
	var/datum/particle_editor/particool

	var/datum/pathfind_debug/path_debug

	/// Player panel
	var/datum/admin_player_panel/player_panel

	/// Banning Panel
	var/datum/admin_ban_panel/ban_panel

	/// A lazylist of tagged datums, for quick reference with the View Tags verb
	var/list/tagged_datums

/datum/admins/New(datum/admin_rank/R, ckey, force_active = FALSE, protected)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if (!target) //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return
	if(!ckey)
		QDEL_IN(src, 0)
		CRASH("Admin datum created without a ckey")
	if(!istype(R))
		QDEL_IN(src, 0)
		CRASH("Admin datum created without a rank")
	target = ckey
	name = "[ckey]'s admin datum ([R])"
	rank = R
	admin_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	href_token = GenerateToken()
	if(R.rights & R_DEBUG) //grant profile access
		world.SetConfig("APP/admin", ckey, "role=admin")
	//only admins with +ADMIN start admined
	if(protected)
		GLOB.protected_admins[target] = src
	if (force_active || (R.rights & R_AUTOADMIN))
		activate()
	else
		deactivate()

/datum/admins/Destroy()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE
	QDEL_NULL(path_debug)
	return ..()

/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	deadmined = FALSE
	if (GLOB.directory[target])
		associate(GLOB.directory[target])	//find the client for a ckey if they are connected and associate them with us
	load_mentors()

/datum/admins/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins[target] = src
	GLOB.admin_datums -= target
	QDEL_NULL(path_debug)
	deadmined = TRUE
	var/client/C
	if ((C = owner) || (C = GLOB.directory[target]))
		disassociate()
		C.add_verb(/client/proc/readmin)
		C.update_special_keybinds()
	load_mentors()

/datum/admins/proc/associate(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(istype(C))
		if(C.ckey != target)
			var/msg = " has attempted to associate with [target]'s admin datum"
			message_admins("[key_name_admin(C)][msg]")
			log_admin("[key_name(C)][msg]")
			return
		if (deadmined)
			activate()
		owner = C
		owner.holder = src
		owner.add_admin_verbs()	//TODO <--- todo what? the proc clearly exists and works since its the backbone to our entire admin system
		owner.remove_verb(/client/proc/readmin)
		owner.update_special_keybinds()
		if(rank.rights & R_DEBUG)
			winset(owner, "menudebug", "parent=\"menu\";name=\"&Debug\";command=\"\"")
			winset(owner, "menuoptions", "parent=\"menu\";name=\"&Options and Messages\";command=\".options\";category=\"&Debug\"")
			winset(owner, "menuprofiler", "parent=\"menu\";name=\"&Profiler\";command=\".profile\";category=\"&Debug\"")
		GLOB.admins |= C

/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(owner)
		if((rank.rights & R_DEBUG) && length(winexists(owner, "menudebug")))
			winset(owner, "menudebug", "parent=")
		GLOB.admins -= owner
		owner.remove_admin_verbs()
		owner.holder = null
		owner = null

/datum/admins/proc/check_for_rights(rights_required)
	if(rights_required && !(rights_required & rank.rights))
		return 0
	return 1


/datum/admins/proc/check_if_greater_rights_than_holder(datum/admins/other)
	if(!other)
		return 1 //they have no rights
	if(rank.rights == R_EVERYTHING)
		return 1 //we have all the rights
	if(src == other)
		return 1 //you always have more rights than yourself
	if(rank.rights != other.rank.rights)
		if( (rank.rights & other.rank.rights) == other.rank.rights )
			return 1 //we have all the rights they have and more
	return 0

/datum/admins/vv_edit_var(var_name, var_value)
	return FALSE //nice try trialmin

/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.
if it doesn't return 1 and show_msg=1 it will prints a message explaining why the check has failed
generally it would be used like so:

/proc/admin_proc()
	if(!check_rights(R_ADMIN))
		return
	to_chat(world, "you have enough rights!")

NOTE: it checks usr! not src! So if you're checking somebody's rank in a proc which they did not call
you will have to do something like if(client.rights & R_ADMIN) yourself.
*/
/proc/check_rights(rights_required, show_msg=1)
	if(usr?.client)
		if (check_rights_for(usr.client, rights_required))
			return 1
		else
			if(show_msg)
				to_chat(usr, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>")
	return 0

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr?.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return 1
			return usr.client.holder.check_if_greater_rights_than_holder(other.holder)
	return 0

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	if(subject && subject.holder)
		return subject.holder.check_for_rights(rights_required)
	return 0

/proc/GenerateToken()
	. = ""
	for(var/I in 1 to 32)
		. += "[rand(10)]"

/proc/RawHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/admins/holder = C.holder
		if(holder)
			tok = holder.href_token
	return tok

/proc/HrefToken(forceGlobal = FALSE)
	return "admin_token=[RawHrefToken(forceGlobal)]"

/proc/HrefTokenFormField(forceGlobal = FALSE)
	return "<input type='hidden' name='admin_token' value='[RawHrefToken(forceGlobal)]'>"
