
pacel={}
pacel.world={}
pacel.mode="menu"

pacel.screen={width=1000, height=900}

pacel.currentPos={area="", scene="", heldItem=""}

pacel.tags={all={}, area={}, scene={}, portal={}, object={}, item={}}
pacel.areas={}
pacel.items={}
pacel.inventories={}
pacel.HUDs={}
pacel.invHUDs={}

pacel.move=function(area, scene)
  pacel.currentPos.area=area
  pacel.currentPos.scene=scene
  pacel.saveCheck()
end

pacel.utils={
  table={
    Clone=function(T, N)
      assert(T and type(T)=="table", "Missing input table to table.Clone")
      local t={}
      if N then
        for k,v in pairs(T) do
          if not N[k] then
            t[k]=v
          end
        end
      else
        for k,v in pairs(T) do
          t[k]=v
        end
      end
      return t
    end,
    
    HasKey=function(T,K)
      assert(T and type(T)=="table", "Missing input table to table.HasKey")
      assert(K, "Missing input key to table.HasKey")
      for k,v in pairs(T) do
        if k==K then return true end
      end
      return false
    end,
    
    HasValue=function(T,V)
      assert(T and type(T)=="table", "Missing input table to table.HasValue")
      assert(V, "Missing input value to table.HasValue")
      for k,v in pairs(T) do
        if v==V then return true end
      end
      return false
    end,
    
    Len=function(T)
      assert(T and type(T)=="table", "Missing input table to table.Len")
      n=0
      for k,v in pairs(T) do
        n=n+1
      end
      return n
    end
    
  }
}

pacel.Tag=function(name, Type)
  assert(name, "Tag assigned without name")
  if Type then
    assert(pacel.tags[Type], "Tag assigned to nonexistant type")
    pacel.tags[Type][name]={}
  else
    pacel.tags["all"][name]={}
  end
end

pacel.Area=function(name, tags, def)
  assert(def, "Area created without definition")
  assert(name, "Area created without name")
  if tags then
    for _,v in pairs(tags) do
      assert(pacel.tags["all"][v] or pacel.tags["area"][v], "Area created with invalid tag")
      if pacel.tags["area"][v] then
        pacel.tags["area"][v][name]=name
      else
        pacel.tags["all"][v][name]=name
      end
    end
    pacel.areas[name]={Tags=pacel.utils.table.Clone(tags), Def=pacel.utils.table.Clone(def), scenes={}}
  else
    pacel.areas[name]={Def=pacel.utils.table.Clone(def), scenes={}}
  end
end

pacel.Scene=function(name, area, tags, def)
  assert(def, "Scene created without definition")
  assert(pacel.areas[area], "Scene created out of area")
  assert(name, "Scene created without name")
  if def.bg then 
    def.bg=love.graphics.newImage(def.bg)
  else
    def.bg=pacel.areas[area].Def.bg or nil
  end
  
  if def.fg then 
    def.fg=love.graphics.newImage(def.fg)
  else
    def.fg=pacel.areas[area].Def.fg or nil
  end
  
  if tags then
    for _,v in pairs(tags) do
      assert(pacel.tags["all"][v] or pacel.tags["scene"][v], "Scene created with invalid tag")
      if pacel.tags["scene"][v] then
        pacel.tags["scene"][v][name]=name
      else
        pacel.tags["all"][v][name]=name
      end
    end
    pacel.areas[area].scenes[name]={Tags=pacel.utils.table.Clone(tags), Def=pacel.utils.table.Clone(def), portals={}, objects={}}
  else
    pacel.areas[area].scenes[name]={Def=pacel.utils.table.Clone(def), objects={}, portals={}}
  end
end

pacel.Portal=function(name, tags, area, scene, toArea, toScene, def, x, y, z, w, h)
  assert(name, "Portal created without name")
  assert(pacel.areas[area], "Portal created without parent area")
  assert(pacel.areas[area].scenes[scene], "Portal created without parent scene")
  assert(pacel.areas[toArea], "Portal created without destination area")
  assert(pacel.areas[toArea].scenes[toScene], "Portal created without destination scene")
  assert(def, "Portal created without definiton")
  assert(x, "Portal has no x position")
  assert(y, "Portal has no y position")
  assert(z, "Portal has no draw weight")
  assert(w, "Portal has no width")
  assert(h, "Portal has no height")
  
  def2={
    area=area, 
    scene=scene, 
    toArea=toArea, 
    toScene=toScene
  }
  
  if def.txt then
    def2.txt=love.graphics.newImage(def.txt)
  end
  
  def=pacel.utils.table.Clone(def2)

  if tags then
    for _,v in pairs(tags) do
      assert(pacel.tags["all"][v] or pacel.tags["portal"][v], "Portal created with invalid tag")
      if pacel.tags["portal"][v] then
        pacel.tags["portal"][v][name]=name
      else
        pacel.tags["all"][v][name]=name
      end
    end
    pacel.areas[area].scenes[scene].portals[name]={Tags=pacel.utils.table.Clone(tags), Def=pacel.utils.table.Clone(def), x=x, y=y, z=z, w=w, h=h}
  else
    pacel.areas[area].scenes[scene].portals[name]={Def=pacel.utils.table.Clone(def), x=x, y=y, z=z, w=w, h=h}
  end
end

pacel.Object=function(name, tags, def, area, scene, x, y, z, w, h)
  assert(name, "Object created without name")
  assert(def, "Object created without definiton")
  assert(pacel.areas[area], "Object created without area")
  assert(pacel.areas[area].scenes[scene], "Object created without scene")
  assert(x, "Object has no x position")
  assert(y, "Object has no y position")
  assert(z, "Object has no draw weight")
  assert(w, "Object has no width")
  assert(h, "Object has no height")
  
  if def.txt then
    def.txt=love.graphics.newImage(def.txt)
  end

  if tags then
    for _,v in pairs(tags) do
      assert(pacel.tags["all"][v] or pacel.tags["object"][v], "Object created with invalid tag")
      if pacel.tags["object"][v] then
        pacel.tags["object"][v][name]=name
      else
        pacel.tags["all"][v][name]=name
      end
    end
    pacel.areas[area].scenes[scene].objects[name]={Tags=pacel.utils.table.Clone(tags), Def=pacel.utils.table.Clone(def), x=x, y=y, z=z, w=w, h=h}
  else
    pacel.areas[area].scenes[scene].objects[name]={Def=pacel.utils.table.Clone(def), x=x, y=y, z=z, w=w, h=h}
  end
end

pacel.Item=function(name, tags, def)
  assert(name, "Item created without name")
  assert(def, "Item created without definiton")
  
  if def.txt then
    def.txt=love.graphics.newImage(def.txt)
    def.cursor=love.mouse.newCursor(def.txt, 0, 0)
  end

  if tags then
    for _,v in pairs(tags) do
      assert(pacel.tags["all"][v] or pacel.tags["item"][v], "Item created with invalid tag")
      if pacel.tags["item"][v] then
        pacel.tags["item"][v][name]=name
      else
        pacel.tags["all"][v][name]=name
      end
    end
    pacel.items[name]={Tags=pacel.utils.table.Clone(tags), Def=pacel.utils.table.Clone(def)}
  else
    pacel.items[name]={Def=pacel.utils.table.Clone(def)}
  end
end

pacel.Inventory=function(n,s)
  assert(n, "Inventory created without name")
  local I={}
  if s then I.Limit={} end
  I.items={}
  I.realPacelInv=true
  pacel.inventories[n]=I
  return n
end

pacel.invAdd=function(inv, item, count)
  inv=pacel.inventories[inv]
  assert(pacel.items[item], "Item does not exist")
  if inv.realPacelInv and inv.items then
    if inv.Limit then
      if inv.items[item] then inv.items[item]["count"]=inv.items[item]["count"]+count 
      else inv.items[item]={count=count, name=item} end
    else
      if pacel.utils.table.Len(inv.items) < inv.Limit then
        if inv.items[item] then inv.items[item]["count"]=inv.items[item]["count"]+count 
        else inv.items[item]={count=count, name=item} end
      end
    end
  end
end
pacel.invRemove=function(inv, item, count)
  inv=pacel.inventories[inv]
  if inv.realPacelInv and inv.items then
    if inv.items[item] then 
      if count then 
        inv.items[item]["count"]=inv.items[item]["count"]-count 
      else 
        inv.items[item]=nil 
      end
    end
  end
end
pacel.invContains=function(inv, item, count)
  inv=pacel.inventories[inv]
  if inv.realPacelInv and inv.items then
    if inv.items[item] then 
      if count then 
        return inv.items[item]["count"]>=count
      else 
        return true
      end
    end
  end
end
pacel.invGet=function(inv)
  inv=pacel.inventories[inv]
    if inv.realPacelInv and inv.items then
      return inv.items
    end
end

pacel.HUD=function(name, txt, func, func2, x, y, z, w, h)
  assert(name, "HUD created without name")
  assert(txt, "HUD created without image")
  if func then assert(type(func)=="function", "Invalid HUD function") end
  pacel.HUDs[name]={txt=love.graphics.newImage(txt), func=func, x=x, y=y, z=z, w=w, h=h}
end

pacel.InvHUD=function(name, txt, func, func2, x, y, z, w, h, inv, i)
  assert(name, "InvHUD created without name")
  assert(txt, "InvHUD created without image")
  if func then assert(type(func)=="function", "Invalid HUD function") end
  pacel.invHUDs[name]={txt=love.graphics.newImage(txt), func=func, x=x, y=y, z=z, w=w, h=h, inv=inv, i=i}
end

pacel.Button=function(x,y,w,h)
  if love.mouse.getX() > x and love.mouse.getX() < x+w 
  and love.mouse.getY() > y and love.mouse.getY() < y+h then
    return true
  else
    return false
  end
end

function love.mousereleased(x,y,b) 
  if b==1 then
    pacel.MouseReleasedButton=1
  end
  if b==2 then
    pacel.MouseReleasedButton=2
  end
end

pacel.Set=function(area, scene)
  if pacel.mode=="world" then
    assert(area and pacel.areas[area], "Area not found")
    assert(scene and pacel.areas[area].scenes[scene], "Scene not found")
    local scene2=pacel.areas[area].scenes[scene]
    
    if scene2.Def.bg then 
      love.graphics.draw(scene2.Def.bg, 0, 0, 0, love.graphics.getWidth()/scene2.Def.bg:getWidth(), love.graphics.getHeight()/scene2.Def.bg:getHeight())
    end
    
    local things={}
    for _,p in pairs(pacel.areas[area].scenes[scene].portals) do
      if p.z then 
        if not things[p.z] then things[p.z]={} end
        table.insert(things[p.z], pacel.utils.table.Clone(p))
      else
        if not things[0] then things[0]={} end
        table.insert(things[0], pacel.utils.table.Clone(p))
      end
    end
    for _,p in pairs(pacel.areas[area].scenes[scene].objects) do
      if p.z then 
        if not things[p.z] then things[p.z]={} end
        table.insert(things[p.z], pacel.utils.table.Clone(p))
      else
        if not things[0] then things[0]={} end
        table.insert(things[0], pacel.utils.table.Clone(p))
      end
    end
    
    for _,pd in pairs(things) do
      for __,p in ipairs(pd) do
        if p.Def then 
          if p.Def.txt then
            love.graphics.draw(p.Def.txt, (love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y, 0, p.w/p.Def.txt:getWidth()-((pacel.screen.width-love.graphics.getWidth())/1000), p.h/p.Def.txt:getHeight()-((pacel.screen.height-love.graphics.getHeight())/1000))
          end
        end
      end
    end
    
    if scene2.Def.fg then 
      love.graphics.draw(scene2.Def.fg, 0, 0, 0, love.graphics.getWidth()/scene2.Def.fg:getWidth(), love.graphics.getHeight()/scene2.Def.fg:getHeight())
    end
    
    local invhuds={}
    for _,p in pairs(pacel.invHUDs) do
      if p.z then 
        if not invhuds[p.z] then invhuds[p.z]={} end
        table.insert(invhuds[p.z], pacel.utils.table.Clone(p))
      else
        if not invhuds[0] then invhuds[0]={} end
        table.insert(invhuds[0], pacel.utils.table.Clone(p))
      end
    end
    for _,pd in pairs(invhuds) do
      for __,p in ipairs(pd) do
        love.graphics.draw(p.txt, (love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y, 0, p.w/p.txt:getWidth()-((pacel.screen.width-love.graphics.getWidth())/1000), p.h/p.txt:getHeight()-((pacel.screen.height-love.graphics.getHeight())/1000))
        if p.inv and pacel.inventories[p.inv] then
          if pacel.inventories[p.inv].items then
            if pacel.inventories[p.inv].items[p.i] then
              if pacel.items[pacel.inventories[p.inv].items[p.i].name] then
                love.graphics.draw(pacel.items[pacel.inventories[p.inv].items[p.i].name].Def.txt, (love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y, 0, p.w/p.txt:getWidth()-((pacel.screen.width-love.graphics.getWidth())/1000), p.h/p.txt:getHeight()-((pacel.screen.height-love.graphics.getHeight())/1000))
              end
            end
          end
        end
      end
    end
    
    local huds={}
    for _,p in pairs(pacel.HUDs) do
      if p.z then 
        if not huds[p.z] then huds[p.z]={} end
        table.insert(huds[p.z], pacel.utils.table.Clone(p))
      else
        if not huds[0] then huds[0]={} end
        table.insert(huds[0], pacel.utils.table.Clone(p))
      end
    end
    for _,pd in pairs(huds) do
      for __,p in ipairs(pd) do
        love.graphics.draw(p.txt, (love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y, 0, p.w/p.txt:getWidth()-((pacel.screen.width-love.graphics.getWidth())/1000), p.h/p.txt:getHeight()-((pacel.screen.height-love.graphics.getHeight())/1000))
      end
    end
  end
end

pacel.Check=function(area, scene)
  if pacel.mode=="world" then
    assert(area and pacel.areas[area], "Area not found")
    assert(scene and pacel.areas[area].scenes[scene], "Scene not found")
    for _,p in pairs(pacel.areas[area].scenes[scene].portals) do
      if p.Def then 
        if pacel.Button((love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y,p.w,p.h) then 
          if pacel.MouseReleasedButton==1 then
            pacel.move(p.Def.toArea,p.Def.toScene)
          end
        end
      end
    end
    for _,p in pairs(pacel.areas[area].scenes[scene].objects) do
      if p.Def then 
        if pacel.Button((love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y,p.w,p.h) then
	  if p.Def.func3 then p.Def.func(p, area, scene, pacel.currentPos.heldItem) end
          if pacel.MouseReleasedButton==1 then
            if p.Def.func then p.Def.func(p, area, scene, pacel.currentPos.heldItem) end
          end
          if pacel.MouseReleasedButton==2 then
            if p.Def.func2 then p.Def.func2(p, area, scene, pacel.currentPos.heldItem) end
          end
        end
      end
    end
    for _,p in pairs(pacel.HUDs) do
      if p.func then
        if pacel.Button((love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y,p.w,p.h) then
          if pacel.MouseReleasedButton==1 then
            p.func()
          end
          if pacel.MouseReleasedButton==2 then
            if p.func2 then p.func2() end
          end
        end
      end
    end
    for _,p in pairs(pacel.invHUDs) do
      if p.func then
        if pacel.Button((love.graphics.getWidth()/100)*p.x, (love.graphics.getHeight()/100)*p.y,p.w,p.h) then
          if pacel.MouseReleasedButton==1 then
            p.func(p.inv,p.i)
          end
          if pacel.MouseReleasedButton==2 then
            if p.func2 then p.func2(p.inv,p.i) end
          end
        end
      end
    end
  end
  pacel.MouseReleasedButton=0
end

pacel.saveCheck=function()
    local dir = love.filesystem.getSaveDirectory()
    local r=io.open(dir.."/save", "w")
    local t={mode=pacel.mode, pos=pacel.utils.table.Clone(pacel.currentPos), xt=pacel.utils.table.Clone(pacel.world)}
    r:write(TSerial.pack(t, function(n) return "<function>" end, false))
    r:close()
end

pacel.load=function()
  local dir = love.filesystem.getSaveDirectory()
  if io.open(dir.."/save") then
    local s=io.open(dir.."/save", r)
    local s2=s:read()
    local t=TSerial.unpack(s2, true)
    s:close()
    assert(t.mode, "Save file corrupt")
    assert(t.pos, "Save file corrupt")
    assert(t.xt, "Save file corrupt")
    
    pacel.mode=t.mode
    pacel.currentPos=pacel.utils.table.Clone(t.pos)
    pacel.world=pacel.utils.table.Clone(t.xt)
  end
end
