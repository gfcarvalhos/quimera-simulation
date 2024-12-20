globals [
  random-x
  random-y
  evaporation-rate
  diffusion-rate
  num-comida-armazenada
  num-humanos-mortos
  num-cacadores-comum-mortos
  num-cacadores-elite-mortos
  num-guardas-reais
  ultimo-guardas-reais
  ultimo-humanos-mortos
  ultimo-cacadores-mortos
  rei?
  rainha?
  num-cacadores-lendarios
  cod-rei
  cod-rainha
  encontrou?
  evento-catastrofe?
  contador-tempestades
]

turtles-own [
  classe
  tipo
  vida
  dano
  comida?
  foco
]

patches-own [
  comida
  tipo-de-fonte-de-comida
  aldeoes
  quantidade-de-fontes-de-comida
  chemical
  ninho?
  nest-scent
  aldeia?
]

to setup
  clear-all
  print "Bem-vindo à Simulação HxH Quimera."
  set random-x random-xcor
  set random-y random-ycor
  set-default-shape turtles "bug"
  set evaporation-rate 20
  set diffusion-rate 5
  set num-comida-armazenada 0
  set num-humanos-mortos 0
  set num-cacadores-comum-mortos 0
  set num-cacadores-elite-mortos 0
  set num-guardas-reais 0
  set rei? false
  set encontrou? true
  set rainha? false
  set num-cacadores-lendarios 0
  set ultimo-humanos-mortos 0
  set ultimo-cacadores-mortos 0
  set ultimo-guardas-reais 0
  set evento-catastrofe? false
   set contador-tempestades 0
  criar-formigueiro
  destacar-formigueiro
  setup-patches
  criar-aldeia 2
  reset-ticks
end

to setup-patches
  ask patches [
    set aldeia? false
    criar-comida-padrao
    destacar-patch-de-comida
    setup-ninho
  ]
  ask patches with [aldeia?] [sprout 1 [set shape "house" set color white]]
end

to setup-ninho
  set ninho? (distancexy random-x random-y) < 2
  set nest-scent 200 - distancexy random-x random-y
end

; === AMBIENTE ESTÁTICO ===

to criar-formigueiro
  let propriedades (propriedades-formiga "amarelo")

    create-turtles 1 [
    set classe "formiga"
    set tipo item 0 propriedades
    set vida item 1 propriedades
    set dano item 2 propriedades
    set color item 3 propriedades
    setxy random-x random-y
  ]

  set cod-rainha one-of turtles with [color = yellow]
  set rainha? true

  ; Cria formigas vermelhas (soldados)
  criar-formigas-como "vermelho" 10
end

to destacar-formigueiro
  if random-x > (max-pxcor - 1) [ set random-x (max-pxcor - 1) ]
  if random-x < (min-pxcor + 1) [ set random-x (min-pxcor + 1) ]
  if random-y > (max-pycor - 1) [ set random-y (max-pycor - 1) ]
  if random-y < (min-pycor + 1) [ set random-y (min-pycor + 1) ]
  ask patches [
    if (distancexy random-x random-y) < 2
    [
    set pcolor violet
    ]
  ]
end

to criar-comida-padrao
  set quantidade-de-fontes-de-comida one-of [0 1 2]

  repeat quantidade-de-fontes-de-comida [
    let float random-float 10 + 1
    let new-x random-xcor * float
    let new-y random-ycor * float

    if (distancexy (new-x * float) (new-y * float)) < (distancexy random-x random-y)
    [
    set tipo-de-fonte-de-comida one-of [1 2 3]
    ]
    if tipo-de-fonte-de-comida > 0
    [
      set comida one-of [10 20]
    ]
  ]
end

to destacar-patch-de-comida
  if comida > 0 [
    if tipo-de-fonte-de-comida = 1 [ set pcolor cyan ]
    if tipo-de-fonte-de-comida = 2 [ set pcolor sky ]
    if tipo-de-fonte-de-comida = 3 [ set pcolor blue ]
  ]
end


to criar-aldeia [quantidade]
 repeat quantidade [
    let x random-xcor
    let y random-ycor

    ask patches with [abs (pxcor - x) <= 2 and abs (pycor - y) <= 2] [
      set aldeoes random 20 + 10
      set pcolor lime
      set chemical 100
      set aldeia? true
    ]
  ]

 ask patches with [aldeia?] [
    sprout 1 [
      set shape "house"
      set color gray
      set size 1
    ]
  ]
end

to recolor-patch  ; procedimento dos patches
  ifelse ninho? [
    set pcolor violet                    ; patches do ninho em violeta
  ] [
    ifelse comida > 0 [
      ; patches com comida são coloridos de acordo com a fonte
      if tipo-de-fonte-de-comida = 1 [ set pcolor cyan ]
      if tipo-de-fonte-de-comida = 2 [ set pcolor sky ]
      if tipo-de-fonte-de-comida = 3 [ set pcolor blue ]
    ] [
      ; patches normais variam de cor com base na quantidade de feromônio
      set pcolor scale-color pink chemical 0.1 5
      ;set pcolor lime + 3
    ]
    if aldeoes > 0 [
      set pcolor lime
      set chemical 100
    ]

  ]
end

; === AÇÕES FORMIGAS ===

to criar-formigas-como [formiga-cor quantidade]
  let propriedades (propriedades-formiga formiga-cor)

  create-turtles quantidade [
    set classe "formiga"
    set tipo item 0 propriedades
    set vida item 1 propriedades
    set dano item 2 propriedades
    set color item 3 propriedades
    set size 1
    setxy random-x random-y
  ]
end


to procurar-por-comida
  if comida > 0 [
    set comida comida - 1
    set comida? true
    rt 180
    stop
  ]
  if aldeoes > 0 [
    set aldeoes aldeoes - 1
    set num-humanos-mortos num-humanos-mortos + 1
    if chemical > 0 [set chemical chemical - 1]
    set comida? true
    rt 180
    stop
  ]
  if (chemical >= 0.05) and (chemical < 2) [
    uphill-chemical                     ; segue o rastro de feromônio
  ]
end

to retornar-ao-formigueiro
    ifelse ninho? [
    set comida? false
    set num-comida-armazenada num-comida-armazenada + 1
    rt 180                              ; vira 180 graus para sair novamente
  ] [
    set chemical chemical + 60          ; deposita feromônio no caminho de volta
    uphill-nest-scent                   ; move-se em direção ao ninho seguindo o gradiente
  ]
end

to gerar-novas-formigas
  if num-comida-armazenada > 0 and num-comida-armazenada mod 5 = 0 and rei? = false [
    criar-formigas-como "vermelho" 1
  ]
  if num-humanos-mortos > 0 and num-humanos-mortos mod 10 = 0 and rei? = false [
    criar-formigas-como "rosa" 1
  ]
  if num-cacadores-comum-mortos > 0 and num-cacadores-comum-mortos mod 10 = 0 and rei? = false [
    criar-formigas-como "fucsia" 1
    print "General nasceu!"
  ]
  if num-cacadores-elite-mortos > 0 and num-cacadores-elite-mortos mod 5 = 0 and num-guardas-reais < 3 and rei? = false [
    criar-formigas-como "laranja" 1
    set num-guardas-reais num-guardas-reais + 1
    print "Guarda-real nasceu!"
  ]
  if num-guardas-reais > ultimo-guardas-reais and num-guardas-reais mod 3 = 0 and rei? = false [
    ask cod-rainha [
      print "A rainha está morta! Longa vida ao rei!"
      wait 1
      die
    ]
    criar-formigas-como "amarelo" 1
    set cod-rei one-of turtles with [color = yellow]
    set rei? true

    criar-rainha
    set rainha? true

    set ultimo-guardas-reais num-guardas-reais
  ]
end


to criar-rainha
    let propriedades (propriedades-formiga "amarelo")

  create-turtles 1 [
    set classe "formiga"
    set tipo item 0 propriedades
    set vida item 1 propriedades
    set dano item 2 propriedades
    set color item 3 propriedades
    set size 1
    setxy random-xcor random-ycor
  ]

  set cod-rainha one-of turtles with [ color = yellow and self != cod-rei ]

end

to-report propriedades-formiga [formiga-cor]
  if formiga-cor = "rosa" [
    report ["movel" 130 6 magenta]
  ]
  if formiga-cor = "laranja" [
    report ["movel" 160 10 lime]
  ]
  if formiga-cor = "amarelo" [
    report ["imovel" 500 25 yellow]
  ]
  if formiga-cor = "fucsia" [
    report ["movel" 200 20 pink]
  ]
  report ["movel" 100 5 red]
end


; === MOVIMENTAÇÃO E ORIENTAÇÃO ===

to uphill-chemical  ; procedimento das formigas
  let scent-ahead chemical-scent-at-angle 0
  let scent-right chemical-scent-at-angle 45
  let scent-left chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead) [
    ifelse scent-right > scent-left [
      rt 45                              ; vira 45 graus à direita
    ] [
      lt 45                              ; vira 45 graus à esquerda
    ]
  ]
end

to uphill-nest-scent  ; procedimento das formigas
  let scent-ahead nest-scent-at-angle 0
  let scent-right nest-scent-at-angle 45
  let scent-left nest-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead) [
    ifelse scent-right > scent-left [
      rt 45                              ; vira 45 graus à direita
    ] [
      lt 45                              ; vira 45 graus à esquerda
    ]
  ]
end


to wiggle
  rt random 40
  lt random 40
  if not can-move? 1 [ rt 180 ]
  fd 1
end

to procurar-conjuge
    let alvo one-of turtles in-radius 1 with [self = cod-rainha]
    if alvo != nobody [
      set random-x [xcor] of alvo
      set random-y [ycor] of alvo

      wait 1
      set rei? false
      set encontrou? true
      print "O rei está morto! Longa vida à rainha!"
      die
    ]
end

; == Catástrofes (Tempestade) ===

to tempestade
  ; Verifica se podo ocorrer uma nova tempestade
  if contador-tempestades >= 2 [
    stop ; Impede que a tempestade ocorra mais de 2 vezes
  ]
  ; Incrementa o contador de tempestades
  set contador-tempestades contador-tempestades + 1
  print "A tempestade começou! Nuvens e raios estão no céu."
  ; Reduz vida das formigas
  ask turtles with [classe = "formiga"] [
    set vida max list (vida - 2) 0  ; Reduz a vida em 10, mas não abaixo de 0
    if vida = 0 [ die ]  ; Elimina formigas sem vida
  ]
  print "Uma tempestade tirou vida das formigas!"
  ; A tempestade dura 5 segundos (50 ciclos de 5s)
  repeat 4 [
    ask patches[
      set pcolor gray
    ]
    display ; Atualiza a interface para mostrar os efeitos
    ;wait 3 ; Aguarda 3.0 segundo antes do próximo ciclo
  ]
  display ; Atualiza a interface novamente
  print "A tempestade acabou. O céu está limpo novamente."
  ; Marca o fim do evento
  set evento-catastrofe? false
end


; === Vereficando Catástrofes

to check-catastrophes
  if contador-tempestades < 1 [  ; Limita a tempestade a no máximo 2 ocorrências
    if random 100 < 10 [ ; 10% de chance de ocorrer uma tempestade
      tempestade
    ]
  ]
end



; === FUNÇÕES AUXILIARES ===

to-report nest-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]             ; se não houver patch, retorna 0
  report [nest-scent] of p               ; retorna o valor de 'nest-scent' do patch
end

to-report chemical-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]             ; se não houver patch, retorna 0
  report [chemical] of p                 ; retorna o valor de 'chemical' do patch
end

; === AÇÕES CAÇADORES ===

to criar-cacadores
  if num-humanos-mortos > 0 and num-humanos-mortos mod 5 = 0 and num-humanos-mortos > ultimo-humanos-mortos [
    criar-novo-cacador "cacador-comum" 1
    set ultimo-humanos-mortos num-humanos-mortos
  ]

  if num-cacadores-comum-mortos > 0 and num-cacadores-comum-mortos mod 5 = 0 and num-cacadores-comum-mortos > ultimo-cacadores-mortos [
    criar-novo-cacador "cacador-comum" 1
    criar-novo-cacador "cacador-elite" 1
    set ultimo-cacadores-mortos num-cacadores-comum-mortos
  ]

  if rei? = true and num-cacadores-lendarios <= 4 [
    criar-novo-cacador "cacador-lendario" 2
    set num-cacadores-lendarios num-cacadores-lendarios + 2
    print "Caçador lendario nasceu!"
  ]

end

to criar-novo-cacador [tipo-cacador quantidade]
  let propriedades (propriedades-cacadores tipo-cacador)

  create-turtles quantidade [
    set shape "wolf"
    set size 1
    set classe "cacador"
    set tipo item 0 propriedades
    set dano item 2 propriedades
    set vida item 1 propriedades
    set color item 3 propriedades
    if (item 4 propriedades) = true [
    set foco one-of patches with [aldeia?]
    ]
    setxy random-xcor random-ycor
  ]
end

to mover-cacadores
  ask turtles with [classe = "cacador"] [
    ifelse distance foco > 5 [
      face foco
      if not can-move? 1 [ rt 180 ]
      fd 1
    ] [
      right random 30  ; Movimento aleatório ao redor da aldeia
      left random 30
      if not can-move? 1 [ rt 180 ]
      fd 1
    ]
  ]
end

to-report propriedades-cacadores [tipo-cacador]
  if tipo-cacador = "cacador-elite" [
    report ["cacador-elite" 400 20 orange true]
  ]
  if tipo-cacador = "cacador-lendario" [
    report ["cacador-lendario" 750 25 pink true]
  ]
  report ["cacador-comum" 300 15 blue true]
end

; === DINÂMICA PARA INTERAÇÃO ===

to exterminar-formigas
  ask turtles with [classe = "formiga"] [
    die
  ]
  print "Todas as formigas foram exterminadas pela Rosa dos Pobres!"
  user-message "Fim da Simulação: Rosa dos Pobres ativada!"
  stop
end


to verificar-alvos [classe-agente]
  ask turtles with [classe = classe-agente] [
    if classe = "cacador" [
      let alvo one-of turtles in-radius 1 with [classe = "formiga"]
      if alvo != nobody [
        ask alvo [
          set vida vida - [dano] of myself
          if vida <= 0 [
            if color = orange [set num-guardas-reais num-guardas-reais - 1]
            if self = cod-rei [
              print "O rei foi morto! A Rosa dos Pobres exterminará todas as formigas!"
              set rei? false
              exterminar-formigas
              stop
            ]
            if self = cod-rainha [
              print "A rainha foi morta pelos caçadores!"
              set rainha? false
            ]
            die
          ]
        ]
        ;set vida vida - 10
      ]
    ]
    if classe = "formiga" [
      let alvo one-of turtles in-radius 1 with [classe = "cacador"]
      if alvo != nobody [
        ask alvo [
          set vida vida - [dano] of myself
          if vida <= 0 [
            if tipo = "cacador-comum" [set num-cacadores-comum-mortos num-cacadores-comum-mortos + 1]
            if tipo = "cacador-elite" [set num-cacadores-elite-mortos num-cacadores-elite-mortos + 1]
            if tipo = "cacador-lendario" [set num-cacadores-lendarios num-cacadores-lendarios - 1]
            die
          ]
        ]
        set vida vida - 20
      ]
    ]
  ]
end



; === PROCEDIMENTOS PRINCIPAIS ===

to go
  check-catastrophes  ; Verifica se ocorre uma tempestade no início do tick
  ask turtles with [classe = "formiga" and tipo = "movel"] [
    if who >= ticks [ stop ]             ; sincroniza a saída das formigas do ninho com o tempo
    verificar-alvos "formiga"
    ifelse comida? = false and rei? = false [
      procurar-por-comida                ; procura por comida se não estiver carregando
    ] [
      retornar-ao-formigueiro            ; retorna ao ninho se estiver carregando comida
    ]
    wiggle                               ; movimento aleatório para simular procura
    fd 1                                 ; move-se para frente
  ]
  diffuse chemical (diffusion-rate / 100)  ; difusão do feromônio entre os patches
  ask patches [
    set chemical chemical * (100 - evaporation-rate) / 100  ; evaporação do feromônio
    recolor-patch                     ; atualiza a cor do patch após mudanças
  ]

  ask turtles with [classe = "cacador"] [
    verificar-alvos "cacador"

    mover-cacadores
    fd 1
  ]

  if rei? = true [
    set encontrou? false
    ask turtles with [ color = yellow ] [
      wiggle
    ]

    ask cod-rei [ procurar-conjuge ]

    if rei? = false and encontrou? = true [
      ask patches [
        set nest-scent 0
        setup-ninho
      ]
      destacar-formigueiro
    ]

    if rei? = false or not any? turtles with [self = cod-rei] and encontrou? = false [
      print "Os caçadores mataram o rei! Fim da simulação."
      print "O rei foi morto! Ativando Rosa dos Pobres."
      exterminar-formigas
      user-message "Fim!"
      stop
    ]

    if rainha? = false [
      print "O rei não consegue mais seguir com a linhagem. Fim da simulação."
      user-message "Fim!"
      stop
    ]

    ;set encontrou? false
  ]

  if rainha? = true and rei? = false and encontrou? = false [
    print "A rainha não consegue mais seguir com a linhagem. Fim da simulação."
    user-message "Fim!"
    stop
  ]

  if rainha? = false and rei? = false [
    print "As formigas não conseguem mais procriar! Fim da simulação."
    user-message "Fim!"
    stop
  ]
  if random 80 < 10 [
    tempestade
  ]


  ;Verifica população de formigas
  let populacao-formiga count turtles  with [classe = "formiga" and color != yellow]
  if populacao-formiga = 0 [
    print "População de Formigas Erradicada. Fim da simulação."
    user-message "Fim!"
    stop
  ]

  ;ações nivel observador
  gerar-novas-formigas
  criar-cacadores
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
242
17
709
485
-1
-1
13.91
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
39
48
102
81
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
39
96
102
129
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
36
208
116
253
soldier bugs
count turtles  with [color = red]
17
1
11

MONITOR
35
149
137
194
queen/king bug
count turtles  with [color = yellow]
17
1
11

MONITOR
36
264
121
309
captain bugs
count turtles  with [color = magenta]
17
1
11

MONITOR
139
207
244
252
normal hunter
count turtles  with [tipo = \"cacador-comum\"]
17
1
11

MONITOR
162
267
237
312
elite hunter
count turtles with [tipo = \"cacador-elite\"]
17
1
11

MONITOR
149
324
241
369
legend hunter
count turtles  with [tipo = \"cacador-lendario\"]
17
1
11

MONITOR
34
323
119
368
real bugs
count turtles  with [color = lime]
17
1
11

MONITOR
80
394
198
439
NIL
num-guardas-reais
17
1
11

MONITOR
143
149
237
194
general bugs
count turtles with [dano = 20]
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
