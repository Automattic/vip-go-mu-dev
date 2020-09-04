#!/usr/bin/env node

const program = require( 'commander' );
const fs = require( 'fs' );
const ejs = require( 'ejs' );
const cp = require( 'child_process' );

const defaultPHP = '7.3';

const containerImages = {
	'wordpress': {
		image: 'wpvipdev/wordpress',
		tag: '5.5.1',
	},
	'jetpack': {
		image: 'wpvipdev/jetpack',
		tag: '8.8',
	},
	'muplugins': {
		image: 'wpvipdev/mu-plugins',
		tag: 'auto',
		//tag: 'aabaf807ee150e7c29679410c754c037ed734023',
	},
	'skeleton': {
		image: 'wpvipdev/skeleton',
		tag: '181a17d9aedf7da73730d65ccef3d8dbf172a5c5',
	}
}

program
	.command( 'create <slug>' )
	.description( 'Create a new local development instance' )
	.arguments( 'slug', 'Short name to be used for the lando project and the internal domain' )
	.option( '-t, --title <title>', 'Title for the WordPress site (default: "VIP Dev"' )
	.option( '-m, --multisite', 'Enable multisite install' )
	.option( '-s, --site <site_id>', 'Get all options below for a specific site' )
	.option( '-p, --php <php-version>', 'Use a specific PHP version (default: ' + defaultPHP + ')' )
	.option( '-w, --wordpress <wordpress>', 'Use a specific WordPress version or local directory (default: last stable)' )
	.option( '-u, --mu-plugins <mu-plugins>', 'Use a specific mu-plugins changeset or local directory (default: "auto": last commit in master)' )
	.option( '-j, --jetpack <jetpack>', 'Use a specific Jetpack version or local directory (default: last stable)' )
	.option( '-c, --client-code <clientcode>', 'Use the client code from github or a local directory (default: use the VIP skeleton)' )
	.option( '--no-start', 'If provided, don\'t start the Lando environment, just create it' )
	.action( createAction );

program
	.command( 'upgrade <slug>' )
	.description( 'Upgrade versions for one or more components of a development instance' )
	.arguments( 'slug', 'Name of the development instance' )
	.option( '-p, --php <php-version>', 'Use a specific PHP version (default: ' + defaultPHP + ')' )
	.option( '-w, --wordpress <wordpress>', 'Use a specific WordPress version or local directory' )
	.option( '-u, --mu-plugins <mu-plugins>', 'Use a specific mu-plugins changeset or local directory ("auto" for auto updates)' )
	.option( '-j, --jetpack <jetpack>', 'Use a specific Jetpack version or local directory' )
	.option( '-c, --client-code <clientcode>', 'Use the client code from github or a local directory' )
	.action( upgradeAction );

program.parse( process.argv );

async function createAction( slug, options ) {
	const sitePath = 'site-' + slug;
	if ( fs.existsSync( sitePath ) ) {
		return console.error( 'Instance ' + slug + ' already exists' );
	}
	fs.mkdirSync( sitePath );

	// Fill options if a site is provided
	// TODO: Detect incompatible options
	if ( options.site ) {
		setOptionsForSiteId( options, options.site );
	}

	let siteData = {
		siteSlug: slug,
		wpTitle: options.title || 'VIP Dev',
		multisite: options.multisite || false,
		wordpress: {},
		muplugins: {},
		jetpack: {},
		clientcode: {},
	};

	updateSiteDataWithOptions( siteData, options );

	await prepareLandoEnv( siteData, sitePath );

	console.log( siteData );
	fs.writeFileSync( sitePath + '/siteData.json', JSON.stringify( siteData ) );

	if ( options.start ) {
		landoStart( sitePath );
		console.log( 'Lando environment created on directory "' + sitePath + '" and started.' );
	} else {
		console.log( 'Lando environment created on directory "' + sitePath + '".' );
		console.log( 'You can cd into that directory and run "lando start"' );
	}
}

async function upgradeAction( slug, options ) {
	const sitePath = 'site-' + slug;
	const siteData = JSON.parse( fs.readFileSync( sitePath + '/siteData.json' ) );

	updateSiteDataWithOptions( siteData, options );

	fs.writeFileSync( sitePath + '/siteData.json', JSON.stringify( siteData ) );

	await prepareLandoEnv( siteData, sitePath );

	landoRebuild( sitePath );
}

function setOptionsForSiteId( options, siteId ) {
    let response = cp.execSync( 'vipgo api GET /sites/' + siteId ).toString();
	const siteInfo = JSON.parse( response );

	options.title = siteInfo.data[0].name + ' (' + siteId + ')';

	const repo = siteInfo.data[0].source_repo;
	const branch = siteInfo.data[0].source_repo_branch;
	options.clientCode = 'git@github.com:' + repo + '#' + branch

    response = cp.execSync( 'vipgo api GET /sites/' + siteId + '/allocations' ).toString();
	const siteAllocations = JSON.parse( response );

	siteAllocations.data.forEach( ( allocation ) => {
		if ( allocation.container_type_id == 1 ) {
			options.wp = allocation.software_stack_name.split( ' ' ).slice( -1 )[0];
			options.php = allocation.container_image_name.split( ' ' ).slice( -1 )[0];
		}
	} );
}

function updateSiteDataWithOptions( siteData, options ) {
	updatePhpData( siteData, options.php );
	updateWordPressData( siteData, options.wordpress );
	updateMuPluginsData( siteData, options.muPlugins );
	updateJetpackData( siteData, options.jetpack );
	updateClientCodeData( siteData, options.clientCode );
}

function updatePhpData( siteData, phpParam ) {
	if ( phpParam ) {
		siteData.phpVersion = phpParam;
	} else if ( ! siteData.phpVersion ) {
		siteData.phpVersion = defaultPHP;
	}
}

function updateWordPressData( siteData, wpParam ) {
	if ( wpParam ) {
		if ( wpParam.includes( '/' ) ) {
			siteData.wordpress = {
				mode: 'local',
				dir: wpParam,
			}
		} else {
			siteData.wordpress = {
				mode: 'image',
				image: containerImages['wordpress'].image,
				tag: wpParam,
			}
		}
	} else if ( ! siteData.wordpress.mode ) {
		siteData.wordpress = {
			mode: 'image',
			image: containerImages['wordpress'].image,
			tag: containerImages['wordpress'].tag,
		}
	}
}

function updateMuPluginsData( siteData, muParam ) {
	if ( muParam ) {
		if ( muParam.includes( '/' ) ) {
			siteData.muplugins = {
				mode: 'local',
				dir: muParam,
			}
		} else {
			siteData.muplugins = {
				mode: 'image',
				image: containerImages['muplugins'].image,
				tag: muParam,
			}
		}
	} else if ( ! siteData.muplugins.mode ) {
		siteData.muplugins = {
			mode: 'image',
			image: containerImages['muplugins'].image,
			tag: containerImages['muplugins'].tag,
		}
	}
}

function updateJetpackData( siteData, jpParam ) {
	if ( jpParam ) {
		if ( jpParam.includes( '/' ) ) {
			siteData.jetpack = {
				mode: 'local',
				dir: jpParam,
			}
		} else {
			siteData.jetpack = {
				mode: 'image',
				image: containerImages['jetpack'].image,
				tag: jpParam,
			}
		}
	} else if ( ! siteData.jetpack.mode ) {
		siteData.jetpack = {
			mode: 'image',
			image: containerImages['jetpack'].image,
			tag: containerImages['jetpack'].tag,
		}
	}
}

function updateClientCodeData( siteData, codeParam ) {
	if ( codeParam ) {
		if ( codeParam.includes( 'github' ) ) {
			siteData.clientcode = {
				mode: 'git',
				repo: codeParam,
				fetched: false,
			}
		} else {
			siteData.clientcode = {
				mode: 'local',
				dir: codeParam,
			}
		}
	} else if ( ! siteData.clientcode.mode ) {
		siteData.clientcode = {
			mode: 'image',
			image: containerImages['skeleton'].image,
			tag: containerImages['skeleton'].tag,
		}
	}
}

async function prepareLandoEnv( siteData, sitePath ) {
	if ( siteData.clientcode.mode == 'git' && ! siteData.clientcode.fetched ) {
		const clonePath = sitePath + '/clientcode';
		fs.rmdirSync(clonePath, { recursive: true });

		console.log( 'Cloning client code repo: ' + siteData.clientcode.repo );

		let [ repo, branch ] = siteData.clientcode.repo.split( '#' );

		let cmd = 'git clone ' + repo + ' ' + clonePath;
		if ( branch ) {
			cmd += ' --branch ' + branch;
		}

		cp.execSync( cmd );
		siteData.clientcode.fetched = true;
		siteData.clientcode.dir = './clientcode';
	}
	const landoFile = await ejs.renderFile( '.lando.yml.ejs', siteData );
	fs.writeFileSync( sitePath + '/.lando.yml', landoFile );
}

function landoStart( sitePath ) {
	cp.execSync( 'lando start', { cwd: sitePath, stdio: 'inherit' } );
}

function landoRebuild( sitePath ) {
	cp.execSync( 'lando rebuild -y', { cwd: sitePath, stdio: 'inherit' } );
}
