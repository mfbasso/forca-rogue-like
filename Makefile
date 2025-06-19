.PHONY: run

run:
	love --console .

build-love:
	@echo "Gerando forca-rogue-like.love..."
	@rm -f forca-rogue-like.love
	@zip -9 -r forca-rogue-like.love . -x "web/*" -x "*.love" -x "*.DS_Store" -x "Makefile" -x "*.md" -x "*/.git*" -x "*/__pycache__/*"

lovejs: build-love
	@echo "Gerando nome aleatório para o arquivo .love..."
	@export RAND_NAME=$(shell date +%Y%m%d%H%M%S).love; \
	cp forca-rogue-like.love web/$$RAND_NAME; \
	sed -i.bak "s/game.love/$$RAND_NAME/g" web/index.html; \
	echo "Arquivo copiado para web/$$RAND_NAME e index.html atualizado."; \
	rm -f web/index.html.bak

watch:
	love --console --watch .

serve:
	cd web && npx node server.js

deploy:
	@echo "Deploying to GitHub Pages..."
	@curl https://integrations.esportetenis.com/webhook/b52ac233-20e6-4fd6-9030-364ed530e03b

build-android:
	@echo "Building for Android..."
	@mkdir -p build/android
	@docker build -f Dockerfile.android -t love-android .
	@docker run --rm -v $(PWD)/build/android:/app/output love-android cp /app/build/android/love-11.5-android-embed.apk /app/output/forca-rogue-like.apk
	@echo "APK copied to build/android/"
	@cp build/android/forca-rogue-like.apk web/game.apk
	@echo "Done!"