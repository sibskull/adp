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
        'policy (form-value "policy"))))

;;;
(define (init)
    ; Check Active Directory domain on machine
    (if (not (woo-get-option (woo-read-first "domain-policy") 'is_dc))
        (begin
          (form-update-visibility "noedit" #t)
          (form-update-visibility "edit" #f)))

    ; Read domain policy list
    (form-update-enum "policy" (woo-list "domain-policy/policies" 'language (form-value "language")))

    ; Bind slot to policy select
    (form-bind "policy" "change" on-policy-select))
