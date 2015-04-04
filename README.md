# save-continue-file

This is emacs lisp to re-visit all files at start.
Once setup, the files are visited everytime emacs starts, until the buffer killed.

Instruction:

put save-continue-file.el to anywhere emacs can load

place it in .emacs
  (load "save-continue-file.el")

do it in *scratch*
  (load "save-continue-file.el")
  (save-continue-file)

Notice:
 - visited files are monotonically grown. use kill-buffer appropriately.
