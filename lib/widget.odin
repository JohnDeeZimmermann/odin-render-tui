package ort

import "core:strings"

widget_render_any :: proc(
	widget: Widget,
	area: Area,
	buffer: ^Buffer,
	allocator := context.allocator,
) -> (
	ok: bool,
) {
	switch w in widget {
	case ParagraphWidget:
		return paragraph_widget_render(w, buffer, area, allocator)
	case ContainerWidget:
		return container_widget_render(w, buffer, area, allocator)
	}

	return true
}

widget_render :: proc {
	widget_render_any,
	paragraph_widget_render,
	container_widget_render,
}

Widget :: union {
	ParagraphWidget,
	ContainerWidget,
}
