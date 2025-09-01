  $ source $TESTDIR/scaffold

Tuples render with square brackets with (test), but no other assertions:

  $ use <<EOF
  > (use judge)
  > (test [1 2 3])
  > (test-pp [1 2 3])
  > (defmacro foo [] [1 2 3])
  > (test-macro (foo))
  > EOF
  $ judge
  ! <dim># script.janet</>
  ! 
  ! <red>(test [1 2 3])</>
  ! <grn>(test [1 2 3] [1 2 3])</>
  ! 
  ! <red>(test-pp [1 2 3])</>
  ! <grn>(test-pp [1 2 3] (1 2 3))</>
  ! 
  ! <red>(test-macro (foo))</>
  ! <grn>(test-macro (foo)
  !   (1 2 3))</>
  ! 
  ! 0 passed 3 failed
  [1]

Nested tuples use square/round brackets consistently:

  $ use <<EOF
  > (use judge)
  > (test [1 [2] 3])
  > (test [1 '[2] 3])
  > (test '[1 [2] 3])
  > (test-pp [1 [2] 3])
  > (test-pp [1 '[2] 3])
  > (test-pp '[1 [2] 3])
  > (defmacro foo [] [1 [2] 3])
  > (test-macro (foo))
  > (defmacro foo [] [1 '[2] 3])
  > (test-macro (foo))
  > (defmacro foo [] '[1 [2] 3])
  > (test-macro (foo))
  > EOF
  $ judge
  ! <dim># script.janet</>
  ! 
  ! <red>(test [1 [2] 3])</>
  ! <grn>(test [1 [2] 3] [1 [2] 3])</>
  ! 
  ! <red>(test [1 '[2] 3])</>
  ! <grn>(test [1 '[2] 3] [1 [2] 3])</>
  ! 
  ! <red>(test '[1 [2] 3])</>
  ! <grn>(test '[1 [2] 3] [1 [2] 3])</>
  ! 
  ! <red>(test-pp [1 [2] 3])</>
  ! <grn>(test-pp [1 [2] 3] (1 (2) 3))</>
  ! 
  ! <red>(test-pp [1 '[2] 3])</>
  ! <grn>(test-pp [1 '[2] 3] (1 [2] 3))</>
  ! 
  ! <red>(test-pp '[1 [2] 3])</>
  ! <grn>(test-pp '[1 [2] 3] [1 [2] 3])</>
  ! 
  ! <red>(test-macro (foo))</>
  ! <grn>(test-macro (foo)
  !   (1 (2) 3))</>
  ! 
  ! <red>(test-macro (foo))</>
  ! <grn>(test-macro (foo)
  !   (1 [2] 3))</>
  ! 
  ! <red>(test-macro (foo))</>
  ! <grn>(test-macro (foo)
  !   [1 [2] 3])</>
  ! 
  ! 0 passed 9 failed
  [1]

Test does not distinguish bracketed tuples, but test-pp and test-macro do:

  $ use <<EOF
  > (use judge)
  > (test [1 '[2] 3])
  > (test-pp [1 '[2] 3])
  > (defmacro foo [] [1 '[2] 3])
  > (test-macro (foo))
  > EOF
  $ judge -a
  ! <dim># script.janet</>
  ! 
  ! <red>(test [1 '[2] 3])</>
  ! <grn>(test [1 '[2] 3] [1 [2] 3])</>
  ! 
  ! <red>(test-pp [1 '[2] 3])</>
  ! <grn>(test-pp [1 '[2] 3] (1 [2] 3))</>
  ! 
  ! <red>(test-macro (foo))</>
  ! <grn>(test-macro (foo)
  !   (1 [2] 3))</>
  ! 
  ! 0 passed 3 failed
  [1]
  $ judge
  ! <dim># script.janet</>
  ! 
  ! 3 passed

The different hash order of ptuples and btuples in structs
doesn't cause comparisons to fail:

  $ use <<EOF
  > (use judge)
  > (test {[0 1] 1 '[1 2] 2 [2 3] 3} {[0 1] 1 [1 2] 2 [2 3] 3})
  > (test-pp {[0 1] 1 '[1 2] 2 [2 3] 3} {(0 1) 1 [1 2] 2 (2 3) 3})
  > EOF
  $ judge
  ! <dim># script.janet</>
  ! 
  ! 2 passed

Dictionaries that mix round and square tuples are not representable with (test), but are
representable with other printers:

  $ use <<EOF
  > (use judge)
  > (test {'[] 1 '() 2})
  > (test-pp {'[] 1 '() 2})
  > (defmacro foo [] {'[] 1 '() 2})
  > (test-macro (foo))
  > EOF
  $ judge -a
  ! <dim># script.janet</>
  ! 
  ! <red>(test {'[] 1 '() 2})</>
  ! <grn>(test {'[] 1 '() 2} {[] 1})</>
  ! 
  ! <red>(test-pp {'[] 1 '() 2})</>
  ! <grn>(test-pp {'[] 1 '() 2} {() 2 [] 1})</>
  ! 
  ! <red>(test-macro (foo))</>
  ! <grn>(test-macro (foo)
  !   {() 2 [] 1})</>
  ! 
  ! 0 passed 3 failed
  [1]
  $ judge
  ! <dim># script.janet</>
  ! 
  ! 3 passed

Judge uses a custom `deep=` to compare expectations that respects tuple shape:

  $ use <<EOF
  > (use judge)
  > (test [1 2 3] [1 2 3])
  > (test [1 2 3] (1 2 3))
  > (test-pp [1 2 3] [1 2 3])
  > (test-pp [1 2 3] (1 2 3))
  > EOF
  $ judge -a
  ! <dim># script.janet</>
  ! 
  ! <red>(test [1 2 3] (1 2 3))</>
  ! <grn>(test [1 2 3] [1 2 3])</>
  ! 
  ! <red>(test-pp [1 2 3] [1 2 3])</>
  ! <grn>(test-pp [1 2 3] (1 2 3))</>
  ! 
  ! 2 passed 2 failed
  [1]

  $ cat script.janet
  (use judge)
  (test [1 2 3] [1 2 3])
  (test [1 2 3] [1 2 3])
  (test-pp [1 2 3] (1 2 3))
  (test-pp [1 2 3] (1 2 3))
