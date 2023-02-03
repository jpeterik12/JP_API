function initialize()

end

function start()
  -- mk_text_but(55, 0, 20, "DEV", function()
  --   local thing = table_from_file("mods/" .. MODNAME .. "/modules/debugger").run
  --   setfenv(thing, getfenv(1))
  --   thing()
  -- end).ents[1].button = false
  local ttime = 0
  local numb = 0
  add_listener("upd", function(self)
    if #bullets > numb then
      _log(self.t - ttime)
      ttime = self.t
    end
    numb = #bullets
  end)
end

function run()
  -- remove_buts()
  -- wait(100)
  -- for i = 0, 100 do
  --   if defbtn(i) then
  --     _log(defbtn(i))
  --   end
  -- end
  _logv(lang)
end
