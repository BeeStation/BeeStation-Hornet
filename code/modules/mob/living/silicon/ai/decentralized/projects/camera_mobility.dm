/datum/ai_project/camera_speed
	name = "Optimised Camera Acceleration"
	description = "Using advanced deep learning algorithms you could boost your camera traverse speed."
	research_cost = 500
	ram_required = 1
	research_requirements = "None"
	category = AI_PROJECT_CAMERAS

/datum/ai_project/camera_speed/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.max_camera_sprint *= 2
	ai.sprint *= 2


/datum/ai_project/camera_speed/stop()
	ai.max_camera_sprint *= 0.5
	ai.sprint *= 0.5
	..()
