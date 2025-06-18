.PHONY: run

run:
	love --console .

build:
	@echo "Gerando forca-rogue-like.love..."
	@rm -f forca-rogue-like.love
	@zip -9 -r forca-rogue-like.love . -x "web/*" -x "*.love" -x "*.DS_Store" -x "Makefile" -x "*.md" -x "*/.git*" -x "*/__pycache__/*"

lovejs: build
	@echo "Copiando forca-rogue-like.love para web/game.love..."
	@cp forca-rogue-like.love web/game.love
	@echo "Pronto! Agora coloque os arquivos do love.js em web/ e abra o index.html."

watch:
	love --console --watch .

serve:
	cd web && npx node server.js