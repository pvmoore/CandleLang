# Syntax

## Statement

### Variable
$
Variable ::= Type \: Identifier [= Expr] 
$

$Type ::= \begin{cases}
TypeName\\
PointerType
\end{cases}
$

$$PointerType ::= TypeName \{*\}^\text{1 to $\infty$}$$

$
TypeName 
\begin{cases}
bool\\
byte\\
short\\
int\\
long\\
float\\
double\\
void\\
UserType
\end{cases}
$
## Expression

