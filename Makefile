.PHONY: run
run: strength.wasm
	wasm-interp $< --run-all-exports --host-print

%.wasm: %.wat
	wat2wasm $< -o $@
