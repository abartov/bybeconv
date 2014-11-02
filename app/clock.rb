if Rails.env.production?
  every(1.day, 'bybe_prod_backup', at: '03:30') do
    dir = File.expand_path('../../', __FILE__)
    Bundler.with_clean_env do
      system "cd #{dir}/vendor/backup/; bundle exec backup perform --trigger bybe_prod_backup --config-file ./config.rb"
    end
  end
end
