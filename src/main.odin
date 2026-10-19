package main
import "core:fmt"
import vmem "core:mem/virtual"
import ort "lib"

main :: proc() {
	arena: vmem.Arena
	app := ort.app_create(&arena).?
	defer ort.app_destroy(app)
}
