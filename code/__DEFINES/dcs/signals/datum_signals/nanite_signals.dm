// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

//Nanites
#define COMSIG_HAS_NANITES "has_nanites"						//() returns TRUE if nanites are found
#define COMSIG_NANITE_IS_STEALTHY "nanite_is_stealthy"			//() returns TRUE if nanites have stealth
#define COMSIG_NANITE_DELETE "nanite_delete"					//() deletes the nanite component
#define COMSIG_NANITE_GET_PROGRAMS	"nanite_get_programs"		//(list/nanite_programs) - makes the input list a copy the nanites' program list
#define COMSIG_NANITE_GET_VOLUME "nanite_get_volume"			//(amount) Returns nanite amount
#define COMSIG_NANITE_SET_VOLUME "nanite_set_volume"			//(amount) Sets current nanite volume to the given amount
#define COMSIG_NANITE_ADJUST_VOLUME "nanite_adjust"				//(amount) Adjusts nanite volume by the given amount
#define COMSIG_NANITE_SET_MAX_VOLUME "nanite_set_max_volume"	//(amount) Sets maximum nanite volume to the given amount
#define COMSIG_NANITE_SET_CLOUD "nanite_set_cloud"				//(amount(0-100)) Sets cloud ID to the given amount
#define COMSIG_NANITE_SET_CLOUD_SYNC "nanite_set_cloud_sync"	//(method) Modify cloud sync status. Method can be toggle, enable or disable
#define COMSIG_NANITE_SET_SAFETY "nanite_set_safety"			//(amount) Sets safety threshold to the given amount
#define COMSIG_NANITE_SET_REGEN "nanite_set_regen"				//(amount) Sets regeneration rate to the given amount
#define COMSIG_NANITE_SIGNAL "nanite_signal"					//(code(1-9999)) Called when sending a nanite signal to a mob.
#define COMSIG_NANITE_COMM_SIGNAL "nanite_comm_signal"			//(comm_code(1-9999), comm_message) Called when sending a nanite comm signal to a mob.
#define COMSIG_NANITE_SCAN "nanite_scan"						//(mob/user, full_scan) - sends to chat a scan of the nanites to the user, returns TRUE if nanites are detected
#define COMSIG_NANITE_UI_DATA "nanite_ui_data"					//(list/data, scan_level) - adds nanite data to the given data list - made for ui_data procs
#define COMSIG_NANITE_ADD_PROGRAM "nanite_add_program"			//(datum/nanite_program/new_program, datum/nanite_program/source_program) Called when adding a program to a nanite component
	#define COMPONENT_PROGRAM_INSTALLED		1					//Installation successful
	#define COMPONENT_PROGRAM_NOT_INSTALLED		2				//Installation failed, but there are still nanites
#define COMSIG_NANITE_SYNC "nanite_sync"						//(datum/component/nanites, full_overwrite, copy_activation) Called to sync the target's nanites to a given nanite component
