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
    if version[2] < '9'
      %x[unzip -j -d .akephalos/#{version} htmlunit-#{version}.zip htmlunit-#{version}/lib htmlunit-#{version}/lib/*]
    else
      %x[unzip -j -d .akephalos/#{version} htmlunit-#{version}-bin.zip htmlunit-#{version}/lib htmlunit-#{version}/lib/*]
    end
    
  end
  
  def self.download(version)
    if version[2] < '9'
      %x[curl -L -O http://sourceforge.net/projects/htmlunit/files/htmlunit/#{version}/htmlunit-#{version}.zip]
    else
      %x[curl -L -O http://sourceforge.net/projects/htmlunit/files/htmlunit/#{version}/htmlunit-#{version}-bin.zip]
    end
  end
  
  def self.remove_cache(version)
    if version[2] < '9'    
      File.unlink "htmlunit-#{version}.zip"
    else
      File.unlink "htmlunit-#{version}-bin.zip"
    end
  end  
end