// Registry modes and optional resource families use these manifest keys.
#define BRANDISH_MODE_ROTATE "surface"
#define BRANDISH_MODE_SMOOTH "smooth"
#define BRANDISH_MODE_CORNER "corner"
#define BRANDISH_MODE_GROUP_ROTATE "world"
#define BRANDISH_MODE_CONNECTED "fixed_surface"
#define BRANDISH_MODE_BASIS "basis"
#define BRANDISH_ASSET_FOOTPRINT "footprint"
#define BRANDISH_ASSET_VIEW_GATES "viewGates"
#define BRANDISH_ASSET_FOREGROUND "foreground"

#define BRANDISH_EFFECT_VIEW 1
#define BRANDISH_EFFECT_WORLD_X 2
#define BRANDISH_EFFECT_WORLD_Y 3
#define BRANDISH_EFFECT_LOCAL_ONLY 4
#define BRANDISH_EFFECT_SCREEN_X 5
#define BRANDISH_EFFECT_SCREEN_Y 6

#define BRANDISH_RESULT_VIEW 1
#define BRANDISH_RESULT_WORLD_X 2
#define BRANDISH_RESULT_WORLD_Y 3
#define BRANDISH_RESULT_SCREEN_X 4
#define BRANDISH_RESULT_SCREEN_Y 5

#define COMSIG_GLOB_BRANDISH_PERSPECTIVE_CHANGED "glob_brandish_perspective_changed"

// Legacy corner states use d-* or one-character slot prefixes. Inline for hot overlays.
#define BRANDISH_IS_CORNER_STATE(state) (findtext(state, "d-") == 1 || (length(state) > 2 && copytext(state, 2, 3) == "-"))

// Share native bounds math without per-view calls or temporary coordinate lists.
#define APPLY_BRANDISH_BOUNDS_OFFSET(x_offset, y_offset, footprint, facing) \
	switch(facing) { \
		if(EAST) { \
			x_offset += footprint.bound_height - ICON_SIZE_Y + footprint.bound_x + footprint.bound_y; \
			y_offset += -footprint.bound_x + footprint.bound_y; \
		} \
		if(SOUTH) { \
			x_offset += footprint.bound_width - ICON_SIZE_X + 2 * footprint.bound_x; \
			y_offset += footprint.bound_height - ICON_SIZE_Y + 2 * footprint.bound_y; \
		} \
		if(WEST) { \
			x_offset += footprint.bound_x - footprint.bound_y; \
			y_offset += footprint.bound_width - ICON_SIZE_X + footprint.bound_x + footprint.bound_y; \
		} \
	}
