.PHONY: run

run:
	love --console .

build:
	love --console --release .

watch:
	love --console --watch .