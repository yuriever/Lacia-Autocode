

(*convertNotebookToWLT-simple.nb*)

VerificationTest[
	Begin["Global`"];
	ClearAll["`*"]
	,
	Null
	,
	TestID->"0-convertNotebookToWLT-simple.nb"
]

VerificationTest[
	Get["Lacia`Base`"]
	,
	Null
	,
	TestID->"1-convertNotebookToWLT-simple.nb"
]

VerificationTest[
	deleteEmptyList[{{{{}}}}]
	,
	Sequence[]
	,
	TestID->"2-convertNotebookToWLT-simple.nb"
]

VerificationTest[
	ClearAll["`*"];
	End[]
	,
	"Global`"
	,
	TestID->"∞-convertNotebookToWLT-simple.nb"
]