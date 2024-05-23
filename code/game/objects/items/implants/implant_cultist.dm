/obj/item/implant/cultist
	name = "Ancient Blood"
	desc = "With the ancient blood of the blood God shall you preform his miracles!"
	activated = 0

/obj/item/implanter/cultist
	name = "implanter (Ancient Blood)"
	imp_type = /obj/item/implant/exile

/obj/item/implantcase/cutlist
	name = "implant case - 'Ancient Blood'"
	desc = "A glass case containing the Ancient Blood implant."
	imp_type = /obj/item/implant/cultist

/obj/item/implant/cultist/on_implanted(mob/user)
	var/datum/antagonist/cultist/cult_antag = mob.mind.add_antag_datum(/datum/antagonist/cultist)
	cult_antag.equip_cultist()
	if(!QDELETED(src))
		qdel(src)
