#ifndef STABLE
#define STABLE

// #include <stdlib.h>
// #include <cstdlib>
#include <string.h>
#include <ctype.h>
// #include <stdio.h>
#include <iostream>

/* symbol table entry */
typedef struct entry {
	char* name;
	struct entry* next;
}Entry;

Entry* create();
int lookup(Entry* entry, const char* str);
int insert(Entry* entry, char* str);
int dump(Entry* entry);
#endif