%{
/* C Declarations and Includes */
// #include <stdio.h>
#include <string.h>
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",t,i);}
#define tokenFloat(t,f) {LIST; printf("<%s:%f>\n",t,f);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
%}

/* regular definition */
delimiters  [,:.;()\[\]{}]
arithmetic   [+\-*/]

alphabet    [a-zA-Z]
digit       [0-9]

    /* [a-zA-Z][a-zA-Z0-9]* */
id          {alphabet}+({alphabet}*{digit}*)*
integer     {digit}+


%%

    /* Delimiters */
    /* [,:.;()\[\]{}]      {token(yytext);} */
{delimiters}    {token(yytext);}

    /* Arithmetic */
{arithmetic}    {token(yytext);}

    /* Remainder */
"%"     {token(yytext);}

    /* Relational */
"<"     {token(yytext);}
"<="    {token(yytext);}
">="    {token(yytext);}
">"     {token(yytext);}
"=="    {token(yytext);}
"!="    {token(yytext);}

    /* Logical */
&&      {token(yytext);}
"||"    {token(yytext);}
!       {token(yytext);}


    /* Keywords*/
boolean     {token(yytext);}
break       {token(yytext);}
char        {token(yytext);}
case        {token(yytext);}
class       {token(yytext);}
continue    {token(yytext);}
def         {token(yytext);}
do          {token(yytext);}
else        {token(yytext);}
exit        {token(yytext);}
false       {token(yytext);}
float       {token(yytext);}
for         {token(yytext);}
if          {token(yytext);}
int         {token(yytext);}
null        {token(yytext);}
object      {token(yytext);}
print       {token(yytext);}
println     {token(yytext);}
repeat      {token(yytext);}
return      {token(yytext);}
string      {token(yytext);}
to          {token(yytext);}
true        {token(yytext);}
type        {token(yytext);}
val         {token(yytext);}
var         {token(yytext);}
while       {token(yytext);}

    /* identifiers */
{id}        {tokenString("id", yytext);}

    /* integer */
{integer}   {tokenInteger("integer", atoi(yytext));}


\n      {
            LIST;
            printf("%d: %s", linenum++, buf);
            buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {

        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%
