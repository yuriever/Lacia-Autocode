(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Lacia`Autocode`exportPublicSymbolUsage`"];


Needs["CodeParser`"];

Needs["Lacia`Autocode`"];

Needs["Lacia`Autocode`Constant`"];


(* ::Section:: *)
(*Public*)


exportPublicSymbolUsage::usage =
    "export the usages of public symbols in the directory.";

$usageFileName::usage =
    "default name of the usage file.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


$usageFileName = "Usage.wl"


(* ::Subsection:: *)
(*Main*)


exportPublicSymbolUsage[
    dir_?DirectoryQ,
    targetDir_?DirectoryQ,
    HoldPattern[excludedFileList:{___String}:{$usageFileName}],
    excludedSymbolList:{___String}:{}
] :=
    File@Export[
        FileNameJoin@{targetDir,$usageFileName},
        getUsageFromDirectory[dir,excludedFileList,excludedSymbolList],
        "Text"
    ];


(* ::Subsection:: *)
(*Helper*)


getUsageFromDirectory[dir_,excludedFileList_List,excludedSymbolList_List] :=
    fileListFromDirectory[dir,excludedFileList]//
		(*get the list of usages from *.wl files.*)
		Query[All,<|"FileName"->#FileName,"Usage"->getUsageFromSingleFile[#File,excludedSymbolList]|>&]//
			(*mark the usages from different files.*)
			Query[All,"\n\n(*"<>#FileName<>"*)\n\n"<>#Usage&];


getUsageFromSingleFile[file_File,excludedSymbolList_List] :=
    file//CodeParse//getUsageListFromAST[excludedSymbolList]//postFormat;


getUsageListFromAST[excludedSymbolList_List][ast_] :=
    ast//DeleteCases[#,_ContextNode,Infinity]&//
	    Cases[#,patternOfUsage,Infinity]&//
    		Query[Select[!MemberQ[excludedSymbolList,#Symbol]&]];


postFormat[usageList_List] :=
    usageList//Query[All,StringTemplate["`Symbol`::usage =\n\t`Usage`;"]]//StringRiffle[#,"\n\n"]&;


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
