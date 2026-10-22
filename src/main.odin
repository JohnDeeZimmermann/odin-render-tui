package main
import "core:fmt"
import vmem "core:mem/virtual"
import ort "lib"

main :: proc() {
	arena: vmem.Arena
	app := ort.app_create(&arena).?
	defer ort.app_destroy(app)

	buffer := ort.create_screen_buffer()
	ort.buffer_initialize_contents(&buffer)

	// fmt.printfln(
	// 	"Initialized buffer with width %d and height %d",
	// 	buffer.area.width,
	// 	buffer.area.height,
	// )

	paragraph := ort.ParagraphWidget {
		text = "Das ist ein wirklich ganz ganz ganz toller Test Text! Wahnisnn, was da alles geht!",
		style = {
			bg_color = ort.AnsiColor.White,
			fg_color = ort.AnsiColor.Black,
			padding = {top = 5, left = 20, bottom = 10},
			vertical_alignment = .END,
			horizontal_alignment = .CENTER,
		},
	}
	if !ort.paragraph_widget_render(paragraph, &buffer) {
		fmt.eprintfln("Error trying to render widget")
	}
	if !ort.buffer_draw_screen(buffer, app) {
		fmt.eprintfln("Error trying to draw buffer to screen")
	}

	ort.app_wait(&app)
}
