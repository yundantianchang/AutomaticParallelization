/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Skeleton interface for Bison GLR parsers in C

   Copyright (C) 2002-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_MCXX_CXX_PARSER_INTERNAL_H_INCLUDED
# define YY_MCXX_CXX_PARSER_INTERNAL_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int mcxxdebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ADD_ASSIGN = 258,
    ANDAND = 259,
    AND_ASSIGN = 260,
    ASM = 261,
    AUTO = 262,
    TOKEN_BOOL = 263,
    BOOLEAN_LITERAL = 264,
    BREAK = 265,
    CASE = 266,
    CATCH = 267,
    TOKEN_CHAR = 268,
    CHARACTER_LITERAL = 269,
    CLASS = 270,
    TOKEN_CONST = 271,
    CONST_CAST = 272,
    CONTINUE = 273,
    DECIMAL_LITERAL = 274,
    DEFAULT = 275,
    TOKEN_DELETE = 276,
    DIV_ASSIGN = 277,
    DO = 278,
    TWO_COLONS = 279,
    TOKEN_DOUBLE = 280,
    DYNAMIC_CAST = 281,
    ELSE = 282,
    ENUM = 283,
    EQUAL = 284,
    DECLTYPE = 285,
    EXPLICIT = 286,
    EXPORT = 287,
    EXTERN = 288,
    TOKEN_FLOAT = 289,
    FLOATING_LITERAL = 290,
    HEXADECIMAL_FLOAT = 291,
    FOR = 292,
    FRIEND = 293,
    GOTO = 294,
    HEXADECIMAL_LITERAL = 295,
    IDENTIFIER = 296,
    IF = 297,
    INLINE = 298,
    TOKEN_INT = 299,
    LEFT = 300,
    LEFT_ASSIGN = 301,
    LESS_OR_EQUAL = 302,
    TOKEN_LONG = 303,
    MINUSMINUS = 304,
    MOD_ASSIGN = 305,
    MUL_ASSIGN = 306,
    MUTABLE = 307,
    NAMESPACE = 308,
    TOKEN_NEW = 309,
    NOT_EQUAL = 310,
    OCTAL_LITERAL = 311,
    OPERATOR = 312,
    OR_ASSIGN = 313,
    OROR = 314,
    PLUSPLUS = 315,
    PRIVATE = 316,
    PROTECTED = 317,
    PTR_OP = 318,
    PTR_OP_MUL = 319,
    PUBLIC = 320,
    REGISTER = 321,
    REINTERPRET_CAST = 322,
    RETURN = 323,
    TOKEN_SHORT = 324,
    TOKEN_SIGNED = 325,
    SIZEOF = 326,
    STATIC = 327,
    STATIC_CAST = 328,
    STRING_LITERAL = 329,
    STRUCT = 330,
    SUB_ASSIGN = 331,
    SWITCH = 332,
    TEMPLATE = 333,
    TOKEN_THIS = 334,
    THROW = 335,
    ELLIPSIS = 336,
    TRY = 337,
    TYPEDEF = 338,
    TYPEID = 339,
    TYPENAME = 340,
    UNION = 341,
    TOKEN_UNSIGNED = 342,
    USING = 343,
    VIRTUAL = 344,
    TOKEN_VOID = 345,
    TOKEN_VOLATILE = 346,
    TOKEN_WCHAR_T = 347,
    WHILE = 348,
    XOR_ASSIGN = 349,
    STATIC_ASSERT = 350,
    UNKNOWN_PRAGMA = 351,
    PP_COMMENT = 352,
    PP_TOKEN = 353,
    GXX_HAS_NOTHROW_ASSIGN = 354,
    GXX_HAS_NOTHROW_CONSTRUCTOR = 355,
    GXX_HAS_NOTHROW_COPY = 356,
    GXX_HAS_TRIVIAL_ASSIGN = 357,
    GXX_HAS_TRIVIAL_CONSTRUCTOR = 358,
    GXX_HAS_TRIVIAL_COPY = 359,
    GXX_HAS_TRIVIAL_DESTRUCTOR = 360,
    GXX_HAS_VIRTUAL_DESTRUCTOR = 361,
    GXX_IS_ABSTRACT = 362,
    GXX_IS_BASE_OF = 363,
    GXX_IS_CLASS = 364,
    GXX_IS_CONVERTIBLE_TO = 365,
    GXX_IS_EMPTY = 366,
    GXX_IS_ENUM = 367,
    GXX_IS_LITERAL_TYPE = 368,
    GXX_IS_POD = 369,
    GXX_IS_POLYMORPHIC = 370,
    GXX_IS_STANDARD_LAYOUT = 371,
    GXX_IS_TRIVIAL = 372,
    GXX_IS_UNION = 373,
    AB1 = 374,
    AB2 = 375,
    BUILTIN_VA_ARG = 376,
    BUILTIN_OFFSETOF = 377,
    ALIGNOF = 378,
    EXTENSION = 379,
    REAL = 380,
    IMAG = 381,
    LABEL = 382,
    COMPLEX = 383,
    TYPEOF = 384,
    RESTRICT = 385,
    ATTRIBUTE = 386,
    THREAD = 387,
    SUBPARSE_EXPRESSION = 388,
    SUBPARSE_EXPRESSION_LIST = 389,
    SUBPARSE_STATEMENT = 390,
    SUBPARSE_DECLARATION = 391,
    SUBPARSE_MEMBER = 392,
    SUBPARSE_TYPE = 393,
    SUBPARSE_TYPE_LIST = 394,
    SUBPARSE_ID_EXPRESSION = 395,
    STATEMENT_PLACEHOLDER = 396,
    VERBATIM_PRAGMA = 397,
    VERBATIM_CONSTRUCT = 398,
    VERBATIM_TYPE = 399,
    VERBATIM_TEXT = 400,
    PRAGMA_CUSTOM = 401,
    PRAGMA_CUSTOM_NEWLINE = 402,
    PRAGMA_CUSTOM_DIRECTIVE = 403,
    PRAGMA_CUSTOM_CONSTRUCT = 404,
    PRAGMA_CUSTOM_CONSTRUCT_NOEND = 405,
    PRAGMA_CUSTOM_END_CONSTRUCT = 406,
    PRAGMA_CUSTOM_CLAUSE = 407,
    PRAGMA_CLAUSE_ARG_TEXT = 408,
    CONSTRUCT = 409,
    SUBPARSE_OMP_UDR_DECLARE = 410,
    SUBPARSE_OMP_UDR_DECLARE_2 = 411,
    SUBPARSE_OMP_UDR_IDENTITY = 412,
    OMP_UDR_CONSTRUCTOR = 413,
    SUBPARSE_OMP_OPERATOR_NAME = 414,
    TWO_DOTS = 415,
    SUBPARSE_SUPERSCALAR_DECLARATOR = 416,
    SUBPARSE_SUPERSCALAR_DECLARATOR_LIST = 417,
    SUBPARSE_SUPERSCALAR_EXPRESSION = 418,
    CUDA_DEVICE = 419,
    CUDA_GLOBAL = 420,
    CUDA_HOST = 421,
    CUDA_CONSTANT = 422,
    CUDA_SHARED = 423,
    CUDA_KERNEL_LEFT = 424,
    CUDA_KERNEL_RIGHT = 425,
    XL_BUILTIN_SPEC = 426
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 51 "cxx03.y" /* glr.c:2555  */

	token_atrib_t token_atrib;
	AST ast;
	AST ast2[2];
	AST ast3[3];
	AST ast4[4];
	node_t node_type;
    const char *text;

#line 236 "cxx-parser-internal.h" /* glr.c:2555  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE mcxxlval;

int mcxxparse (AST* parsed_tree);

#endif /* !YY_MCXX_CXX_PARSER_INTERNAL_H_INCLUDED  */
