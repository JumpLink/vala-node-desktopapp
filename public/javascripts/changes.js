function switch_fullscreen() {
	var state = $("#FullscreenButton").attr("active");
	//console.log("ausgelöst");
	if (state == "true") {
		//console.log("restore");
		$("#FullscreenButton > img").attr("src", "./images/icons/Actions/view-fullscreen-symbolic.png");
		$("#FullscreenButton > span").html("<br>Fullscreen");
		$("#FullscreenButton").attr("active", "false");
		goUnFullscreen();
	} else {
		//console.log("fullscreen");
		$("#FullscreenButton > img").attr("src", "./images/icons/Actions/view-restore-symbolic.png");
		$("#FullscreenButton > span").html("<br>Restore");
		$("#FullscreenButton").attr("active", "true");
		goFullscreen()
	}
}