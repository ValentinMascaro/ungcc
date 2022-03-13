/*
Auteur : Mascaro Valentin, Marco Gazzera
Version :  0.1
Date derniere modif : 10.03.2022
Resume : Gere la table de donnee en vue de la verification semantique.
*/

#ifndef _STRUCTURE_H
#define _STRUCTURE_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define TAILLE 103
int ACC;

enum type_arbre{
	MON_FONCTION, 
	MON_ITERATION,  // for / while  
	MON_IF,  // 
	MON_BLOC, // { }
	MON_RETURN, 
	MON_APPEL, // f ( )
	MON_VARIABLE,
	MON_DECLARATION,
	MON_AUTRE  // Gerer plus tard 
};

typedef struct _arbre {
	char *label ;  // ( a = 2;)  label = '='
	enum type_arbre type_arbre_t;  // a = 2  , type_arbre = 'affectation'
	struct _symbole *symbole_t; /* exemple :  a = 2 , c'est le symbole de cette ligne
	 								dont le type est celui de a */
	struct _arbre *frere_t; // a = 2;  a = 3 ; frere_t = arbre a = 3
	struct _arbre *fils_t; // a
	
}arbre;

typedef struct _symbole{
	char *label;
	char *type_symbol ;
	struct _symbole *frere;
	struct _param *param_t;
	int nb_param;
} symbole;

typedef struct _param{
	char *type_t;
	struct _param *suivant_t;
}param;
/* Creer un tableau de tous les symboles */
struct symbole *TABLE[TAILLE];

void nouvelle_adresse();
symbole *creer_symbole(char* label_t, char* type_t);
symbole *ajouter_symbole(symbole *actuel, symbole *futur);
void verif_redefinition(char *label);
char *find_type(symbole *expression1);
symbole *search_by_label(char *label);
void verif_type(symbole *expression1, symbole *expression2);

#endif