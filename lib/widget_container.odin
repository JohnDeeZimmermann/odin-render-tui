package ort

import "core:math"
ContainerWidgetStyle :: struct {
	layout_direction: Direction,
	bg_color:         Maybe(Color),
	padding:          Padding,
}

ContainerWidget :: struct {
	style:             ContainerWidgetStyle,
	children:          []Widget,
	widget_dimensions: WidgetDimensions,
}

container_widget_render :: proc(
	widget: ContainerWidget,
	buffer: ^Buffer,
	area: Area,
	allocator := context.allocator,
) -> (
	ok: bool,
) {

	// First fill buffer with background color
	if bg_color, ok_bg_color := widget.style.bg_color.?; ok_bg_color {
		buffer_fill_background_color(buffer, area, bg_color)
	}

	for child in widget.children {
		render_ok := widget_render_any(child, area, buffer, allocator)
		if (!render_ok) {
			return false
		}
	}

	return
}
