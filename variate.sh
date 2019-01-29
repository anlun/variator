# 
# (C) Dmitry Boulytchev, Saint Petersburg State University, JetBrains Research, 2019
#
# Usage:
#
#    variate.sh -leave <regexp> -remove <regexp> -ending <regexp> files
#
# Example:
#
#    variate.sh -leave '\(\* Homework' -remove '\(\* Solution' -ending 'End \*\)' file1.ml file2.ml
# 
#    This will
#    - remove all lines matching '\(\* Homework assignment', '\(\* Solution', and 'End \*\)'
#    - remove all lines between '\(\* Solution' and 'End \*\)'
#    - but preserve all lines between '\(\* Homework assignment' and 'End \*\)'
#
#    Thus, a fragment
#
#       (* Implement integer addition *)
#       let add x y =
#          (* Homework assignment
#             invalid_arg "Not implemented"
#	      End *)
#          (* Solution *)
#	      x + y
#	   (* End *)
#
#    will be converted into
#
#       (* Implement integer addition *)
#       let add x y =
#             invalid_arg "Not implemented"
#
#
#    All files are overwritten in-place; their original content is saved in backups (file~).
#    Nested decorations are not supported
#

LEAVE=
REMOVE=
ENDING=
FILES=

while [ "$1" != "" ]; do
    case "$1" in
	-leave  ) shift
		  LEAVE=$1 ;;
	
	-remove ) shift
		  REMOVE=$1 ;;
	
	-ending ) shift
		  ENDING=$1 ;;
	*  ) FILES="$FILES $1" ;;
    esac
    shift
done

#echo "Files : $FILES"
#echo "Leave : $LEAVE"
#echo "Remove: $REMOVE"
#echo "Ending: $ENDING"

for FILE in $FILES
do
  echo "Processing $FILE:"
  echo "  backing up..."
  cp $FILE $FILE~
  echo "  weaving..."
  cat $FILE~ | awk -v begin=0 -v end=0 -v flag=1 -v leave="$LEAVE" -v ending="$ENDING" -v remove="$REMOVE" '$0 ~ leave  {flag=0; begin=1}
                                                                                                            $0 ~ remove {flag=0}
                                                                                                            $0 ~ ending {flag=0; end=1}
                                                                                                                        {if (flag) print $0; if (end) {flag=1; end=0}; if (begin) {flag=1; begin=0}}' > $FILE
done
