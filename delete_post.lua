if #ARGV ~= 2 then
  error("Register should be called with 2 arguments: url and token. Actually called with " .. #ARGV .. " arguments")
end

local url = ARGV[1]
local uuid = ARGV[2]

local username = redis.call("GET", "session:" .. uuid)

if not username then
  error("Unauthorized. Unknown UUID")
end

redis.call("EXPIRE", "session:" .. uuid, 10 * 60)

local deleted = redis.call("SREM", "user:" .. username .. ":posts", url)
if deleted == 0 then
  error("The given url didn't match any user's posts")
end

redis.call("DEL", "post:" .. url)
