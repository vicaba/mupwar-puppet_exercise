class deploying {

	file {'/var/www/':
		ensure => 'directory',
		path => '/var/www/',
		mode => '1777',
		owner => 'vagrant',
		group => 'vagrant',
		before => Class['apache']
	}

	file {'/var/www/project1/':
		ensure => 'directory',
		path => '/var/www/project1/',
		mode => '1777',
		owner => 'vagrant',
		group => 'vagrant',
		before => Class['apache']
	}


	class {'apache':
	}

	# Las dependencias entre apache y los vhosts se gestionan internamente
	apache::vhost { 'centos.dev':
		port    => '8080',
		docroot => '/var/www/',
	}

	apache::vhost { 'project1.dev':
		port    => '8081',
		docroot => '/var/www/project1/',
	}

	class { '::mysql::server':
		root_password => 'vagrantpass',
	}

	mysql::db { 'mpwar_test':
		user => 'vagrant',
	 	password => 'mpwardb',
	}


	host { 'mysql1':
		ip => '127.0.0.1',
	}

	host { 'memcached1':
		ip => '127.0.0.1',
	}

	class development::create_files {
		file {'/var/www/index.php':
			ensure => 'file',
			path => '/var/www/index.php',
			mode => '1777',
			owner => 'apache',
			group => 'apache',
			source => 'puppet:///modules/deploying/index1.html',
			require => File['/var/www/']
		}

		file {'/var/www/project1/index.php':
			ensure => 'file',
			path => '/var/www/project1/index.php',
			mode => '1777',
			owner => 'apache',
			group => 'apache',
			source => 'puppet:///modules/deploying/index2.html',
			require => File['/var/www/project1/']
		}
	}

	$php_version = '56'

	include ::yum::repo::remi

	if $php_version == '55' {
	    include ::yum::repo::remi_php55
	}
	elsif $php_version == '56'{
	    ::yum::managed_yumrepo { 'remi-php56':
	      descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - PHP 5.6',
	      mirrorlist     => 'http://rpms.famillecollet.com/enterprise/$releasever/php56/mirror',
	      enabled        => 1,
	      gpgcheck       => 1,
	      gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi',
	      gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-remi',
	      priority       => 1,
	    }
	}

	class { 'php': 
	    version => 'latest',
	    require => Yumrepo['remi-php56']
	}

	include development::create_files

	include epel
	include memcached

}


