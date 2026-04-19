# MMSJ-BASIC - Referência Rápida de Comandos

Esta referência cobre somente comandos e palavras-chave de uso direto do BASIC do monitor.
Funções internas como `ASC`, `ABS`, `CHR$`, `STR$` e similares foram omitidas de propósito.

## Controle de programa

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `LET` | `LET <var> = <expr>` | Atribui valor a uma variável. O `LET` é opcional; `A$="OI"` funciona do mesmo jeito. | `LET A = 10` |
| `PRINT` | `PRINT <valor>[;|, <valor> ...]` | Mostra texto ou valores na tela. `;` e `,` são aceitos como separadores. | `PRINT "X=";X` |
| `IF` | `IF <expr> THEN <comando>` | Executa algo somente quando a expressão for verdadeira. | `IF A>10 THEN PRINT "OK"` |
| `FOR` | `FOR <var> = <inicio> TO <final> [STEP <passo>]` | Inicia laço contado. A variável pode ser criada automaticamente. | `FOR I = 1 TO 10 STEP 2` |
| `NEXT` | `NEXT [<var>]` | Fecha o laço `FOR` e avança para a próxima iteração. | `NEXT I` |
| `GOTO` | `GOTO <linha>` | Salta para uma linha do programa sem retorno. | `GOTO 100` |
| `GOSUB` | `GOSUB <linha>` | Salta para uma sub-rotina e volta com `RETURN`. | `GOSUB 200` |
| `RETURN` | `RETURN` | Retorna de um `GOSUB`. | `RETURN` |
| `ON` | `ON <expr> GOTO <l1>,<l2>,...` / `ON <expr> GOSUB <l1>,<l2>,...` | Faz desvio por índice: 1 vai para a primeira linha, 2 para a segunda, e assim por diante. | `ON N GOTO 100,200,300` |
| `ONERR` | `ONERR GOTO <linha>` | Define uma linha de tratamento para erro. | `ONERR GOTO 900` |
| `REM` | `REM <texto>` | Comentário; o resto da linha é ignorado. | `REM sem efeito` |
| `END` | `END` | Encerra o programa normalmente. | `END` |
| `STOP` | `STOP` | Interrompe o programa com erro/parada. | `STOP` |

## Variáveis, entrada e dados

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `DIM` | `DIM (<dim 1>[,<dim 2>[,...]])` | Reserva espaço para array. | `DIM A(10,20)` |
| `INPUT` | `INPUT ["texto";] <var>` | Lê valores do teclado e grava na variável. Se houver texto, ele aparece antes da leitura. | `INPUT "Nome"; N$` |
| `GET` | `GET <var>` | Lê um único caractere/valor do teclado. | `GET K$` |
| `READ` | `READ <var>[,<var>...]` | Lê valores dos blocos `DATA`. | `READ A$,B` |
| `RESTORE` | `RESTORE` | Volta o ponteiro de leitura do `DATA` para o começo. | `RESTORE` |
| `DATA` | `DATA <valor>[,<valor>...]` | Guarda valores que serão consumidos por `READ`. | `DATA 1,2,3` |
| `CLEAR` | `CLEAR` | Limpa todas as variáveis. | `CLEAR` |

## Tela e modo de vídeo

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `CLS` | `CLS` | Limpa a tela atual. | `CLS` |
| `SCREEN` | `SCREEN <modo>[,<sprite>]` | Troca o modo de vídeo. `modo` pode ser `0` texto, `1` multicolor, `2` G2. O segundo parâmetro ajusta o modo/tamanho de sprite. | `SCREEN 2,0` |
| `LOCATE` | `LOCATE <x>,<y>` | Posiciona o cursor na tela de texto. | `LOCATE 10,5` |
| `COLOR` | `COLOR <fg>,<bg>` / `COLOR <fg>` / `COLOR ,<bg>` | Ajusta as cores atuais de frente e fundo. | `COLOR 15,1` |

## Gráficos

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `PLOT` | `PLOT <x>,<y>` | Desenha um ponto/pixel na posição informada. | `PLOT 20,10` |
| `LINE` | `LINE x,y TO x,y [TO x,y...]` | Desenha uma linha ou sequência de segmentos. | `LINE 10,10 TO 100,10 TO 100,50` |
| `CIRCLE` | `CIRCLE x,y,rh[,rv]` | Desenha um círculo ou ovoide. `rv` é opcional. | `CIRCLE 120,80,20` |
| `RECT` | `RECT x1,y1,x2,y2` | Desenha as bordas de um retângulo. | `RECT 10,10,80,40` |
| `PAINT` | `PAINT x,y,c` | Flood fill a partir de um ponto, preenchendo a área conectada com a cor `c`. | `PAINT 30,20,4` |
| `FILL` | `FILL <x1>,<y1>,<x2>,<y2>,<cor>` | Preenche um retângulo definido, direto na VDP, com a cor informada. | `FILL 10,10,60,40,3` |

## Sprites

| Comando | Sintaxe | O que faz | Exemplo |
|---|---|---|---|
| `SPRITESET` | `SPRITESET <number>,<var$>` | Carrega o padrão bruto de sprite a partir de uma string. | `SPRITESET 0,S$` |
| `SPRITEPUT` | `SPRITEPUT <number>,<plano>,<x>,<y>,<cor>` | Ativa o sprite, define plano, posição e cor inicial. | `SPRITEPUT 0,1,100,80,15` |
| `SPRITECOLOR` | `SPRITECOLOR <number>,<cor>` | Muda só a cor de um sprite já ativo. | `SPRITECOLOR 0,7` |
| `SPRITEPOS` | `SPRITEPOS <number>,<x>,<y>` | Move um sprite já ativo. | `SPRITEPOS 0,120,90` |

## Palavras-chave auxiliares

Estas palavras existem no BASIC, mas não são comandos independentes:
`THEN`, `TO`, `STEP`, `AT`.

## Notas rápidas

- `PAINT` é flood fill por área conectada.
- `FILL` é preenchimento de retângulo.
- Os comandos gráficos e de sprite exigem modo gráfico compatível, geralmente `SCREEN 2` para G2.
- `PRINT`, `INPUT`, `READ` e `DATA` aceitam strings e números conforme o contexto.
