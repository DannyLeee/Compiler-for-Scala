%{
/* C Declarations and Includes */
#include <string.h>
#include <ctype.h>
#define LIST     strcat(buf,yytext)
#define TOUPPER(s, temp) for (int i = 0; i < strlen(s); i++) {temp[i] = toupper(s[i]); temp[i+1] = 0;} 
#define token(t) {LIST; printf("<'%s'>\n",t);}
#define tokenKeyword(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s: %d>\n",t,atoi(i));}
#define tokenFloat(t,f) {LIST; printf("<%s: %f>\n",t,atof(f));}
#define tokenString(t,s) {LIST; printf("<%s%s>\n",t,s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];

/* symbol table */
typedef struct entry {
	char* name;
	struct entry* next;
}Entry;

Entry* create();
int lookup(Entry* entry, const char* str);
int insert(Entry* entry, const char* str);
int dump(Entry* entry);

Entry* sTable;
%}

/* regular definition */
/* symbol */
delimiters  [,:.;()\[\]{}]
arithmetic   [+\-*/]

/* keyword */
keyword     boolean|break|char|case|class|continue|def|do|else|exit|false|float|for|if|int|null|object|print|println|repeat|return|string|to|true|type|val|var|while

/* relational */
relational  <|<=|>=|>|==|!=

/* basic component */
alphabet    [a-zA-Z]
digit       [0-9]

/* identifier*/
/* [a-zA-Z][a-zA-Z0-9]* */
id          {alphabet}+({alphabet}*{digit}*)*

/* number system */
integer     {digit}+
plain_real  {digit}+"."{digit}+ 
expreal     [+-]?{digit}+"."{digit}+[Ee][+-]?{digit}+
real        {plain_real}|{expreal}

/* state */
%x C_COMMENT
%x COMMENT

%%
    /* Delimiters */
    /* [,:.;()\[\]{}]      {token(yytext);} */
{delimiters}    {token(yytext);}

    /* Arithmetic */
{arithmetic}    {token(yytext);}

    /* Remainder */
"%"     {token(yytext);}

    /* Relational */
{relational}     {token(yytext);}

    /* Logical */
&&|"||"|!      {token(yytext);}

    /* Keywords*/
{keyword}   {
    char temp[16];
    TOUPPER(yytext, temp);
    tokenKeyword(temp);
}

    /* identifiers */
{id}        {
    tokenString("id: ", yytext);
    char *temp = malloc(sizeof(char) * (yyleng + 1));
    strcpy(temp, yytext);
    insert(sTable, temp);
}

    /* integer */
{integer}   {tokenInteger("integer", yytext);}

    /* Real */
{real}  {tokenFloat("real", yytext);}

    /* string */
\"[^"]*\"    {
    char c = input();   // next character   // yytext no change
    if (c == '\"') {
        unput(c);
        yymore();   // yytext no change            
    }
    else {
        char * temp = malloc(sizeof(char) * (yyleng - 2 + 1));
        strcpy(temp, yytext);
        
        char *l, *r;
        for (int i = 0; i < strlen(temp); i++)
        {
            if (temp[i] == '\"' && temp[i + 1] == '\"')
            {
                l = malloc(sizeof(char) * (i + 1));
                strcpy(l, temp);
                l[i] = 0;
                r = malloc(sizeof(char) * (strlen(temp) - i + 1));
                strcpy(r, temp + i + 1);
                
                strcat(l, r);
                memset(temp, 0, strlen(temp));
                strcpy(temp,l);
                free(l);
                free(r);
            }
        }

        strcpy(temp, temp + 1);
        temp[strlen(temp) - 1] = 0;
        tokenString("string:", temp);
        free(temp);
        unput(c);   // yytext no change
    }
}

    /* single line comment */
"//"        {
    LIST;
    BEGIN(COMMENT);
}

<COMMENT>\n {
    LIST;
    printf("%d: %s", linenum++, buf);
    memset(buf, 0, MAX_LINE_LENG);
    BEGIN(INITIAL);
}

<COMMENT>.  {LIST;}

    /* multi lines comment */
"/*"    {
    LIST;
    BEGIN(C_COMMENT);
}
<C_COMMENT>"*/" {
    LIST;
    BEGIN(INITIAL);
}
<C_COMMENT>\n   {
    LIST;
    printf("%d: %s", linenum++, buf);
    memset(buf, 0, MAX_LINE_LENG);
}
<C_COMMENT>.    {LIST;}

\n      {
            LIST;
            printf("%d: %s", linenum++, buf);
            memset(buf, 0, MAX_LINE_LENG);
        }

[ \t]*  {LIST;}

.       {
            LIST;
            printf("%d:%s\n", linenum+1, buf);
            printf("bad character:'%s'\n",yytext);
            exit(-1);
        }

%%
int main (int argc, char* argv[]) {
    sTable = create();
    yyin = fopen(argv[1], "r");
    yylex();
    printf("\nSymbol Table:\n");
    dump(sTable);
    free(sTable);
    fclose(yyin);
}

yywrap() {
    printf("%d: %s\n", linenum, buf);
    return 1;
}

Entry* create() {
	Entry* sTable = malloc(sizeof(struct entry));
	sTable->name = "";
	sTable->next = NULL;
	return sTable;
}

int lookup(Entry* entry, const char* str) {
	if (entry == NULL)
		return -1;
	for (int i = 0; entry != NULL; i++) {
		if (strcmp(entry->name, str) == 0)
			return i;
		entry = entry->next;
	}
	return -1;
}

int insert(Entry* entry, const char* str) {
	if (entry == NULL)
		return -1;
	int i;
    if (lookup(entry, str) == -1) {
        for (i = 0; entry != NULL; i++) {
            if (entry->next == NULL)
                break;
            entry = entry->next;
        }
        Entry* new_entry = malloc(sizeof(Entry));
        entry->next = new_entry;
        entry->name = str;
        new_entry->name = "";
        new_entry->next = NULL;
        return i;
    }
    return -1;
}

int dump(Entry* entry) {
	if (entry == NULL)
		return -1;
	int i;
	for (i = 0; entry->next != NULL; i++) {
		printf("%s\n", entry->name);
		entry = entry->next;
	}
	return i;
}