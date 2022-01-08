function toggle_head(source, ext) {
    document.getElementById(source.id.slice(0, -4) + ext).checked = source.checked;
}

function toggle_checkboxes(source, ext) {
    var checkboxes = document.getElementsByClassName(source.name);
    for (var i = 0, n = checkboxes.length; i < n; i++) {
        checkboxes[i].checked = source.checked;
        if (checkboxes[i].id) {
            var idfound = document.getElementById(checkboxes[i].id.slice(0, -4) + ext);
            if (idfound) {
                idfound.checked = source.checked;
            }
        }
    }
}

function suppression_lock(activator) {
	var state = activator.checked
	var restricted_elements = document.getElementsByClassName("redact_incompatible")
	for (var i=0, n = restricted_elements.length; i < n; i++) {
		restricted_elements[i].checked = false;
		restricted_elements[i].disabled = state;
	}
	if(!state) {
		return;
	}
	var force_enabled = document.getElementsByClassName("redact_force_checked");
	for (var i=0, n = force_enabled.length; i < n; i++) {
		force_enabled[i].checked = true;
	}
}
