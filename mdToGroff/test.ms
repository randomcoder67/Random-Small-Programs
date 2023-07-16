.nr HM 2c
.ps +18
.B
Header 1
.br

.br
.ps
.ps +15
.B
Header 2
.br

.br
.ps
.ps +12
.B
Header 3
.br

.br
.ps
.ps +9
.B
Header 4
.br

.br
.ps
.ps +0
.B
Header 5
.br

.br
.ps
.ps +3
.B
Header 6
.br

.br
.ps
.TS
tab(;) allbox;
l l l.
Header 1;Header 2;Header 3
Big;Thing;thing2
Small;Dog;mad
Left;Handed;tings
.TE
.CW
.br
#include <stdio.h>

.br
int main() {
    printf("%d, %s\n", 2, "thing");
    return 0
.br
}

.IP \[bu] 2
List 1
.IP \[bu]
List 2


.nr step 2 1
.IP \n[step]. 3
Entry 1
.IP \n+[step].
Entry 2
.IP \n+[step].
Entry 3

.LP
> Quoted text

.LP
Normal text 
.I "italic text"\c
 normal text 
.B "bold text"\c
 normal text
.BI "bold italic text"\c
 normal text 
.CW "monospace text"\c
 normal text
.LP
line 1
.br 
line 2

.LP
New Paragraph

.PDFPIC testPhoto.pdf

