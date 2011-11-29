module HtmlUnit
  def self.download_htmlunit(version)
    if not version_exist?(version)
      puts "Installing HTMLUnit #{version} at .akephalos/#{version}/"
      Dir.mkdir(".akephalos") unless File.exists?(".akephalos")
      Dir.mkdir(".akephalos/#{version}") unless File.exists?(".akephalos/#{version}")
      download(version)
      unzip(version)
      remove_cache(version)
    else
      puts "Using HTMLUnit #{version}"
    end
  end

  def self.version_exist?(version)
    File.exist?(".akephalos/#{version}/htmlunit-#{version}.jar")
  end

  def self.unzip(version)
    `tar xzf htmlunit-#{version}.zip`
    `cp -r htmlunit-#{version}/lib/ .akephalos/#{version}/`
  end

  def self.download(version)
    if version[2] < '9'
      %x[curl -L -O http://sourceforge.net/projects/htmlunit/files/htmlunit/#{version}/htmlunit-#{version}.zip]
    else
      %x[curl -L -o htmlunit-#{version}.zip  http://sourceforge.net/projects/htmlunit/files/htmlunit/#{version}/htmlunit-#{version}-bin.zip]
    end
  end

  def self.remove_cache(version)
    `rm -rf htmlunit-#{version} htmlunit-#{version}.zip`
  end
end