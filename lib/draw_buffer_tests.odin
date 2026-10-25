package ort

import "core:testing"

@(test)
test_buffer_draw_to_buffer :: proc(t: ^testing.T) {
	target_buffer, ok_tb := create_buffer(area_from(10, 10), context.temp_allocator)
	testing.expect(t, ok_tb)

	source_area := Area {
		width  = 5,
		height = 5,
		x      = 7, // Partially cut off
		y      = 7,
	}
	source_buffer, ok_sb := create_buffer(source_area, context.temp_allocator)
	testing.expect(t, ok_sb)

	// Render a widget
	widget := ParagraphWidget {
		text = "Hello World",
	}
	paragraph_widget_render(widget, &source_buffer, source_buffer.area, context.temp_allocator)

	// Shallow check whether rendering worked
	testing.expect(t, source_buffer.content[0].rune == 'H')

	buffer_draw_to_buffer(source_buffer, &target_buffer)

	testing.expect_value(t, buffer_get_cell(target_buffer, 7, 7).rune, 'H')
	testing.expect_value(t, buffer_get_cell(target_buffer, 8, 7).rune, 'e')
	testing.expect_value(t, buffer_get_cell(target_buffer, 9, 7).rune, 'l')
	testing.expect_value(t, buffer_get_cell(target_buffer, 8, 8).rune, 'W')

	free_all(context.temp_allocator)
}
