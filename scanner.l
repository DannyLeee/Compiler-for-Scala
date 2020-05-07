%{
/* C Declarations and Includes */
#include <string.h>
#include <ctype.h>
#define LIST     strcat(buf,yytext)
#define TOUPPER(s, temp) for (int i = 0; i < strlen(s); i++) {temp[i] = toupper(s[i]); temp[i+1] = 0;} 
#define token(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s: %d>\n",t,atoi(i));}
#define tokenFloat(t,f) {LIST; printf("<%s: %f>\n",t,atof(f));}
#define tokenString(t,s) {LIST; printf("<%s: %s>\n",t,s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
int bufPt = 0;
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
&&|\|\||!      {token(yytext);}

    /* Keywords*/
{keyword}   {
    char temp[16];
    TOUPPER(yytext, temp);
    token(temp);
}

    /* identifiers */
{id}        {tokenString("id", yytext);}

    /* integer */
{integer}   {tokenInteger("integer", yytext);}

  /* Real */
{real}  {tokenFloat("real", yytext);}

    /* single line comment */
\/\/    {
    char c;
    bufPt = 2;
    LIST;
    while((c = input()) != '\n') {
        buf[bufPt] = c;
        buf[bufPt + 1] = 0;
        bufPt++;
    }
    unput(c);
}

    /* multi lines comment */
"/*"    {
    LIST;
    bufPt = 2;
    BEGIN(C_COMMENT);
}
<C_COMMENT>"*/" {
    LIST;
    BEGIN(INITIAL);
}
<C_COMMENT>\n   {
    LIST;
    printf("%d: %s", linenum++, buf);
    buf[0] = '\0';
    bufPt = 0;
}
<C_COMMENT>.    {
    LIST;
    bufPt++;
}

\n      {
            LIST;
            printf("%d: %s", linenum++, buf);
            buf[0] = '\0';
            bufPt = 0;
        }

[ \t]*  {LIST;}

.       {
            LIST;
            printf("%d:%s\n", linenum+1, buf);
            printf("bad character:'%s'\n",yytext);
            exit(-1);
        }
%%
