local utf8 = require("utf8") 

local questions = {
  {question = "Cor do céu em um dia sem nuvens", answer = "AZUL", level = 1},
  {question = "Animal que late", answer = "CACHORRO", level = 1},
  {question = "Fruta amarela e curvada", answer = "BANANA", level = 1},
  {question = "Objeto usado para escrever", answer = "LAPIS", level = 1},
  {question = "Grande astro que ilumina o dia", answer = "SOL", level = 1},
  {question = "Animal que mia", answer = "GATO", level = 1},
  {question = "Bebida feita com frutas", answer = "SUCO", level = 1},
  {question = "Lugar onde moramos", answer = "CASA", level = 1},
  {question = "Objeto usado para cortar papel", answer = "TESOURA", level = 1},
  {question = "Objeto que usamos nos pes", answer = "SAPATO", level = 1},
  {question = "Dia que vem depois da sexta", answer = "SABADO", level = 1},
  {question = "Cor do sangue", answer = "VERMELHO", level = 1},
  {question = "Animal que vive no mar", answer = "PEIXE", level = 1},
  {question = "Usado para enxugar o corpo", answer = "TOALHA", level = 1},
  {question = "Usado para escovar os dentes", answer = "ESCOVA", level = 1},
  {question = "Inseto que faz mel", answer = "ABELHA", level = 1},
  {question = "Fruta vermelha pequena", answer = "MORANGO", level = 1},
  {question = "Parte do corpo usada para ver", answer = "OLHO", level = 1},
  {question = "Peça de roupa usada na cabeca", answer = "BONÉ", level = 1},
  {question = "Cor das nuvens", answer = "BRANCO", level = 1},
  {question = "Animal que tem asas e bico", answer = "PASSARO", level = 1},
  {question = "Tem chaves e abre portas", answer = "FECHADURA", level = 1},
  {question = "Ponto de luz no teto", answer = "LAMPADA", level = 1},
  {question = "Parte do corpo que usamos para andar", answer = "PÉ", level = 1},
  {question = "Brinquedo com rodas e pedais", answer = "BICICLETA", level = 1},
  {question = "Usado para ver horas", answer = "RELOGIO", level = 1},
  {question = "Comida redonda com queijo e molho", answer = "PIZZA", level = 1},
  {question = "Usamos para sentar", answer = "CADEIRA", level = 1},
  {question = "Fruta que pode ser verde ou roxa", answer = "UVA", level = 1},
  {question = "Dia depois da segunda", answer = "TERCA", level = 1},

}

-- Function to remove accents from a string
local function remove_accents(str)
  local accent_map = {
    ['Á']='A', ['À']='A', ['Â']='A', ['Ã']='A', ['Ä']='A',
    ['É']='E', ['È']='E', ['Ê']='E', ['Ë']='E',
    ['Í']='I', ['Ì']='I', ['Î']='I', ['Ï']='I',
    ['Ó']='O', ['Ò']='O', ['Ô']='O', ['Õ']='O', ['Ö']='O',
    ['Ú']='U', ['Ù']='U', ['Û']='U', ['Ü']='U',
    ['Ç']='C',
    ['á']='a', ['à']='a', ['â']='a', ['ã']='a', ['ä']='a',
    ['é']='e', ['è']='e', ['ê']='e', ['ë']='e',
    ['í']='i', ['ì']='i', ['î']='i', ['ï']='i',
    ['ó']='o', ['ò']='o', ['ô']='o', ['õ']='o', ['ö']='o',
    ['ú']='u', ['ù']='u', ['û']='u', ['ü']='u',
    ['ç']='c',
    ['É']='E', ['é']='e', ['Ê']='E', ['ê']='e', ['Í']='I', ['í']='i', ['Ó']='O', ['ó']='o', ['Ú']='U', ['ú']='u', ['Â']='A', ['â']='a', ['Ô']='O', ['ô']='o', ['À']='A', ['à']='a', ['Ã']='A', ['ã']='a', ['Õ']='O', ['õ']='o', ['Ç']='C', ['ç']='c', ['Ü']='U', ['ü']='u', ['Ï']='I', ['ï']='i', ['Ö']='O', ['ö']='o', ['Ë']='E', ['ë']='e', ['Ä']='A', ['ä']='a'
  }
  local result = {}
  for _, codepoint in utf8.codes(str) do
    local char = utf8.char(codepoint)
    table.insert(result, accent_map[char] or char)
  end
  return table.concat(result)
end

for i, q in ipairs(questions) do
  q.answer = remove_accents(q.answer)
end

return questions
