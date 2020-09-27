/*
Blueshield
*/

/datum/job/blueshield
  title = "Blueshield"
  flag = BLUESHIELD
  department_flag = CIVILIAN
  faction = "Station"
  total_positions = 1
  spawn_positions = 1
  supervisors = "captain and command personnel"
  selection_color = "#ddddff"
  req_admin_notify = 1
  minimal_player_age = 14

  outfit = /datum/outfit/job/blueshield

  access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_WEAPONS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			         	ACCESS_RESEARCH, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_BLUESHIELD)
  minimal_access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_SEC_DOORS, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS,
                  ACCESS_RESEARCH, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_HEADS, ACCESS_BLUESHIELD, ACCESS_WEAPONS)

/datum/outfit/job/blueshield
  name = "Blueshield"
  jobtype = /datum/job/blueshield

  id = /obj/item/card/id/silver
  uniform = /obj/item/clothing/under/rank/blueshield
  gloves = /obj/item/clothing/gloves/combat
  shoes = /obj/item/clothing/shoes/jackboots
  ears = /obj/item/device/radio/headset/heads/blueshield/alt
  glasses = /obj/item/clothing/glasses/hud/health/sunglasses
  belt = /obj/item/device/pda/blueshield

  implants = list(/obj/item/implant/mindshield)

  backpack = /obj/item/storage/backpack/security
  satchel = /obj/item/storage/backpack/satchel/sec
  duffelbag = /obj/item/storage/backpack/duffelbag/sec

  backpack_contents = list(
    /obj/item/gun/energy/e_gun/blueshield = 1
  )
