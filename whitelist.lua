local whitelist = {
  5709024479, -- Lunar / Thio
  2568715750, -- borytoko
  2645334884, -- polol
  3923431908, -- polol2
  7352719091, -- flocky
}

-- Sprawdzanie czy są liczbami
for _, userId in ipairs(whitelist) do
    if type(userId) ~= "number" then
        print("Błąd! ID nie jest liczbą: " .. tostring(userId))
    else
        print("ID jest liczbą: " .. tostring(userId))
    end
end
