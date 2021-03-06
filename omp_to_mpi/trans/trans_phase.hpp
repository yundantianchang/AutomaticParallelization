#ifndef INLINE_PHASE_HPP
#define INLINE_PHASE_HPP

#include <tl-compilerphase.hpp>
#include <hlt/hlt-inline.hpp>
#include <hlt/hlt-common.hpp>
#include <tl-ast.hpp>
#include <tl-scopelink.hpp>
#include <tl-langconstruct.hpp>
#include <tl-symbol.hpp>
#include "tl-pragmasupport.hpp"
#include <cxx-utils.h>
#include <uniquestr.h>
#include <tl-source.hpp>
#include <tl-datareference.hpp>

#include "tl-omp.hpp"
#include <unordered_map>
#include "hlt/hlt-outline.hpp"

//#include "printTraverse.hpp"
using namespace TL;
using namespace TL::HLT;
using namespace std;


class TransPhase : public PragmaCustomCompilerPhase {
    struct transferInfo {
        string name;
        string start;
        string end;
    };
    struct infoVar {
        Source name;
        Source operation;
        Source type; 
        ObjectList<string> size;
        ObjectList<Source> iterVar;
        int iterVarInOperation;
    };
  
public:
    TransPhase();
    virtual void run(DTO &dto);

    class TraverseASTFunctor4All : public TraverseASTFunctor {
    private:
        ScopeLink _slM;
        
    public:
        TraverseASTFunctor4All(ScopeLink sl) : _slM(sl) {};
        virtual ASTTraversalResult do_(const TL::AST_t &a) const
        {
            //                    cout<<a.prettyprint()<<endl;
            return ast_traversal_result_helper(true, true);
        };
    };
    class TraverseASTFunctor4LocateOMP : public TraverseASTFunctor {
    private:
        ScopeLink _sl;
    public:
        
        TraverseASTFunctor4LocateOMP(ScopeLink sl) : _sl(sl) {};
        virtual ASTTraversalResult do_(const TL::AST_t &a) const
        {
            
            bool retBool = false;
            if (!Expression::predicate(a)) {
                std::istringstream f(a.prettyprint());
                std::string line;    
                int lines=0;
                while (std::getline(f, line)) {
                    lines++;
                }
                if(lines>1){
                    PragmaCustomConstruct test(a,_sl);
                    if(test.is_construct()){
                        retBool = true;
                        return ast_traversal_result_helper(retBool,false);
                    } 
                }
            }
            return ast_traversal_result_helper(false, true);
        };
    };
    string addCommaIfNeeded(string arrayToCheck);
    int get_real_line(AST_t asT, ScopeLink scopeL, AST_t actLineAST, int update, int searching_construct, int initialConstruct);
     AST_t get_last_ast(AST_t ast, ScopeLink scopeL);
    int is_inside_bucle(AST_t ast2check, ScopeLink scopeL, int exprLine, int searching_construct);
    string cleanWhiteSpaces(string toClean);
private:
    string getSimplifiedMathExpression(Expression iterating, string name, int doInverse);
    void finalize();
    
    int iteratedVarCorrespondstoAnyVarIdx(string initVar, ObjectList<Source> iter);
    ObjectList<Source> findPrincipalIterator(string varUse, string name);
    AST_t getForContextofConstruct(AST_t ast2check, ScopeLink scopeL, int exprLine, int searching_construct);

    void pragma_postorder(PragmaCustomConstruct construct);
    bool checkDirective(PragmaCustomConstruct construct, string directiveName);
    int get_size_of_array(string name, string declaration);
    vector<infoVar> fill_vars_info(std::unordered_map <std::string,ObjectList<AST_t>> params, TL::HLT::Outline outlineAux, PragmaCustomConstruct construct, Source initVar, Scope functionScope, Scope globalScope, int iNOUT);
    Source generateMPIVariableMessagesSend(vector<infoVar> _inVars, Source initVar, Scope functionScope, string dest, string offset, int withReduced);
    Source handleMemory(string source);
    Source modifyReductionOperation(infoVar reducedVar, AST_t constructAST, PragmaCustomConstruct construct);
    void putBarrier(int minLine, int staticC, int block_line, PragmaCustomConstruct construct, Symbol function_sym, Statement function_body, AST_t minAST, AST_t startAST);
    int isUploadedVar(string name);
    int isExistingVariable(string name, AST_t ast, ScopeLink sL);
    void divideTask();
    void assignMasterWork(AST_t functionAST, ObjectList<Symbol> functionsWithOMP, string functionName);
    AST_t compute_last_astLoop(AST_t lastA, ScopeLink sL);
    int checkIfIteratedByOutsideIterators(string principalIt, AST_t _construct_loop, ScopeLink scopeL, int io, int exprLine);
    AST_t _translation_unit;
    ScopeLink _scope_link;
    vector<infoVar> _reducedVars;
    vector<infoVar> _ioVars;
    vector<infoVar> _inVars;
    int _initialized;
    int _constructLine;

    int _elseNeeded;
    AST_t _initAST;
    int _maxManagedVarsCoor;
    int _lastMaxManagedVarsCoor;
    int _num_transformed_blocks;
    int _num_non_trasformed_blocks;
    int _finalized;
    int _isForDirective;
    int _reducedVarsIndexStart;
    int _construct_num_loop;
    int _construct_inside_bucle;
    int _secureWrite;
    int _workWithCopiesOnSlave;

    int _divideWork;
    string _statVar;
    string _sizeVar;
    string _myidVar;
    string _timeStartVar;
    string _timeFinishVar;
    string _argcVar;
    string _argvVar;
    string _partSizeVar;
    string _offsetVar;
    string _sourceVar;
    string _followINVar;
    string _killedVar;
    string _toVar;
    string _fromVar;
    string _coordVectorVar;
    Source _aditionalLinesRead;
    Source _aditionalLinesWrite;
    int _outsideAditionalReads;
    int _outsideAditionalWrites;
    vector<transferInfo> _uploadedVars;
    vector<transferInfo> _downloadVars;
    AST_t _construct_loop;
    ObjectList<string> _privateVars;
    string _lastFunctionName;
    
    struct lastAst {
        AST_t _wherePutFinal;
        AST_t _lastModifiedAST;
        AST_t _lastModifiedASTstart;
        string _lastFunctionNameList;
        int _inside_bucle;
        int _num_loop;
        
    };
    string _RTAG;
    string _ATAG;
    string _FTAG;
    string _WTAG;
    string _SWTAG;
    string _FRTAG;
    string _FWTAG;    
    vector<lastAst> _lastTransformInfo;
    //*******************
    struct use{
        int row;
        AST_t ast;
        ScopeLink sl;
        int inside_loop;
        int for_num;
        AST_t for_ast;
        AST_t for_internal_ast_last;
        AST_t for_internal_ast_first;
    };
    struct var_use{       
        use row_last_write_master;
        use row_last_read_master;
        use row_first_write_master;
        use row_first_read_master;
    }; 
    struct for_info {
        AST_t ast;
        int lineS;
        int lineF;
    };
    int _levelFunc;
    ObjectList<Symbol> _prmters;
    ObjectList<ObjectList<Symbol>> _prmtersOutlinedFunc;
    typedef unordered_map <string, var_use> Mymap; 
    unordered_map <string, AST_t> _initializedFunctions;
    unordered_map <string, var_use> _smart_use_table;
    std::unordered_map <std::string,ObjectList<AST_t>> _ioParams;
    std::unordered_map <std::string,ObjectList<AST_t>> _inParams;
    
    //****************************
    DTO _dto;
    std::vector<std::string> p_l_s;
    int _inside_loop,_for_num, _for_min_line, _pragma_lines, _notOutlined;
    AST_t _for_ast, _for_internal_ast_last, _for_internal_ast_first, _file_tree;
    void assignMasterWork(lastAst ast2Work);
    int isDeclarationLine(AST_t ast, ObjectList<Symbol> allSym, ScopeLink sL);
    use fill_use(int line, AST_t actAst);
    void defineVars();
    AST_t get_first_ast(AST_t ast, ScopeLink scopeL);
   
    int isReducedVar(string name);
    int isPrivateVar(string name);
    int isIOVar(string name);
    int isINVar(string name);
    int is_inside_master(AST_t ast2check, ScopeLink scopeL, int exprLine, int searching_construct);
    ObjectList<Source> splitMathExpression(Scope sC,std::string secondO, int includeIterators);
    string rectifyName(string oldName);
    void completeLoopsInAST(AST_t ast, ScopeLink scopeL);
    string replaceAll(std::string str, const std::string& from, const std::string& to);
    AST_t fill_smart_use_table(AST_t asT, ScopeLink scopeL, Scope sC, int outline_num_line, ObjectList<Symbol> prmters , int hmppOrig, int offset, AST_t prevAST);
    string transformConstructAST(PragmaCustomConstruct construct, ScopeLink scopeL, Scope sC, Source initVar);
    int isInForIteratedBy(string principalIt, AST_t ast, AST_t astWhereSearch, ScopeLink scopeL, string variableName, int io, ObjectList<string> iteratorOutside, string op);
    int _hasInit;
    int _num_Loop_uncountedLines;
    int _withMemoryLimitation;
    int _oldMPIStyle;
    int _smartUploadDownload;
    int _fullArrayReads;
    int _fullArrayWrites;
    string _rI;
    string _rF;
    int _outline_line;
    int _num_included_if;
    int _expandFullArrayReadWrite;
    int _sendComputedIndices;
    AST_t _forIter;
    ScopeLink _ifScopeL;
    Scope _ifScope;
    int _insideMaster;
    int _breakPointNumber;
    string concatenateUnsigned(string s);
    void debugPoint(string msg);
    int isParam(string p2check);
    void useOldStyle(int staticC, Source mpiVariantStructurePart1, Source mpiVariantStructurePart2, Source mpiVariantStructurePart3, 
                            string maxS, Source initVar, Scope functionScope, Source initValue, 
                            Source conditionToWork, Source mpiFixStructurePart1, Source mpiFixStructurePart2, Statement function_body,
                            PragmaCustomConstruct construct, Source constructASTS, Source initType);
    class TraverseASTFunctor4LocateUse : public TraverseASTFunctor {
    private:
        ScopeLink _slLU;
        bool _f_defined;
        bool _a_defined;
        
    public:
        
        TraverseASTFunctor4LocateUse(ScopeLink sl) : _slLU(sl) {};
        virtual ASTTraversalResult do_(const TL::AST_t &a) const
        {
            
            bool retBool = false;

//                cout<<"---------------------------------"<<endl;
//                cout<<a.prettyprint()<<endl;
//                cout<<a.prettyprint().find("++")<<endl;
//                cout<<a.prettyprint().length()-3<<endl;
//                cin.get();
            if(a.prettyprint().find("MPI_")>= 0 && a.prettyprint().find("MPI_")<a.prettyprint().length()){
                std::istringstream f(a.prettyprint());
                std::string line;    
                int lines=0;
                while (std::getline(f, line)) {
                    lines++;
                }
                
                if(lines==1){
//                    cout<<a.prettyprint()<<endl;
//                    cin.get();
                    retBool = true;
                    return ast_traversal_result_helper(retBool,false);
                }
                
            }
            if (Expression::predicate(a)) {
                Expression expr(a, _slLU);
//                cout<<"as. "<<a.prettyprint()<<endl;
//                cin.get();
                if(expr.is_assignment()){
                    retBool = true;
                }
                if(expr.is_function_call()){
//                    cout<<expr.prettyprint()<<endl;
                    retBool = true;
//                    cin.get();
                }
                
                if(expr.is_operation_assignment()){
                    retBool = true;
                }
                if(a.prettyprint().find("++")==0 || a.prettyprint().find("++")==a.prettyprint().length()-3
                    || a.prettyprint().find("--")==0 || a.prettyprint().find("--")<a.prettyprint().length()-3) {
                        retBool = true;
                }
                
                return ast_traversal_result_helper(retBool,false);
            } else {
                std::istringstream f(a.prettyprint());
                std::string line;    
                int lines=0;
                while (std::getline(f, line)) {
                    lines++;
                }
                
                if(lines==1){
                    retBool = true;
                    return ast_traversal_result_helper(retBool,false);
                } else {
                    PragmaCustomConstruct test(a,_slLU);
                    if(test.is_construct()){
                        retBool = true;
                        return ast_traversal_result_helper(retBool,false);
                    } 
                }
            }
            return ast_traversal_result_helper(false, true);
        };
    };
    class TraverseASTFunctor4Malloc : public TraverseASTFunctor {
    private:
        ScopeLink _slM;
    public:
        
        TraverseASTFunctor4Malloc(ScopeLink sl) : _slM(sl) {};
        virtual ASTTraversalResult do_(const TL::AST_t &a) const
        {
            
            if (Expression::predicate(a)) {
                Expression expr(a, _slM);
                bool retBool = false;
                bool is_assigment =expr.is_assignment();
                if(is_assigment){
                    retBool = true;
                }
                return ast_traversal_result_helper(retBool,false);
            }
            return ast_traversal_result_helper(false, true);
        };
    };
    
    class TraverseASTFunctor4LocateFor : public TraverseASTFunctor {
    private:
        ScopeLink _slLF;
    public:
        
        TraverseASTFunctor4LocateFor(ScopeLink sl) : _slLF(sl) {};
        virtual ASTTraversalResult do_(const TL::AST_t &a) const
        {
            bool retBool = false;
            //std::cout<<"********************+"<<a.prettyprint()<<std::endl;
            if(ForStatement::predicate(a)) {
                
                retBool =true;
                return ast_traversal_result_helper(retBool,false);
            }
            if(WhileStatement::predicate(a)) {
                retBool =true;
                return ast_traversal_result_helper(retBool,false);
            }
            if(DoWhileStatement::predicate(a)) {
                retBool =true;
                return ast_traversal_result_helper(retBool,false);
            }
            return ast_traversal_result_helper(false, true);
        };
    };
    
    class TraverseASTFunctor4LocateIf : public TraverseASTFunctor {
    private:
        ScopeLink _sl;
    public:
        
        TraverseASTFunctor4LocateIf(ScopeLink sl) : _sl(sl) {};
        virtual ASTTraversalResult do_(const TL::AST_t &a) const
        {
            
            bool retBool = false;

            if (IfStatement::predicate(a)) {
                retBool = true;
                return ast_traversal_result_helper(retBool,false);
                    
            }
            return ast_traversal_result_helper(false, true);
        };
    };
    class TraverseASTFunctor4LocateFunction : public TraverseASTFunctor {
    private:
        ScopeLink _sl;
    public:
        
        TraverseASTFunctor4LocateFunction(ScopeLink sl) : _sl(sl) {};
        virtual ASTTraversalResult do_(const TL::AST_t &a) const
        {
            
            bool retBool = false;
            Expression expr(a, _sl);
            if (expr.is_function_call()) {
                    retBool = true;
                return ast_traversal_result_helper(retBool,false);
                    
            }
            return ast_traversal_result_helper(false, true);
        };
    };
};



#endif // OMP_TO_MPI_PHASE

