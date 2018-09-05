if #ARGV < 1 then
  error("User profile posts should be called with at least 1 arguments: text. Actually called with " .. #ARGV .. " arguments")
end

local text = ARGV[1]
local token = ARGV[2]

if token then
  redis.call("EXPIRE", "session:" .. token, 10 * 60)
end

local results = {}
local max_results = 10
local rangelen = 50
local start = redis.call("ZRANK", "user_autocomplete", text)
local loop = true

while start and #results < max_results and loop do
  local range = redis.call("ZRANGE", "user_autocomplete", start, start + rangelen - 1)
  start = start + rangelen
  if not range or #range == 0 then
    break
  end

  for i=1, #range do
    local entry = range[i]
    local minlen = math.min(entry:len(), text:len())
    if entry:sub(1, minlen) ~= text:sub(1, minlen) then
      loop = false
      break
    end
    if entry:sub(-1) == "*" and #results < max_results then
      table.insert(results, entry:sub(1, entry:len() - 1))
    end
  end
end

return results
