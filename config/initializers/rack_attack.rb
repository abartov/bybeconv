class Rack::Attack
  # Allow all requests from localhost
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end
  blocklist_ip("84.95.84.30")
  blocklist_ip("147.189.171.165") # Oct 2024

  # Throttle requests to 5 requests per second per IP
  throttle('req/ip', limit: 500, period: 3.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end
end
