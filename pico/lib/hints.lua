-- events
msgs={}
flts={}

function addmsg(_txt,_secs,_colr)
	add(msgs,
		{
			txt=_txt,
			duration=_secs*60,
			frames=0,
			colr=_colr
		}
	)
end

function update_messages()
	for ms in all(msgs) do
		if ms.frames == 
					ms.duration then
			del(msgs,ms)
			ms=nil
		else
			ms.frames+=1
		end
	end
end

function draw_messages()
	if #msgs==0 then 
		return
	end
	local sz=(#msgs-1)*8
	local ys=13*8-sz-3
	local ye=14*8-3
	if me.mapy>7 then
		ys=1
		ye=11+sz-3
	end
	rectfill(5,ys+1,125,ye+1,0)
	rectfill(4,ys,124,ye,7)
	
	for i=1,#msgs do
		local txt=msgs[i].txt
		local colr=msgs[i].colr
		color(colr)
		cursor(8,ys+2+(i-1)*8)
		print(txt)
	end
end

function addflt(_x,_y,_txt,_colr)
	add(flts,
		{
			txt=_txt,
			frames=0,
			colr=_colr,
			tgr=obj.y-10,
			x=_x,
			y=_y
		}
	)
end

function update_flts()
	for fl in all(flts) do
		if fl.frames==50 then
			del(flts,fl)
			fl=nil
		else
			fl.frames+=1
			fl.y-=(fl.y-fl.tgr)/10
		end
	end
end

function draw_flts()
	for fl in all(flts) do
		printo(fl.txt,fl.x-2,fl.y,fl.colr)
	end
end

function printo(txt,x,y,colr)
	for i=1,3 do
		print(txt,(x+(i-2)),y,0)
		print(txt,x,(y+(i-2)),0)
	end
	print(txt,x,y,colr)
end