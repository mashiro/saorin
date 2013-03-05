#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require 'saorin'

class Handler
  def log(tag, time, record)
    puts [tag, time, record]
    nil
  end
end

Saorin::Server.start Handler.new, :host => 'localhost', :port => 25252, :adapter => :reel

