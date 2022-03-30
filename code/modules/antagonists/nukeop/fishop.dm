
/datum/antagonist/nukeop/fishop
	name = "Fish Operative"
	roundend_category = "fish operatives"
	antagpanel_category = "FishOp"
	nukeop_outfit = /datum/outfit/fishop

/datum/antagonist/nukeop/fishop/leader
	name = "Fish Operative Leader"
	roundend_category = "fish operatives"
	antagpanel_category = "FishOp"
	nukeop_outfit = /datum/outfit/fishop/leader

/datum/antagonist/nukeop/fishop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = "Fish Operative"
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has clown op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has clown op'ed [key_name(new_owner)].")
