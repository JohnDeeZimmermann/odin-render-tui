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

area_from :: proc(width: u16, height: u16) -> Area {
	return Area{width = width, height = height}
}

area_subtract_in_direction :: proc(base: Area, other: Area, direction: Direction) -> Area {}

buffer_get_cell_idx :: proc(buffer: Buffer, x: u16, y: u16) -> int {
	area := buffer.area

	assert(x < area.width && y < area.height, "Provided value out of bounds for area.")

	return int(y * area.width + x)
}

buffer_get_cell :: proc(buffer: Buffer, x: u16, y: u16) -> Cell {
	idx := buffer_get_cell_idx(buffer, x, y)
	return buffer.content[idx]
}

create_screen_buffer :: proc(allocator := context.allocator) -> (buffer: Buffer, ok: bool) {
	area := Area {
		width  = u16(tbx.width()),
		height = u16(tbx.height()),
	}
	return create_buffer(area, allocator)
}

create_buffer :: proc(area: Area, allocator := context.allocator) -> (buffer: Buffer, ok: bool) {
	buffer = Buffer {
		area = area,
	}
	if !buffer_reset(&buffer, allocator) {
		return buffer, false
	}

	return buffer, true
}

buffer_reset :: proc(buffer: ^Buffer, allocator := context.allocator) -> (ok: bool) {
	size := buffer.area.width * buffer.area.height

	if (buffer.content == nil) {
		content, err := make([dynamic]Cell, size, allocator)
		if err != nil {
			fmt.eprintfln("Error allocating buffer memory")
			return false
		}
		buffer.content = content
		return true
	}

	clear(&buffer.content)
	if resize(&buffer.content, size) != nil {
		return false
	}
	return true
}
