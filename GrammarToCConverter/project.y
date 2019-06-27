%{
#include <stdio.h>
#include <string.h>
extern FILE *yyin;
struct semantic{
	char nt[40];
	int expected_rule_count;
	int actual_rule_count;
	int defined;
	char contained_nonterminals[5000];
	int used;
};
int counter=0;
int i=0;
int flag=0;
int j=0;
int flag2=0;
int counter2=0;
int indexx;
int counter3;
struct semantic s[30];
%}

%union
{
char *string;
}
%token <string> FLOATRSW
%token <string> INTRSW
%token <string> NUMBERNONTERMINAL
%token <string> NONTERMINAL
%token <string> NUMBER
%token <string> PLUSOP
%token <string> MINUSOP
%token <string> DIVOP
%token <string> TIMES
%token <string> OR
%token <string> OPEN
%token <string> CLOSE
%token <string> RULESRSW
%token <string> ARROW
%token <string> SEMICOLMN
%left PLUSOP MINUSOP
%left TIMES DIVOP
%type <string> statement statements rulesdefinition singledefinition grammerdefinition  grammerrule op types paranthesis orrule

%%
statements:
	rulesdefinition statement{
		char grammar[10000]="#include <stdio.h>\ntypedef enum{INT,FLOAT,NUMBER,PLUSOP,MINUSOP,DIVOP,TIMES,MATHOP,OPEN,CLOSE,END} TOKEN;\nTOKEN *next=input; \n";
		strcat(grammar,$1);
		strcat(grammar,"\n");
		strcat(grammar,"int term(TOKEN tok){return *next++==tok;}\n");
		strcat(grammar,$2);
		for(int r=0;r<counter;r++)
		{
			char cpyarray[5000];
			sprintf(cpyarray,"int %s(){TOKEN *save=next;return %s1() ||",s[r].nt,s[r].nt);
			for(int p=0;p<s[r].actual_rule_count;p++)
			{
				char cpyarray2[1000];
				if(p!=s[r].actual_rule_count-1)
				{
					sprintf(cpyarray2,"(next=save, %s%d()) ||",s[r].nt,p+1);
					strcat(cpyarray,cpyarray2);
				}
				else
				{
					sprintf(cpyarray2,"(next=save, %s%d());}",s[r].nt,p+1);
					strcat(cpyarray,cpyarray2);
				}
				strcpy(cpyarray2," ");
			}
			strcat(grammar,cpyarray);
			strcat(grammar,"\n");
			strcpy(cpyarray," ");
		}
		char grammar2[8000];
		sprintf(grammar2,"int main(void){ \nif(%s()&&term(END)){\nprintf(\"Accept!\");\n}else{\nprintf(\"Reject!\");\n}\nreturn 0;\n}\n",s[counter-1].nt);
		strcat(grammar,grammar2);
		FILE *fp=fopen("grammar.c","w+");
		fprintf(fp,"%s",grammar);
		fclose(fp);
	};
statement:
	grammerdefinition statement
	{
		while(i<counter)
		{
			if(s[i].defined!=1)
			{
				printf("There is no grammer rule for %s\n",s[i].nt);
				exit(0);
			}
			if(s[i].actual_rule_count!=s[i].expected_rule_count)
			{
				printf("Expected rule count of %s is %d but you have %d rule/rules \n",s[i].nt,s[i].expected_rule_count,s[i].actual_rule_count);
				exit(0);
			}
			i++;
		}
		int m=0;
		while(counter-1>m)
		{
			int z=m+1;
			while(counter>z)
			{
				char array[2000];
				sprintf(array,"%s()",s[m].nt);
					if(strstr(s[z].contained_nonterminals,array)!=NULL) 
					{
						s[m].used=1;
					}	
				z++;		
			}
			m++;
		}
		for(int k=0;k<counter-1;k++)
		{
			if(s[k].used!=1)
			{
				printf("%s never used in this grammer \n",s[k].nt);
				exit(0);
			}
		}
		sprintf($$, "%s%s", $1,$2);
			
	}
	|
	{

		$$="";
	}
	;
rulesdefinition:
	RULESRSW singledefinition SEMICOLMN{
		$$=malloc(sizeof(char)*(strlen($2)+10));			
		sprintf($$, "%s", $2);
	};
singledefinition:
	NONTERMINAL NUMBER singledefinition{
		int h=0;
		while(h<counter)
		{
			if(!strcmp($1,s[h].nt))
			{
				printf("%s was defined in rules before \n",$1);
				exit(0);
			}
			h++;
			
		}
		if(atoi($2)<1)
		{
			printf("%s 's rule count cannot be less than 1 \n",$1);
			exit(0);
		}
		strcpy(s[counter].nt,$1);
		s[counter].expected_rule_count=atoi($2);
		s[counter].actual_rule_count=1;
		counter++;
		counter2=counter;
		counter3=counter;
		char array[4000];
		for(int k=0;k<atoi($2)+1;k++) 
		{
			if(k==0)
			{
				char array2[k];
				sprintf(array2,"int %s();",$1);
				strcpy(array,array2); 
			}
			else
			{
				char array2[k];
				char array3[k];
				sprintf(array3,"%d",k);
				sprintf(array2,"int %s%s();",$1,array3);
				strcat(array,array2);

			}	
		}
		$$=malloc(sizeof(char)*(strlen(array)+strlen($3)+10));
		sprintf($$, "%s%s",array,$3);
		
	}
	|
	{
		$$="";
	}
	;
grammerdefinition:
	NONTERMINAL ARROW grammerrule orrule SEMICOLMN
	{
		char pr2[1000];
		while(i<counter)
		{
			if(!strcmp($1,s[i].nt)) 
			{
				flag=1;
				if(s[i].defined==1)
				{
					printf("%s was defined before\n",s[i].nt);
					exit(0);
				}
				else{
					s[i].defined=1;
				}
				if(counter3-1!=i)
				{
					printf("Rules of %s defined in wrong place. Your rule definitions should be in same order with %%rules line's order \n",s[i].nt);
					exit(0);
				}
				indexx=i;
			}
			i++;
		}
		if(flag==0)
		{
			printf("%s is not declared in rules \n",$1);
			exit(0);
		}
		counter3--;
		i=0;
		flag=0;	
		sprintf(pr2, "%s",$4);
		sprintf(s[indexx].contained_nonterminals, "int %s1(){%s;}%s \n",s[counter2].nt,$3,$4);
		sprintf($$, "int %s1(){return %s;}%s \n", s[counter2].nt,$3,$4);
	
		
	};
orrule:
	OR grammerrule orrule{ 
		char array[1000]; 
		s[counter2].actual_rule_count++;
		sprintf(array,"%d",s[counter2].actual_rule_count);
		sprintf($$, "\nint %s%s(){return %s;}%s",s[counter2].nt,array,$2,$3);
	}
	|
	{
		counter2--;
		$$="";
	}
	;
	
grammerrule:
	NONTERMINAL grammerrule{
		while(i<counter)
		{
			if(!strcmp($1,s[i].nt))
			{
				flag2=1;
				break;
			}
			i++;
		}
		if(flag2!=1)
		{
			printf("%s is not defined in rules \n",$1);
			exit(0);
		}
		i=0;
		flag2=0;
		if(!strcmp($2,"")){
			sprintf($$, "%s()%s", $1,$2);
		}
		else
		{
			sprintf($$, "%s() && %s", $1,$2);
		}
	}
	|
	types grammerrule{
		if(!strcmp($2,"")){
			sprintf($$, "%s%s", $1,$2);
		}
		else
		{
			sprintf($$, "%s && %s", $1,$2);
		}
	}
	|
	paranthesis grammerrule{

		if(!strcmp($2,"")){
			sprintf($$, "%s%s", $1,$2);
		}
		else
		{
			sprintf($$, "%s && %s", $1,$2);
		}
	}
	|
	/*NUMBER grammerrule{
		if(!strcmp($2,"")){
			sprintf($$, "%s%s", $1,$2);
		}
		else
		{
			sprintf($$, "%s && %s", $1,$2);
		}
	}
	|*/
	op grammerrule{
		if(!strcmp($2,"")){
			sprintf($$, "%s%s", $1,$2);
		}
		else
		{
			sprintf($$, "%s && %s", $1,$2);
		}
	}
	|
	{
		$$="";
	}
	;
op:
	//PLUSOP { char array[]="term(PLUSOP)";sprintf($$, "%s", array);} 
	PLUSOP { char array[]="term(MATHOP)";sprintf($$, "%s", array);} 
	|
	//MINUSOP { char array[]="term(MINUSOP)";sprintf($$, "%s", array);}
	MINUSOP { char array[]="term(MATHOP)";sprintf($$, "%s", array);}
	|
	//DIVOP {char array[]="term(DIVOP)";sprintf($$, "%s", array);}
	DIVOP {char array[]="term(MATHOP)";sprintf($$, "%s", array);}
	|
	//TIMES {char array[]="term(TIMES)";sprintf($$, "%s", array);}
	TIMES {char array[]="term(MATHOP)";sprintf($$, "%s", array);}
	/*|
	NUMBER {char array[]="term(NUMBER)";sprintf($$, "%s", array);}*/
	;
types:
	INTRSW {char array[]="term(INT)";sprintf($$, "%s", array);}
	|
	FLOATRSW {char array[]="term(FLOAT)";sprintf($$, "%s", array);}
	|
	NUMBERNONTERMINAL{char array[]="term(NUMBER)";sprintf($$, "%s", array);}
	;		
paranthesis:
	OPEN {char array[]="term(OPEN)";sprintf($$, "%s", array);}
	|
	CLOSE {char array[]="term(CLOSE)";sprintf($$, "%s", array);}
	;		
%%

void yyerror(char *s){
	fprintf(stderr,"error: %s\n",s);
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}
