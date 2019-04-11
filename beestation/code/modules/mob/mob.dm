/mob/Stat()
    . = ..()
    winset(src, "current-map", "text = 'Map: [SSmapping.config?.map_name || "Loading..."]'")