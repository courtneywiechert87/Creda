;; Creda Registry Contract
;; Decentralized Identity Registration and Management

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants and Errors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-ALREADY-REGISTERED u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-INVALID-INPUT u103)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var contract-admin principal tx-sender)

(define-map identity-registry principal
  {
    did: (string-ascii 100),
    metadata-hash: (buff 32),
    created-at: uint
  }
)

(define-map identity-status principal bool)

(define-map profile-aliases (tuple (alias (string-ascii 30))) principal)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private Helper Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (is-admin (caller principal))
  (is-eq caller (var-get contract-admin))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (register-identity (did (string-ascii 100)) (metadata-hash (buff 32)))
  (begin
    (asserts! (not (is-eq did "")) (err ERR-INVALID-INPUT))
    (asserts! (is-none (map-get? identity-registry tx-sender)) (err ERR-ALREADY-REGISTERED))
    (map-set identity-registry tx-sender
      {
        did: did,
        metadata-hash: metadata-hash,
        created-at: block-height
      }
    )
    (map-set identity-status tx-sender true)
    (ok true)
  )
)

(define-public (update-metadata (new-metadata-hash (buff 32)))
  (begin
    (asserts! (is-some (map-get? identity-registry tx-sender)) (err ERR-NOT-FOUND))
    (let (
        (current (unwrap! (map-get? identity-registry tx-sender) (err ERR-NOT-FOUND)))
        (updated {
          did: (get did current),
          metadata-hash: new-metadata-hash,
          created-at: (get created-at current)
        })
      )
      (map-set identity-registry tx-sender updated)
      (ok true)
    )
  )
)

(define-public (deactivate-identity (identity principal))
  (begin
    (asserts! (is-admin tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? identity-status identity)) (err ERR-NOT-FOUND))
    (map-set identity-status identity false)
    (ok true)
  )
)

(define-public (activate-identity (identity principal))
  (begin
    (asserts! (is-admin tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? identity-status identity)) (err ERR-NOT-FOUND))
    (map-set identity-status identity true)
    (ok true)
  )
)

(define-public (add-alias (alias (string-ascii 30)))
  (begin
    (asserts! (is-some (map-get? identity-registry tx-sender)) (err ERR-NOT-FOUND))
    (map-set profile-aliases { alias: alias } tx-sender)
    (ok true)
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin tx-sender) (err ERR-NOT-AUTHORIZED))
    (var-set contract-admin new-admin)
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read-Only Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-identity (owner principal))
  (map-get? identity-registry owner)
)

(define-read-only (is-identity-active (owner principal))
  (default-to false (map-get? identity-status owner))
)

(define-read-only (get-alias-owner (alias (string-ascii 30)))
  (map-get? profile-aliases { alias: alias })
)

(define-read-only (get-admin)
  (var-get contract-admin)
)
