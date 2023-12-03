#lang racket
(require racket/gui)
; Ryan Lee CS 135-A
; I pledge my honor that I have abided by Stevens honor system.

(define fHeight 1000)
(define fWidth 1000)
(define emptyPos '(2 4)) ; empty square index
(define n 8) ; 2^n board size
(define tileSize (floor (/ fWidth (expt 2 n))))

(define frame (new frame%
                   [label "Courtyard"]
                   [width fWidth]
                   [height fHeight]))

(define (draw-canvas dc ltiles-pos)
  (if (<= (length ltiles-pos) 1)
      (drawLTile dc (caaar ltiles-pos) (list-ref (caar ltiles-pos) 1) tileSize (make-object color% (random 256) (random 256) (random 256)) (cadar ltiles-pos))
      (begin
        (drawLTile dc (caaar ltiles-pos) (list-ref (caar ltiles-pos) 1) tileSize (make-object color% (random 256) (random 256) (random 256)) (cadar ltiles-pos))
        (draw-canvas dc (cdr ltiles-pos)))))

(define (drawLTile dc xPos yPos size color orient)
  (send dc set-brush color 'solid)
  (send dc set-pen color 1 'transparent)
  (cond
   [(= orient 1)
    (send dc draw-rectangle
      (- xPos size) yPos
     (* size 2) size)
    (send dc draw-rectangle
      (- xPos size) (- yPos size)
      size (* size 2))]
   [(= orient 2)
    (send dc draw-rectangle
      (- xPos size) (- yPos size)
      size (* size 2))
    (send dc draw-rectangle
      (- xPos size) (- yPos size)
      (* size 2) size)]
   [(= orient 3)
    (send dc draw-rectangle
      xPos (- yPos size)
      size (* size 2))
    (send dc draw-rectangle
      (- xPos size) (- yPos size)
      (* size 2) size)]
   [(= orient 4)
    (send dc draw-rectangle
      (- xPos size) yPos
      (* size 2) size)
    (send dc draw-rectangle
      xPos (- yPos size)
      size (* size 2))])
 )

(define (getPotEmptyPos offsetX offsetY centerPos) ; centerPos relative to subboard
  (list (+ (list-ref centerPos 0) offsetX) (+ (list-ref centerPos 1) offsetY)))

(define (getEmptyPosFromLTile tileX tileY quad orient) ; helper method for width > 2
  (cond
    [(= orient 1)
     (cond [(= quad 1)
            (list (- tileX tileSize) (- tileY tileSize))]
           [(= quad 3)
            (list (- tileX tileSize) tileY)]
           [(= quad 4)
            (list tileX tileY)])]
    [(= orient 2)
     (cond [(= quad 1)
            (list (- tileX tileSize) (- tileY tileSize))]
           [(= quad 2)
            (list tileX (- tileY tileSize))]
           [(= quad 3)
            (list (- tileX tileSize) tileY)])]
    [(= orient 3)
     (cond [(= quad 1)
            (list (- tileX tileSize) (- tileY tileSize))]
           [(= quad 2)
            (list tileX (- tileY tileSize))]
           [(= quad 4)
            (list tileX tileY)])]
    [(= orient 4)
     (cond [(= quad 2)
            (list tileX (- tileY tileSize))]
           [(= quad 3)
            (list (- tileX tileSize) tileY)]
           [(= quad 4)
            (list tileX tileY)])]
    )
  )

(define (getNewCenter oldCenter quad width)
  (cond [(= quad 1)
         (list (- (list-ref oldCenter 0) (* tileSize (/ width 4))) (- (list-ref oldCenter 1) (* tileSize (/ width 4))))]
        [(= quad 2)
         (list (+ (list-ref oldCenter 0) (* tileSize (/ width 4))) (- (list-ref oldCenter 1) (* tileSize (/ width 4))))]
        [(= quad 3)
         (list (- (list-ref oldCenter 0) (* tileSize (/ width 4))) (+ (list-ref oldCenter 1) (* tileSize (/ width 4))))]
        [(= quad 4)
         (list (+ (list-ref oldCenter 0) (* tileSize (/ width 4))) (+ (list-ref oldCenter 1) (* tileSize (/ width 4))))]))

(define (genTilePos emptyPos centerPos width)
  (if (<= width 2)
          (cond
            [(equal? emptyPos (getPotEmptyPos 0 (* -1 tileSize) centerPos))
             (list (list centerPos 1))]
            [(equal? emptyPos (getPotEmptyPos 0 0 centerPos))
             (list (list centerPos 2))]
            [(equal? emptyPos (getPotEmptyPos (* -1 tileSize) 0 centerPos))
             (list (list centerPos 3))]
            [(equal? emptyPos (getPotEmptyPos (* -1 tileSize) (* -1 tileSize) centerPos))
             (list (list centerPos 4))])

          (cond
            ; quadrant 1
            [(and (< (list-ref emptyPos 0) (list-ref centerPos 0)) (< (list-ref emptyPos 1) (list-ref centerPos 1)))
             (append (list (list centerPos 4))
                     (genTilePos emptyPos (getNewCenter centerPos 1 width) (/ width 2))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 2 4) (getNewCenter centerPos 2 width) (/ width 2))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 3 4) (getNewCenter centerPos 3 width) (/ width 2))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 4 4) (getNewCenter centerPos 4 width) (/ width 2)))]
            ; quadrant 2
            [(and (>= (list-ref emptyPos 0) (list-ref centerPos 0)) (< (list-ref emptyPos 1) (list-ref centerPos 1)))
             (append (list (list centerPos 1))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 1 1) (getNewCenter centerPos 1 width) (/ width 2))
                     (genTilePos emptyPos (getNewCenter centerPos 2 width) (/ width 2))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 3 1) (getNewCenter centerPos 3 width) (/ width 2))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 4 1) (getNewCenter centerPos 4 width) (/ width 2)))]
            ; quadrant 3
            [(and (< (list-ref emptyPos 0) (list-ref centerPos 0)) (>= (list-ref emptyPos 1) (list-ref centerPos 1)))
             (append (list (list centerPos 3))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 1 3) (getNewCenter centerPos 1 width) (/ width 2))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 2 3) (getNewCenter centerPos 2 width) (/ width 2))
                     (genTilePos emptyPos (getNewCenter centerPos 3 width) (/ width 2))
                     (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 4 3) (getNewCenter centerPos 4 width) (/ width 2)))]
            ; quadrant 4
            [(and (>= (list-ref emptyPos 0) (list-ref centerPos 0)) (>= (list-ref emptyPos 1) (list-ref centerPos 1)))
             (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 1 2) (getNewCenter centerPos 1 width) (/ width 2))
             (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 2 2) (getNewCenter centerPos 2 width) (/ width 2))
             (genTilePos (getEmptyPosFromLTile (list-ref centerPos 0) (list-ref centerPos 1) 3 2) (getNewCenter centerPos 3 width) (/ width 2))
             (genTilePos emptyPos (getNewCenter centerPos 4 width) (/ width 2))]
            )))


(new canvas% [parent frame]
             [paint-callback
              (lambda (canvas dc)
                (draw-canvas dc (genTilePos (list (* (car emptyPos) tileSize) (* (list-ref emptyPos 1) tileSize)) (list (* (/ (expt 2 n) 2) tileSize) (* (/ (expt 2 n) 2) tileSize)) (expt 2 n))))])
(send frame show #t)

