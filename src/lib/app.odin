package ort

import "core:mem"
import vmem "core:mem/virtual"
import tbx "shared:odin-termbox2"

App :: struct {
	allocator: mem.Allocator,
}

// Creates the app struct and initializes terminal rendering
app_create :: proc(arena: ^vmem.Arena) -> Maybe(App) {
	status := tbx.init()
	if status != tbx.Status.Ok {
		return nil
	}

	allocator := vmem.arena_allocator(arena)

	return App{allocator = allocator}
}

app_destroy :: proc(app: App) {
	free_all(app.allocator)
	tbx.shutdown()
}

app_wait :: proc(app: ^App) {
	ev := tbx.Event{}
	tbx.poll_event(&ev)
}
