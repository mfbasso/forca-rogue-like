# Copilot Instructions

- Sempre utilize variáveis e métodos em inglês
- Sempre separe as responsabilidades em métodos diferentes seguindo a arquitetura de pastas descritas nesse documento
- Só utilize comentários caso seja extremamente necessário
- Sempre utilize nomes de variáveis e métodos que façam sentido com o que estão fazendo
- Sempre que houver algo relevante para conhecimento futuro, adicione nesse documento

## Estrutura de pastas

- `main.lua` — Arquivo principal do jogo
- `conf.lua` — Configurações do Love2D
- `assets/` — Recursos do jogo
  - `fonts/` — Fontes utilizadas
  - `images/` — Imagens do jogo
  - `sounds/` — Sons do jogo
- `src/` — Código-fonte do jogo
  - `game.lua` — Lógica principal do jogo
  - `game_scene.lua` — Cena principal do jogo
  - `game_state.lua` — Gerenciamento de estado do jogo
  - `inventory.lua` — Inventário do jogador
  - `letter_boxes.lua` — Lógica das caixas de letras
  - `menu_scene.lua` — Cena do menu
  - `player.lua` — Lógica do jogador
  - `questions.lua` — Gerenciamento de perguntas
  - `virtual_keyboard.lua` — Teclado virtual
  - `states/` — Estados do jogo (menu, jogo, game over)
    - `gameover.lua`, `jogo.lua`, `menu.lua`
  - `utils/` — Utilitários e helpers
    - `background_music.lua`, `question_selector.lua`, `random_seed.lua`, `wordlist.lua`
- `build/` — Builds do jogo
  - `android/` — Build para Android
- `web/` — Arquivos para versão web e distribuição
  - Inclui scripts, builds e assets para rodar o jogo no navegador
