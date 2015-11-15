clearclass deploying {

	file {'/var/www/':
		ensure => 'directory',
		path => '/var/www/',
		mode => '1777',
		owner => 'root',
		group => 'root',
		before => Class['apache']
	}

	file {'/var/www/project1/':
		ensure => 'directory',
		path => '/var/www/project1/',
		mode => '1777',
		owner => 'root',
		group => 'root',
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

	class { 'php': 
	    version => 'latest',
	}

	include development::create_files

	include epel
	include memcached

}


