(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Lacia`Autocode`reportSuspiciousSet`"];


Needs["CodeParser`"];

Needs["Lacia`Autocode`"];

Needs["Lacia`Autocode`Constant`"];


(* ::Section:: *)
(*Public*)


reportSuspiciousSet::usage =
    "report suspicious set in the *.wl files in the directory.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Main*)


reportSuspiciousSet[
    dir_?DirectoryQ,
    excludedFileList:{___String}:{},
    excludedSymbolList:{___String}:{}
] :=
    fileListFromDirectory[dir,excludedFileList]//
        Query[All,<|"SuspiciousSet"->getSuspiciousSetFromSingleFile[#File,excludedSymbolList],"FileName"->#FileName|>&]//
        	Dataset[#,MaxItems->{All,All,All},HiddenItems->{"RHS"}]&;


(* ::Subsection:: *)
(*Helper*)


getSuspiciousSetFromSingleFile[file_File,excludedSymbolList_List] :=
    file//CodeParse//Cases[#,_ContextNode,Infinity]&//screenVerbatimPattern//
    	getSuspiciousSetFromAST[excludedSymbolList]//postFormat;


screenVerbatimPattern[ast_] :=
    ast//ReplaceAll[patternOfVerbatimPattern];


getSuspiciousSetFromAST[excludedSymbolList_List][ast_] :=
    Module[ {astListOfScoping,astListWithoutScoping},
        astListWithoutScoping =
            DeleteCases[getChildren@ast,patternOfScoping];
        astListOfScoping =
            Cases[getChildren@ast,patternOfScoping2];
        {
            (*extract suspicious sets from the non-scoping children.*)
            astListWithoutScoping//Query[getSuspiciousSetKernel[excludedSymbolList]],
            (*prepare a new node from the children of the non-scoping children to continue the recursion.*)
            astListWithoutScoping//prepareNodeFromChildren//getSuspiciousSetFromAST[excludedSymbolList],
            (*deal with the scoping children.*)
            astListOfScoping//Query[All,getSuspiciousSetFromAST[Union[excludedSymbolList,#LocalSymbolList]][#Body]&]
        }
    ];

getSuspiciousSetFromAST[excludedSymbolList_List][{___LeafNode}] :=
    Nothing;


getChildren[ast:Except[_LeafNode|_List]] :=
    ast[[2]];

(*this is related to prepareNodeFromChildren.*)
getChildren[node_List] :=
    node;

getChildren[_LeafNode] :=
    Nothing;


getSuspiciousSetKernel[excludedSymbolList_List][ast_] :=
    Cases[ast,patternOfSuspiciousSet]//Select[!ContainsAll[excludedSymbolList,handleListSet@#LHS]&];


handleListSet[ast_] :=
    If[ MatchQ[ast,patternOfSymbolList],
        Replace[ast,patternOfSymbolList2],
        (*Else*)
        {ToFullFormString[ast]}
    ];


prepareNodeFromChildren[astList_List] :=
    astList//Map[getChildren]//Flatten;


(* ::Subsubsection:: *)
(*Suspicious set post-format*)


postFormat[sets_List] :=
    sets//Flatten//Query[All,<|
        "LHS"->ToFullFormString[#LHS],
        "RHS"->ToFullFormString[#RHS],
        "Position"->getNodePosition[#LHS]
    |>&];

postFormat[Nothing] :=
    {};


getNodePosition[node_] :=
    Part[node,3,Key[Source],1];


(* ::Subsubsection:: *)
(*File operation*)


fileListFromDirectory[dir_,excludedFileList_List] :=
    FileNames["*.wl",dir]//
    	Query[All,<|"FileName"->FileNameTake[#],"File"->File[#]|>&]//
	    	Query[Select[!MatchQ[#FileName,Alternatives@@excludedFileList]&]];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
