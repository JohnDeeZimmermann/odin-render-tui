package ort

import "core:strings"
import "core:time"
import "core:unicode/utf8"
import tbx "shared:odin-termbox2"

KeyboardKey :: tbx.KeyboardKey
MouseKey :: tbx.MouseKey
Mod :: tbx.Mod

KeyEvent :: struct {
	key:       KeyboardKey,
	mod:       Maybe(Mod),
	character: Maybe(rune),
}

ResizeEvent :: struct {
	dimensions: Dimensions,
}

MouseEvent :: struct {
	key:            MouseKey,
	mouse_position: Position,
}

Event :: union {
	KeyEvent,
	ResizeEvent,
	MouseEvent,
}

wait_for_event :: proc() -> Event {
	for {
		event := poll_event()
		if ev, ok := event.?; ok {
			return ev
		}
	}
}

poll_event :: proc() -> Maybe(Event) {
	tbx_event: tbx.Event
	tbx.poll_event(&tbx_event)

	return _tbx_event_to_event(tbx_event)
}

peek_event :: proc(duration: time.Duration) -> Maybe(Event) {
	tbx_event: tbx.Event

	time_ms := i32(time.duration_milliseconds(duration))
	tbx.peek_event(&tbx_event, time_ms)

	return _tbx_event_to_event(tbx_event)
}

_tbx_event_to_event :: proc(tbx_event: Maybe(tbx.Event)) -> Maybe(Event) {
	if (tbx_event == nil) {
		return nil
	}

	e := tbx_event.?

	switch (e.type) {
	case .Key:
		return KeyEvent {
			key = KeyboardKey(e.key),
			character = nil if (strings.is_null(e.ch)) else e.ch,
			mod = e.mod,
		}
	case .Resize:
		return ResizeEvent{dimensions = Dimensions{width = u16(e.w), height = u16(e.h)}}
	case .Mouse:
		return MouseEvent {
			mouse_position = Position{x = u16(e.x), y = u16(e.y)},
			key = MouseKey(e.key),
		}
	}

	return nil
}

events_set_mouse_enabled :: proc(enabled: bool) {
	if (enabled) {
		tbx.set_input_mode(.Mouse)
	} else {
		tbx.set_input_mode(.Esc)
	}
}
