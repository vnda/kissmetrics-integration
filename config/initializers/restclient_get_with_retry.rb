module RestClient

  def self.get_with_retry(url, headers={}, &block)
    attempt = 1
    begin
      if attempt > 1
        seconds = {2=>3, 3=>15}[attempt]
        puts "Waiting #{seconds} seconds..."
        sleep(seconds)
      end
      get(url, headers, &block)
    rescue => e
      puts "#{e} #{url}"
      attempt += 1
      retry if attempt <= 3
      raise e
    end
  end

end
