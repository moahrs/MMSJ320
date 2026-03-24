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
    unsigned long vSizeAloc = 0, izz;
    unsigned char sqtdtam[10];
    VDP_COLOR vdpcolor;
    MGUI_SAVESCR vsavescr;
    MGUI_MOUSE mouseData;
    MGUI_SAVESCR windowScr;

    linhastatus = linhastatusDef;
    carregaDir = carregaDirDef;
    listaDir = listaDirDef;
    SearchFile = SearchFileDef;
    myitoa = itoa;
    myltoa = ltoa;
    mytoupper = toupper;
    mystrcpy = strcpy;
    mystrcat = strcat;
    mymemset = memset;
    myvRetAlloc = vRetAlloc;

    // Reserva um tanto ja pra memoria de uso do programa de variaveis globais
    vMemTotal = fsMalloc(1024);

    // Define o endereço de cada variavel global dentro desse espaço
    vpos = vMemTotal;
    vposold = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vpos));
    dFileCursor = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vposold));
    vcorfg = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(dFileCursor));
    vcorbg = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vcorfg));
    clinha = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vcorbg));
    dfile = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(clinha) * 32); // 32 linhas de clinha

    // Pega as cores atuais
    getColorData(&vdpcolor);
    *vcorfg = vdpcolor.fg;
    *vcorbg = vdpcolor.bg;

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    SaveScreenNew(&windowScr, 0, 0, 255, 191);

    // Cria a Janela
    showWindow("File Explorer v0.2\0", 0, 0, 255, 191, BTNONE);

    vcont = 1;
    *vpos = 0;
    *vposold = 0xFF;
    vnomefile[0] = 0x00;

    // Prepara Cabeçalho
    FillRect(0,18,255,10,*vcorbg);
    DrawRect(0,18,255,10,*vcorfg);
    writesxy(16,20,8,"Name\0", *vcorfg, *vcorbg);
    writesxy(66,20,8,"Ext\0", *vcorfg, *vcorbg);
    writesxy(90,20,8,"Modify\0", *vcorfg, *vcorbg);
    writesxy(165,20,8,"Size\0", *vcorfg, *vcorbg);
    writesxy(200,20,8,"Atrib\0", *vcorfg, *vcorbg);

    // Carrega Diretorio
    carregaDir();

    // Lista Diretorio
    listaDir();

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
    unsigned long vtotbytes = 0, vqtdtam;
    FILES_DIR ddir;
    FAT32_DIR vdirfiles;

    // Leitura dos Arquivos
    *dFileCursor = 0;
    dsize = sizeof(FILES_DIR);
    dfile->pos = 0;

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    // Logica de leitura Diretorio FAT32
    if (fsFindInDir(NULL, TYPE_FIRST_ENTRY) < ERRO_D_START)
    {
        while (1)
        {
            fsGetDirAtuData(&vdirfiles);

			if (vdirfiles.Attr != ATTR_VOLUME && (vdirfiles.Name[0] != '.' || (vdirfiles.Name[0] == '.' && vdirfiles.Name[1] == '.' )))
            {
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
				mymemset(sqtdtam, 0x0, 10);
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
					mymemset(sqtdtam, 0x0, 10);
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

                dfile->dir[*dFileCursor] = ddir;
                dfile->pos = *dFileCursor;
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

			if (fsFindInDir(vnomefile, TYPE_NEXT_ENTRY) >= ERRO_D_START)
				break;
        }
    }

    TrocaSpriteMouse(MOUSE_POINTER);
}

//--------------------------------------------------------------------------
void listaDirDef(void)
{
    unsigned short pposy, vretfs, dd, ww;
    unsigned char ee, cc,ix, cstring[10];

    linhastatus(1, "\0");

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    for (dd = 0; dd <= 13; dd++)
        clinha[dd] = 0x00;

    pposy = 34;
    dd = *vpos;

    if (dd < 0)
        dd = 0;

    if (dd >= *dFileCursor)
        dd = (*dFileCursor - 1);

    ee = 14;
    cc = 0;

    while(1)
    {
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
        writesxy(90,pposy,6,dfile->dir[dd].Modify,*vcorfg,*vcorbg);

        // Tamanho
        writesxy(165,pposy,6,dfile->dir[dd].Size,*vcorfg,*vcorbg);

        // Atrib
        writesxy(200,pposy,6,dfile->dir[dd].Attr,*vcorfg,*vcorbg);

        clinha[cc] = pposy;
        pposy += 10;
        dd++;
        cc++;
        ee--;

        if (dd == *dFileCursor)
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