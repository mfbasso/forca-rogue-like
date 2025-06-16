# Jogo da Forca Rogue-like

Este projeto é um jogo da forca com elementos rogue-like feito em LÖVE (Love2D).

## Estrutura de Pastas

- `main.lua` — Arquivo principal do jogo
- `conf.lua` — Configurações do Love2D
- `assets/` — Recursos do jogo (imagens, sons, fontes)
- `src/` — Código-fonte do jogo
  - `game.lua` — Lógica principal
  - `states/` — Estados do jogo (menu, jogo, game over)
  - `utils/wordlist.lua` — Lista de palavras e helpers
  - `player.lua` — Lógica do jogador
  - `inventory.lua` — Inventário do jogador

## Como rodar

1. Instale o [Love2D](https://love2d.org/)
2. Execute o comando:
   ```sh
   love .
   ```

## Créditos

- Estrutura inicial gerada por GitHub Copilot
