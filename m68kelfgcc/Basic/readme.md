# MMSJ-BASIC - Referência Rápida de Comandos e Funções

Esta referência cobre os comandos e as funções de uso direto do BASIC do monitor.
Rotinas internas sem token continuam fora.

## Controle de programa

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `END` | `END` | Encerra o programa normalmente. | `END` |
| `FOR` | `FOR <var> = <inicio> TO <final> [STEP <passo>]` | Inicia laço contado. A variável pode ser criada automaticamente. | `FOR I = 1 TO 10 STEP 2` |
| `GOSUB` | `GOSUB <linha>` | Salta para uma sub-rotina e volta com `RETURN`. | `GOSUB 200` |
| `GOTO` | `GOTO <linha>` | Salta para uma linha do programa sem retorno. | `GOTO 100` |
| `IF` | `IF <expr> THEN <cmds> [ELSE <cmds>]` | Verdadeiro: executa após `THEN` (vários comandos com `:`) e salta de `ELSE` até fim da linha. Falso: salta de `THEN` até `ELSE` e executa o resto da linha até `0x00`. | `IF A>10 THEN PRINT "OK" ELSE PRINT "NO"` |
| `LET` | `LET <var> = <expr>` | Atribui valor a uma variável. O `LET` é opcional; `A$="OI"` funciona do mesmo jeito. | `LET A = 10` |
| `LOAD` | `LOAD <arquivo>` | Carrega um programa textual do disco para a memória do BASIC usando o nome informado. | `LOAD CUBE.BAS` |
| `NEXT` | `NEXT [<var>]` | Fecha o laço `FOR` e avança para a próxima iteração. | `NEXT I` |
| `ON` | `ON <expr> GOTO <l1>,<l2>,...` / `ON <expr> GOSUB <l1>,<l2>,...` | Faz desvio por índice: 1 vai para a primeira linha, 2 para a segunda, e assim por diante. | `ON N GOTO 100,200,300` |
| `ONERR` | `ONERR GOTO <linha>` | Define uma linha de tratamento para erro. | `ONERR GOTO 900` |
| `PRINT` | `PRINT <valor>[;/, <valor> ...]` | Mostra texto ou valores na tela. `;` e `,` são aceitos como separadores. | `PRINT "X=";X` |
| `REM` | `REM <texto>` | Comentário; o resto da linha é ignorado. | `REM sem efeito` |
| `RETURN` | `RETURN` | Retorna de um `GOSUB`. | `RETURN` |
| `SAVE` | `SAVE <arquivo>` | Salva o programa atual no disco em formato textual (igual ao `LIST`) usando o nome informado. | `SAVE CUBE.BAS` |
| `STOP` | `STOP` | Interrompe o programa com erro/parada. | `STOP` |
| `WHILE` | `WHILE <expr> ... <comando> .... WEND` | Executa loop enquanto a expressão for verdadeira. | `5 A=15 10 WHILE A>10 20 PRINT "OK" 30 A=A-1 40 WEND` |

## Variáveis, entrada e dados

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `CLEAR` | `CLEAR` | Limpa todas as variáveis. | `CLEAR` |
| `DATA` | `DATA <valor>[,<valor>...]` | Guarda valores que serão consumidos por `READ`. | `DATA 1,2,3` |
| `DIM` | `DIM (<dim 1>[,<dim 2>[,...]])` | Reserva espaço para array. | `DIM A(10,20)` |
| `GET` | `GET <var>` | Lê um único caractere/valor do teclado. | `GET K$` |
| `INPUT` | `INPUT ["texto";] <var>` | Lê valores do teclado e grava na variável. Se houver texto, ele aparece antes da leitura. | `INPUT "Nome"; N$` |
| `READ` | `READ <var>[,<var>...]` | Lê valores dos blocos `DATA`. | `READ A$,B` |
| `RESTORE` | `RESTORE` | Volta o ponteiro de leitura do `DATA` para o começo. | `RESTORE` |

## Tela e modo de vídeo

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `CLS` | `CLS` | Limpa a tela atual. | `CLS` |
| `COLOR` | `COLOR <fg>,<bg>` / `COLOR <fg>` / `COLOR ,<bg>` | Ajusta as cores atuais de frente e fundo. | `COLOR 15,1` |
| `LOCATE` | `LOCATE <x>,<y>` | Posiciona o cursor na tela de texto. | `LOCATE 10,5` |
| `SCREEN` | `SCREEN <modo>[,<sprite>]` | Troca o modo de vídeo. `modo` pode ser `0` texto, `1` multicolor, `2` G2. O segundo parâmetro ajusta o modo/tamanho de sprite. | `SCREEN 2,0` |

## Gráficos

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `CIRCLE` | `CIRCLE x,y,radius[,color[,tracingStart[,tracingEnd[,aspect]]]]` | Desenha círculo, elipse ou arco (estilo MSX-BASIC). `radius` é o raio horizontal; `aspect` (opcional, padrão `1`) define a razão vertical/horizontal (`raio vertical = radius × aspect`). `tracingStart` e `tracingEnd` são ângulos em radianos (0 = ponto mais à esquerda, sentido horário; padrão `0` a `2π` = círculo completo). Valores negativos em `tracingStart` ou `tracingEnd` traçam uma linha do centro até o ponto do ângulo (valor absoluto). `color` é opcional (0–15); se omitida, usa a cor de frente (`COLOR`). Parâmetros intermediários podem ser omitidos com vírgulas: `CIRCLE 127,95,50,,,,1.4`. | `CIRCLE 120,80,20,4` / `CIRCLE 127,95,50,,,,1.4` |
| `DRAW` | `DRAW "<comandos>"` | Desenha/move com comandos encadeados no estilo MSX (`BM`, `M`, `R/L/U/D/E/F/G/H`, `C`). | `DRAW "BM100,100R20D20L20U20"` |
| `FILL` | `FILL <x1>,<y1>,<x2>,<y2>[,<cor>]` | Preenche um retângulo definido, direto na VDP. `cor` é opcional (0–15); se omitida, usa a cor de frente atual. | `FILL 10,10,60,40,3` |
| `LINE` | `LINE x,y TO x,y [TO x,y...] [COLOR <cor>]` | Desenha uma linha ou sequência de segmentos. `COLOR` só no final da linha; aplica a cor a todo o traçado. Se omitido, usa a cor de frente atual. | `LINE 10,10 TO 100,100 COLOR 15` |
| `PAINT` | `PAINT x,y,c` | Flood fill a partir de um ponto, preenchendo a área conectada com a cor `c`. | `PAINT 30,20,4` |
| `PLOT` | `PLOT <x>,<y>[,<cor>]` | Desenha um ponto/pixel na posição informada. `cor` é opcional (0–15); se omitida, usa a cor de frente atual. | `PLOT 20,10,7` |
| `RECT` | `RECT x1,y1,x2,y2[,<cor>]` | Desenha as bordas de um retângulo. `cor` é opcional (0–15); se omitida, usa a cor de frente atual. | `RECT 10,10,80,40,2` |
| `VPOKE` | `VPOKE <endereco>,<byte>` | Grava um byte diretamente na VRAM do VDP (buffer de vídeo do BASIC). | `VPOKE 0,255` |

## Buffer de vídeo (G2)

Há **7 superfícies**: área **0** = VRAM (tela visível); áreas **1** a **6** = buffers em RAM (`pStartVdpBuffer`, 72 KB no total — 6×12 KB: 6 KB tabela de padrão + 6 KB tabela de cor por área). No início e ao fim de cada `RUN`, os desenhos ficam na área **0**.

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `BUFCOPY` | `BUFCOPY <orig>,<dest>,<x1>,<y1>,<x2>,<y2>` | Copia uma região entre áreas (`orig`/`dest`: `0`=VRAM, `1`–`6`=buffers RAM de 12 KB cada). Para exibir um buffer na tela: `BUFCOPY <area>,0,...`. | `BUFCOPY 1,0,0,0,255,191` |
| `BUFDRAW` | `BUFDRAW <area>` | Redireciona os desenhos G2 para a área informada (`0`=VRAM, `1`–`6`=buffer RAM). Ao terminar o programa (`RUN`, `END`, `STOP` ou ESC), volta automaticamente para a área `0`. | `BUFDRAW 1` |

## Sprites

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `SPRITECOLOR` | `SPRITECOLOR <number>,<cor>` | Muda só a cor de um sprite já ativo. | `SPRITECOLOR 0,7` |
| `SPRITEPOS` | `SPRITEPOS <number>,<x>,<y>` | Move um sprite já ativo. | `SPRITEPOS 0,120,90` |
| `SPRITEPUT` | `SPRITEPUT <number>,<plano>,<x>,<y>,<cor>` | Ativa o sprite, define plano, posição e cor inicial. | `SPRITEPUT 0,1,100,80,15` |
| `SPRITESET` | `SPRITESET <number>,<var$>` | Carrega o padrão bruto de sprite a partir de uma string. | `SPRITESET 0,S$` |

## Funções do BASIC

| Função | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `ABS` | `ABS(<number real>)` | Retorna o valor absoluto. | `PRINT ABS(-10)` |
| `ASC` | `ASC(<string>)` | Retorna o código ASCII do primeiro caractere. | `PRINT ASC("A")` |
| `ATN` | `ATN(<number real>)` | Retorna o arco-tangente (radianos, via FFP). | `PRINT ATN(1)` |
| `BASE` | `BASE(<tabela>)` | Retorna o endereço base de uma tabela VDP (esquema próprio do MMSJ-BASIC). `0` = pattern; `1` = name; `2` = color (G2) ou name+0x800 (texto). | `PRINT BASE(1)` |
| `BIN$` | `BIN$(<inteiro>)` | Converte inteiro para string binária com sufixo `b`. | `PRINT BIN$(10)` |
| `CHR$` | `CHR$(<codigo ascii>)` | Retorna uma string com o caractere correspondente ao código. | `A$ = CHR$(65)` |
| `COS` | `COS(<number real>)` | Retorna o cosseno do ângulo. | `PRINT COS(0)` |
| `EXP` | `EXP(<number real>)` | Retorna $e^x$. | `PRINT EXP(1)` |
| `FRE` | `FRE(0)` | Retorna a memória livre disponível para o BASIC. | `PRINT FRE(0)` |
| `HEX$` | `HEX$(<inteiro>)` | Converte inteiro para string hexadecimal com sufixo `h`. | `PRINT HEX$(255)` |
| `INT` | `INT(<number real>)` | Converte o valor para inteiro. | `PRINT INT(3.9)` |
| `LEFT$` | `LEFT$(<string>,<qtd>)` | Retorna os primeiros caracteres da string. | `PRINT LEFT$(A$,3)` |
| `LEN` | `LEN(<string>)` | Retorna o tamanho da string. | `PRINT LEN(A$)` |
| `LOG` | `LOG(<number real>)` | Retorna o logaritmo natural. | `PRINT LOG(10)` |
| `MID$` | `MID$(<string>,<inicio>[,<qtd>])` | Retorna uma parte da string a partir da posição informada. | `PRINT MID$(A$,2,4)` |
| `OCT$` | `OCT$(<inteiro>)` | Converte inteiro para string octal com sufixo `o`. | `PRINT OCT$(64)` |
| `PEEK` | `PEEK(<endereco>)` | Lê um byte da memória. | `PRINT PEEK(4096)` |
| `POINT` | `POINT(<x>,<y>)` | Retorna a cor do pixel na posição informada. | `C = POINT(10,20)` |
| `POKE` | `POKE(<endereco>,<byte>)` | Grava um byte na memória. | `POKE 4096,255` |
| `RND` | `RND(<number>)` | Retorna um número pseudoaleatório. | `PRINT RND(1)` |
| `RIGHT$` | `RIGHT$(<string>,<qtd>)` | Retorna os últimos caracteres da string. | `PRINT RIGHT$(A$,2)` |
| `SIGN` | `SIGN(<numero>)` | Retorna o sinal: `-1` se negativo, `0` se zero, `1` se positivo. Aceita inteiro ou real. | `PRINT SIGN(-5)` |
| `SIN` | `SIN(<number real>)` | Retorna o seno do ângulo. | `PRINT SIN(0)` |
| `SPC` | `SPC(<numero>)` | Gera um bloco de espaços para uso em `PRINT`. | `PRINT "A";SPC(5);"B"` |
| `SPRITEOVER` | `SPRITEOVER(<numsprite1>,<numsprite2>)` | Retorna 1 quando os dois sprites informados estão em colisão. | `PRINT SPRITEOVER(0,1)` |
| `SQRT` | `SQRT(<number real>)` | Retorna a raiz quadrada. | `PRINT SQRT(9)` |
| `STR$` | `STR$(<numero>)` | Converte número para string. | `A$ = STR$(123)` |
| `TAB` | `TAB(<numero>)` | Avança a coluna do `PRINT`. | `PRINT TAB(10);"X"` |
| `TAN` | `TAN(<number real>)` | Retorna a tangente do ângulo. | `PRINT TAN(0)` |
| `VAL` | `VAL(<string>)` | Converte string numérica para valor. | `PRINT VAL("123")` |
| `VPEEK` | `VPEEK(<endereco>)` | Lê um byte da VRAM do VDP (buffer de vídeo do BASIC). | `PRINT VPEEK(0)` |

## Palavras-chave auxiliares

Estas palavras existem no BASIC, mas não são comandos independentes:
`THEN`, `ELSE`, `TO`, `STEP`, `AT`.

## Notas rápidas

- `PAINT` é flood fill por área conectada.
- `FILL` é preenchimento de retângulo.
- `PEEK`/`POKE` acessam memória da CPU; `VPEEK`/`VPOKE` acessam a VRAM do VDP pelo buffer do BASIC.
- `LINE ... COLOR n` só aceita `COLOR` no final da linha, após todos os pontos.
- Os comandos gráficos e de sprite exigem modo gráfico compatível, geralmente `SCREEN 2` para G2.
- `PRINT`, `INPUT`, `READ` e `DATA` aceitam strings e números conforme o contexto.
