if #ARGV ~= 2 then
  error("List all posts should be called with 2 arguments: username and token. Actually called with " .. #ARGV .. " arguments")
end

local provided_username = ARGV[1]
local uuid = ARGV[2]

local username = redis.call("GET", "session:" .. uuid)

if provided_username ~= username then
  error("Unauthorized.")
end

redis.call("EXPIRE", "session:" .. uuid, 10 * 60)

return redis.call("SMEMBERS", "user:" .. username .. ":posts")
