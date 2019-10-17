(define-module (ui domain-policy ajax)
    :use-module (alterator woo)
    :use-module (alterator ajax)
    :use-module (alterator str)
    :use-module (alterator effect)
    :export (init))

; On change policy in list
(define (on-policy-select)
     (form-update-value "ejson" (woo-get-option (woo-read-first "domain-policy/json"
        'action "list"
        'language (form-value "language")
        'policy (form-value "policy")
	'class (form-value "class")) 'json))
     (form-update-visibility "class" #t)
     (form-update-visibility "rules" #t))

; Write rule values
(define (undefined)
   (catch/message
     (lambda()
       (apply woo-write "domain-policy"
              (form-value-list '("policy" "class" "data64" ))))))

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

    ; Bind Apply button click to backend
    (form-bind "apply_button" "click" undefined))

