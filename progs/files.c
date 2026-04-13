/********************************************************************************
*    Programa    : files.c
*    Objetivo    : File Explorer for MMSJOS com MGUI
*    Criado em   : 25/12/2024
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 25/12/2024  0.1     Moacir Jr.   Criacao Versao Beta
* 23/01/2025  0.2     Moacir Jr.   Adaptação nova estrutura e uC/OS-II
*--------------------------------------------------------------------------------*/

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "../mmsj320vdp.h"
#include "../mmsj320mfp.h"
#include "../monitor.h"
#include "../mmsjos.h"
#include "../mgui.h"
#include "../monitorapi.h"
#include "../mmsjosapi.h"
#include "files.h"


//-----------------------------------------------------------------------------
// Principal
//-----------------------------------------------------------------------------
void main(void)
{
    unsigned char vcont, ix, iy, cc, dd, ee, cnum[20], *cfileptr, *cfilepos;
    unsigned char ikk, vnomefile[128], vnomefilenew[15], avdm2, avdm, avdl, vopc, vresp;
    unsigned long vtotbytes = 0;
    unsigned char vstring[64], vwb, my, corOpcFile, corOpcFileExec, corOpcDir, corDisable;
    unsigned char *vMemTail;
    unsigned char sqtdtam[10];
    void (*pCarregaDir)(void);
    char *(*pMyItoa)(int, char *, int);
    char *(*pMyLtoa)(long, char *, int);
    VDP_COLOR vdpcolor;
    MGUI_SAVESCR vsavescr;
    MGUI_MOUSE mouseData;
    MGUI_SAVESCR windowScr;


    writeLongSerial("Starting FILES...\r\n\0");

    //filesInitReloc();

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    writeLongSerial("Defining Pointers...\r\n\0");

    linhastatus = MMSJOS_FUNC_RELOC[FILES_RELOC_LINESTATUS_DEF];
    SearchFile = MMSJOS_FUNC_RELOC[FILES_RELOC_SEARCHFILE_DEF];
    carregaDir = MMSJOS_FUNC_RELOC[FILES_RELOC_CARREGADIR_DEF];
    listaDir = MMSJOS_FUNC_RELOC[FILES_RELOC_LISTADIR_DEF];
    mystrcpy = MMSJOS_FUNC_RELOC[FILES_RELOC_STRCPY];
    mystrcat = MMSJOS_FUNC_RELOC[FILES_RELOC_STRCAT];
    mymemset = MMSJOS_FUNC_RELOC[FILES_RELOC_MEMSET];
    mytoupper = MMSJOS_FUNC_RELOC[FILES_RELOC_TOUPPER];
    myitoa = MMSJOS_FUNC_RELOC[FILES_RELOC_ITOA];
    myltoa = MMSJOS_FUNC_RELOC[FILES_RELOC_LTOA];
    myvRetAlloc = MMSJOS_FUNC_RELOC[FILES_RELOC_VRETALLOC];

    if ((unsigned long)mystrcpy < 0x00010000UL)
        mystrcpy = strcpy;
    if ((unsigned long)mystrcat < 0x00010000UL)
        mystrcat = strcat;
    if ((unsigned long)mymemset < 0x00010000UL)
        mymemset = memset;
    if ((unsigned long)mytoupper < 0x00010000UL)
        mytoupper = toupper;
    if ((unsigned long)myitoa < 0x00010000UL)
        myitoa = itoa;
    if ((unsigned long)myltoa < 0x00010000UL)
        myltoa = ltoa;

    // Copias locais dos ponteiros para o trecho critico de bootstrap.
    // Isso evita depender de leitura dos globais via base register entre chamadas.
    pCarregaDir = carregaDir;
    pMyItoa = myitoa;
    pMyLtoa = myltoa;

    // Reserva apenas o necessario para os globais do explorer.
    // fsMalloc usa a mesma heap do malloc() usado pelo SaveScreenNew.
    writeLongSerial("Alloc memory to variables...\r\n\0");

    vMemTotal = (unsigned char *)fsMalloc(sizeof(LIST_DIR) + 64);

    if (vMemTotal == 0)
    {
        writeLongSerial("FILES: sem memoria\r\n\0");
        TrocaSpriteMouse(MOUSE_POINTER);
        return;
    }

    // Layout fixo: LIST_DIR no inicio do bloco; variaveis pequenas no final.
    dfile = (LIST_DIR *)vMemTotal;
    vMemTail = vMemTotal + sizeof(LIST_DIR);
    vpos = (unsigned short *)vMemTail;
    vposold = (unsigned short *)(vMemTail + 2);
    dFileCursor = (unsigned char *)(vMemTail + 4);
    vcorfg = (unsigned char *)(vMemTail + 5);
    vcorbg = (unsigned char *)(vMemTail + 6);
    clinha = (unsigned char *)(vMemTail + 8);

    writeLongSerial("Drawing interface...\r\n\0");

    // Pega as cores atuais
    getColorData(&vdpcolor);
    *vcorfg = vdpcolor.fg;
    *vcorbg = vdpcolor.bg;

    SaveScreenNew(&windowScr, 0, 0, 255, 191);

    // Cria a Janela
    vcont = 1;
    *vpos = 0;
    *vposold = 0xFF;
    vnomefile[0] = 0x00;

    // Prepara Cabeçalho
    DrawRect(0,18,255,10,*vcorfg);
    writesxy(16,20,8,"Name\0", *vcorfg, *vcorbg);
    writesxy(66,20,8,"Ext\0", *vcorfg, *vcorbg);
    writesxy(90,20,8,"Modify\0", *vcorfg, *vcorbg);
    writesxy(165,20,8,"Size\0", *vcorfg, *vcorbg);
    writesxy(200,20,8,"Atrib\0", *vcorfg, *vcorbg);

    // Carrega Diretorio
    writeLongSerial("FILES: before carregaDir [\0");
    pMyLtoa((unsigned long)pCarregaDir, sqtdtam, 16);
    writeLongSerial(sqtdtam);
    writeLongSerial("]-[");
    pMyLtoa((unsigned long)dfile, sqtdtam, 16);
    writeLongSerial(sqtdtam);
    writeLongSerial("]-[");
    pMyLtoa((unsigned long)windowScr, sqtdtam, 16);
    writeLongSerial(sqtdtam);
    writeLongSerial("]\r\n\0");
    pCarregaDir();
    writeLongSerial("FILES: after carregaDir\r\n\0");

    // Lista Diretorio
    writeLongSerial("FILES: before listaDir\r\n\0");
    listaDir();
    writeLongSerial("FILES: after listaDir\r\n\0");

    TrocaSpriteMouse(MOUSE_POINTER);

    // Loop Principal
    while (vcont)
    {
        setPosPressed(0,0); // vposty = 0;

        while (1)
        {
            getMouseData(&mouseData);

            if (mouseData.mouseButton == 0x02 || mouseData.mouseBtnDouble == 0x01)  // Direito ou DoubleClick Esquerdo
            {
                if (mouseData.vposty >= 34 && mouseData.vposty <= 170)
                {
                    ee = 99;
                    dd = 0;
                    while (ee == 99)
                    {
                        if (mouseData.vposty >= clinha[dd] && mouseData.vposty <= (clinha[dd] + 10) && clinha[dd] != 0)
                            ee = dd;

                        dd++;

                        if (dd > 13)
                            break;
                    }

                    corOpcFile = VDP_LIGHT_RED;
                    corOpcFileExec = VDP_LIGHT_RED;
                    corOpcDir = VDP_LIGHT_RED;
                    corDisable = VDP_LIGHT_RED;

                    if (ee != 99)
                    {
                        MostraIcone(8, clinha[ee], 6, VDP_DARK_GREEN, *vcorbg);

                        if (dfile->dir[ee].Attr[0] == ' ')
                        {
                            corOpcFile = *vcorfg;

                            if (dfile->dir[ee].Ext[0] == 'B' && dfile->dir[ee].Ext[1] == 'I' && dfile->dir[ee].Ext[2] == 'N')
                                corOpcFileExec = *vcorfg;
                        }
                        else
                            corOpcDir = *vcorfg;
                    }
                    else
                        corOpcDir = *vcorfg;

                    if (!mouseData.mouseBtnDouble)
                    {
                        if (ee != 99)
                            my = clinha[ee] + 8;
                        else
                            my = mouseData.vposty;

                        if (my + 46 > 190)
                            my = my - 52;

                        // Abre menu : Delete, Rename, Close
                        SaveScreenNew(&vsavescr,30,my,52,46);

                        FillRect(30,my,50,44,*vcorbg);
                        DrawRect(30,my,50,44,*vcorfg);

                        if (corOpcFile == *vcorfg)
                        {
                            writesxy(33,my+2,8,"Delete",*vcorfg,*vcorbg);
                            writesxy(33,my+10,8,"Rename",*vcorfg,*vcorbg);
                            writesxy(33,my+18,8,"Copy",*vcorfg,*vcorbg);
                            writesxy(33,my+26,8,"Execute",corOpcFileExec,*vcorbg);
                        }
                        else
                        {
                            if (ee != 99)
                                corDisable = *vcorfg;

                            writesxy(33,my+2,8,"Open",corDisable,*vcorbg);
                            writesxy(33,my+10,8,"New",*vcorfg,*vcorbg);
                            writesxy(33,my+18,8,"Remove",corDisable,*vcorbg);
                            writesxy(33,my+26,8," ",VDP_LIGHT_RED,*vcorbg);
                        }

                        DrawLine(30,my+34,80,my+34,*vcorfg);
                        writesxy(33,my+36,8,"Close",*vcorfg,*vcorbg);

                        vopc = 99;

                        while (1)
                        {
                            getMouseData(&mouseData);

                            if (mouseData.mouseButton == 0x01)  // Esquerdo
                            {
                                if (mouseData.vpostx >= 31 && mouseData.vpostx <= 138)
                                {
                                    if (mouseData.vposty >= my+2 && mouseData.vposty <= my+8 && corOpcFile == *vcorfg)
                                    {
                                        vopc = 0;
                                        break;
                                    }
                                    else if (mouseData.vposty >= my+10 && mouseData.vposty <= my+17 && corOpcFile == *vcorfg)
                                    {
                                        vopc = 1;
                                        break;
                                    }
                                    else if (mouseData.vposty >= my+18 && mouseData.vposty <= my+25 && corOpcFile == *vcorfg)
                                    {
                                        vopc = 2;
                                        break;
                                    }
                                    else if (ee != 99 && mouseData.vposty >= my+2 && mouseData.vposty <= my+8 && corOpcDir == *vcorfg)
                                    {
                                        vopc = 3;
                                        break;
                                    }
                                    else if (mouseData.vposty >= my+10 && mouseData.vposty <= my+17 && corOpcDir == *vcorfg)
                                    {
                                        vopc = 4;
                                        break;
                                    }
                                    else if (ee != 99 && mouseData.vposty >= my+18 && mouseData.vposty <= my+25 && corOpcDir == *vcorfg)
                                    {
                                        vopc = 5;
                                        break;
                                    }
                                    else if (mouseData.vposty >= my+26 && mouseData.vposty <= my+33 && corOpcFileExec == *vcorfg)
                                    {
                                        vopc = 6;
                                        break;
                                    }
                                    else if (mouseData.vposty >= my+44 && mouseData.vposty <= my+51)
                                    {
                                        vopc = 7;
                                        break;
                                    }
                                }
                            }

                            OSTimeDlyHMSM(0, 0, 0, 100);
                        }

                        RestoreScreen(vsavescr);
                    }
                    else
                    {
                        if (ee != 99)
                        {
                            if (corOpcDir == *vcorfg)   // Se for dir, entra na pasta
                                vopc = 3;
                            else if (corOpcFileExec == *vcorfg) // Se for .BIN executa
                                vopc = 6;
                        }
                    }

                    // Executa opcao selecionada
                    if (vopc == 0 || vopc == 5)  // Delete File && Delete Directory
                    {
                        // Deleta Arquivo
                        if (vopc == 0)
                            vresp = message("Confirm\nDelete File ?\0",(BTYES | BTNO), 0);
                        else
                            vresp = message("Confirm\nRemove Directory ?\0",(BTYES | BTNO), 0);

                        FillRect(8,clinha[ee],8,8,*vcorbg);

                        if (vresp == BTYES)
                        {
                            mystrcpy(vnomefile,dfile->dir[ee].Name);
                            if (dfile->dir[ee].Ext[0] != 0x00)
                            {
                                mystrcat(vnomefile,".");
                                mystrcat(vnomefile,dfile->dir[ee].Ext);
                            }


                            if (vopc == 0)
                            {
                                linhastatus(4, vnomefile);
                                vresp = fsDelFile(vnomefile);
                            }
                            else
                            {
                                linhastatus(6, vnomefile);
                                vresp = fsRemoveDir(vnomefile);
                            }

                            if (vresp >= ERRO_D_START)
                            {
                                if (vopc == 0)
                                    message("Delete File Error.\0",(BTCLOSE), 0);
                                else
                                    message("Remove Directory Error.\0",(BTCLOSE), 0);
                            }
                            else
                            {
                                carregaDir();
                                listaDir();
                            }
                        }

                        break;
                    }
                    else if (vopc == 1 || vopc == 2 || vopc == 4) // Rename (1) / Copy (2) File & Create Directory (4)
                    {
                        // Renomeia Arquivo
                        linhastatus(1, "\0");

                        // Abre janela para pedir novo nome
                        vstring[0] = '\0';

                        SaveScreenNew(&vsavescr,10,40,240,60);

                        switch (vopc)
                        {
                            case 1:
                                linhastatus(5, "\0");
                                showWindow("Rename File",10,40,240,50, BTNONE);
                                writesxy(12,57,8,"   New Name:",*vcorfg,*vcorbg);
                                break;
                            case 2:
                                linhastatus(8, "\0");
                                showWindow("Copy File",10,40,240,50, BTNONE);
                                writesxy(12,57,8,"Destination:",*vcorfg,*vcorbg);
                                break;
                            case 4:
                                linhastatus(9, "\0");
                                showWindow("Create Directory",10,40,240,50, BTNONE);
                                writesxy(12,57,8,"   Dir Name:",*vcorfg,*vcorbg);
                                break;
                        }

                        fillin(&vstring, 80, 57, 130, WINDISP);
                        button("OK", 18, 78, 44, 10, WINDISP);
                        button("CANCEL", 66, 78, 44, 10, WINDISP);

                        while (1)
                        {
                            fillin(&vstring, 80, 57, 130, WINOPER);

                            if (button("OK", 18, 78, 44, 10, WINOPER))
                            {
                                vwb = BTOK;
                                break;
                            }

                            if (button("CANCEL", 66, 78, 44, 10, WINOPER))
                            {
                                vwb = BTCANCEL;
                                break;
                            }

                            OSTimeDlyHMSM(0, 0, 0, 100);
                        }

                        RestoreScreen(vsavescr);

                        if (vwb == BTOK) {
                            ix = 0;
                            while(vstring[ix])
                            {
                                vnomefilenew[ix] = mytoupper(vstring[ix]);
                                ix++;
                            }

                            vstring[ix] = 0x00;

                            switch (vopc)
                            {
                                case 1:
                                    mystrcpy(vnomefile,"Confirm\nRename File ?\n\0");
                                    break;
                                case 2:
                                    mystrcpy(vnomefile,"Confirm\nCopy File ?\n\0");
                                    break;
                                case 4:
                                    mystrcpy(vnomefile,"Confirm\nCreate Directory ?\n\0");
                                    break;
                            }

                            mystrcat(vnomefile, vstring);

                            vresp = message(vnomefile,(BTYES | BTNO), 0);

                            if (vresp == BTYES)
                            {
                                if (ee != 99)
                                {
                                    if (vopc == 1)
                                    {
                                        mystrcpy(vnomefile,dfile->dir[ee].Name);
                                    }
                                    else if (vopc == 2)
                                    {
                                        mystrcpy(vnomefile,"CP ");
                                        mystrcat(vnomefile,dfile->dir[ee].Name);
                                    }

                                    if (dfile->dir[ee].Ext[0] != 0x00)
                                    {
                                        mystrcat(vnomefile,".");
                                        mystrcat(vnomefile,dfile->dir[ee].Ext);
                                    }
                                }

                                switch (vopc)
                                {
                                    case 1:
                                        linhastatus(5, vnomefile);
                                        vresp = fsRenameFile(vnomefile,vnomefilenew);
                                        break;
                                    case 2:
                                        linhastatus(8, vnomefile);
                                        mystrcat(vnomefile," ");
                                        mystrcat(vnomefile,vnomefilenew);
                                        vresp = fsOsCommand(vnomefile);
                                        break;
                                    case 4:
                                        linhastatus(9, vnomefile);
                                        vresp = fsMakeDir(vnomefilenew);
                                        break;
                                }

                                if (vresp >= ERRO_D_START)
                                {
                                    switch (vopc)
                                    {
                                        case 1:
                                            message("Rename File Error.\0",(BTCLOSE), 0);
                                            break;
                                        case 2:
                                            message("Copy File Error.\0",(BTCLOSE), 0);
                                            break;
                                        case 4:
                                            message("Create Directory Error.\0",(BTCLOSE), 0);
                                            break;
                                    }
                                }
                                else
                                {
                                    carregaDir();
                                    listaDir();
                                }
                            }
                        }

                        linhastatus(0, "\0");

                        if (ee != 99)
                            FillRect(8,clinha[ee],8,8,*vcorbg);

                        break;
                    }
                    else if (vopc == 3) // Enter Directory  // Usar click duplo tb
                    {
                        FillRect(8,clinha[ee],8,8,*vcorbg);

                        mystrcpy(vnomefile,dfile->dir[ee].Name);

                        if (dfile->dir[ee].Ext[0] != 0x00)
                        {
                            mystrcat(vnomefile,".");
                            mystrcat(vnomefile,dfile->dir[ee].Ext);
                        }

                        linhastatus(5, vnomefile);

                        vresp = fsChangeDir(vnomefile);

                        if (vresp >= ERRO_D_START)
                        {
                            message("Change Directory Error.\0",(BTCLOSE), 0);
                        }
                        else
                        {
                            carregaDir();
                            listaDir();
                        }

                        linhastatus(0, "\0");

                        break;
                    }
                    else if (vopc == 6) // Execute File .BIN    // Usar click duplo tb
                    {
                        FillRect(8,clinha[ee],8,8,*vcorbg);

                        mystrcpy(vnomefile,dfile->dir[ee].Name);
                        mystrcat(vnomefile,".");
                        mystrcat(vnomefile,dfile->dir[ee].Ext);

                        linhastatus(5, vnomefile);

                        // Chama Execução via SO
                        // vresp = xxxxxx.

                        linhastatus(0, "\0");

                        break;
                    }
                    else if (vopc == 7) // Close Menu
                    {
                        if (ee != 99)
                            FillRect(8,clinha[ee],8,8,*vcorbg);

                        break;
                    }
                }
            }
            else if (mouseData.mouseButton == 0x01)  // Esquerdo
            {
                if (mouseData.vposty > 170) {
                    // Ultima Linha
                    if (mouseData.vpostx > 5 && mouseData.vpostx <= 20) {               // Flecha Esquerda
                        *vposold = *vpos;
                        if (*vpos < 14)
                            *vpos = 0;
                        else
                            *vpos = *vpos - 14;

                        listaDir();

                        break;
                    }
                    else if (mouseData.vpostx >= 25 && mouseData.vpostx <= 40) {         // Flecha Direita
                        *vposold = *vpos;
                        *vpos = *vpos + 14;

                        listaDir();

                        break;
                    }
                    else if (mouseData.vpostx >= 100 && mouseData.vpostx <= 120) {       // Search
                        break;
                    }
                    else if (mouseData.vpostx >= 200 && mouseData.vpostx <= 220) {       // Sair
                        linhastatus(7,"\0");
                        vcont = 0;
                        break;
                    }
                }
            }

            OSTimeDlyHMSM(0, 0, 0, 100);
        }

        if (vcont)
            OSTimeDlyHMSM(0, 0, 0, 100);
    }

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    RestoreScreen(windowScr);

    TrocaSpriteMouse(MOUSE_POINTER);

    fsFree(vMemTotal);
}

//--------------------------------------------------------------------------
void linhastatusDef(unsigned char vtipomsgs, unsigned char * vmsgs)
{
    FillRect(2,176,252,13,*vcorbg);
    DrawRect(0,175,255,15,*vcorfg);

    switch (vtipomsgs) {
        case 0:
            MostraIcone(10, 180, 5,*vcorfg, *vcorbg);   // Icone <
            MostraIcone(30, 180, 6,*vcorfg, *vcorbg);   // Icone >
            MostraIcone(107, 180, 7,*vcorfg, *vcorbg);  // Icone Search
            MostraIcone(207, 180, 4,*vcorfg, *vcorbg);  // Icone Exit
            break;
        case 1:
            writesxy(7,180,8,"wait...\0",*vcorfg,*vcorbg);
            break;
        case 2:
            writesxy(7,180,8,"processing...\0",*vcorfg,*vcorbg);
            break;
        case 3:
            writesxy(7,180,8,"file not found...\0",*vcorfg,*vcorbg);
            break;
        case 4:
            writesxy(7,180,8,"Deleting file...\0",*vcorfg,*vcorbg);
            break;
        case 5:
            writesxy(7,180,8,"Renaming file...\0",*vcorfg,*vcorbg);
            break;
        case 6:
            writesxy(7,180,8,"Deleting Directory...\0",*vcorfg,*vcorbg);
            break;
        case 7:
            writesxy(7,180,8,"Exiting...\0",*vcorfg,*vcorbg);
            break;
        case 8:
            writesxy(7,180,8,"Copying File...\0",*vcorfg,*vcorbg);
            break;
        case 9:
            writesxy(7,180,8,"Creating Directory...\0",*vcorfg,*vcorbg);
            break;
    }

    if (*vmsgs)
        writesxy(151,180,8,vmsgs,*vcorfg,*vcorbg);
}

//--------------------------------------------------------------------------
void carregaDirDef(void)
{
    unsigned char vcont, ikk, ix, iy, cc, dd, ee, cnum[20];
    unsigned char vnomefile[32], dsize;
    unsigned char sqtdtam[10], cuntam;
    unsigned char vlen;
    unsigned char destIdx;
    unsigned long vtotbytes = 0, vqtdtam;
    FILES_DIR ddir;
    FILES_DIR *pDestDir;
    FAT32_DIR vdirfiles;

writeLongSerial("Aqui 332.666.2-[\0");
myitoa(dfile,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");

    if (vMemTotal == 0 || dfile == (LIST_DIR *)1 || dFileCursor == (unsigned char *)1)
    {
        writeLongSerial("CD0-INITERR\r\n\0");
        TrocaSpriteMouse(MOUSE_POINTER);
        return;
    }

    // Leitura dos Arquivos
    *dFileCursor = 0;
    dsize = sizeof(FILES_DIR);

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    // Logica de leitura Diretorio FAT32
    if (fsFindInDir(NULL, TYPE_FIRST_ENTRY) < ERRO_D_START)
    {
        while (1)
        {
            writeSerial('W');
            writeLongSerial("CD0-CALL\r\n\0");
            writeSerial('w');
            fsGetDirAtuData(&vdirfiles);
            writeLongSerial("CD0-RET\r\n\0");

            if (vdirfiles.Attr != ATTR_VOLUME && (vdirfiles.Name[0] != '.' || (vdirfiles.Name[0] == '.' && vdirfiles.Name[1] == '.' )))
            {
                if (*dFileCursor >= 150)
                {
                    break;
                }

                // Nome
                for (cc = 0; cc <= 7; cc++)
                {
                    if (vdirfiles.Name[cc] > 32)
                        ddir.Name[cc] = vdirfiles.Name[cc];
                    else
                        ddir.Name[cc] = '\0';
                }

                ddir.Name[8] = '\0';

                // Extensao
                for (cc = 0; cc <= 2; cc++)
                {
                    if (vdirfiles.Ext[cc] > 32)
                        ddir.Ext[cc] = vdirfiles.Ext[cc];
                    else
                        ddir.Ext[cc] = '\0';
                }

                ddir.Ext[3] = '\0';

                // Data Ultima Modificacao
                // Mes
                vqtdtam = (vdirfiles.UpdateDate & 0x01E0) >> 5;
                if (vqtdtam < 1 || vqtdtam > 12)
                    vqtdtam = 1;

                vqtdtam--;

                ddir.Modify[0] = vmesc[vqtdtam][0];
                ddir.Modify[1] = vmesc[vqtdtam][1];
                ddir.Modify[2] = vmesc[vqtdtam][2];
                ddir.Modify[3] = '/';

                // Dia
                vqtdtam = vdirfiles.UpdateDate & 0x001F;
			    mymemset(sqtdtam, 0x0, 10);
                myitoa(vqtdtam, sqtdtam, 10);

                if (vqtdtam < 10) {
                    ddir.Modify[4] = '0';
                    ddir.Modify[5] = sqtdtam[0];
                }
                else {
                    ddir.Modify[4] = sqtdtam[0];
                    ddir.Modify[5] = sqtdtam[1];
                }
                ddir.Modify[6] = '/';

                // Ano
                vqtdtam = ((vdirfiles.UpdateDate & 0xFE00) >> 9) + 1980;
                writeLongSerial("CD1\r\n\0");
				mymemset(sqtdtam, 0x0, 10);
                writeLongSerial("CD2\r\n\0");
                myitoa(vqtdtam, sqtdtam, 10);

                ddir.Modify[7] = sqtdtam[0];
                ddir.Modify[8] = sqtdtam[1];
                ddir.Modify[9] = sqtdtam[2];
                ddir.Modify[10] = sqtdtam[3];

                ddir.Modify[11] = '\0';

                // Tamanho
                if (vdirfiles.Attr != ATTR_DIRECTORY) {
                    // Reduz o tamanho a unidade (GB, MB ou KB)
                    vqtdtam = vdirfiles.Size;

                    if ((vqtdtam & 0xC0000000) != 0) {
                        cuntam = 'G';
                        vqtdtam = ((vqtdtam & 0xC0000000) >> 30) + 1;
                    }
                    else if ((vqtdtam & 0x3FF00000) != 0) {
                        cuntam = 'M';
                        vqtdtam = ((vqtdtam & 0x3FF00000) >> 20) + 1;
                    }
                    else if ((vqtdtam & 0x000FFC00) != 0) {
                        cuntam = 'K';
                        vqtdtam = ((vqtdtam & 0x000FFC00) >> 10) + 1;
                    }
                    else
                        cuntam = ' ';

                    // Transforma para decimal
                    writeLongSerial("CD3\r\n\0");
					mymemset(sqtdtam, 0x0, 10);
                    writeLongSerial("CD4\r\n\0");
                    myitoa(vqtdtam, sqtdtam, 10);

                    // Primeira Parte da Linha do dir, tamanho
                    for(ix = 0; ix <= 3; ix++) {
                        if (sqtdtam[ix] == 0)
                            break;
                    }

                    iy = (4 - ix);

                    for(ix = 0; ix <= 3; ix++) {
                        if (iy <= ix) {
                            ikk = ix - iy;
                            ddir.Size[ix] = sqtdtam[ikk];
                        }
                        else
                            ddir.Size[ix] = ' ';
                    }

                    ddir.Size[ix] = cuntam;
                }
                else {
                    ddir.Size[0] = ' ';
                    ddir.Size[1] = ' ';
                    ddir.Size[2] = ' ';
                    ddir.Size[3] = ' ';
                    ddir.Size[4] = '0';
                }

                ddir.Size[5] = '\0';

                // Atributos
                if (vdirfiles.Attr == ATTR_DIRECTORY) {
                    ddir.Attr[0] = '<';
                    ddir.Attr[1] = 'D';
                    ddir.Attr[2] = 'I';
                    ddir.Attr[3] = 'R';
                    ddir.Attr[4] = '>';
                }
                else {
                    ddir.Attr[0] = ' ';
                    ddir.Attr[1] = ' ';
                    ddir.Attr[2] = ' ';
                    ddir.Attr[3] = ' ';
                    ddir.Attr[4] = ' ';
                }

                ddir.Attr[5] = '\0';

                destIdx = *dFileCursor;
                pDestDir = &dfile->dir[destIdx];

                for (cc = 0; cc <= 8; cc++)
                    pDestDir->Name[cc] = ddir.Name[cc];

                for (cc = 0; cc <= 3; cc++)
                    pDestDir->Ext[cc] = ddir.Ext[cc];

                for (cc = 0; cc <= 11; cc++)
                    pDestDir->Modify[cc] = ddir.Modify[cc];

                for (cc = 0; cc <= 5; cc++)
                    pDestDir->Size[cc] = ddir.Size[cc];

                for (cc = 0; cc <= 5; cc++)
                    pDestDir->Attr[cc] = ddir.Attr[cc];

                pDestDir->posy = ddir.posy;
                *dFileCursor = *dFileCursor + 1;

            }

            // Verifica se tem mais Arquivos
            for (ix = 0; ix <= 7; ix++) {
                vnomefile[ix] = vdirfiles.Name[ix];
                if (vnomefile[ix] == 0x20) {
                    vnomefile[ix] = '\0';
                    break;
                }
            }

            vnomefile[ix] = '\0';

            if (vdirfiles.Name[0] != '.') {
                vnomefile[ix] = '.';
                ix++;
                for (iy = 0; iy <= 2; iy++) {
                    vnomefile[ix] = vdirfiles.Ext[iy];
                    if (vnomefile[ix] == 0x20) {
                        vnomefile[ix] = '\0';
                        break;
                    }
                    ix++;
                }
                vnomefile[ix] = '\0';
            }

            vlen = 0;
            while (vnomefile[vlen] != '\0') {
                vlen++;
                if (vlen > 12)
                    break;
            }

            writeLongSerial("CD5:[\0");
            writeLongSerial(vnomefile);
            writeLongSerial("]\r\n\0");

            if (fsFindInDir(vnomefile, TYPE_NEXT_ENTRY) >= ERRO_D_START)
			{
				writeLongSerial("CD6-BRK\r\n\0");
				break;
			}
            writeSerial('R');
			writeLongSerial("CD5-RET[\0");
            myitoa(dfile,sqtdtam,16);
            writeLongSerial(sqtdtam);
            writeLongSerial("]r\r\n\0");
            writeSerial('r');
        }

        writeLongSerial("CD9-OK\r\n\0");
    }
    else
    {
        writeLongSerial("CD1-ERR\r\n\0");
    }

    writeLongSerial("CDA-BEFORE-MOUSE\r\n\0");
    TrocaSpriteMouse(MOUSE_POINTER);
    writeLongSerial("CDB-AFTER-MOUSE\r\n\0");
}

//--------------------------------------------------------------------------
void listaDirDef(void)
{
    unsigned short pposy, vretfs, dd, ww, total;
    unsigned char ee, cc, ix, cstring[16];

    linhastatus(1, "\0");

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    for (dd = 0; dd <= 13; dd++)
        clinha[dd] = 0x00;

    pposy = 34;
    dd = *vpos;
    total = *dFileCursor;

    if (total > 150)
        total = 150;

    // Sem entradas carregadas: limpa area da listagem e sai.
    if (total == 0)
    {
        FillRect(5,34,249,140,*vcorbg);
        TrocaSpriteMouse(MOUSE_POINTER);
        linhastatus(0, "\0");
        return;
    }

    if (dd >= total)
        dd = (total - 1);

    if (dd > 149)
        dd = 149;

    ee = 14;
    cc = 0;

    while(1)
    {
        if (dd > 149 || dd >= total || cc >= 14)
            break;

        for (ix = 0; ix < 8; ix++)
        {
            if (dfile->dir[dd].Name[ix] == 0x00)
                cstring[ix] = 0x20;
            else
                cstring[ix] = dfile->dir[dd].Name[ix];
        }
        cstring[8] = '\0';

        // Nome
        writesxy(16,pposy,6,cstring,*vcorfg,*vcorbg);

        for (ix = 0; ix < 3; ix++)
        {
            if (dfile->dir[dd].Ext[ix] == 0x00)
                cstring[ix] = 0x20;
            else
                cstring[ix] = dfile->dir[dd].Ext[ix];
        }
        cstring[3] = '\0';

        // Ext
        writesxy(66,pposy,6,cstring,*vcorfg,*vcorbg);

        // Modif
        for (ix = 0; ix < 11; ix++)
        {
            if (dfile->dir[dd].Modify[ix] == 0x00)
                cstring[ix] = 0x20;
            else
                cstring[ix] = dfile->dir[dd].Modify[ix];
        }
        cstring[11] = '\0';
        writesxy(90,pposy,6,cstring,*vcorfg,*vcorbg);

        // Tamanho
        for (ix = 0; ix < 5; ix++)
        {
            if (dfile->dir[dd].Size[ix] == 0x00)
                cstring[ix] = 0x20;
            else
                cstring[ix] = dfile->dir[dd].Size[ix];
        }
        cstring[5] = '\0';
        writesxy(165,pposy,6,cstring,*vcorfg,*vcorbg);

        // Atrib
        for (ix = 0; ix < 5; ix++)
        {
            if (dfile->dir[dd].Attr[ix] == 0x00)
                cstring[ix] = 0x20;
            else
                cstring[ix] = dfile->dir[dd].Attr[ix];
        }
        cstring[5] = '\0';
        writesxy(200,pposy,6,cstring,*vcorfg,*vcorbg);

        clinha[cc] = pposy;
        pposy += 10;
        dd++;
        cc++;
        ee--;

        if (dd >= total)
            break;

        if (ee == 0)
            break;
    }

    if (ee > 0) {
        dd = 14 - ee;
        dd = dd * 10;
        dd = dd + 34;
        ww = ee * 10;
        FillRect(5,dd,249,ww,*vcorbg);
    }

    TrocaSpriteMouse(MOUSE_POINTER);

    linhastatus(0, "\0");
}

//--------------------------------------------------------------------------
void SearchFileDef(void)
{
}