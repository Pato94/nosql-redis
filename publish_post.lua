redis.replicate_commands()

if #ARGV ~= 2 then
  error("Publish post should be called with 2 arguments: url and token. Actually called with " .. #ARGV .. " arguments")
end

local url = ARGV[1]
local uuid = ARGV[2]

local username = redis.call("GET", "session:" .. uuid)

if not username then
  error("Unauthorized. Unknown UUID")
end

redis.call("EXPIRE", "session:" .. uuid, 10 * 60)

local exists = redis.call("SISMEMBER", "user:" .. username .. ":posts", url)
if exists == 0 then
  error("The given url didn't match any user's posts")
end

redis.call("ZADD", "user:" .. username .. ":profile:posts", redis.call("TIME")[1], url)
redis.call("HMSET", "post:" .. url, "public", "true")
