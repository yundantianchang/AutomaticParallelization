/*--------------------------------------------------------------------
  (C) Copyright 2006-2011 Barcelona Supercomputing Center 
                          Centro Nacional de Supercomputacion
  
  This file is part of Mercurium C/C++ source-to-source compiler.
  
  See AUTHORS file in the top level directory for information 
  regarding developers and contributors.
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version.
  
  Mercurium C/C++ source-to-source compiler is distributed in the hope
  that it will be useful, but WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU Lesser General Public License for more
  details.
  
  You should have received a copy of the GNU Lesser General Public
  License along with Mercurium C/C++ source-to-source compiler; if
  not, write to the Free Software Foundation, Inc., 675 Mass Ave,
  Cambridge, MA 02139, USA.
--------------------------------------------------------------------*/

%{
/*
   Parser of ISO/IEC 9899:1999 - C

   It parses a superset of the language.

   Must be compiled with rofi-bison-2.1. 
   Ask for it at <rferrer@ac.upc.edu>
 */

#include "c99-parser.h"
#include "cxx-ast.h"
#include "cxx-lexer.h"
#include "cxx-utils.h"

#define YYDEBUG 1
#define YYERROR_VERBOSE 1
// Sometimes we need lots of memory
#define YYMAXDEPTH (10000000)

%}

%glr-parser

%union {
	token_atrib_t token_atrib;
	AST ast;
	node_t node_type;
    const char *text;
};


// This is a specific feature of rofi-bison 2.1
// %default-merge <ambiguityHandler>

%parse-param {AST* parsed_tree}

%{
extern int yylex(void);
static AST ambiguityHandler (YYSTYPE x0, YYSTYPE x1);
void yyerror(AST* parsed_tree UNUSED_PARAMETER, const char* c);
%}

// C++ tokens
%token<token_atrib> ADD_ASSIGN "+="
%token<token_atrib> ANDAND "&&"
%token<token_atrib> AND_ASSIGN "&="
%token<token_atrib> ASM "__asm__"
%token<token_atrib> AUTO "auto"
%token<token_atrib> TOKEN_BOOL "_Bool"
%token<token_atrib> BOOLEAN_LITERAL "boolean-literal"
%token<token_atrib> BREAK "break"
%token<token_atrib> CASE "case"
%token<token_atrib> TOKEN_CHAR "char"
%token<token_atrib> CHARACTER_LITERAL "character-literal"
%token<token_atrib> TOKEN_CONST "const"
%token<token_atrib> CONTINUE "continue"
%token<token_atrib> DECIMAL_LITERAL "decimal-literal"
%token<token_atrib> DEFAULT "default"
%token<token_atrib> DIV_ASSIGN "/="
%token<token_atrib> DO "do"
%token<token_atrib> TOKEN_DOUBLE "double"
%token<token_atrib> ELSE "else"
%token<token_atrib> ENUM "enum"
%token<token_atrib> EQUAL "=="
%token<token_atrib> EXTERN "extern"
%token<token_atrib> TOKEN_FLOAT "float"
%token<token_atrib> FLOATING_LITERAL "floating-literal"
%token<token_atrib> HEXADECIMAL_FLOAT "hexadecimal-floating-literal"
%token<token_atrib> FOR "for"
%token<token_atrib> GOTO "goto"
%token<token_atrib> GREATER_OR_EQUAL ">="
%token<token_atrib> HEXADECIMAL_LITERAL "hexadecimal-integer-literal"
%token<token_atrib> IDENTIFIER "identifier"
%token<token_atrib> IF "if"
%token<token_atrib> INLINE "inline"
%token<token_atrib> TOKEN_INT "int"
%token<token_atrib> LEFT "<<"
%token<token_atrib> LEFT_ASSIGN "<<="
%token<token_atrib> LESS_OR_EQUAL "<="
%token<token_atrib> TOKEN_LONG "long"
%token<token_atrib> MINUSMINUS "--"
%token<token_atrib> MOD_ASSIGN "%="
%token<token_atrib> MUL_ASSIGN "*="
%token<token_atrib> NOT_EQUAL "!="
%token<token_atrib> OCTAL_LITERAL "octal-integer-literal"
%token<token_atrib> OR_ASSIGN "|="
%token<token_atrib> OROR "||"
%token<token_atrib> PLUSPLUS "++"
%token<token_atrib> PTR_OP "->"
%token<token_atrib> REGISTER "register"
%token<token_atrib> RETURN "return"
%token<token_atrib> RIGHT ">>"
%token<token_atrib> RIGHT_ASSIGN ">>="
%token<token_atrib> TOKEN_SHORT "short"
%token<token_atrib> TOKEN_SIGNED "signed"
%token<token_atrib> SIZEOF "sizeof"
%token<token_atrib> STATIC "static"
%token<token_atrib> STRING_LITERAL "string-literal"
%token<token_atrib> STRUCT "struct"
%token<token_atrib> SUB_ASSIGN "-="
%token<token_atrib> SWITCH "switch"
%token<token_atrib> ELLIPSIS "..."
%token<token_atrib> TYPEDEF "typedef"
%token<token_atrib> UNION "union"
%token<token_atrib> TOKEN_UNSIGNED "unsigned"
%token<token_atrib> TOKEN_VOID "void"
%token<token_atrib> TOKEN_VOLATILE "volatile"
%token<token_atrib> WHILE "while"
%token<token_atrib> XOR_ASSIGN "^="

%token<token_atrib> UNKNOWN_PRAGMA "<unknown-pragma>"

%token<token_atrib> PP_COMMENT "<preprocessor-comment>"
%token<token_atrib> PP_TOKEN "<preprocessor-token>"

// Lexical symbols
%token<token_atrib> '!'
%token<token_atrib> '%'
%token<token_atrib> '&'
%token<token_atrib> '('
%token<token_atrib> ')'
%token<token_atrib> '*'
%token<token_atrib> '+'
%token<token_atrib> ','
%token<token_atrib> '-'
%token<token_atrib> '.'
%token<token_atrib> '/'
%token<token_atrib> ':'
%token<token_atrib> ';'
%token<token_atrib> '<'
%token<token_atrib> '='
%token<token_atrib> '>'
%token<token_atrib> '?'
%token<token_atrib> '['
%token<token_atrib> ']'
%token<token_atrib> '^'
%token<token_atrib> '{'
%token<token_atrib> '|'
%token<token_atrib> '}'
%token<token_atrib> '~'

// GNU Extensions
%token<token_atrib> BUILTIN_VA_ARG "__builtin_va_arg"
%token<token_atrib> BUILTIN_OFFSETOF "__builtin_offsetof"
%token<token_atrib> BUILTIN_CHOOSE_EXPR "__builtin_choose_expr"
%token<token_atrib> BUILTIN_TYPES_COMPATIBLE_P "__builtin_types_compatible_p"
%token<token_atrib> ALIGNOF "__alignof__"
%token<token_atrib> EXTENSION "__extension__"
%token<token_atrib> REAL "__real__"
%token<token_atrib> IMAG "__imag__"
%token<token_atrib> LABEL "__label__"
%token<token_atrib> COMPLEX "__complex__"
%token<token_atrib> IMAGINARY "__imaginary__"
%token<token_atrib> TYPEOF "__typeof__"
// This is not a GNU extension, though
%token<token_atrib> RESTRICT "restrict"
%token<token_atrib> ATTRIBUTE "__attribute__"
%token<token_atrib> THREAD "__thread"

// Nonterminals
%type<ast> abstract_declarator
%type<ast> additive_expression
%type<ast> and_expression
%type<ast> asm_definition
%type<ast> asm_operand
%type<ast> asm_operand_list
%type<ast> asm_operand_list_nonempty
%type<ast> asm_specification
%type<ast> assignment_expression
%type<ast> attribute
%type<ast> attribute_list
%type<ast> attributes
%type<ast> attribute_value
%type<ast> block_declaration
%type<ast> non_empty_block_declaration
%type<ast> common_block_declaration
%type<ast> builtin_types
%type<ast> cast_expression
%type<ast> class_head
%type<ast> class_key
%type<ast> class_specifier
%type<ast> compound_statement
%type<ast> condition
%type<ast> condition_opt
%type<ast> conditional_expression
%type<ast> constant_expression
%type<ast> constant_initializer
%type<ast> cv_qualifier
%type<ast> cv_qualifier_seq
%type<ast> declaration
%type<ast> declaration_sequence
%type<ast> declaration_statement
%type<ast> declarator
%type<ast> functional_declarator
%type<ast> declarator_id
%type<ast> functional_declarator_id
%type<ast> final_declarator_id
%type<ast> decl_specifier_seq
%type<ast> decl_specifier_seq_may_end_with_declarator
%type<ast> abstract_direct_declarator
%type<ast> direct_declarator
%type<ast> functional_direct_declarator
%type<ast> optional_array_cv_qualifier_seq
%type<ast> array_cv_qualifier_seq
%type<ast> optional_array_static_qualif
%type<ast> array_static_qualif
%type<ast> optional_array_expression
%type<ast> elaborated_type_specifier
%type<ast> enumeration_definition
%type<ast> enumeration_list
%type<ast> enumeration_list_proper
%type<ast> enum_specifier
%type<ast> equality_expression
%type<ast> exclusive_or_expression
%type<ast> expression
%type<ast> expression_opt
%type<ast> expression_list
%type<ast> expression_statement
%type<ast> for_init_statement
%type<ast> function_body
%type<ast> function_definition
%type<ast> function_specifier
%type<ast> id_expression
%type<ast> if_else_eligible_statements
%type<ast> if_else_statement
%type<ast> if_statement
%type<ast> inclusive_or_expression
%type<ast> init_declarator
%type<ast> init_declarator_list
%type<ast> initializer
%type<ast> initializer_clause
%type<ast> initializer_list
%type<ast> iteration_statement
%type<ast> jump_statement
%type<ast> label_declaration
%type<ast> label_declarator_seq
%type<ast> labeled_statement
%type<ast> literal
%type<ast> logical_and_expression
%type<ast> logical_or_expression
%type<ast> member_declaration
%type<ast> member_declarator
%type<ast> member_declarator_list
%type<ast> member_specification_seq
%type<ast> multiplicative_expression
%type<ast> no_if_statement
%type<ast> parameter_type_list
%type<ast> identifier_list
%type<ast> identifier_list_kr
%type<ast> parameter_declaration
%type<ast> parameter_declaration_list
%type<ast> postfix_expression
%type<ast> primary_expression
%type<ast> ptr_operator
%type<ast> relational_expression
%type<ast> selection_statement
%type<ast> shift_expression
%type<ast> simple_declaration
%type<ast> non_empty_simple_declaration
%type<ast> simple_type_specifier
%type<ast> statement
%type<ast> statement_seq
%type<ast> storage_class_specifier
%type<ast> string_literal
%type<ast> translation_unit
%type<ast> type_id
%type<ast> type_name
%type<ast> type_specifier
%type<ast> type_specifier_seq
%type<ast> type_specifier_seq_may_end_with_attribute
%type<ast> unary_expression
%type<ast> unqualified_id
%type<ast> nontype_specifier_seq
%type<ast> nontype_specifier_no_end_attrib_seq
%type<ast> nontype_specifier
// %type<ast> nontype_specifier_seq2
// %type<ast> nontype_specifier2
%type<ast> volatile_optional
%type<ast> unknown_pragma
%type<ast> designation
%type<ast> designator_list
%type<ast> designator
%type<ast> offsetof_member_designator

%type<ast> old_style_parameter_list
%type<ast> old_style_parameter

%type<ast> nontype_specifier_without_attribute_seq
%type<ast> nontype_specifier_without_attribute

%type<ast> old_style_decl_specifier_seq

%type<ast> decl_specifier_alone_seq
%type<ast> type_specifier_alone

%type<node_type> unary_operator
%type<node_type> assignment_operator





%type<ast> subparse_type_list

// Subparsing
%token<token_atrib> SUBPARSE_EXPRESSION "<subparse-expression>"
%token<token_atrib> SUBPARSE_EXPRESSION_LIST "<subparse-expression-list>"
%token<token_atrib> SUBPARSE_STATEMENT "<subparse-statement>"
%token<token_atrib> SUBPARSE_DECLARATION "<subparse-declaration>"
%token<token_atrib> SUBPARSE_MEMBER "<subparse-member>"
%token<token_atrib> SUBPARSE_TYPE "<subparse-type>"
%token<token_atrib> SUBPARSE_TYPE_LIST "<subparse-type-list>"
%token<token_atrib> SUBPARSE_ID_EXPRESSION "<subparse-id-expression>"

























































































%type<ast> shape_seq
%type<ast> shape
%type<ast> noshape_cast_expression



















































%token<token_atrib> STATEMENT_PLACEHOLDER "<statement-placeholder>"

%{
    static AST* decode_placeholder(const char *);
%}



















// This is code





























%token<token_atrib> VERBATIM_PRAGMA "<verbatim pragma>"
%token<token_atrib> VERBATIM_CONSTRUCT "<verbatim construct>"
%token<token_atrib> VERBATIM_TYPE "<verbatim type clause>"
%token<token_atrib> VERBATIM_TEXT "<verbatim text>"

%type<ast> verbatim_construct


%token<token_atrib> PRAGMA_CUSTOM "<pragma-custom>"
%token<token_atrib> PRAGMA_CUSTOM_NEWLINE "<pragma-custom-newline>"
%token<token_atrib> PRAGMA_CUSTOM_DIRECTIVE "<pragma-custom-directive>"
%token<token_atrib> PRAGMA_CUSTOM_CONSTRUCT "<pragma-custom-construct>"
%token<token_atrib> PRAGMA_CUSTOM_CONSTRUCT_NOEND "<pragma-custom-construct-noend>"
%token<token_atrib> PRAGMA_CUSTOM_END_CONSTRUCT "<pragma-custom-end-construct>"
%token<token_atrib> PRAGMA_CUSTOM_CLAUSE "<pragma-custom-clause>"

%token<token_atrib> PRAGMA_CLAUSE_ARG_TEXT "<pragma-clause-argument-text>"

%type<ast> pragma_custom_directive
%type<ast> pragma_custom_line_directive
%type<ast> pragma_custom_line_construct
%type<ast> pragma_custom_construct_statement

%type<ast> pragma_custom_construct_declaration
%type<ast> pragma_custom_construct_member_declaration








%type<ast> pragma_custom_clause
%type<ast> pragma_custom_clause_seq
%type<ast> pragma_custom_clause_opt_seq

// %type<ast> pragma_expression_entity
// %type<ast> pragma_expression_entity_list

%type<ast> pragma_clause_arg_list

%type<text> pragma_clause_arg
%type<text> pragma_clause_arg_item 
%type<text> pragma_clause_arg_text


































































































































































































































































%type<ast> custom_construct_statement
%type<ast> custom_construct_header
%type<ast> custom_construct_parameters_seq
%type<ast> custom_construct_parameter
%token<token_atrib> CONSTRUCT "__construct__"


















































%token<token_atrib> SUBPARSE_OMP_UDR_DECLARE "<subparse-omp-udr-declare>"
%token<token_atrib> SUBPARSE_OMP_UDR_DECLARE_2 "<subparse-omp-udr-declare-2>"

%type<ast> omp_udr_operator_list
%type<ast> omp_udr_operator
%type<ast> omp_udr_operator_2



%type<ast> omp_udr_unqualified_operator
%type<ast> omp_udr_builtin_op
%type<ast> omp_udr_type_specifier
%type<ast> omp_udr_type_specifier_2
%type<ast> omp_udr_declare_arg
%type<ast> omp_udr_declare_arg_2
%type<ast> omp_udr_expression

%token<token_atrib> SUBPARSE_OMP_UDR_IDENTITY "<subparse-omp-udr-identity>"
%token<token_atrib> OMP_UDR_CONSTRUCTOR "constructor"

%token<token_atrib> SUBPARSE_OMP_OPERATOR_NAME "<subparse_omp_operator_name>"

%type<ast> omp_udr_identity

























































































































































































































































// Lexical Symbol for superscalar regions
%token<token_atrib> TWO_DOTS ".."

// Tokens for subparsing
%token<token_atrib> SUBPARSE_SUPERSCALAR_DECLARATOR "<subparse-superscalar-declarator>"
%token<token_atrib> SUBPARSE_SUPERSCALAR_DECLARATOR_LIST "<subparse-superscalar-declarator-list>"
%token<token_atrib> SUBPARSE_SUPERSCALAR_EXPRESSION "<subparse-superscalar-expression>"

// Tokens for rules
%type<ast> superscalar_declarator superscalar_declarator_list opt_superscalar_region_spec_list superscalar_region_spec_list superscalar_region_spec

















































































%token<token_atrib> UPC_MYTHREAD "MYTHREAD (UPC)" 
%token<token_atrib> UPC_RELAXED "relaxed (UPC)"
%token<token_atrib> UPC_SHARED "shared (UPC)"
%token<token_atrib> UPC_STRICT "strict (UPC)"
%token<token_atrib> UPC_THREADS "THREADS (UPC)"
%token<token_atrib> UPC_BARRIER "upc_barrier"
%token<token_atrib> UPC_BLOCKSIZEOF "upc_blocksizeof"
%token<token_atrib> UPC_ELEMSIZEOF "upc_elemsizeof"
%token<token_atrib> UPC_FENCE "upc_fence"
%token<token_atrib> UPC_FORALL "upc_forall"
%token<token_atrib> UPC_LOCALSIZEOF "upc_localsizeof"
%token<token_atrib> UPC_MAX_BLOCKSIZE "UPC_MAX_BLOCKSIZE"
%token<token_atrib> UPC_NOTIFY "upc_notify"
%token<token_atrib> UPC_WAIT "upc_wait"

%type<ast> upc_shared_type_qualifier
%type<ast> upc_reference_type_qualifier
%type<ast> upc_layout_qualifier
%type<ast> upc_layout_qualifier_element
%type<ast> upc_synchronization_statement
%type<ast> upc_expression_opt
%type<ast> upc_affinity_opt
%type<ast> upc_affinity






















































































































































%token<token_atrib> CUDA_DEVICE "__device__" 
%token<token_atrib> CUDA_GLOBAL "__global__"
%token<token_atrib> CUDA_HOST "__host__"
%token<token_atrib> CUDA_CONSTANT "__constant__"
%token<token_atrib> CUDA_SHARED "__shared__"
%token<token_atrib> CUDA_KERNEL_LEFT "<<<"
%token<token_atrib> CUDA_KERNEL_RIGHT ">>>"

%type<ast> cuda_specifiers
%type<ast> cuda_kernel_call
%type<ast> cuda_kernel_arguments
%type<ast> cuda_kernel_config_list

%type<token_atrib> cuda_kernel_config_left
%type<token_atrib> cuda_kernel_config_right



























































































%token<token_atrib> XL_BUILTIN_SPEC "_Builtin"













%type<ast> subparsing

%start translation_unit

%%

// *********************************************************
// A.3 - Basic concepts
// *********************************************************

translation_unit : declaration_sequence
{
	*parsed_tree = $1;
}
| /* empty */
{
	*parsed_tree = NULL;
}
;

// *********************************************************
// A.6. - Declarations
// *********************************************************

declaration_sequence : declaration
{
	$$ = ASTListLeaf($1);
}
| declaration_sequence declaration
{
	$$ = ASTList($1, $2);
}
;

declaration : block_declaration 
{
	$$ = $1;
}
| function_definition
{
	$$ = $1;
}
;

block_declaration : simple_declaration
{
	$$ = $1;
}
| common_block_declaration
{
    $$ = $1;
}
;

non_empty_block_declaration : non_empty_simple_declaration
{
    $$ = $1;
}
| common_block_declaration
{
    $$ = $1;
}
;

common_block_declaration : asm_definition
{
	$$ = $1;
}
/* GNU extensions */
| label_declaration 
{
	$$ = $1;
}
| EXTENSION block_declaration
{
	$$ = ASTMake1(AST_GCC_EXTENSION, $2, $1.token_file, $1.token_line, $1.token_text);
}
/* Handling of unknown pragmae */
| unknown_pragma
{
	$$ = $1;
}
// Prettyprinted comments
| PP_COMMENT
{
	$$ = ASTLeaf(AST_PP_COMMENT, $1.token_file, $1.token_line, $1.token_text);
}
// Prettyprinted preprocessor elements
| PP_TOKEN
{
	$$ = ASTLeaf(AST_PP_TOKEN, $1.token_file, $1.token_line, $1.token_text);
}
;

/* GNU Extension */
label_declaration : LABEL label_declarator_seq ';'
{
	$$ = ASTMake1(AST_GCC_LABEL_DECL, $2, $1.token_file, $1.token_line, NULL);
}
;

label_declarator_seq : IDENTIFIER 
{
    AST symbol_holder = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);
	$$ = ASTListLeaf(symbol_holder);
}
| label_declarator_seq ',' IDENTIFIER
{
	AST label = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);
	$$ = ASTList($1, label);
}
;
/* End of GNU extension */

/* GNU Extension */
attributes : attributes attribute
{
	$$ = ASTList($1, $2);
}
| attribute
{
	$$ = ASTListLeaf($1);
}
;

attribute : ATTRIBUTE '(' '(' attribute_list ')' ')'
{
	$$ = ASTMake1(AST_GCC_ATTRIBUTE, $4, $1.token_file, $1.token_line, $1.token_text);
}
| ATTRIBUTE '(''(' ')'')'
{
	$$ = ASTMake1(AST_GCC_ATTRIBUTE, NULL, $1.token_file, $1.token_line, $1.token_text);
}
;

attribute_list : attribute_value
{
	$$ = ASTListLeaf($1);
}
| attribute_list ',' attribute_value
{
	$$ = ASTList($1, $3);
}
;

// Why on earth ASTSon1 is always null ?
attribute_value : IDENTIFIER
{
	AST identif = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);

	$$ = ASTMake3(AST_GCC_ATTRIBUTE_EXPR, identif, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
| TOKEN_CONST
{
	AST identif = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);

	$$ = ASTMake3(AST_GCC_ATTRIBUTE_EXPR, identif, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
| IDENTIFIER '(' expression_list ')'
{
	AST identif1 = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);
	
	$$ = ASTMake3(AST_GCC_ATTRIBUTE_EXPR, identif1, NULL, $3, $1.token_file, $1.token_line, NULL);
}
;
/* End of GNU extension */

asm_definition : ASM volatile_optional '(' string_literal ')' ';'
{
	$$ = ASTMake2(AST_ASM_DEFINITION, $4, $2, $1.token_file, $1.token_line, $1.token_text);
}
// From here, none of these asm-definitions are standard but gcc only
| ASM volatile_optional '(' string_literal ':' asm_operand_list ')' ';'
{
	AST asm_parms = ASTMake4(AST_GCC_ASM_DEF_PARMS, 
			$4, $6, NULL, NULL, ASTFileName($4), ASTLine($4), NULL);
	$$ = ASTMake2(AST_GCC_ASM_DEFINITION, $2, asm_parms, $1.token_file, $1.token_line, $1.token_text);
}
| ASM volatile_optional '(' string_literal ':' asm_operand_list ':' asm_operand_list ')' ';'
{
	AST asm_parms = ASTMake4(AST_GCC_ASM_DEF_PARMS, 
			$4, $6, $8, NULL, ASTFileName($4), ASTLine($4), NULL);
	$$ = ASTMake2(AST_GCC_ASM_DEFINITION, $2, asm_parms, $1.token_file, $1.token_line, $1.token_text);
}
| ASM volatile_optional '(' string_literal ':' asm_operand_list ':' asm_operand_list ':' asm_operand_list ')' ';'
{
	AST asm_parms = ASTMake4(AST_GCC_ASM_DEF_PARMS, 
			$4, $6, $8, $10, ASTFileName($4), ASTLine($4), NULL);
	$$ = ASTMake2(AST_GCC_ASM_DEFINITION, $2, asm_parms, $1.token_file, $1.token_line, $1.token_text);
}
;

volatile_optional : /* empty */
{
	$$ = NULL;
}
| TOKEN_VOLATILE
{
	$$ = ASTLeaf(AST_VOLATILE_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
;

asm_operand_list : asm_operand_list_nonempty
{
	$$ = $1;
}
| /* empty */
{
	$$ = NULL;
};


/* GNU Extensions */
asm_operand_list_nonempty : asm_operand
{
	$$ = ASTListLeaf($1);
}
| asm_operand_list_nonempty ',' asm_operand
{
	$$ = ASTList($1, $3);
}
;

asm_operand : string_literal '(' expression ')' 
{
	$$ = ASTMake3(AST_GCC_ASM_OPERAND, NULL, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| '[' IDENTIFIER ']' string_literal '(' expression ')'
{
    AST symbol_tree = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

	$$ = ASTMake3(AST_GCC_ASM_OPERAND, symbol_tree, $4, $6, $1.token_file, $1.token_line, NULL);
}
| string_literal
{
	$$ = $1;
}
;
/* End of GNU extensions */


simple_declaration : non_empty_simple_declaration
{
    $$ = $1;
}
| ';'
{
    // This is an error but also a common extension
    $$ = ASTLeaf(AST_EMPTY_DECL, $1.token_file, $1.token_line, $1.token_text);
}
;

non_empty_simple_declaration : decl_specifier_seq init_declarator_list ';'  %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_SIMPLE_DECLARATION, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| decl_specifier_alone_seq ';' %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_SIMPLE_DECLARATION, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| init_declarator_list ';'  %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_SIMPLE_DECLARATION, NULL, $1, ASTFileName($1), ASTLine($1), NULL);
}
;

old_style_parameter : old_style_decl_specifier_seq init_declarator_list ';' 
{
	$$ = ASTMake2(AST_SIMPLE_DECLARATION, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
;

old_style_decl_specifier_seq : nontype_specifier_without_attribute_seq type_specifier nontype_specifier_seq
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_without_attribute_seq type_specifier
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier nontype_specifier_seq
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_without_attribute_seq
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

// This avoids a conflict existing in GCC
nontype_specifier_without_attribute_seq : nontype_specifier_without_attribute 
{
    $$ = ASTListLeaf($1);
}
| nontype_specifier_without_attribute_seq nontype_specifier_without_attribute
{
    $$ = ASTList($1, $2);
}
;

decl_specifier_seq : nontype_specifier_seq type_specifier nontype_specifier_no_end_attrib_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_seq type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier nontype_specifier_no_end_attrib_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_no_end_attrib_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

decl_specifier_seq_may_end_with_declarator : nontype_specifier_seq type_specifier nontype_specifier_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_seq type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier nontype_specifier_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

// This does not declare an object, maybe just types, so restrict it a bit
// 
// Note that, in contrast to decl_specifier_seq, we allow here to end with an attribute
// ('nontype_specifier_seq' instead of 'nontype_specifier_no_end_attrib_seq')
// In these cases there is not any declarator, so a trailing __attribute__ would not be
// valid
decl_specifier_alone_seq : nontype_specifier_seq type_specifier_alone nontype_specifier_seq
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_seq type_specifier_alone
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier_alone nontype_specifier_seq
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier_alone
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

nontype_specifier_seq : nontype_specifier
{
	$$ = ASTListLeaf($1);
}
| nontype_specifier_seq nontype_specifier
{
	$$ = ASTList($1, $2);
}
;

nontype_specifier_no_end_attrib_seq : nontype_specifier_without_attribute
{
    $$ = ASTListLeaf($1);
}
| nontype_specifier_seq nontype_specifier_without_attribute
{
    $$ = ASTList($1, $2);
}
;

nontype_specifier : nontype_specifier_without_attribute
{
    $$ = $1;
}
| attribute
{
	$$ = $1;
}

nontype_specifier_without_attribute : storage_class_specifier
{
	$$ = $1;
}
| function_specifier
{
	$$ = $1;
}
| TYPEDEF
{
	$$ = ASTLeaf(AST_TYPEDEF_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
// To ease things
| cv_qualifier
{
	$$ = $1;
}
// Repeat them
| TOKEN_SIGNED
{
	$$ = ASTLeaf(AST_SIGNED_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_UNSIGNED
{
	$$ = ASTLeaf(AST_UNSIGNED_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_LONG
{
	$$ = ASTLeaf(AST_LONG_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_SHORT
{
	$$ = ASTLeaf(AST_SHORT_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
// GNU Extension for C++ but not for C99
| COMPLEX
{
	$$ = ASTLeaf(AST_GCC_COMPLEX_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| IMAGINARY
{
	$$ = ASTLeaf(AST_GCC_IMAGINARY_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
;

storage_class_specifier : AUTO 
{
	$$ = ASTLeaf(AST_AUTO_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
| REGISTER
{
	$$ = ASTLeaf(AST_REGISTER_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
| STATIC
{
	$$ = ASTLeaf(AST_STATIC_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
| EXTERN
{
	$$ = ASTLeaf(AST_EXTERN_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
// GNU Extension
| THREAD
{
	$$ = ASTLeaf(AST_THREAD_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
;

function_specifier : INLINE
{
	$$ = ASTLeaf(AST_INLINE_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
;

type_specifier : type_specifier_alone
{
}
| simple_type_specifier
{
    $$ = $1;
}
// GNU Extensions
| COMPLEX
{
	$$ = ASTLeaf(AST_GCC_COMPLEX_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
;

type_specifier_alone : class_specifier
{
	$$ = $1;
}
| enum_specifier
{
	$$ = $1;
}
| elaborated_type_specifier
{
	$$ = $1;
}
;

type_specifier_seq : nontype_specifier_seq type_specifier nontype_specifier_no_end_attrib_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_seq type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier nontype_specifier_no_end_attrib_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_no_end_attrib_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

type_specifier_seq_may_end_with_attribute : nontype_specifier_seq type_specifier nontype_specifier_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_seq type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier nontype_specifier_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, NULL, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| nontype_specifier_seq %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_TYPE_SPECIFIER_SEQ, $1, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

simple_type_specifier : type_name
{
	$$ = ASTMake1(AST_SIMPLE_TYPE_SPEC, $1, ASTFileName($1), ASTLine($1), NULL);
}
| builtin_types
{
	$$ = $1;
}
// GNU Extension. Somebody decided that this had to be different in gcc and g++
| TYPEOF '(' expression ')' %merge<ambiguityHandler>
{
	$$ = ASTMake1(AST_GCC_TYPEOF_EXPR, $3, $1.token_file, $1.token_line, $1.token_text);
}
| TYPEOF '(' type_id ')' %merge<ambiguityHandler>
{
	$$ = ASTMake1(AST_GCC_TYPEOF, $3, $1.token_file, $1.token_line, $1.token_text);
}
;

// Simplified rule
type_name : IDENTIFIER
{
	$$ = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);
}
;

builtin_types : TOKEN_CHAR
{
	$$ = ASTLeaf(AST_CHAR_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_BOOL
{
	$$ = ASTLeaf(AST_BOOL_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_SHORT
{
	$$ = ASTLeaf(AST_SHORT_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_INT
{
	$$ = ASTLeaf(AST_INT_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_LONG
{
	$$ = ASTLeaf(AST_LONG_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_SIGNED
{
	$$ = ASTLeaf(AST_SIGNED_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_UNSIGNED
{
	$$ = ASTLeaf(AST_UNSIGNED_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_FLOAT
{
	$$ = ASTLeaf(AST_FLOAT_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_DOUBLE
{
	$$ = ASTLeaf(AST_DOUBLE_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_VOID
{
	$$ = ASTLeaf(AST_VOID_TYPE, $1.token_file, $1.token_line, $1.token_text);
}
;

elaborated_type_specifier : class_key IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

	$$ = ASTMake2(AST_ELABORATED_TYPE_CLASS_SPEC, $1, identifier, ASTFileName($1), ASTLine($1), NULL);
}
| ENUM IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

	$$ = ASTMake1(AST_ELABORATED_TYPE_ENUM_SPEC, identifier, $1.token_file, $1.token_line, NULL);
}
// GNU Extensions
| class_key attributes IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);

	$$ = ASTMake3(AST_GCC_ELABORATED_TYPE_CLASS_SPEC, $1, identifier, $2, ASTFileName($1), ASTLine($1), NULL);
}
| ENUM attributes IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);

	$$ = ASTMake2(AST_GCC_ELABORATED_TYPE_ENUM_SPEC, identifier, $2, $1.token_file, $1.token_line, NULL);
}
;

// *********************************************************
// A.7 - Declarators
// *********************************************************
init_declarator_list : init_declarator
{
	$$ = ASTListLeaf($1);
}
| init_declarator_list ',' init_declarator
{
	$$ = ASTList($1, $3);
}
;

init_declarator : declarator 
{
	$$ = ASTMake2(AST_INIT_DECLARATOR, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| declarator initializer
{
	$$ = ASTMake2(AST_INIT_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
// GNU Extensions
| declarator asm_specification 
{
	$$ = ASTMake4(AST_GCC_INIT_DECLARATOR, $1, NULL, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| declarator attributes
{
	$$ = ASTMake4(AST_GCC_INIT_DECLARATOR, $1, NULL, NULL, $2, ASTFileName($1), ASTLine($1), NULL);
}
| declarator asm_specification attributes
{
	$$ = ASTMake4(AST_GCC_INIT_DECLARATOR, $1, NULL, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
| declarator asm_specification initializer
{
	$$ = ASTMake4(AST_GCC_INIT_DECLARATOR, $1, $3, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| declarator attributes initializer
{
	$$ = ASTMake4(AST_GCC_INIT_DECLARATOR, $1, $3, NULL, $2, ASTFileName($1), ASTLine($1), NULL);
}
| declarator asm_specification attributes initializer
{
	$$ = ASTMake4(AST_GCC_INIT_DECLARATOR, $1, $4, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

/* GNU Extension */
asm_specification : ASM '(' string_literal ')'
{
	$$ = ASTMake1(AST_GCC_ASM_SPEC, $3, $1.token_file, $1.token_line, $1.token_text);
}
;
/* End of GNU Extension */

declarator : direct_declarator
{
	$$ = ASTMake1(AST_DECLARATOR, $1, ASTFileName($1), ASTLine($1), NULL);
}
| ptr_operator declarator
{
	$$ = ASTMake2(AST_POINTER_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
/* GNU Extension */
| attributes direct_declarator
{
    $$ = ASTMake2(AST_GCC_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| attributes ptr_operator declarator
{
    $$ = ASTMake3(AST_GCC_POINTER_DECLARATOR, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

ptr_operator : '*'
{
	$$ = ASTMake2(AST_POINTER_SPEC, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
| '*' cv_qualifier_seq
{
	$$ = ASTMake2(AST_POINTER_SPEC, NULL, $2, $1.token_file, $1.token_line, NULL);
}
;

/*
   A functional declarator is a syntactic enforced declarator that will have
   a functional nature
 */
functional_declarator : functional_direct_declarator
{
	$$ = ASTMake1(AST_DECLARATOR, $1, ASTFileName($1), ASTLine($1), NULL);
}
| ptr_operator functional_declarator
{
	$$ = ASTMake2(AST_POINTER_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
// GNU extension
| attributes functional_direct_declarator
{
	$$ = ASTMake2(AST_GCC_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| attributes ptr_operator functional_declarator
{
	$$ = ASTMake3(AST_GCC_POINTER_DECLARATOR, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

functional_direct_declarator : functional_declarator_id
{
	$$ = $1;
}
| '(' functional_declarator ')'
{
	$$ = ASTMake1(AST_PARENTHESIZED_DECLARATOR, $2, $1.token_file, $1.token_line, NULL);
}
;

// This eases the writing of array declarators
optional_array_cv_qualifier_seq : /* empty */
{
    $$ = NULL;
}
| array_cv_qualifier_seq
{
    $$ = $1;
}
;

array_cv_qualifier_seq : cv_qualifier_seq
{
    $$ = $1;
}
;

// This eases the writing of array declarators
optional_array_static_qualif : /* empty */
{
    $$ = NULL;
}
| array_static_qualif
{
    $$ = $1;
};

array_static_qualif : STATIC
{
    $$ = ASTLeaf(AST_STATIC_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
;

// This eases the writing of array declarators
optional_array_expression : /* empty */
{
    $$ = NULL;
}
| '*'
{
    $$ = ASTLeaf(AST_VLA_EXPRESSION, $1.token_file, $1.token_line, $1.token_text);
}
| assignment_expression
{
    $$ = $1;
}
;

functional_declarator_id : final_declarator_id '(' parameter_type_list ')' %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, $3, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| final_declarator_id '(' identifier_list ')' %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, $3, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| final_declarator_id '(' ')'
{
	AST empty_parameter = ASTLeaf(AST_EMPTY_PARAMETER_DECLARATION_CLAUSE, NULL, 0, NULL);

	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, empty_parameter, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

// This rule is needed because of redundant parentheses
final_declarator_id : declarator_id
{
    $$ = $1;
}
|
'(' final_declarator_id ')'
{
    $$ = ASTMake1(AST_PARENTHESIZED_DECLARATOR, $2, $1.token_file, $1.token_line, NULL);
}
;

cv_qualifier_seq : cv_qualifier
{
	$$ = ASTListLeaf($1);
}
| cv_qualifier_seq cv_qualifier
{
	$$ = ASTList($1, $2);
}
;

cv_qualifier : TOKEN_CONST
{
	$$ = ASTLeaf(AST_CONST_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
| TOKEN_VOLATILE
{
	$$ = ASTLeaf(AST_VOLATILE_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
// GNU Extension
| RESTRICT
{
	$$ = ASTLeaf(AST_GCC_RESTRICT_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
;

direct_declarator : declarator_id
{
	$$ = $1;
}
| direct_declarator '(' ')'
{
	AST empty_parameter = ASTLeaf(AST_EMPTY_PARAMETER_DECLARATION_CLAUSE, NULL, 0, NULL);

	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, empty_parameter, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| direct_declarator '(' identifier_list ')' %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, $3, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| direct_declarator '(' parameter_type_list ')' %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, $3, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| direct_declarator '[' optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, $1, $3, NULL, NULL,  ASTFileName($1), ASTLine($1), NULL);
}
| direct_declarator '[' array_cv_qualifier_seq optional_array_static_qualif optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, $1, $5, $3, $4,  ASTFileName($1), ASTLine($1), NULL);
}
| direct_declarator '[' array_static_qualif optional_array_cv_qualifier_seq optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, $1, $5, $4, $3,  ASTFileName($1), ASTLine($1), NULL);
}
| '(' declarator ')'
{
	$$ = ASTMake1(AST_PARENTHESIZED_DECLARATOR, $2, $1.token_file, $1.token_line, NULL);
}
;

declarator_id : id_expression
{
	$$ = ASTMake1(AST_DECLARATOR_ID_EXPR, $1, ASTFileName($1), ASTLine($1), NULL);
}
;


enum_specifier : ENUM IDENTIFIER '{' enumeration_list '}'
{
	AST identifier = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

	$$ = ASTMake2(AST_ENUM_SPECIFIER, identifier, $4, $1.token_file, $1.token_line, NULL);
}
| ENUM '{' enumeration_list '}'
{
	$$ = ASTMake2(AST_ENUM_SPECIFIER, NULL, $3, $1.token_file, $1.token_line, NULL);
}
| ENUM IDENTIFIER '{' '}'
{
	AST identifier = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

	$$ = ASTMake2(AST_ENUM_SPECIFIER, identifier, NULL, $1.token_file, $1.token_line, NULL);
}
| ENUM '{' '}'
{
	$$ = ASTMake2(AST_ENUM_SPECIFIER, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
// GCC extensions
| ENUM attributes IDENTIFIER '{' enumeration_list '}'
{
	AST identifier = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);

	$$ = ASTMake3(AST_GCC_ENUM_SPECIFIER, identifier, $5, $2, $1.token_file, $1.token_line, NULL);
}
| ENUM attributes '{' enumeration_list '}'
{
	$$ = ASTMake3(AST_GCC_ENUM_SPECIFIER, NULL, $4, $2, $1.token_file, $1.token_line, NULL);
}
| ENUM attributes IDENTIFIER '{' '}'
{
	AST identifier = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);

	$$ = ASTMake3(AST_GCC_ENUM_SPECIFIER, identifier, NULL, $2, $1.token_file, $1.token_line, NULL);
}
| ENUM attributes '{' '}'
{
	$$ = ASTMake3(AST_GCC_ENUM_SPECIFIER, NULL, NULL, $2, $1.token_file, $1.token_line, NULL);
}
;
;

enumeration_list : enumeration_list_proper
{
	$$ = $1;
}
// This is a running comma that many people forgets here. It is of non
// standard nature
| enumeration_list_proper ','
{
	$$ = $1;
};

enumeration_list_proper : enumeration_list_proper ',' enumeration_definition
{
	$$ = ASTList($1, $3);
}
| enumeration_definition
{
	$$ = ASTListLeaf($1);
}
;

enumeration_definition : IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);

	$$ = ASTMake2(AST_ENUMERATOR_DEF, identifier, NULL, $1.token_file, $1.token_line, NULL);
}
| IDENTIFIER '=' constant_expression
{
	AST identifier = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);

	$$ = ASTMake2(AST_ENUMERATOR_DEF, identifier, $3, $1.token_file, $1.token_line, NULL);
}
;

type_id : type_specifier_seq_may_end_with_attribute
{
	$$ = ASTMake2(AST_TYPE_ID, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier_seq abstract_declarator
{
	$$ = ASTMake2(AST_TYPE_ID, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
;

abstract_declarator : ptr_operator
{
	$$ = ASTMake2(AST_POINTER_DECLARATOR, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| ptr_operator abstract_declarator
{
	$$ = ASTMake2(AST_POINTER_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| abstract_direct_declarator
{
	$$ = ASTMake1(AST_DECLARATOR, $1, ASTFileName($1), ASTLine($1), NULL);
}
// GNU extension
| attributes ptr_operator
{
	$$ = ASTMake2(AST_GCC_POINTER_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| attributes ptr_operator abstract_declarator
{
	$$ = ASTMake2(AST_GCC_POINTER_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| attributes abstract_direct_declarator
{
	$$ = ASTMake2(AST_GCC_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
;

abstract_direct_declarator : '(' abstract_declarator ')'
{
	$$ = ASTMake1(AST_PARENTHESIZED_DECLARATOR, $2, $1.token_file, $1.token_line, NULL);
}
| '(' parameter_type_list ')' %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_DECLARATOR_FUNC, NULL, $2, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
| abstract_direct_declarator '(' parameter_type_list ')' %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, $3, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| '(' ')'
{
	AST empty_parameter = ASTLeaf(AST_EMPTY_PARAMETER_DECLARATION_CLAUSE, NULL, 0, NULL);

	$$ = ASTMake4(AST_DECLARATOR_FUNC, NULL, empty_parameter, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
| abstract_direct_declarator '(' ')'
{
	AST empty_parameter = ASTLeaf(AST_EMPTY_PARAMETER_DECLARATION_CLAUSE, NULL, 0, NULL);

	$$ = ASTMake4(AST_DECLARATOR_FUNC, $1, empty_parameter, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| '[' optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, NULL, $2, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
| '[' array_cv_qualifier_seq optional_array_static_qualif optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, NULL, $4, $2, $3, $1.token_file, $1.token_line, NULL);
}
| '[' array_static_qualif optional_array_cv_qualifier_seq optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, NULL, $4, $3, $2, $1.token_file, $1.token_line, NULL);
}
| abstract_direct_declarator '[' optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, $1, $3, NULL, NULL,  ASTFileName($1), ASTLine($1), NULL);
}
| abstract_direct_declarator '[' array_cv_qualifier_seq optional_array_static_qualif optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, $1, $5, $3, $4,  ASTFileName($1), ASTLine($1), NULL);
}
| abstract_direct_declarator '[' array_static_qualif optional_array_cv_qualifier_seq optional_array_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, $1, $5, $4, $3,  ASTFileName($1), ASTLine($1), NULL);
}
;

identifier_list : identifier_list_kr
{
    $$ = ASTMake1(AST_KR_PARAMETER_LIST, $1, ASTFileName($1), ASTLine($1), NULL);
};

identifier_list_kr : IDENTIFIER
{
    AST symbol = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);

    $$ = ASTListLeaf(symbol);
}
| identifier_list_kr ',' IDENTIFIER 
{
    AST symbol = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);

    $$ = ASTList($1, symbol);
}
;

parameter_type_list : parameter_declaration_list
{
    $$ = $1;
}
| parameter_declaration_list ',' ELLIPSIS
{
    AST variadic_arg = ASTLeaf(AST_VARIADIC_ARG, $3.token_file, $3.token_line, $3.token_text);
	$$ = ASTList($1, variadic_arg);
}
;

parameter_declaration_list : parameter_declaration
{
	$$ = ASTListLeaf($1);
}
| parameter_declaration_list ',' parameter_declaration
{
	$$ = ASTList($1, $3);
}
;

parameter_declaration : decl_specifier_seq declarator %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_PARAMETER_DECL, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| decl_specifier_seq_may_end_with_declarator %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_PARAMETER_DECL, $1, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| decl_specifier_seq abstract_declarator %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_PARAMETER_DECL, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
// GCC Extension
| decl_specifier_seq declarator attributes %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_GCC_PARAMETER_DECL, $1, $2, NULL, $3, ASTFileName($1), ASTLine($1), NULL);
}
| decl_specifier_seq abstract_declarator attributes %merge<ambiguityHandler>
{
	$$ = ASTMake4(AST_GCC_PARAMETER_DECL, $1, $2, NULL, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

initializer : '=' initializer_clause
{
	$$ = ASTMake1(AST_EQUAL_INITIALIZER, $2, $1.token_file, $1.token_line, NULL);
}
;

initializer_clause : assignment_expression
{
	$$ = $1;
}
| '{' initializer_list '}'
{
	$$ = ASTMake1(AST_INITIALIZER_BRACES, $2, $1.token_file, $1.token_line, NULL);
}
| '{' initializer_list ',' '}'
{
	$$ = ASTMake1(AST_INITIALIZER_BRACES, $2, $1.token_file, $1.token_line, NULL);
}
| '{' '}'
{
	$$ = ASTMake1(AST_INITIALIZER_BRACES, NULL, $1.token_file, $1.token_line, NULL);
}
;

initializer_list : initializer_clause
{
	$$ = ASTListLeaf($1);
}
| initializer_list ',' initializer_clause
{
	$$ = ASTList($1, $3);
}
| designation initializer_clause
{
    AST designated_initializer = ASTMake2(AST_DESIGNATED_INITIALIZER, $1, $2, ASTFileName($1), ASTLine($1), NULL);

    $$ = ASTListLeaf(designated_initializer);
}
| initializer_list ',' designation initializer_clause
{
    AST designated_initializer = ASTMake2(AST_DESIGNATED_INITIALIZER, $3, $4, ASTFileName($3), ASTLine($3), NULL);

    $$ = ASTList($1, designated_initializer);
}
// GNU Extensions
| IDENTIFIER ':' initializer_clause
{
	AST identifier = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);

	AST gcc_initializer_clause = ASTMake2(AST_GCC_INITIALIZER_CLAUSE, identifier, $3, $1.token_file, $1.token_line, NULL);

	$$ = ASTListLeaf(gcc_initializer_clause);
}
| initializer_list ',' IDENTIFIER ':' initializer_clause
{
	AST identifier = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);

	AST gcc_initializer_clause = ASTMake2(AST_GCC_INITIALIZER_CLAUSE, identifier, $5, ASTFileName($1), ASTLine($1), NULL);

	$$ = ASTList($1, gcc_initializer_clause);
}
;

designation : designator_list '='
{
    $$ = ASTMake1(AST_DESIGNATION, $1, ASTFileName($1), ASTLine($1), NULL);
}
;

designator_list : designator
{
    $$ = ASTListLeaf($1);
}
| designator_list designator
{
    $$ = ASTList($1, $2);
}
;

designator : '[' constant_expression ']'
{
    $$ = ASTMake1(AST_INDEX_DESIGNATOR, $2, $1.token_file, $1.token_line, NULL);
}
| '.' IDENTIFIER
{
    AST symbol = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

    $$ = ASTMake1(AST_FIELD_DESIGNATOR, symbol, $1.token_file, $1.token_line, NULL);
}
;

function_definition : decl_specifier_seq functional_declarator function_body
{
	$$ = ASTMake4(AST_FUNCTION_DEFINITION, $1, $2, NULL, $3, ASTFileName($1), ASTLine($1), NULL);
}
| decl_specifier_seq functional_declarator old_style_parameter_list function_body
{
	$$ = ASTMake4(AST_FUNCTION_DEFINITION, $1, $2, $3, $4, ASTFileName($1), ASTLine($1), NULL);
}
/* This is an ugly heritage from C90 */
| functional_declarator function_body 
{
    $$ = ASTMake4(AST_FUNCTION_DEFINITION, NULL, $1, NULL, $2, ASTFileName($1), ASTLine($1), NULL);
}
| functional_declarator old_style_parameter_list function_body 
{
    $$ = ASTMake4(AST_FUNCTION_DEFINITION, NULL, $1, $2, $3, ASTFileName($1), ASTLine($1), NULL);
}
// GCC extension
| EXTENSION function_definition
{
	$$ = ASTMake1(AST_GCC_EXTENSION, $2, $1.token_file, $1.token_line, $1.token_text);
}
;

old_style_parameter_list : old_style_parameter
{
    $$ = ASTListLeaf($1);
}
| old_style_parameter_list old_style_parameter
{
    $$ = ASTList($1, $2);
}
;

function_body : compound_statement
{
	$$ = ASTMake1(AST_FUNCTION_BODY, $1, ASTFileName($1), ASTLine($1), NULL);
}
;

// *********************************************************
// A.8 - Classes
// *********************************************************

class_specifier : class_head '{' member_specification_seq '}'
{
	$$ = ASTMake2(AST_CLASS_SPECIFIER, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| class_head '{' '}'
{
	$$ = ASTMake2(AST_CLASS_SPECIFIER, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

class_head : class_key 
{
	$$ = ASTMake3(AST_CLASS_HEAD_SPEC, $1, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| class_key IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

	$$ = ASTMake3(AST_CLASS_HEAD_SPEC, $1, identifier, NULL, ASTFileName($1), ASTLine($1), NULL);
}
// GNU Extensions
| class_key attributes
{
	$$ = ASTMake4(AST_GCC_CLASS_HEAD_SPEC, $1, NULL, NULL, $2, ASTFileName($1), ASTLine($1), NULL);
}
| class_key attributes IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $3.token_file, $3.token_line, $3.token_text);

	$$ = ASTMake4(AST_GCC_CLASS_HEAD_SPEC, $1, identifier, NULL, $2, ASTFileName($1), ASTLine($1), NULL);
}
;

class_key : STRUCT
{
	$$ = ASTLeaf(AST_CLASS_KEY_STRUCT, $1.token_file, $1.token_line, $1.token_text);
}
| UNION
{
	$$ = ASTLeaf(AST_CLASS_KEY_UNION, $1.token_file, $1.token_line, $1.token_text);
}
;

member_specification_seq : member_declaration
{
	$$ = ASTListLeaf($1);
}
| member_specification_seq member_declaration
{
	$$ = ASTList($1, $2);
}
;

member_declaration : decl_specifier_seq member_declarator_list ';'  %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_MEMBER_DECLARATION, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| decl_specifier_alone_seq ';' %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_MEMBER_DECLARATION, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| unknown_pragma
{
	$$ = $1;
}
// This is a common tolerated error
| ';' 
{
	$$ = ASTLeaf(AST_EMPTY_DECL, $1.token_file, $1.token_line, NULL);
}
// GNU Extension
| EXTENSION member_declaration
{
	$$ = ASTMake1(AST_GCC_EXTENSION, $2, $1.token_file, $1.token_line, $1.token_text);
}
;

member_declarator_list : member_declarator
{
	$$ = ASTListLeaf($1);
}
| member_declarator_list ',' member_declarator
{
	$$ = ASTList($1, $3);
}
;

member_declarator : declarator 
{
	$$ = ASTMake2(AST_MEMBER_DECLARATOR, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| declarator constant_initializer
{
	$$ = ASTMake2(AST_MEMBER_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
| ':' constant_expression
{
	$$ = ASTMake2(AST_BITFIELD_DECLARATOR, NULL, $2, $1.token_file, $1.token_line, NULL);
}
| IDENTIFIER ':' constant_expression
{
	AST identifier = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);
	AST declarator_id_expr = ASTMake1(AST_DECLARATOR_ID_EXPR, identifier, ASTFileName(identifier), ASTLine(identifier), NULL);

	$$ = ASTMake2(AST_BITFIELD_DECLARATOR, declarator_id_expr, $3, $1.token_file, $1.token_line, NULL);
}
// GNU Extensions
| declarator attributes 
{
	$$ = ASTMake3(AST_GCC_MEMBER_DECLARATOR, $1, NULL, $2, ASTFileName($1), ASTLine($1), NULL);
}
| declarator attributes constant_initializer
{
	$$ = ASTMake3(AST_GCC_MEMBER_DECLARATOR, $1, $3, $2, ASTFileName($1), ASTLine($1), NULL);
}
| IDENTIFIER attributes ':' constant_expression
{
	AST identifier = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);

	$$ = ASTMake3(AST_GCC_BITFIELD_DECLARATOR, identifier, $4, $2, $1.token_file, $1.token_line, NULL);
}
| attributes ':' constant_expression
{
	$$ = ASTMake3(AST_GCC_BITFIELD_DECLARATOR, NULL, $3, $1, ASTFileName($1), ASTLine($1), NULL);
}
;

constant_initializer : '=' constant_expression
{
	$$ = $2;
}
;

// *********************************************************
// A.5. - Statements
// *********************************************************

statement : no_if_statement
{
	$$ = $1;
}
| if_statement %dprec 2
{
	$$ = $1;
}
| if_else_statement %dprec 1
{
	$$ = $1;
}
;

no_if_statement : labeled_statement
{
	$$ = $1;
}
| expression_statement %merge<ambiguityHandler>
{
	$$ = $1;
}
| compound_statement
{
	$$ = $1;
}
| selection_statement
{
	$$ = $1;
}
| iteration_statement
{
	$$ = $1;
}
| jump_statement
{
	$$ = $1;
}
| declaration_statement %merge<ambiguityHandler>
{
	$$ = $1;
}
;


labeled_statement : IDENTIFIER ':' statement
{
	AST identifier = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);
	
	$$ = ASTMake2(AST_LABELED_STATEMENT, identifier, $3, $1.token_file, $1.token_line, NULL);
}
| CASE constant_expression ':' statement
{
	$$ = ASTMake2(AST_CASE_STATEMENT, $2, $4, $1.token_file, $1.token_line, NULL);
}
| DEFAULT ':' statement
{
	$$ = ASTMake1(AST_DEFAULT_STATEMENT, $3, $1.token_file, $1.token_line, NULL);
}
// GNU Extension
| CASE constant_expression ELLIPSIS constant_expression ':' statement
{
	$$ = ASTMake3(AST_GCC_CASE_STATEMENT, $2, $4, $6, $1.token_file, $1.token_line, NULL);
}
;

expression_statement : expression ';'
{
	$$ = ASTMake1(AST_EXPRESSION_STATEMENT, $1, ASTFileName($1), ASTLine($1), NULL);
}
| ';'
{
	// Empty statement ...
	$$ = ASTLeaf(AST_EMPTY_STATEMENT, $1.token_file, $1.token_line, NULL);
}
;

declaration_statement : non_empty_block_declaration
{
	$$ = ASTMake1(AST_DECLARATION_STATEMENT, $1, ASTFileName($1), ASTLine($1), NULL);
}
;

compound_statement : '{' statement_seq '}'
{
	$$ = ASTMake1(AST_COMPOUND_STATEMENT, $2, $1.token_file, $1.token_line, NULL);
}
| '{' '}'
{
	$$ = ASTMake1(AST_COMPOUND_STATEMENT, NULL, $1.token_file, $1.token_line, NULL);
}
;

statement_seq : statement
{
	$$ = ASTListLeaf($1);
}
| statement_seq statement
{
	$$ = ASTList($1, $2);
}
;

// If ambiguity
// We can generate anything here
if_statement : IF '(' condition ')' statement
{
	$$ = ASTMake4(AST_IF_ELSE_STATEMENT, $3, $5, NULL, NULL, $1.token_file, $1.token_line, NULL);
}
;

// Here only if with an else inside
if_else_statement : IF '(' condition ')' if_else_eligible_statements ELSE statement
{
	$$ = ASTMake4(AST_IF_ELSE_STATEMENT, $3, $5, $7, NULL, $1.token_file, $1.token_line, NULL);
}
;

// Here only if without an else inside
if_else_eligible_statements : no_if_statement
{
	$$ = $1;
}
| if_else_statement
{
	$$ = $1;
}
;

selection_statement : SWITCH '(' condition ')' statement
{
	$$ = ASTMake3(AST_SWITCH_STATEMENT, $3, $5, NULL, $1.token_file, $1.token_line, NULL);
}
;

condition : expression
{
	$$ = ASTMake3(AST_CONDITION, NULL, NULL, $1, ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier_seq declarator '=' assignment_expression
{
	$$ = ASTMake3(AST_CONDITION, $1, $2, $4, ASTFileName($1), ASTLine($1), NULL);
}
// GNU Extension
| type_specifier_seq declarator asm_specification attributes '=' assignment_expression
{
	$$ = ASTMake2(AST_GCC_CONDITION, $4,
			ASTMake4(AST_GCC_CONDITION_DECL, $1, $2, $3, $6, ASTFileName($1), ASTLine($1), NULL),
			ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier_seq declarator attributes '=' assignment_expression
{
	$$ = ASTMake2(AST_GCC_CONDITION, $3,
			ASTMake4(AST_GCC_CONDITION_DECL, $1, $2, NULL, $5, ASTFileName($1), ASTLine($1), NULL),
			ASTFileName($1), ASTLine($1), NULL);
}
| type_specifier_seq declarator asm_specification '=' assignment_expression
{
	$$ = ASTMake2(AST_GCC_CONDITION, NULL,
			ASTMake4(AST_GCC_CONDITION_DECL, $1, $2, $3, $5, ASTFileName($1), ASTLine($1), NULL),
			ASTFileName($1), ASTLine($1), NULL);
}
;

iteration_statement : WHILE '(' condition ')' statement
{
	$$ = ASTMake2(AST_WHILE_STATEMENT, $3, $5, $1.token_file, $1.token_line, NULL);
}
| DO statement WHILE '(' expression ')' ';'
{
	$$ = ASTMake2(AST_DO_STATEMENT, $2, $5, $1.token_file, $1.token_line, NULL);
}
| FOR '(' for_init_statement condition_opt ';' expression_opt ')' statement
{
    AST loop_control = ASTMake3(AST_LOOP_CONTROL, $3, $4, $6, $1.token_file, $1.token_line, NULL);
	$$ = ASTMake3(AST_FOR_STATEMENT, loop_control, $8, NULL, $1.token_file, $1.token_line, NULL);
}
;

expression_opt : expression
{
    $$ = $1;
}
| /* empty */
{
    $$ = NULL;
}
;

condition_opt : condition
{
    $$ = $1;
}
| /* empty */
{
    $$ = NULL;
}
;


for_init_statement : expression_statement %merge<ambiguityHandler>
{
	$$ = $1;
}
| non_empty_simple_declaration %merge<ambiguityHandler>
{
	$$ = $1;
}
;

jump_statement : BREAK ';'
{
	$$ = ASTLeaf(AST_BREAK_STATEMENT, $1.token_file, $1.token_line, NULL);
}
| CONTINUE ';'
{
	$$ = ASTLeaf(AST_CONTINUE_STATEMENT, $1.token_file, $1.token_line, NULL);
}
| RETURN ';'
{
	$$ = ASTMake1(AST_RETURN_STATEMENT, NULL, $1.token_file, $1.token_line, NULL);
}
| RETURN expression ';'
{
	$$ = ASTMake1(AST_RETURN_STATEMENT, $2, $1.token_file, $1.token_line, NULL);
}
| GOTO IDENTIFIER ';'
{
	AST identifier = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);
	
	$$ = ASTMake1(AST_GOTO_STATEMENT, identifier, $1.token_file, $1.token_line, NULL);
}
// GNU Extension
| GOTO '*' expression ';'
{
	$$ = ASTMake1(AST_GCC_GOTO_STATEMENT, $3, $1.token_file, $1.token_line, NULL);
}
;

// *********************************************************
// A.4 - Expressions
// *********************************************************

primary_expression : literal
{
	$$ = $1;
}
| '(' expression ')' 
{
	$$ = ASTMake1(AST_PARENTHESIZED_EXPRESSION, $2, $1.token_file, $1.token_line, NULL);
}
| id_expression
{
	$$ = $1;
}
// GNU Extensions
/*
     ( compound-statement )
     __builtin_va_arg ( assignment-expression , type-name )
     __builtin_offsetof ( type-name , offsetof-member-designator )
     __builtin_choose_expr ( assignment-expression ,
			     assignment-expression ,
			     assignment-expression )
     __builtin_types_compatible_p ( type-name , type-name )
*/
| '(' compound_statement ')'
{
	$$ = ASTMake1(AST_GCC_PARENTHESIZED_EXPRESSION, $2, $1.token_file, $1.token_line, NULL);
}
| BUILTIN_VA_ARG '(' assignment_expression ',' type_id ')'
{
	$$ = ASTMake2(AST_GCC_BUILTIN_VA_ARG, $3, $5, $1.token_file, $1.token_line, NULL);
}
| BUILTIN_OFFSETOF '(' type_id ',' offsetof_member_designator ')'
{
    $$ = ASTMake2(AST_GCC_BUILTIN_OFFSETOF, $3, $5, $1.token_file, $1.token_line, NULL);
}
| BUILTIN_CHOOSE_EXPR '(' assignment_expression ',' assignment_expression ',' assignment_expression ')'
{
    $$ = ASTMake3(AST_GCC_BUILTIN_CHOOSE_EXPR, $3, $5, $7, $1.token_file, $1.token_line, NULL);
}
| BUILTIN_TYPES_COMPATIBLE_P '(' type_id ',' type_id ')'
{
    $$ = ASTMake2(AST_GCC_BUILTIN_TYPES_COMPATIBLE_P, $3, $5, $1.token_file, $1.token_line, NULL);
}
;

/* GNU extension */
/*
   offsetof-member-designator:
     identifier
     offsetof-member-designator . identifier
     offsetof-member-designator [ expression ]
*/
offsetof_member_designator :  IDENTIFIER designator_list
{
    $$ = ASTMake2(AST_GCC_OFFSETOF_MEMBER_DESIGNATOR,
            ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text),
            $2, $1.token_file, $1.token_line, NULL);
}
| IDENTIFIER
{
    $$ = ASTMake2(AST_GCC_OFFSETOF_MEMBER_DESIGNATOR,
            ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text),
            NULL, $1.token_file, $1.token_line, NULL);
}
;

id_expression : unqualified_id
{
	$$ = $1;
}
;

unqualified_id : IDENTIFIER
{
	$$ = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);
}
;

postfix_expression : primary_expression
{
	$$ = $1;
}
| postfix_expression '[' expression ']'
{
	$$ = ASTMake2(AST_ARRAY_SUBSCRIPT, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression '(' ')' 
{
	$$ = ASTMake2(AST_FUNCTION_CALL, $1, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression '(' expression_list ')' 
{
	$$ = ASTMake2(AST_FUNCTION_CALL, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression '.' id_expression
{
	$$ = ASTMake2(AST_CLASS_MEMBER_ACCESS, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression PTR_OP id_expression
{
	$$ = ASTMake2(AST_POINTER_CLASS_MEMBER_ACCESS, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression PLUSPLUS
{
	$$ = ASTMake1(AST_POSTINCREMENT, $1, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression MINUSMINUS
{
	$$ = ASTMake1(AST_POSTDECREMENT, $1, ASTFileName($1), ASTLine($1), NULL);
}
// GNU Extensions
| '(' type_id ')' '{' initializer_list '}'
{
	$$ = ASTMake2(AST_GCC_POSTFIX_EXPRESSION, $2, $5, $1.token_file, $1.token_line, NULL);
}
| '(' type_id ')' '{' initializer_list ',' '}'
{
	$$ = ASTMake2(AST_GCC_POSTFIX_EXPRESSION, $2, $5, $1.token_file, $1.token_line, NULL);
}
;

expression_list : assignment_expression 
{
    AST expression_holder = ASTMake1(AST_EXPRESSION, $1, ASTFileName($1), ASTLine($1), NULL);
	$$ = ASTListLeaf(expression_holder);
}
| expression_list ',' assignment_expression
{
    AST expression_holder = ASTMake1(AST_EXPRESSION, $3, ASTFileName($3), ASTLine($3), NULL);
	$$ = ASTList($1, expression_holder);
}
;

unary_expression : postfix_expression
{
	$$ = $1;
}
| PLUSPLUS unary_expression
{
	$$ = ASTMake1(AST_PREINCREMENT, $2, $1.token_file, $1.token_line, NULL);
}
| MINUSMINUS unary_expression
{
	$$ = ASTMake1(AST_PREDECREMENT, $2, $1.token_file, $1.token_line, NULL);
}
| unary_operator cast_expression
{
	$$ = ASTMake1($1, $2, ASTFileName($2), ASTLine($2), NULL);
}
| SIZEOF unary_expression %merge<ambiguityHandler>
{
	$$ = ASTMake1(AST_SIZEOF, $2, $1.token_file, $1.token_line, NULL);
}
| SIZEOF '(' type_id ')' %merge<ambiguityHandler>
{
	$$ = ASTMake1(AST_SIZEOF_TYPEID, $3, $1.token_file, $1.token_line, NULL);
}
// GNU Extensions
| EXTENSION cast_expression
{
	$$ = ASTMake1(AST_GCC_EXTENSION_EXPR, $2, $1.token_file, $1.token_line, $1.token_text);
}
| ALIGNOF unary_expression %merge<ambiguityHandler>
{
	$$ = ASTMake1(AST_GCC_ALIGNOF, $2, $1.token_file, $1.token_line, $1.token_text);
}
| ALIGNOF '(' type_id ')' %merge<ambiguityHandler>
{
	$$ = ASTMake1(AST_GCC_ALIGNOF_TYPE, $3, $1.token_file, $1.token_line, $1.token_text);
}
| REAL cast_expression
{
	$$ = ASTMake1(AST_GCC_REAL_PART, $2, $1.token_file, $1.token_line, NULL);
}
| IMAG cast_expression
{
	$$ = ASTMake1(AST_GCC_IMAG_PART, $2, $1.token_file, $1.token_line, NULL);
}
| ANDAND IDENTIFIER
{
	AST identifier = ASTLeaf(AST_SYMBOL, $2.token_file, $2.token_line, $2.token_text);

	$$ = ASTMake1(AST_GCC_LABEL_ADDR, identifier, $1.token_file, $1.token_line, NULL);
}
;

unary_operator : '*'
{
	$$ = AST_DERREFERENCE;
}
| '&' 
{
	$$ = AST_REFERENCE;
}
| '+'
{
	$$ = AST_PLUS;
}
| '-'
{
	$$ = AST_NEG;
}
| '!'
{
	$$ = AST_NOT;
}
| '~'
{
	$$ = AST_COMPLEMENT;
}
;

cast_expression : unary_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| '(' type_id ')' cast_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_CAST_EXPRESSION, $2, $4, $1.token_file, $1.token_line, NULL);
}
;

multiplicative_expression : cast_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| multiplicative_expression '*' cast_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_MULT, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| multiplicative_expression '/' cast_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_DIV, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| multiplicative_expression '%' cast_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_MOD, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

additive_expression : multiplicative_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| additive_expression '+' multiplicative_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_ADD, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| additive_expression '-' multiplicative_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_MINUS, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

shift_expression : additive_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| shift_expression LEFT additive_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_SHL, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| shift_expression RIGHT additive_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_SHR, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

relational_expression : shift_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| relational_expression '<' shift_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_LOWER_THAN, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| relational_expression '>' shift_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_GREATER_THAN, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| relational_expression GREATER_OR_EQUAL shift_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_GREATER_OR_EQUAL_THAN, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| relational_expression LESS_OR_EQUAL shift_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_LOWER_OR_EQUAL_THAN, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

equality_expression : relational_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| equality_expression EQUAL relational_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_EQUAL, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
| equality_expression NOT_EQUAL relational_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_DIFFERENT, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

and_expression : equality_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| and_expression '&' equality_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_BITWISE_AND, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

exclusive_or_expression : and_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| exclusive_or_expression '^' and_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_BITWISE_XOR, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

inclusive_or_expression : exclusive_or_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| inclusive_or_expression '|' exclusive_or_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_BITWISE_OR, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

logical_and_expression : inclusive_or_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| logical_and_expression ANDAND inclusive_or_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_LOGICAL_AND, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

logical_or_expression : logical_and_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| logical_or_expression OROR logical_and_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_LOGICAL_OR, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

conditional_expression : logical_or_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| logical_or_expression '?' expression ':' assignment_expression %merge<ambiguityHandler>
{
	$$ = ASTMake3(AST_CONDITIONAL_EXPRESSION, $1, $3, $5, ASTFileName($1), ASTLine($1), NULL);
}
// GNU Extension
| logical_or_expression '?' ':' assignment_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_GCC_CONDITIONAL_EXPRESSION, $1, $4, ASTFileName($1), ASTLine($1), NULL);
}
;

assignment_expression : conditional_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| logical_or_expression assignment_operator assignment_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2($2, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}
;

expression : assignment_expression %merge<ambiguityHandler>
{
	$$ = ASTMake1(AST_EXPRESSION, $1, ASTFileName($1), ASTLine($1), NULL);
}
| expression ',' assignment_expression %merge<ambiguityHandler>
{
	AST comma_expression = ASTMake2(AST_COMMA, $1, $3, ASTFileName($1), ASTLine($1), NULL);

	$$ = ASTMake1(AST_EXPRESSION, comma_expression, ASTFileName(comma_expression), ASTLine(comma_expression), NULL);
}
;

assignment_operator : '='
{
	$$ = AST_ASSIGNMENT;
}
| MUL_ASSIGN
{
	$$ = AST_MUL_ASSIGNMENT;
}
| DIV_ASSIGN
{
	$$ = AST_DIV_ASSIGNMENT;
}
| ADD_ASSIGN
{
	$$ = AST_ADD_ASSIGNMENT;
}
| SUB_ASSIGN
{
	$$ = AST_SUB_ASSIGNMENT;
}
| LEFT_ASSIGN
{
	$$ = AST_SHL_ASSIGNMENT;
}
| RIGHT_ASSIGN
{
	$$ = AST_SHR_ASSIGNMENT;
}
| AND_ASSIGN
{
	$$ = AST_AND_ASSIGNMENT;
}
| OR_ASSIGN
{
	$$ = AST_OR_ASSIGNMENT;
}
| XOR_ASSIGN
{
	$$ = AST_XOR_ASSIGNMENT;
}
| MOD_ASSIGN
{
	$$ = AST_MOD_ASSIGNMENT;
}
;

constant_expression : conditional_expression
{
	$$ = ASTMake1(AST_CONSTANT_EXPRESSION, $1, ASTFileName($1), ASTLine($1), NULL);
}
;

// *********************************************************
// A.2 - Lexical conventions
// *********************************************************

literal : DECIMAL_LITERAL
{
	$$ = ASTLeaf(AST_DECIMAL_LITERAL, $1.token_file, $1.token_line, $1.token_text);
}
| OCTAL_LITERAL
{
	$$ = ASTLeaf(AST_OCTAL_LITERAL, $1.token_file, $1.token_line, $1.token_text);
}
| HEXADECIMAL_LITERAL
{
	$$ = ASTLeaf(AST_HEXADECIMAL_LITERAL, $1.token_file, $1.token_line, $1.token_text);
}
| HEXADECIMAL_FLOAT
{
    $$ = ASTLeaf(AST_HEXADECIMAL_FLOAT, $1.token_file, $1.token_line, $1.token_text);
}
| FLOATING_LITERAL
{
	$$ = ASTLeaf(AST_FLOATING_LITERAL, $1.token_file, $1.token_line, $1.token_text);
}
| BOOLEAN_LITERAL
{
	$$ = ASTLeaf(AST_BOOLEAN_LITERAL, $1.token_file, $1.token_line, $1.token_text);
}
| CHARACTER_LITERAL
{
	$$ = ASTLeaf(AST_CHARACTER_LITERAL, $1.token_file, $1.token_line, $1.token_text);
}
| string_literal
{
	$$ = $1;
}
;

unknown_pragma : UNKNOWN_PRAGMA
{
	$$ = ASTLeaf(AST_UNKNOWN_PRAGMA, $1.token_file, $1.token_line, $1.token_text);
}

// This eases parsing, though it should be viewed as a lexical issue
string_literal : STRING_LITERAL
{
	$$ = ASTLeaf(AST_STRING_LITERAL, $1.token_file, $1.token_line, $1.token_text);
}
| string_literal STRING_LITERAL
{
	// Let's concatenate here, it will ease everything

	const char* str1 = ASTText($1);
	const char* str2 = $2.token_text;
	char* text = calloc(strlen(str1) + strlen(str2) + 1, sizeof(*text));

	strcat(text, str1);

	// Append the second string
	strcat(text, str2);

	$$ = ASTLeaf(AST_STRING_LITERAL, ASTFileName($1), ASTLine($1), text);
}
;





















translation_unit : subparsing
{
	*parsed_tree = $1;
}
;

subparsing : SUBPARSE_EXPRESSION expression
{
	$$ = $2;
}
| SUBPARSE_STATEMENT statement_seq
{
	$$ = $2;
}
| SUBPARSE_STATEMENT
{
	$$ = NULL;
}
| SUBPARSE_MEMBER member_specification_seq
{
	$$ = $2;
}
| SUBPARSE_DECLARATION declaration_sequence
{
	$$ = $2;
}
| SUBPARSE_DECLARATION
{
    $$ = NULL;
}
| SUBPARSE_TYPE type_id
{
    $$ = $2;
}
| SUBPARSE_TYPE_LIST subparse_type_list
{
    $$ = $2;
}
| SUBPARSE_EXPRESSION_LIST expression_list
{
    $$ = $2;
}
| SUBPARSE_ID_EXPRESSION id_expression
{
    $$ = $2;
}
;






















subparse_type_list : type_specifier_seq
{
    $$ = ASTListLeaf($1);
}
| subparse_type_list ',' type_specifier_seq
{
    $$ = ASTList($1, $3);
}
;













postfix_expression : postfix_expression '[' expression_opt ':' expression_opt ']'
{
    $$ = ASTMake3(AST_ARRAY_SECTION, $1, $3, $5, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression '[' expression ';' expression ']'
{
    $$ = ASTMake3(AST_ARRAY_SECTION_SIZE, $1, $3, $5, ASTFileName($1), ASTLine($1), NULL);
}

;

noshape_cast_expression : unary_expression %merge<ambiguityHandler>
{
	$$ = $1;
}
| '(' type_id ')' cast_expression %merge<ambiguityHandler>
{
	$$ = ASTMake2(AST_CAST_EXPRESSION, $2, $4, $1.token_file, $1.token_line, NULL);
}
;

cast_expression : shape_seq noshape_cast_expression %merge<ambiguityHandler>
{
    $$ = ASTMake2(AST_SHAPING_EXPRESSION, $1, $2, ASTFileName($1), ASTLine($1), NULL);
}
;

shape_seq : shape_seq shape %dprec 2
{
    $$ = ASTList($1, $2);
}
| shape %dprec 1
{
    $$ = ASTListLeaf($1);
}
;

shape: '[' expression ']'
{
    $$ = $2;
}
;














statement : STATEMENT_PLACEHOLDER
{
    // The lexer ensures this has the following form
    // @STATEMENT-PH::0x1234abcd@, where the pointer coded
    // is an 'AST*'
    AST *tree = decode_placeholder($1.token_text);

    // This is an empty statement
    $$ = *tree = ASTMake1(AST_DECLARATION_STATEMENT,
            ASTLeaf(AST_EMPTY_DECL, $1.token_file, $1.token_line, $1.token_text), 
            $1.token_file, $1.token_line, NULL);
};



// This is code














































































// Grammar entry point

no_if_statement : pragma_custom_construct_statement
{
    $$ = $1;
}
| pragma_custom_directive
{
    $$ = $1;
}
;

declaration : pragma_custom_construct_declaration
{
    $$ = $1;
}
| pragma_custom_directive
{
	$$ = $1;
}
;

member_declaration : pragma_custom_construct_member_declaration
{
    $$ = $1;
}
| pragma_custom_directive
{
    $$ = $1;
}
;


















// Pragma custom

pragma_custom_directive : PRAGMA_CUSTOM pragma_custom_line_directive
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_DIRECTIVE, $2, NULL, $1.token_file, $1.token_line, $1.token_text);
}
;


pragma_custom_construct_declaration : PRAGMA_CUSTOM pragma_custom_line_construct declaration
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_CONSTRUCT, $2, $3, $1.token_file, $1.token_line, $1.token_text);
}
;

pragma_custom_construct_member_declaration : PRAGMA_CUSTOM pragma_custom_line_construct member_declaration
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_CONSTRUCT, $2, $3, $1.token_file, $1.token_line, $1.token_text);
}
;

pragma_custom_construct_statement : PRAGMA_CUSTOM pragma_custom_line_construct statement
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_CONSTRUCT, $2, $3, $1.token_file, $1.token_line, $1.token_text);
}
;
























































pragma_custom_line_directive : PRAGMA_CUSTOM_DIRECTIVE pragma_custom_clause_opt_seq PRAGMA_CUSTOM_NEWLINE
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_LINE, $2, NULL, $1.token_file, $1.token_line, $1.token_text);
}
| PRAGMA_CUSTOM_DIRECTIVE '(' pragma_clause_arg_list ')' pragma_custom_clause_opt_seq PRAGMA_CUSTOM_NEWLINE
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_LINE, $5, $3, $1.token_file, $1.token_line, $1.token_text);
}
| PRAGMA_CUSTOM_NEWLINE
{
    // This is a degenerated case caused by wrong designed pragmas
    $$ = ASTMake2(AST_PRAGMA_CUSTOM_LINE, NULL, NULL, NULL, 0, NULL);
}
;

pragma_custom_line_construct : PRAGMA_CUSTOM_CONSTRUCT pragma_custom_clause_opt_seq PRAGMA_CUSTOM_NEWLINE
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_LINE, $2, NULL, $1.token_file, $1.token_line, $1.token_text);
}
| PRAGMA_CUSTOM_CONSTRUCT '(' pragma_clause_arg_list ')' pragma_custom_clause_opt_seq PRAGMA_CUSTOM_NEWLINE
{
	$$ = ASTMake2(AST_PRAGMA_CUSTOM_LINE, $5, $3, $1.token_file, $1.token_line, $1.token_text);
}
;

pragma_custom_clause_opt_seq : /* empty */
{
	$$ = NULL;
}
| pragma_custom_clause_seq
{
	$$ = $1;
}
;

pragma_custom_clause_seq : pragma_custom_clause
{
	$$ = ASTListLeaf($1);
}
| pragma_custom_clause_seq ',' pragma_custom_clause
{
	$$ = ASTList($1, $3);
}
| pragma_custom_clause_seq pragma_custom_clause
{
	$$ = ASTList($1, $2);
}
;

pragma_custom_clause : PRAGMA_CUSTOM_CLAUSE '(' pragma_clause_arg_list ')'
{
	$$ = ASTMake1(AST_PRAGMA_CUSTOM_CLAUSE, $3, $1.token_file, $1.token_line, $1.token_text);
}
| PRAGMA_CUSTOM_CLAUSE '(' ')'
{
	$$ = ASTMake1(AST_PRAGMA_CUSTOM_CLAUSE, NULL, $1.token_file, $1.token_line, $1.token_text);
}
| PRAGMA_CUSTOM_CLAUSE 
{
	$$ = ASTMake1(AST_PRAGMA_CUSTOM_CLAUSE, NULL, $1.token_file, $1.token_line, $1.token_text);
}
;

pragma_clause_arg_list : pragma_clause_arg
{
    AST node = ASTLeaf(AST_PRAGMA_CLAUSE_ARG, NULL, 0, $1);

    $$ = ASTListLeaf(node);
}
;

pragma_clause_arg : pragma_clause_arg_item
{
    $$ = $1;
}
| pragma_clause_arg pragma_clause_arg_item
{
    $$ = strappend($1, $2);
}
;

pragma_clause_arg_item : pragma_clause_arg_text
{
    $$ = $1;
}
;

pragma_clause_arg_text : PRAGMA_CLAUSE_ARG_TEXT
{
    $$ = $1.token_text;
}
;


// Verbatim construct
verbatim_construct : VERBATIM_PRAGMA VERBATIM_TYPE '(' IDENTIFIER ')' VERBATIM_TEXT
{
    AST ident = ASTLeaf(AST_SYMBOL, $4.token_file, $4.token_line, $4.token_text);

    $$ = ASTMake1(AST_VERBATIM, ident, $1.token_file, $1.token_line, $6.token_text);
}
| VERBATIM_PRAGMA VERBATIM_TEXT
{
    $$ = ASTMake1(AST_VERBATIM, NULL, $1.token_file, $1.token_line, $2.token_text);
}
;

common_block_declaration : verbatim_construct
{
    $$ = $1;
}
;

member_declaration : verbatim_construct
{
    $$ = $1;
}
;













// Grammar entry point
statement : custom_construct_statement
{
    $$ = $1;
}
;

// Custom code construct

custom_construct_statement : custom_construct_header statement
{
    $$ = ASTMake2(AST_CUSTOM_CONSTRUCT_STATEMENT, $1, $2, ASTFileName($1), ASTLine($1), NULL);
};

custom_construct_header : CONSTRUCT IDENTIFIER custom_construct_parameters_seq
{
    $$ = ASTMake1(AST_CUSTOM_CONSTRUCT_HEADER, $3, $1.token_file, $1.token_line, $2.token_text);
}
| CONSTRUCT IDENTIFIER 
{
    $$ = ASTMake1(AST_CUSTOM_CONSTRUCT_HEADER, NULL, $1.token_file, $1.token_line, $2.token_text);
}
;

custom_construct_parameters_seq : custom_construct_parameter
{
    $$ = ASTListLeaf($1);
}
| custom_construct_parameters_seq ',' custom_construct_parameter
{
    $$ = ASTList($1, $3);
}
;

custom_construct_parameter : IDENTIFIER ':' expression
{
    $$ = ASTMake2(AST_CUSTOM_CONSTRUCT_PARAMETER,
            ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text), 
            $3, 
            $1.token_file, $1.token_line, NULL);
}
;




































omp_udr_declare_arg : omp_udr_operator_list ':' omp_udr_type_specifier
{
    $$ = ASTMake3(AST_OMP_UDR_DECLARE_ARG, NULL, $1, $3, ASTFileName($1), ASTLine($1), NULL);
}






;


omp_udr_declare_arg_2 : omp_udr_unqualified_operator ':' omp_udr_type_specifier_2 ':' omp_udr_expression
{
    $$ = ASTMake3(AST_OMP_UDR_DECLARE_ARG_2, $1, $3, $5, ASTFileName($1), ASTLine($1), NULL);
}
;


omp_udr_type_specifier : type_id
{
    $$ = ASTListLeaf($1);
}
;













omp_udr_type_specifier_2 : type_id
{
    $$ = ASTListLeaf($1);
}
| omp_udr_type_specifier_2 ',' type_id
{
    $$ = ASTList($1, $3);
}


omp_udr_unqualified_operator :  IDENTIFIER
{
    $$ = ASTLeaf(AST_SYMBOL, $1.token_file, $1.token_line, $1.token_text);
}
| omp_udr_builtin_op
{
	$$ = $1;
	struct { const char *op; const char *name; } map[] =
    { 
        { "+", "_plus_"},
        { "-", "_minus_"},
        { "*", "_mult_"},
        { "/", "_div_"},
        { "&", "_and_"},
        { "|", "_or_"},
        { "^", "_exp_"},
        { "&&", "_andand_"},
        { "||", "_oror_"},
        { NULL, NULL }
    };

	int i; 
	char found = 0;
	for (i = 0; map[i].op != NULL && !found; i++)
	{
		if ((found = (strcmp(ast_get_text($$), map[i].op) == 0)))
        {
            ast_set_type($$, AST_SYMBOL);
            ast_set_text($$, map[i].name);
		    break;
        }
	}
	if (!found)
    {
		internal_error("Unhandled operator '%s'", ast_get_text($$));
    }
}
;

omp_udr_expression : expression
{
    $$ = $1;
}
;

omp_udr_operator_2 : omp_udr_unqualified_operator
{
    $$ = $1;
}






;















omp_udr_operator_list : omp_udr_operator
{
    $$ = ASTListLeaf($1);
}
| omp_udr_operator_list ',' omp_udr_operator
{
    $$ = ASTList($1, $3);
}
;

omp_udr_operator : id_expression
{
    $$ = $1;
}










;

omp_udr_builtin_op : '+'
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| '-'
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| '*'
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| '/'
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| '&'
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| '|'
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| '^'
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| ANDAND
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
| OROR
{
    $$ = ASTLeaf(AST_OMP_UDR_BUILTIN_OP, $1.token_file, $1.token_line, $1.token_text);
}
;

subparsing : SUBPARSE_OMP_UDR_DECLARE omp_udr_declare_arg
{
    $$ = $2;
}
;

subparsing : SUBPARSE_OMP_UDR_DECLARE_2 omp_udr_declare_arg_2
{
    $$ = $2;
}
;

subparsing : SUBPARSE_OMP_UDR_IDENTITY omp_udr_identity
{
    $$ = $2;
}
;

subparsing : SUBPARSE_OMP_OPERATOR_NAME omp_udr_operator_2
{
    $$ = $2;
}
;

omp_udr_identity : initializer_clause
{
    $$ = $1;
}












;































// Grammar entry point
subparsing : SUBPARSE_SUPERSCALAR_DECLARATOR superscalar_declarator opt_superscalar_region_spec_list
{
	$$ = ASTMake2(AST_SUPERSCALAR_DECLARATOR, $2, $3, ASTFileName($2), ASTLine($2), NULL);
}
| SUBPARSE_SUPERSCALAR_DECLARATOR_LIST superscalar_declarator_list
{
    $$ = $2;
}
| SUBPARSE_SUPERSCALAR_EXPRESSION expression opt_superscalar_region_spec_list
{
	$$ = ASTMake2(AST_SUPERSCALAR_EXPRESSION, $2, $3, ASTFileName($2), ASTLine($2), NULL);
}
;

superscalar_declarator_list : superscalar_declarator opt_superscalar_region_spec_list
{
	AST ss_decl = ASTMake2(AST_SUPERSCALAR_DECLARATOR, $1, $2, ASTFileName($1), ASTLine($1), NULL);
    $$ = ASTListLeaf(ss_decl);
}
| superscalar_declarator_list ',' superscalar_declarator opt_superscalar_region_spec_list
{
	AST ss_decl = ASTMake2(AST_SUPERSCALAR_DECLARATOR, $3, $4, ASTFileName($3), ASTLine($3), NULL);
    $$ = ASTList($1, ss_decl);
}
;

superscalar_declarator : declarator_id
{
	$$ = $1;
}
| superscalar_declarator '[' assignment_expression ']'
{
	$$ = ASTMake4(AST_DECLARATOR_ARRAY, $1, $3, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

opt_superscalar_region_spec_list :
/* NULL */
{
	$$ = NULL;
}
| superscalar_region_spec_list
;

superscalar_region_spec_list : superscalar_region_spec
{
	$$ = ASTListLeaf($1);
}
| superscalar_region_spec_list superscalar_region_spec
{
	$$ = ASTList($1, $2);
}
;

superscalar_region_spec : '{' '}'
{
	$$ = ASTLeaf(AST_SUPERSCALAR_REGION_SPEC_FULL, $1.token_file, $1.token_line, NULL);
}
| '{' expression '}'
{
	$$ = ASTMake1(AST_SUPERSCALAR_REGION_SPEC_SINGLE, $2, $1.token_file, $1.token_line, NULL);
}
| '{' expression TWO_DOTS expression '}'
{
	$$ = ASTMake2(AST_SUPERSCALAR_REGION_SPEC_RANGE, $2, $4, $1.token_file, $1.token_line, NULL);
}
| '{' expression ':' expression '}'
{
	$$ = ASTMake2(AST_SUPERSCALAR_REGION_SPEC_LENGTH, $2, $4, $1.token_file, $1.token_line, NULL);
}
;






























unary_expression : UPC_LOCALSIZEOF unary_expression
{
    $$ = ASTMake1(AST_UPC_LOCALSIZEOF, $2, $1.token_file, $1.token_line, NULL);
}
| UPC_LOCALSIZEOF '(' type_id ')'
{
    $$ = ASTMake1(AST_UPC_LOCALSIZEOF_TYPEID, $3, $1.token_file, $1.token_line, NULL);
}
| UPC_BLOCKSIZEOF unary_expression
{
    $$ = ASTMake1(AST_UPC_BLOCKSIZEOF, $2, $1.token_file, $1.token_line, NULL);
}
| UPC_BLOCKSIZEOF '(' type_id ')'
{
    $$ = ASTMake1(AST_UPC_BLOCKSIZEOF_TYPEID, $3, $1.token_file, $1.token_line, NULL);
}
| UPC_ELEMSIZEOF unary_expression
{
    $$ = ASTMake1(AST_UPC_ELEMSIZEOF, $2, $1.token_file, $1.token_line, NULL);
}
| UPC_ELEMSIZEOF '(' type_id ')'
{
    $$ = ASTMake1(AST_UPC_ELEMSIZEOF_TYPEID, $3, $1.token_file, $1.token_line, NULL);
}
;

cv_qualifier : upc_shared_type_qualifier
{
    $$ = $1;
}
| upc_reference_type_qualifier
{
    $$ = $1;
}
;

upc_shared_type_qualifier : UPC_SHARED
{
    $$ = ASTMake1(AST_UPC_SHARED, NULL, $1.token_file, $1.token_line, NULL);
}
| UPC_SHARED upc_layout_qualifier
{
    $$ = ASTMake1(AST_UPC_SHARED, $2, $1.token_file, $1.token_line, NULL);
}
;

upc_reference_type_qualifier : UPC_RELAXED
{
    $$ = ASTLeaf(AST_UPC_RELAXED, $1.token_file, $1.token_line, NULL);
}
| UPC_STRICT
{
    $$ = ASTLeaf(AST_UPC_STRICT, $1.token_file, $1.token_line, NULL);
}
;

// UPC only allows one of these qualifiers but as an extension we allow a list
upc_layout_qualifier: upc_layout_qualifier_element
{
    $$ = ASTListLeaf($1);
}
| upc_layout_qualifier upc_layout_qualifier_element
{
    $$ = ASTList($1, $2);
}
;

upc_layout_qualifier_element : '[' ']'
{
    $$ = ASTMake1(AST_UPC_LAYOUT_QUALIFIER, NULL, $1.token_file, $1.token_line, NULL);
}
| '[' constant_expression ']'
{
    $$ = ASTMake1(AST_UPC_LAYOUT_QUALIFIER, $2, $1.token_file, $1.token_line, NULL);
}
| '[' '*' ']'
{
    $$ = ASTMake1(AST_UPC_LAYOUT_QUALIFIER, 
            ASTLeaf(AST_UPC_LAYOUT_UNDEF, $2.token_file, $2.token_line, NULL), 
            $1.token_file, $1.token_line, NULL);
}
;

no_if_statement : upc_synchronization_statement
{
    $$ = $1;
}
;

upc_synchronization_statement : UPC_NOTIFY upc_expression_opt ';'
{
    $$ = ASTMake1(AST_UPC_NOTIFY, $2, $1.token_file, $1.token_line, NULL);
}
| UPC_WAIT upc_expression_opt ';'
{
    $$ = ASTMake1(AST_UPC_WAIT, $2, $1.token_file, $1.token_line, NULL);
}
| UPC_BARRIER upc_expression_opt ';'
{
    $$ = ASTMake1(AST_UPC_BARRIER, $2, $1.token_file, $1.token_line, NULL);
}
| UPC_FENCE ';'
{
    $$ = ASTLeaf(AST_UPC_FENCE, $1.token_file, $1.token_line, NULL);
}
;

upc_expression_opt : expression
{
    $$ = $1;
}
|
{
    $$ = NULL;
}
;

iteration_statement : UPC_FORALL '(' for_init_statement upc_expression_opt ';' upc_expression_opt ';' upc_affinity_opt ')' statement
{
    AST upc_forall_header =
        ASTMake4(AST_UPC_FORALL_HEADER, $3, $4, $6, $8, $1.token_file, $1.token_line, NULL);

    $$ = ASTMake2(AST_UPC_FORALL, upc_forall_header, $10, $1.token_file, $1.token_line, NULL);
}
;

upc_affinity_opt : upc_affinity
{
    $$ = $1;
}
| 
{
    $$ = NULL;
};

upc_affinity : expression
{
    $$ = $1;
}
| CONTINUE
{
    $$ = ASTLeaf(AST_UPC_CONTINUE, $1.token_file, $1.token_line, NULL);
}
;






















nontype_specifier_without_attribute : cuda_specifiers
{
    $$ = $1;
}
;

postfix_expression : cuda_kernel_call
{
    $$ = $1;
}
;

cuda_specifiers : CUDA_DEVICE
{
    $$ = ASTLeaf(AST_CUDA_DEVICE, $1.token_file, $1.token_line, $1.token_text);
}
| CUDA_GLOBAL
{
    $$ = ASTLeaf(AST_CUDA_GLOBAL, $1.token_file, $1.token_line, $1.token_text);
}
| CUDA_HOST
{
    $$ = ASTLeaf(AST_CUDA_HOST, $1.token_file, $1.token_line, $1.token_text);
}
| CUDA_CONSTANT
{
    $$ = ASTLeaf(AST_CUDA_CONSTANT, $1.token_file, $1.token_line, $1.token_text);
}
| CUDA_SHARED
{
    $$ = ASTLeaf(AST_CUDA_SHARED, $1.token_file, $1.token_line, $1.token_text);
}
;

cuda_kernel_call : postfix_expression cuda_kernel_arguments '(' ')'
{
    $$ = ASTMake3(AST_CUDA_KERNEL_CALL, $1, $2, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| postfix_expression cuda_kernel_arguments '(' expression_list ')'
{
    $$ = ASTMake3(AST_CUDA_KERNEL_CALL, $1, $2, $4, ASTFileName($1), ASTLine($1), NULL);
}
;

cuda_kernel_arguments : cuda_kernel_config_left cuda_kernel_config_list cuda_kernel_config_right
{
    $$ = $2;
}
;

cuda_kernel_config_list : assignment_expression ',' assignment_expression ',' assignment_expression ',' assignment_expression
{
    $$ = ASTMake4(AST_CUDA_KERNEL_ARGUMENTS, $1, $3, $5, $7, ASTFileName($1), ASTLine($1), NULL);
}
| assignment_expression ',' assignment_expression ',' assignment_expression
{
    $$ = ASTMake4(AST_CUDA_KERNEL_ARGUMENTS, $1, $3, $5, NULL, ASTFileName($1), ASTLine($1), NULL);
}
| assignment_expression ',' assignment_expression
{
    $$ = ASTMake4(AST_CUDA_KERNEL_ARGUMENTS, $1, $3, NULL, NULL, ASTFileName($1), ASTLine($1), NULL);
}
;

cuda_kernel_config_left : CUDA_KERNEL_LEFT
{
    $$ = $1;
}
;


cuda_kernel_config_right : CUDA_KERNEL_RIGHT
{
    $$ = $1;
}
;

















nontype_specifier_without_attribute : XL_BUILTIN_SPEC
{
    $$ = ASTLeaf(AST_XL_BUILTIN_SPEC, $1.token_file, $1.token_line, $1.token_text);
}
;




%%





























// This is code


#define TOK_SEPARATOR "::"
static AST* decode_placeholder(const char *c)
{
    const char * colons = strstr(c, TOK_SEPARATOR);

    if (colons == NULL)
    {
        internal_error("Invalid placeholder token", 0);
    }

    colons += strlen(TOK_SEPARATOR);

    AST *tree = NULL;
    sscanf(colons, "%p", &tree);

    if (tree == NULL)
    {
        internal_error("Invalid AST* reference", 0);
    }

    return tree;
}



#include "cxx-utils.h"

static AST ambiguityHandler (YYSTYPE x0, YYSTYPE x1)
{
	AST son0 = x0.ast;
	AST son1 = x1.ast;

	if (son0 == son1) 
	{
		internal_error("Ambiguity function received two trees that are the same!\n", 0);
	}

    return ast_make_ambiguous(son0, son1);
}



void yyerror(AST* parsed_tree UNUSED_PARAMETER, const char* c)
{
	fprintf(stderr, "%s:%d: error: %s\n", scanning_now.current_filename, scanning_now.line_number, c);
}
