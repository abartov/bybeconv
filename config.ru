# This file is used by Rack-based servers to start the application.
ENV['RACK_QUERY_PARSER_BYTESIZE_LIMIT'] = '20000000' # * some works, such as https://benyehuda.org/read/47208, are longer than Rack's default 4M POST limit size.

require_relative "config/environment"

run Rails.application
Rails.application.load_server
