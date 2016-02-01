require 'json'
require 'hash-joiner'
require 'open-uri'
require 'hmac_authentication'


module Jekyll_Get
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    def hmac_auth(source_config)
      env_var = source_config['authentication_env_var_name']
      secret_key = ENV[env_var]
      if !secret_key
        raise "authentication_env_var_name `#{env_var}` not set in environment"
      end
      digest_name = 'sha1' # Or any other available Hash algorithm.
      signature_header = 'Team-Api-Signature'
      headers = ['Content-Type', 'Date']
      auth = HmacAuthentication::HmacAuth.new(
        digest_name, secret_key, signature_header, headers)
      return auth
    end

    def download_contents(source_config)
      uri = URI(source_config['json'])
      Net::HTTP.start(uri.host, uri.port,
        :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri
        if source_config['authentication_scheme'] == 'hmac'
          auth = hmac_auth source_config
          auth.sign_request request
        end
        response = http.request request # Net::HTTPResponse object
        return response.body
      end
    end

    private :hmac_auth, :download_contents

    def generate(site)
      config = site.config['jekyll_get']
      if !config
        return
      end
      if !config.kind_of?(Array)
        config = [config]
      end
      config.each do |d|
        begin
          target = site.data[d['data']]
          raw_source = download_contents d
          source = JSON.load(raw_source)
          if target
            HashJoiner.deep_merge target, source
          else
            site.data[d['data']] = source
          end
          if d['cache']
            data_source = (site.config['data_source'] || '_data')
            path = "#{data_source}/#{d['data']}.json"
            open(path, 'wb') do |file|
              file << JSON.generate(site.data[d['data']])
            end
          end
        rescue Exception => e
          puts "Error collecting jekyll_get data for #{d['data']} (#{d['json']}): #{e}"
          next
        end
      end
    end
  end
end
