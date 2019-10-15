(define-module (ui domain-policy ajax)
    :use-module (alterator woo)
    :use-module (alterator ajax)
    :use-module (alterator str)
    :use-module (alterator effect)
    :export (init))

; On change policy in list
(define (on-policy-select)
     (form-update-enum "rules" (woo-list "domain-policy/rules"
        'language (form-value "language")
        'policy (form-value "policy")
        'class (form-value "class")))
     (form-update-visibility "rules" #t))

; Write rule values
(define (ui-write)
   (catch/message
     (lambda()
       (apply woo-write "domain-policy"
              (form-value-list '("policy" "rules"))))))

; Write activate and disable rule
(define (ui-active)
    (woo-error "AAA"))

;;;
(define (init)
    ; Check Active Directory domain on machine
    (if (not (woo-get-option (woo-read-first "domain-policy") 'is_dc))
        (begin
          (form-update-visibility "noedit" #t)
          (form-update-visibility "edit" #f)))

    ; Read domain policy list
    (form-update-enum "policy" (woo-list "domain-policy/policies" 'language (form-value "language")))

    ; Read available classes
    (form-update-enum "class" (woo-list "domain-policy/classes" 'language (form-value "language")))

    ; Bind slot to policy or class select
    (form-bind "policy" "change" on-policy-select)
    (form-bind "class"  "change" on-policy-select)

    ; Write change check state
    (form-bind "rules" "update-value" ui-active)
    (form-bind "rules" "change" ui-active)

    ; Bind Apply button click to backend
    (form-bind "apply_button" "click" ui-write))

