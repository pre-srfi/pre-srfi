;; Scrape pre-SRFIs from a file listing of
;; https://github.com/johnwcowan/r7rs-work

(import (scheme base) (scheme write) (srfi 1) (srfi 13))

(cond-expand
  (gauche (import (only (gauche base) sys-basename))
          (import (only (file util) path-sans-extension))))

(define (filename-stem filename)
  (path-sans-extension (sys-basename filename)))

(define (displayln x) (display x) (newline))

(define (read-all-lines)
  (let loop ((lines '()))
    (let ((line (read-line)))
      (if (eof-object? line) (reverse lines) (loop (cons line lines))))))

;;

(define base-url "https://github.com/johnwcowan/r7rs-work/blob/master/")

(define people
  '(
    ("Breuel")
    ("Cowan")
    ("Curtis")
    ("Durusau" "PatrickDurusau")
    ("Ganz" "SteveGanz" "StevenGanz")
    ("Gleckler" "ArthurGleckler")
    ("Gloria")
    ("Harvey" "BrianHarvey")
    ("Hemann")
    ("Lucier" "BradleyLucier")
    ("Medernach" "EmmanuelMedernach")
    ("Radul" "AlexeyRadul")
    ("Read" "JeffreyRead")
    ("Rush" "DavidRush")
    ("Russell" "BenjaminRussell")
    ("Shinn" "AlexShinn")
    ("Shivers" "OlinShivers")
    ("SnellPym" "AlaricSnellPym")
    ("Sussman" "GeraldSussman")
    ("Wise")
    ("Wortman")
    ;;
    ("Arcfide" "AaronHsu")
    ("Riastradh")
    ;;
    ("Alexandria")
    ("Gauche")
    ("MIT")
    ("MitTeam")
    ))

(define person-last-name car)
(define person-full-names cdr)

(define ideas
  '(
    "BottomScheme"
    "CharsetDefinitions"
    "CL-R"
    "DivisionUseCases"
    "ExpressionLanguage"
    "FatArch"
    "ImplementationsMay"
    "ImplementationsShould"
    ))

(define surveys
  '(
    "ApplyArgsLimit"
    "ArgumentOrder"
    "BackslashBar"
    "BracketsBraces"
    "CallCc"
    "CaseInsensitivity"
    "CaseSensitivity"
    "CaseSensitivityArcfide"
    "CharEq"
    "ChezReplSemantics"
    "CommaCommands"
    "CommaInIdentifiers"
    "CompilerAvailable"
    "ComplexLog"
    "ComplexRepresentations"
    "CondExpand"
    "CondExpandShinn"
    "CwifClosePort"
    "DatumLabels"
    "DefineSyntaxDefines"
    "DisjointPromises"
    "DotComma"
    "EmbeddedCrLf"
    "EmptyDefine"
    "EmptyList"
    "EmptyStringsVectors"
    "EvalDefine"
    "ExactExpt"
    "ExactSqrt"
    "ExceptionTaxonomies"
    "FiveToSixToSeven"
    "FixnumInfo"
    "FloatPrecision"
    "ForceNonPromise"
    "GetFromClosedStringPort"
    "GuardBehavior"
    "HashBangEof"
    "HashInIdentifiers"
    "HashQuote"
    "HygienicInclusion"
    "ImmediateStringsCoalesced"
    "ImmutableLiterals"
    "ImmutableStrings"
    "ImplementationContrasts"
    "ImplementationSupport"
    "ImproperLists"
    "KeywordSyntax"
    "LetrecStar"
    "LiSPTopLevels"
    "MaxInfNan"
    "ModuleSyntax"
    "ModuleSystemSurvey"
    "MultipleValues"
    "NegativeRationalize"
    "NegativeSqrt"
    "NilIsFalse"
    "NonFiniteNumbers"
    "NonFiniteSyntax"
    "NumericTower"
    "OneArmedIf"
    "OnePlusEx"
    "Optionality"
    "ParametersAndThreads"
    "PetrofskyCatastrophe"
    "PetrofskyLet"
    "PrefixedStringToNumber"
    "PropertyLists"
    "QuoteDelimiter"
    "R7RSMUSTard"
    "RationalizeDefinition"
    "ReadLine"
    "ReadMutable"
    "Readtables"
    "RedefiningKeywords"
    "RedefiningSyntax"
    "RedundantImports"
    "RoundInf"
    "SchemeOnWindows"
    "SelfQuotingVectors"
    "SetUndefinedVariable"
    "ShortEquality"
    "SixRejection"
    "SquareBrackets"
    "StandaloneExecutables"
    "StringSymbolConversion"
    "StringTitlecase"
    "SyntaxAbuse"
    "SyntaxDefinitions"
    "UnicodeSupport"
    "UnsignedImaginary"
    "UpperCaseEscape"
    "VerticalLineSymbols"
    "WhatLoadReturns"
    "Zero"
    ))

(define (editorial-page? stem)
  (any (lambda (candidate) (string-contains stem candidate))
       '("Docket" "Edition" "Draft" "Summary" "WG1" "WG2"
         "WorkingGroup" "WokringGroup")))

(define (personal-page? stem)
  (any (lambda (person) (member stem (person-full-names person)))
       people))

(define (relevant? stem)
  (not (or (editorial-page? stem)
           (personal-page? stem)
           (member stem surveys)
           (member stem ideas))))

(define (split-author-names stem)
  (let loop ((names '()) (stem stem))
    (let ((name (any (lambda (name) (and (string-suffix? name stem) name))
                     (map person-last-name people))))
      (if (not name)
          (cons stem names)
          (loop (cons name names)
                (substring stem 0 (- (string-length stem)
                                     (string-length name))))))))

(define (stem->table-row stem)
  (let* ((stem+names (split-author-names stem))
         (stem (car stem+names))
         (names (cdr stem+names)))
    (string-append "|"
                   base-url stem (string-join names "") ".md"
                   "[" stem "]"
                   "|"
                   (string-join names ", "))))

(define (markdown? filename) (string-suffix-ci? ".md" filename))

(define (main)
  (for-each displayln
            (map stem->table-row
                 (filter relevant?
                         (map filename-stem
                              (filter markdown?
                                      (read-all-lines)))))))

(main)
