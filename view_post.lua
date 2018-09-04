if #ARGV < 1 then
  error("View post should be called with at least 1 argument: postURL. Actually called with " .. #ARGV .. " arguments")
end

local url = ARGV[1]
local uuid = ARGV[2]
local username = nil
local user_posts = {}
local is_user_post = false

if uuid then
  username = redis.call("GET", "session:" .. uuid)
  if not username then
    error("Unauthorized. Unknown UUID")
  end

  user_posts = redis.call("SMEMBERS", "user:" .. username .. ":posts")
  for i=1, #user_posts do
    if user_posts[i] == url then
      is_user_post = true
    end
  end

  redis.call("EXPIRE", "session:" .. uuid, 10 * 60)
end

-- gets all fields from a hash as a dictionary
local hgetall = function (key)
  local bulk = redis.call('HGETALL', key)
	local result = {}
	local nextkey
	for i, v in ipairs(bulk) do
		if i % 2 == 1 then
			nextkey = v
		else
			result[nextkey] = v
		end
	end
	return result
end

local post = hgetall("post:" .. url)

if next(post) == nil then
  error("The requested post does not exist. Aborting")
end

-- redis doesn't let me store `false` so we check for the string "false" instead
if not(is_user_post) and post["public"] == "false" then
  error("The post is marked as private")
end

return post["markdown"]
