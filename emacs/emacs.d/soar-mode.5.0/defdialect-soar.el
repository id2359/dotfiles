;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : defdialect-soar.el
;;;; Author          : Frank Ritter
;;;; Created On      : Wed Mar 27 22:12:00 1991
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Mon Nov 16 12:46:20 1992
;;;; Update Count    : 167
;;;; 
;;;; PURPOSE
;;;; 	Define soar dialect in ilisp.
;;;; TABLE OF CONTENTS
;;;; 	i.	Global variables
;;;;	ii.	inferior-soar-documentation
;;;;	iii.	Keymaps and syntax table functions
;;;;
;;;;	I.	defdialect soar 
;;;; 	II.	SOAR-MODE, INFERIOR-SOAR-MODE
;;;; 
;;;; (C) Copyright 1990, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'defdialect-soar)

;;;
;;; 	i.	Global variables
;;;----------------------------------------------------------------------------

(defvar soar-mode-map (full-copy-sparse-keymap lisp-mode-map)
  "Major mode map used when editing Soar source.")

(defvar isoar-mode-map (full-copy-sparse-keymap ilisp-mode-map)
  "Major mode map used when running Soar.")

(defvar soar-mode-syntax-table nil
  "Syntax table in Soar mode buffers.")

(defvar soar-symbol-syntax-table nil
  "Syntax table for searching for Soar symbols.")

(defvar soar-beep-after-setup-p t
  "Soar will beep when initialized if t.")

(if (not (memq 'soar-mode lisp-source-modes))
    (setq lisp-source-modes (cons 'soar-mode lisp-source-modes)))


;;;
;;;	ii.	inferior-soar-documentation
;;;

(defvar inferior-soar-documentation

"Major mode for interacting with an inferior Soar process.  Runs a
Soar interpreter as a subprocess of Emacs, with Lisp I/O through an
Emacs buffer.  (This mode is based on ILISP, which makes it an excellect
lisp editor package also.)

Most of these key bindings work in both Soar and ILISP mode.
There are a few additional and-go bindings and help found in Soar Mode.
\\{isoar-mode-map}

If the Franz online Common LISP manual is available, fi:clman
\(\\[fi:clman]) will get information on a specific symbol.
fi:clman-apropos \(\\[fi:clman-apropos]) will get information apropos
a specific string.  Some of the documentation is specific to the
Allegro dialect, but most of it is for standard Common LISP.

Each Soar/ILISP buffer has a command history associated with it.
Commands that do not match ilisp-filter-regexp and that are longer
than ilisp-filter-length and that do not match the immediately prior
command will be added to this history.  comint-previous-input
\(\\[comint-previous-input]) and comint-next-input
\(\\[comint-next-input]) cycle through the input history.
comint-previous-similar-input \(\\[comint-previous-similar-input])
cycles through input that has the string typed so far as a prefix.

An alternative to popper windows is to always have the inferior LISP
buffer visible and have all output go there.  Setting lisp-no-popper
to T will cause all output to go to the inferioir LISP buffer.
Setting comint-always-scroll to T will cause process output to always
be visible.  If a command gets an error, you will be left in the break
loop.

When you send something to Soar, the status light will reflect the
progress of the command. In a lisp mode buffer the light will reflect
the status of the currently selected inferior Soar unless
lisp-show-status is nil.  If you want to find out what command is
currently running, use the command status-lisp \(\\[status-lisp]).  If
you call it with a prefix, the pending commands will be displayed as well.

If you are want to abort the last command you can use
\(\\[keyboard-quit]).  If you want to abort all commands, you should
use the command abort-commands-lisp \(\\[abort-commands-lisp]).
Commands that are aborted will be put in the buffer *Aborted Commands*
so that you can see what was aborted.  If you want to abort the
currently running top-level command, use interrupt-subjob-ilisp
\(\\[interrupt-subjob-ilisp]).

bol-ilisp \(\\[bol-ilisp]) will go after the prompt as defined by
comint-prompt-regexp or ilisp-other-prompt.  

\\[return-ilisp] knows about prompts and sexps.  If an sexp is not
complete, it will indent properly.  When an entire sexp is complete,
it is sent to the inferior LISP together with a new line.  If you edit
old input, the input will be copied to the end of the buffer first.

\\[close-and-send-lisp] will close the current sexp, indent it, then
send it to the current inferior LISP.

\\[indent-line-ilisp] indents for LISP.  With prefix, shifts rest of
expression rigidly with the current line.

\\[newline-and-indent-lisp] will insert a new line and then indent to
the appropriate level.  If you are at the end of the inferior LISP
buffer and an sexp, the sexp will be sent to the inferior LISP without
a trailing newline.  

\\[indent-sexp-ilisp] will indent each line in the next sexp.

\\[backward-delete-char-untabify] converts tabs to spaces as it moves
back.

\\[delete-char-or-pop-ilisp] will delete prefix characters unless you
are at the end of an ILISP buffer in which case it will pop one level
in the break loop.

reset-ilisp, \(\\[reset-ilisp]) will reset the current inferior LISP's
top-level so that it will no longer be in a break loop.

switch-to-lisp \(\\[switch-to-lisp]) will pop to the current ILISP
buffer or if already in an ILISP buffer, it will return to the buffer
that last switched to an ILISP buffer.  With a prefix, it will also go
to the end of the buffer.  If you do not want it to pop, set
pop-up-windows to nil.  

reposition-window-lisp \(\\[reposition-window-lisp]) will put the
start of the current defun or Soar production at the top of the
current window.

lisp-previous-buffer \(\\[lisp-previous-buffer]) will switch to the
last visited buffer in the current window.

find-unbalanced-lisp \(\\[find-unbalanced-lisp]) will find unbalanced
parentheses in the current buffer.  When called with a prefix it will
look in the current region.

close-all-lisp \(\\[close-all-lisp]) will close all outstanding
parentheses back to the containing form, or a previous left bracket
which will be converted to a left parentheses.  If there are too many
parentheses, they will be deleted unless there is text between the
last parenthese and the end of the defun.  If called with a prefix,
all open left brackets will be closed.

reindent-lisp \(\\[reindent-lisp]) will reindent the current paragraph
if in a comment or string.  Otherwise it will close the containing
defun and reindent it.

comment-region-lisp \(\\[comment-region-lisp]) will put prefix copies of
comment-start before and comment-end's after the lines in region.  To
uncomment a region, use a minus prefix.

arglist-lisp \(\\[arglist-lisp]) will return the arglist of the
current function.  With a numeric prefix, the leading paren will be
removed and the arglist will be inserted into the buffer.

documentation-lisp \(\\[documentation-lisp]) infers whether function
or variable documentation is desired.  With a negative prefix, you can
specify the type of documentation as well.  With a positive prefix the
documentation of the current function call is returned.

macroexpand-lisp \(\\[macroexpand-lisp]) and macroexpand-1-lisp
\(\\[macroexpand-1-lisp]) will be applied to the next sexp.  They will
insert their result into the buffer if called with a numeric prefix.

complete-lisp \(\\[complete-lisp]) will try to complete the previous
symbol in the current inferior LISP.  Partial completion is supported
unless ilisp-prefix-match is set to T.  (If you set it to T, inferior
LISP completions will be faster.)  With partial completion, \"p--n\"
would complete to \"position-if-not\" in Common LISP.  If the symbol
follows a left paren or a #', only symbols with function cells will be
considered.  If the symbol starts with a \* all possible completions
will be considered.  To force all symbols to be considered, call it
with a prefix.  Only external symbols are considered if there is a
package qualification with only one colon.  The first time you try to
complete a string the longest common substring will be inserted.  If
you try to complete again, you can see the possible completions.  If
you are in a string, then filename completion will be done instead.
And if you try to complete a filename twice, you will see a list of
possible completions.

trace-lisp \(\\[trace-lisp]) traces the previous function symol.  When
called with a numeric prefix the function will be untraced.

default-directory-lisp \(\\[default-directory-lisp]\) sets the default
inferior LISP directory to the directory of the current buffer.  If
called in an inferior LISP buffer, it sets the Emacs default-directory
the LISP default directory.

The eval/compile commands evaluate or compile the forms specified.  If
any of the forms contain an interactive command, then the command will
never return.  To get out of this state, you need to use
abort-commands-lisp \(\\[abort-commands-lisp]).  The eval/compile
commands verify that their expressions are balanced and then send the
form to the inferior LISP.  If called with a positive prefix, the
result of the operation will be inserted into the buffer after the
form that was just sent.  If lisp-wait-p is t, then EMACS will display
the result of the command in the minibuffer or a pop-up window.  If
lisp-wait-p is nil, (the default) the send is done asynchronously and
the results will be brought up only if there is more than one line or
there is an error.  In this case, you will be given the option of
ignoring the error, keeping it in another buffer or keeping it and
aborting all pending sends.  If there is not a command already running
in the inferior LISP, you can preserve the break loop.  If called with
a negative prefix, the sense of lisp-wait-p will be inverted for the
next command.  The and-go versions will perform the operation and then
immediately switch to the ILISP buffer where you will see the results
of executing your form.  If eval-defun-and-go-lisp
\(\\[eval-defun-and-go-lisp]) or compile-defun-and-go-lisp
\(\\[compile-defun-and-go-lisp]) is called with a prefix, a call for
the form will be inserted as well.

When an eval is done of a single form matching ilisp-defvar-regexp,
the corresponding symbol will be unbound and the value assigned again.

The following commands all deal with finding things in source code.
The first time that one of these commands is used, there may be some
delay while the source module is loaded.  When searching files, the
first applicable rule is used: 1) try the inferior LISP, 2) try a tags
file if defined, 3) try all buffers in one of lisp-modes or all files
defined using lisp-directory.

lisp-directory \(\\[lisp-directory]) defines a set of files to be
searched by the source code commands.  It prompts for a directory and
sets the source files to be those in the directory that match entries
in auto-mode-alist for modes in lisp-source-modes.  With a positive
prefix, the files are appended.  With a negative prefix, all current
buffers that are in one of lisp-source-modes will be searched.  This
is also what happens by default.  Using this command stops using a
tags file.

edit-definitions-lisp \(\\[edit-definitions-lisp]) will find a
particular type of definition for a symbol.  It trys to use the rules
described above.  The files to be searched are listed in the buffer
\*Edit-Definitions*.  If lisp-edit-files is nil, no search will be
done if not found through the inferior LISP.  The variable
ilisp-locator contains a function that when given the name and type
should be able to find the appropriate definition in the file.  There
is often a flag to cause your LISP to record source files that you
will need to set in the initialization file for your LISP.  The
variable is \*record-source-files* in both allegro and lucid.  Once a
definition has been found, next-definition-lisp
\(\\[next-definition-lisp]) will find the next definition.  \(Or the
previous definition with a prefix.)

edit-callers-lisp \(\\[edit-callers-lisp]) will generate a list of all
of the callers of a function in the current inferior LISP and edit the
first caller using edit-definition.  Each successive call to
next-caller-lisp \(\\[next-caller-lisp]) will edit the next caller.
\(Or the previous caller with a prefix.)  The list is stored in the
buffer \*All-Callers*.  You can also look at the callers by doing
who-calls-lisp \(\\[who-calls-lisp]).

search-lisp \(\\[search-lisp]) will search the current tags files,
lisp directory files or buffers in one of lisp-source-modes for a
string or a regular expression when called with a prefix.
\(\\[next-definition-lisp]) will find the next definition.  \(Or the
previous definition with a prefix.)

replace-lisp \(\\[replace-lisp]) will replace a string (or a regexp
with a prefix) in the current tags files, lisp directory files or
buffers in one of lisp-source-modes.

find-file-lisp \(\\[find-file-lisp]) will find a file.  If it is in a
string, that will be used as the default if it matches an existing
file.  Symbolic links are expanded so that different references to the
same file will end up with the same buffer.

****************************************************************
The text below here requires a more than novice understanding to
implement.  You have been warned.  But it explains a lot of features,
so do go ahead and just read it

Customization: Entry to this mode runs the hooks on comint-mode-hook and
ilisp-mode-hook and then DIALECT-hooks specific to LISP
dialects in the nesting order above.  For more information on creating
a new dialect see ilisp.el.

See comint-mode documentation for more information on comint commands.

call-defun-lisp \(\\[call-defun-lisp]) will put a call to the current
defun in the inferior LISP and go there.  If it is a \(def* name form,
it looks up reasonable forms of name in the input history unless
called with a prefix. If not found, \(name or *name* will be inserted.
If it is not a def* form, the whole defun will be put in the buffer.

The very first inferior LISP command executed may send some forms to
initialize the inferior LISP.

Each time an inferior LISP command is executed, the last form sent can be
seen in the \*ilisp-send* buffer.

The first time an inferior LISP mode command is executed in a Lisp
Mode buffer, the package will be determined by using the regular
expression ilisp-package-regexp to find a package sexp and then
passing that sexp to the inferior LISP through ilisp-package-command.
For the clisp dialect, this will find the first \(in-package PACKAGE)
form in the file.  A buffer's package will be displayed in the mode
line.  reparse-attribute-list \(\\[reparse-attribute-list]) will
update the current package from the buffer.  If a buffer has no
specification, forms will be evaluated in the current inferior LISP
package.  package-lisp \(\\[package-lisp]) will show the current
package of the inferioir LISP.  set-package-lisp
\(\\[set-package-lisp]) will set the inferior LISP package to the
current buffer's package or to a manually entered package with a
prefix.

describe-lisp, arglist-lisp, documentation-lisp, macroexpand-1-lisp,
macroexpand-lisp, edit-definitions-lisp, who-calls-lisp,
edit-callers-lisp and trace-lisp will switch whether they prompt for a
response or use a default when called with a negative prefix.  If they
are prompting, there is completion through the inferior LISP by using
TAB or ESC-TAB.  When you are entering an expression in the
minibuffer, all of the normal ilisp commands like arglist-lisp also
work.

Commands that work on a function will use the nearest previous
function symbol.  This is either a symbol after a #' or the symbol at
the start of the current list.

describe-lisp \(\\[describe-lisp]) will describe the previous sexp.
If there is no previous-sexp and you are in an ILISP buffer, the
previous result will be described.


When compile-defun-lisp \(\\[compile-defun-lisp]) is called in an
inferior LISP buffer with no current form, the last form typed to the
top-level will be compiled.


The following commands all deal with making a number of changes all at
once.  The first time one of these commands is used, there may be some
delay as the module is loaded.  The eval/compile versions of these
commands are always executed asynchronously.

mark-change-lisp \(\\[mark-change-lisp]) marks the current defun as
being changed.  A prefix causes it to be unmarked.  clear-changes-lisp
\(\\[clear-changes-lisp]) will clear all of the changes.
list-changes-lisp \(\\[list-changes-lisp]) will show the forms
currently marked. 

eval-changes-lisp \(\\[eval-changes-lisp]), or compile-changes-lisp
\(\\[compile-changes-lisp]) will evaluate or compile these changes as
appropriate.  If called with a positive prefix, the changes will be
kept.  If called with a negative prefix, the commands will be sent to
the inferior LISP without waiting.  If there is an error, the process
will stop and show the error and all remaining changes will remain in
the list.  All of the results will be kept in the buffer
*Last-Changes*.

File commands in lisp-source-mode buffers keep track of the last used
directory and file.  If the point is on a string, that will be the
default.  If the buffer is one of lisp-source-modes, the buffer file
will be the default.  Otherwise, the last file used in a
lisp-source-mode will be used.

soar-load-file \(\\[load-file-lisp]) will load a file into the
inferior Soar.  If the filename  ends in .lisp, it will be loaded with
lisp-syntax set, if it ends in .soar it will be loaded with
Soar-syntax set.  the syntax is left unchanged after loading in either
case.  You will be given the opportunity to save the buffer if it has
changed and to compile the file if the compiled version is older than
the current version.

compile-file-lisp \(\\[compile-file-lisp]) will compile a file in the
current inferior LISP."
  "Documentation string for ILISP mode.")

;; Unused doc string from ilisp:

;ILISP uses a dynamically sized pop-up window that can be buried and
;scrolled from any window for displaying output.  By default the smallest
;window will have just one line.  If you like bigger windows, set
;window-min-height to the number of lines desired plus one.  The
;variable popper-pop-buffers has a list of temporary buffer names that
;will be displayed in the pop-up window.  By default only
;\*Typeout-window* and \*Completions* will be displayed in the pop-up
;window.  If you want all temporary windows to use the pop-up window,
;set popper-pop-buffers to T.  The variable popper-buffers-to-skip has
;a list of the buffer names popper-other-window
;\(\\[popper-other-window]) skips or T to skip all popper buffers.
;popper-bury-output \(\\[popper-bury-output]) burys the output window.
;popper-scroll-output \(\\[popper-scroll-output]) scrolls the output
;window if it is already showing, otherwise it pops it up.  If it is
;called with a negative prefix, it will scroll backwards.
;popper-grow-output \(\\[popper-grow-output]) will grow the output
;window if showing by the prefix number of lines.  Otherwise, it will
;pop the window up.

;If you are running epoch, the popper window will be in a separate
;X window that is not automatically grown or shrunk.  The variable
;popper-screen-properties can be used to set window properties for that
;window. 


(defvar inferior-soar6-documentation

"Major mode for interacting with an inferior Soar process.  Runs a
Soar interpreter as a subprocess of Emacs, with I/O through an Emacs
buffer.  (This mode is based on ILISP, which makes it an excellect
lisp editor package also.)

Most of these key bindings work in both Soar and ISOAR mode.
There are a few additional and-go bindings and help found in Soar Mode.
\\{isoar-mode-map}

Each Soar/ISOAR buffer has a command history associated with it.
Commands that do not match ilisp-filter-regexp and that are longer
than ilisp-filter-length and that do not match the immediately prior
command will be added to this history.  comint-previous-input
\(\\[comint-previous-input]) and comint-next-input
\(\\[comint-next-input]) cycle through the input history.
comint-previous-similar-input \(\\[comint-previous-similar-input])
cycles through input that has the string typed so far as a prefix.

An alternative to popper windows is to always have the inferior Soar
buffer visible and have all output go there.  Setting lisp-no-popper
to T will cause all output to go to the inferioir Soar buffer.
Setting comint-always-scroll to T will cause process output to always
be visible.  If a command gets an error, you will be left in the break
loop.

When you send something to Soar, the status light in the mode line
will reflect the progress of the command.  In a Soar mode buffer the
light will reflect the status of the currently selected inferior Soar
unless lisp-show-status is nil.  If you want to find out what command
is currently running, use the command status-lisp \(\\[status-lisp]).
If you call it with a prefix, the pending commands will be displayed
as well.

If you are want to abort the last command you can use
\(\\[keyboard-quit]).  If you want to abort all commands, you should
use the command abort-commands-lisp \(\\[abort-commands-lisp]).
Commands that are aborted will be put in the buffer *Aborted Commands*
so that you can see what was aborted.  If you want to abort the
currently running top-level command, use interrupt-subjob-ilisp
\(\\[interrupt-subjob-ilisp]).

bol-ilisp \(\\[bol-ilisp]) will go after the prompt as defined by
comint-prompt-regexp or ilisp-other-prompt.  

\\[return-ilisp] knows about prompts and sexps.  If an sexp is not
complete, it will indent properly.  When an entire sexp is complete,
it is sent to the inferior LISP together with a new line.  If you edit
old input, the input will be copied to the end of the buffer first.

\\[close-and-send-lisp] will close the current sexp, indent it, then
send it to the current inferior LISP.

\\[indent-line-ilisp] indents for LISP.  With prefix, shifts rest of
expression rigidly with the current line.

\\[newline-and-indent-lisp] will insert a new line and then indent to
the appropriate level.  If you are at the end of the inferior LISP
buffer and an sexp, the sexp will be sent to the inferior LISP without
a trailing newline.  

\\[indent-sexp-ilisp] will indent each line in the next sexp.

\\[backward-delete-char-untabify] converts tabs to spaces as it moves
back.

\\[delete-char-or-pop-ilisp] will delete prefix characters unless you
are at the end of an ILISP buffer in which case it will pop one level
in the break loop.

reset-ilisp, \(\\[reset-ilisp]) will reset the current inferior LISP's
top-level so that it will no longer be in a break loop.

switch-to-lisp \(\\[switch-to-lisp]) will pop to the current ILISP
buffer or if already in an ILISP buffer, it will return to the buffer
that last switched to an ILISP buffer.  With a prefix, it will also go
to the end of the buffer.  If you do not want it to pop, set
pop-up-windows to nil.  

reposition-window-lisp \(\\[reposition-window-lisp]) will put the
start of the current defun or Soar production at the top of the
current window.

lisp-previous-buffer \(\\[lisp-previous-buffer]) will switch to the
last visited buffer in the current window.

find-unbalanced-lisp \(\\[find-unbalanced-lisp]) will find unbalanced
parentheses in the current buffer.  When called with a prefix it will
look in the current region.

close-all-lisp \(\\[close-all-lisp]) will close all outstanding
parentheses back to the containing form, or a previous left bracket
which will be converted to a left parentheses.  If there are too many
parentheses, they will be deleted unless there is text between the
last parenthese and the end of the defun.  If called with a prefix,
all open left brackets will be closed.

reindent-lisp \(\\[reindent-lisp]) will reindent the current paragraph
if in a comment or string.  Otherwise it will close the containing
defun and reindent it.

comment-region-lisp \(\\[comment-region-lisp]) will put prefix copies of
comment-start before and comment-end's after the lines in region.  To
uncomment a region, use a minus prefix.

arglist-lisp \(\\[arglist-lisp]) will return the arglist of the
current function.  With a numeric prefix, the leading paren will be
removed and the arglist will be inserted into the buffer.

documentation-lisp \(\\[documentation-lisp]) infers whether function
or variable documentation is desired.  With a negative prefix, you can
specify the type of documentation as well.  With a positive prefix the
documentation of the current function call is returned.

macroexpand-lisp \(\\[macroexpand-lisp]) and macroexpand-1-lisp
\(\\[macroexpand-1-lisp]) will be applied to the next sexp.  They will
insert their result into the buffer if called with a numeric prefix.

complete-lisp \(\\[complete-lisp]) will try to complete the previous
symbol in the current inferior LISP.  Partial completion is supported
unless ilisp-prefix-match is set to T.  (If you set it to T, inferior
LISP completions will be faster.)  With partial completion, \"p--n\"
would complete to \"position-if-not\" in Common LISP.  If the symbol
follows a left paren or a #', only symbols with function cells will be
considered.  If the symbol starts with a \* all possible completions
will be considered.  To force all symbols to be considered, call it
with a prefix.  Only external symbols are considered if there is a
package qualification with only one colon.  The first time you try to
complete a string the longest common substring will be inserted.  If
you try to complete again, you can see the possible completions.  If
you are in a string, then filename completion will be done instead.
And if you try to complete a filename twice, you will see a list of
possible completions.

trace-lisp \(\\[trace-lisp]) traces the previous function symol.  When
called with a numeric prefix the function will be untraced.

default-directory-lisp \(\\[default-directory-lisp]\) sets the default
inferior LISP directory to the directory of the current buffer.  If
called in an inferior LISP buffer, it sets the Emacs default-directory
the LISP default directory.

The eval/compile commands evaluate or compile the forms specified.  If
any of the forms contain an interactive command, then the command will
never return.  To get out of this state, you need to use
abort-commands-lisp \(\\[abort-commands-lisp]).  The eval/compile
commands verify that their expressions are balanced and then send the
form to the inferior LISP.  If called with a positive prefix, the
result of the operation will be inserted into the buffer after the
form that was just sent.  If lisp-wait-p is t, then EMACS will display
the result of the command in the minibuffer or a pop-up window.  If
lisp-wait-p is nil, (the default) the send is done asynchronously and
the results will be brought up only if there is more than one line or
there is an error.  In this case, you will be given the option of
ignoring the error, keeping it in another buffer or keeping it and
aborting all pending sends.  If there is not a command already running
in the inferior LISP, you can preserve the break loop.  If called with
a negative prefix, the sense of lisp-wait-p will be inverted for the
next command.  The and-go versions will perform the operation and then
immediately switch to the ILISP buffer where you will see the results
of executing your form.  If eval-defun-and-go-lisp
\(\\[eval-defun-and-go-lisp]) or compile-defun-and-go-lisp
\(\\[compile-defun-and-go-lisp]) is called with a prefix, a call for
the form will be inserted as well.

When an eval is done of a single form matching ilisp-defvar-regexp,
the corresponding symbol will be unbound and the value assigned again.

The following commands all deal with finding things in source code.
The first time that one of these commands is used, there may be some
delay while the source module is loaded.  When searching files, the
first applicable rule is used: 1) try the inferior LISP, 2) try a tags
file if defined, 3) try all buffers in one of lisp-modes or all files
defined using lisp-directory.

lisp-directory \(\\[lisp-directory]) defines a set of files to be
searched by the source code commands.  It prompts for a directory and
sets the source files to be those in the directory that match entries
in auto-mode-alist for modes in lisp-source-modes.  With a positive
prefix, the files are appended.  With a negative prefix, all current
buffers that are in one of lisp-source-modes will be searched.  This
is also what happens by default.  Using this command stops using a
tags file.

edit-definitions-lisp \(\\[edit-definitions-lisp]) will find a
particular type of definition for a symbol.  It trys to use the rules
described above.  The files to be searched are listed in the buffer
\*Edit-Definitions*.  If lisp-edit-files is nil, no search will be
done if not found through the inferior LISP.  The variable
ilisp-locator contains a function that when given the name and type
should be able to find the appropriate definition in the file.  There
is often a flag to cause your LISP to record source files that you
will need to set in the initialization file for your LISP.  The
variable is \*record-source-files* in both allegro and lucid.  Once a
definition has been found, next-definition-lisp
\(\\[next-definition-lisp]) will find the next definition.  \(Or the
previous definition with a prefix.)

edit-callers-lisp \(\\[edit-callers-lisp]) will generate a list of all
of the callers of a function in the current inferior LISP and edit the
first caller using edit-definition.  Each successive call to
next-caller-lisp \(\\[next-caller-lisp]) will edit the next caller.
\(Or the previous caller with a prefix.)  The list is stored in the
buffer \*All-Callers*.  You can also look at the callers by doing
who-calls-lisp \(\\[who-calls-lisp]).

search-lisp \(\\[search-lisp]) will search the current tags files,
lisp directory files or buffers in one of lisp-source-modes for a
string or a regular expression when called with a prefix.
\(\\[next-definition-lisp]) will find the next definition.  \(Or the
previous definition with a prefix.)

replace-lisp \(\\[replace-lisp]) will replace a string (or a regexp
with a prefix) in the current tags files, lisp directory files or
buffers in one of lisp-source-modes.

find-file-lisp \(\\[find-file-lisp]) will find a file.  If it is in a
string, that will be used as the default if it matches an existing
file.  Symbolic links are expanded so that different references to the
same file will end up with the same buffer.

****************************************************************
The text below here requires a more than novice understanding to
implement.  You have been warned.  But it explains a lot of features,
so do go ahead and just read it

Customization: Entry to this mode runs the hooks on comint-mode-hook and
ilisp-mode-hook and then DIALECT-hooks specific to LISP
dialects in the nesting order above.  For more information on creating
a new dialect see ilisp.el.

See comint-mode documentation for more information on comint commands.

call-defun-lisp \(\\[call-defun-lisp]) will put a call to the current
defun in the inferior LISP and go there.  If it is a \(def* name form,
it looks up reasonable forms of name in the input history unless
called with a prefix. If not found, \(name or *name* will be inserted.
If it is not a def* form, the whole defun will be put in the buffer.

The very first inferior LISP command executed may send some forms to
initialize the inferior LISP.

Each time an inferior LISP command is executed, the last form sent can be
seen in the \*ilisp-send* buffer.

The first time an inferior LISP mode command is executed in a Lisp
Mode buffer, the package will be determined by using the regular
expression ilisp-package-regexp to find a package sexp and then
passing that sexp to the inferior LISP through ilisp-package-command.
For the clisp dialect, this will find the first \(in-package PACKAGE)
form in the file.  A buffer's package will be displayed in the mode
line.  reparse-attribute-list \(\\[reparse-attribute-list]) will
update the current package from the buffer.  If a buffer has no
specification, forms will be evaluated in the current inferior LISP
package.  package-lisp \(\\[package-lisp]) will show the current
package of the inferioir LISP.  set-package-lisp
\(\\[set-package-lisp]) will set the inferior LISP package to the
current buffer's package or to a manually entered package with a
prefix.

describe-lisp, arglist-lisp, documentation-lisp, macroexpand-1-lisp,
macroexpand-lisp, edit-definitions-lisp, who-calls-lisp,
edit-callers-lisp and trace-lisp will switch whether they prompt for a
response or use a default when called with a negative prefix.  If they
are prompting, there is completion through the inferior LISP by using
TAB or ESC-TAB.  When you are entering an expression in the
minibuffer, all of the normal ilisp commands like arglist-lisp also
work.

Commands that work on a function will use the nearest previous
function symbol.  This is either a symbol after a #' or the symbol at
the start of the current list.

describe-lisp \(\\[describe-lisp]) will describe the previous sexp.
If there is no previous-sexp and you are in an ILISP buffer, the
previous result will be described.


When compile-defun-lisp \(\\[compile-defun-lisp]) is called in an
inferior LISP buffer with no current form, the last form typed to the
top-level will be compiled.


The following commands all deal with making a number of changes all at
once.  The first time one of these commands is used, there may be some
delay as the module is loaded.  The eval/compile versions of these
commands are always executed asynchronously.

mark-change-lisp \(\\[mark-change-lisp]) marks the current defun as
being changed.  A prefix causes it to be unmarked.  clear-changes-lisp
\(\\[clear-changes-lisp]) will clear all of the changes.
list-changes-lisp \(\\[list-changes-lisp]) will show the forms
currently marked. 

eval-changes-lisp \(\\[eval-changes-lisp]), or compile-changes-lisp
\(\\[compile-changes-lisp]) will evaluate or compile these changes as
appropriate.  If called with a positive prefix, the changes will be
kept.  If called with a negative prefix, the commands will be sent to
the inferior LISP without waiting.  If there is an error, the process
will stop and show the error and all remaining changes will remain in
the list.  All of the results will be kept in the buffer
*Last-Changes*.

File commands in lisp-source-mode buffers keep track of the last used
directory and file.  If the point is on a string, that will be the
default.  If the buffer is one of lisp-source-modes, the buffer file
will be the default.  Otherwise, the last file used in a
lisp-source-mode will be used.

soar-load-file \(\\[load-file-lisp]) will load a file into the
inferior Soar.  If the filename  ends in .lisp, it will be loaded with
lisp-syntax set, if it ends in .soar it will be loaded with
Soar-syntax set.  the syntax is left unchanged after loading in either
case.  You will be given the opportunity to save the buffer if it has
changed and to compile the file if the compiled version is older than
the current version.
"
  "Documentation string for ISoar 6 mode.")


;;;
;;;   iii.  Keymaps and syntax table functions
;;;----------------------------------------------------------------------------
;;;

(defun soar-keys-setup (map &optional edit-mode)
 (let ((ilisp-prefix soar-command-prefix))
 (if (not map) 
     (error "Couldn't find key-map for soar-keys-setup."))
  ;; Commands useful in both subprocess and edit buffers
  ;; get put into map in reverse order (ie with a push)

  (ilisp-defkey map "\C-z" 'switch-to-lisp)
  (ilisp-defkey map " " 'macrocycle)
  (ilisp-defkey map "." 'soar-d)
  (ilisp-defkey map "," 'soar-r)
  (ilisp-defkey map "\M-\C-f" 'find-production-in-other-window)
  (ilisp-defkey map "\C-b" 'soar-load-buffer)
  (ilisp-defkey map "\C-d" 'insert-date-string)
  (ilisp-defkey map "\C-l" 'run-soar)
  (ilisp-defkey map "B"	'soar-pbreak-production)
  (ilisp-defkey map "c"	'soar-pclass)
  (ilisp-defkey map "e" 'soar-load-production)
  (ilisp-defkey map "f" 'soar-find-tag)
  (ilisp-defkey map "l" 'soar-load-file)
  (ilisp-defkey map "m"	'soar-smatches-production)
  (ilisp-defkey map "M"	'soar-full-matches-production)
  (ilisp-defkey map "\M-m"	'soar-really-full-matches-production)
  (ilisp-defkey map "o"	'soar-spr-symbol)
  (ilisp-defkey map "p"	'soar-spr-production)
  (ilisp-defkey map "T"	'soar-ptrace-production)
  (ilisp-defkey map "w"	'soar-copy-sp)
  (ilisp-defkey map "x"	'soar-excise-production)
  (ilisp-defkey map soar-menu-prefix 'run-soar-menu)
  ;; Deleted "fi:" preface
  (ilisp-defkey map "A" 'clman-apropos)
  (ilisp-defkey map "D" 'clman)
  (define-key map "\M-q" 'soar-reindent-sp)

 (cond ((not edit-mode)
        ;; just running buffer
        (ilisp-defkey map "]"	'next-cl-top-window)
        (ilisp-defkey map "["	'last-cl-top-window)
        )
        (edit-mode
        ;; just in edit buffers
         (ilisp-defkey map outline-prefix-char outline-minor-keymap)
  ))
))
          
;; init this here so you are ready if the user doesn't start
;; soar right away.
(soar-keys-setup soar-mode-map t)

;; done to keep keymaps consistent
(ilisp-defkey lisp-mode-map "\C-z" 'switch-to-lisp)

(defun soar-syntax-table-setup ()
  (if (not (syntax-table-p soar-mode-syntax-table))
    (progn
    (setq soar-mode-syntax-table (copy-syntax-table lisp-mode-syntax-table))
    (modify-syntax-entry ?{ "(}" soar-mode-syntax-table)
    (modify-syntax-entry ?} "){" soar-mode-syntax-table)
    ;; this could get screwed up with preferences, we'll 
    ;; have to assume that users can keep track of variable names
;    (modify-syntax-entry ?< "(>" soar-mode-syntax-table)
;    (modify-syntax-entry ?> ")<" soar-mode-syntax-table)
    (modify-syntax-entry ?* "_"  soar-mode-syntax-table)
    (modify-syntax-entry ?: "_"  soar-mode-syntax-table)
    (modify-syntax-entry ?- "_"  soar-mode-syntax-table) ;-fer added
    (modify-syntax-entry ?^ "_"  soar-mode-syntax-table)))
  (set-syntax-table soar-mode-syntax-table))

(unless (syntax-table-p soar-symbol-syntax-table)
  (setq soar-symbol-syntax-table (copy-syntax-table lisp-mode-syntax-table))
  (modify-syntax-entry ?{ "(}" soar-mode-syntax-table)
  (modify-syntax-entry ?} "){" soar-mode-syntax-table)
  ;; this could get screwed up with preferences, we'll 
  ;; have to assume that users can keep track of variable names
  (modify-syntax-entry ?< "_" soar-mode-syntax-table)
  (modify-syntax-entry ?> "_" soar-mode-syntax-table)
  (modify-syntax-entry ?* "_"  soar-mode-syntax-table)
  ;; most users will want this to be part of a word
  (modify-syntax-entry ?: "_"  soar-mode-syntax-table)
  ;; this makes : denote a package name or such
  ;; (modify-syntax-entry ?: "."  soar-mode-syntax-table)
  (modify-syntax-entry ?- "_"  soar-mode-syntax-table) ;-fer added
  (modify-syntax-entry ?^ "_"  soar-mode-syntax-table))


;;;
;;;	I.	soar dialect
;;;

;; (string-match comint-prompt-regexp "<sci,user> ")
;;
;; Has to go in here for now, defdialect not defined at load time.
;;
(defdialect soar "Soar based on Allegro"
   allegro
   ;; If you run lucid, put lucid in here instead of allegro.
   ;; If you don't run either, call us or send email to soar-bugs@cs.cmu.edu
   (ilisp-load-init 'soar "soar.lisp")
   (setq ilisp-program soar-image-name)	; User is responsible for having this in path.
   ;; Following accepts the default Allegro prompts, among others.
   ;; added a-z, 10-Jun-92 -FER
   (setq comint-prompt-regexp
"^\
\\(\\[[0-9]*c*\\] \\|\\)\
[A-Za-z]*\
[(<]\
[ 0-9A-Za-z:+,\\-]*\
[>\\)]\
\\(:\\|\\)\
 ?")
;; These lines match:
;; (1) beginning of string
;; (2) (a "[", any number of digits, followed by any number of "c"s, 
;;     a "]", and a single space), or not the [XXc] stuff
;; (3) a leading package name or no leading package name
;; (4) an open broken bracket or open paren
;; (5) any number of digits or letters, or certain punctuation marks
;; (6) a close broken bracket or close paren 
;; (7) a colon or not
;; (8) (a space or not)

    (setq ilisp-send-start-sync "\"Start sync\"")
    (setq ilisp-receive-start-sync "[ \t\n]*\"Start sync\"")
    (setq ilisp-send-end-sync "\"End sync\"")
    (setq ilisp-receive-end-sync "\"End sync\"")
    (set-ilisp-value 'ilisp-eval-command   "(ILISP:ilisp-eval \"%s\" \"%s\" \"%s\")")
    (setq ilisp-load-no-compile-query t)

   ;; Following lets production groupings be read as sets:
   (modify-syntax-entry ?{ "(}  " lisp-mode-syntax-table)
   (modify-syntax-entry ?} "){  " lisp-mode-syntax-table)
   (fset 'soar-send (symbol-function 'ilisp-send))
   (setq ilisp-motd 
         (format "Soar mode %s based on ILISP %s
Type \"%s%s\" for a command menu when in soar-mode buffers."
                  soar-mode-version
                  "V%s" 
                  soar-command-prefix  soar-menu-prefix))
   (ilisp-set-doc 'ilisp-mode inferior-soar-documentation)
   ;; (setq ilisp-init-binary-command
   ;; "(let ((ext (or #+m68k \"68fasl\"
   ;; 	        #+sparc \"sfasl\"
   ;; 	        #+iris4d \"ifasl\"
   ;;                      #+dec3100 \"pfasl\"
   ;;                      excl:*fasl-default-type*)))
   ;;         #+allegro-v4.0 (setq ext (concatenate 'string ext \"4\"))
   ;;         ext)")
   ;; setup our own syntax
   (soar-syntax-table-setup)
   (soar-keys-setup isoar-mode-map nil)
   (use-local-map isoar-mode-map)
   ;; Following will run at the first top-level prompt:
   (add-hook 'ilisp-init-hook
     (function (lambda ()
       ;; Set up for invisible process bridge so that for
       ;; example LISP code can generate graphs with mathematica
       ;; has to happen after soar is up.
       (install-bridge)
       (setq mode-name "ISOAR")
       (setq soar-version
             (ilisp-send "(format nil \"~a.~a.~a\" soar::*version-number*
                                      soar::*release-number*
                                      soar::*minor-version*)"))
       (if soar-beep-after-setup-p
	   (beep t))))))	; Beep when we can start working.


;; The following 3 defdialect's are examples of other ways to run Soar
;; (under Allegro Common Windows and on remote machines).
;;
;(defdialect cwsoar "Soar based on Allegro and CW"
;   allegro
;   (ilisp-load-init 'soar "soar.lisp")
;   (setq ilisp-program cwsoar-image-name) ; User is responsible for having this in path.
;   ;; Following allows prompts of the form "<56 soar> ":
;   (setq comint-prompt-regexp "^\\(\\[[0-9]*c*\\] \\|\\)\\(<\\|\\)[a-zA-Z0-9 :,\\-]*> ")
;   ;; Following lets production groupings be read as sets:
;   (modify-syntax-entry ?{ "(}  " lisp-mode-syntax-table)
;   (modify-syntax-entry ?} "){  " lisp-mode-syntax-table)
;   (setq ilisp-motd 
;         (format "Soar mode %s based on ILISP %s
;Type \"%s%s\" for a command menu when in soar-mode buffers."
;                  soar-mode-version
;                  "V%s" 
;                  soar-command-prefix  soar-menu-prefix))
;   (ilisp-set-doc 'ilisp-mode inferior-soar-documentation)
;   ;; setup our own syntax
;   (soar-syntax-table-setup)
;   (soar-keys-setup isoar-mode-map nil)
;   (use-local-map isoar-mode-map)
;   ;; Following will run at the first top-level prompt:
;   (add-hook 'ilisp-init-hook
;             (function (lambda ()
;               ;; Set up for invisible process bridge so that for
;               ;; example LISP code can generate graphs with mathematica
;               ;; has to happen after soar is up.
;               (install-bridge)
;               (setq mode-name "ISOAR")
;               (if soar-beep-after-setup-p
;                   (beep t))))))          ; Beep when we can start working.
;
;
;(defdialect remote-soar "Soar based on Allegro"
;  soar
;  (setq remote-soar-program
;        (concat "rsh "
;                (read-from-minibuffer "Remote host: ")
;                " ~soar/bin/soar")))
;
;
;(defdialect remote-cwsoar "Soar based on Allegro and CW"
;  soar
;  (setq remote-cwsoar-program
;        (concat "rsh "
;                (read-from-minibuffer "Remote host: ")
;                " ~soar/bin/cwsoar")))


(defdialect Soar6 "Soar6"
  ilisp
   (require 'soar6)
    (setq comint-prompt-regexp "^Soar>")
    (setq ilisp-send-start-sync "echo \"Start sync\"")
    (setq ilisp-receive-start-sync "[ \t\n]*Start sync")
    (setq ilisp-send-end-sync "echo \"End sync\"")
    (setq ilisp-receive-end-sync "End sync")
    (set-ilisp-value 'ilisp-eval-command  "%s")
                                         ;; "(ILISP:ilisp-eval \"%s\" \"%s\" \"%s\")"
   (setq ilisp-load-no-compile-query t)
   (setq ilisp-mode-map isoar-mode-map)
   (setq ilisp-use-map  isoar-mode-map)
   ;; Following lets production groupings be read as sets:
   (modify-syntax-entry ?{ "(}  " lisp-mode-syntax-table)
   (modify-syntax-entry ?} "){  " lisp-mode-syntax-table)
   (setq ilisp-motd 
         (format "Soar mode %s based on ILISP %s
Type \"%s%s\" for a command menu when in soar-mode buffers."
                  soar-mode-version
                  "V%s" 
                  soar-command-prefix  soar-menu-prefix))
   (ilisp-set-doc 'ilisp-mode inferior-soar-documentation)
   ;; Setup our own syntax
   (soar-syntax-table-setup)
   (soar-keys-setup isoar-mode-map nil)
   (use-local-map isoar-mode-map)
  (setq ilisp-program soar6-image-name)	; User is responsible for having this in path.
  (fset 'soar-send (symbol-function 'soar6-send))
  (if (not (fboundp 'common-lisp-indent-hook))
      (load "cl-indent"))
  (setq lisp-indent-hook 'common-lisp-indent-hook)
  (setq ilisp-load-or-send-command 
	"(or (and (load \"%s\" :if-does-not-exist nil) t)
             (and (load \"%s\" :if-does-not-exist nil) t))")
  ;; don't load an init file.
  ;; (ilisp-load-init 'clisp "clisp.lisp")
  (setq ilisp-last-command "*"
	ilisp-block-command "(progn %s\n)"
	ilisp-eval-command "(ILISP:ilisp-eval \"%s\" \"%s\" \"%s\")")
  (setq ilisp-describe-command "(ILISP:ilisp-describe \"%s\" \"%s\")"
	ilisp-inspect-command "(ILISP:ilisp-inspect \"%s\" \"%s\")"
	ilisp-arglist-command "(ILISP:ilisp-arglist \"%s\" \"%s\")")
  (setq ilisp-documentation-command
	"(ILISP:ilisp-documentation \"%s\" \"%s\" \"%s\")")
  (setq ilisp-macroexpand-1-command 
	"(ILISP:ilisp-macroexpand-1 \"%s\" \"%s\")")
  (setq ilisp-directory-command "(namestring *default-pathname-defaults*)"
	ilisp-set-directory-command
	"(setq *default-pathname-defaults* (parse-namestring \"%s\"))")
  (setq ilisp-load-command "(load \"%s\")")
   ;; Following will run at the first top-level prompt:
   (add-hook 'ilisp-init-hook
     (function (lambda ()
       ;; Set up for invisible process bridge so that for
       ;; example LISP code can generate graphs with mathematica
       ;; has to happen after soar is up.
       (install-bridge)
       (setq mode-name "ISOAR")
       (setq soar-version "6")
       ;(setq soar-version
       ;      (ilisp-send "(format nil \"~a.~a.~a\" soar::*version-number*
       ;                               soar::*release-number*
       ;                               soar::*minor-version*)"))
       (if soar-beep-after-setup-p
	   (beep t)))))	; Beep when we can start working.

)

(fset 'soar6 (symbol-function 'Soar6))

;; in later ilisp versions 4.11+, this may be replaced by
;; (setq ilisp-mode-map isoar-mode-map)
(add-hook 'soar-after-ilisp-hook
   (function 
      (lambda ()
         (use-local-map isoar-mode-map)
      )))

;;(add-hook 'soar6-after-ilisp-hook
;;   (function 
;;      (lambda ()
;;         (use-local-map isoar-mode-map)
;;      )))

;; Allow some aliases.
;; 
(fset 'run-soar (symbol-function 'soar))
(fset 'run-Soar (symbol-function 'soar))
(fset 'Soar (symbol-function 'soar))


;;;
;;; 	II.	SOAR-MODE, INFERIOR-SOAR-MODE
;;;-----------------------------------------------------------------------------
;;; The different modes are organized as follows:
;;;
;;;   Mode            "major-mode"         "mode-name"
;;;  ------           ------------         ------------
;;;  Soar files       soar-mode            Soar
;;;  Soar running     ilisp-mode           Ilisp 
;;;  


(defun soar-mode ()
  "Major mode for editing Soar source text and interacting with Soar
processes.  It is based on ILisp mode.  Soar Mode provides the
following features:

  * Functions to generate and maintain informative source code file headers 
  * Tags file support for Soar productions
  * Support for running one or more Soar processes in separate buffers,
  * Mouse support under X windows.

To run Soar type \"esc-x soar\".

Following is a list of the default Soar Mode key bindings:
\\{soar-mode-map}

The mouse keymap:

BUTTON                  FUNCTION
-------------------------------------------------------------------------
left                    set point           [actually whatever your defaults
middle                  paste from X-cutbuf    are, set by the user]
right                   select text

SHIFT-left              Run Soar spr on item under cursor
SHIFT-middle            Run Soar full-matches on item under cursor
SHIFT-right             Run find-tag on item under cursor

CONTROL-left            Eval definition (Soar or lisp) under cursor
CONTROL-middle          Run Soar ptrace on item under cursor
CONTROL-right            .. available for future expansion or user settable

In addition, a number of other commands are not bound to keys but are
available as extended commands:

    run-soar		    Start up a Soar process.
    
    make-header             Insert file header into current buffer
    make-revision           Add a revision line to header
    
    make-tags-table         Make a tags table for a list of files.
    remake-tags-table       Update a tags table, replacing entries only for 
                            files that have changed since the TAGS file was
			    saved. 

    find-tags-table         Switch tags table files.
    
    soar-count-productions  Count the number of productions in current buffer.
    soar-list-production-names
	                    Collect the names of all productions in buffer
		            and output in other window

Emacs Soar mode provides extensive support for file headers.  A file header
is a descriptive comment block placed at the beginning of a source code file
to keep track of such information as the author, creation date, last-modified
date, etc.  To make a header for the file in the current buffer, execute the
command esc-x `make-header'.  This inserts a standard header at the top of the
buffer, based on the current mode (it will work for non-soar buffers too) and
the functions listed in the variable `make-header-hooks'.

Soar Mode also adds \"tags\" support for the sp form of Soar productions.
Using the tags feature of Soar Mode, it's possible to create a tags table
file listing all the productions in a task.  The simplest way to generate
this file is to use the function `make-tags-table'.  It prompts for the names
of the source file and the name of the TAGS table to be created.  (A
suggestion: whenever you built a tags table for a set of Soar files, include
in the list of filenames ~soar/src/default.soar.  This often comes in handy
when you see default productions firing and you're wondering what they are
doing.)

To look up the definition of a production, first position the cursor over the
name of the production, and then type `C-c C-f' which invokes the find-tag
function.  (The almost-equivalent alternative, `ESC-.'  is retained for
compatibility with normal Emacs/Lisp key bindings.)

This feature works in both Soar subprocess buffers and Soar text buffers.
Thus you can lookup the definition of a production whose name you see printed
anywhere in the buffer (provide, of course, the appropriate tags table has
been built.)

The function \"remake-tags-table\" can be used to update a TAGS file for
a set of files.

Sometimes you will need to switch tags table files.  The function
\"find-tags-table\" will prompt you for the name of a new tags table to use.

The function `tags-apropos' will display a list of all tags matching a
given regular expression in the current tags table.

Entry to Soar Mode runs the following hooks in order: ilisp-hook(s)
common-lisp-mode-hook soar-mode-hook.
"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'soar-mode)
  (setq mode-name "Soar")
  (use-local-map soar-mode-map)

  (if (string-match "^18.4" emacs-version) ; hack.
      (lisp-mode-variables)    ; this is right for 18.49  
      (lisp-mode-variables t)) ; this is right for 18.50

  (setq local-abbrev-table lisp-mode-abbrev-table)
  (soar-syntax-table-setup)
  (soar-setup-outline)
  (turn-on-auto-fill)
  ;; a buffer local variable
  (setq ilisp-load-no-compile-query t)
  (run-hooks 'lisp-mode-hook
	     'common-lisp-mode-hook
             'soar-mode-hook)
  (message "Soar-mode set up -- type \"%s%s\" for the Soar command menu." 
         soar-command-prefix  soar-menu-prefix)
  t )

;; Allow some aliases
;; 
(fset 'Soar-mode (symbol-function 'soar-mode))



;;;
;;;
;;;

;When running X windows, Soar Mode defines special mouse button bindings:
;
;Button                  Function
;-----------------------------------------------------------------------
;left                    set point
;middle                  paste text
;right                   select text
;
;SHIFT-left		Run Soar \"spr\" on item under cursor
;SHIFT-middle		Run Soar \"full-matches\" on item under cursor
;SHIFT-right		Run find-tag on item under cursor
;
;CONTROL-SHIFT-left	Eval definition (Soar or lisp) under cursor
;CONTROL-SHIFT-middle	Run Soar \"ptrace\" on item under cursor
;-----------------------------------------------------------------------


;; old version of comint-prompt-regexp:  22-Jun-92 -FER
;	 "^\
;\\(\\[[0-9]*c*\\] \\|\\)\
;\\(<\\|\\)\
;[ 0-9A-Za-z:+,\\-]*\
;> ?")
