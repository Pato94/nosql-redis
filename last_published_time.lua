if #ARGV < 1 then
  error("User profile posts should be called with at least 1 arguments: username. Actually called with " .. #ARGV .. " arguments")
end

local username = ARGV[1]
local token = ARGV[2]

if token then
  redis.call("EXPIRE", "session:" .. token, 10 * 60)
end

local most_recent_post = redis.call("ZREVRANGE", "user:" .. username .. ":profile:posts", 0, 0, "WITHSCORES")
return most_recent_post[2]
