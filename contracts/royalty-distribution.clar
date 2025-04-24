;; Royalty Distribution Contract
;; Handles automated payments

(define-data-var admin principal tx-sender)

;; Map to store royalty configurations for works
(define-map royalty-configs uint
  {
    creator: principal,
    royalty-percentage: uint,
    collaborators: (list 10 {collaborator: principal, share: uint}),
    total-earned: uint
  }
)

;; Map to track earnings by principal
(define-map earnings principal uint)

;; Public function to set up royalty configuration for a work
(define-public (set-royalty-config
    (work-id uint)
    (royalty-percentage uint)
    (collaborators (list 10 {collaborator: principal, share: uint})))
  (begin
    ;; Verify the caller is the work owner (would need to call work-registration contract)
    ;; This is simplified for this example
    (map-set royalty-configs work-id
      {
        creator: tx-sender,
        royalty-percentage: royalty-percentage,
        collaborators: collaborators,
        total-earned: u0
      }
    )
    (ok true)
  )
)

;; Public function to pay royalties for using a work
(define-public (pay-royalty (work-id uint) (amount uint))
  (let
    (
      (config (unwrap! (map-get? royalty-configs work-id) (err u404)))
      (creator (get creator config))
      (collaborators (get collaborators config))
      (total-earned (get total-earned config))
      (creator-earnings (default-to u0 (map-get? earnings creator)))
    )
    ;; Transfer STX from caller to this contract
    ;; This is simplified for this example
    ;; (stx-transfer? amount tx-sender (as-contract tx-sender))

    ;; Update total earned for the work
    (map-set royalty-configs work-id (merge config {total-earned: (+ total-earned amount)}))

    ;; If there are no collaborators, all goes to creator
    (if (is-eq (len collaborators) u0)
      (begin
        (map-set earnings creator (+ creator-earnings amount))
        (ok true)
      )
      ;; Otherwise distribute according to shares
      (begin
        ;; Calculate and distribute shares
        ;; This is simplified for this example
        (map-set earnings creator (+ creator-earnings amount))
        (ok true)
      )
    )
  )
)

;; Public function to withdraw earnings
(define-public (withdraw-earnings)
  (let
    (
      (user-earnings (default-to u0 (map-get? earnings tx-sender)))
    )
    (asserts! (> user-earnings u0) (err u100))
    ;; Transfer STX from contract to caller
    ;; This is simplified for this example
    ;; (as-contract (stx-transfer? user-earnings (as-contract tx-sender) tx-sender))
    (map-set earnings tx-sender u0)
    (ok user-earnings)
  )
)

;; Public function to get royalty configuration for a work
(define-read-only (get-royalty-config (work-id uint))
  (map-get? royalty-configs work-id)
)

;; Public function to get earnings for a principal
(define-read-only (get-earnings (user principal))
  (default-to u0 (map-get? earnings user))
)
