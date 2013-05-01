require 'rake/clean'
task :default => ['bootstaller-i686.usb', 'bootstaller-x86_64.usb']
task :upload => '.upload'

CLEAN.include('*.usb', 'bootstaller-i686.ipxe', '.upload') 

file 'bootstaller-i686.ipxe' => 'bootstaller-x86_64.ipxe' do |t|
  sh "sed -f i386.sed #{t.prerequisites.first} > #{t.name}"
end

rule '.usb' => ['.ipxe'] do |t|
  sh "cd ../ipxe/src; make EMBED=#{File.join Dir.getwd, t.source} bin/ipxe.usb"
  mv '../ipxe/src/bin/ipxe.usb', t.name
end

file '.upload' => ['bootstaller-i686.usb', 'bootstaller-x86_64.usb'] do |t|
  t.prerequisites.each do |bootstaller|
    bootstaller =~ /bootstaller-(.*)\.usb/ && arch = Regexp.last_match[1]
    sh "bb-images -c ${CLIENT:-staging} register --upload --source=#{bootstaller} --name='Brightbox Bootstaller' --arch=#{arch} --public=true"
    File.open(t.name, 'w')  {}
  end
end
