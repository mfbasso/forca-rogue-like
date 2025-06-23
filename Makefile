.PHONY: run

run:
	love --console .

build-love:
	@echo "Gerando forca-rogue-like.love..."
	@rm -f forca-rogue-like.love
	@zip -9 -r forca-rogue-like.love . \
	    -x "web/*" \
			-x "*.DS_Store" \
			-x "Makefile" \
			-x "*.md" \
			-x "*/.git*" \
			-x "*/__pycache__/*" \
			-x ".git" \
			-x ".git/*" \
			-x ".git/**" \
			-x "Dockerfile*" \
			-x "docker-compose*" \
			-x ".project" \
			-x ".project/*" \
			-x ".project/**" \
			-x ".gitignore" \
			-x ".github/" \
			-x ".github/*" \
			-x ".github/**" \
			-x "build/" \
			-x "build/*" \
			-x "build/**" \

lovejs: build-love
	@echo "Gerando nome aleatório para o arquivo .love..."
	npx love.js forca-rogue-like.love forca-rogue-like -c -m 500000000 -t "Forca Rogue Like"
	cp web/server.js forca-rogue-like/server.js
	cp web/love.css forca-rogue-like/theme/love.css

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