/*
Auteur : Mascaro Valentin, Marco Gazzera
Version :  0.1
Date derniere modif : 10.03.2022
Resume : Gère la table de donnée en vue de la vérification sémantique.
*/

#ifndef _STRUCTURE_H
#define _STRUCTURE_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define TAILLE 103
int ACC;
typedef struct _symbole{
	char *label;
	//int adress_de_def;
	//int valeur;
	char *type_symbol ;
} symbole;

/* Créer un tableau de tous les symboles */
struct symbole *TABLE[TAILLE];
/*
typedef struct _struct{
	//char *name_ptr;
	int adress; //adress de la 1 ère valeur
	int nbr_param; 
	param *parameters;
}structu;

typedef struct _param{
	_symbole;
	* param suivant;
}param;

typedef struct _memoire{
	type enum{ int, struct};
	//int adress;
	int index; // Numero pour liste chainée 
	_symbole symbole_du_symbol;
	_struct structure_du_struct;
	* memoire suivant;
}memoire;*/

void nouvelle_adresse();
symbole *creer_symbole(char* label_t, char* type_t);
void verif_redefinition(char *label);
#endif