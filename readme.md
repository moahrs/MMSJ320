# MMSJ-320 - Referência Rápida de Comandos

Este documento reúne os comandos do Monitor e do MMSJOS no mesmo estilo da referência do BASIC.

Base: parser real dos arquivos `monitor.c` e `mmsjos.c`.

## Observações gerais

- O parser converte comandos para maiúsculas, então `ls` e `LS` funcionam igual.
- Comandos marcados como `TBD` existem no parser, mas ainda não têm implementação útil.
- Quando houver dúvida de endereço/parâmetro de baixo nível, prefira hexadecimal.

## Monitor

| Comando | Sintaxe | O que faz | Exemplo | Observações |
|---|---|---|---|---|
| `CLS` | `CLS` | Limpa a tela. | `CLS` |  |
| `CLEAR` | `CLEAR` | Limpa a tela (equivalente a `CLS`). | `CLEAR` |  |
| `VER` | `VER` | Mostra a versão da BIOS/Monitor. | `VER` |  |
| `LOAD` | `LOAD [endereco_hex]` | Recebe programa pela serial, protocolo xmodem 128, e carrega na memória. | `LOAD 00810000` | Sem endereço usa padrão interno, 00850000h. |
| `LOAD2` | `LOAD2 [endereco_hex]` | Recebe programa pela serial, protocolo xmodem 1k CRC, e carrega na memória. | `LOAD2 00810000` | Sem endereço usa padrão interno, 00850000h. |
| `RUN` | `RUN <endereco_hex>` | Executa código em memória. | `RUN 00810000` | Sem argumento usa `00810000h`. |
| `BASIC` | `BASIC` | Entra no BASIC/chama `runBasic`. | `BASIC` |  |
| `MODE` | `MODE <modo>` | a definir | `MODE <modo>` | a definir |
| `POKE` | `POKE <endereco_hex> <valor_hex>` | Escreve valor em endereço de memória. | `POKE 00600000 FF` |  |
| `LOADSO` | `LOADSO` | Carrega o sistema operacional do disco. | `LOADSO` |  |
| `RUNSO` | `RUNSO` | Executa o sistema operacional previamente carregado. | `RUNSO` |  |
| `DEBUG` | `DEBUG` | Alterna modo de depuração (on/off). | `DEBUG` |  |
| `DUMP` | `DUMP <endereco_hex> <quantidade> <colunas>` | Dump de memória em formato geral. | `DUMP 006020A0 128` |  |
| `DUMPS` | `DUMPS <endereco_hex> <quantidade>` | Dump de memória para serial. | `DUMPS 006020A0 128` |  |
| `DUMPW` | `DUMPW <endereco_hex> <quantidade>` | Dump de memória em formato de janela. | `DUMPW 006020A0 128` |  |

## MMSJOS

| Comando | Sintaxe | O que faz | Exemplo | Observações |
|---|---|---|---|---|
| `CLS` | `CLS` | Limpa a tela. | `CLS` |  |
| `CLEAR` | `CLEAR` | Limpa a tela (equivalente a `CLS`). | `CLEAR` |  |
| `QUIT` | `QUIT` | Sai do prompt (retorna código 99). | `QUIT` |  |
| `VER` | `VER` | Mostra a versão do MMSJOS. | `VER` |  |
| `MGUI` | `MGUI` | Inicia a interface gráfica MGUI. | `MGUI` |  |
| `BASIC` | `BASIC [arquivo]` | Chama o BASIC em Flash ROM e pode executar arquivo automaticamente. | `BASIC COBE.BAS` | Também aceita `BASIC` sem argumento. |
| `PWD` | `PWD` | Mostra o diretório atual. | `PWD` |  |
| `LS` | `LS [caminho_ou_wildcard]` | Lista arquivos e diretórios. | `LS *.BIN` | Suporta caminho e wildcard. |
| `RM` | `RM <arquivo_ou_wildcard>` | Remove arquivo(s). | `RM *.BAK` | Suporta wildcard. |
| `CP` | `CP <origem> <destino>` | Copia arquivo(s). | `CP *.BIN /MGUI/PROGS` | Wildcard na origem; destino pode ser pasta. |
| `REN` | `REN <arquivo> <novo_nome>` | Renomeia arquivo. | `REN ANTIGO.TXT NOVO.TXT` | Destino deve ser nome válido; sem wildcard. |
| `MD` | `MD <diretorio>` | Cria diretório. | `MD PROJETOS` |  |
| `CD` | `CD <diretorio>` | Muda diretório atual. | `CD /MGUI` | Trata também `..` e `/`. |
| `RD` | `RD <diretorio>` | Remove diretório. | `RD TEMP` |  |
| `STOF` | `STOF <arquivo>` | Recebe via serial, protocolo xmodem 1k CRC, e grava em arquivo. | `STOF TESTE.BIN` |  |
| `STOR` | `STOR <endereço memoria>` | Recebe via serial, protocolo xmodem 1k CRC, e executa via rotina do SO. | `STOR 00870000` |  |
| `DATE` | `DATE [parametros]` | Comando reservado. | `DATE` | `TBD` |
| `TIME` | `TIME [parametros]` | Comando reservado. | `TIME` | `TBD` |
| `FORMAT` | `FORMAT <rotulo_ou_parametro>` | Formata unidade com `fsFormat(0x5678, argumento)`. | `FORMAT DISCO` | Significado exato do argumento ainda precisa confirmação. |
| `MODE` | `MODE <parametros>` | Comando reservado | `MODE <parametros>` | `TBD` |
| `CAT` | `CAT <arquivo>` | Mostra conteúdo de arquivo. | `CAT LEIAME.TXT` |  |

## Execução implícita de .BIN (MMSJOS)

| Sintaxe | O que faz | Exemplo | Observações |
|---|---|---|---|
| `<programa>` | Se não for comando interno, o MMSJOS procura `<programa>.BIN`, carrega em memória, 00880000h e executa. | `EDIT` | Internamente transforma para `<comando>.BIN` antes da busca. |

## Notas de uso

- Wildcards com suporte explícito em `LS`, `RM` e `CP`.
- Caminhos usam `/`.
- Pendências para fechar depois:
  - Confirmar modos válidos de `MODE` no Monitor.
  - Confirmar parâmetro aceito por `BASIC` no Monitor.
  - Confirmar significado exato do argumento de `FORMAT` no MMSJOS.
  - Completar `DATE`, `TIME` e `MODE` no MMSJOS quando forem implementados.
