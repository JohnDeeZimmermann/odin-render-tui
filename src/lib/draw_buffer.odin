package ort

import "core:fmt"
import tbx "shared:odin-termbox2"

// Draws the buffer to the screen, as is.
buffer_draw_screen :: proc(buffer: Buffer, app: App) -> (ok: bool = true) {
	area := buffer.area
	for y in 0 ..< area.height {
		for x in 0 ..< area.width {
			cell_idx := int(y * area.width + x)
			if (cell_idx >= len(buffer.content)) {
				fmt.eprintfln(
					"Cell x: %d, y: %d (cell_idx: %d) exceeds buffer size of %d",
					x,
					y,
					cell_idx,
					len(buffer.content),
				)
				return false
			}
			buffer_cell := buffer.content[cell_idx]
			fg_color := _tbx_color_apply_style(
				_tbx_color_from_color(buffer_cell.style.fg_color),
				buffer_cell.style,
			)
			status := tbx.set_cell(
				i32(x),
				i32(y),
				buffer_cell.rune,
				fg_color,
				_tbx_color_from_color(buffer_cell.style.bg_color),
			)
			if status != tbx.Status.Ok {
				fmt.eprintfln(
					"Cell x: %d, y: %d (cell_idx: %d) caused error %d",
					x,
					y,
					cell_idx,
					status,
				)
				return false
			}
		}
	}

	return true
}
