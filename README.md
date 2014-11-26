# Luxor

Luxor is the lightest dusting of syntactic sugar on the Cairo graphics package (which should also be installed).

Luxor is intended to be slightly easier to use than Cairo, with shorter names, fewer underscores, and simplified functions.

It's for when you just want to draw something without too much ceremony.

Color.jl provides excellent color definitions.

# Example usage

![output](my-png.png)

    using Luxor, Color
    Drawing(1200, 1400, "/tmp/my-pdf.pdf") 
    # or PNG filename for PNG
    origin() # move 0/0 to center
    background(color("purple"))
    # opacity from 0 to 1
    setopacity(0.7)
    # sethue sets the color but doesn't change the opacity
    sethue(0.3,.7,0.9)
    setline(20)
    # graphics functions use fill, stroke, fillstroke, 
    # clip, or leave blank
    rect(-400,-400,800,800, fill)
    randomhue()
    circle(0, 0, 460, stroke)
    # clip the following graphics to a circle positioned above the x axis
    circle(0,-200,400,clip)
    sethue(color("gold"))
    setopacity(0.7)
    setline(10)
    # simple line drawing
    for i in 0:pi/36:2*pi - pi/36
        move(0, 0)
        line(cos(i) * 600, sin(i) * 600 )
        stroke()
    end
    # finish clipping
    clipreset()
    # using  Mac OS X fonts
    fontsize(60)
    setcolor(color("turquoise"))
    fontface("Optima-ExtraBlack")
    textwidth = textextents("Luxor")[5]
    # then move the text by half the width
    text("Luxor", -textwidth/2, currentdrawing.height/2 - 400)
    # text on curve starting on an arc: arc starts at a line through (0,-10) radius 550, centered at 0,0 
    fontsize(18)
    fontface("Avenir-Black")
    textcurve("THIS IS TEXT ON A CURVE " ^ 14, 0, 0, 0, -10, 550)
    finish()
    preview() # Mac OS X only, opens in Preview
    

# To do

make it better