;
; Reflection v0.3 2007-12-20
;
; Copyright (C) 2005-2007 Otavio Correa Cordeiro (otavio gmail com)
; Create a reflection effect like Apple iWeb does..
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; modified by Paul Sherman to work in GIMP 2.4.2 on 11/30/2007
;
; modified by David Cummins and Paul Sherman Dec 2007, tested on GIMP-2.4.3
; * added user settings to control the height of the generated reflection,
;   the gradient mask starting point (presented as Fade Rate %), and options
;   to keep the generated reflection as a separate layer, or on a single layer
;   either transparent or flattened.
; * added code to "play nice" with the current GIMP environment: colors and
;   gradient prior selections are preserved, as well as the original layer
;   name (handled using careful stack order).
;   generated layers are constrained around the original layer.
; * simplified some of the internal logic so repeated calculations are done
;   only once, reformatted, organised the code, added comments, etc.
; * flattened on start (to avoid errors)
; * undo ability functional
;
; modified by Dylan McCall on August 4, 2009
; * added blur effect to reflection and parameters to configure it.
;
(define (script-fu-gimp-reflection
         theImage
         theLayer
         userHeight
         userFade
         userBlurWidth
         userBlurHeight
         new_layer
         transparentBG
        )
    (gimp-image-undo-group-start theImage)
    (gimp-selection-all theImage)
    (gimp-selection-none theImage)
    (set! theLayer (car(gimp-image-merge-visible-layers theImage 0)))

    ;preserve original settings
    (define old-bg   (car (gimp-context-get-background)))
    (define old-fg   (car (gimp-context-get-foreground)))
    (define old-grad (car (gimp-context-get-gradient)))

    ;calculate color for start of gradient fade
    (define fadeStart (* (- 100 userFade) 2.55))
    (define fadeColor (list fadeStart fadeStart fadeStart))

    (define originalWidth (car (gimp-image-width theImage)))
    (define originalHeight (car (gimp-image-height theImage)))
    (define reflectionScale (/ userHeight 100))
    (define stackPos (car(gimp-image-get-layer-position theImage theLayer)))
    (define newWidth originalWidth)
    (define newHeight (* originalHeight (+ reflectionScale 1)))
    (define gradX (/ originalWidth 2))
    (define gradY1 (* originalHeight reflectionScale))
    (define gradY2 (* originalHeight reflectionScale -1))

    (gimp-image-resize theImage originalWidth newHeight 0 0)
    (define new-layer (car (gimp-layer-copy theLayer 1)))
    (gimp-image-add-layer theImage new-layer (+ stackPos 0))
    (gimp-drawable-set-name new-layer "Reflection")
    (gimp-layer-set-offsets new-layer 0 originalHeight)
    (gimp-flip new-layer 1)
    (define new-mask (car (gimp-layer-create-mask new-layer 0)))
    (gimp-layer-add-mask new-layer new-mask)

    (gimp-context-set-foreground fadeColor)

    (gimp-edit-blend new-mask FG-TRANSPARENT-MODE NORMAL-MODE
		   GRADIENT-LINEAR 100 0 REPEAT-NONE
		   FALSE
		   FALSE 0 0 TRUE
		   gradX gradY1 gradX gradY2)
		   
    (gimp-layer-remove-mask new-layer MASK-APPLY)
    (gimp-layer-resize-to-image-size new-layer)
    (plug-in-gauss 1 theImage new-layer userBlurWidth userBlurHeight 1)

  (if (= new_layer FALSE)
    (begin
        (if (= transparentBG TRUE)
	      (begin ;# NO separate layer, transparent ##############
	          (gimp-image-merge-visible-layers theImage 1)
	      )
	      (begin ;# NO separate layer, NOT transparent ##########
	          (gimp-image-flatten theImage)
	      )
	    )
        ; final crop not needed for new_layer FALSE
    )
    (begin
        (if (= transparentBG TRUE)
	      (begin ;# separate layer, transparent ###############
	      	  (gimp-image-set-active-layer theImage new-layer)
	      )
	      (begin ;# separate layer, NOT transparent ###########
                (define bg-layer (car(gimp-layer-new theImage originalWidth newHeight 0 "Reflection BG" 100 0)))
                (gimp-image-add-layer theImage bg-layer (+ stackPos 2))
                (gimp-selection-all theImage)
                (gimp-bucket-fill bg-layer 1 0 100 255 0 1 1)
                (gimp-selection-none theImage)
                (gimp-image-set-active-layer theImage new-layer)
            )
        )
        ; the Reflection layer still overflows the image here
        (gimp-image-crop theImage originalWidth newHeight 0 0)
    )
  )

    ;restore original settings
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
    (gimp-context-set-gradient old-grad)

    (gimp-image-undo-group-end theImage)
)


; The following is separate from the above Reflection script. This is a
; part of the ubiquity-slideshow project.
; <http://launchpad.net/~ubiquity-slideshow>

(define (process-reflection image)
    (plug-in-autocrop 1 image (car (gimp-image-get-active-layer image)))
    (script-fu-gimp-reflection image (car (gimp-image-get-active-layer image)) 30 90 10 40 0 1)
)

; returns the filename.ext of a full path (i.e. ubuntu/file.svg -> file.svg)
(define (basename fullname)
	(if (string=? "/" (substring fullname 0 1)) 
		(substring fullname 1) 
		(basename (substring fullname 1))
	)
)

(define (batch-reflection pattern output)
    (let* ((filelist (cadr (file-glob pattern 1))))
        (while (not (null? filelist))
            (let* ((filename (car filelist))
                (image (car (gimp-file-load 1 filename filename))))
                (process-reflection image)
                (define base-filename (basename filename))
                (define new-filename (string-append output (substring base-filename 0 (- (string-length base-filename) 4)) ".png"))
                (gimp-file-save 1 image (car (gimp-image-get-active-layer image)) new-filename new-filename)
                (gimp-image-delete image)
            )
            (set! filelist (cdr filelist))
        )
    )
)

(define (batch-reflection-svg pattern output)
    (let* ((filelist (cadr (file-glob pattern 1))))
        (while (not (null? filelist))
            (let* ((filename (car filelist))
                (image (car (file-svg-load 1 filename filename 90 185 185 0))))
                (process-reflection image)
                (define base-filename (basename filename))
                (define new-filename (string-append output (substring base-filename 0 (- (string-length base-filename) 4)) ".png"))
                (gimp-file-save 1 image (car (gimp-image-get-active-layer image)) new-filename new-filename)
                (gimp-image-delete image)
            )
            (set! filelist (cdr filelist))
        )
    )
)

(batch-reflection-svg "./*.svg" "./out/")
(batch-reflection "./*.png" "./out/")

(gimp-quit 0)
