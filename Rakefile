require 'rake/clean'
task default: %w[bootstaller-x86_64.usb]
task all: [:default, 'centos7-ks-x86_64.usb', 'centos6-ks-x86_64.usb']
task upload: '.upload_all'

CLEAN.include('*.usb', '*.upload', '.upload_all*', 'centos6*.ipxe',
              'bootstaller-i686*.ipxe')

file 'centos6-ks-x86_64.ipxe' => 'centos7-ks-x86_64.ipxe' do |t|
  sh "sed '/^:/,$s/7/6/' #{t.prerequisites.first} > #{t.name}"
end

rule '.usb' => ['.ipxe'] do |t|
  sh "cd ../ipxe/src; make EMBED=#{File.join Dir.getwd, t.source} bin/ipxe.usb"
  mv '../ipxe/src/bin/ipxe.usb', t.name
end

rule '.upload' => ['.usb'] do |t|
  t.prerequisites.each do |bootstaller|
    bootstaller =~ /(.*)-([^-]*)\.usb$/ && (arch = Regexp.last_match[2]) &&
      (image_name = "Brightbox #{Regexp.last_match[1].capitalize}")
    sh "bb-images -c ${CLIENT:-staging} register --upload --source=#{bootstaller} --name='#{image_name}' --arch=#{arch} --public=true"
    File.open(t.name, 'w') {}
  end
end

file '.upload_all' => ['bootstaller-x86_64.upload'] do |t|
  File.open(t.name, 'w') {}
end
