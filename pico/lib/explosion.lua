ex_emitters={}

function add_exp(x,y)
    local e={
        parts={},
        x=x,
        y=y,
        offset={x=cos(rnd())*2,y=sin(rnd())*2},
        age=0,
        maxage=25
    }
    for i=0,7 do
        add_exp_part(e)
    end
    add(ex_emitters,e)
end
  
function add_exp_part(e)
local p={
    x=e.x+(cos(rnd())*5),
    y=e.y+(sin(rnd())*5),
    rad=0,
    age=0,
    maxage=5+rnd(10),
    c=rnd({8,9,10})
    }
    add(e.parts,p)
end

function update_explosions()
    for i=#ex_emitters,1,-1 do
      local e=ex_emitters[i]
      add_exp_part(e)
      for ip=#e.parts,1,-1 do
        local p=e.parts[ip]
         p.rad+=1
         p.age+=1
         if p.age+5>p.maxage then
           p.c=5
         end
         if p.age>p.maxage then
           del(e.parts,p)
         end
       end
       e.age+=1
       if e.age>e.maxage then
         del(ex_emitters,e)
       end
    end
end

function draw_explosions()
    for e in all(ex_emitters) do
      for p in all(e.parts) do
        circfill(p.x,p.y,p.rad,p.c)
        circfill(p.x+e.offset.x,p.y+e.offset.y,p.rad-3,0)
        circ(p.x+(cos(rnd())*5),p.y+(sin(rnd())*5),1,0)
       end
    end
end