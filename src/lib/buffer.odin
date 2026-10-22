package ort

import "core:fmt"
import tbx "shared:odin-termbox2"

Position :: struct {
	x: u16,
	y: u16,
}

Dimensions :: struct {
	width:  u16,
	height: u16,
}

Area :: struct {
	using position:   Position,
	using dimensions: Dimensions,
}

Buffer :: struct {
	area:    Area,
	content: [dynamic]Cell,
}

buffer_get_cell_idx :: proc(buffer: Buffer, x: u16, y: u16) -> int {
	area := buffer.area

	assert(x < area.width && y < area.height, "Provided value out of bounds for area.")

	return int(y * area.width + x)
}

create_screen_buffer :: proc() -> Buffer {
	return Buffer{area = {height = u16(tbx.height()), width = u16(tbx.width())}}
}

buffer_initialize_contents :: proc(buffer: ^Buffer) -> (ok: bool) {
	clear(&buffer.content)
	if resize(&buffer.content, buffer.area.width * buffer.area.height) != nil {
		return false
	}
	return true
}
