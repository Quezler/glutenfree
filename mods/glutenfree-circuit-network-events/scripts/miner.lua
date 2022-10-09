local miner = {}

-- https://math.stackexchange.com/a/163101
function spiral(n)
  k=math.ceil((math.sqrt(n)-1)/2)
  t=2*k+1
  m=t^2 
  t=t-1
  if n>=m-t then return k-(m-n),-k        else m=m-t end
  if n>=m-t then return -k,-k+(m-n)       else m=m-t end
  if n>=m-t then return -k+(m-n),k else return k,k-(m-n-t) end
end

-- next instead of find, full assumption that you're gonna put something there
function miner.next_empty_position()
  for n, _ in pairs(global.spiral_empty) do
    global.spiral_empty[n] = nil
    return {spiral(n)}
  end

  global.spiral_index = global.spiral_index + 1
  local x, y = spiral(global.spiral_index)
  return {x, y}
end

return miner
