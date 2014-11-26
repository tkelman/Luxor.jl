#!/Applications/Julia-0.3.2.app/Contents/Resources/julia/bin/julia

module Luxor

using  Color

import Cairo

global currentdrawing # will hold the current drawing

export Drawing, currentdrawing, 
    finish, preview,
    origin, axes, background, 
    newpath, closepath, newsubpath, 
    randompoint, randompointarray, 
	circle, rect, setantialias, setline, setlinecap, setlinejoin, setdash,
	move, rmove,
	line, rline, curve, arc,
	stroke, fill, fillstroke, poly, strokepreserve, 
	fillpreserve, 
	save, restore, 
	scale, rotate, translate, 
	clip, clippreserve, clipreset,
	fontface, fontsize, text,
	textextents, textcurve, 
	setcolor, setopacity, sethue, randomhue, randomcolor

type Drawing
    width::Float64
    height::Float64
    filename
    surface
    cr
    surfacetype
    redvalue::Float64
    greenvalue::Float64
    bluevalue::Float64
    alpha::Float64
    function Drawing(w=800, h=800, f="/tmp/test.png")
        global currentdrawing
        this = new()
        this.width = w
        this.height = h
        this.filename = f
        this.redvalue = 0.0
        this.greenvalue = 0.0
        this.bluevalue = 0.0 
        this.alpha = 1.0
         (path, ext) = splitext(f)
         if ext == ".pdf"
            this.surface =  Cairo.CairoPDFSurface(f, w, h)
            this.surfacetype = "pdf"
            this.cr      =  Cairo.CairoContext(this.surface)
         elseif ext == ".png" || ext == "" # default to PNG
            this.surface = Cairo.CairoRGBSurface(w,h)
            this.surfacetype = "png"
            this.cr      = Cairo.CairoContext(this.surface)
         end
         currentdrawing = this
    end
end

function finish()
    if currentdrawing.surfacetype == "png"
        Cairo.write_to_png(currentdrawing.surface, currentdrawing.filename)
    elseif currentdrawing.surfacetype == "pdf"
        Cairo.finish(currentdrawing.surface)
    end
end

# TODO what to do on non-OS X
function preview()
    @osx_only run(`open $(currentdrawing.filename)`)
end

function origin()
    # set the origin at the center
    # this was going to do reflection as well
    # but doesn't
    #    reflection = Cairo.CairoMatrix(1.0, 0.0, 0.0, -1.0, 0.0, 0.0)
    #    Cairo.setmatrix(cr,reflection)
    Cairo.translate(currentdrawing.cr, currentdrawing.width/2, currentdrawing.height/2)
end

function axes()
    # draw axes
    save()
        setline(1)
        fontsize(20)
        setcolor(color("gray"))
        move(0,0)
        line(currentdrawing.width/2 - 20,0)
        stroke()
        text("x", currentdrawing.width/2 - 20, 0)
        move(0,0)
        line(0, currentdrawing.height/2 - 20)
        stroke()
        text("y", 0, currentdrawing.height/2 - 20)
    restore()
end

function background(color)
   setcolor(color)
   rect(-currentdrawing.width/2, -currentdrawing.height/2, currentdrawing.width, currentdrawing.height, fill)
end

function randompoint(low, high)
# random (x, y) tuple between low and high
    (low + rand() * abs(high - low), low + rand() * abs(high - low))
end

function randompointarray(low, high, n)
    array = Tuple[]
    for i in 1:n
       push!(array, randompoint(low,high))
    end
    array
end

# does this do anything in Cairo?

setantialias(n) = Cairo.set_antialias(currentdrawing.cr, n)

# paths

newpath() = Cairo.new_path(currentdrawing.cr)
newsubpath() = Cairo.new_sub_path(currentdrawing.cr)
closepath() = Cairo.close_path(currentdrawing.cr)

# shapes and lines

stroke()            = Cairo.stroke(currentdrawing.cr)
fill()              = Cairo.fill(currentdrawing.cr)
strokepreserve()    = Cairo.stroke_preserve(currentdrawing.cr)
fillpreserve()      = Cairo.fill_preserve(currentdrawing.cr)

function fillstroke()
    fillpreserve()
    stroke()
end

# clipping

clip() = Cairo.clip(currentdrawing.cr)
clippreserve() = Cairo.clip_preserve(currentdrawing.cr)
clipreset() = Cairo.reset_clip(currentdrawing.cr)

# circles and arcs

function circle(x, y, r, action=())
    newpath()
    Cairo.circle(currentdrawing.cr, x, y, r)
    if action == fill
        fill()
    elseif action == stroke
        stroke()
    elseif action == clip
        clip()
    elseif action == fillstroke
        fillstroke()
    end
end         

# positive clockwise from x axis in radians
function arc(xc, yc, radius, angle1, angle2, action=())
    newpath()
    Cairo.arc(currentdrawing.cr, xc, yc, radius, angle1, angle2)
    if action == fill
        fill()
    elseif action == stroke
        stroke()
    elseif action == clip
        clip()
    elseif action == fillstroke
        fillstroke()
    end
end

function rect(xmin, ymin, w, h, action=())
    newpath()
    Cairo.rectangle(currentdrawing.cr, xmin, ymin, w, h)
    if action == fill
        fill()
    elseif action == stroke
        stroke()
    elseif action == clip
        clip()
    elseif action == fillstroke
        fillstroke()
    end
end         

setline(n)      = Cairo.set_line_width(currentdrawing.cr, n)

function setlinecap(str="butt")
    if str == "round"
        Cairo.set_line_cap(currentdrawing.cr, Cairo.CAIRO_LINE_CAP_ROUND)
    elseif str == "square"
        Cairo.set_line_cap(currentdrawing.cr, Cairo.CAIRO_LINE_CAP_SQUARE)
    else
        Cairo.set_line_cap(currentdrawing.cr, Cairo.CAIRO_LINE_CAP_BUTT)        
    end 
end

function setlinejoin(str="miter")
    if str == "round"
        Cairo.set_line_join(currentdrawing.cr, Cairo.CAIRO_LINE_JOIN_ROUND)
    elseif str == "bevel"
        Cairo.set_line_join(currentdrawing.cr, Cairo.CAIRO_LINE_JOIN_BEVEL)
    else
        Cairo.set_line_join(currentdrawing.cr, Cairo.CAIRO_LINE_JOIN_MITER)
    end
end

function setdash(dashing)
# solid, dotted, dot, dotdashed, longdashed, shortdashed, dash, dased, dotdotdashed, dotdotdotdashed
    Cairo.set_line_type(currentdrawing.cr, dashing)
end

move(x, y)      = Cairo.move_to(currentdrawing.cr,x, y)
rmove(x, y)     = Cairo.rel_move(currentdrawing.cr,x, y)
line(x, y)      = Cairo.line_to(currentdrawing.cr,x, y)
rline(x, y)     = Cairo.rel_line_to(currentdrawing.cr,x, y)
curve(x1, y1, x2, y2, x3, y3) = Cairo.curve_to(currentdrawing.cr, x1, y1, x2, y2, x3, y3)

save() = Cairo.save(currentdrawing.cr)
restore() = Cairo.restore(currentdrawing.cr)

scale(sx, sy) = Cairo.scale(currentdrawing.cr, sx, sy)
rotate(a) = Cairo.rotate(currentdrawing.cr, a)
translate(tx, ty) = Cairo.translate(currentdrawing.cr, tx, ty)

function poly(list, action = (); close=false, )
# where list is [(x,y), (x1,y1), (x2,y2),....]
# by default doesn't close or fill, to allow for clipping.etc
    newpath()
    move(list[1][1], list[1][2])    
    for p in 1:length(list)
        line(list[p][1], list[p][2])
    end
    if close
        closepath()
    end
    if action == fill
        fill()
    elseif action == stroke
        stroke()
    elseif action == clip
        clip()
    elseif action == fillstroke
        fillstroke()
    end
end

# text, the 'toy' API... "Any serious application should avoid them." :)

fontface(f) = Cairo.select_font_face (currentdrawing.cr, f, Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
fontsize(n) = Cairo.set_font_size(currentdrawing.cr, n)

textextents(string) = Cairo.text_extents(currentdrawing.cr, string)
# typedef struct {
#     double x_bearing;
#     double y_bearing;
#     double width;
#     double height;
#     double x_advance;
#     double y_advance;
# } cairo_text_extents_t;
#=

The bearing is the displacement from the reference point to the upper-left corner of the bounding box.
It is often zero or a small positive value for x displacement, but can be negative x for characters like 
j as shown; it's almost always a negative value for y displacement. The width and height then describe the 
size of the bounding box. The advance takes you to the suggested reference point for the next letter. 
Note that bounding boxes for subsequent blocks of text can overlap if the bearing is negative, or the 
advance is smaller than the width would suggest.

=# 

# text doesn't affect current point!
function text(t, x=0, y=0)
    save()
    Cairo.move_to(currentdrawing.cr, x, y)
    Cairo.show_text(currentdrawing.cr, t)
    restore()
end

function textcurve(str, x, y, xc, yc, r)
    # put string of text on a circular arc
    # starting on line passing through (x,y), on arc/circle centred (xc,yc) on circle with radius r
    # the radius is used to define the circle, the x/y are just used to define the start position

    # first get widths of every character:
    widths = Float64[]
    for i in 1:length(str)
        extents = textextents(str[i:i])
#        x_bearing = extents[1]
#        y_bearing = extents[2]
#        w = extents[3]
#        h = extents[4]
        x_advance = extents[5]
#        y_advance = extents[6]
        push!(widths, x_advance )
    end
    save()
        arclength = r * atan2(y, x) # starting on line passing through x/y but using radius
        for i in 1:length(str)
            save()
                theta = arclength/r  # angle for this character
                delta = widths[i]/ r # amount of turn created by width of this char
                translate(r * cos(theta), r * sin(theta)) # move the origin to this point
                rotate(theta + pi/2 + delta/2) # rotate so text baseline perp to center
                text(str[i:i])
                arclength += widths[i] # move on by the width of this character
            restore()
        end    
    restore()
end

# colours, relying on Color.jl to convert anything to RGBA
# eg setcolor(color("gold")) # or "green", "darkturquoise", "lavender" or what have you
#    setcolor(convert(Color.HSV, Color.RGB(0.5, 1, 1)))
#    for i in 1:15:360
#       setcolor(convert(Color.RGB, Color.HSV(i, 1, 1)))
#       ...
#    end

function setcolor(color)
    temp = convert(RGBA, color)
    (currentdrawing.redvalue, currentdrawing.greenvalue, currentdrawing.bluevalue, currentdrawing.alpha) = (temp.c.r, temp.c.g, temp.c.b, temp.alpha)
    Cairo.set_source_rgba(currentdrawing.cr, currentdrawing.redvalue, currentdrawing.greenvalue, currentdrawing.bluevalue, temp.alpha)
end

function setcolor(r, g, b, a=1)
    Cairo.set_source_rgba(currentdrawing.cr, r, g, b, a)
end

# like Mathematica we sometimes want to change the current 'color' without changing alpha/opacity
# using sethue() rather than setcolor() doesn't change the current alpha 

function sethue(r, g, b)
    (currentdrawing.redvalue, currentdrawing.greenvalue, currentdrawing.bluevalue) = (r, g, b)
    # use current alpha
    Cairo.set_source_rgba(currentdrawing.cr, r, g, b, currentdrawing.alpha)
end

function sethue(color)
    temp = convert(RGBA, color)
    (currentdrawing.redvalue, currentdrawing.greenvalue, currentdrawing.bluevalue) = (temp.c.r, temp.c.g, temp.c.b)
    Cairo.set_source_rgba(currentdrawing.cr, currentdrawing.redvalue, currentdrawing.greenvalue, currentdrawing.bluevalue, currentdrawing.alpha) # use current alpha, not incoming one
end

# like Mathematica we sometimes want to change the current opacity without changing the current color

function setopacity(a)
    # use current RGB values
    alpha = a
    Cairo.set_source_rgba(currentdrawing.cr, currentdrawing.redvalue, currentdrawing.greenvalue, currentdrawing.bluevalue, currentdrawing.alpha)
end

function randomhue()
    sethue(rand(), rand(),rand())
end

function randomcolor()
    setcolor(rand(), rand(),rand(), rand())
end

end