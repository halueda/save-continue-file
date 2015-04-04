# save-continue-file

put save-continue-file.el to anywhere emacs can load

place it in .emacs
  (load "save-continue-file.el")

do it in *scratch*
  (load "save-continue-file.el")
  (save-continue-file)

Notice:
 - visited files are monotonically grown. use kill-buffer appropriately.
