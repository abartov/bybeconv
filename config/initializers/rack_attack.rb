class Rack::Attack
  # Allow all requests from localhost
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end
  blocklist_ip("84.95.84.30")
  # Throttle requests to 5 requests per second per IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end
end
