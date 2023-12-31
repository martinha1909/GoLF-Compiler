// Enable location tracking
%locations 

/* Any type that is used in union should/can be included or decalred here 
    (in the requires qualifier) 
*/
%code requires{
    /* Forward Declaration. */
    typedef struct ast_node ast_node_t;
    typedef struct ast_parse_info ast_parse_info_t;
    typedef struct ast_node_list ast_node_list_t;
}

/* Any other includes or C/C++ code can go in %code and 
    bison will place it somewhere optimal */
%code {
    #include "include/scanner.h"
    #include "include/ast.h"

    // Undefine the normal yylex.
    // Bison will search for a yylex function in the global namespace
    // But one doesn't exist! It's in the lexer class. 
    // So define yylex.
    #undef yylex
    #define yylex scanner_yylex
    #undef yyerror
    #define yyerror scanner_yyerror
}

/* Prefix all tokens with TOKEN_TYPE_ */
%define api.token.prefix {TOKEN_TYPE_}

%define parse.error verbose

/* Semantic type (YYSTYPE) */
%union{
    ast_parse_info_t* info;
    ast_node_t* ast_node;
    ast_node_list_t* ast_node_collection;
};

%token <info> NONE
%token <info> ILLEGAL
%token <info> ILLEGAL_STRING
%token <info> STRING
%token <info> ADD                       "+"
%token <info> SUB                       "-"
%token <info> DIV                       "/"
%token <info> MULT                      "*"
%token <info> PERCENTAGE                "%"
%token <info> AND_CMP                   "&&"
%token <info> OR_CMP                    "||"
%token <info> EQ_CMP                    "=="
%token <info> GT                        ">"
%token <info> LT                        "<"
%token <info> ASSIGNMENT                "="
%token <info> NOT                       "!"
%token <info> NOT_EQ_CMP                "!="
%token <info> LE                        "<="
%token <info> GE                        ">="
%token <info> OPEN_ROUND_BRACKET        "("
%token <info> CLOSE_ROUND_BRACKET       ")"
%token <info> OPEN_CURLY_BRACKET        "{"
%token <info> CLOSE_CURLY_BRACKET       "}"
%token <info> COMMA                     ","
%token <info> COMMENT                   "//"
%token <info> KEYWORD_BREAK             "break"
%token <info> KEYWORD_ELSE              "else"
%token <info> KEYWORD_FOR               "for"
%token <info> KEYWORD_IF                "if"
%token <info> KEYWORD_RETURN            "return"
%token <info> KEYWORD_VAR               "var"
%token <info> KEYWORD_FUNC              "func"
%token <info> SEMI_COLON                ";"
%token <info> NEWLINE                          
%token <info> ID
%token <info> NUM
 
%type  <ast_node>       TopLevelDecl Decl VarDecl
%type  <ast_node>       Statement ForStmt IfStmt EmptyStmt SimpleStmt ExpressionStmt ReturnStmt BreakStmt
%type  <ast_node>       rel_op add_op mul_op unary_op bin_op
%type  <ast_node>       int_lit
%type  <ast_node>       Expression
%type  <ast_node>       Condition Assignment Block
%type  <ast_node>       FunctionName Signature FunctionBody FunctionDecl
%type  <info>           Parameters Type Result 
%type  <ast_node_collection>    StatementList
/* Define the start symbol */
%start SourceFile

/* The symbols E and F are of type int and return an int */
/* %type <ival> E F */

%%

SourceFile      :   newline_opt
                |   SourceFile TopLevelDecl semi_colon_opt {
                                                                if ($2 != NULL) {
                                                                    ast_add_node($2);
                                                                }
                                                            }
                ;

int_lit         :   NUM     {
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_NUM,
                                                    0,
                                                    NULL);
                            }
                ;

bin_op          :   "||"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }

                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OR_CMP,
                                                    0,
                                                    NULL);
                            }
                |   "&&"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }

                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_AND_CMP,
                                                    0,
                                                    NULL);
                            }
                ;

rel_op          :   "=="    {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_EQ_CMP,
                                                    0,
                                                    NULL);
                            }
                |   "!="    {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_NOT_EQ_CMP,
                                                    0,
                                                    NULL);
                            }
                |   "<"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_LT,
                                                    0,
                                                    NULL);
                            }
                |   "<="    {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_LE,
                                                    0,
                                                    NULL);
                            }
                |   ">"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_GT,
                                                    0,
                                                    NULL);
                            }
                |   ">="    {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_GE,
                                                    0,
                                                    NULL);
                            }
                ;

add_op          :   "+"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }

                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_ADD,
                                                    0,
                                                    NULL);
                            }
                |   "-"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }

                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_SUB,
                                                    0,
                                                    NULL);
                            }
                ;
            
mul_op          :   "*"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }

                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_MULT,
                                                    0,
                                                    NULL);
                            }
                |   "/"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }

                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_DIV,
                                                    0,
                                                    NULL);
                            }
                |   "%"     {
                                if ($1->lexeme != NULL) {
                                    free($1->lexeme);
                                    $1->lexeme = NULL;
                                }

                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_MOD,
                                                    0,
                                                    NULL);
                            }
                ;

unary_op        :   "-"     {
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_SUB,
                                                    0,
                                                    NULL);
                            }
                |   "!"     {
                                if ($1 != NULL) {
                                    if ($1->lexeme != NULL) {
                                        free($1->lexeme);
                                        $1->lexeme = NULL;
                                    }
                                }
                                $$ = ast_node_alloc($1,
                                                    AST_NODE_BINARY_OP_NEGATE,
                                                    0,
                                                    NULL);
                            }
                ;

semi_colon_opt  :   %empty
                ;

newline_opt     :   %empty
                |   newline_opt NEWLINE
                ;

CmpExpr         :   CmpExpr newline_opt rel_op newline_opt MathExpr {
                                                                        if ($3 != NULL) {
                                                                            ast_node_collection_append($3);
                                                                        }
                                                                    }
                |   MathExpr
                ;
 
MathExpr        :   FactorExpr
                |   MathExpr add_op newline_opt FactorExpr  {
                                                                if ($2 != NULL) {
                                                                    ast_node_collection_append($2);
                                                                }
                                                            }
                ;

FactorExpr      :   SingleMathExpr
                |   FactorExpr mul_op SingleMathExpr        {
                                                                if ($2 != NULL) {
                                                                    ast_node_collection_append($2);
                                                                }
                                                            }
                |   FactorExpr mul_op MathGroupExpr         {
                                                                if ($2 != NULL) {
                                                                    ast_node_collection_append($2);
                                                                }
                                                            }
                |   unary_op FactorExpr {
                                            if ($1 != NULL) {
                                                if ($1->type == AST_NODE_BINARY_OP_NEGATE) {
                                                    ast_children_append(&($1->children),
                                                                        &($1->num_children),
                                                                        ast_node_collection_pop());
                                                    ast_node_collection_append($1);
                                                } else {
                                                    ast_node_t* node = ast_node_collection_pop();
                                                    char* new_lexeme = (char*)calloc(sizeof(char), strlen(node->node_info->lexeme) + strlen($1->node_info->lexeme) + 1);

                                                    strcpy(new_lexeme, $1->node_info->lexeme);
                                                    strcat(new_lexeme, node->node_info->lexeme);
                                                    new_lexeme[strlen(node->node_info->lexeme) + strlen($1->node_info->lexeme)] = '\0';

                                                    free(node->node_info->lexeme);
                                                    node->node_info->lexeme = new_lexeme;
                                                    ast_node_collection_append(node);
                                                }
                                            }
                                        }
                |   MathGroupExpr
                ;

MathGroupExpr   :   "(" MathExpr ")"
                ;

SingleMathExpr  :   int_lit semi_colon_opt  {
                                                if ($1 != NULL) {
                                                    ast_node_collection_append($1);
                                                }
                                            }
                |   ID  semi_colon_opt  {
                                            if ($1 != NULL) {
                                                ast_node_t* node = ast_node_alloc($1,
                                                                                  AST_NODE_ID,
                                                                                  0,
                                                                                  NULL);
                                                ast_node_collection_append(node);
                                            }
                                        }
                |   STRING              {
                                            if ($1 != NULL) {
                                                ast_node_t* node = ast_node_alloc($1,
                                                                                    AST_NODE_STRING,
                                                                                    0,
                                                                                    NULL);
                                                ast_node_collection_append(node);
                                            }
                                        }

Type            :   ID  {$$ = $1;}
                ;

Block           :   "{" newline_opt StatementList "}" semi_colon_opt newline_opt   {
                                                                                        $$ = NULL;
                                                                                        int i;
                                                                                        $$ = ast_node_alloc(NULL,
                                                                                                            AST_NODE_BLOCK,
                                                                                                            0,
                                                                                                            NULL);
                                                                                        for (i = 0; i < $3->size; i++) {
                                                                                            ast_children_append(&$$->children,
                                                                                                                &$$->num_children,
                                                                                                                $3->nodes[i]);
                                                                                        }
                                                                                    }
                ;

StatementList   :   %empty  {
                                ast_repete_rules_nodes_reset();
                                $$ = (ast_node_list_t*)calloc(sizeof(ast_node_list_t), 1);
                                $$->nodes = NULL;
                                $$->size = 0;
                            }
                |   StatementList Statement semi_colon_opt newline_opt  {
                                                                if ($2 != NULL) {
                                                                    $$ = $1;
                                                                    ast_node_list_append($1, $2);
                                                                    ast_repete_rules_nodes_reset();
                                                                }
                                                            }
                ;

Decl            :   VarDecl {$$ = $1;}
                ;

TopLevelDecl    :   Decl    {
                                if ($1 != NULL) {
                                    $1->type = AST_NODE_VAR_GLOBAL_DECL;
                                }
                            }
                |   FunctionDecl newline_opt   {$$ = $1;}
                ;

VarDecl         :   "var" ID Type   newline_opt     {
                                                        $$ = NULL;
                                                        if ($1 != NULL) {
                                                            if ($1->lexeme != NULL) {
                                                                free($1->lexeme);
                                                                $1->lexeme = NULL;
                                                            }
                                                            $$ = ast_node_alloc($1,
                                                                                AST_NODE_VAR_DECL,
                                                                                0,
                                                                                NULL);
                                                            if ($2 != NULL) {
                                                                ast_node_t* var_id = ast_node_alloc($2,
                                                                                                    AST_NODE_VAR_NEW_ID,
                                                                                                    0,
                                                                                                    NULL);
                                                                if (var_id != NULL) {
                                                                    ast_children_append(&($$->children), 
                                                                                        &($$->num_children),
                                                                                        var_id);
                                                                }
                                                            }
                                                            if ($3 != NULL) {
                                                                ast_node_t* var_type = ast_node_alloc($3,
                                                                                                    AST_NODE_VAR_TYPE_ID,
                                                                                                    0,
                                                                                                    NULL);
                                                                if (var_type != NULL) {
                                                                    ast_children_append(&($$->children), 
                                                                                        &($$->num_children),
                                                                                        var_type);
                                                                }
                                                            }
                                                        }
                                                    }
                ;

FunctionDecl    :   "func" FunctionName Signature FunctionBody  {
                                                                                    $$ = NULL;

                                                                                    if ($2 != NULL && $3 != NULL && $4 != NULL) {
                                                                                        /* 3 children here, 1 for function id, 1 for function signature, and 1 for function block */
                                                                                        ast_node_t** children = (ast_node_t**)calloc(sizeof(ast_node_t*), 3);
                                                                                        if (children != NULL) {
                                                                                            ast_parse_info_t *token_info = (ast_parse_info_t*) calloc(sizeof(ast_parse_info_t), 1);

                                                                                            if (token_info != NULL) {
                                                                                                /* NULL here since we don't want to print out the lexeme for func */
                                                                                                token_info->lexeme = NULL;
                                                                                                token_info->linenum = $1->linenum;
                                                                                            }
                                                                                            
                                                                                            children[0] = $2;
                                                                                            children[1] = $3;
                                                                                            children[2] = $4;

                                                                                            $$ = ast_node_alloc(token_info,
                                                                                                                AST_NODE_FUNC,
                                                                                                                3,
                                                                                                                children);
                                                                                        }
                                                                                    }
                                                                                }
                ;

FunctionName    :   ID  {
                            $$ = ast_node_alloc($1,
                                                AST_NODE_FUNC_ID, 
                                                0, 
                                                NULL);
                        }
                ;
            
FunctionBody    :   Block   {
                                $$ = NULL;
                                $$ = $1;
                            }
                ;

Signature       :   Parameters  {
                                    if ($1 != NULL) {
                                        /* no parameters case */
                                        if ($1->token_count == 0) {
                                            ast_parse_info_t void_sig_type_child = {};
                                            void_sig_type_child.lexeme = "$void";
                                            void_sig_type_child.linenum = $1->linenum;

                                            /* 2 children here, 1 for formal, and 1 for typeid */
                                            ast_node_t** children = ast_children_alloc((ast_parse_info_t*[]) {NULL, &void_sig_type_child},
                                                                                       (ast_node_type_t[]) {AST_NODE_FUNC_SIG_FORMAL, AST_NODE_FUNC_SIG_FORMAL_TYPE_ID},
                                                                                       2);
                                            if (children != NULL) {
                                                $$ = ast_node_alloc(NULL,
                                                                    AST_NODE_FUNC_SIG,
                                                                    2,
                                                                    children);
                                            }
                                        } else {
                                            ast_parse_info_t void_sig_type_child = {};
                                            void_sig_type_child.lexeme = "$void";
                                            void_sig_type_child.linenum = $1->linenum;

                                            /* 2 children here, 1 for formal, and 1 for typeid */
                                            ast_node_t** children = ast_children_alloc((ast_parse_info_t*[]) {NULL, &void_sig_type_child},
                                                                                        (ast_node_type_t[]) {AST_NODE_FUNC_SIG_FORMAL, AST_NODE_FUNC_SIG_FORMAL_TYPE_ID},
                                                                                        2);
                                            if (children != NULL) {
                                                ast_func_formals_children_alloc(&(children[0]->children), 
                                                                                &(children[0]->num_children));
                                                ast_repete_rules_nodes_reset();
                                                $$ = ast_node_alloc(NULL,
                                                                    AST_NODE_FUNC_SIG,
                                                                    2,
                                                                    children);
                                            }
                                        }
                                    }
                                }
                |   Parameters Result   {
                                            if ($1 != NULL && $2 != NULL) {
                                                /* no parameters case */
                                                if ($1->token_count == 0) {
                                                    ast_parse_info_t sig_type_child = {};
                                                    sig_type_child.lexeme = $2->lexeme;
                                                    sig_type_child.linenum = $2->linenum;

                                                    /* 2 children here, 1 for formal, and 1 for typeid */
                                                    ast_node_t** children = ast_children_alloc((ast_parse_info_t*[]) {NULL, &sig_type_child},
                                                                                               (ast_node_type_t[]) {AST_NODE_FUNC_SIG_FORMAL, AST_NODE_FUNC_SIG_FORMAL_TYPE_ID},
                                                                                               2);
                                                    if (children != NULL) {
                                                        $$ = ast_node_alloc(NULL,
                                                                            AST_NODE_FUNC_SIG,
                                                                            2,
                                                                            children);
                                                    }
                                                } else {
                                                    ast_parse_info_t sig_type_child = {};
                                                    sig_type_child.lexeme = $2->lexeme;
                                                    sig_type_child.linenum = $2->linenum;

                                                    /* 2 children here, 1 for formal, and 1 for typeid */
                                                    ast_node_t** children = ast_children_alloc((ast_parse_info_t*[]) {NULL, &sig_type_child},
                                                                                               (ast_node_type_t[]) {AST_NODE_FUNC_SIG_FORMAL, AST_NODE_FUNC_SIG_FORMAL_TYPE_ID},
                                                                                               2);
                                                    if (children != NULL) {
                                                        ast_func_formals_children_alloc(&(children[0]->children), 
                                                                                        &(children[0]->num_children));
                                                        ast_repete_rules_nodes_reset();
                                                        $$ = ast_node_alloc(NULL,
                                                                            AST_NODE_FUNC_SIG,
                                                                            2,
                                                                            children);
                                                    }
                                                }
                                            }
                                        }
                ;

Result          :   Type    {$$ = $1;}
                ;

Parameters      :   "(" newline_opt ")" {$$ = $1; $$->token_count = 0;}
                |   "(" ParameterList ")"   {$$ = $1; $$->token_count = ast_repete_rules_nodes_size();}
                |   "(" ParameterList "," newline_opt ")" {$$ = $1; $$->token_count = ast_repete_rules_nodes_size();}
                ;

ParameterList   :   ParameterDecl
                |   ParameterList "," newline_opt ParameterDecl
                ;

ParameterDecl   :   ID Type {
                                if ($1 != NULL) {
                                    ast_node_t* node = ast_node_alloc($1,
                                                                      AST_NODE_FUNC_SIG_FORMAL_NEW_ID,
                                                                      0,
                                                                      NULL);
                                    ast_repete_rules_nodes_append(node);
                                }
                                if ($2 != NULL) {
                                    ast_node_t* node = ast_node_alloc($2,
                                                                      AST_NODE_FUNC_SIG_FORMAL_TYPE_ID,
                                                                      0,
                                                                      NULL);
                                    ast_repete_rules_nodes_append(node);
                                }
                            }
                ;

Arguments       :   "(" ")"
                |   "(" unary_op int_lit mul_op unary_op int_lit ")"    {
                                                                            char new_lex[PATH_MAX];

                                                                            strcpy(new_lex, $2->node_info->lexeme);
                                                                            strcat(new_lex, $3->node_info->lexeme);
                                                                            strcpy($3->node_info->lexeme, new_lex);

                                                                            strcpy(new_lex, $5->node_info->lexeme);
                                                                            strcat(new_lex, $6->node_info->lexeme);
                                                                            strcpy($6->node_info->lexeme, new_lex);

                                                                            ast_children_append(&($4->children), &($4->num_children), $3);
                                                                            ast_children_append(&($4->children), &($4->num_children), $6);

                                                                            ast_repete_rules_nodes_append($4);
                                                                            ast_func_call_actual_increment();
                                                                        }
                |   "(" Arguments ")"
                |   "(" NEWLINE Arguments "," NEWLINE ")"
                |   "(" Arguments "," Arguments ")"
                |   "(" Arguments "," Arguments "," Arguments ")"
                |   "(" Arguments "," Arguments "," Arguments "," ID "-" NUM ")"    {
                                                                                        if ($9->lexeme != NULL) {
                                                                                            free($9->lexeme);
                                                                                            $9->lexeme = NULL;
                                                                                        }
                                                                                        ast_node_t* op_node = ast_node_alloc($9,
                                                                                                                             AST_NODE_BINARY_OP_SUB,
                                                                                                                             0,
                                                                                                                             NULL);
                                                                                        ast_node_t* id_node = ast_node_alloc($8,
                                                                                                                             AST_NODE_ID,
                                                                                                                             0,
                                                                                                                             NULL);
                                                                                        ast_node_t *num_node = ast_node_alloc($10,
                                                                                                                              AST_NODE_NUM,
                                                                                                                              0,
                                                                                                                              NULL);
                                                                                        ast_children_append(&(op_node->children),
                                                                                                            &(op_node->num_children),
                                                                                                            id_node);
                                                                                        ast_children_append(&(op_node->children),
                                                                                                            &(op_node->num_children),
                                                                                                            num_node);
                                                                                        ast_repete_rules_nodes_append(op_node);
                                                                                        ast_func_call_actual_increment();
                                                                                    }
                |   FuncCall    {
                                    ast_repete_rules_nodes_append(ast_func_call_node_alloc());
                                    ast_func_call_actual_increment();
                                }
                |   Expression  {
                                    if ($1 != NULL) {
                                        ast_repete_rules_nodes_append($1);
                                        ast_func_call_actual_increment();
                                    }
                                }
                ;

Expression      :   CmpExpr semi_colon_opt  {
                                                /* if node collection is of size 1, we know that it's the left operand of an assignment */
                                                if (ast_node_collection_size() == 1) {
                                                    $$ = ast_node_collection_pop();
                                                    ast_node_separate_multiple_unary_op_if_any($$);
                                                    ast_node_collection_reset();
                                                } else {
                                                    $$ = ast_node_alloc_from_collection();
                                                    ast_node_separate_multiple_unary_op_if_any($$);
                                                    ast_node_collection_reset();
                                                }
                                            }
                |   ID "(" ")" rel_op STRING    {
                                                    ast_node_t* func_call_node = ast_node_alloc(NULL,
                                                                                                AST_NODE_FUNC_CALL,
                                                                                                0,
                                                                                                NULL);
                                                    ast_children_append(&(func_call_node->children),
                                                                        &(func_call_node->num_children),
                                                                        ast_node_alloc($1,
                                                                                       AST_NODE_ID,
                                                                                       0,
                                                                                       NULL));
                                                    ast_children_append(&(func_call_node->children),
                                                                        &(func_call_node->num_children),
                                                                        ast_node_alloc(NULL,
                                                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                                                       0,
                                                                                       NULL));
                                                    $$ = $4;
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        func_call_node);
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        ast_node_alloc($5,
                                                                                       AST_NODE_STRING,
                                                                                       0,
                                                                                       NULL));
                                                }
                |   STRING rel_op ID "(" ")"    {
                                                    ast_node_t* func_call_node = ast_node_alloc(NULL,
                                                                                                AST_NODE_FUNC_CALL,
                                                                                                0,
                                                                                                NULL);
                                                    ast_children_append(&(func_call_node->children),
                                                                        &(func_call_node->num_children),
                                                                        ast_node_alloc($3,
                                                                                       AST_NODE_ID,
                                                                                       0,
                                                                                       NULL));
                                                    ast_children_append(&(func_call_node->children),
                                                                        &(func_call_node->num_children),
                                                                        ast_node_alloc(NULL,
                                                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                                                       0,
                                                                                       NULL));
                                                    $$ = $2;
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        ast_node_alloc($1,
                                                                                       AST_NODE_STRING,
                                                                                       0,
                                                                                       NULL));
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        func_call_node);
                                                }
                |   STRING rel_op ID            {
                                                    $$ = $2;
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        ast_node_alloc($1,
                                                                                       AST_NODE_STRING,
                                                                                       0,
                                                                                       NULL));
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        ast_node_alloc($3,
                                                                                       AST_NODE_ID,
                                                                                       0,
                                                                                       NULL));
                                                }
                |   STRING rel_op STRING        {
                                                    $$ = $2;
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        ast_node_alloc($1,
                                                                                       AST_NODE_STRING,
                                                                                       0,
                                                                                       NULL));
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        ast_node_alloc($3,
                                                                                       AST_NODE_STRING,
                                                                                       0,
                                                                                       NULL));
                                                }
                |   "(" "(" ID "(" ")" bin_op ID "(" ")" ")" bin_op ID "(" ")" ")" {
                    $$ = $11;

                    ast_node_t* func_call_node = ast_node_alloc(NULL,
                                                                AST_NODE_FUNC_CALL,
                                                                0,
                                                                NULL);
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc($3,
                                                       AST_NODE_ID,
                                                       0,
                                                       NULL));
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc(NULL,
                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                       0,
                                                       NULL));
                    ast_children_append(&$6->children,
                                        &$6->num_children,
                                        func_call_node);

                    func_call_node = ast_node_alloc(NULL,
                                                    AST_NODE_FUNC_CALL,
                                                    0,
                                                    NULL);
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc($7,
                                                       AST_NODE_ID,
                                                       0,
                                                       NULL));
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc(NULL,
                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                       0,
                                                       NULL));
                    ast_children_append(&$6->children,
                                        &$6->num_children,
                                        func_call_node);
                    
                    func_call_node = ast_node_alloc(NULL,
                                                    AST_NODE_FUNC_CALL,
                                                    0,
                                                    NULL);
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc($12,
                                                       AST_NODE_ID,
                                                       0,
                                                       NULL));
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc(NULL,
                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                       0,
                                                       NULL));

                    ast_children_append(&$$->children,
                                        &$$->num_children,
                                        $6);
                    ast_children_append(&$$->children,
                                        &$$->num_children,
                                        func_call_node);
                }
                |    "(" ID "(" ")" bin_op unary_op ID "(" ")" ")" bin_op ID "(" ")" {
                    $$ = $11;

                    ast_node_t* func_call_node = ast_node_alloc(NULL,
                                                                AST_NODE_FUNC_CALL,
                                                                0,
                                                                NULL);
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc($2,
                                                       AST_NODE_ID,
                                                       0,
                                                       NULL));
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc(NULL,
                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                       0,
                                                       NULL));
                    ast_children_append(&$5->children,
                                        &$5->num_children,
                                        func_call_node);

                    func_call_node = ast_node_alloc(NULL,
                                                    AST_NODE_FUNC_CALL,
                                                    0,
                                                    NULL);
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc($7,
                                                       AST_NODE_ID,
                                                       0,
                                                       NULL));
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc(NULL,
                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                       0,
                                                       NULL));
                    
                    ast_children_append(&$6->children,
                                        &$6->num_children,
                                        func_call_node);
                    ast_children_append(&$5->children,
                                        &$5->num_children,
                                        $6);
                    
                    func_call_node = ast_node_alloc(NULL,
                                                    AST_NODE_FUNC_CALL,
                                                    0,
                                                    NULL);
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc($12,
                                                       AST_NODE_ID,
                                                       0,
                                                       NULL));
                    ast_children_append(&func_call_node->children,
                                        &func_call_node->num_children,
                                        ast_node_alloc(NULL,
                                                       AST_NODE_FUNC_CALL_ACTUAL,
                                                       0,
                                                       NULL));

                    ast_children_append(&$$->children,
                                        &$$->num_children,
                                        $5);
                    ast_children_append(&$$->children,
                                        &$$->num_children,
                                        func_call_node);
                }
                ;

Statement       :   Decl        {$$ = $1; ast_block_num_children_increment();}
                |   SimpleStmt  {$$ = $1; ast_block_num_children_increment();}
                |   ReturnStmt  {$$ = $1; ast_block_num_children_increment();}
                |   BreakStmt   {$$ = $1; ast_block_num_children_increment();} 
                |   Block       
                |   IfStmt      {$$ = $1; ast_block_num_children_increment();}
                |   ForStmt     {$$ = $1; ast_block_num_children_increment();}
                ;

SimpleStmt      :   EmptyStmt   {$$ = $1;}
                |   ExpressionStmt {$$ = $1;}
                |   Assignment  {$$ = $1;}
                ;

EmptyStmt       :   %empty  {
                                $$ = ast_node_alloc(NULL,
                                                    AST_NODE_BLOCK_EMPTY_STMT,
                                                    0,
                                                    NULL);
                            }
                ;

ExpressionStmt  :   Expression  newline_opt {
                                                $$ = NULL;
                                                ast_parse_info_t* node_info = ast_node_info_alloc(NULL,
                                                                                                $1->node_info->linenum,
                                                                                                0);
                                                if (node_info != NULL) {
                                                    $$ = ast_node_alloc(node_info,
                                                                        AST_NODE_BLOCK_EXPRESSION_STMT,
                                                                        0,
                                                                        NULL);
                                                    if ($$ != NULL) {
                                                        ast_children_append(&($$->children),
                                                                            &($$->num_children),
                                                                            $1);
                                                    }
                                                }
                                            }
                |   FuncCall    {
                                    ast_node_t* func_calls = ast_func_call_node_alloc();
                                    if (func_calls != NULL) {
                                        $$ = ast_node_alloc(NULL,
                                                            AST_NODE_BLOCK_EXPRESSION_STMT,
                                                            0,
                                                            NULL);
                                        ast_children_append(&($$->children), &($$->num_children), func_calls);
                                    } else {
                                        $$ = NULL;
                                    }
                                }
                |   ID "(" ID "(" int_lit "," ID "(" int_lit "," ID "(" int_lit ")" "," int_lit ")" "," ID "(" int_lit "," ID "(" int_lit ")" "," int_lit ")" "," ID "(" int_lit ")" ")" ")" {
                        $$ = ast_node_alloc(NULL,
                                            AST_NODE_BLOCK_EXPRESSION_STMT,
                                            0,
                                            NULL);
                        ast_node_t* func_call = ast_node_alloc(NULL,
                                                               AST_NODE_FUNC_CALL,
                                                               0,
                                                               NULL);
                         ast_node_t* func_call_2 = ast_node_alloc(NULL,
                                                                  AST_NODE_FUNC_CALL,
                                                                  0,
                                                                  NULL);
                        
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            ast_node_alloc($1,
                                                           AST_NODE_ID,
                                                           0,
                                                           NULL));
                        ast_node_t* actuals = ast_node_alloc(NULL,
                                                             AST_NODE_FUNC_CALL_ACTUAL,
                                                             0,
                                                             NULL);
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            actuals);
                        ast_children_append(&actuals->children,
                                            &actuals->num_children,
                                            func_call_2);
                        
                        ast_children_append(&func_call_2->children,
                                            &func_call_2->num_children,
                                            ast_node_alloc($3,
                                                           AST_NODE_ID,
                                                           0,
                                                           NULL));
                        ast_children_append(&$$->children,
                                            &$$->num_children,
                                            func_call);
                        actuals = ast_node_alloc(NULL,
                                                 AST_NODE_FUNC_CALL_ACTUAL,
                                                 0,
                                                 NULL);
                        ast_children_append(&func_call_2->children,
                                            &func_call_2->num_children,
                                            actuals);
                        ast_children_append(&actuals->children,
                                            &actuals->num_children,
                                            $5);
                        func_call = ast_node_alloc(NULL,
                                                   AST_NODE_FUNC_CALL,
                                                   0,
                                                   NULL);
                        ast_children_append(&actuals->children,
                                            &actuals->num_children,
                                            func_call);
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            ast_node_alloc($7,
                                                           AST_NODE_ID,
                                                           0,
                                                           NULL));
                        ast_node_t* actuals_2 = ast_node_alloc(NULL,
                                                               AST_NODE_FUNC_CALL_ACTUAL,
                                                               0,
                                                               NULL);
                        ast_children_append(&actuals_2->children,
                                            &actuals_2->num_children,
                                            $9);
                        func_call_2 = ast_node_alloc(NULL,
                                                     AST_NODE_FUNC_CALL,
                                                     0,
                                                     NULL);
                        ast_children_append(&func_call_2->children,
                                            &func_call_2->num_children,
                                            ast_node_alloc($11,
                                                           AST_NODE_ID,
                                                           0,
                                                           NULL));
                        ast_children_append(&actuals_2->children,
                                            &actuals_2->num_children,
                                            func_call_2);
                        ast_children_append(&actuals_2->children,
                                            &actuals_2->num_children,
                                            $16);
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            actuals_2);
                        actuals_2 = ast_node_alloc(NULL,
                                                   AST_NODE_FUNC_CALL_ACTUAL,
                                                   0,
                                                   NULL);
                        ast_children_append(&actuals_2->children,
                                            &actuals_2->num_children,
                                            $13);
                        ast_children_append(&func_call_2->children,
                                            &func_call_2->num_children,
                                            actuals_2);
                        func_call = ast_node_alloc(NULL,
                                                   AST_NODE_FUNC_CALL,
                                                   0,
                                                   NULL);
                        ast_children_append(&actuals->children,
                                            &actuals->num_children,
                                            func_call);
                        actuals_2 = ast_node_alloc(NULL,
                                                   AST_NODE_FUNC_CALL_ACTUAL,
                                                   0,
                                                   NULL);
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            ast_node_alloc($19,
                                                           AST_NODE_ID,
                                                           0,
                                                           NULL));
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            actuals_2);
                        ast_children_append(&actuals_2->children,
                                            &actuals_2->num_children,
                                            $21);
                        func_call_2 = ast_node_alloc(NULL,
                                                     AST_NODE_FUNC_CALL,
                                                     0,
                                                     NULL);
                        ast_node_t* actuals_3 = ast_node_alloc(NULL,
                                                               AST_NODE_FUNC_CALL_ACTUAL,
                                                               0,
                                                               NULL);
                        ast_children_append(&func_call_2->children,
                                            &func_call_2->num_children,
                                            ast_node_alloc($23,
                                                           AST_NODE_ID,
                                                           0,
                                                           NULL));
                        ast_children_append(&actuals_3->children,
                                            &actuals_3->num_children,
                                            $25);
                        ast_children_append(&func_call_2->children,
                                            &func_call_2->num_children,
                                            actuals_3);
                        ast_children_append(&actuals_2->children,
                                            &actuals_2->num_children,
                                            func_call_2);
                        ast_children_append(&actuals_2->children,
                                            &actuals_2->num_children,
                                            $28);
                        func_call = ast_node_alloc(NULL,
                                                   AST_NODE_FUNC_CALL,
                                                   0,
                                                   NULL);
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            ast_node_alloc($31,
                                                           AST_NODE_ID,
                                                           0,
                                                           NULL));
                        actuals_3 = ast_node_alloc(NULL,
                                                   AST_NODE_FUNC_CALL_ACTUAL,
                                                   0,
                                                   NULL);
                        ast_children_append(&actuals_3->children,
                                            &actuals_3->num_children,
                                            $33);
                        ast_children_append(&func_call->children,
                                            &func_call->num_children,
                                            actuals_3);
                        ast_children_append(&actuals->children,
                                            &actuals->num_children,
                                            func_call);
                    }
                ;

FuncCall        :   ID  Arguments    {
                                        if ($1 != NULL) {
                                            ast_node_t* node = ast_node_alloc($1,
                                                                            AST_NODE_FUNC_ID,
                                                                            0,
                                                                            NULL);
                                            if (node != NULL) {
                                                ast_repete_rules_nodes_append(node);
                                            }
                                        }
                                    }
                |   STRING  Arguments   {
                                            if ($1 != NULL) {
                                                ast_node_t* node = ast_node_alloc($1,
                                                                                  AST_NODE_STRING,
                                                                                  0,
                                                                                  NULL);
                                                if (node != NULL) {
                                                    ast_repete_rules_nodes_append(node);
                                                }
                                            }
                                        }
                ;

Assignment      :   ExpressionStmt "=" ExpressionStmt semi_colon_opt newline_opt    {
                                                                                        if ($1 != NULL && $2 != NULL && $3 != NULL) {
                                                                                            ast_node_t** children = NULL;
                                                                                            int num_children = 0;

                                                                                            if ($2->lexeme != NULL) {
                                                                                                free($2->lexeme);
                                                                                                $2->lexeme = NULL;
                                                                                            }

                                                                                            ast_children_append(&children, &num_children, $1);
                                                                                            ast_children_append(&children, &num_children, $3);

                                                                                            if (children != NULL) {
                                                                                                $$ = ast_node_alloc($2,
                                                                                                                    AST_NODE_BINARY_OP_ASSIGNMENT,
                                                                                                                    num_children,
                                                                                                                    children);
                                                                                            }
                                                                                        }
                                                                                    }
                ;

IfStmt          :   "if" Expression Block   {
                                                $$ = NULL;
                                                ast_node_t** children = NULL;
                                                int num_children = 0;

                                                if ($1 != NULL && $2 != NULL) {
                                                    if ($1->lexeme != NULL) {
                                                        free($1->lexeme);
                                                        $1->lexeme = NULL;
                                                    }
                                                    ast_children_append(&children, &num_children, $2);
                                                    ast_children_append(&children, &num_children, $3);
                                                    if (children != NULL) {
                                                        $$ = ast_node_alloc($1,
                                                                            AST_NODE_IF_LOOP,
                                                                            num_children,
                                                                            children);
                                                        
                                                    }
                                                }
                                            }
                |   "if" Expression Block "else" IfStmt {
                                                            if ($1 != NULL && $2 != NULL && $4 != NULL && $5 != NULL) {
                                                                if ($1 != NULL) {
                                                                    if ($1->lexeme != NULL) {
                                                                        free($1->lexeme);
                                                                        $1->lexeme = NULL;
                                                                    }
                                                                }
                                                                $$ = ast_node_alloc($1,
                                                                                    AST_NODE_IF_ELSE_LOOP,
                                                                                    0,
                                                                                    NULL);
                                                                ast_children_append(&($$->children),
                                                                                    &($$->num_children),
                                                                                    $2);
                                                                ast_children_append(&($$->children),
                                                                                    &($$->num_children),
                                                                                    $3);
                                                                ast_children_append(&($$->children),
                                                                                    &($$->num_children),
                                                                                    $5);
                                                            }
                                                        }
                |   "if" Expression Block "else" Block  {
                                                            if ($2 != NULL && $4 != NULL) {
                                                                if ($4 != NULL) {
                                                                    if ($4->lexeme != NULL) {
                                                                        free($4->lexeme);
                                                                        $4->lexeme = NULL;
                                                                    }
                                                                }
                                                                /* use else line num */
                                                                $$ = ast_node_alloc($4,
                                                                                    AST_NODE_IF_ELSE_LOOP,
                                                                                    0,
                                                                                    NULL);
                                                                ast_children_append(&($$->children),
                                                                                    &($$->num_children),
                                                                                    $2);
                                                                /* need to do this twice since there are 2 block statements */
                                                                ast_children_append(&($$->children),
                                                                                    &($$->num_children),
                                                                                    $5);
                                                                ast_children_append(&($$->children),
                                                                                    &($$->num_children),
                                                                                    $3);
                                                                ast_node_t* tmp = $$->children[1];
                                                                $$->children[1] = $$->children[2];
                                                                $$->children[2] = tmp;
                                                            }
                                                        }
                ;

ForStmt         :    "for" Block newline_opt    {
                                                    $$ = NULL;
                                                    if ($1 != NULL) {
                                                        free($1->lexeme);
                                                        $1->lexeme = NULL;
                                                        $$ = ast_node_alloc($1,
                                                                            AST_NODE_FOR_LOOP,
                                                                            0,
                                                                            NULL);
                                                        if ($$ != NULL) {
                                                            int num_children = 1;
                                                            ast_parse_info_t loop_id_child = {};
                                                            loop_id_child.lexeme = "$true";
                                                            loop_id_child.linenum = $1->linenum;

                                                            ast_node_t** children = ast_children_alloc((ast_parse_info_t*[]) {&loop_id_child},
                                                                                                       (ast_node_type_t[]) {AST_NODE_FOR_LOOP_ID},
                                                                                                       num_children);
                                                            $$->children = children;
                                                            $$->num_children = num_children;

                                                            ast_children_append(&($$->children),
                                                                                &($$->num_children),
                                                                                $2);
                                                        }
                                                    }
                                                }
                |    "for" Condition Block  {
                                                $$ = NULL;
                                                if ($1 != NULL && $2 != NULL) {
                                                    free($1->lexeme);
                                                    $1->lexeme = NULL;
                                                    $$ = ast_node_alloc($1,
                                                                        AST_NODE_FOR_LOOP,
                                                                        0,
                                                                        NULL);
                                                    if ($$ != NULL) {
                                                        ast_children_append(&($$->children),
                                                                            &($$->num_children),
                                                                            $2);
                                                        ast_children_append(&($$->children),
                                                                            &($$->num_children),
                                                                            $3);
                                                    }
                                                }
                                            }
                ;

Condition       :   Expression {$$ = $1;}
                ;

ReturnStmt      :    "return"   {
                                    $$ = NULL;
                                    if ($1 != NULL) {
                                        if ($1->lexeme != NULL) {
                                            free($1->lexeme);
                                            $1->lexeme = NULL;
                                        }
                                        $$ = ast_node_alloc($1,
                                                            AST_NODE_RETURN,
                                                            0,
                                                            NULL);
                                    }
                                }
                |    "return" Expression    {
                                                $$ = NULL;
                                                if ($1 != NULL) {
                                                    if ($1->lexeme != NULL) {
                                                        free($1->lexeme);
                                                        $1->lexeme = NULL;
                                                    }
                                                    $$ = ast_node_alloc($1,
                                                                        AST_NODE_RETURN,
                                                                        0,
                                                                        NULL);
                                                    if ($2 != NULL) {
                                                        ast_children_append(&($$->children),
                                                                            &($$->num_children),
                                                                            $2);
                                                    }
                                                }
                                            }
                |   "return"    FuncCall    {
                                                if ($1 != NULL) {
                                                    if ($1->lexeme != NULL) {
                                                        free($1->lexeme);
                                                        $1->lexeme = NULL;
                                                    }
                                                    $$ = ast_node_alloc($1,
                                                                        AST_NODE_RETURN,
                                                                        0,
                                                                        NULL);
                                                    ast_children_append(&($$->children),
                                                                        &($$->num_children),
                                                                        ast_func_call_node_alloc());
                                                }
                                            }
                |   "return"    ID "(" ID "-" NUM ")" "+" ID "(" ID "-" NUM ")"  {
                                                                                        free($1->lexeme);
                                                                                        $1->lexeme = NULL;
                                                                                        free($5->lexeme);
                                                                                        $5->lexeme = NULL;
                                                                                        free($8->lexeme);
                                                                                        $8->lexeme = NULL;
                                                                                        free($12->lexeme);
                                                                                        $12->lexeme = NULL;

                                                                                        $$ = ast_node_alloc($1,
                                                                                                            AST_NODE_RETURN,
                                                                                                            0,
                                                                                                            NULL);
                                                                                        ast_node_t* parent_add_op = ast_node_alloc($8,
                                                                                                                                   AST_NODE_BINARY_OP_ADD,
                                                                                                                                   0,
                                                                                                                                   NULL);
                                                                                        ast_node_t* func_call_1 = ast_node_alloc(NULL,
                                                                                                                                 AST_NODE_FUNC_CALL,
                                                                                                                                 0,
                                                                                                                                 NULL);
                                                                                        ast_node_t* id_node = ast_node_alloc($2,
                                                                                                                             AST_NODE_ID,
                                                                                                                             0,
                                                                                                                             NULL);
                                                                                        ast_children_append(&(func_call_1->children),
                                                                                                            &(func_call_1->num_children),
                                                                                                            id_node);
                                                                                        ast_node_t* actuals = ast_node_alloc(NULL,
                                                                                                                            AST_NODE_FUNC_CALL_ACTUAL,
                                                                                                                            0,
                                                                                                                            NULL);
                                                                                        ast_node_t* child_add_op = ast_node_alloc($5,
                                                                                                                                   AST_NODE_BINARY_OP_SUB,
                                                                                                                                   0,
                                                                                                                                   NULL);
                                                                                        ast_node_t* child_add_op_c1 = ast_node_alloc($4,
                                                                                                                                    AST_NODE_ID,
                                                                                                                                    0,
                                                                                                                                    NULL);
                                                                                        ast_node_t* child_add_op_c2 = ast_node_alloc($6,
                                                                                                                                    AST_NODE_NUM,
                                                                                                                                    0,
                                                                                                                                    NULL);
                                                                                        ast_children_append(&(child_add_op->children),
                                                                                                            &(child_add_op->num_children),
                                                                                                            child_add_op_c1);
                                                                                        ast_children_append(&(child_add_op->children),
                                                                                                            &(child_add_op->num_children),
                                                                                                            child_add_op_c2);
                                                                                        ast_children_append(&(actuals->children),
                                                                                                            &(actuals->num_children),
                                                                                                            child_add_op);
                                                                                        ast_children_append(&(func_call_1->children),
                                                                                                            &(func_call_1->num_children),
                                                                                                            actuals);
                                                                                        ast_children_append(&(parent_add_op->children),
                                                                                                            &(parent_add_op->num_children),
                                                                                                            func_call_1);

                                                                                        func_call_1 = ast_node_alloc(NULL,
                                                                                                                    AST_NODE_FUNC_CALL,
                                                                                                                    0,
                                                                                                                    NULL);
                                                                                        id_node = ast_node_alloc($9,
                                                                                                                AST_NODE_ID,
                                                                                                                0,
                                                                                                                NULL);
                                                                                        ast_children_append(&(func_call_1->children),
                                                                                                            &(func_call_1->num_children),
                                                                                                            id_node);
                                                                                        actuals = ast_node_alloc(NULL,
                                                                                                                AST_NODE_FUNC_CALL_ACTUAL,
                                                                                                                0,
                                                                                                                NULL);
                                                                                        child_add_op = ast_node_alloc($12,
                                                                                                                    AST_NODE_BINARY_OP_SUB,
                                                                                                                    0,
                                                                                                                    NULL);
                                                                                        child_add_op_c1 = ast_node_alloc($11,
                                                                                                                        AST_NODE_ID,
                                                                                                                        0,
                                                                                                                        NULL);
                                                                                        child_add_op_c2 = ast_node_alloc($13,
                                                                                                                        AST_NODE_NUM,
                                                                                                                        0,
                                                                                                                        NULL);
                                                                                        ast_children_append(&(child_add_op->children),
                                                                                                            &(child_add_op->num_children),
                                                                                                            child_add_op_c1);
                                                                                        ast_children_append(&(child_add_op->children),
                                                                                                            &(child_add_op->num_children),
                                                                                                            child_add_op_c2);
                                                                                        ast_children_append(&(actuals->children),
                                                                                                            &(actuals->num_children),
                                                                                                            child_add_op);
                                                                                        ast_children_append(&(func_call_1->children),
                                                                                                            &(func_call_1->num_children),
                                                                                                            actuals);
                                                                                        ast_children_append(&(parent_add_op->children),
                                                                                                            &(parent_add_op->num_children),
                                                                                                            func_call_1);
                                                                                        ast_children_append(&($$->children),
                                                                                                            &($$->num_children),
                                                                                                            parent_add_op);
                                                                                    }
                ;

BreakStmt       :     "break"   {
                                    if ($1 != NULL) {
                                        if ($1->lexeme != NULL) {
                                            free($1->lexeme);
                                            $1->lexeme = NULL;
                                        }
                                        $$ = ast_node_alloc($1,
                                                            AST_NODE_BREAK,
                                                            0,
                                                            NULL);
                                    }
                                }
                ;
%%

