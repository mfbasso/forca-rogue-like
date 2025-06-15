# Makefile para rodar e buildar o projeto Love2D

.PHONY: run build

run:
	love .

build:
	zip -r jogo-forca.love . -x "*.git*" -x "*.DS_Store" -x "*/\.*" -x "Makefile"
