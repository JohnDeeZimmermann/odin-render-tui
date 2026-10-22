package ort

import "core:testing"
import "core:unicode/utf8"

@(private = "file")
fresh_buffer :: proc() -> Buffer {
	buffer := Buffer {
		area = {height = 10, width = 10},
	}
	buffer_initialize_contents(&buffer, context.temp_allocator)
	return buffer
}

@(test)
test_paragraph_widget_render_simple :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer.content[0].rune, runes[0])
	testing.expect_value(t, buffer.content[2].rune, runes[2])
	testing.expect_value(t, buffer.content[6].rune, runes[6])

	free_all(context.temp_allocator)
}

@(test)
test_paragraph_widget_render_padding :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
		style = {padding = {top = 2, left = 2}},
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer_get_cell(buffer, 2, 2).rune, 'H')
	testing.expect_value(t, buffer_get_cell(buffer, 4, 2).rune, 'l')

	free_all(context.temp_allocator)
}

@(test)
test_paragraph_widget_render_word_wrap :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
		style = {padding = {top = 2, left = 8}},
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer_get_cell(buffer, 8, 2).rune, 'H')
	testing.expect_value(t, buffer_get_cell(buffer, 8, 3).rune, 'l')
	testing.expect_value(t, buffer_get_cell(buffer, 8, 4).rune, 'o')
	testing.expect_value(t, buffer_get_cell(buffer, 8, 5).rune, 'W')

	free_all(context.temp_allocator)
}

@(test)
test_paragraph_widget_render_v_align_end :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
		style = {padding = {top = 2, left = 2, bottom = 2}, vertical_alignment = .END},
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer_get_cell(buffer, 2, 6).rune, 'H')
	testing.expect_value(t, buffer_get_cell(buffer, 3, 7).rune, 'l')

	free_all(context.temp_allocator)
}

@(test)
test_paragraph_widget_render_v_align_center :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
		style = {padding = {top = 3, left = 2, bottom = 2}, vertical_alignment = .CENTER},
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer_get_cell(buffer, 2, 4).rune, 'H')
	testing.expect_value(t, buffer_get_cell(buffer, 3, 5).rune, 'l')

	free_all(context.temp_allocator)
}

@(test)
test_paragraph_widget_render_h_align_end :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
		style = {
			padding = {top = 3, left = 2, bottom = 2, right = 1},
			vertical_alignment = .CENTER,
			horizontal_alignment = .END,
		},
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer_get_cell(buffer, 2, 4).rune, 'H')
	testing.expect_value(t, buffer_get_cell(buffer, 7, 5).rune, 'l')
	testing.expect_value(t, buffer_get_cell(buffer, 8, 5).rune, 'd')

	free_all(context.temp_allocator)
}

@(test)
test_paragraph_widget_render_h_align_center :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
		style = {
			padding = {top = 3, left = 2, bottom = 2, right = 1},
			vertical_alignment = .CENTER,
			horizontal_alignment = .CENTER,
		},
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer_get_cell(buffer, 2, 4).rune, 'H')
	testing.expect_value(t, buffer_get_cell(buffer, 5, 5).rune, 'l')
	testing.expect_value(t, buffer_get_cell(buffer, 6, 5).rune, 'd')

	free_all(context.temp_allocator)
}

@(test)
test_paragraph_widget_render_colors_applied :: proc(t: ^testing.T) {
	text := "Hello World"
	runes := utf8.string_to_runes(text, context.temp_allocator)

	buffer := fresh_buffer()

	widget := ParagraphWidget {
		text = text,
		style = {
			padding = {top = 3, left = 2, bottom = 2, right = 1},
			vertical_alignment = .CENTER,
			horizontal_alignment = .CENTER,
			bg_color = AnsiColor.White,
			fg_color = AnsiColor.Black,
			bold = true,
		},
	}

	paragraph_widget_render(widget, &buffer, context.temp_allocator)

	testing.expect_value(t, buffer_get_cell(buffer, 2, 4).rune, 'H')
	testing.expect_value(t, buffer_get_cell(buffer, 5, 5).rune, 'l')
	testing.expect_value(t, buffer_get_cell(buffer, 6, 5).rune, 'd')
	testing.expect_value(t, buffer_get_cell(buffer, 2, 4).style.fg_color, AnsiColor.Black)
	testing.expect_value(t, buffer_get_cell(buffer, 5, 5).style.bg_color, AnsiColor.White)
	testing.expect_value(t, buffer_get_cell(buffer, 6, 5).style.bold, true)
	testing.expect_value(t, buffer_get_cell(buffer, 6, 5).style.italic, false)

	free_all(context.temp_allocator)
}
