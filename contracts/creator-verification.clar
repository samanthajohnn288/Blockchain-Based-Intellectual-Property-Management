;; Creator Verification Contract
;; This contract validates the identity of IP owners

(define-data-var admin principal tx-sender)

;; Map to store verified creators
(define-map verified-creators principal
  {
    name: (string-utf8 100),
    verification-date: uint,
    verification-level: uint
  }
)

;; Public function to verify a creator (admin only)
(define-public (verify-creator (creator principal) (name (string-utf8 100)) (verification-level uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-creators creator
      {
        name: name,
        verification-date: block-height,
        verification-level: verification-level
      }
    ))
  )
)

;; Public function to check if a creator is verified
(define-read-only (is-verified (creator principal))
  (is-some (map-get? verified-creators creator))
)

;; Public function to get creator details
(define-read-only (get-creator-details (creator principal))
  (map-get? verified-creators creator)
)

;; Public function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u101))
    (ok (var-set admin new-admin))
  )
)
