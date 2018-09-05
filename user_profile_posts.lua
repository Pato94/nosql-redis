if #ARGV < 3 then
  error("User profile posts should be called with at least 3 arguments: username, from and to. Actually called with " .. #ARGV .. " arguments")
end

local username = ARGV[1]
local from = ARGV[2]
local to = ARGV[3]
local token = ARGV[4]

if token then
  redis.call("EXPIRE", "session:" .. token, 10 * 60)
end

return redis.call("ZREVRANGE", "user:" .. username .. ":profile:posts", from, to)
