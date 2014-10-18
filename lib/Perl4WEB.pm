package Perl4WEB;
use Dancer2;
use Dancer2::Plugin::DBIC qw(schema rset);
use DBIx::Class::Schema::Loader;
our $VERSION = '0.1';

schema('default')->source('Sometable')->resultset_attributes({rows=>20});

get '/' => sub {	
	my @columns = schema('default')->source('Sometable')->columns;
    my @rows;
    for my $row ( rset('Sometable')->page(param('page') || 1)->all ) {
    	push @rows, { 
			data => [ map { $row->$_ } @columns ],
			id => map { $row->$_ } schema('default')->source('Sometable')->primary_columns
    	}
    }
    
    template 'index', { 
    	columns => \@columns,
    	rows => \@rows,
    	page => param('page') || 1
    };
};

get '/delete' => sub {
	redirect '/?page=' . (param('page') || 1) if (!param('id')); 
	rset('Sometable')->find({id => param('id')})->delete;
	redirect '/?page=' . (param('page') || 1); 
};

get '/create' => sub {
	my %params = params;
	delete $params{$_} foreach schema('default')->source('Sometable')->primary_columns, "page";
	rset('Sometable')->create(\%params);
	redirect '/?page=' . (param('page') || 1); 
};

true;
