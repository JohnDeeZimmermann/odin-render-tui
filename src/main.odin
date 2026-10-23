package main
import "core:fmt"
import vmem "core:mem/virtual"
import "core:time"
import ort "lib"

main :: proc() {
	arena: vmem.Arena
	app := ort.app_create(&arena).?
	defer ort.app_destroy(app)

	buffer, ok := ort.create_screen_buffer(app)
	if !ok {
		fmt.eprintfln("Failed to create buffer")
		return
	}

	paragraph := ort.ParagraphWidget {
		text = "Das ist ein wirklich ganz ganz ganz toller Test Text! Wahnisnn, was da alles geht!",
		style = {
			bg_color = ort.AnsiColor.LightGreen,
			fg_color = ort.AnsiColor.Black,
			padding = {top = 5, left = 30, bottom = 5, right = 30},
			vertical_alignment = .END,
			horizontal_alignment = .END,
		},
	}
	if !ort.paragraph_widget_render(paragraph, &buffer) {
		fmt.eprintfln("Error trying to render widget")
	}
	if !ort.buffer_draw_screen(buffer, app) {
		fmt.eprintfln("Error trying to draw buffer to screen")
	}

	ort.events_set_mouse_enabled(true)
	ort.peek_event(time.Second * 5) // Any input or waiting 5 seconds will quite the app
}
